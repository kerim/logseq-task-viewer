import Foundation

enum LogseqCLIError: Error, LocalizedError {
    case invalidConfig
    case commandFailed(String)
    case conversionFailed(String)
    case decodingFailed(String)
    case processError(String)

    var errorDescription: String? {
        switch self {
        case .invalidConfig:
            return "Invalid CLI configuration. Check graph name and CLI paths."
        case .commandFailed(let msg):
            return "Logseq CLI command failed: \(msg)"
        case .conversionFailed(let msg):
            return "EDN to JSON conversion failed: \(msg)"
        case .decodingFailed(let msg):
            return "Failed to decode response: \(msg)"
        case .processError(let msg):
            return "Process execution error: \(msg)"
        }
    }
}

class LogseqCLIClient: @unchecked Sendable {
    private let config: CLIConfig

    init(config: CLIConfig) {
        self.config = config
    }

    /// List all available graphs
    func listGraphs() async throws -> [String] {
        guard config.isValid else {
            throw LogseqCLIError.invalidConfig
        }

        let (stdout, stderr, exitCode) = try await executeProcess(
            path: config.logseqCLIPath,
            arguments: ["list"]
        )

        guard exitCode == 0 else {
            throw LogseqCLIError.commandFailed(stderr)
        }

        // Parse output like:
        // DB Graphs:
        //   graph-name-1
        //   graph-name-2

        let lines = stdout.split(separator: "\n")
        var graphs: [String] = []
        var inDBSection = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "DB Graphs:" {
                inDBSection = true
                continue
            }
            if inDBSection && !trimmed.isEmpty && trimmed != "File Graphs:" {
                graphs.append(trimmed)
            }
            if trimmed == "File Graphs:" {
                break  // Only interested in DB graphs
            }
        }

        return graphs
    }

    /// Execute a datalog query and return parsed blocks
    func executeQuery(_ query: String) async throws -> [LogseqBlock] {
        guard config.isValid else {
            throw LogseqCLIError.invalidConfig
        }

        // Step 1: Execute logseq query command
        let (stdout, stderr, exitCode) = try await executeProcess(
            path: config.logseqCLIPath,
            arguments: ["query", query, "-g", config.graphName]
        )

        print("=== CLI Execution Details ===")
        print("Exit Code: \(exitCode)")
        print("STDOUT:")
        print("```")
        print(stdout)
        print("```")
        if !stderr.isEmpty {
            print("STDERR:")
            print("```")
            print(stderr)
            print("```")
        }

        guard exitCode == 0 else {
            throw LogseqCLIError.commandFailed(stderr)
        }

        // Step 2: Convert EDN output to JSON using jet
        print("=== Converting EDN to JSON ===")
        let jsonData = try await convertEDNtoJSON(stdout)

        // Debug: Print JSON data
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Converted JSON:")
            print("```")
            print(jsonString)
            print("```")
        } else {
            print("Failed to convert JSON data to string")
        }

        // Step 3: Decode JSON to LogseqBlock array
        do {
            // Handle empty/nil response case
            if jsonData.isEmpty || jsonData == Data("[null]".utf8) || jsonData == Data("null".utf8) {
                print("No tasks found - returning empty array")
                return [] // Return empty array for no results
            }
            
            // Debug: Show what we're trying to decode
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Attempting to decode JSON: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            
            // Logseq CLI returns results in format: [[block1, block2, ...]]
            // Try to decode as array of arrays of blocks (old format)
            if let nestedBlocks = try? decoder.decode([[LogseqBlock]].self, from: jsonData) {
                return nestedBlocks.flatMap { $0 }
            }
            
            // Try to decode as array of block+status tuples (new format)
            if let blockWithStatusTuples = try? decoder.decode([LogseqBlockWithStatus].self, from: jsonData) {
                return blockWithStatusTuples.map { $0.block }
            }
            
            // If that fails, try as direct array of blocks
            if let directBlocks = try? decoder.decode([LogseqBlock].self, from: jsonData) {
                return directBlocks
            }
            
            // Try simple block format for debug queries
            if let simpleNestedBlocks = try? decoder.decode([[SimpleLogseqBlock]].self, from: jsonData) {
                return simpleNestedBlocks.flatMap { $0 }.map {
                    LogseqBlock(uuid: $0.uuid, content: $0.content)
                }
            }
            
            // Try direct simple block format
            if let simpleDirectBlocks = try? decoder.decode([SimpleLogseqBlock].self, from: jsonData) {
                return simpleDirectBlocks.map {
                    LogseqBlock(uuid: $0.uuid, content: $0.content)
                }
            }
            
            // If we get here, try to decode as raw data to see what we're getting
            if let rawData = try? JSONSerialization.jsonObject(with: jsonData) as? [Any] {
                print("Raw decoded data structure: \(rawData)")
                return []
            }
            
            // Final fallback
            throw LogseqCLIError.decodingFailed("Failed to decode response: The data couldn't be read because it is missing or format is unexpected")
        } catch {
            throw LogseqCLIError.decodingFailed(error.localizedDescription)
        }
    }

    /// Fetch tasks with "Doing" status and resolve block references in titles
    func fetchDoingTasks() async throws -> [LogseqBlock] {
        let query = DatalogQueryBuilder.doingTasksQuery()
        var blocks = try await executeQuery(query)
        
        print("DEBUG: Found \(blocks.count) blocks before resolution")
        for block in blocks {
            print("DEBUG: Original title: \(block.title ?? "nil")")
        }
        
        // Resolve block references in task titles
        blocks = try await resolveBlockReferencesInTitles(blocks)
        
        print("DEBUG: After resolution:")
        for block in blocks {
            print("DEBUG: Resolved title: \(block.title ?? "nil")")
        }
        
        return blocks
    }

    /// Resolve block references in task titles (e.g., [[uuid]] -> actual title)
    func resolveBlockReferencesInTitles(_ blocks: [LogseqBlock]) async throws -> [LogseqBlock] {
        print("DEBUG: ***** STARTING REFERENCE RESOLUTION *****")
        
        // Extract all UUIDs from task titles that need resolution
        var uuidToResolve = Set<String>()
        
        for block in blocks {
            if let title = block.title {
                // Find all UUID patterns in the title
                let pattern = "\\[\\[([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})\\]\\]"
                let regex = try? NSRegularExpression(pattern: pattern)
                
                if let regex = regex {
                    let matches = regex.matches(in: title, range: NSRange(title.startIndex..., in: title))
                    for match in matches {
                        if match.numberOfRanges > 1 {
                            let uuidRange = match.range(at: 1)
                            if let substringRange = Range(uuidRange, in: title) {
                                let uuid = String(title[substringRange])
                                uuidToResolve.insert(uuid)
                                print("DEBUG: Found UUID to resolve: \(uuid)")
                            }
                        }
                    }
                }
            }
        }
        
        // If no UUIDs to resolve, return original blocks
        if uuidToResolve.isEmpty {
            print("DEBUG: No UUIDs found to resolve")
            return blocks
        }
        
        print("DEBUG: Found \(uuidToResolve.count) UUIDs to resolve: \(uuidToResolve.joined(separator: ", "))")
        
        // Build a mapping of UUID to resolved title
        var uuidToTitleMap = [String: String]()
        
        for uuid in uuidToResolve {
            print("DEBUG: Resolving UUID: \(uuid)")
            let resolveQuery = "[:find (pull ?b [:block/uuid :block/title]) :where [?b :block/uuid #uuid \"" + uuid + "\"]]"
            
            let (stdout, _, exitCode) = try await executeProcess(
                path: config.logseqCLIPath,
                arguments: ["query", resolveQuery, "-g", config.graphName]
            )
            
            guard exitCode == 0, !stdout.isEmpty, stdout != "()" else {
                print("DEBUG: Resolution failed for UUID \(uuid)")
                continue
            }
            
            print("DEBUG: Resolution result: \(stdout)")
            
            // Parse the EDN result to extract title
            // Look for pattern: :block/title "actual-title"
            let pattern = ":block/title \"([^\"]*)\""
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let matches = regex.matches(in: stdout, range: NSRange(stdout.startIndex..., in: stdout))
                if let match = matches.first, match.numberOfRanges > 1 {
                    let titleRange = match.range(at: 1)
                    if let substringRange = Range(titleRange, in: stdout) {
                        let title = String(stdout[substringRange])
                        uuidToTitleMap[uuid] = title
                        print("DEBUG: Resolved \(uuid) → \(title)")
                    }
                }
            }
        }
        
        // Replace UUID references with resolved titles in block titles
        var resolvedBlocks = [LogseqBlock]()
        
        for block in blocks {
            if var title = block.title {
                print("DEBUG: Original title before replacement: \(title)")
                
                // Find which UUIDs are actually present in this title and replace only those
                for (uuid, resolvedTitle) in uuidToTitleMap {
                    // Use actual brackets, not escaped ones
                    let pattern = "[[" + uuid + "]]"
                    
                    // Debug: Check if the UUID is in the title using different methods
                    let containsPattern = title.contains(pattern)
                    let rangeOfPattern = title.range(of: pattern)
                    
                    print("DEBUG: Checking UUID \(uuid) in title")
                    print("DEBUG: Pattern: \(pattern)")
                    print("DEBUG: contains(pattern): \(containsPattern)")
                    print("DEBUG: range(of: pattern): \(rangeOfPattern != nil)")
                    
                    // Check if this UUID is actually in the current title
                    if containsPattern {
                        let oldTitle = title
                        title = title.replacingOccurrences(of: pattern, with: "[[" + resolvedTitle + "]]")
                        if title != oldTitle {
                            print("DEBUG: Successfully replaced \(uuid) with \(resolvedTitle)")
                            print("DEBUG: Title changed from: \(oldTitle)")
                            print("DEBUG: Title changed to: \(title)")
                        } else {
                            print("DEBUG: WARNING: Replacement failed for \(uuid) -> \(resolvedTitle) even though pattern was found")
                        }
                    } else {
                        print("DEBUG: Skipping \(uuid) -> \(resolvedTitle) (not found in this title)")
                    }
                }
                
                print("DEBUG: Final resolved title: \(title)")
                
                // Create a new block with the resolved title using JSON encoding/decoding
                // This is necessary because LogseqBlock is a struct with let properties
                let encoder = JSONEncoder()
                let decoder = JSONDecoder()
                
                do {
                    print("DEBUG: Starting JSON encoding/decoding process")
                    
                    // Encode the original block
                    let encodedData = try encoder.encode(block)
                    print("DEBUG: Successfully encoded block, data size: \(encodedData.count)")
                    
                    // Decode it back to a mutable dictionary
                    var jsonObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any] ?? [:]
                    print("DEBUG: Successfully decoded to dictionary: \(jsonObject)")
                    
                    // Update the title in the dictionary
                    jsonObject["block/title"] = title
                    print("DEBUG: Updated title in dictionary to: \(title)")
                    
                    // Re-encode the modified dictionary
                    let modifiedData = try JSONSerialization.data(withJSONObject: jsonObject)
                    print("DEBUG: Successfully re-encoded modified data, size: \(modifiedData.count)")
                    
                    // Decode back to LogseqBlock
                    let resolvedBlock = try decoder.decode(LogseqBlock.self, from: modifiedData)
                    print("DEBUG: Successfully decoded resolved block with title: \(resolvedBlock.title ?? "nil")")
                    resolvedBlocks.append(resolvedBlock)
                } catch {
                    print("ERROR: Failed in JSON encoding/decoding process: $error")
                    print("DEBUG: Falling back to simple block creation")
                    // If encoding/decoding fails, create a simple block with the resolved title
                    resolvedBlocks.append(LogseqBlock(uuid: block.uuid, content: title))
                }
            } else {
                resolvedBlocks.append(block)
            }
        }
        
        print("DEBUG: Reference resolution complete")
        return resolvedBlocks
    }

    /// Check if CLI is available and working
    func checkCLIAvailable() async -> Bool {
        do {
            let (_, _, exitCode) = try await executeProcess(
                path: config.logseqCLIPath,
                arguments: ["--version"]
            )
            return exitCode == 0
        } catch {
            return false
        }
    }

    // MARK: - Private Helpers

    /// Execute a process and return stdout, stderr, exit code
    func executeProcess(path: String, arguments: [String]) async throws -> (stdout: String, stderr: String, exitCode: Int32) {
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = arguments

            // Set up environment
            var environment = ProcessInfo.processInfo.environment
            environment["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
            process.environment = environment

            // Set working directory to home (avoids EPERM errors)
            process.currentDirectoryURL = FileManager.default.homeDirectoryForCurrentUser

            // Capture output
            let outPipe = Pipe()
            let errPipe = Pipe()
            process.standardOutput = outPipe
            process.standardError = errPipe

            do {
                try process.run()

                process.waitUntilExit()

                let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

                let stdout = String(data: outData, encoding: .utf8) ?? ""
                let stderr = String(data: errData, encoding: .utf8) ?? ""

                continuation.resume(returning: (stdout, stderr, process.terminationStatus))
            } catch {
                continuation.resume(throwing: LogseqCLIError.processError(error.localizedDescription))
            }
        }
    }

    /// Convert EDN string to JSON using jet CLI
    private func convertEDNtoJSON(_ edn: String) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            print("=== Jet Conversion ===")
            print("Input EDN:")
            print("```")
            print(edn)
            print("```")

            let process = Process()
            process.executableURL = URL(fileURLWithPath: config.jetCLIPath)
            process.arguments = ["--to", "json"]

            let inPipe = Pipe()
            let outPipe = Pipe()
            let errPipe = Pipe()

            process.standardInput = inPipe
            process.standardOutput = outPipe
            process.standardError = errPipe

            do {
                try process.run()

                // Write EDN to stdin
                if let ednData = edn.data(using: .utf8) {
                    inPipe.fileHandleForWriting.write(ednData)
                }
                try inPipe.fileHandleForWriting.close()

                process.waitUntilExit()

                let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

                print("Jet exit code: \(process.terminationStatus)")
                
                if !errData.isEmpty, let stderr = String(data: errData, encoding: .utf8) {
                    print("Jet STDERR:")
                    print("```")
                    print(stderr)
                    print("```")
                }

                if process.terminationStatus == 0 {
                    if let jsonString = String(data: outData, encoding: .utf8) {
                        print("Jet output:")
                        print("```")
                        print(jsonString)
                        print("```")
                    }
                    continuation.resume(returning: outData)
                } else {
                    let stderr = String(data: errData, encoding: .utf8) ?? "Unknown error"
                    continuation.resume(throwing: LogseqCLIError.conversionFailed(stderr))
                }
            } catch {
                continuation.resume(throwing: LogseqCLIError.processError(error.localizedDescription))
            }
        }
    }
}

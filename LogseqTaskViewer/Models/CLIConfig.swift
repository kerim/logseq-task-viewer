import Foundation

struct CLIConfig: Codable {
    var graphName: String = ""
    var logseqCLIPath: String = "/opt/homebrew/bin/logseq"
    var jetCLIPath: String = "/opt/homebrew/bin/jet"

    var isValid: Bool {
        !graphName.isEmpty &&
        FileManager.default.fileExists(atPath: logseqCLIPath) &&
        FileManager.default.fileExists(atPath: jetCLIPath)
    }
}

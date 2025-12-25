import Foundation
import Combine
import AppKit

/// ViewModel for managing task data and state
@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [LogseqBlock] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showingSettings: Bool = false
    @Published var customQuery: String = ""
    @Published var currentQueryType: String = "DOING"
    @Published var queryManagerWindow: QueryManagerWindowController?
    @Published var hasMoreResults: Bool = false

    private let maxDisplayResults = 50

    nonisolated let client: LogseqCLIClient  // Made accessible for graph selection
    private var cancellables = Set<AnyCancellable>()
    
    init(client: LogseqCLIClient) {
        self.client = client
    }
    
    /// Load DOING tasks
    func loadDoingTasks() async {
        print("DEBUG: loadDoingTasks called on ViewModel: \(ObjectIdentifier(self))")
        // Use the new executeCustomQuery method for consistency
        let doingQuery = DatalogQueryBuilder.doingTasksQuery()
        await executeCustomQuery(doingQuery, queryName: "DOING")
    }
    
    /// Load cached tasks (for UI development without live queries)
    func loadCachedTasks() {
        isLoading = true
        errorMessage = nil
        
        // Simulate loading with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // Create test data with properties
            var tasks: [LogseqBlock] = []
            
            // Task 1: With priority A, scheduled and deadline
            tasks.append(LogseqBlock(
                uuid: "6933c742-69e9-40a9-b049-1337cf92723f", 
                content: "1st December [[Triptych]] post",
                priority: "A",
                scheduled: 20231201,
                deadline: 20231215
            ))
            
            // Task 2: With priority B, deadline only
            tasks.append(LogseqBlock(
                uuid: "692a5166-51dd-420e-8b97-4bdae021dc11",
                content: "[[revise HTTL manuscript]]",
                priority: "B",
                scheduled: nil,
                deadline: 20231231
            ))
            
            // Task 3: With priority C, scheduled only
            tasks.append(LogseqBlock(
                uuid: "68f48c61-41f6-4ff1-a612-ea7338ebbbeb",
                content: "Watch [[TIEFF 2025]] Films that I haven't seen yet",
                priority: "C",
                scheduled: 20240101,
                deadline: nil
            ))
            
            self?.tasks = tasks
            self?.isLoading = false
        }
    }
    
    /// Clear all tasks
    func clearTasks() {
        tasks = []
    }
    
    /// Execute custom datalog query
    func executeCustomQuery(_ query: String, queryName: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        // Debug: Log which query is being executed
        if query.contains("priority") && query.contains("\"A\"") {
            print("DEBUG: Executing HIGH PRIORITY query")
        } else if query.contains("\"Doing\"") {
            print("DEBUG: Executing DOING query")
        } else if query.contains("\"TODO\"") {
            print("DEBUG: Executing TODO query")
        } else {
            print("DEBUG: Executing CUSTOM query")
        }
        
        // Set query type based on provided name or query content
        if let name = queryName {
            currentQueryType = name
            print("DEBUG: Set currentQueryType to: \(name)")
        } else {
            // Fallback string-matching logic for backward compatibility
            if query.contains("\"Doing\"") {
                currentQueryType = "DOING"
            } else if query.contains("\"TODO\"") {
                currentQueryType = "TODO"
            } else if query.contains("\"A\"") && query.contains("priority") {
                currentQueryType = "HIGH PRIORITY"
            } else {
                currentQueryType = "CUSTOM"
            }
            print("DEBUG: Fallback detection set currentQueryType to: \(currentQueryType)")
        }
        
        // Force UI update by triggering objectWillChange
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
        do {
            let blocks = try await client.executeQuery(query)

            // Limit results FIRST for menu bar display (before expensive block reference resolution)
            let totalCount = blocks.count
            let limitedBlocks = totalCount > maxDisplayResults ? Array(blocks.prefix(maxDisplayResults)) : blocks
            hasMoreResults = totalCount > maxDisplayResults

            if hasMoreResults {
                print("DEBUG: Limiting to \(maxDisplayResults) of \(totalCount) results before resolving block references")
            }

            // THEN resolve block references only for the limited set
            let resolvedBlocks = try await client.resolveBlockReferencesInTitles(limitedBlocks)

            tasks = resolvedBlocks
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    /// Toggle settings visibility
    func toggleSettings() {
        showingSettings.toggle()
    }

    /// Open the Query Manager window
    func openQueryManager() {
        if queryManagerWindow == nil {
            queryManagerWindow = QueryManagerWindowController(viewModel: self)
        }
        queryManagerWindow?.showWindow(nil)
        queryManagerWindow?.window?.makeKeyAndOrderFront(nil)
    }

    /// Execute query for preview without updating UI state
    func executeQueryForPreview(_ query: String) async throws -> [LogseqBlock] {
        return try await client.executeQuery(query)
    }
}

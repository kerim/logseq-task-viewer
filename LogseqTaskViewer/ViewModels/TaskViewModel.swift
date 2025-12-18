import Foundation
import Combine

/// ViewModel for managing task data and state
@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [LogseqBlock] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private nonisolated let client: LogseqCLIClient
    private var cancellables = Set<AnyCancellable>()
    
    init(client: LogseqCLIClient) {
        self.client = client
    }
    
    /// Load DOING tasks
    func loadDoingTasks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let blocks = try await client.fetchDoingTasks()
            tasks = blocks
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
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
}
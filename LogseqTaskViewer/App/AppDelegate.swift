import SwiftUI
import AppKit
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var viewModel: TaskViewModel?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "checkmark.circle",
                                 accessibilityDescription: "Tasks")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover (content will be created when first shown)
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 600)
        popover?.behavior = .transient

        // Initialize view model and load cached data for immediate UI
        initializeViewModel()
    }

    @MainActor
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        guard let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            // Create content only when first shown to avoid layout issues
            if popover.contentViewController == nil {
                if let viewModel = viewModel {
                    popover.contentViewController = NSHostingController(
                        rootView: TaskListView(viewModel: viewModel)
                            .frame(width: 400, height: 600)
                    )
                } else {
                    popover.contentViewController = NSHostingController(
                        rootView: Text("Loading...")
                            .frame(width: 400, height: 600)
                    )
                }
            }
            
            // Use robust activation approach
            activateAppAndShowPopover(button: button, popover: popover)
        }
    }
    
    /// Activate app and show popover with proper focus handling
    private func activateAppAndShowPopover(button: NSStatusBarButton, popover: NSPopover) {
        // Ensure app is active
        NSApp.activate(ignoringOtherApps: true)
        
        // Create temporary window if no windows exist to ensure proper activation
        var tempWindow: NSWindow?
        if NSApp.windows.isEmpty {
            tempWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            tempWindow?.makeKeyAndOrderFront(nil)
        }
        
        // Configure popover
        popover.behavior = .transient
        popover.animates = true
        
        // Small delay to ensure activation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            print("DEBUG: Showing popover after activation delay")
            
            // Show popover
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            
            // Ensure popover window gets focus and is on top
            if let popoverWindow = popover.contentViewController?.view.window {
                popoverWindow.level = .floating
                popoverWindow.makeKeyAndOrderFront(nil)
                print("DEBUG: Popover window made key and ordered front")
            }
            
            // Clean up temporary window
            tempWindow?.close()
            
            // Additional focus handling
            if let currentWindow = NSApp.windows.first(where: { $0.isVisible }) {
                currentWindow.makeKeyAndOrderFront(nil)
            }
        }
    }

    private func initializeViewModel() {
        let config = CLIConfig(
            graphName: "LSEQ 2025-12-15",
            logseqCLIPath: "/opt/homebrew/bin/logseq",
            jetCLIPath: "/opt/homebrew/bin/jet"
        )

        let client = LogseqCLIClient(config: config)
        // Store the graph name in UserDefaults so URL generation can access it
        UserDefaults.standard.set(config.graphName, forKey: "selectedGraph")
        viewModel = TaskViewModel(client: client)
        print("DEBUG: AppDelegate created ViewModel: \(ObjectIdentifier(viewModel as AnyObject))")

        // Load last used query or fall back to DOING tasks
        let storage = QueryStorageService()

        // Run one-time migration to new query versioning system
        storage.migrateQueriesIfNeeded()

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
            Task {
                if let lastQuery = storage.loadLastUsedQuery() {
                    // Load last used query with explicit query name
                    await self.viewModel?.executeCustomQuery(lastQuery.queryText, queryName: lastQuery.name)
                } else {
                    // Fallback to DOING tasks using the new execution path
                    let doingQuery = DatalogQueryBuilder.doingTasksQuery()
                    await self.viewModel?.executeCustomQuery(doingQuery, queryName: "DOING")
                }
            }
        }
    }


}

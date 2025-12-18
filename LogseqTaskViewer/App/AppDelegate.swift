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
            
            // Use dispatch to avoid potential layout recursion
            DispatchQueue.main.async {
                popover.show(relativeTo: button.bounds,
                            of: button,
                            preferredEdge: .minY)
                // Activate the app to ensure clicks register immediately
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    private func initializeViewModel() {
        // TODO: Replace "your-graph-name" with your actual Logseq graph name
        let config = CLIConfig(
            graphName: "LSEQ 2025-12-15",
            logseqCLIPath: "/opt/homebrew/bin/logseq",
            jetCLIPath: "/opt/homebrew/bin/jet"
        )

        let client = LogseqCLIClient(config: config)
        // Store the graph name in UserDefaults so URL generation can access it
        UserDefaults.standard.set(config.graphName, forKey: "selectedGraph")
        viewModel = TaskViewModel(client: client)
        
        // Load cached data first for immediate UI
        viewModel?.loadCachedTasks()
        
        // For development: Don't load real data to keep the test UI stable
        // Uncomment the following to load real data in production:
        // DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.0) {
        //     Task {
        //         await self.viewModel?.loadDoingTasks()
        //     }
        // }
    }


}

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
        // Debug: App launched
        let debugMessage = "DEBUG: AppDelegate.applicationDidFinishLaunching called\n"
        try? debugMessage.data(using: .utf8)?.write(to: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log"), options: .atomic)
        
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
                let debugMessage = "DEBUG: Creating popover content. viewModel is \(viewModel != nil ? "not nil" : "nil")\n"
                try? debugMessage.data(using: .utf8)?.write(to: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log"), options: .atomic)
                
                if let viewModel = viewModel {
                    let debugMessage2 = "DEBUG: Using TaskListView with \(viewModel.tasks.count) tasks\n"
                    if let debugFile = try? FileHandle(forWritingTo: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log")) {
                        debugFile.seekToEndOfFile()
                        debugFile.write(debugMessage2.data(using: .utf8) ?? Data())
                        debugFile.closeFile()
                    }
                    
                    popover.contentViewController = NSHostingController(
                        rootView: TaskListView(viewModel: viewModel)
                            .frame(width: 400, height: 600)
                    )
                } else {
                    let debugMessage3 = "DEBUG: Using Loading... text instead\n"
                    if let debugFile = try? FileHandle(forWritingTo: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log")) {
                        debugFile.seekToEndOfFile()
                        debugFile.write(debugMessage3.data(using: .utf8) ?? Data())
                        debugFile.closeFile()
                    }
                    
                    popover.contentViewController = NSHostingController(
                        rootView: Text("Loading...")
                            .frame(width: 400, height: 600)
                    )
                }
            } else {
                let debugMessage4 = "DEBUG: Popover content already exists, reusing it\n"
                if let debugFile = try? FileHandle(forWritingTo: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log")) {
                    debugFile.seekToEndOfFile()
                    debugFile.write(debugMessage4.data(using: .utf8) ?? Data())
                    debugFile.closeFile()
                }
            }
            
            // Use dispatch to avoid potential layout recursion
            DispatchQueue.main.async {
                print("DEBUG: About to show popover")
                popover.show(relativeTo: button.bounds,
                            of: button,
                            preferredEdge: .minY)
                print("DEBUG: Popover shown")
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

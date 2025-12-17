import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

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

        // Test CLI connection
        testCLIConnection()
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
                popover.contentViewController = NSHostingController(
                    rootView: Text("LogseqTaskViewer")
                        .frame(width: 400, height: 600)
                )
            }
            
            // Use dispatch to avoid potential layout recursion
            DispatchQueue.main.async {
                popover.show(relativeTo: button.bounds,
                            of: button,
                            preferredEdge: .minY)
            }
        }
    }

    func testCLIConnection() {
        Task {
            // TODO: Replace "your-graph-name" with your actual Logseq graph name
            let config = CLIConfig(
                graphName: "LSEQ 2025-12-15",
                logseqCLIPath: "/opt/homebrew/bin/logseq",
                jetCLIPath: "/opt/homebrew/bin/jet"
            )

            let client = LogseqCLIClient(config: config)

            // Test 1: Check CLI is available
            let isAvailable = await client.checkCLIAvailable()
            print("CLI Available: \(isAvailable)")

            // Test 2: List graphs
            do {
                let graphs = try await client.listGraphs()
                print("Found graphs: \(graphs)")
            } catch {
                print("Error listing graphs: \(error.localizedDescription)")
            }

            // Test DOING query (isolated test)
            do {
                print("\n=== Testing DOING Query ===")
                let blocks = try await client.fetchDoingTasks()
                
                if blocks.isEmpty {
                    print("No DOING tasks found")
                } else {
                    print("Found \(blocks.count) DOING tasks")
                    
                    // Print first few blocks for inspection
                    for (index, block) in blocks.prefix(3).enumerated() {
                        print("DOING Task \(index + 1):")
                        print("  UUID: \(block.uuid)")
                        if let title = block.title {
                            print("  Title: \(title.prefix(100))...")
                        } else if let content = block.content {
                            print("  Content: \(content.prefix(100))...")
                        } else {
                            print("  Text: (no content)")
                        }
                    }
                    
                    if blocks.count > 3 {
                        print("... and \(blocks.count - 3) more DOING tasks")
                    }
                }
                
                print("\n=== DOING Query Test Complete ===")
                exit(0) // Exit after DOING query test
            } catch {
                print("Error executing DOING query: \(error.localizedDescription)")
                exit(1)
            }
        }
    }
}

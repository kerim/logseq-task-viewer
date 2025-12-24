import SwiftUI
import AppKit

/// Window controller for the Query Manager
class QueryManagerWindowController: NSWindowController {
    convenience init(viewModel: TaskViewModel) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Query Manager"
        window.minSize = NSSize(width: 600, height: 400)
        window.center()

        // Make window float on top
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Create the SwiftUI view
        let contentView = QueryManagerView(viewModel: viewModel)
        window.contentView = NSHostingView(rootView: contentView)

        self.init(window: window)
    }
}

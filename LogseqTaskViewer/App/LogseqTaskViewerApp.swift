import SwiftUI

@main
struct LogseqTaskViewerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            Text("Settings placeholder")
                .frame(width: 400, height: 300)
        }
    }
}

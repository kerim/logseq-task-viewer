import SwiftUI
import AppKit

/// Main view for displaying a list of tasks
struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    
    init(viewModel: TaskViewModel) {
        self.viewModel = viewModel
        let debugMessage = "DEBUG: TaskListView initialized with \(viewModel.tasks.count) tasks\n"
        if let debugFile = try? FileHandle(forWritingTo: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log")) {
            debugFile.seekToEndOfFile()
            debugFile.write(debugMessage.data(using: .utf8) ?? Data())
            debugFile.closeFile()
        } else {
            try? debugMessage.data(using: .utf8)?.write(to: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log"))
        }
        
        // Debug: Check task properties
        for (index, task) in viewModel.tasks.enumerated() {
            let taskDebug = "DEBUG: Task \(index): priority=\(task.priority?.name ?? "nil"), scheduled=\(task.scheduled ?? 0), deadline=\(task.deadline ?? 0)\n"
            if let debugFile = try? FileHandle(forWritingTo: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log")) {
                debugFile.seekToEndOfFile()
                debugFile.write(taskDebug.data(using: .utf8) ?? Data())
                debugFile.closeFile()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Debug: TaskListView is being rendered
            Text("")
                .hidden()
                .onAppear {
                    let debugMessage = "DEBUG: TaskListView body being rendered with \(viewModel.tasks.count) tasks\n"
                    if let debugFile = try? FileHandle(forWritingTo: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log")) {
                        debugFile.seekToEndOfFile()
                        debugFile.write(debugMessage.data(using: .utf8) ?? Data())
                        debugFile.closeFile()
                    } else {
                        try? debugMessage.data(using: .utf8)?.write(to: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log"))
                    }
                    
                    // Check if properties will be displayed
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMdd"
                    
                    for (index, task) in viewModel.tasks.enumerated() {
                        let priorityDisplay = task.priority?.name ?? "nil"
                        let scheduledDisplay = task.scheduled.flatMap { date in
                            let dateString = String(date)
                            guard dateString.count == 8 else { return nil }
                            let year = String(dateString.prefix(4))
                            let month = String(dateString.dropFirst(4).prefix(2))
                            let day = String(dateString.dropFirst(6).prefix(2))
                            return "\(year)-\(month)-\(day)"
                        } ?? "nil"
                        
                        let deadlineDisplay = task.deadline.flatMap { date in
                            let dateString = String(date)
                            guard dateString.count == 8 else { return nil }
                            let year = String(dateString.prefix(4))
                            let month = String(dateString.dropFirst(4).prefix(2))
                            let day = String(dateString.dropFirst(6).prefix(2))
                            return "\(year)-\(month)-\(day)"
                        } ?? "nil"
                        
                        let uiDebug = "DEBUG: Task \(index) UI: priority=\(priorityDisplay), scheduled=\(scheduledDisplay), deadline=\(deadlineDisplay)\n"
                        if let debugFile = try? FileHandle(forWritingTo: URL(fileURLWithPath: "/tmp/LogseqTaskViewer.debug.log")) {
                            debugFile.seekToEndOfFile()
                            debugFile.write(uiDebug.data(using: .utf8) ?? Data())
                            debugFile.closeFile()
                        }
                    }
                }
            // Header
            Text("DOING Tasks")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .foregroundColor(.secondary)
            
            // Task list
            if viewModel.tasks.isEmpty {
                EmptyTaskView()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<viewModel.tasks.count, id: \.self) { index in
                            TaskItemView(task: viewModel.tasks[index])
                                .padding(.horizontal, 16)
                             
                            // Divider except for last item
                            if index < viewModel.tasks.count - 1 {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
            }
            
            // Footer
            Text("Total: \(viewModel.tasks.count) tasks")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .background(Color(.windowBackgroundColor))
    }
}

/// View for when no tasks are found
struct EmptyTaskView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No DOING tasks found")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("All tasks are completed or not yet started.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

/// Custom text view that can handle clickable links within [[brackets]]
struct ClickableTextView: View {
    let text: String
    let onLinkClick: (String) -> Void
    let onBackgroundClick: () -> Void
    @State private var hoveredLink: String? = nil
    
    // Parse text to find [[links]]
    private func parseLinks() -> [(range: Range<String.Index>, link: String)] {
        var links: [(range: Range<String.Index>, link: String)] = []
        var searchRange = text.startIndex..<text.endIndex
        
        while let openRange = text.range(of: "[[", range: searchRange) {
            let remainingText = text[openRange.upperBound...]
            if let closeRange = remainingText.range(of: "]]") {
                let linkRange = openRange.upperBound..<closeRange.lowerBound
                let link = String(text[linkRange])
                links.append((range: openRange.lowerBound..<closeRange.upperBound, link: link))
                searchRange = closeRange.upperBound..<text.endIndex
            } else {
                break
            }
        }
        
        return links
    }
    
    var body: some View {
        let links = parseLinks()
        
        if links.isEmpty {
            // No links, just regular text
            Text(text)
                .font(.body)
                .lineLimit(2)
                .padding(.vertical, 12)
                .onTapGesture(perform: onBackgroundClick)
                .help("Click to open task in Logseq")
        } else {
            // Has links, need to build a more complex view
            buildAttributedText(links: links)
        }
    }
    
    private func buildAttributedText(links: [(range: Range<String.Index>, link: String)]) -> some View {
        var currentIndex = text.startIndex
        var views: [AnyView] = []
        
        for link in links {
            // Add text before the link
            if currentIndex < link.range.lowerBound {
                let beforeText = String(text[currentIndex..<link.range.lowerBound])
                views.append(AnyView(
                    Text(beforeText)
                        .font(.body)
                        .onTapGesture(perform: onBackgroundClick)
                        .help("Click to open task in Logseq")
                ))
            }
            
            // Add the clickable link
            let linkText = String(text[link.range])
            let isThisLinkHovered = hoveredLink == link.link
            views.append(AnyView(
                Text(linkText)
                    .font(.body)
                    .foregroundColor(isThisLinkHovered ? .blue : .blue)
                    .underline(isThisLinkHovered)
                    .background(isThisLinkHovered ? Color.blue.opacity(0.2) : Color.clear)
                    .onTapGesture {
                        onLinkClick(link.link)
                    }
                    .help("Click to open linked page in Logseq")
            ))
            
            currentIndex = link.range.upperBound
        }
        
        // Add remaining text after last link
        if currentIndex < text.endIndex {
            let afterText = String(text[currentIndex..<text.endIndex])
            views.append(AnyView(
                Text(afterText)
                    .font(.body)
                    .onTapGesture(perform: onBackgroundClick)
                    .help("Click to open task in Logseq")
            ))
        }
        
        return HStack(spacing: 0) {
            ForEach(0..<views.count, id: \.self) { index in
                views[index]
            }
        }
        .lineLimit(2)
        .padding(.vertical, 12)
    }
}

/// View for individual task item
struct TaskItemView: View {
    let task: LogseqBlock
    @State private var isHovered = false
    
    // Helper function to generate Logseq URL for opening the task
    private func logseqTaskURL() -> URL? {
        // Get the graph name from UserDefaults
        let graphName = UserDefaults.standard.string(forKey: "selectedGraph") ?? "default"
        let encodedGraphName = graphName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? graphName
        
        return URL(string: "logseq://graph/\(encodedGraphName)?block-id=\(task.uuid)")
    }
    
    // Helper function to generate Logseq URL for opening a linked page
    private func logseqPageURL(for link: String) -> URL? {
        // Get the graph name from UserDefaults
        let graphName = UserDefaults.standard.string(forKey: "selectedGraph") ?? "default"
        let encodedGraphName = graphName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? graphName
        let encodedLink = link.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? link
        
        return URL(string: "logseq://graph/\(encodedGraphName)?page=\(encodedLink)")
    }
    
    // Helper function to open URL in Logseq
    private func openLogseqURL(_ url: URL) {
        print("DEBUG: Opening Logseq URL: \(url.absoluteString)")
        NSWorkspace.shared.open(url)
    }
    
    // Helper function to format date from YYYYMMDD integer
    private func formatDate(_ dateInt: Int?) -> String? {
        guard let dateInt = dateInt else { return nil }
        
        let dateString = String(dateInt)
        guard dateString.count == 8 else { return nil }
        
        let year = String(dateString.prefix(4))
        let month = String(dateString.dropFirst(4).prefix(2))
        let day = String(dateString.dropFirst(6).prefix(2))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: "\(year)-\(month)-\(day)") {
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        
        return "\(year)-\(month)-\(day)"
    }
    
    // Helper function to get priority display
    private func priorityDisplay() -> String? {
        if let priorityRef = task.priority {
            return priorityRef.name ?? priorityRef.title
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Task title with clickable links - VISUAL TEST
            ClickableTextView(
                text: task.title ?? task.content ?? "Untitled Task",
                onLinkClick: { link in
                    NSLog("DEBUG: Link clicked: %@", link)
                    if let url = logseqPageURL(for: link) {
                        NSLog("DEBUG: Opening link URL: %@", url.absoluteString)
                        openLogseqURL(url)
                    }
                },
                onBackgroundClick: {
                    NSLog("DEBUG: Task background clicked")
                    if let url = logseqTaskURL() {
                        NSLog("DEBUG: Opening task URL: %@", url.absoluteString)
                        openLogseqURL(url)
                    }
                }
            )
            .padding(.vertical, 2)
            
            // Task properties and metadata
            HStack(spacing: 8) {
                // Priority icon (using SF Symbols)
                if let priority = priorityDisplay() {
                    let priorityIcon = priority == "A" ? "exclamationmark.2" :
                                      priority == "B" ? "exclamationmark" :
                                      "exclamationmark.3"
                    let priorityColor = priority == "A" ? Color.red :
                                      priority == "B" ? Color.orange :
                                      Color.yellow
                    
                    Image(systemName: priorityIcon)
                        .font(.caption)
                        .foregroundColor(priorityColor)
                }
                
                // Dates
                if let scheduled = formatDate(task.scheduled) {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(scheduled)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let deadline = formatDate(task.deadline) {
                    HStack(spacing: 2) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text(deadline)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status
                Text("DOING")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            NSLog("DEBUG: Task clicked - opening Logseq")
            if let url = logseqTaskURL() {
                NSLog("DEBUG: Opening URL: %@", url.absoluteString)
                openLogseqURL(url)
            }
        }
        .help("Click anywhere to open this task in Logseq")
        .padding(.vertical, 4)
        .onHover { hover in
            isHovered = hover
            if hover {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pointingHand.pop()
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.5), lineWidth: isHovered ? 2 : 0)
        )
    }
}

// Preview for development
struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TaskViewModel(client: LogseqCLIClient(config: CLIConfig()))
        viewModel.tasks = [
            LogseqBlock(uuid: "6933c742-69e9-40a9-b049-1337cf92723f", content: "1st December [[Triptych]] post"),
            LogseqBlock(uuid: "692a5166-51dd-420e-8b97-4bdae021dc11", content: "[[revise HTTL manuscript]]"),
            LogseqBlock(uuid: "68f48c61-41f6-4ff1-a612-ea7338ebbbeb", content: "Watch [[TIEFF 2025]] Films that I haven't seen yet")
        ]
        
        return TaskListView(viewModel: viewModel)
            .frame(width: 300, height: 500)
    }
}
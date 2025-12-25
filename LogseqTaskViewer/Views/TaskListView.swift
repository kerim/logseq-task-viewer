import SwiftUI
import AppKit

/// Main view for displaying a list of tasks
struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    
    init(viewModel: TaskViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        print("DEBUG: TaskListView created with ViewModel: \(ObjectIdentifier(viewModel))")
        return VStack(alignment: .leading, spacing: 0) {
            // Header with settings button
            HStack {
                Text("\(viewModel.currentQueryType) Tasks")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    viewModel.openQueryManager()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Query Manager")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Task list
            if viewModel.isLoading {
                LoadingView(queryType: viewModel.currentQueryType)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage)
            } else if viewModel.tasks.isEmpty {
                EmptyTaskView(queryType: viewModel.currentQueryType)
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
            VStack(alignment: .leading, spacing: 4) {
                Text("Total: \(viewModel.tasks.count) tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if viewModel.hasMoreResults {
                    Text("Showing first 50 results. More tasks available in Logseq.")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.windowBackgroundColor))
    }
}

/// View for when no tasks are found
struct EmptyTaskView: View {
    let queryType: String
    
    init(queryType: String) {
        self.queryType = queryType
        print("DEBUG: EmptyTaskView created with queryType: \(queryType)")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No \(queryType) tasks found")
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

/// View for when data is loading
struct LoadingView: View {
    let queryType: String
    
    init(queryType: String) {
        self.queryType = queryType
        print("DEBUG: LoadingView created with queryType: \(queryType)")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text("Loading \(queryType) tasks...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Fetching data from Logseq...")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

/// View for when an error occurs
struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Error Loading Tasks")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
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
            
            // Add the clickable link with link-specific hover effects
            let linkText = String(text[link.range])
            let isThisLinkHovered = Binding<Bool>(
                get: { self.hoveredLink == link.link },
                set: { isHovered in
                    if isHovered {
                        self.hoveredLink = link.link
                    } else {
                        self.hoveredLink = nil
                    }
                }
            )
            
            views.append(AnyView(
                Text(linkText)
                    .font(.body)
                    .foregroundColor(isThisLinkHovered.wrappedValue ? .blue : .blue)
                    .underline(isThisLinkHovered.wrappedValue)
                    .background(isThisLinkHovered.wrappedValue ? Color.blue.opacity(0.2) : Color.clear)
                    .onTapGesture {
                        onLinkClick(link.link)
                    }
                    .help("Click to open linked page in Logseq")
                    .onHover { isHovered in
                        if isHovered {
                            self.hoveredLink = link.link
                        } else {
                            self.hoveredLink = nil
                        }
                    }
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
        .onTapGesture(perform: onBackgroundClick)
        .help("Click to open task in Logseq")
    }
}

/// View for individual task item
struct TaskItemView: View {
    let task: LogseqBlock
    @State private var isTaskHovered = false
    
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
    
    // Helper function to format date from YYYYMMDD integer or timestamp
    private func formatDate(_ dateValue: Any?) -> String? {
        // Handle nil case
        guard let dateValue = dateValue else { return nil }
        
        // Try to handle as timestamp first (milliseconds since epoch)
        if let timestamp = dateValue as? Double {
            let date = Date(timeIntervalSince1970: timestamp / 1000.0)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        
        // Try to handle as YYYYMMDD integer
        if let dateInt = dateValue as? Int {
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
        
        return nil
    }
    
    // Helper function to get priority display
    private func priorityDisplay() -> String? {
        if let priorityRef = task.priority {
            return priorityRef.title ?? priorityRef.name  // Prefer title (capitalized) over name
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Task title with clickable links - VISUAL TEST
            ClickableTextView(
                text: task.title ?? task.content ?? "Untitled Task",
                onLinkClick: { link in
                    if let url = logseqPageURL(for: link) {
                        openLogseqURL(url)
                    }
                },
                onBackgroundClick: {
                    if let url = logseqTaskURL() {
                        openLogseqURL(url)
                    }
                }
            )
            .padding(.vertical, 2)
            
            // Task properties and metadata
            HStack(spacing: 8) {
                // Priority icon (using SF Symbols) - DB graph priorities
                if let priority = priorityDisplay() {
                    let priorityIcon = priority == "Urgent" ? "exclamationmark.3" :
                                      priority == "High" ? "exclamationmark.2" :
                                      priority == "Medium" ? "exclamationmark" :
                                      "arrow.down"
                    let priorityColor = priority == "Urgent" ? Color.red :
                                      priority == "High" ? Color.orange :
                                      priority == "Medium" ? Color.yellow :
                                      Color.blue

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
            if let url = logseqTaskURL() {
                openLogseqURL(url)
            }
        }
        .help("Click anywhere to open this task in Logseq")
        .padding(.vertical, 4)
        .onHover { hover in
            isTaskHovered = hover
            if hover {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pointingHand.pop()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isTaskHovered ? Color.gray.opacity(0.1) : Color.clear)
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
        viewModel.currentQueryType = "DOING"
        
        return TaskListView(viewModel: viewModel)
            .frame(width: 300, height: 500)
    }
}

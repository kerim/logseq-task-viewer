import SwiftUI

/// Main view for the Query Manager with two-pane interface
struct QueryManagerView: View {
    @ObservedObject var viewModel: TaskViewModel
    @StateObject private var queryManager = QueryManagerViewModel()

    @State private var selectedQueryId: UUID?
    @State private var editingQueryId: UUID?
    @State private var showingDeleteConfirmation = false
    @State private var showingResetConfirmation = false
    @State private var queryToDelete: SavedQuery?
    @State private var previewResults: [LogseqBlock] = []
    @State private var isPreviewLoading = false
    @State private var previewError: String?
    @State private var isLoadingQuery = false
    @State private var availableGraphs: [String] = []
    @State private var selectedGraph: String = ""

    var selectedQuery: SavedQuery? {
        queryManager.queries.first { $0.id == selectedQueryId }
    }

    var body: some View {
        HSplitView {
            // Left pane: Query list
            queryListPane
                .frame(minWidth: 200, idealWidth: 250)

            // Right pane: Query editor
            queryEditorPane
                .frame(minWidth: 400)
        }
        .frame(minWidth: 600, minHeight: 400)
        .onAppear {
            // Load available graphs
            Task {
                print("DEBUG: Loading available graphs...")
                do {
                    // Create a temporary client just for listing graphs (doesn't need a graph name)
                    let tempConfig = CLIConfig(
                        graphName: "temp",  // Dummy name just to pass validation
                        logseqCLIPath: "/opt/homebrew/bin/logseq",
                        jetCLIPath: "/opt/homebrew/bin/jet"
                    )
                    let tempClient = LogseqCLIClient(config: tempConfig)
                    let graphs = try await tempClient.listGraphs()
                    print("DEBUG: Loaded graphs: \(graphs)")
                    await MainActor.run {
                        availableGraphs = graphs
                        print("DEBUG: Set availableGraphs to: \(availableGraphs)")
                    }

                    // Load saved graph or use first available
                    if let saved = UserDefaults.standard.string(forKey: "selectedGraph"),
                       graphs.contains(saved) {
                        await MainActor.run {
                            selectedGraph = saved
                            print("DEBUG: Set selectedGraph to saved: \(saved)")
                        }
                    } else if let first = graphs.first {
                        await MainActor.run {
                            selectedGraph = first
                            print("DEBUG: Set selectedGraph to first: \(first)")
                        }
                        UserDefaults.standard.set(first, forKey: "selectedGraph")
                    }
                } catch {
                    print("ERROR: Failed to load graphs: \(error)")
                }
            }

            // Select first query on load
            if let firstQuery = queryManager.queries.first {
                selectedQueryId = firstQuery.id
            }
        }
        .alert("Delete Query", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let query = queryToDelete {
                    queryManager.deleteQuery(query)
                    if selectedQueryId == query.id {
                        selectedQueryId = queryManager.queries.first?.id
                    }
                }
            }
        } message: {
            if let query = queryToDelete {
                Text("Are you sure you want to delete '\(query.name)'?")
            }
        }
        .alert("Reset to Defaults?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                let storage = QueryStorageService()
                storage.resetToDefaults()
                queryManager.loadQueries()
                selectedQueryId = queryManager.queries.first?.id
            }
        } message: {
            Text("This will delete all custom queries and restore default queries. This cannot be undone.")
        }
    }

    // MARK: - Query List Pane

    private var queryListPane: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with graph selector
            VStack(alignment: .leading, spacing: 4) {
                // Graph selector row
                HStack {
                    Text("Graph:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Picker("", selection: $selectedGraph) {
                        if availableGraphs.isEmpty {
                            Text("Loading...").tag("")
                        } else {
                            ForEach(availableGraphs, id: \.self) { graph in
                                Text(graph).tag(graph)
                            }
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .onChange(of: selectedGraph) { newGraph in
                        if !newGraph.isEmpty {
                            UserDefaults.standard.set(newGraph, forKey: "selectedGraph")
                            // Notify AppDelegate to update config
                            NotificationCenter.default.post(
                                name: Notification.Name("GraphChanged"),
                                object: newGraph
                            )
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Divider()

                // Queries header row
                HStack {
                    Text("Saved Queries")
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)

                    Spacer()

                    Button(action: { showingResetConfirmation = true }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.subheadline)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 4)
                    .help("Reset to default queries")

                    Button(action: createNewQuery) {
                        Image(systemName: "plus")
                            .font(.subheadline)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 8)
                    .help("Create new query")
                }
            }
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Query list
            List(selection: $selectedQueryId) {
                ForEach(queryManager.queries) { query in
                    QueryListItem(
                        query: query,
                        isEditing: editingQueryId == query.id,
                        onRename: { newName in
                            queryManager.renameQuery(query, to: newName)
                            editingQueryId = nil
                        },
                        onDuplicate: { queryManager.duplicateQuery(query) },
                        onDelete: { confirmDelete(query) },
                        onStartEditing: { editingQueryId = query.id }
                    )
                    .tag(query.id)
                    .contextMenu {
                        Button("Rename") { editingQueryId = query.id }
                        Button("Duplicate") { queryManager.duplicateQuery(query) }
                        Divider()
                        Button("Delete", role: .destructive) { confirmDelete(query) }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .contextMenu(forSelectionType: UUID.self) { selectedIds in
                // Optional: additional context menu items for selected items
            } primaryAction: { selectedIds in
                // DOUBLE-CLICK ACTION - Prevent multiple simultaneous executions
                guard !isLoadingQuery, !viewModel.isLoading else {
                    print("DEBUG: Ignoring double-click - query already loading (local: \(isLoadingQuery), viewModel: \(viewModel.isLoading))")
                    return
                }

                if let queryId = selectedIds.first,
                   let query = queryManager.queries.first(where: { $0.id == queryId }) {
                    Task {
                        defer { isLoadingQuery = false }

                        isLoadingQuery = true
                        print("DEBUG: Double-click handler called for query: \(query.name)")

                        await selectAndLoadQuery(query)
                        print("DEBUG: Query loaded, attempting to close window")

                        // Small delay to ensure UI updates complete
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

                        closeWindow()
                    }
                }
            }

            // Version footer with quit button
            Divider()
            VStack(spacing: 8) {
                HStack {
                    Text("v1.0.1")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)

                Divider()

                Button(action: quitApplication) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit Application")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .keyboardShortcut("q", modifiers: .command)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
    }

    // MARK: - Query Editor Pane

    private var queryEditorPane: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let query = selectedQuery {
                // Query name
                HStack {
                    Text(query.name)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)

                // Query editor
                Text("Query")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)

                TextEditor(text: bindingForQuery(query))
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)

                // Preview button and results
                HStack {
                    Button(action: { previewQuery(query) }) {
                        HStack {
                            Image(systemName: "eye")
                            Text("Preview")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isPreviewLoading)

                    if isPreviewLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    }

                    Spacer()

                    if !previewResults.isEmpty {
                        Text("\(previewResults.count) results")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)

                // Preview results or error
                if let error = previewError {
                    ScrollView {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 150)
                    .padding(.horizontal, 16)
                } else if !previewResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(previewResults.prefix(10), id: \.uuid) { block in
                                Text(block.title ?? block.content ?? "Untitled")
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            if previewResults.count > 10 {
                                Text("... and \(previewResults.count - 10) more")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 150)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                }

                Spacer()

                // Action buttons
                HStack(spacing: 12) {
                    Spacer()

                    Button("Close") {
                        closeWindow()
                    }
                    .keyboardShortcut(.cancelAction)
                }
                .padding(16)
            } else {
                // No query selected
                VStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("Select a query to view or edit")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Actions

    private func createNewQuery() {
        let newQuery = SavedQuery(
            name: "New Query",
            queryText: "[:find (pull ?b [:block/uuid :block/content])\n :where\n [?b :block/uuid]]"
        )
        queryManager.addQuery(newQuery)
        selectedQueryId = newQuery.id
        editingQueryId = newQuery.id
    }

    private func confirmDelete(_ query: SavedQuery) {
        queryToDelete = query
        showingDeleteConfirmation = true
    }

    private func selectAndLoadQuery(_ query: SavedQuery) async {
        // Save as last used query
        queryManager.setLastUsedQuery(query)

        // Update query type immediately
        viewModel.currentQueryType = query.name

        // Load into main view model and wait for completion
        await viewModel.executeCustomQuery(query.queryText, queryName: query.name)
    }

    private func previewQuery(_ query: SavedQuery) {
        isPreviewLoading = true
        previewError = nil

        Task {
            do {
                // Use viewModel's client to execute query
                previewResults = try await viewModel.executeQueryForPreview(query.queryText)
                isPreviewLoading = false
            } catch {
                previewError = error.localizedDescription
                previewResults = []
                isPreviewLoading = false
            }
        }
    }

    private func bindingForQuery(_ query: SavedQuery) -> Binding<String> {
        Binding(
            get: { query.queryText },
            set: { newValue in
                queryManager.updateQueryText(query, text: newValue)
            }
        )
    }

    private func closeWindow() {
        // Close the Query Manager window by finding it in the open windows
        DispatchQueue.main.async {
            if let queryManagerWindow = NSApplication.shared.windows.first(where: { $0.title == "Query Manager" }) {
                print("DEBUG: Found Query Manager window, attempting to close")
                queryManagerWindow.close()
            } else {
                print("DEBUG: Query Manager window not found")
            }
        }
    }

    private func quitApplication() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Query List Item

struct QueryListItem: View {
    let query: SavedQuery
    let isEditing: Bool
    let onRename: (String) -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onStartEditing: () -> Void

    @State private var editingName: String = ""

    var body: some View {
        HStack {
            if isEditing {
                TextField("Query name", text: $editingName, onCommit: {
                    onRename(editingName)
                })
                .textFieldStyle(PlainTextFieldStyle())
                .onAppear {
                    editingName = query.name
                }
            } else {
                Text(query.name)
                    .lineLimit(1)

                Spacer()
            }
        }
        // Double-click is now handled by List's primaryAction
    }
}

import Foundation
import Combine

/// ViewModel for managing saved queries
@MainActor
class QueryManagerViewModel: ObservableObject {
    @Published var queries: [SavedQuery] = []

    private let storage = QueryStorageService()

    init() {
        loadQueries()
    }

    /// Load queries from storage
    func loadQueries() {
        queries = storage.loadQueries()
    }

    /// Add a new query
    func addQuery(_ query: SavedQuery) {
        storage.addQuery(query)
        loadQueries()
    }

    /// Update an existing query
    func updateQuery(_ query: SavedQuery) {
        storage.updateQuery(query)
        loadQueries()
    }

    /// Delete a query
    func deleteQuery(_ query: SavedQuery) {
        storage.deleteQuery(query)
        loadQueries()
    }

    /// Rename a query
    func renameQuery(_ query: SavedQuery, to newName: String) {
        var updated = query
        updated.name = newName
        updateQuery(updated)
    }

    /// Duplicate a query
    func duplicateQuery(_ query: SavedQuery) {
        let duplicate = query.duplicate()
        addQuery(duplicate)
    }

    /// Update query text
    func updateQueryText(_ query: SavedQuery, text: String) {
        var updated = query
        updated.queryText = text
        updateQuery(updated)
    }

    /// Save as last used query
    func setLastUsedQuery(_ query: SavedQuery) {
        storage.saveLastUsedQueryId(query.id)
    }
}

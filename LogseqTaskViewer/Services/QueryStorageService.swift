import Foundation

/// Service for managing query storage using UserDefaults
class QueryStorageService {
    private let queriesKey = "savedQueries"
    private let lastUsedQueryIdKey = "lastUsedQueryId"

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Query Management

    /// Save queries to UserDefaults
    func saveQueries(_ queries: [SavedQuery]) {
        if let encoded = try? encoder.encode(queries) {
            defaults.set(encoded, forKey: queriesKey)
        }
    }

    /// Load queries from UserDefaults, or populate with defaults if empty
    func loadQueries() -> [SavedQuery] {
        var queries: [SavedQuery] = []

        if let data = defaults.data(forKey: queriesKey),
           let decoded = try? decoder.decode([SavedQuery].self, from: data) {
            queries = decoded
        }

        // If empty, populate with defaults
        if queries.isEmpty {
            queries = defaultQueries()
            saveQueries(queries)
        }

        return queries
    }

    /// Add a new query
    func addQuery(_ query: SavedQuery) {
        var queries = loadQueries()
        queries.append(query)
        saveQueries(queries)
    }

    /// Update an existing query
    func updateQuery(_ query: SavedQuery) {
        var queries = loadQueries()
        if let index = queries.firstIndex(where: { $0.id == query.id }) {
            var updatedQuery = query
            updatedQuery.lastModified = Date()
            queries[index] = updatedQuery
            saveQueries(queries)
        }
    }

    /// Delete a query
    func deleteQuery(_ query: SavedQuery) {
        var queries = loadQueries()
        queries.removeAll { $0.id == query.id }
        saveQueries(queries)
    }

    // MARK: - Last Used Query

    /// Save the ID of the last used query
    func saveLastUsedQueryId(_ id: UUID) {
        defaults.set(id.uuidString, forKey: lastUsedQueryIdKey)
    }

    /// Load the last used query
    func loadLastUsedQuery() -> SavedQuery? {
        guard let idString = defaults.string(forKey: lastUsedQueryIdKey),
              let id = UUID(uuidString: idString) else {
            return nil
        }

        let queries = loadQueries()
        return queries.first { $0.id == id }
    }

    // MARK: - Default Queries

    /// Return default queries that ship with the app
    private func defaultQueries() -> [SavedQuery] {
        [
            SavedQuery(
                name: "DOING Tasks",
                queryText: DatalogQueryBuilder.doingTasksQuery(),
                isReadOnly: false
            ),
            SavedQuery(
                name: "TODO Tasks",
                queryText: DatalogQueryBuilder.todoTasksWithPriorityQuery(),
                isReadOnly: false
            ),
            SavedQuery(
                name: "High Priority",
                queryText: DatalogQueryBuilder.highPriorityTasksQuery(),
                isReadOnly: false
            )
        ]
    }
}

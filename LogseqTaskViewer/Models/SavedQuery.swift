import Foundation

/// Represents a saved Datalog query with metadata
struct SavedQuery: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var queryText: String
    var isReadOnly: Bool
    let createdAt: Date
    var lastModified: Date

    init(
        id: UUID = UUID(),
        name: String,
        queryText: String,
        isReadOnly: Bool = false
    ) {
        self.id = id
        self.name = name
        self.queryText = queryText
        self.isReadOnly = isReadOnly
        self.createdAt = Date()
        self.lastModified = Date()
    }

    /// Create a duplicate of this query with " Copy" appended to the name
    func duplicate() -> SavedQuery {
        SavedQuery(
            name: "\(name) Copy",
            queryText: queryText,
            isReadOnly: false
        )
    }
}

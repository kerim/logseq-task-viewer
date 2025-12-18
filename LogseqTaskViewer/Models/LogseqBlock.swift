import Foundation

/// Represents a raw block from Logseq CLI query output (DB graphs)
struct LogseqBlock: Codable {
    let uuid: String
    let title: String?              // Block title (main content for tasks)
    let content: String?            // Block content (secondary content)
    let properties: [String: PropertyValue]?
    let tags: [BlockReference]?
    let page: BlockReference?

    // Task properties (if present)
    let status: BlockReference?      // Status property reference
    let priority: BlockReference?    // Priority property reference
    let scheduled: Int?              // Scheduled date (YYYYMMDD)
    let deadline: Int?               // Deadline date (YYYYMMDD)

    enum CodingKeys: String, CodingKey {
        case uuid = "block/uuid"
        case title = "block/title"
        case content = "block/content"
        case properties = "block/properties"
        case tags = "block/tags"
        case page = "block/page"
        case status = "logseq.property/status"
        case priority = "logseq.property/priority"
        case scheduled = "logseq.property/scheduled"
        case deadline = "logseq.property/deadline"
    }

    // Debug initializer for testing
    init(uuid: String, content: String) {
        self.uuid = uuid
        self.title = nil
        self.content = content
        self.properties = nil
        self.tags = nil
        self.page = nil
        self.status = nil
        self.priority = nil
        self.scheduled = nil
        self.deadline = nil
    }
    
    // Test initializer with properties
    init(uuid: String, content: String, priority: String?, scheduled: Int?, deadline: Int?) {
        self.uuid = uuid
        self.title = nil
        self.content = content
        self.properties = nil
        self.tags = nil
        self.page = nil
        self.status = nil
        self.priority = priority.flatMap { BlockReference(id: nil, title: $0, name: $0) }
        self.scheduled = scheduled
        self.deadline = deadline
    }
    
    // Helper function to convert timestamp to YYYYMMDD
    private static func convertTimestampToYYYYMMDD(_ timestamp: Double) -> Int? {
        let date = Date(timeIntervalSince1970: timestamp / 1000.0)
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return year * 10000 + month * 100 + day
    }
    
    // Custom decoder to handle timestamp conversion
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode basic fields
        uuid = try container.decode(String.self, forKey: .uuid)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        properties = try container.decodeIfPresent([String: PropertyValue].self, forKey: .properties)
        tags = try container.decodeIfPresent([BlockReference].self, forKey: .tags)
        page = try container.decodeIfPresent(BlockReference.self, forKey: .page)
        status = try container.decodeIfPresent(BlockReference.self, forKey: .status)
        priority = try container.decodeIfPresent(BlockReference.self, forKey: .priority)
        
        // Handle scheduled date - check if it's a timestamp (large number) or YYYYMMDD format
        if let scheduledValue = try? container.decodeIfPresent(Int.self, forKey: .scheduled) {
            // If the number is larger than 99991231 (Dec 31, 9999), it's likely a timestamp in milliseconds
            if scheduledValue > 99991231 {
                // Convert timestamp (milliseconds) to YYYYMMDD
                scheduled = LogseqBlock.convertTimestampToYYYYMMDD(Double(scheduledValue))
            } else {
                // It's already in YYYYMMDD format
                scheduled = scheduledValue
            }
        } else {
            scheduled = nil
        }
        
        // Handle deadline date - check if it's a timestamp (large number) or YYYYMMDD format
        if let deadlineValue = try? container.decodeIfPresent(Int.self, forKey: .deadline) {
            // If the number is larger than 99991231 (Dec 31, 9999), it's likely a timestamp in milliseconds
            if deadlineValue > 99991231 {
                // Convert timestamp (milliseconds) to YYYYMMDD
                deadline = LogseqBlock.convertTimestampToYYYYMMDD(Double(deadlineValue))
            } else {
                // It's already in YYYYMMDD format
                deadline = deadlineValue
            }
        } else {
            deadline = nil
        }
    }
}

/// Represents a query result that includes both block data and resolved status name
/// Used for queries that resolve status/tag names in the result tuple
struct LogseqBlockWithStatus: Codable {
    let block: LogseqBlock
    let statusName: String

    init(block: LogseqBlock, statusName: String) {
        self.block = block
        self.statusName = statusName
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        // First element is the block dictionary - decode it as a LogseqBlock
        let blockData = try container.decode(LogseqBlock.self)
        
        // Second element is the status name string
        self.statusName = try container.decode(String.self)
        
        self.block = blockData
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(block)
        try container.encode(statusName)
    }
}

/// Simple version for debugging - only UUID and content
struct SimpleLogseqBlock: Codable {
    let uuid: String
    let content: String

    enum CodingKeys: String, CodingKey {
        case uuid = "block/uuid"
        case content = "block/content"
    }
}

struct BlockReference: Codable {
    let id: Int?
    let title: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id = "db/id"
        case title = "block/title"
        case name = "block/name"
    }
}

/// Handle dynamic property values (strings, numbers, dates, etc.)
enum PropertyValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([PropertyValue])
    case object([String: PropertyValue])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let arrayValue = try? container.decode([PropertyValue].self) {
            self = .array(arrayValue)
        } else if let objectValue = try? container.decode([String: PropertyValue].self) {
            self = .object(objectValue)
        } else {
            throw DecodingError.typeMismatch(PropertyValue.self,
                DecodingError.Context(codingPath: decoder.codingPath,
                    debugDescription: "Cannot decode PropertyValue"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        }
    }

    var asInt: Int? {
        if case .int(let value) = self { return value }
        if case .double(let value) = self { return Int(value) }
        return nil
    }

    var asString: String? {
        if case .string(let value) = self { return value }
        return nil
    }
}

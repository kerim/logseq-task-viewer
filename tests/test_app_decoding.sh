#!/bin/bash

# Test that the app can properly decode the new query results
echo "=== Testing App Decoding of DOING Query Results ==="

# The updated query that should return title field
QUERY='[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]]'

echo "Query: $QUERY"
echo ""

# Execute query
RESULT=$(logseq query "$QUERY" -g "LSEQ 2025-12-15")

echo "Raw EDN Result:"
echo "$RESULT"
echo ""

# Convert to JSON for easier reading
JSON_RESULT=$(echo "$RESULT" | /opt/homebrew/bin/jet --from edn --to json)

echo "JSON Result:"
echo "$JSON_RESULT"
echo ""

# Test if this can be decoded by our Swift models
echo "=== Testing Swift Decoding ==="

# Create a simple Swift test to decode this JSON
cat > test_decoding.swift << 'SWIFT_EOF'
import Foundation

// Simplified version of our models for testing
struct LogseqBlock: Codable {
    let uuid: String
    let title: String?
    let content: String?
    let tags: [BlockReference]?
    let properties: [String: PropertyValue]?

    enum CodingKeys: String, CodingKey {
        case uuid = "block/uuid"
        case title = "block/title"
        case content = "block/content"
        case tags = "block/tags"
        case properties = "block/properties"
    }
}

struct BlockReference: Codable {
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case id = "db/id"
    }
}

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
}

struct LogseqBlockWithStatus: Codable {
    let block: LogseqBlock
    let statusName: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let blockData = try container.decode(LogseqBlock.self)
        self.statusName = try container.decode(String.self)
        self.block = blockData
    }
}

// Test decoding
let jsonData = """
[ [ {
  "block/tags" : [ {
    "db/id" : 140
  } ],
  "block/title" : "1st December [[68301217-1a99-4d9b-a2f8-e8756851ec28]] post",
  "block/uuid" : "6933c742-69e9-40a9-b049-1337cf92723f"
}, "Doing" ] ]
""".data(using: .utf8)!

do {
    let decoder = JSONDecoder()
    let blocksWithStatus = try decoder.decode([LogseqBlockWithStatus].self, from: jsonData)
    
    print("Successfully decoded \(blocksWithStatus.count) blocks:")
    for (index, blockWithStatus) in blocksWithStatus.enumerated() {
        print("Block \(index + 1):")
        print("  UUID: \(blockWithStatus.block.uuid)")
        print("  Title: \(blockWithStatus.block.title ?? "nil")")
        print("  Status: \(blockWithStatus.statusName)")
    }
} catch {
    print("Decoding failed: \(error)")
}
SWIFT_EOF

# Run the Swift test
swift test_decoding.swift

echo ""
echo "=== Decoding Test Complete ==="

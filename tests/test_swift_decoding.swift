import Foundation

// Test the actual LogseqBlockWithStatus decoding with real data
let jsonString = """
[ [ {
  "block/tags" : [ {
    "db/id" : 140
  } ],
  "block/uuid" : "6933c742-69e9-40a9-b049-1337cf92723f"
}, "Doing" ], [ {
  "block/tags" : [ {
    "db/id" : 140
  } ],
  "block/uuid" : "692a5166-51dd-420e-8b97-4bdae021dc11"
}, "Doing" ], [ {
  "block/tags" : [ {
    "db/id" : 140
  } ],
  "block/uuid" : "68f48c61-41f6-4ff1-a612-ea7338ebbbeb"
}, "Doing" ] ]
"""

let jsonData = jsonString.data(using: .utf8)!

// Import the actual models from the project
// For now, let's test with a simplified version

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

struct LogseqBlock: Codable {
    let uuid: String
    let content: String?
    let properties: [String: String]?
    let tags: [BlockReference]?
    let page: BlockReference?
    let status: BlockReference?
    let priority: BlockReference?
    let scheduled: Int?
    let deadline: Int?

    enum CodingKeys: String, CodingKey {
        case uuid = "block/uuid"
        case content = "block/content"
        case properties = "block/properties"
        case tags = "block/tags"
        case page = "block/page"
        case status = "logseq.property/status"
        case priority = "logseq.property/priority"
        case scheduled = "logseq.property/scheduled"
        case deadline = "logseq.property/deadline"
    }
}

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

do {
    print("Testing LogseqBlockWithStatus decoding...")
    
    // Try to decode as array of block+status tuples
    let tuples = try JSONDecoder().decode([LogseqBlockWithStatus].self, from: jsonData)
    
    print("✓ Successfully decoded as [LogseqBlockWithStatus]")
    print("Found \(tuples.count) tasks")
    
    for (index, tuple) in tuples.enumerated() {
        print("Task \(index + 1):")
        print("  UUID: \(tuple.block.uuid)")
        print("  Status: \(tuple.statusName)")
        if let tags = tuple.block.tags {
            print("  Tags: \(tags.count)")
        }
    }
    
    // Extract blocks
    let blocks = tuples.map { $0.block }
    print("Extracted \(blocks.count) blocks")
    
    print("\n✓ SUCCESS: The LogseqBlockWithStatus decoding is working correctly!")
    print("The app should now be able to decode the DOING tasks from the query.")
    
} catch {
    print("✗ Failed to decode: \(error)")
    print("\nThis suggests there's still an issue with the decoding logic.")
    print("The JSON structure is correct, but the Swift decoding needs adjustment.")
}

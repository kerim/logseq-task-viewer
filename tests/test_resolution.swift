import Foundation

// Test the regex pattern for UUID extraction
let testTitles = [
    "1st December [[68301217-1a99-4d9b-a2f8-e8756851ec28]] post",
    "[[692a5173-3bb9-49fa-85d2-c74ba89ea796]]",
    "Watch [[68f48c70-c9cf-4960-89b1-853802050a5f]] Films that I haven't seen yet"
]

let uuidToTitleMap = [
    "68301217-1a99-4d9b-a2f8-e8756851ec28": "Triptych",
    "68f48c70-c9cf-4960-89b1-853802050a5f": "TIEFF 2025",
    "692a5173-3bb9-49fa-85d2-c74ba89ea796": "revise HTTL manuscript"
]

print("Testing UUID extraction and replacement:")
print("========================================")

for title in testTitles {
    print("Original: \(title)")
    
    var resolvedTitle = title
    
    // Apply the same regex pattern
    let pattern = "\\[\\[([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})\\]\\]"
    
    if let regex = try? NSRegularExpression(pattern: pattern) {
        let matches = regex.matches(in: title, range: NSRange(title.startIndex..., in: title))
        
        for match in matches {
            if match.numberOfRanges > 1 {
                let uuidRange = match.range(at: 1)
                if let substringRange = Range(uuidRange, in: title) {
                    let uuid = String(title[substringRange])
                    if let resolvedName = uuidToTitleMap[uuid] {
                        let pattern = "\\[\\[" + uuid + "\\]\\]"
                        resolvedTitle = resolvedTitle.replacingOccurrences(of: pattern, with: "[[\(resolvedName)]]")
                    }
                }
            }
        }
    }
    
    print("Resolved: \(resolvedTitle)")
    print("")
}

print("Expected results:")
print("1. 1st December [[Triptych]] post")
print("2. [[revise HTTL manuscript]]")
print("3. Watch [[TIEFF 2025]] Films that I haven't seen yet")

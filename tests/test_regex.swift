import Foundation

let testString = "Watch [[68f48c70-c9cf-4960-89b1-853802050a5f]] Films"
let pattern = "\\[\\[([a-f0-9\\-]{36})\\]\\]"

print("Testing string: \(testString)")
print("Pattern: \(pattern)")

if let regex = try? NSRegularExpression(pattern: pattern) {
    let matches = regex.matches(in: testString, range: NSRange(testString.startIndex..., in: testString))
    print("Found \(matches.count) matches")
    
    for match in matches {
        print("Match range: \(match.range)")
        if match.numberOfRanges > 1 {
            for i in 0..<match.numberOfRanges {
                let range = match.range(at: i)
                if let substringRange = Range(range, in: testString) {
                    let matchString = String(testString[substringRange])
                    print("Group \(i): \(matchString)")
                }
            }
        }
    }
} else {
    print("Regex compilation failed")
}

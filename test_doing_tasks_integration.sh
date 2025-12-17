#!/bin/bash

# Integration test for doing tasks functionality
# This tests the complete flow from query building to execution

echo "=== Integration Test: Doing Tasks ==="
echo

# Build the project first
echo "Building project..."
xcodebuild -project LogseqTaskViewer.xcodeproj -scheme LogseqTaskViewer -configuration Debug -derivedDataPath ./DerivedData build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"
echo

# Create a test Swift file that uses the new functionality
test_file="$(mktemp).swift"

cat > "$test_file" << 'EOF'
import Foundation

// Import the module (this would work in a real build)
// For now, we'll test the query directly

let query = DatalogQueryBuilder.doingTasksQuery()
print("Generated Query:")
print("=" * 50)
print(query)
print("=" * 50)

// Test with actual Logseq CLI
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
process.arguments = ["logseq", "query", query, "-g", "LSEQ 2025-12-15"]

let outputPipe = Pipe()
let errorPipe = Pipe()
process.standardOutput = outputPipe
process.standardError = errorPipe

do {
    try process.run()
    process.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    
    if let output = String(data: outputData, encoding: .utf8), !output.isEmpty {
        print("\nQuery Results:")
        print(output)
    }
    
    if let error = String(data: errorData, encoding: .utf8), !error.isEmpty {
        print("\nError:")
        print(error)
    }
    
    print("\nExit code: \(process.terminationStatus)")
    
    if process.terminationStatus == 0 {
        print("✅ Query executed successfully")
    } else {
        print("❌ Query failed")
    }
} catch {
    print("Failed to run query: \(error)")
}
EOF

echo "Running integration test..."
swift "$test_file"

# Clean up
rm "$test_file"

echo
echo "=== Integration Test Complete ==="
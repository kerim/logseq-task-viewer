#!/bin/bash

echo "Testing DOING query only..."

cd /Users/niyaro/Documents/Code/Logseq/logseq\ task\ viewer

# Kill any existing instances
pkill -f LogseqTaskViewer || true
sleep 2

# Create a minimal Swift test that only tests the DOING query
cat > test_doing_only.swift << 'EOF'
import Foundation

// Minimal test for DOING query
func testDoingQuery() {
    let config = CLIConfig(
        graphName: "LSEQ 2025-12-15",
        logseqCLIPath: "/opt/homebrew/bin/logseq",
        jetCLIPath: "/opt/homebrew/bin/jet"
    )

    let client = LogseqCLIClient(config: config)
    
    Task {
        do {
            print("=== Testing DOING Query Only ===")
            let blocks = try await client.fetchDoingTasks()
            
            if blocks.isEmpty {
                print("No DOING tasks found")
            } else {
                print("Found \(blocks.count) DOING tasks")
                
                for (index, block) in blocks.enumerated() {
                    print("DOING Task \(index + 1):")
                    print("  UUID: \(block.uuid)")
                    if let content = block.content {
                        print("  Content: \(content.prefix(50))...")
                    } else {
                        print("  Content: (no content)")
                    }
                }
            }
            
            exit(0)
        } catch {
            print("Error: \(error.localizedDescription)")
            exit(1)
        }
    }
    
    // Keep running until task completes
    RunLoop.main.run()
}

testDoingQuery()
EOF

echo "Running minimal DOING query test..."

# Compile and run the test
swiftc -o test_doing_only test_doing_only.swift -I . -L . -lLogseqTaskViewer

if [ $? -eq 0 ]; then
    ./test_doing_only
else
    echo "Failed to compile test"
fi

# Clean up
rm -f test_doing_only.swift test_doing_only
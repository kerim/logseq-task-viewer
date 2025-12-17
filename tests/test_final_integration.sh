#!/bin/bash

# Final integration test to verify the complete flow
echo "=== Final Integration Test ==="
echo "Testing the complete DOING tasks flow"
echo

# Step 1: Verify the query is correct
echo "Step 1: Checking query structure"
if grep -q "?status-name" LogseqTaskViewer/Services/DatalogQueryBuilder.swift && \
   grep -q "Doing" LogseqTaskViewer/Services/DatalogQueryBuilder.swift; then
    echo "✅ Query includes status resolution and DOING filter"
else
    echo "❌ Query structure incorrect"
    exit 1
fi

# Step 2: Verify the decoding logic exists
echo "Step 2: Checking decoding logic"
if grep -q "LogseqBlockWithStatus" LogseqTaskViewer/Services/LogseqCLIClient.swift; then
    echo "✅ Decoding logic for tuple format exists"
else
    echo "❌ Decoding logic missing"
    exit 1
fi

# Step 3: Test actual query execution
echo "Step 3: Testing actual query execution"
QUERY='[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]]'

RESULT=$(logseq query "$QUERY" -g "LSEQ 2025-12-15")

if echo "$RESULT" | grep -q "Doing"; then
    echo "✅ Query returns DOING tasks"
    
    # Count the number of tasks
    TASK_COUNT=$(echo "$RESULT" | grep -c "Doing")
    echo "   Found $TASK_COUNT DOING tasks"
    
    # Check if titles are present
    if echo "$RESULT" | grep -q "block/title"; then
        echo "✅ Tasks include title content"
    else
        echo "❌ Tasks missing title content"
        exit 1
    fi
else
    echo "❌ Query did not return DOING tasks"
    exit 1
fi

# Step 4: Test JSON conversion
echo "Step 4: Testing JSON conversion"
JSON_RESULT=$(echo "$RESULT" | /opt/homebrew/bin/jet --from edn --to json)

if [ -n "$JSON_RESULT" ]; then
    echo "✅ EDN to JSON conversion successful"
else
    echo "❌ JSON conversion failed"
    exit 1
fi

# Step 5: Build the project
echo "Step 5: Building project"
if xcodebuild -project LogseqTaskViewer.xcodeproj -scheme LogseqTaskViewer build -quiet; then
    echo "✅ Project builds successfully"
else
    echo "❌ Project build failed"
    exit 1
fi

echo
echo "=== All Integration Tests Passed! ==="
echo
echo "Summary:"
echo "✅ Query structure is correct"
echo "✅ Decoding logic is implemented"
echo "✅ Query executes and returns DOING tasks"
echo "✅ Tasks include title content"
echo "✅ JSON conversion works"
echo "✅ Project builds successfully"
echo
echo "The app should now be able to:"
echo "1. Query for DOING tasks"
echo "2. Decode the tuple-based results"
echo "3. Display task titles (content)"
echo "4. Show the correct status (Doing)"

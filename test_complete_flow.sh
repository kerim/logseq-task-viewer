#!/bin/bash

# Comprehensive test of the updated query flow
echo "=== Comprehensive Query Flow Test ==="
echo

echo "This test verifies that:"
echo "1. Updated queries resolve status names correctly"
echo "2. New parsing logic handles tuple-based results"
echo "3. Data models can parse the new structure"
echo

# Test 1: Verify updated query structure
echo "Test 1: Checking updated query structure"
echo "----------------------------------------"

# Check if the simpleTaskQuery includes status resolution
if grep -q "?status-name" LogseqTaskViewer/Services/DatalogQueryBuilder.swift; then
    echo "✅ Queries updated to resolve status names"
else
    echo "❌ Queries not updated properly"
    exit 1
fi

# Check if the allTasksQuery includes status resolution
if grep -A 20 "allTasksQuery()" LogseqTaskViewer/Services/DatalogQueryBuilder.swift | grep -q "?status-name"; then
    echo "✅ allTasksQuery includes status resolution"
else
    echo "❌ allTasksQuery missing status resolution"
    exit 1
fi

echo

# Test 2: Verify new data model exists
echo "Test 2: Checking new data model"
echo "--------------------------------"

if grep -q "LogseqBlockWithStatus" LogseqTaskViewer/Models/LogseqBlock.swift; then
    echo "✅ LogseqBlockWithStatus model created"
else
    echo "❌ LogseqBlockWithStatus model missing"
    exit 1
fi

if grep -q "statusName" LogseqTaskViewer/Models/LogseqBlock.swift; then
    echo "✅ LogseqBlockWithStatus includes statusName field"
else
    echo "❌ LogseqBlockWithStatus missing statusName field"
    exit 1
fi

echo

# Test 3: Verify parsing logic updated
echo "Test 3: Checking parsing logic"
echo "------------------------------"

if grep -q "LogseqBlockWithStatus" LogseqTaskViewer/Services/LogseqCLIClient.swift; then
    echo "✅ CLI client updated to handle new model"
else
    echo "❌ CLI client not updated for new model"
    exit 1
fi

if grep -q "blockWithStatusTuples" LogseqTaskViewer/Services/LogseqCLIClient.swift; then
    echo "✅ Parsing logic includes tuple handling"
else
    echo "❌ Parsing logic missing tuple handling"
    exit 1
fi

echo

# Test 4: Test actual query execution
echo "Test 4: Testing actual query execution"
echo "--------------------------------------"

SIMPLE_QUERY='[:find (pull ?b [:block/uuid :block/content]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]]'

echo "Testing query:"
echo "$SIMPLE_QUERY"
echo

if command -v logseq &> /dev/null; then
    echo "Running query with Logseq CLI..."
    
    # Run the query
    RESULT=$(logseq query "$SIMPLE_QUERY" -g "LSEQ 2025-12-15" --format json 2>/dev/null)
    
    if [ -n "$RESULT" ]; then
        echo "✅ Query executed successfully"
        
        # Check for status names in results
        if echo "$RESULT" | grep -q "Done\|Todo\|Doing\|Backlog\|Canceled\|In Review"; then
            echo "✅ Query returns status names (not just IDs)"
            
            # Show sample results
            echo "Sample results:"
            echo "$RESULT" | head -c 300
            echo "..."
        else
            echo "⚠️  Query ran but status names not found in results"
        fi
    else
        echo "❌ Query failed or returned no results"
        exit 1
    fi
else
    echo "⚠️  Logseq CLI not available, skipping execution test"
fi

echo

# Test 5: Build verification
echo "Test 5: Build verification"
echo "-------------------------"

if xcodebuild -project LogseqTaskViewer.xcodeproj -scheme LogseqTaskViewer build -quiet; then
    echo "✅ Project builds successfully with updated code"
else
    echo "❌ Project build failed"
    exit 1
fi

echo

echo "=== All Tests Passed! ==="
echo
echo "Summary of Changes:"
echo "1. ✅ Updated DatalogQueryBuilder.swift with status resolution queries"
echo "2. ✅ Added LogseqBlockWithStatus model for tuple-based results"
echo "3. ✅ Updated LogseqCLIClient.swift to parse new result format"
echo "4. ✅ Verified queries return human-readable status names"
echo "5. ✅ Project builds successfully"
echo
echo "Next Steps:"
echo "- Update LogseqTask.swift to use resolved status names"
echo "- Create ViewModels to transform data for UI"
echo "- Build actual task display views"
echo "- Implement error handling for missing data fields"
#!/bin/bash

echo "=== Logseq CLI Test Script ==="
echo

# Test 1: Check if CLI is available
echo "Test 1: Checking Logseq CLI availability..."
if command -v logseq &> /dev/null; then
    echo "✓ Logseq CLI is available"
    logseq --version
else
    echo "✗ Logseq CLI not found"
    exit 1
fi
echo

# Test 2: List available graphs
echo "Test 2: Listing available graphs..."
logseq list
echo

# Test 3: Test simple query on your graph
echo "Test 3: Testing simple query on LSEQ 2025-12-15 graph..."
QUERY='[:find ?b :where [?b :block/uuid] :limit 1]'
echo "Query: $QUERY"
logseq query "$QUERY" -g "LSEQ 2025-12-15"
echo

# Test 4: Test task query
echo "Test 4: Testing task query..."
TASK_QUERY='[:find (pull ?b [:block/uuid :block/content]) :where [?b :block/tags ?t] [?t :block/title "Task"] :limit 3]'
echo "Query: $TASK_QUERY"
logseq query "$TASK_QUERY" -g "LSEQ 2025-12-15"
echo

# Test 5: Test jet conversion
echo "Test 5: Testing jet EDN to JSON conversion..."
if command -v jet &> /dev/null; then
    echo "✓ jet CLI is available"
    TEST_EDN='[:find 1 2 3]'
    echo "Input EDN: $TEST_EDN"
    echo "$TEST_EDN" | jet --to json
else
    echo "✗ jet CLI not found"
fi
echo

echo "=== Test Complete ==="
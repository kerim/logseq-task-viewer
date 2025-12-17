#!/bin/bash

echo "=== Testing Limit Clause ==="
echo

# Test with explicit limit
echo "Test 1: Query with limit 2"
QUERY='[:find (pull ?b [:block/uuid]) :where [?b :block/tags ?t] [?t :block/title "Task"] :limit 2]'
echo "Query: $QUERY"
RESULT=$(logseq query "$QUERY" -g "LSEQ 2025-12-15")
echo "Result count: $(echo "$RESULT" | grep -o "uuid" | wc -l)"
echo "First few lines:"
echo "$RESULT" | head -5
echo

# Test without limit
echo "Test 2: Same query without limit"
QUERY_NO_LIMIT='[:find (pull ?b [:block/uuid]) :where [?b :block/tags ?t] [?t :block/title "Task"]]'
echo "Query: $QUERY_NO_LIMIT"
RESULT_NO_LIMIT=$(logseq query "$QUERY_NO_LIMIT" -g "LSEQ 2025-12-15")
echo "Result count: $(echo "$RESULT_NO_LIMIT" | grep -o "uuid" | wc -l)"
echo

echo "=== Test Complete ==="
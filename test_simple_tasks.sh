#!/bin/bash

# Test to see if there are any tasks at all
echo "=== Testing Simple Task Query ==="

# Simple query for any blocks with Task tag
QUERY='[:find (pull ?b [:block/uuid :block/content])
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]]'

echo "Query: $QUERY"
echo ""

# Execute query
RESULT=$(echo "$QUERY" | /opt/homebrew/bin/logseq query -g "LSEQ 2025-12-15")

echo "Raw EDN Result:"
echo "$RESULT"
echo ""

# Convert to JSON for easier reading
JSON_RESULT=$(echo "$RESULT" | /opt/homebrew/bin/jet --from edn --to json)

echo "JSON Result:"
echo "$JSON_RESULT"

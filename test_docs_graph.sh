#!/bin/bash

# Test Logseq DB Docs graph
echo "=== Testing Logseq DB Docs Graph ==="

# Simple query for any blocks with Task tag
QUERY='[:find (pull ?b [:block/uuid :block/content])
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]]'

echo "Query: $QUERY"
echo ""

# Execute query
RESULT=$(echo "$QUERY" | /opt/homebrew/bin/logseq query -g "Logseq DB Docs - CE - v1")

echo "Raw EDN Result:"
echo "$RESULT"
echo ""

# Convert to JSON for easier reading
JSON_RESULT=$(echo "$RESULT" | /opt/homebrew/bin/jet --from edn --to json)

echo "JSON Result:"
echo "$JSON_RESULT"

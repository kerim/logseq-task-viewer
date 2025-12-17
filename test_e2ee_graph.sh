#!/bin/bash

# Test e2ee restore 2 graph
echo "=== Testing e2ee restore 2 Graph ==="

# Simple query for any blocks with Task tag
QUERY='[:find (pull ?b [:block/uuid :block/content])
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]]'

echo "Query: $QUERY"
echo ""

# Execute query
RESULT=$(echo "$QUERY" | /opt/homebrew/bin/logseq query -g "e2ee restore 2")

echo "Raw EDN Result:"
echo "$RESULT"
echo ""

# Convert to JSON for easier reading
JSON_RESULT=$(echo "$RESULT" | /opt/homebrew/bin/jet --from edn --to json)

echo "JSON Result:"
echo "$JSON_RESULT"

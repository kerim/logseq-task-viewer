#!/bin/bash

# Test to see what content is available for DOING tasks
echo "=== Testing DOING Tasks Content ==="

# Query for DOING tasks with more fields
QUERY='[:find (pull ?b [:block/uuid :block/content :block/title :block/properties])
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]
    [?b :logseq.property/status ?s]
    [?s :block/title "Doing"]]'

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

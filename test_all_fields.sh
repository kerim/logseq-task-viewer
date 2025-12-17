#!/bin/bash

# Test to see ALL available fields for DOING tasks
echo "=== Testing ALL Fields for DOING Tasks ==="

# Query for DOING tasks with ALL fields (using * wildcard)
QUERY='[:find (pull ?b [*]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]]'

echo "Query: $QUERY"
echo ""

# Execute query
RESULT=$(logseq query "$QUERY" -g "LSEQ 2025-12-15")

echo "Raw EDN Result:"
echo "$RESULT"
echo ""

# Convert to JSON for easier reading
JSON_RESULT=$(echo "$RESULT" | /opt/homebrew/bin/jet --from edn --to json)

echo "JSON Result:"
echo "$JSON_RESULT"

#!/bin/bash

# Test the updated doing tasks query
echo "=== Testing Updated DOING Query ==="

# The updated query that should return title field
QUERY='[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties]) ?status-name
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

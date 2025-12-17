#!/bin/bash

# Test comprehensive query that resolves all references in one go
echo "=== Testing Comprehensive Reference Resolution ==="

# Query that gets tasks AND resolves their title references
COMPREHENSIVE_QUERY='[:find (pull ?b [:block/uuid :block/title]) ?status-name ?ref-block
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]
   [?b :block/title ?title]
   [(get-else $ ?title "") ?title-str]
   [(re-pattern "\[\[([a-f0-9\-]{36})\]\]") ?pattern]
   [(re-find ?pattern ?title-str) ?match]
   [(get ?match 1) ?ref-uuid]
   [(uuid ?ref-uuid) ?ref-block]
   [?ref-block :block/title ?ref-title]]'

echo "Comprehensive Query:"
echo "$COMPREHENSIVE_QUERY"
echo ""

RESULT=$(logseq query "$COMPREHENSIVE_QUERY" -g "LSEQ 2025-12-15")
echo "Result:"
echo "$RESULT"
echo ""

# Convert to JSON for better reading
JSON_RESULT=$(echo "$RESULT" | /opt/homebrew/bin/jet --from edn --to json)
echo "JSON Result:"
echo "$JSON_RESULT"

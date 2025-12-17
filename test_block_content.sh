#!/bin/bash

echo "=== Testing Block Content Resolution ==="
echo

# Test 1: Get block content for a specific UUID
echo "Test 1: Querying block content for a specific UUID"
QUERY='[:find (pull ?b [:block/uuid :block/content :block/page]) :where [?b :block/uuid #uuid "682c66c8-7194-4591-b783-bbbb58ac4b63"]]'
echo "Query: $QUERY"
logseq query "$QUERY" -g "LSEQ 2025-12-15"
echo

# Test 2: Get block content with tags
echo "Test 2: Querying blocks with their content and tags"
QUERY='[:find (pull ?b [:block/uuid :block/content :block/tags]) :where [?b :block/tags ?t] [?t :block/title "Task"] :limit 3]'
echo "Query: $QUERY"
logseq query "$QUERY" -g "LSEQ 2025-12-15"
echo

# Test 3: Get block content with status
echo "Test 3: Querying blocks with content and status"
QUERY='[:find (pull ?b [:block/uuid :block/content :logseq.property/status]) :where [?b :block/tags ?t] [?t :block/title "Task"] :limit 3]'
echo "Query: $QUERY"
logseq query "$QUERY" -g "LSEQ 2025-12-15"
echo

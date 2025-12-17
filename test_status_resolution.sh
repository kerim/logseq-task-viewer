#!/bin/bash

echo "=== Testing Status ID Resolution ==="
echo

# Test 1: Get all status entities
echo "Test 1: Querying all status entities"
QUERY='[:find ?s ?title :where [?s :block/title ?title] [?s :logseq.property/type "status"]]'
echo "Query: $QUERY"
logseq query "$QUERY" -g "LSEQ 2025-12-15"
echo

# Test 2: Get status by ID (trying common IDs)
echo "Test 2: Querying status entities by their IDs"
for ID in 73 74 70 71 72; do
    echo "Looking up status ID: $ID"
    QUERY="[:find ?title :where [?s :block/title ?title] [?s :db/id $ID]]"
    logseq query "$QUERY" -g "LSEQ 2025-12-15"
    echo
done

# Test 3: Get blocks with status names instead of IDs
echo "Test 3: Querying blocks with status names"
QUERY='[:find (pull ?b [:block/uuid :block/content]) ?status-name :where [?b :block/tags ?t] [?t :block/title "Task"] [?b :logseq.property/status ?s] [?s :block/title ?status-name] :limit 5]'
echo "Query: $QUERY"
logseq query "$QUERY" -g "LSEQ 2025-12-15"
echo

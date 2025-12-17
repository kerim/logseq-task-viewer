#!/bin/bash

echo "=== Testing Tag ID Resolution ==="
echo

# Test 1: Get all tag entities
echo "Test 1: Querying all tag entities"
QUERY='[:find ?tag ?title :where [?tag :block/title ?title] [?tag :logseq.property/type "tag"] :limit 10]'
echo "Query: $QUERY"
logseq query "$QUERY" -g "LSEQ 2025-12-15"
echo

# Test 2: Get tag by ID (trying common IDs from our data)
echo "Test 2: Querying tag entities by their IDs"
for ID in 140 1166 2572 1191 2056; do
    echo "Looking up tag ID: $ID"
    QUERY="[:find ?title :where [?tag :block/title ?title] [?tag :db/id $ID]]"
    logseq query "$QUERY" -g "LSEQ 2025-12-15"
    echo
done

# Test 3: Get blocks with tag names instead of IDs
echo "Test 3: Querying blocks with tag names"
QUERY='[:find (pull ?b [:block/uuid :block/content]) ?tag-name :where [?b :block/tags ?t] [?t :block/title ?tag-name] [?b :block/tags ?t2] [?t2 :block/title "Task"] :limit 5]'
echo "Query: $QUERY"
logseq query "$QUERY" -g "LSEQ 2025-12-15"
echo

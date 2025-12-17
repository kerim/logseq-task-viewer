#!/bin/bash

echo "=== Testing Corrected Logseq Queries ==="
echo

# Test 1: Simple task query (should return blocks with UUID and content)
echo "Test 1: Simple Task Query"
TASK_QUERY='[:find (pull ?b [:block/uuid :block/content]) :where [?b :block/tags ?t] [?t :block/title "Task"] :limit 3]'
echo "Query: $TASK_QUERY"
logseq query "$TASK_QUERY" -g "LSEQ 2025-12-15"
echo

# Test 2: TODO blocks query
echo "Test 2: TODO Blocks Query"
TODO_QUERY='[:find (pull ?b [:block/uuid :block/content :block/tags]) :where [?b :block/tags ?t] [?t :block/title "Task"] [?b :logseq.property/status ?s] [?s :block/title "TODO"] :limit 3]'
echo "Query: $TODO_QUERY"
logseq query "$TODO_QUERY" -g "LSEQ 2025-12-15"
echo

# Test 3: All incomplete tasks query
echo "Test 3: All Incomplete Tasks Query"
INCOMPLETE_QUERY='[:find (pull ?b [:block/uuid :block/content]) :where [?b :block/tags ?t] [?t :block/title "Task"] (not [?b :logseq.property/status ?s]) (not [?b :logseq.property/status ?s] [?s :block/title "DONE"]) (not [?b :logseq.property/status ?s] [?s :block/title "CANCELLED"]) :limit 5]'
echo "Query: $INCOMPLETE_QUERY"
logseq query "$INCOMPLETE_QUERY" -g "LSEQ 2025-12-15"
echo

echo "=== Test Complete ==="
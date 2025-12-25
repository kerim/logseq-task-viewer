#!/bin/bash

echo "=== Debugging Comprehensive TODO Query ==="
echo

# First, let's see what tasks exist with different tagging approaches
echo "Test 1: Find all tasks with #Task tag"
TASK_TAG_QUERY='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where [?b :block/tags ?t] [?t :block/title "Task"] :limit 10]'
echo "Query: $TASK_TAG_QUERY"
logseq query "$TASK_TAG_QUERY" -g "LSEQ 2025-12-15" | head -10
echo

echo "Test 2: Find all tasks with TODO status (regardless of tag)"
ALL_TODO_QUERY='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where [?b :logseq.property/status ?s] [?s :block/title "Todo"] :limit 10]'
echo "Query: $ALL_TODO_QUERY"
logseq query "$ALL_TODO_QUERY" -g "LSEQ 2025-12-15" | head -10
echo

echo "Test 3: Find tasks with class-based inheritance (extending Task)"
CLASS_BASED_QUERY='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where [?b :block/tags ?child] [?child :logseq.property.class/extends ?parent] [?parent :block/title "Task"] :limit 10]'
echo "Query: $CLASS_BASED_QUERY"
logseq query "$CLASS_BASED_QUERY" -g "LSEQ 2025-12-15" | head -10
echo

echo "Test 4: Test the or-join part of the comprehensive query"
OR_JOIN_TEST='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where (or-join [?b] (and [?b :block/tags ?t] [?t :block/title "Task"]) (and [?b :block/tags ?child] [?child :logseq.property.class/extends ?parent] [?parent :block/title "Task"])) :limit 10]'
echo "Query: $OR_JOIN_TEST"
logseq query "$OR_JOIN_TEST" -g "LSEQ 2025-12-15" | head -10
echo

echo "Test 5: Full comprehensive TODO query"
COMPREHENSIVE_QUERY='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where (or-join [?b] (and [?b :block/tags ?t] [?t :block/title "Task"]) (and [?b :block/tags ?child] [?child :logseq.property.class/extends ?parent] [?parent :block/title "Task"])) [?b :logseq.property/status ?s] [?s :block/title "Todo"] [?b :logseq.property/priority ?p]]'
echo "Query: $COMPREHENSIVE_QUERY"
logseq query "$COMPREHENSIVE_QUERY" -g "LSEQ 2025-12-15" | head -10
echo

echo "Test 6: Check if there are any tasks with #shopping tag that have TODO status"
SHOPPING_TODO_QUERY='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where [?b :block/tags ?t] [?t :block/title "Shopping"] [?b :logseq.property/status ?s] [?s :block/title "Todo"] :limit 10]'
echo "Query: $SHOPPING_TODO_QUERY"
logseq query "$SHOPPING_TODO_QUERY" -g "LSEQ 2025-12-15" | head -10
echo

echo "=== Debug Complete ==="
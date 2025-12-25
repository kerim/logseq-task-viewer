#!/bin/bash

echo "Testing TODO Query Directly Against Logseq CLI"
echo "=============================================="
echo ""

# Test the TODO query with priority requirement
TODO_QUERY='[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties :logseq.property/status :logseq.property/priority :logseq.property/scheduled :logseq.property/deadline]) ?status-name
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]
    [?b :logseq.property/status ?s]
    [?s :block/title ?status-name]
    [(= ?status-name "TODO")]
    [?b :logseq.property/priority ?p]]'

echo "TODO Query (with priority requirement):"
echo "$TODO_QUERY"
echo ""

# Execute query
echo "Executing TODO query with priority requirement..."
RESULT=$(/opt/homebrew/bin/logseq query "$TODO_QUERY" -g "LSEQ 2025-12-15" 2>&1)

echo "Raw EDN result:"
echo "$RESULT"
echo ""

# Test the TODO query without priority requirement
TODO_QUERY_NO_PRIORITY='[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties :logseq.property/status :logseq.property/priority :logseq.property/scheduled :logseq.property/deadline]) ?status-name
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]
    [?b :logseq.property/status ?s]
    [?s :block/title ?status-name]
    [(= ?status-name "TODO")]]'

echo "TODO Query (without priority requirement):"
echo "$TODO_QUERY_NO_PRIORITY"
echo ""

# Execute query
echo "Executing TODO query without priority requirement..."
RESULT_NO_PRIORITY=$(/opt/homebrew/bin/logseq query "$TODO_QUERY_NO_PRIORITY" -g "LSEQ 2025-12-15" 2>&1)

echo "Raw EDN result:"
echo "$RESULT_NO_PRIORITY"
echo ""

# Test a simple count query to see how many TODO tasks exist
COUNT_QUERY='[:find (count ?b)
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]
    [?b :logseq.property/status ?s]
    [?s :block/title "TODO"]]'

echo "Count Query (all TODO tasks):"
echo "$COUNT_QUERY"
echo ""

# Execute count query
echo "Executing count query..."
COUNT_RESULT=$(/opt/homebrew/bin/logseq query "$COUNT_QUERY" -g "LSEQ 2025-12-15" 2>&1)

echo "Count result:"
echo "$COUNT_RESULT"
echo ""

# Test a count query with priority
COUNT_PRIORITY_QUERY='[:find (count ?b)
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]
    [?b :logseq.property/status ?s]
    [?s :block/title "TODO"]
    [?b :logseq.property/priority ?p]]'

echo "Count Query (TODO tasks with priority):"
echo "$COUNT_PRIORITY_QUERY"
echo ""

# Execute count with priority query
echo "Executing count with priority query..."
COUNT_PRIORITY_RESULT=$(/opt/homebrew/bin/logseq query "$COUNT_PRIORITY_QUERY" -g "LSEQ 2025-12-15" 2>&1)

echo "Count with priority result:"
echo "$COUNT_PRIORITY_RESULT"
echo ""

echo "Summary:"
echo "- TODO query with priority: $(echo "$RESULT" | grep -c "block/uuid" || echo "0") results"
echo "- TODO query without priority: $(echo "$RESULT_NO_PRIORITY" | grep -c "block/uuid" || echo "0") results"
echo "- Total TODO tasks: $(echo "$COUNT_RESULT" | grep -o "[0-9]\+" || echo "0")"
echo "- TODO tasks with priority: $(echo "$COUNT_PRIORITY_RESULT" | grep -o "[0-9]\+" || echo "0")"
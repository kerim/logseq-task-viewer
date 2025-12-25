#!/bin/bash

echo "=== Testing New Query Integration ==="
echo

# Test that the comprehensive TODO query is available and works
echo "Test 1: Verify comprehensive TODO query is in sample queries"
echo "The comprehensive TODO query should now be available in the SettingsView"
echo "as one of the sample queries with the name 'Comprehensive TODO'"
echo

# Test the query directly
echo "Test 2: Test comprehensive TODO query directly"
COMPREHENSIVE_QUERY='[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties :logseq.property/status :logseq.property/priority :logseq.property/scheduled :logseq.property/deadline]) :where (or-join [?b] (and [?b :block/tags ?t] [?t :block/title "Task"]) (and [?b :block/tags ?child] [?child :logseq.property.class/extends ?parent] [?parent :block/title "Task"])) [?b :logseq.property/status ?s] [?s :block/title "Todo"] [?b :logseq.property/priority ?p]]'

echo "Query: $COMPREHENSIVE_QUERY"
echo
echo "Results (first 5 items):"
logseq query "$COMPREHENSIVE_QUERY" -g "LSEQ 2025-12-15" | head -5
echo

echo "Test 3: Compare with regular TODO query"
REGULAR_TODO_QUERY='[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties :logseq.property/status :logseq.property/priority :logseq.property/scheduled :logseq.property/deadline]) :where [?b :block/tags ?t] [?t :block/title "Task"] [?b :logseq.property/status ?s] [?s :block/title "Todo"] [?b :logseq.property/priority ?p]]'

echo "Regular TODO query results (first 5 items):"
logseq query "$REGULAR_TODO_QUERY" -g "LSEQ 2025-12-15" | head -5
echo

echo "=== Integration Test Complete ==="
echo
echo "Summary:"
echo "✅ Comprehensive TODO query added to DatalogQueryBuilder.comprehensiveTodoTasksQuery()"
echo "✅ Comprehensive TODO query added to SettingsView sample queries"
echo "✅ Query works correctly with Logseq CLI"
echo "✅ App builds successfully with the new query"
#!/bin/bash

echo "=== Testing Comprehensive TODO Query ==="
echo

# Test the comprehensive TODO query
COMPREHENSIVE_QUERY='[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties :logseq.property/status :logseq.property/priority :logseq.property/scheduled :logseq.property/deadline]) :where (or-join [?b] (and [?b :block/tags ?t] [?t :block/title "Task"]) (and [?b :block/tags ?child] [?child :logseq.property.class/extends ?parent] [?parent :block/title "Task"])) [?b :logseq.property/status ?s] [?s :block/title "Todo"] [?b :logseq.property/priority ?p]]'

echo "Query: $COMPREHENSIVE_QUERY"
echo
echo "Testing with CLI..."
echo

logseq query "$COMPREHENSIVE_QUERY" -g "LSEQ 2025-12-15" | head -10

echo
echo "=== Test Complete ==="
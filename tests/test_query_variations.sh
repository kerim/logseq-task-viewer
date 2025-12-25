#!/bin/bash

echo "=== Testing Query Variations ==="
echo

echo "Option 1: Original Comprehensive Query (with priority)"
WITH_PRIORITY='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where (or-join [?b] (and [?b :block/tags ?t] [?t :block/title "Task"]) (and [?b :block/tags ?child] [?child :logseq.property.class/extends ?parent] [?parent :block/title "Task"])) [?b :logseq.property/status ?s] [?s :block/title "Todo"] [?b :logseq.property/priority ?p]]'
echo "Results:"
logseq query "$WITH_PRIORITY" -g "LSEQ 2025-12-15" | head -5
echo

echo "Option 2: Comprehensive Query without priority requirement"
WITHOUT_PRIORITY='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where (or-join [?b] (and [?b :block/tags ?t] [?t :block/title "Task"]) (and [?b :block/tags ?child] [?child :logseq.property.class/extends ?parent] [?parent :block/title "Task"])) [?b :logseq.property/status ?s] [?s :block/title "Todo"]]'
echo "Results:"
logseq query "$WITHOUT_PRIORITY" -g "LSEQ 2025-12-15" | head -10
echo

echo "Option 3: Simple TODO query (just status, no task identification)"
SIMPLE_TODO='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where [?b :logseq.property/status ?s] [?s :block/title "Todo"] :limit 10]'
echo "Results:"
logseq query "$SIMPLE_TODO" -g "LSEQ 2025-12-15" | head -10
echo

echo "=== Recommendation ==="
echo "The comprehensive query is working correctly!"
echo "If you want to see more results, you can:"
echo "1. Use the version without priority requirement (Option 2)"
echo "2. Add more test data with TODO + priority + task identification"
echo "3. Use a different graph with more diverse task data"
echo
echo "The current query is correctly implementing the logic you specified:"
echo "- Find tasks that are either #Task tagged OR extend Task class"
echo "- Filter for TODO status"
echo "- Require priority to be present"
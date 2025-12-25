#!/bin/bash

echo "=== Analyzing Task Data in Graph ==="
echo

echo "Test 1: Find all TODO tasks and their tags"
TODO_WITH_TAGS='[:find (pull ?b [:block/uuid :block/title :block/tags :logseq.property/status]) :where [?b :logseq.property/status ?s] [?s :block/title "Todo"] :limit 20]'
echo "Query: $TODO_WITH_TAGS"
logseq query "$TODO_WITH_TAGS" -g "LSEQ 2025-12-15" | head -20
echo

echo "Test 2: Find all tasks with #Shopping tag"
SHOPPING_TASKS='[:find (pull ?b [:block/uuid :block/title :block/tags :logseq.property/status]) :where [?b :block/tags ?t] [?t :block/title "Shopping"] :limit 10]'
echo "Query: $SHOPPING_TASKS"
logseq query "$SHOPPING_TASKS" -g "LSEQ 2025-12-15" | head -10
echo

echo "Test 3: Find all tasks with priority (regardless of status)"
TASKS_WITH_PRIORITY='[:find (pull ?b [:block/uuid :block/title :logseq.property/priority]) :where [?b :logseq.property/priority ?p] :limit 10]'
echo "Query: $TASKS_WITH_PRIORITY"
logseq query "$TASKS_WITH_PRIORITY" -g "LSEQ 2025-12-15" | head -10
echo

echo "Test 4: Find TODO tasks with priority (this is what comprehensive query should return)"
TODO_WITH_PRIORITY='[:find (pull ?b [:block/uuid :block/title :block/tags]) :where [?b :logseq.property/status ?s] [?s :block/title "Todo"] [?b :logseq.property/priority ?p] :limit 10]'
echo "Query: $TODO_WITH_PRIORITY"
logseq query "$TODO_WITH_PRIORITY" -g "LSEQ 2025-12-15" | head -10
echo

echo "Test 5: Check if there are any tasks that extend Task class"
TASK_CLASS_EXTENSIONS='[:find ?child ?parent :where [?child :logseq.property.class/extends ?parent] [?parent :block/title "Task"] :limit 10]'
echo "Query: $TASK_CLASS_EXTENSIONS"
logseq query "$TASK_CLASS_EXTENSIONS" -g "LSEQ 2025-12-15" | head -10
echo

echo "=== Analysis Complete ==="
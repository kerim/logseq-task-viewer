#!/bin/bash

# Simple test for doing tasks functionality
echo "=== Simple Test: Doing Tasks Query ==="
echo

# Test the query directly with Logseq CLI
echo "Testing query directly with Logseq CLI..."

query='[:find (pull ?b [:block/uuid :block/content :block/tags]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]]'

echo "Query:"
echo "$query"
echo
echo "="

# Test with Logseq CLI
if command -v logseq &> /dev/null; then
    echo "Running query on LSEQ 2025-12-15 graph..."
    result=$(logseq query "$query" -g "LSEQ 2025-12-15" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✅ Query executed successfully"
        echo
        echo "Results:"
        echo "$result"
        
        # Count the number of tasks found
        task_count=$(echo "$result" | grep -o "uuid" | wc -l)
        echo
        echo "Found $task_count tasks with 'Doing' status"
    else
        echo "❌ Query failed"
        echo "$result"
    fi
else
    echo "❌ Logseq CLI not found"
fi

echo
echo "=== Test Complete ==="
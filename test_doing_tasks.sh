#!/bin/bash

# Test script for doing tasks query
# This script tests the new doingTasksQuery() method

echo "Testing doing tasks query..."
echo "="

# The query we want to test
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
echo "Running query..."
echo

# Test the query with Logseq CLI
if command -v logseq &> /dev/null; then
    echo "Available graphs:"
    logseq list
    echo
    
    # Use the first available graph or a specific one
    graph_name="LSEQ 2025-12-15"  # Change this to your actual graph name
    result=$(logseq query "$query" -g "$graph_name" 2>&1)
    echo "Query Results for graph '$graph_name':"
    echo "$result"
else
    echo "Logseq CLI not found. Please ensure Logseq is installed and in your PATH."
fi

echo
echo "Test completed."
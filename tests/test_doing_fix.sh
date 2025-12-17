#!/bin/bash

echo "Testing DOING query fix..."

# Test the query directly with Logseq CLI
QUERY='[:find (pull ?b [:block/uuid :block/content :block/tags :block/properties])
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]
    [?b :logseq.property/status ?s]
    [?s :block/title "Doing"]]'

echo "Query:"
echo "$QUERY"
echo ""

# Execute query
RESULT=$(/opt/homebrew/bin/logseq query "$QUERY" -g "LSEQ 2025-12-15" 2>&1)

echo "Raw EDN result:"
echo "$RESULT"
echo ""

# Convert to JSON
JSON_RESULT=$(/opt/homebrew/bin/jet --to json <<< "$RESULT" 2>&1)

echo "JSON result:"
echo "$JSON_RESULT"
echo ""

# Check if we got results
echo "Checking for DOING tasks..."
echo "$JSON_RESULT" | grep -c '"Doing"' || echo "No DOING tasks found in results"

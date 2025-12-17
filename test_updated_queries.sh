#!/bin/bash

# Test script to verify the updated queries work correctly
# This script tests the updated DatalogQueryBuilder queries

echo "Testing Updated Datalog Queries"
echo "================================"

# Test 1: Simple task query (should now resolve status names)
echo ""
echo "Test 1: Simple Task Query (with status resolution)"
echo "Query: simpleTaskQuery()"

# Extract the simple task query from the Swift file
SIMPLE_QUERY=$(grep -A 5 "simpleTaskQuery()" LogseqTaskViewer/Services/DatalogQueryBuilder.swift | grep -v "---" | grep -v "static func" | grep -v "return" | grep -v '"""' | sed 's/^[[:space:]]*//' | sed 's/"""//' | sed 's/\\//' | tr -d '\n' | sed 's/"""//')

# Clean up the query string
SIMPLE_QUERY=$(echo "$SIMPLE_QUERY" | sed 's/\\//g' | sed 's/"""//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

echo "Extracted query: $SIMPLE_QUERY"

# Test with Logseq CLI
if command -v logseq &> /dev/null; then
    echo "Running query with Logseq CLI..."
    logseq --query "$SIMPLE_QUERY" --format json 2>/dev/null | head -20
else
    echo "Logseq CLI not found. Would run: logseq --query \"$SIMPLE_QUERY\" --format json"
fi

# Test 2: All tasks query (should resolve status names)
echo ""
echo "Test 2: All Tasks Query (with status resolution)"
echo "Query: allTasksQuery()"

# Extract the all tasks query
ALL_QUERY=$(grep -A 15 "allTasksQuery()" LogseqTaskViewer/Services/DatalogQueryBuilder.swift | grep -v "---" | grep -v "static func" | grep -v "return" | grep -v '"""' | sed 's/^[[:space:]]*//' | sed 's/"""//' | sed 's/\\//' | tr -d '\n' | sed 's/"""//')

ALL_QUERY=$(echo "$ALL_QUERY" | sed 's/\\//g' | sed 's/"""//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

echo "Extracted query: $ALL_QUERY"

if command -v logseq &> /dev/null; then
    echo "Running query with Logseq CLI..."
    logseq --query "$ALL_QUERY" --format json 2>/dev/null | head -20
else
    echo "Logseq CLI not found. Would run: logseq --query \"$ALL_QUERY\" --format json"
fi

echo ""
echo "Test Summary:"
echo "- Updated queries should now resolve status IDs to human-readable names"
echo "- Queries include the pattern: [?b :logseq.property/status ?s] [?s :block/title ?status-name]"
echo "- This resolves the issue where status was returned as {:db/id 73} instead of \"Done\""

echo ""
echo "Next Steps:"
echo "1. Update LogseqBlock.swift to handle the new query result structure"
echo "2. Update LogseqTask.swift to parse status names instead of IDs"
echo "3. Test the full data flow from query to UI display"
#!/bin/bash

# Simple test to verify the updated queries work
echo "Testing Updated Query Patterns"
echo "=============================="

# Test the simple task query pattern that should resolve status names
SIMPLE_QUERY='[:find (pull ?b [:block/uuid :block/content]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]]'

echo ""
echo "Test Query:"
echo "$SIMPLE_QUERY"
echo ""

# Test with Logseq CLI if available
if command -v logseq &> /dev/null; then
    echo "Running query with Logseq CLI..."
    echo "Command: logseq query \"$SIMPLE_QUERY\" -g \"LSEQ 2025-12-15\" --format json"
    
    # Run the query and show first few results
    RESULT=$(logseq query "$SIMPLE_QUERY" -g "LSEQ 2025-12-15" --format json 2>/dev/null)
    
    if [ -n "$RESULT" ]; then
        echo "Query successful! First 500 characters of result:"
        echo "$RESULT" | head -c 500
        echo "..."
        
        # Check if we get status names instead of IDs
        if echo "$RESULT" | grep -q "Done\|Todo\|Doing\|Backlog\|Canceled\|In Review"; then
            echo "✅ SUCCESS: Query returns status names (not just IDs)"
            echo "Found status names: $(echo "$RESULT" | grep -o "\"[A-Za-z ]*\"" | sort | uniq)"
        else
            echo "⚠️  Query ran but may not have resolved status names"
        fi
    else
        echo "❌ Query failed or returned no results"
    fi
else
    echo "Logseq CLI not found in PATH"
    echo "The updated query pattern should resolve status IDs to human-readable names"
    echo "Example: Instead of {:db/id 73}, it should return \"Done\""
fi

echo ""
echo "Query Analysis:"
echo "- The query now includes: [?b :logseq.property/status ?s] [?s :block/title ?status-name]"
echo "- This resolves status entity references to their actual names"
echo "- Expected status names: Todo, Doing, Done, Backlog, Canceled, In Review"

echo ""
echo "Next Steps:"
echo "1. Update LogseqBlock.swift to parse the new result structure"
echo "2. Update LogseqTask.swift to handle status names"
echo "3. Build and test the full application flow"
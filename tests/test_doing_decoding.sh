#!/bin/bash

echo "=== Testing DOING Query Decoding ==="

# Set up paths
LOGSEQ_CLI="/opt/homebrew/bin/logseq"
JET_CLI="/opt/homebrew/bin/jet"
GRAPH_NAME="LSEQ 2025-12-15"

# Query for DOING tasks
QUERY='[:find (pull ?b [:block/uuid :block/content :block/tags]) ?status-name
:where
    [?b :block/tags ?t]
    [?t :block/title "Task"]
    [?b :logseq.property/status ?s]
    [?s :block/title ?status-name]
    [(= ?status-name "Doing")]]'

echo "Query: $QUERY"
echo ""

# Execute query
echo "=== Executing Logseq Query ==="
QUERY_OUTPUT=$($LOGSEQ_CLI query "$QUERY" -g "$GRAPH_NAME" 2>&1)

echo "Query output:"
echo "$QUERY_OUTPUT"
echo ""

# Convert EDN to JSON
echo "=== Converting EDN to JSON ==="
JSON_OUTPUT=$(echo "$QUERY_OUTPUT" | $JET_CLI --to json 2>&1)

echo "JSON output:"
echo "$JSON_OUTPUT"
echo ""

# Test if we can parse the JSON structure
echo "=== Testing JSON Structure ==="
echo "$JSON_OUTPUT" | python3 -c "
import sys
import json

try:
    data = json.load(sys.stdin)
    print(f'Successfully parsed JSON')
    print(f'Type: {type(data)}')
    print(f'Length: {len(data)}')
    
    if len(data) > 0:
        first_item = data[0]
        print(f'First item type: {type(first_item)}')
        print(f'First item length: {len(first_item)}')
        
        if len(first_item) >= 2:
            block_data = first_item[0]
            status_name = first_item[1]
            print(f'Block data: {block_data}')
            print(f'Status name: {status_name}')
            
except Exception as e:
    print(f'Error parsing JSON: {e}')
"

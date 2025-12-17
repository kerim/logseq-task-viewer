#!/bin/bash

# Test to resolve block references within task titles
echo "=== Testing Block Reference Resolution ==="

# First, get the DOING tasks with their references
QUERY='[:find (pull ?b [:block/uuid :block/title :block/refs]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]]'

echo "Step 1: Get DOING tasks with references"
echo "Query: $QUERY"
echo ""

RESULT=$(logseq query "$QUERY" -g "LSEQ 2025-12-15")
echo "Raw EDN Result:"
echo "$RESULT"
echo ""

# Extract the UUIDs that need resolution
# Looking for patterns like [[68f48c70-c9cf-4960-89b1-853802050a5f]]
echo "Step 2: Extract block references from titles"

# Extract UUIDs from the EDN result
UUIDS=$(echo "$RESULT" | grep -oE '#uuid "[^"]+"' | sed 's/#uuid "//;s/"//' | sort | uniq)

echo "Found UUIDs in results:"
echo "$UUIDS"
echo ""

# For each UUID, try to resolve it to a title
if [ -n "$UUIDS" ]; then
    echo "Step 3: Resolve each reference to its title"
    
    for UUID in $UUIDS; do
        echo "Resolving UUID: $UUID"
        
        # Query to get the title of this block
        RESOLVE_QUERY="[:find (pull ?b [:block/uuid :block/title]) :where [?b :block/uuid #uuid \"$UUID\"]]"
        
        echo "Resolve query: $RESOLVE_QUERY"
        RESOLVE_RESULT=$(logseq query "$RESOLVE_QUERY" -g "LSEQ 2025-12-15")
        echo "Resolve result: $RESOLVE_RESULT"
        echo ""
    done
else
    echo "No UUIDs found to resolve"
fi

echo "=== Reference Resolution Test Complete ==="

#!/bin/bash

# Test simpler approach - get tasks and their referenced blocks
echo "=== Testing Simple Reference Resolution ==="

# First, get just the DOING tasks
TASKS_QUERY='[:find (pull ?b [:block/uuid :block/title]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]]'

echo "Step 1: Get DOING tasks"
TASKS_RESULT=$(logseq query "$TASKS_QUERY" -g "LSEQ 2025-12-15")
echo "$TASKS_RESULT"
echo ""

# Extract UUIDs from titles
UUIDS=$(echo "$TASKS_RESULT" | grep -oE '\[\[[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\]\]' | sed 's/\[\[//;s/\]\]//' | sort | uniq)

echo "Step 2: Found UUIDs to resolve: $UUIDS"
echo ""

if [ -n "$UUIDS" ]; then
    # Build a query to get all referenced blocks at once
    echo "Step 3: Build resolution query"
    
    # Start building the query
    RESOLUTION_QUERY='[:find ?uuid ?title :where'
    
    # Add conditions for each UUID
    for UUID in $UUIDS; do
        RESOLUTION_QUERY="$RESOLUTION_QUERY \n  [?b$UUID :block/uuid #uuid \"$UUID\"]"
        RESOLUTION_QUERY="$RESOLUTION_QUERY \n  [?b$UUID :block/title ?title$UUID]"
    done
    
    # Add the return values
    RESOLUTION_QUERY="$RESOLUTION_QUERY \n  [(tuple ?uuid ?title)]]"
    
    echo "Resolution Query:"
    echo "$RESOLUTION_QUERY"
    echo ""
    
    # This approach is getting complex, let's try a simpler method
    echo "Step 4: Simple individual resolution"
    
    for UUID in $UUIDS; do
        SIMPLE_QUERY="[:find (pull ?b [:block/uuid :block/title]) :where [?b :block/uuid #uuid \"$UUID\"]]"
        RESOLUTION=$(logseq query "$SIMPLE_QUERY" -g "LSEQ 2025-12-15")
        
        if [ "$RESOLUTION" != "()" ]; then
            # Extract just the title
            TITLE=$(echo "$RESOLUTION" | sed 's/.*:block\/title "\([^"]*\)".*/\1/')
            echo "UUID $UUID → $TITLE"
        else
            echo "UUID $UUID → NOT FOUND"
        fi
    done
fi

echo ""
echo "=== Simple Resolution Complete ==="

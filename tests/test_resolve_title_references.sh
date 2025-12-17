#!/bin/bash

# Test to resolve block references within task titles
echo "=== Testing Title Reference Resolution ==="

# Get the DOING tasks
QUERY='[:find (pull ?b [:block/uuid :block/title]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]]'

echo "Step 1: Get DOING tasks"
RESULT=$(logseq query "$QUERY" -g "LSEQ 2025-12-15")
echo "$RESULT"
echo ""

# Extract UUIDs from the title text (patterns like [[uuid]])
echo "Step 2: Extract UUIDs from titles"

# Use grep to find UUID patterns in the titles
TITLE_UUIDS=$(echo "$RESULT" | grep -oE '\[\[[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\]\]' | sed 's/\[\[//;s/\]\]//' | sort | uniq)

echo "Found UUIDs in titles:"
echo "$TITLE_UUIDS"
echo ""

if [ -n "$TITLE_UUIDS" ]; then
    echo "Step 3: Resolve each title reference"
    
    for UUID in $TITLE_UUIDS; do
        echo "Resolving UUID: $UUID"
        
        # Query to get the title of this referenced block
        RESOLVE_QUERY="[:find (pull ?b [:block/uuid :block/title]) :where [?b :block/uuid #uuid \"$UUID\"]]"
        
        RESOLVE_RESULT=$(logseq query "$RESOLVE_QUERY" -g "LSEQ 2025-12-15")
        
        if [ "$RESOLVE_RESULT" != "()" ]; then
            echo "Found: $RESOLVE_RESULT"
        else
            echo "Not found in database"
        fi
        echo ""
    done
else
    echo "No UUID references found in titles"
fi

echo "=== Title Reference Resolution Complete ==="

#!/bin/bash

# Simulate what the app will do when it runs
echo "=== Simulating App Run ==="
echo "This simulates the exact flow the app will follow"
echo

# Simulate the CLI connection test
echo "1. Testing CLI connection..."
if command -v logseq &> /dev/null && command -v jet &> /dev/null; then
    echo "✅ CLI tools available"
else
    echo "❌ CLI tools not available"
    exit 1
fi

echo "2. Listing graphs..."
GRAPHS=$(logseq list | grep -A 10 "DB Graphs:")
echo "Available graphs:"
echo "$GRAPHS"

echo "3. Running DOING query..."
QUERY='[:find (pull ?b [:block/uuid :block/title :block/content :block/tags :block/properties]) ?status-name
 :where
   [?b :block/tags ?t]
   [?t :block/title "Task"]
   [?b :logseq.property/status ?s]
   [?s :block/title ?status-name]
   [(= ?status-name "Doing")]]'

RESULT=$(logseq query "$QUERY" -g "LSEQ 2025-12-15")

echo "4. Converting EDN to JSON..."
JSON_RESULT=$(echo "$RESULT" | /opt/homebrew/bin/jet --from edn --to json)

echo "5. Parsing results..."

# Count tasks
TASK_COUNT=$(echo "$JSON_RESULT" | grep -c "Doing")
echo "Found $TASK_COUNT DOING tasks"

# Extract and display task details
echo ""
echo "Task details:"
echo "-------------"

# Use jq if available, otherwise use simple parsing
if command -v jq &> /dev/null; then
    # Extract tasks with jq
    for i in $(seq 0 $((TASK_COUNT - 1))); do
        TASK=$(echo "$JSON_RESULT" | jq -r ".[$i][0]")
        STATUS=$(echo "$JSON_RESULT" | jq -r ".[$i][1]")
        UUID=$(echo "$TASK" | jq -r '."block/uuid"')
        TITLE=$(echo "$TASK" | jq -r '."block/title"')
        
        echo "Task $((i + 1)):"
        echo "  UUID: $UUID"
        echo "  Title: $TITLE"
        echo "  Status: $STATUS"
        echo ""
    done
else
    # Simple parsing without jq
    echo "$JSON_RESULT" | grep -o '"block/uuid" : "[^"]*"' | sed 's/"block\/uuid" : "//;s/"//' | while read uuid; do
        echo "  UUID: $uuid"
    done
    
    echo "$JSON_RESULT" | grep -o '"block/title" : "[^"]*"' | sed 's/"block\/title" : "//;s/"//' | while read title; do
        echo "  Title: $title"
    done
fi

echo "=== Simulation Complete ==="
echo
echo "The app should now display:"
echo "- $TASK_COUNT DOING tasks"
echo "- Each task with its UUID and title content"
echo "- Proper status resolution (Doing)"

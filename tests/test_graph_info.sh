#!/bin/bash

# Test to see info about the graph
echo "=== Testing Graph Info ==="

# Get graph info
INFO=$( /opt/homebrew/bin/logseq show -g "LSEQ 2025-12-15")

echo "Graph Info:"
echo "$INFO"
echo ""

# Try a very simple query to see if graph is accessible
SIMPLE_QUERY='[:find ?b :where [?b :block/uuid]]'

echo "Simple Query: $SIMPLE_QUERY"

RESULT=$(echo "$SIMPLE_QUERY" | /opt/homebrew/bin/logseq query -g "LSEQ 2025-12-15")

echo "Simple Query Result:"
echo "$RESULT"

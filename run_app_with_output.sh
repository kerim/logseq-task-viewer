#!/bin/bash

echo "Running LogseqTaskViewer with output capture..."

# Run the app and capture output
cd /Users/niyaro/Documents/Code/Logseq/logseq\ task\ viewer

# Kill any existing instance
pkill -f LogseqTaskViewer || true

# Wait a bit
sleep 2

# Run the app in the background and capture output
nohup ./DerivedData/Build/Products/Debug/LogseqTaskViewer.app/Contents/MacOS/LogseqTaskViewer > console_output.txt 2>&1 &

# Wait for the app to start and produce output
sleep 15

# Show the output
echo "=== Console Output ==="
tail -n 100 console_output.txt || echo "No output captured yet"

# Show if the app is still running
ps aux | grep LogseqTaskViewer | grep -v grep
#!/bin/bash

echo "=== Running LogseqTaskViewer from command line ==="
echo

# Kill any existing processes
echo "Step 1: Killing existing processes..."
pkill -f LogseqTaskViewer || true
sleep 1
echo

# Check if the app exists
echo "Step 2: Checking for built app..."
APP_PATH="build/Build/Products/Debug/LogseqTaskViewer.app/Contents/MacOS/LogseqTaskViewer"
if [ ! -f "$APP_PATH" ]; then
    echo "✗ App not found. Please build the project first."
    echo "Run: xcodebuild -project LogseqTaskViewer.xcodeproj -scheme LogseqTaskViewer -configuration Debug"
    exit 1
fi
echo "✓ Found app at: $APP_PATH"
echo

# Run the app and capture output
echo "Step 3: Running app and capturing console output..."
echo "================================================"
echo

# Run the app and capture both stdout and stderr
"$APP_PATH" 2>&1 | tee console_output_live.txt

echo
echo "================================================"
echo "=== App finished running ==="
echo "Console output has been saved to: console_output_live.txt"
echo "You can also check the main console output file: console output.txt"

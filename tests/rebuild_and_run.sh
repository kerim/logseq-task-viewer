#!/bin/bash

echo "=== Rebuilding and Running LogseqTaskViewer ==="
echo

# Kill any existing processes
echo "Step 1: Killing existing processes..."
pkill -f LogseqTaskViewer || true
sleep 1
echo

# Clean build
echo "Step 2: Cleaning build..."
rm -rf build/
echo

# Build the app
echo "Step 3: Building the app..."
xcodebuild -project LogseqTaskViewer.xcodeproj -scheme LogseqTaskViewer -configuration Debug
if [ $? -ne 0 ]; then
    echo "✗ Build failed"
    exit 1
fi
echo

# Run the app
echo "Step 4: Running the app..."
open build/Build/Products/Debug/LogseqTaskViewer.app
echo

echo "=== Done ==="
echo "The app should now be running with the layout fix applied."
echo "Check the console output to verify the layout error is gone."

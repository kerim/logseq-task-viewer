#!/bin/bash

echo "=== Running LogseqTaskViewer ==="
echo

# Find the most recent build of the app
APP_PATH=$(find /Users/niyaro/Library/Developer/Xcode/DerivedData -name "LogseqTaskViewer.app" -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    echo "✗ Could not find the app. Please build the project first."
    echo "Run: xcodebuild -project LogseqTaskViewer.xcodeproj -scheme LogseqTaskViewer -configuration Debug"
    exit 1
fi

echo "✓ Found app at: $APP_PATH"
echo "Opening the app..."
echo

# Run the app
open "$APP_PATH"

echo "✓ App should now be running!"
echo "Check the menu bar for the LogseqTaskViewer icon."

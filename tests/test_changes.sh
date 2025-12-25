#!/bin/bash

echo "Testing Logseq Task Viewer Changes"
echo "=================================="
echo ""

# Find the built app
APP_PATH="/Users/niyaro/Library/Developer/Xcode/DerivedData/LogseqTaskViewer-flbipwfkhjxlxtaqfxquhbxyxogd/Build/Products/Debug/LogseqTaskViewer.app"

echo "Looking for built app at: $APP_PATH"
echo ""

# Check if app exists
if [ -d "$APP_PATH" ]; then
    echo "✅ App found!"
    echo ""
    
    # Get app info
    echo "App Info:"
    ls -la "$APP_PATH"
    echo ""
    
    # Check if we can run it
    echo "Checking if app is executable..."
    if [ -x "$APP_PATH/Contents/MacOS/LogseqTaskViewer" ]; then
        echo "✅ App is executable"
        echo ""
        echo "To test the changes:"
        echo "1. Quit any running instance of Logseq Task Viewer"
        echo "2. Run: open $APP_PATH"
        echo "3. Check Console.app for debug messages starting with 'DEBUG:'"
        echo "4. Test the following:"
        echo "   - Single click on menu bar icon (should open popover immediately)"
        echo "   - Switch between different query types (TODO, DOING, etc.)"
        echo "   - Check that loading text shows the correct query type"
        echo "   - Check that empty state shows the correct query type"
        echo "   - Test custom queries to see if links resolve properly"
    else
        echo "❌ App is not executable"
    fi
else
    echo "❌ App not found. Please build the project first."
    echo "Run: xcodebuild -project LogseqTaskViewer.xcodeproj -scheme LogseqTaskViewer -configuration Debug build"
fi
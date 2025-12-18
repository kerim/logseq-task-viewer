#!/bin/bash

# Add new Swift files to the Xcode project
cd /Users/niyaro/Documents/Code/Logseq/logseq\ task\ viewer

# Check if files exist
if [ ! -f "LogseqTaskViewer/Views/TaskListView.swift" ]; then
    echo "Error: TaskListView.swift not found"
    exit 1
fi

if [ ! -f "LogseqTaskViewer/ViewModels/TaskViewModel.swift" ]; then
    echo "Error: TaskViewModel.swift not found"
    exit 1
fi

echo "Files exist, adding to Xcode project..."

# For now, just build to see if there are other issues
xcodebuild -project LogseqTaskViewer.xcodeproj -scheme LogseqTaskViewer build

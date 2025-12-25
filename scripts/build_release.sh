#!/bin/bash
set -e

echo "Building Logseq Task Viewer v1.0.0..."

# Clean previous builds
rm -rf build/
rm -f LogseqTaskViewer.app.zip

# Build release configuration
xcodebuild -scheme LogseqTaskViewer \
           -configuration Release \
           -derivedDataPath build \
           clean build

# Copy app to build directory
mkdir -p build/Release
cp -R build/Build/Products/Release/LogseqTaskViewer.app build/Release/

# Create distributable zip
cd build/Release
zip -r ../../LogseqTaskViewer.app.zip LogseqTaskViewer.app
cd ../..

echo "✅ Build complete: LogseqTaskViewer.app.zip"
echo "   App location: build/Release/LogseqTaskViewer.app"
echo "   Zip location: LogseqTaskViewer.app.zip"

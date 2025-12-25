#!/bin/bash
set -e

# Logseq-inspired colors
BG_COLOR="#002B36"      # Dark teal (Logseq-like)
CHECK_COLOR="#FFFFFF"   # White checkmark
CIRCLE_COLOR="#38B2AC"  # Teal accent (Logseq teal)

# Project paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"
APPICONSET_DIR="$PROJECT_ROOT/LogseqTaskViewer/Resources/Assets.xcassets/AppIcon.appiconset"

echo "Generating Logseq Task Viewer app icons..."
echo "Background: $BG_COLOR"
echo "Circle: $CIRCLE_COLOR"
echo "Checkmark: $CHECK_COLOR"
echo ""

# Create appiconset directory
mkdir -p "$APPICONSET_DIR"

# Function to generate icon at specific size
generate_icon() {
    local SIZE=$1
    local OUTPUT="$APPICONSET_DIR/icon_${SIZE}x${SIZE}.png"

    # Create icon with ImageMagick
    magick -size ${SIZE}x${SIZE} xc:"$BG_COLOR" \
        -fill "$CIRCLE_COLOR" \
        -draw "circle $(($SIZE/2)),$(($SIZE/2)) $(($SIZE/2)),$(($SIZE*2/10))" \
        -fill "$CHECK_COLOR" \
        -stroke "$CHECK_COLOR" \
        -strokewidth $(($SIZE/30)) \
        -draw "path 'M $(($SIZE*3/10)),$(($SIZE*5/10)) L $(($SIZE*45/100)),$(($SIZE*65/100)) L $(($SIZE*7/10)),$(($SIZE*35/100))'" \
        "$OUTPUT"

    echo "✓ Generated ${SIZE}x${SIZE} icon"
}

# Generate all required sizes for macOS
generate_icon 16
generate_icon 32
generate_icon 64
generate_icon 128
generate_icon 256
generate_icon 512
generate_icon 1024

# Create Contents.json
cat > "$APPICONSET_DIR/Contents.json" <<'EOF'
{
  "images" : [
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_64x64.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_1024x1024.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo ""
echo "✅ App icons generated successfully!"
echo "   Location: $APPICONSET_DIR"
echo ""
echo "Next steps:"
echo "1. Rebuild the app: ./scripts/build_release.sh"
echo "2. The new icon will appear in Finder and the Dock"

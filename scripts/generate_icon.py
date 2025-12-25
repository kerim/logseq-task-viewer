#!/usr/bin/env python3
"""
Generate app icon for Logseq Task Viewer
Uses checkmark.circle with Logseq-inspired colors
"""

import os
import subprocess
import json

# Logseq-inspired colors (dark teal background, white checkmark)
BACKGROUND_COLOR = "#002B36"  # Dark teal/blue (Logseq-like)
CHECKMARK_COLOR = "#FFFFFF"   # White checkmark

# Icon sizes needed for macOS app
SIZES = [
    16, 32, 64, 128, 256, 512, 1024
]

def create_icon_at_size(size, output_path):
    """Create icon using SF Symbols via Swift"""
    swift_code = f'''
import Cocoa
import AppKit

let size = CGSize(width: {size}, height: {size})
let image = NSImage(size: size)

image.lockFocus()

// Background circle
let bgColor = NSColor(red: 0.0, green: 0.169, blue: 0.212, alpha: 1.0)  // #002B36
bgColor.setFill()
let bgPath = NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: {size}, height: {size}))
bgPath.fill()

// Checkmark using SF Symbol
if let checkmarkImage = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: nil) {{
    let config = NSImage.SymbolConfiguration(pointSize: {size} * 0.7, weight: .medium)
    let configuredImage = checkmarkImage.withSymbolConfiguration(config)

    // Draw white checkmark
    let imageRect = NSRect(x: {size} * 0.15, y: {size} * 0.15, width: {size} * 0.7, height: {size} * 0.7)

    configuredImage?.draw(in: imageRect, from: .zero, operation: .sourceOver, fraction: 1.0)
}}

image.unlockFocus()

// Save as PNG
if let tiffData = image.tiffRepresentation,
   let bitmapImage = NSBitmapImageRep(data: tiffData),
   let pngData = bitmapImage.representation(using: .png, properties: [:]) {{
    try? pngData.write(to: URL(fileURLWithPath: "{output_path}"))
}}
'''

    # Write Swift code to temp file
    temp_swift = f"/tmp/generate_icon_{size}.swift"
    with open(temp_swift, 'w') as f:
        f.write(swift_code)

    # Compile and run Swift code
    try:
        subprocess.run(['swift', temp_swift], check=True, capture_output=True)
        print(f"✓ Generated {size}x{size} icon")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to generate {size}x{size} icon: {e.stderr.decode()}")
        return False
    finally:
        if os.path.exists(temp_swift):
            os.remove(temp_swift)

def main():
    # Get project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)

    # Create AppIcon.appiconset directory
    appiconset_path = os.path.join(
        project_root,
        "LogseqTaskViewer/Resources/Assets.xcassets/AppIcon.appiconset"
    )
    os.makedirs(appiconset_path, exist_ok=True)

    print("Generating app icons...")
    print(f"Background: {BACKGROUND_COLOR}")
    print(f"Checkmark: {CHECKMARK_COLOR}")
    print()

    # Generate icons at each size
    contents = {
        "images": [],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

    for size in SIZES:
        filename = f"icon_{size}x{size}.png"
        output_path = os.path.join(appiconset_path, filename)

        if create_icon_at_size(size, output_path):
            # Add to Contents.json
            if size <= 32:
                scale = "1x" if size == 16 else "2x"
                idiom_size = "16x16" if size <= 32 else "32x32"
            else:
                scale = "1x" if size in [128, 256, 512] else "2x"
                if size == 64:
                    idiom_size = "32x32"
                elif size in [128, 256]:
                    idiom_size = "128x128"
                elif size in [256, 512]:
                    idiom_size = "256x256"
                else:
                    idiom_size = "512x512"

            contents["images"].append({
                "filename": filename,
                "idiom": "mac",
                "scale": scale,
                "size": idiom_size
            })

    # Write Contents.json
    contents_path = os.path.join(appiconset_path, "Contents.json")
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)

    print()
    print(f"✅ App icon generated at:")
    print(f"   {appiconset_path}")
    print()
    print("Next steps:")
    print("1. Rebuild the app: ./scripts/build_release.sh")
    print("2. The new icon will appear in the built app")

if __name__ == "__main__":
    main()

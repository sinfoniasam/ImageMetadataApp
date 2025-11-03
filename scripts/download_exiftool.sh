#!/bin/bash
# Script to download and prepare ExifTool for bundling with the macOS app

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="$PROJECT_DIR/ImageMetadataApp/ImageMetadataApp"

echo "🚀 ExifTool Bundle Preparation Script"
echo "======================================"
echo ""

# Check if ExifTool is already installed
if command -v exiftool &> /dev/null; then
    echo "✅ Found ExifTool installed on system"
    EXIFTOOL_PATH=$(which exiftool)
    EXIFTOOL_DIR=$(dirname "$EXIFTOOL_PATH")
    echo "   Location: $EXIFTOOL_PATH"
    echo ""
    
    echo "📦 Copying ExifTool from system installation..."
    mkdir -p "$TARGET_DIR"
    
    # Copy exiftool script
    cp "$EXIFTOOL_PATH" "$TARGET_DIR/exiftool"
    echo "   ✅ Copied exiftool script"
    
    # Copy lib directory
    if [ -d "$EXIFTOOL_DIR/lib" ]; then
        cp -R "$EXIFTOOL_DIR/lib" "$TARGET_DIR/"
        echo "   ✅ Copied lib directory"
    elif [ -d "/usr/local/lib/Image-ExifTool" ]; then
        # Sometimes lib is in a different location
        mkdir -p "$TARGET_DIR/lib"
        cp -R /usr/local/lib/Image-ExifTool/lib/* "$TARGET_DIR/lib/"
        echo "   ✅ Copied lib directory from /usr/local/lib/Image-ExifTool"
    else
        echo "   ⚠️  Warning: Could not find lib directory"
        echo "   You may need to download ExifTool manually"
    fi
    
else
    echo "📥 ExifTool not found on system. Downloading from exiftool.org..."
    echo ""
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    # Get latest version
    echo "   Fetching latest version info..."
    LATEST_URL="https://exiftool.org/Image-ExifTool.tar.gz"
    
    cd "$TEMP_DIR"
    echo "   Downloading ExifTool..."
    curl -L -o exiftool.tar.gz "$LATEST_URL" || {
        echo "   ❌ Failed to download. Please download manually from https://exiftool.org/"
        exit 1
    }
    
    echo "   Extracting..."
    tar -xzf exiftool.tar.gz
    
    # Find the extracted directory
    EXTRACTED_DIR=$(find . -type d -name "Image-ExifTool-*" | head -1)
    
    if [ -z "$EXTRACTED_DIR" ]; then
        echo "   ❌ Could not find extracted directory"
        exit 1
    fi
    
    echo "   ✅ Extracted to $EXTRACTED_DIR"
    
    # Copy files
    mkdir -p "$TARGET_DIR"
    cp "$EXTRACTED_DIR/exiftool" "$TARGET_DIR/exiftool"
    cp -R "$EXTRACTED_DIR/lib" "$TARGET_DIR/"
    
    echo "   ✅ Copied exiftool script"
    echo "   ✅ Copied lib directory"
fi

# Verify files exist
echo ""
echo "🔍 Verifying files..."
if [ -f "$TARGET_DIR/exiftool" ] && [ -d "$TARGET_DIR/lib" ]; then
    echo "   ✅ exiftool: Found"
    echo "   ✅ lib/: Found"
    
    # Check lib structure
    if [ -f "$TARGET_DIR/lib/Image/ExifTool.pm" ]; then
        echo "   ✅ lib/Image/ExifTool.pm: Found"
    else
        echo "   ⚠️  Warning: lib/Image/ExifTool.pm not found. Structure may be incorrect."
    fi
    
    echo ""
    echo "✨ ExifTool files are ready!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Open your Xcode project"
    echo "   2. In Xcode, drag 'exiftool' and 'lib' from the ImageMetadataApp folder into the project"
    echo "   3. Make sure 'Copy items if needed' and your target are checked"
    echo "   4. In Build Phases → Copy Bundle Resources, add both files"
    echo "   5. Add a Run Script phase to make exiftool executable (see BUNDLE_EXIFTOOL.md)"
    echo ""
    echo "   Files are at: $TARGET_DIR"
else
    echo "   ❌ Verification failed. Some files are missing."
    exit 1
fi


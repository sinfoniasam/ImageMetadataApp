#!/bin/bash

# Script to check GPS metadata in an image file
# Usage: ./check_gps_metadata.sh <image_file>

if [ -z "$1" ]; then
    echo "Usage: $0 <image_file>"
    echo "Example: $0 /path/to/image.jpg"
    exit 1
fi

IMAGE_FILE="$1"

if [ ! -f "$IMAGE_FILE" ]; then
    echo "Error: File not found: $IMAGE_FILE"
    exit 1
fi

echo "========================================="
echo "GPS Metadata Check for: $IMAGE_FILE"
echo "========================================="
echo ""

# Check if exiftool is available
if command -v exiftool &> /dev/null; then
    echo "Using ExifTool to read GPS metadata:"
    echo ""
    exiftool -GPS:all -n "$IMAGE_FILE" | grep -E "GPS|Latitude|Longitude" | head -20
    echo ""
    echo "----------------------------------------"
    echo "GPS Coordinates (decimal degrees):"
    exiftool -GPSPosition -n "$IMAGE_FILE" 2>/dev/null || echo "No GPSPosition tag found"
    echo ""
    echo "Latitude:"
    exiftool -GPSLatitude -GPSLatitudeRef -n "$IMAGE_FILE" 2>/dev/null
    echo ""
    echo "Longitude:"
    exiftool -GPSLongitude -GPSLongitudeRef -n "$IMAGE_FILE" 2>/dev/null
    echo ""
else
    echo "ExifTool not found. Install it with: brew install exiftool"
    echo ""
    echo "Trying with mdls (macOS metadata tool):"
    mdls "$IMAGE_FILE" | grep -i "gps\|latitude\|longitude" || echo "No GPS metadata found with mdls"
fi

echo ""
echo "========================================="
echo "Interpretation:"
echo "========================================="
echo ""
echo "Expected formats:"
echo "  Latitude: -90 to 90 degrees (N = positive, S = negative)"
echo "  Longitude: -180 to 180 degrees (E = positive, W = negative)"
echo ""
echo "Common issues:"
echo "  1. Coordinates swapped (lat/long reversed)"
echo "  2. Missing or incorrect references (N/S/E/W)"
echo "  3. Coordinates in wrong format (DMS vs decimal)"
echo "  4. Coordinates are 0,0 (Gulf of Guinea)"
echo ""


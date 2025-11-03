# Image Metadata App

A macOS GUI application for updating EXIF metadata in image files from a JSON file. Perfect for updating metadata on scanned film images.

## Features

- Select a folder containing image files
- Select a JSON file containing metadata to apply
- Automatically matches files from JSON `SourceFile` field to actual files in the folder
- Supports all image formats that ExifTool supports, including:
  - **RAW formats**: ARW (Sony), CR2 (Canon), NEF (Nikon), DNG, RAF (Fuji), ORF (Olympus), and more
  - **Standard formats**: JPEG, PNG, TIFF, HEIC, and more
- Updates all standard EXIF metadata fields including:
  - Date/time, GPS coordinates, camera/lens information
  - ISO, exposure settings, focal length
  - Custom fields like reel name, notes, user comments
- Progress tracking with real-time updates
- Error handling and status reporting

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later (for building)
- ExifTool (see installation below)

## Installing ExifTool

ExifTool is required for this app to work. Install it using one of these methods:

### Option 1: Homebrew (Recommended)

```bash
brew install exiftool
```

### Option 2: Direct Download

1. Download from [https://exiftool.org/](https://exiftool.org/)
2. Extract and install according to the instructions
3. Make sure `exiftool` is in your PATH

The app will automatically detect ExifTool in common installation locations:
- `/usr/local/bin/exiftool` (Intel Macs with Homebrew)
- `/opt/homebrew/bin/exiftool` (Apple Silicon Macs with Homebrew)
- Any location found in your PATH

## Building the App

### Using Xcode

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "macOS" → "App"
4. Name it "ImageMetadataApp" (or any name you prefer)
5. Language: Swift
6. Interface: SwiftUI
7. Copy all the `.swift` files from this directory into your Xcode project:
   - `ImageMetadataApp.swift`
   - `ContentView.swift`
   - `MetadataUpdateViewModel.swift`
   - `MetadataUpdateService.swift`
8. Build and run (⌘R)

### Using Swift Package Manager (Alternative)

This project can also be structured as a Swift Package, but for a macOS GUI app, Xcode is recommended.

## Usage

1. Launch the app
2. Click "Select Folder" and choose the folder containing your image files
3. Click "Select JSON" and choose your metadata JSON file
4. Click "Update Metadata" to start processing
5. Wait for the process to complete - you'll see progress updates and a success message

## JSON File Format

The JSON file should be an array of objects, where each object contains:
- `SourceFile`: The filename (e.g., `"./frame1.jpg"`) - this will be matched to files in your folder
- Various metadata fields (see the example in your query)

The app matches files based on the filename extracted from `SourceFile`. For example, if `SourceFile` is `"./frame1.jpg"`, it will look for `frame1.jpg` in your selected folder.

## Notes

- The app uses the `-overwrite_original` flag with ExifTool, so your original files will be modified
- Only files that exist in the selected folder and match entries in the JSON will be processed
- Failed files are counted and reported, but the app continues processing other files
- Empty or zero values in the JSON are skipped (not written to the image)

## Troubleshooting

**"Operation not permitted" or "Can't open perl script" error:**
This means macOS is blocking the app from running ExifTool. To fix:
1. System Settings → Privacy & Security → Full Disk Access
2. Click the + button and add your `ImageMetadataApp.app`
3. Make sure the toggle is enabled (green)
4. Restart the app

**Alternative:** Run from Terminal (bypasses some restrictions):
```bash
open "/Applications/ImageMetadataApp.app"
```
or
```bash
open "/path/to/ImageMetadataApp.app"
```

**"ExifTool Not Found" error:**
- Make sure ExifTool is installed (run `which exiftool` in Terminal to verify)
- Try reinstalling with `brew install exiftool`
- Restart the app after installing ExifTool

**Files not being updated:**
- Check that the filenames in your JSON `SourceFile` field match the actual filenames in your folder
- The app matches by base filename (ignoring extensions), so `frame1.jpg` in JSON will match `frame1.ARW` in your folder
- Verify you have write permissions for the image files
- Check the console output or error alerts for specific error messages

## License

This is a personal project. Feel free to modify and use as needed.


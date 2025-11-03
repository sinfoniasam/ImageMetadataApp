# Quick ExifTool Bundle Setup

✅ **ExifTool files have been copied to your project!**

The `exiftool` script and `lib` directory are now in:
```
ImageMetadataApp/ImageMetadataApp/exiftool
ImageMetadataApp/ImageMetadataApp/lib/
```

## Add to Xcode (5 minutes)

### Step 1: Add Files to Xcode Project

1. **Open Xcode** and open your `ImageMetadataApp.xcodeproj`

2. **In Xcode's file navigator** (left sidebar), find the `ImageMetadataApp` folder

3. **In Finder**, navigate to:
   ```
   ImageMetadataApp/ImageMetadataApp/
   ```

4. **Drag both files into Xcode:**
   - Drag `exiftool` (file) into the Xcode file list
   - Drag `lib` (folder) into the Xcode file list
   
5. **When the dialog appears:**
   - ✅ Check "Copy items if needed" (should already be checked since they're already there)
   - ✅ Check your app target (ImageMetadataApp)
   - ✅ Select "Create groups" (NOT "Create folder references")
   - Click "Finish"

6. **Verify in Xcode:**
   - You should now see `exiftool` and `lib` in your file list

### Step 2: Add to Copy Bundle Resources

1. **Select your project** (blue icon at top of left sidebar)

2. **Select your app target** "ImageMetadataApp" under TARGETS

3. **Click "Build Phases" tab**

4. **Expand "Copy Bundle Resources"** section

5. **Click the "+" button** at the bottom

6. **Add both files:**
   - Select `exiftool` and `lib` (hold Cmd to select both)
   - Click "Add"

7. **Verify:**
   - Both `exiftool` and `lib` should appear in the list

### Step 3: Make Script Executable

1. **Still in Build Phases**, click the "+" button at the top

2. **Select "New Run Script Phase"**

3. **Drag it BELOW "Copy Bundle Resources"** (order matters!)

4. **Expand the Run Script section**

5. **Paste this script:**
   ```bash
   if [ -f "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/exiftool" ]; then
       chmod +x "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/exiftool"
   fi
   ```

6. **Verify:**
   - Shell: `/bin/sh`
   - Script phase is BELOW "Copy Bundle Resources"

### Step 4: Build and Test

1. **Clean build folder:** Product → Clean Build Folder (⇧⌘K)

2. **Build:** Product → Build (⌘B)

3. **Verify it worked:**
   - Find `ImageMetadataApp.app` in Products (bottom of left sidebar)
   - Right-click → "Show in Finder"
   - Right-click the `.app` → "Show Package Contents"
   - Navigate to `Contents/Resources/`
   - You should see `exiftool` and `lib/` folder ✅

## That's It!

Your app now has ExifTool bundled and will work for RAW files without requiring system installation!

The app will:
- ✅ Use bundled ExifTool for RAW files (ARW, CR2, NEF, etc.)
- ✅ Use native ImageIO for standard formats (JPEG, PNG, TIFF, HEIC)
- ✅ Work without external dependencies or special permissions


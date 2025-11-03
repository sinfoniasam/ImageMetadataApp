# ⚠️ IMPORTANT: Add ExifTool Files to Xcode

Your ExifTool files are in the project directory but **haven't been added to Xcode yet**, so they're not being bundled with your app.

## Quick Fix (2 minutes):

### Step 1: Open Xcode
Open `ImageMetadataApp.xcodeproj` in Xcode.

### Step 2: Add Files to Project

1. **In Xcode's file navigator** (left sidebar), right-click on the `ImageMetadataApp` folder
2. Select **"Add Files to ImageMetadataApp..."**
3. Navigate to: `ImageMetadataApp/ImageMetadataApp/`
4. Select **both**:
   - `exiftool` (file)
   - `lib` (folder)
5. In the dialog:
   - ✅ Check "Copy items if needed" 
   - ✅ Check your target "ImageMetadataApp"
   - ✅ Select "Create groups"
   - Click "Add"

### Step 3: Add to Bundle Resources

1. Click your **project** (blue icon) in left sidebar
2. Click your **target** "ImageMetadataApp" under TARGETS
3. Click **"Build Phases"** tab
4. Expand **"Copy Bundle Resources"**
5. Click **"+"** button
6. Select `exiftool` and `lib`
7. Click "Add"

### Step 4: Make Script Executable

1. Still in **Build Phases**, click **"+"** at top
2. Select **"New Run Script Phase"**
3. Drag it **BELOW** "Copy Bundle Resources"
4. Paste this script:
   ```bash
   chmod +x "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/exiftool"
   ```

### Step 5: Clean & Rebuild

1. **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)

## Verify It Worked:

1. Right-click `ImageMetadataApp.app` in Products folder
2. Select "Show in Finder"
3. Right-click the `.app` → "Show Package Contents"
4. Go to `Contents/Resources/`
5. You should see `exiftool` and `lib/` ✅

**Until you do this, the app will try to use the system ExifTool and get permission errors!**


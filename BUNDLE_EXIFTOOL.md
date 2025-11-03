# How to Bundle ExifTool with Your App (Xcode 15+)

This guide will help you bundle ExifTool with your app so it works without requiring system installation.

## Step 1: Get ExifTool Files

You need two things: the `exiftool` script and the `lib` folder.

### Option A: Copy from Homebrew (If you have it installed)

Open Terminal and run:
```bash
# Create a temporary folder
mkdir ~/Desktop/exiftool_bundle
cd ~/Desktop/exiftool_bundle

# Copy the script
cp /usr/local/bin/exiftool ./exiftool

# Copy the lib directory
cp -R /usr/local/bin/lib ./

# Verify you have both
ls -la
# You should see: exiftool (file) and lib/ (directory)
```

### Option B: Download from exiftool.org

1. Go to https://exiftool.org/
2. Download the latest version (Image-ExifTool-XX.XX.tar.gz)
3. Extract it
4. Inside the extracted folder, you'll find:
   - `exiftool` (the script)
   - `lib/` (the directory with Perl modules)

## Step 2: Add Files to Xcode Project

**Important:** You're working with your source project files (`.xcodeproj`), not a `.app` file yet. The `.app` file will be created when you build.

1. **Find your Xcode project folder:**
   - In Finder, navigate to where your Xcode project is located
   - You should see your `ImageMetadataApp.xcodeproj` file (this is your project file)
   - Also look for a folder with your `.swift` files (like `ImageMetadataApp` or similar)

2. **Copy files into the project folder:**
   - Copy `exiftool` (the file) into the same folder where your `.swift` files are
   - Copy `lib` (the folder) into the same folder where your `.swift` files are
   - They should be at the same level as files like `ImageMetadataApp.swift`, `ContentView.swift`, etc.

3. **In Xcode:**
   - Click on your project folder in the left sidebar (the blue icon at the top)
   - You should see your project files listed
   - In Finder, drag `exiftool` and `lib` into the Xcode file list
   - A dialog will appear:
     - ✅ Check "Copy items if needed"
     - ✅ Check your app target (ImageMetadataApp)
     - ✅ Select "Create groups" (NOT "Create folder references")
     - Click "Finish"

4. **Verify they were added:**
   - In Xcode's left sidebar, you should now see:
     - `exiftool` (file)
     - `lib` (folder, expandable)
   - Both should appear in your file list

## Step 3: Add to Copy Bundle Resources

1. **Select your app target:**
   - Click on your project (blue icon) in the left sidebar
   - In the main area, click on your app target under "TARGETS" (should be "ImageMetadataApp")

2. **Open Build Phases:**
   - Click the "Build Phases" tab at the top

3. **Find "Copy Bundle Resources":**
   - Scroll down to find the "Copy Bundle Resources" section
   - Expand it by clicking the triangle

4. **Add the files:**
   - Click the "+" button at the bottom of the "Copy Bundle Resources" section
   - A file picker will appear
   - Select both `exiftool` and `lib` (hold Cmd to select multiple)
   - Click "Add"

5. **Verify:**
   - You should see both `exiftool` and `lib` listed in "Copy Bundle Resources"
   - If they're not there, add them manually using the "+" button

## Step 4: Make Script Executable (Add Build Script)

1. **Still in Build Phases:**
   - Click the "+" button at the top (next to "Copy Bundle Resources")
   - Select "New Run Script Phase"

2. **Configure the script:**
   - A new "Run Script" section will appear
   - Drag it BELOW "Copy Bundle Resources" (important!)
   - Expand it
   - In the script box, paste this:
   ```bash
   if [ -f "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/exiftool" ]; then
       chmod +x "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/exiftool"
   fi
   ```
   - Make sure "Shell" is set to `/bin/sh`
   - You can leave "Show environment variables in build log" unchecked

3. **Order matters:**
   - The "Run Script" phase should come AFTER "Copy Bundle Resources"
   - Drag it to the right position if needed

## Step 5: Build the App

**Note:** The `.app` file doesn't exist until you build! It will be created during the build process.

1. **Clean build folder (optional but recommended):**
   - Menu: Product → Clean Build Folder (Shift+Cmd+K)
   - This clears old build files

2. **Build the app:**
   - Menu: Product → Build (Cmd+B)
   - Wait for the build to complete (check the bottom status bar)
   - You should see "Build Succeeded" if everything worked

3. **Find your built `.app` file:**
   - In Xcode, look at the left sidebar
   - Find "Products" folder (at the bottom, might be collapsed)
   - Expand "Products" - you should see `ImageMetadataApp.app`
   - **Right-click** on `ImageMetadataApp.app`
   - Select **"Show in Finder"** or **"Reveal in Finder"**
   - This will open Finder and show you where the `.app` file is

4. **Verify it worked:**
   - In Finder, you should see `ImageMetadataApp.app`
   - **Right-click** on `ImageMetadataApp.app` → **"Show Package Contents"**
   - Navigate to `Contents` → `Resources`
   - You should see:
     - `exiftool` (file)
     - `lib/` (folder)
   - If you see both, you're good!

**Where is the `.app` file located?**
- Usually: `~/Library/Developer/Xcode/DerivedData/YourProject-xxxxx/Build/Products/Debug/`
- Or use "Show in Finder" from Xcode to find it easily!

## Troubleshooting

**"Files not showing in Xcode":**
- Make sure you dragged them into the project, not just Finder
- Check they're in your project folder (same location as your .swift files)
- Try right-clicking your project folder → "Add Files to [Project]..."

**"Can't find exiftool or lib in app":**
- Make sure both are in "Copy Bundle Resources" build phase
- Check the build phase order (Copy Bundle Resources should run before Run Script)
- Clean build folder and rebuild

**"Permission denied" errors:**
- Make sure the Run Script phase is set up correctly
- Check that the script actually ran (look at build log)

**"Can't locate Image::ExifTool.pm":**
- Make sure `lib/` folder is bundled (check Contents/Resources/lib/)
- Verify the lib folder structure: `lib/Image/ExifTool.pm` should exist
- The lib folder must be in the same directory as exiftool script

## Visual Checklist

After following all steps, your Xcode project should look like:
```
YourProject (blue icon)
  ├── YourProject folder
  │   ├── ImageMetadataApp.swift
  │   ├── ContentView.swift
  │   ├── MetadataUpdateViewModel.swift
  │   ├── MetadataUpdateService.swift
  │   ├── exiftool  ← Should be here
  │   └── lib/      ← Should be here (expandable folder)
  └── Products
```

And in Build Phases → Copy Bundle Resources:
- exiftool
- lib/

That's it! Once bundled, the app will use the bundled ExifTool and won't require system installation or special permissions.

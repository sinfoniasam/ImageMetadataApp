# Building the Final App for Distribution

## Step 1: Build Release Version

1. **Open Xcode**
2. **Select the scheme:** Make sure "ImageMetadataApp" is selected (next to the play/stop buttons)
3. **Select Release configuration:**
   - Product → Scheme → Edit Scheme (or press ⌘<)
   - Go to "Run" → Build Configuration → Select **Release**
   - Click "Close"
4. **Clean Build Folder:**
   - Product → Clean Build Folder (⇧⌘K)
5. **Build:**
   - Product → Build (⌘B)
   - Wait for "Build Succeeded"

## Step 2: Find Your .app File

1. **In Xcode's left sidebar**, scroll to the bottom
2. **Find "Products" folder** (might be collapsed)
3. **Expand "Products"**
4. **Right-click on `ImageMetadataApp.app`**
5. **Select "Show in Finder"**
6. The `.app` file is now ready!

**Location:** Usually in:
```
~/Library/Developer/Xcode/DerivedData/ImageMetadataApp-[random]/Build/Products/Release/ImageMetadataApp.app
```

## Step 3: Test the App

1. **Double-click** the `.app` file in Finder
2. **First launch:** macOS may show a security warning
   - Right-click the app → **Open**
   - Or: System Settings → Privacy & Security → Allow the app
3. **Test functionality:**
   - Select a folder with images
   - Select a JSON file
   - Process some images to verify it works

## Step 4: Create Distribution Copy (Optional)

### Copy to Applications Folder

```bash
# Copy to Applications (replace with actual path from Finder)
cp -R "/path/to/ImageMetadataApp.app" ~/Applications/
```

### Or Create a DMG for Distribution

1. **Open Disk Utility** (Applications → Utilities)
2. **File → New Image → Blank Image**
3. **Settings:**
   - Name: `ImageMetadataApp`
   - Size: 200 MB (or larger if needed)
   - Format: Mac OS Extended (Journaled)
   - Encryption: None
   - Partitions: Single partition - Apple Partition Map
   - Image Format: read/write disk image
4. **Click Create**
5. **Drag `ImageMetadataApp.app` into the mounted DMG**
6. **Optional:** Create a shortcut to Applications folder
7. **Eject the DMG**
8. **In Disk Utility:** Images → Convert
9. **Select your DMG → Convert**
10. **Format:** compressed
11. **Save as:** `ImageMetadataApp.dmg`

## Step 5: Verify App Icon

Your app icon should appear:
- In Finder
- In the Dock when running
- In Launchpad (if copied to Applications)

If the icon doesn't appear:
1. Check that all icon sizes are in `Assets.xcassets/AppIcon.appiconset`
2. Clean build folder and rebuild
3. Check that `Contents.json` references all icon files

## Quick Command Line Build (Alternative)

If you prefer terminal:

```bash
cd "/Users/samjividen/Documents/Code/Image Metadata App"

# Build Release version
xcodebuild -project ImageMetadataApp/ImageMetadataApp.xcodeproj \
           -scheme ImageMetadataApp \
           -configuration Release \
           -derivedDataPath ./build

# The .app will be in:
# ./build/Build/Products/Release/ImageMetadataApp.app
```

## Troubleshooting

**App icon not showing:**
- Make sure all required icon sizes are present (512x512, 256x256, 128x128, etc.)
- Clean build folder and rebuild
- Check `Assets.xcassets/AppIcon.appiconset/Contents.json`

**App won't open:**
- Right-click → Open (first time)
- System Settings → Privacy & Security → Allow

**"App is damaged" error:**
```bash
xattr -cr /path/to/ImageMetadataApp.app
```

That's it! Your app is ready for distribution! 🎉


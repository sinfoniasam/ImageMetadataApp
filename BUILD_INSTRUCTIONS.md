# Building the Image Metadata App

## Creating an Executable macOS App

### Method 1: Build in Xcode (Recommended)

1. **Open your project in Xcode**

2. **Select the target scheme:**
   - At the top of Xcode, make sure your app target is selected (not a test target)

3. **Choose Build Configuration:**
   - Click on your project in the left sidebar
   - Select your app target
   - Go to the "Build Settings" tab
   - Set "Build Configuration" to "Release" (or use Product → Scheme → Edit Scheme → Run → Build Configuration → Release)

4. **Build the app:**
   - Go to Product → Build (⌘B) or Product → Archive
   - If using Archive: Product → Archive (⌘⇧B) - this creates a distributable version

5. **Find your .app file:**
   - After building, right-click on your app target in the left sidebar
   - Select "Show in Finder"
   - Navigate to: `Products` → `Release` → `ImageMetadataApp.app`
   - OR if you archived: Window → Organizer → Archives → Select your archive → Distribute App → Copy App → Choose location

### Method 2: Command Line Build

If you prefer using the terminal:

```bash
# Navigate to your project directory
cd "/Users/samjividen/Documents/Code/Image Metadata App"

# Build for release (if you have an .xcodeproj)
xcodebuild -project ImageMetadataApp.xcodeproj \
           -scheme ImageMetadataApp \
           -configuration Release \
           -derivedDataPath ./build

# The .app will be in: ./build/Build/Products/Release/ImageMetadataApp.app
```

### Creating a Standalone App Bundle

Once you have the `.app` file:

1. **Copy the .app file** to where you want it (e.g., Applications folder)
2. **Make it executable** (if needed):
   ```bash
   chmod +x /path/to/ImageMetadataApp.app/Contents/MacOS/ImageMetadataApp
   ```

3. **Test it:**
   - Double-click the `.app` file to launch
   - The first time you run it, macOS may show a security warning
   - Go to System Settings → Privacy & Security → Allow the app to run

### Creating a DMG for Distribution (Optional)

If you want to distribute the app:

1. **Create a DMG:**
   ```bash
   # Install create-dmg (optional tool)
   brew install create-dmg
   
   # Create DMG
   create-dmg \
     --volname "Image Metadata App" \
     --window-pos 200 120 \
     --window-size 600 400 \
     --icon-size 100 \
     --icon "ImageMetadataApp.app" 150 200 \
     --hide-extension "ImageMetadataApp.app" \
     --app-drop-link 450 200 \
     "ImageMetadataApp.dmg" \
     "ImageMetadataApp.app"
   ```

2. **Or manually:**
   - Open Disk Utility
   - Create a new disk image
   - Copy your .app into it
   - Eject and save

### Code Signing (For Distribution Outside App Store)

If you want to distribute the app (not required for personal use):

1. In Xcode: Signing & Capabilities → Add your Apple Developer account
2. Select "Sign to Run Locally" for personal use
3. Or configure proper signing for distribution

### Troubleshooting

**App won't open:**
- Right-click the .app → Open (first time only)
- Or: System Settings → Privacy & Security → Allow

**"App is damaged" error:**
- Remove quarantine attribute:
  ```bash
  xattr -cr /path/to/ImageMetadataApp.app
  ```

**Can't find ExifTool:**
- Make sure ExifTool is installed: `brew install exiftool`
- The app will check for it when you run it

### Quick Test Build

The fastest way to test:

1. In Xcode: Product → Build (⌘B)
2. Product → Run (⌘R) to test
3. When satisfied: Product → Archive for distribution version


# Fix Code Signing Error

## Problem
The error "Command CodeSign failed with a nonzero exit code" is caused by a mismatch between:
- Build settings: `ENABLE_APP_SANDBOX = YES`
- Entitlements: `com.apple.security.app-sandbox = false`

## Solution

I've automatically fixed this in the project file, but if you need to do it manually:

### Option 1: Disable App Sandbox (Recommended for this app)

1. **Open Xcode**
2. **Select your project** (blue icon) in left sidebar
3. **Select your target** "ImageMetadataApp"
4. **Go to "Signing & Capabilities" tab**
5. **Remove "App Sandbox"** if it's there (click the "-" button)
6. **Or if it's not there**, make sure:
   - Build Settings → "Enable App Sandbox" = NO

### Option 2: In Xcode Build Settings

1. **Open your project** in Xcode
2. **Select project** → **Target** → **Build Settings**
3. **Search for "sandbox"**
4. **Set "Enable App Sandbox" to NO** for both Debug and Release

### Option 3: For Development Only - Disable Code Signing

If you just want to build for personal use:

1. **Select your target** in Xcode
2. **Go to "Signing & Capabilities"**
3. **Uncheck "Automatically manage signing"**
4. **Set "Signing Certificate" to "Sign to Run Locally"**

### Verify

After making changes:
1. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
2. **Build**: Product → Build (⌘B)
3. The code signing error should be resolved

## Why This Happened

The app needs to:
- Modify files on Desktop (user-selected locations)
- Run ExifTool (executable script)
- Access files outside sandbox

For a personal utility app like this, disabling the sandbox is appropriate since it needs these capabilities.


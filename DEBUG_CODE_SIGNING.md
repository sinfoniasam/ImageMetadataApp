# Debug Code Signing Error

If you're still getting "Command CodeSign failed with a nonzero exit code", try these steps:

## Step 1: Check the Exact Error

1. In Xcode, open the **Report Navigator** (⌘9 or View → Navigators → Show Report Navigator)
2. Click on the failed build
3. Expand the **CodeSign** step to see the exact error message
4. The error might tell us what's actually failing

## Step 2: Verify Settings in Xcode UI

Sometimes the project file changes don't sync with Xcode's UI. Verify manually:

1. **Select your project** (blue icon) in left sidebar
2. **Select your target** "ImageMetadataApp"
3. **Go to "Signing & Capabilities" tab**
4. **Uncheck "Automatically manage signing"** if it's checked
5. Make sure there's no development team selected
6. **Go to "Build Settings" tab**
7. **Search for "code sign"**
8. Verify:
   - Code Signing Style: **Manual**
   - Code Signing Identity: **- (no signing)**
   - Enable App Sandbox: **No**

## Step 3: Complete Reset (If Above Doesn't Work)

1. **Close Xcode completely**
2. **Delete Derived Data:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/ImageMetadataApp-*
   ```
3. **Reopen Xcode**
4. **Clean Build Folder:** Product → Clean Build Folder (⇧⌘K)
5. **Build again**

## Step 4: Alternative - Disable Code Signing in Build Phases

If Xcode is still trying to sign:

1. **Select target** → **Build Phases**
2. Look for a **"Code Sign"** or **"Embed Frameworks"** phase
3. If you see one, you might be able to remove it, OR
4. Try adding this to **Build Settings** → **User-Defined Settings**:
   - Key: `CODE_SIGN_IDENTITY`
   - Value: `-`
   - Key: `CODE_SIGNING_ALLOWED`
   - Value: `NO`

## Step 5: Share the Exact Error

If none of the above works, please share:
- The exact error message from the Report Navigator
- What build configuration you're using (Debug/Release)
- The full error output from the build log

This will help identify what's specifically failing in the code signing process.


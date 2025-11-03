# Upload to GitHub - Quick Guide

## ✅ Already Done

I've initialized git and created the initial commit. Now you just need to push to GitHub!

## Next Steps

### Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. **Repository name:** `ImageMetadataApp` (or your preferred name)
3. **Description:** "macOS app to update image metadata from JSON files"
4. **Visibility:** Choose Public or Private
5. **DO NOT** check "Add a README file" (we already have one)
6. **DO NOT** check "Add .gitignore" (we already have one)
7. Click **"Create repository"**

### Step 2: Connect and Push

After creating the repo, GitHub will show you commands. Use these (replace `YOUR_USERNAME`):

```bash
cd "/Users/samjividen/Documents/Code/Image Metadata App"

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/ImageMetadataApp.git

# Set main branch
git branch -M main

# Push to GitHub
git push -u origin main
```

### Alternative: If You Want a Different Repo Name

If your GitHub repo has a different name:

```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

## What's Included

✅ **All source files** (Swift, Assets, etc.)
✅ **ExifTool** (bundled script and lib/)
✅ **Documentation** (.md files)
✅ **Scripts**
✅ **Xcode project** (cleaned up)

❌ **Not included** (excluded by .gitignore):
- Build artifacts (`.app` files)
- DerivedData/
- User-specific Xcode settings
- `.DS_Store` files

## After Uploading

1. **View your repo** at `https://github.com/YOUR_USERNAME/ImageMetadataApp`
2. **Read README.md** - it should appear on the main page
3. **Add screenshots** (optional) - drag and drop into README.md
4. **Create releases** when ready - upload the `.app` file as a release asset

## Troubleshooting

**"Repository not found" error:**
- Make sure you created the repo on GitHub first
- Check the repository name matches
- Verify your GitHub username is correct

**"Permission denied" error:**
- You may need to authenticate
- Use GitHub CLI: `gh auth login`
- Or use SSH: `git remote set-url origin git@github.com:USERNAME/REPO.git`

That's it! 🚀

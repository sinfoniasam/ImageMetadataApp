# GitHub Authentication Fix

GitHub no longer accepts passwords for Git operations. You need to use one of these methods:

## Option 1: Personal Access Token (PAT) - Easiest

### Step 1: Create a Personal Access Token

1. Go to https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Give it a name: `ImageMetadataApp Git Access`
4. Select scopes:
   - ✅ **`repo`** (Full control of private repositories)
   - If you want public repos only, use **`public_repo`**
5. Click **"Generate token"**
6. **COPY THE TOKEN IMMEDIATELY** - you won't see it again!

### Step 2: Use Token When Pushing

When you run `git push`, it will prompt for credentials:
- **Username:** `sinfoniasam`
- **Password:** Paste your Personal Access Token (NOT your GitHub password)

Or use it in the URL directly:

```bash
git remote set-url origin https://sinfoniasam:YOUR_TOKEN@github.com/sinfoniasam/ImageMetadataApp.git
git push -u origin main
```

## Option 2: SSH Authentication - Recommended for Long Term

### Step 1: Check if You Have SSH Keys

```bash
ls -la ~/.ssh/id_*.pub
```

### Step 2: Generate SSH Key (if needed)

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# Press Enter to accept default location
# Optionally set a passphrase
```

### Step 3: Add SSH Key to GitHub

```bash
# Copy your public key
cat ~/.ssh/id_ed25519.pub | pbcopy
```

Then:
1. Go to https://github.com/settings/keys
2. Click **"New SSH key"**
3. Paste your key
4. Click **"Add SSH key"**

### Step 4: Switch to SSH Remote

```bash
cd "/Users/samjividen/Documents/Code/Image Metadata App"
git remote set-url origin git@github.com:sinfoniasam/ImageMetadataApp.git
git push -u origin main
```

## Option 3: GitHub CLI (gh) - Most Convenient

If you have GitHub CLI installed:

```bash
gh auth login
# Follow the prompts to authenticate
git push -u origin main
```

## Quick Fix Right Now

If you just want to push immediately, use a Personal Access Token:

1. Create token: https://github.com/settings/tokens/new (select `repo` scope)
2. Copy the token
3. Run:

```bash
cd "/Users/samjividen/Documents/Code/Image Metadata App"
git remote set-url origin https://sinfoniasam:YOUR_TOKEN_HERE@github.com/sinfoniasam/ImageMetadataApp.git
git push -u origin main
```

**Security Note:** After pushing, you can remove the token from the URL:
```bash
git remote set-url origin https://github.com/sinfoniasam/ImageMetadataApp.git
```

Then use the token when prompted, or better yet, switch to SSH.




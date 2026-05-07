# 🚀 How to Build the APK Online (GitHub Actions)

No Flutter installation needed. GitHub builds it for you **free**.  
Total time: ~5 minutes.

---

## Step 1 — Create a GitHub Repository

1. Go to **https://github.com/new**
2. Repository name: `shift-filter`
3. Set to **Private** (recommended) or Public
4. **Do NOT** check "Add README"
5. Click **Create repository**

---

## Step 2 — Upload the Project Files

### Option A: GitHub Web Upload (easiest, no git needed)

1. On your new empty repo page, click **"uploading an existing file"**
2. **Drag and drop ALL files** from the extracted ZIP into the browser window
3. Make sure to include the hidden `.github/` folder:
   - On Windows: Show hidden files in Explorer first
   - On Mac: Press `Cmd+Shift+.` in Finder
4. At the bottom, click **Commit changes**

### Option B: Git Command Line

```bash
# Extract the ZIP first, then:
cd shift_filter

git init
git add .
git commit -m "Initial commit: Shift Filter app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/shift-filter.git
git push -u origin main
```

---

## Step 3 — Watch the Build

1. Go to your repo on GitHub
2. Click the **"Actions"** tab
3. You'll see **"Build Shift Filter APK"** running (yellow spinner)
4. Click it to watch live logs (~4-5 minutes)

---

## Step 4 — Download Your APK

### From Actions (every build):
1. Click the completed workflow run (green checkmark ✅)
2. Scroll down to **"Artifacts"** section
3. Click **ShiftFilter-APK-1** to download the ZIP
4. Extract it — your `.apk` file is inside

### From Releases (auto-created on main branch):
1. Click **"Releases"** on the right sidebar of your repo
2. Click the latest release
3. Download `ShiftFilter-v1.0.1.apk` directly

---

## Step 5 — Install on Android

1. Transfer the APK to your Android device (USB, WhatsApp, email, Google Drive)
2. On your phone: **Settings → Security → Install unknown apps → Allow**
3. Open the APK file → **Install**
4. Done! 🎉

---

## 🔄 Future Updates

Every time you push any change to GitHub, a new APK is automatically built.  
Just re-download from the Releases page.

---

## ❓ Troubleshooting

| Problem | Fix |
|---------|-----|
| Build fails | Click the failed run → see which step failed → open an issue |
| `.github` folder not uploaded | Enable "Show hidden files" on your OS |
| "Install blocked" on Android | Enable "Unknown sources" in Settings |
| Actions tab not visible | Go to Settings → Actions → Allow all actions |

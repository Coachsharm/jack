# Google Drive Backup Option (Future Enhancement)

## Overview
While local backups are secure, you may want to sync them to Google Drive for cross-device access.

## Why Google Drive?
- **Private by default**: Files are encrypted in transit and at rest
- **Access anywhere**: Download backups on Mac, other PCs
- **Version history**: Google Drive keeps old versions automatically
- **Large storage**: 15GB free (or unlimited with Workspace)

## Setup Options

### Option A: Manual Upload (Easiest - 2 minutes)
1. Open Google Drive in your browser
2. Create a folder called "Jack-Backups" (make it private)
3. Drag and drop the `backups/` folder whenever you create a new backup
4. **Pros**: Simple, no setup
5. **Cons**: Manual process each time

### Option B: Google Drive Desktop App (Recommended - 5 minutes)
1. Download: https://www.google.com/drive/download/
2. Install and sign in with your Google account
3. Choose "Mirror files" mode
4. Add `C:\Users\hisha\Code\Jack\backups` to sync folders
5. **Pros**: Automatic sync, works like Dropbox
6. **Cons**: Requires desktop app installation

### Option C: Automated Script with rclone (Advanced - 15 minutes)
**Requires**: Installing `rclone` (a command-line tool for cloud storage)

1. **Install rclone**:
   ```powershell
   # Using Chocolatey (if you have it)
   choco install rclone
   
   # OR download from: https://rclone.org/downloads/
   ```

2. **Configure Google Drive**:
   ```powershell
   rclone config
   # Follow prompts to add "gdrive" remote
   ```

3. **Add to backup script**:
   We can modify `backup.ps1` to automatically upload after creating a backup:
   ```powershell
   rclone copy "C:\Users\hisha\Code\Jack\backups" gdrive:Jack-Backups
   ```

4. **Pros**: Fully automated, runs after every backup
5. **Cons**: Requires technical setup

## Current Status
✅ **Option 1 (Local Only)** is now active - backups are excluded from GitHub for security.

If you want to enable Google Drive sync, I recommend **Option B** (Desktop App) as the best balance of ease and automation.

Let me know if you'd like help setting up any of these options!

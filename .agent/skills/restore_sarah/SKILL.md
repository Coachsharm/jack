---
name: Restore Sarah
description: Completely restore Sarah's agent from local brain files, including configuration, brain files, and session clearing. Use this if Sarah becomes unresponsive or needs a full reset.
---

# 🧘‍♀️ Restore Sarah Skill

**Trigger:** `/restore-sarah` or when Sarah is broken/unresponsive.

## Purpose
This skill provides a **one-shot recovery** for Sarah. It effectively "reincarnates" her by:
1. Ensuring her workspace directory exists
2. Uploading all her latest brain files
3. Clearing her sessions (memory wipe of current conversations)
4. Restarting the gateway

## Requirements
- Sarah's local brain files must exist at: `c:\Users\hisha\Code\Jack\sarah\workspace\`
- SSH access to `jack` (root@185.187.170.55) must be working
- `openclaw` CLI must be installed on the server

---

## The Procedure

### Step 1: Verify Local Files
Check that you have the source of truth files locally:
```powershell
ls "c:\Users\hisha\Code\Jack\sarah\workspace\"
# Expect: SOUL.md, USER.md, IDENTITY.md, HEARTBEAT.md, etc.
```

### Step 2: Create/Verify Remote Workspace
Ensure the directory exists on the server:
```bash
ssh jack "mkdir -p /root/.openclaw/workspace-sarah"
```

### Step 3: Upload Brain Files
Run this **exact** block to upload everything:

```powershell
$RemotePath = "/root/.openclaw/workspace-sarah/"
$LocalPath = "c:\Users\hisha\Code\Jack\sarah\workspace\"

# Core Brain Files
scp "$LocalPath\SOUL.md" "jack:$RemotePath"
scp "$LocalPath\USER.md" "jack:$RemotePath"
scp "$LocalPath\IDENTITY.md" "jack:$RemotePath"
scp "$LocalPath\HEARTBEAT.md" "jack:$RemotePath"

# Guide Files
scp "$LocalPath\HUMAN_TEXTING_GUIDE.md" "jack:$RemotePath"
scp "$LocalPath\STYLE_GUIDE.md" "jack:$RemotePath"
scp "$LocalPath\telegram-formatting-preferences.md" "jack:$RemotePath"

echo "✅ Sarah's brain files uploaded."
```

### Step 4: Clear Sessions (Crucial!)
This forces Sarah to reload her brain files on the next message.
```bash
ssh jack "rm -f /root/.openclaw/agents/sarah/sessions/sessions.json"
echo "✅ Sarah's sessions cleared."
```

### Step 5: Restart Gateway
Apply all changes.
```bash
ssh jack "openclaw gateway restart"
echo "✅ Gateway restarted."
```

### Step 6: Verification
Ping Sarah on Telegram (`@thrive5bot`) with:
> "Status check. Which workspace are you using?"

**Expected Answer:**
> "I'm using `/root/.openclaw/workspace-sarah/`"

---

## Troubleshooting

### "Permission denied"
- Check that your SSH key is loaded (`ssh-add -l`)
- Ensure you have root access to `185.187.170.55`

### Sarah still quiet?
- Check `openclaw.json` for **bindings**:
```json
"bindings": [
  {
    "agentId": "sarah",
    "match": {
      "channel": "telegram",
      "accountId": "sarah"
    }
  }
]
```
- If missing, you must add this to `openclaw.json` and upload it.

### "No such file or directory"
- You might be missing a local file in `c:\Users\hisha\Code\Jack\sarah\workspace\`.
- Check the folder and recreate missing files from the `lessons/sarah-complete-journey-2026-02-14.md` documentation.

# Tomorrow Morning - Phase 3 gogcli OAuth Completion

## What's Done Today ✅

- Jack is now **OpenClaw-aware** (Phase 2 complete)
- Updated workspace files deployed: AGENTS.md, SOUL.md, TOOLS.md
- gogcli v0.9.0 installed on server at `/usr/local/bin/gog`
- OAuth credentials configured (client ID + secret)

## What's Pending ⏸️

**gogcli OAuth Authorization** - Need browser access to complete authorization flow

## Complete OAuth Tomorrow (5 minutes)

### Option A: SSH Port Forwarding (Clean)

1. **Open PowerShell and create SSH tunnel:**
   ```powershell
   plink -ssh -pw "Corecore8888-" -L 8080:127.0.0.1:34009 root@72.62.252.124
   ```

2. **In another terminal, start OAuth in container:**
   ```powershell
   plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker exec openclaw-dntm-openclaw-1 gog auth login"
   ```

3. **Open browser and visit:**
   ```
   http://localhost:8080
   ```

4. **Sign in with:** hisham.musa@gmail.com

5. **Grant permissions** for Gmail and Calendar

6. **Test it works:**
   ```powershell
   plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker exec openclaw-dntm-openclaw-1 gog gmail search --query 'is:unread' --max 5"
   ```

### Option B: Device Code Flow (Simpler)

Check if gogcli supports device code:
```powershell
plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker exec openclaw-dntm-openclaw-1 gog auth login --help"
```

Look for `--no-browser` or `--device-code` flags

## Test After Authorization

Once authorized, verify Jack can use it:

1. **Restart Jack's session** (new Telegram chat or restart container)

2. **Ask Jack:** "Check my Gmail"

3. **Expected:** Jack runs `gog gmail search` and reports emails (not "I need gogcli")

## Files to Reference

- OAuth credentials: `C:\Users\hisha\Code\Jack\gogcli_credentials.json`
- Deployment guide: `C:\Users\hisha\.gemini\antigravity\brain\9272c18b-9f34-49b9-ba13-54831ec7ec97\oauth_credentials_guide.md`

## If Issues

Skip Phase 3 entirely. Jack already knows to explain gogcli setup properly. Main goals (OpenClaw awareness, skills, response tone) are complete ✅

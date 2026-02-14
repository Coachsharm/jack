# Jack Installation & Configuration — Session Summary (Feb 14, 2026)

## What We Accomplished

### ✅ Completed
1. **Full server backup** — `openclaw-full-backup-14feb26-0213am-pre-workspace-upload.tar.gz` (602KB)
2. **Emergency rollback guide** — `lessons/emergency-rollback-jack.md`
3. **Restoration guide** — `lessons/restore-jack-from-backup.md`
4. **Updated installation lesson** — `lessons/installjackfeb.md` with browser, WhatsApp, testing methodology
5. **Updated skill** — `.agent/skills/installjackfeb/SKILL.md` with all new procedures
6. **Browser config added** — Chrome headless enabled, Jack tested responsive ✅
7. **Telegram groups enabled** — `groupPolicy: open`, Jack tested responsive ✅
8. **Testing methodology established** — Test after each change, rollback if broken

### 📋 Current Jack State (Verified Working)
- ✅ **Responsive on Telegram** (@thrive2bot)
- ✅ **Primary model:** `google-antigravity/claude-opus-4-6`
- ✅ **Fallback:** `google-antigravity/gemini-3-pro-high`
- ✅ **11 model aliases** configured (a1-a5, Aopus, sonnet, gpt4o-mini, sonnet-or, gemini-low, gpt-oss)
- ✅ **Browser enabled:** Chrome headless for web browsing
- ✅ **Telegram groups:** Open policy
- ✅ **ElevenLabs TTS:** Configured
- ✅ **Brave Search:** API key set
- ✅ **OpenRouter:** Configured via env var
- ✅ **Auth profiles:** Google Antigravity (OAuth), Anthropic (token), OpenAI Codex (OAuth), OpenRouter (API key)

### ⏭️ Ready to Add (Not Yet Installed)
1. **WhatsApp channel** — Full setup guide written, requires QR scan
2. **Full workspace upload** — 109 files + 31 directories from jack4 backup
3. **Sarah agent** — Exists but needs correct brain files uploaded

---

## WhatsApp Setup Plan (When Ready)

### Prerequisites
- Jack is responsive (verified ✅)
- Backup created (verified ✅)
- Terminal access for QR scan

### Steps
```bash
# 1. Enable plugin
openclaw plugins enable whatsapp

# 2. Configure access
openclaw config set channels.whatsapp.dmPolicy allowlist
openclaw config set channels.whatsapp.selfChatMode true
openclaw config set channels.whatsapp.groupPolicy allowlist
openclaw config set channels.whatsapp.mediaMaxMb 50

# 3. Set allowlists (use --json!)
openclaw config set --json channels.whatsapp.allowFrom '["+6588626460","+6591090995"]'
openclaw config set --json channels.whatsapp.groupAllowFrom '["*"]'
openclaw config set --json channels.whatsapp.groups '["*"]'

# 4. Link WhatsApp (QR scan)
openclaw channels login --channel whatsapp
# Scan QR code with WhatsApp mobile app

# 5. Restart & approve
openclaw gateway restart
openclaw pairing list whatsapp
openclaw pairing approve whatsapp <CODE>

# 6. Test
# Send WhatsApp message, verify Jack responds
```

### Key Points
- **Use `--json` flag** for array values
- **Phone numbers must be strings** with quotes: `"+6588626460"`
- **QR scan is interactive** — requires terminal access
- **Test after each phase** to ensure Jack stays responsive
- **Rollback ready** if anything breaks

---

## Emergency Rollback (If Needed)

```bash
# Quick 5-minute recovery
openclaw gateway stop
mv /root/.openclaw /root/.openclaw-BROKEN-$(date +%Y%m%d-%H%M%S)
tar -xzf /root/backups/openclaw-full-backup-14feb26-0213am-pre-workspace-upload.tar.gz
chmod -R 700 /root/.openclaw
chmod 600 /root/.openclaw/agents/*/agent/auth-profiles.json
openclaw gateway restart
openclaw status
# Test on Telegram
```

---

## Key Lessons Learned

### 1. Always Test After Changes
- Send test message to @thrive2bot after every config change
- Wait 10 seconds for response
- If no response, check logs and rollback immediately

### 2. Use OpenClaw CLI Only
- **NEVER** edit `openclaw.json` or `auth-profiles.json` directly
- Use `openclaw config set`, `openclaw models auth`, `openclaw onboard`
- Use `--json` flag for array values (phone numbers, groups)

### 3. Backup Before Risky Changes
- Create backup before WhatsApp, workspace upload, or major config changes
- Name backups descriptively: `before-whatsapp`, `before-workspace-upload`
- Keep local copies in `c:\Users\hisha\Code\Jack\backups\`

### 4. Phone Numbers Must Be Strings
- ❌ Wrong: `openclaw config set 'channels.whatsapp.allowFrom[0]' +6588626460`
- ✅ Right: `openclaw config set --json channels.whatsapp.allowFrom '["+6588626460"]'`

### 5. Browser Config is Safe
- Adding browser config did not break Jack
- Tested responsive after change ✅

### 6. Telegram Groups is Safe
- Setting `groupPolicy: open` did not break Jack
- Tested responsive after change ✅

---

## Files Created/Updated This Session

### New Files
- `lessons/emergency-rollback-jack.md` — Quick 5-minute rollback guide
- `lessons/restore-jack-from-backup.md` — Full restoration guide
- `backups/openclaw-full-backup-14feb26-0213am-pre-workspace-upload.tar.gz` — Current good state (602KB)

### Updated Files
- `lessons/installjackfeb.md` — Added Phase 7.5 (Browser), Phase 8 (WhatsApp), Testing Methodology, Emergency Rollback
- `.agent/skills/installjackfeb/SKILL.md` — Added Steps 7.5-7.6, Emergency Rollback, updated Safety Rules

---

## Next Steps (When Ready)

1. **WhatsApp Setup** — Follow plan above, requires QR scan
2. **Full Workspace Upload** — Upload 109 files from jack4 backup
3. **Sarah Agent** — Upload correct brain files from sarah backup
4. **Test Everything** — Verify all channels working

---

*Session completed: Feb 14, 2026 02:14 AM*
*Jack status: Responsive and working ✅*
*Backup: Available and tested ✅*

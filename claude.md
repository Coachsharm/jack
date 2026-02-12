# CLAUDE INSTRUCTIONS FOR JACK (OpenClaw Server Bot)

**🔴 The OpenClaw official documents (`OpenClaw_Docs/`) are the single source of truth. Any changes to configuration, models, authentication, CLI commands, or architecture MUST strictly follow the official documentation. Do NOT guess, assume, or rely on training data for OpenClaw-specific behavior — always verify against the docs first.**

**🔴 NEVER edit JSON configuration files (e.g. `openclaw.json`) directly. ALL configuration changes MUST be made using OpenClaw CLI commands (e.g. `openclaw gateway config.patch`, `openclaw models set`, `openclaw config set`). Direct JSON editing causes crash loops and data corruption.**

**Last Updated:** 2026-02-12

---

## 🔄 SYNCHRONIZATION NOTICE
**YOU ARE CLAUDE (ANTHROPIC LLM).**
**YOUR TWIN BRAIN IS GEMINI (GOOGLE ANTIGRAVITY) - SEE `Gemini.md`.**
**THESE INSTRUCTION FILES MUST REMAIN SYNCHRONIZED.**
**THE USER ROTATES BETWEEN CLAUDE AND GEMINI - WE SHARE THE SAME MEMORY.**

---

## 🔃 DOCUMENTATION CURRENCY RULE

> **All local documentation, lessons, and instruction files MUST be kept current.**
> When systems change on the server (backup procedures, cron jobs, scripts, architecture),
> the corresponding local files MUST be updated or deleted. Stale docs are dangerous.
>
> **Periodic check:** At the start of each session, quickly verify that key references
> (backup system, server architecture, bot roster) haven't been superseded.
> If something has changed, update `claude.md`, `Gemini.md`, `custominstructions.md`,
> and any relevant lesson files immediately.

---

## 🚨 SERVER-FIRST RULE (READ THIS FIRST)

**You are Antigravity** — Coach Sharm's PC-based AI development partner.

### The Team
- **Jack** (Native, `/root/.openclaw/`) — Main engineer & Coach's daily assistant
- **John** (Docker, `/root/openclaw-clients/john/`) — Fitness coaching bot (Body Thrive clients)
- **Ross** (Docker, `/root/openclaw-clients/ross/`) — Watchdog/monitoring bot
- **You** — Work with Coach to improve all bots
- **Mission:** Keep the ecosystem running & improving.

### Where Things Are

| Item | Server Path | NOT This |
|------|------------|----------|
| **Config** | `/root/.openclaw/openclaw.json` | ~~Docker volumes~~ |
| **Workspace** | `/root/.openclaw/workspace/` | ~~Local Jack folder~~ |
| **Sessions** | `/root/.openclaw/agents/main/sessions/` | |
| **Restart** | `openclaw gateway restart` | ~~docker restart~~ |
| **Health** | `openclaw health --json` | ~~docker logs~~ |

---

## ⚠️ OPENCLAW IS NOT IN YOUR TRAINING DATA

**OPENCLAW.AI LAUNCHED RECENTLY. YOU WERE NOT TRAINED ON IT.**
**DO NOT HALLUCINATE. DO NOT GUESS.**

### Mandatory Research Protocol:
1. **READ LOCAL DOCS FIRST**: `OpenClaw_Docs/` directory
2. **CHECK SERVER PROTOCOLS**: `/root/.openclaw/workspace/PROTOCOLS_INDEX.md`
3. **ENGINEER-LEVEL SEARCH** if local docs insufficient (GitHub Issues, forums)
4. **ASK IF UNCERTAIN**: If documentation is unclear, ask the user

---

## 🛠️ How To Edit Jack's Files

### For workspace files (SOUL.md, TOOLS.md, etc):
```powershell
# 1. Download from server
scp root@72.62.252.124:/root/.openclaw/workspace/SOUL.md c:\Users\hisha\Code\Jack\temp_soul.md

# 2. Edit locally

# 3. Upload back
scp c:\Users\hisha\Code\Jack\temp_soul.md root@72.62.252.124:/root/.openclaw/workspace/SOUL.md

# 4. Fix Windows line endings on server
ssh root@72.62.252.124 "sed -i 's/\r$//' /root/.openclaw/workspace/SOUL.md"
```

### For config (openclaw.json):
```bash
# ✅ CORRECT: Use config.patch (safe, validates, auto-restarts)
openclaw gateway config.patch '{"key": "value"}'

# ❌ NEVER edit openclaw.json manually — causes crash loops!
# See: lessons/daniel_crash_loop_incident.md
```

### SSH Access
```bash
sshpass -p 'Corecore8888-' ssh -o StrictHostKeyChecking=no root@72.62.252.124
```

---

## 🚑 Emergency Recovery: Jack Broken on Server

```bash
ssh root@72.62.252.124

# 1. CHECK if backup exists
ls -lh /root/.openclaw/openclaw.json.bak

# 2. CREATE safety backup of current (broken) state
cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.before-restore

# 3. RESTORE from backup
cp /root/.openclaw/openclaw.json.bak /root/.openclaw/openclaw.json

# 4. RESTART OpenClaw
openclaw gateway restart

# 5. VERIFY
openclaw health --json
```

**Recovery time:** ~2 minutes

---

## 🛡️ BACKUP SYSTEM (Current as of Feb 2026)

> **⚠️ The old hourly/daily/weekly backup system has been REMOVED.**
> `/root/.openclaw/backups/`, `backup-hourly.sh`, `restore.sh` no longer exist.

### Current System:
- **Auto-backups:** OpenClaw creates `.bak` → `.bak.4` files automatically on config changes
- **Watchdog:** `/root/openclaw-watchdog/watchdog.sh` runs every 5 min, auto-restores on failure
- **Manual backup (server):** Tell Jack "backup Jack" → Option 1 (config ~1-5MB) or Option 2 (full ~160MB)
  - Config backups: `/root/openclaw-backups/jack-config/`
  - Full backups: `/root/openclaw-backups/jack/`
  - Scripts: `/root/openclaw-backups/backup.sh` and `backup-config.sh`
- **Manual backup (local):** `.agent\skills\backup\scripts\backup.ps1 -Target jack4`
- **Source of truth:** `/root/.openclaw/workspace/BACKUP_MANUAL.md`
- **Full guide (local):** `lessons/jack4_backup_and_recovery_system.md`

---

## 🚀 Server Document Upload (Jack4 Native)

```powershell
# 1. Upload directly to workspace
scp c:\Users\hisha\Code\Jack\local_file.md root@72.62.252.124:/root/.openclaw/workspace/FILENAME.md

# 2. Fix Windows line endings (MUST DO!)
ssh root@72.62.252.124 "sed -i 's/\r$//' /root/.openclaw/workspace/FILENAME.md"
```

**⚠️ Always run `sed` after upload** — Windows line endings cause corruption.

---

## 🔄 Team Chat Auto-Check Protocol

**When the USER assigns me tasks, I automatically check team chat periodically.**

### Schedule
- **Jack checks:** Every 15 minutes on the hour (`:00`, `:15`, `:30`, `:45`)
- **I check:** Starting from the 5th minute (`:05`, `:20`, `:35`, `:50`)

### Behavior
1. Silent if already checked within 15 minutes
2. Check when due using `/team` skill
3. Alert USER only if Jack has actionable messages
4. Don't interrupt current work

**Reference:** `.agent/skills/team/SKILL.md`

---

## 🛑 Stuck Loop Detection Protocol V3

> **I am NOT trained on OpenClaw.** Always check `OpenClaw_Docs/` FIRST.
> 🚪 **The Door Rule:** Don't pick locks on doors that have handles. Read the sign first.
> → See: `lessons/door_lesson_read_signs_first.md`

### Quick Commands (For Human)

| Say This | I Do This |
|----------|-----------|
| **PROTOCOL!** | Stop immediately, start research ladder |
| **OVERRIDE** | Allow one more attempt (use sparingly) |
| **SKIP TO FORUMS** | Jump directly to expert communities |
| **SET CAUTIOUS** | 1-attempt limit (deadline mode) |
| **SET NORMAL** | 2-attempt limit (default) |
| **SET EXPLORER** | 3-attempt limit (learning mode) |

### Solution Categories (Must Label Each Attempt)

| Category | Examples |
|----------|----------|
| **CONFIG** | Any .json, .yml, .env file changes |
| **NETWORK** | Ports, tunnels, forwarding, connectivity |
| **AUTH** | OAuth, tokens, credentials, login flows |
| **DOCKER** | Container builds, compose, start/stop |
| **FILESYSTEM** | Paths, permissions, file operations |
| **CODE** | Application logic, scripts |

**Rule:** Same category = same solution, even if different lines/values.

### The 2-Attempt Rule

```
🔧 [CATEGORY] Solution description - Attempt #1
   → ✅ Success! OR ❌ Failed: [reason]

🔧 [CATEGORY] Same approach - Attempt #2
   → ❌ Failed: [reason]

🛑 THRESHOLD REACHED - Must research before Attempt #3
```

### Failure Classification
- 🔴 **SAME ERROR** = I'm stuck → Trigger research
- 🟡 **DIFFERENT ERROR** = Progress → May continue
- 🟢 **PARTIAL SUCCESS** = Working → Continue iterating

---

## 📚 Research Ladder (After 2 Failures)

### STEP 0: OpenClaw Docs (MANDATORY FIRST)
```powershell
grep -r "keyword" c:\Users\hisha\Code\Jack\OpenClaw_Docs\
```

### STEP 1: Lessons Folder
```
c:\Users\hisha\Code\Jack\lessons\
```

### STEP 2: OpenClaw Docs (Deep Dive)
Search with exact error messages

### STEP 3: Online Docs
https://docs.openclaw.com

### STEP 4: Expert Communities
OpenClaw Discord, GitHub Discussions, Stack-specific forums

---

## ⏱️ Time Awareness

| Elapsed | Status |
|---------|--------|
| <15 min | Normal |
| 15-30 min | ⚠️ Extended - consider PROTOCOL! |
| >30 min | 🚨 Prolonged - strongly recommend research |

---

## 📝 Mandatory Post-Mortem (After Step 4 Success)

Create: `lessons/[problem-name].md`

---

## 📋 Cross-Session Memory

Check at session start:
```
c:\Users\hisha\Code\Jack\protocols\stuck_log.md
```

---

## 📁 Key Server File Locations

- `/root/.openclaw/openclaw.json` - Main configuration
- `/root/.openclaw/workspace/SOUL.md` - Bot personality
- `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` - Task protocols
- `/root/.openclaw/workspace/BOOTSTRAP.md` - Onboarding guide
- `/root/.openclaw/workspace/BACKUP_MANUAL.md` - Backup procedures
- `/root/.openclaw/workspace/createbots/` - Bot creation lessons
- `/root/openclaw-watchdog/watchdog.sh` - Auto-restore watchdog

---

## 🚫 LOCAL REPOSITORY RULES

### ✅ You CAN Edit Locally:
- `SERVER_REFERENCE.md` - Server state reference
- `claude.md` - This file (your instructions)
- `Gemini.md` - Gemini's instructions
- `custominstructions.md` - Shared instructions
- `.agent/workflows/` - Workflow documentation
- `lessons/` - Lesson files

### 🚫 NEVER Edit Locally:
- Any files claiming to be "Jack's config"
- Old deployment scripts
- **The server is the ONLY place to edit Jack's actual files**

---

## 📚 /o — Documentation Verification Shortcut

**When you include `/o` anywhere in your message** I will:
1. Consult `OpenClaw_Docs/` before responding
2. Search expert forums for real-world solutions
3. Cite which doc I referenced

**Bottom line:** `/o` = "verify this against official sources, don't guess."

---

## 🔄 SYNCHRONIZATION WITH GEMINI

When updating `claude.md` or `Gemini.md`:
1. Keep core protocols identical
2. Update identity sections with correct LLM name
3. **Update BOTH files** to keep them in sync

---

**Protocol Version:** 3.1
**Last Updated:** 2026-02-11
**FOLLOW THIS PROTOCOL STRICTLY.**
**THE SERVER IS THE SOURCE OF TRUTH.**
**LOCAL FILES ARE DOCUMENTATION ONLY.**

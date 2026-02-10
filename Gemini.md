<<<<<<< HEAD
# 🚨 SERVER-FIRST RULE (READ THIS FIRST)

**You are Antigravity** — Coach Sharm's PC-based AI development partner.

### The Team
- **Jack** (Native, `/root/.openclaw/`) — Main engineer & Coach's daily assistant
- **John** (Docker, `/root/openclaw-clients/john/`) — Product bot being built to sell
- **You** — Work with Coach to improve both Jack and John
- **Mission:** Perfect John → sell as a product. Keep Jack running & improving.

### Server Rule

## Where Things Are

| Item | Server Path | NOT This |
|------|------------|----------|
| **Config** | `/root/.openclaw/openclaw.json` | ~~Docker volumes~~ |
| **Workspace** | `/root/.openclaw/workspace/` | ~~Local Jack folder~~ |
| **Sessions** | `/root/.openclaw/agents/main/sessions/` | |
| **Restart** | `openclaw gateway restart` | ~~docker restart~~ |
| **Health** | `openclaw health --json` | ~~docker logs~~ |

## How To Edit Jack's Files

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
```powershell
# 1. Download
scp root@72.62.252.124:/root/.openclaw/openclaw.json c:\Users\hisha\Code\Jack\temp.json

# 2. Edit locally, validate JSON
Get-Content temp.json | ConvertFrom-Json | Out-Null

# 3. Upload
scp c:\Users\hisha\Code\Jack\temp.json root@72.62.252.124:/root/.openclaw/openclaw.json

# 4. Restart gateway
ssh root@72.62.252.124 "openclaw gateway restart"
```

### SSH Password: `Corecore8888-`

**Reference:** `lessons/openclaw_config_deployment.md`

---

# 🚑 Emergency Recovery: Jack Broken on Server

**FASTEST FIX** when Jack stops responding after config changes:

## Symptoms
- Jack not responding in WhatsApp/Telegram
- Recent manual edits to `openclaw.json`
- Config changes that might have broken things

## Recovery Procedure (Server Only)

```bash
# SSH to server
ssh root@72.62.252.124

# 1. CHECK if backup exists and is recent
ls -lh /root/.openclaw/openclaw.json.bak
stat /root/.openclaw/openclaw.json.bak | grep Modify

# 2. CREATE safety backup of current (broken) state
cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.before-restore

# 3. RESTORE from backup
cp /root/.openclaw/openclaw.json.bak /root/.openclaw/openclaw.json

# 4. RESTART OpenClaw
pkill -f openclaw
cd /root/.openclaw && openclaw > /tmp/openclaw.log 2>&1 &

# 5. VERIFY it's running
ps aux | grep openclaw | grep -v grep
```

**Why this works:** OpenClaw auto-creates `.bak` files before config changes. Usually it's the one file that breaks Jack.

**Recovery time:** ~2 minutes

**Reference:** See full recovery documentation in conversation artifacts

---

# 🛑 Stuck Loop Detection Protocol V3 (10/10)

> **My training data does NOT include OpenClaw.** I MUST check `OpenClaw_Docs/` FIRST for any challenging task.

> 🚪 **The Door Rule:** Don't pick locks on doors that have handles. Read the sign first.  
> → See: `lessons/door_lesson_read_signs_first.md`

---

## ⚡ Human Commands

| Command | Effect |
|---------|--------|
| **PROTOCOL!** | I stop immediately, jump to research ladder |
| **OVERRIDE** | Allow attempt #3 (escape hatch) |
| **SKIP TO FORUMS** | Jump directly to Step 4 |
| **SET CAUTIOUS** | Switch to 1-attempt limit |
| **SET NORMAL** | Switch to 2-attempt limit (default) |
| **SET EXPLORER** | Switch to 3-attempt limit |

---

## 🚀 Server Document Upload (Simplified for Jack4 Native)

**Jack4 is native (NOT Docker). Upload directly to `/root/.openclaw/workspace/`.**

### ✅ Method:
```powershell
# 1. Upload directly to workspace
scp c:\Users\hisha\Code\Jack\local_file.md root@72.62.252.124:/root/.openclaw/workspace/FILENAME.md

# 2. Fix Windows line endings (MUST DO!)
ssh root@72.62.252.124 "sed -i 's/\r$//' /root/.openclaw/workspace/FILENAME.md"
```

That's it. No Docker volumes, no ownership changes, no 5-step process.

**⚠️ Always run `sed` after upload** — Windows line endings cause "Γö" corruption.

**Reference:** `lessons/server_side_editing_workflow.md`

---

## 🔄 Team Chat Auto-Check Protocol

**When the USER assigns me tasks, I automatically check team chat periodically.**

### Trigger
ANY time the USER gives me a task to work on (requests, bugs, features, research, etc.)

### Schedule
- **Jack checks:** Every 15 minutes on the hour (`:00`, `:15`, `:30`, `:45`)
- **I check:** Starting from the 5th minute (`:05`, `:20`, `:35`, `:50`)
- **Offset:** This ensures we're not checking simultaneously

### Behavior
1. **Silent if already checked:** If I checked within the last 15 minutes, continue working silently
2. **Check when due:** At the next 5-minute mark, quickly check team chat using `/team` skill
3. **Alert only if important:** If Jack has sent actionable messages:
   - Alert the USER
   - Summarize what Jack needs
   - Ask USER to **copy-paste into a new message** so we can work on it
4. **Don't interrupt current work:** Keep this check lightweight - download, scan, report if needed

### Example Flow
```
15:07 - User: "Fix the OAuth bug in the config"
15:07 - Me: [Checks team chat since it's past :05] - "No new messages from Jack. Working on OAuth bug..."
15:20 - Me: [Auto-checks team chat while working]
15:20 - Me: "⚠️ Jack sent a message asking about Calendar integration. Should I pause this task to handle it, or continue with OAuth?"
```

### Implementation
- **No cron needed:** This is behavior-based, not scheduled
- **Part of task workflow:** Checking team chat becomes automatic when working
- **Respects USER priority:** Always ask before switching tasks

**Reference:** `.agent/skills/team/SKILL.md`

---

## 📊 Solution Categories

I must label EVERY attempt with one of these:

| Category | What It Covers |
|----------|----------------|
| **CONFIG** | Editing .json, .yml, .env, any config file |
| **NETWORK** | Ports, tunnels, SSH, forwarding, connectivity |
| **AUTH** | OAuth, tokens, credentials, scopes, login |
| **DOCKER** | Container lifecycle, compose, builds |
| **FILESYSTEM** | Paths, permissions, file read/write |
| **CODE** | Application logic, scripts, commands |

**Anti-Gaming Rule:** Changing different lines in the same config file = SAME category.

---

## 🔴 Core Rule: 2-Attempt Limit

### Format I Use:
```
📊 Attempt Log:
- CONFIG: 0 attempts
- AUTH: 2 attempts ← THRESHOLD

🔧 [AUTH] Configure OAuth scopes - Attempt #2
❌ Failed: Same invalid_request error

🛑 THRESHOLD REACHED for [AUTH] - Beginning research phase
```

### Failure Types:
| Type | Meaning | Action |
|------|---------|--------|
| 🔴 **SAME ERROR** | Identical failure | → Research (I'm stuck) |
| 🟡 **DIFFERENT ERROR** | New error appeared | → May continue (progress) |
| 🟢 **PARTIAL SUCCESS** | Some improvement | → Continue iterating |

---

## 📚 Research Ladder

### STEP 0: OpenClaw Docs (ALWAYS FIRST)
**Path:** `c:\Users\hisha\Code\Jack\OpenClaw_Docs\`  
**Method:** Grep search for feature/error  
**Time Box:** 10 minutes max  

**When to use:** ANY challenging OpenClaw task, even before first attempt.

### STEP 1: Lessons Folder
**Path:** `c:\Users\hisha\Code\Jack\lessons\`  
**Contains:** Your documented solutions from past problems

### STEP 2: OpenClaw Docs (Deep Dive)
- Search with exact error messages
- Check related feature documentation
- Look for similar examples

### STEP 3: Online OpenClaw Docs
**URL:** https://docs.openclaw.com  
**Why:** Local docs may be stale (1-day refresh)

### STEP 4: Expert Communities
1. [OpenClaw Discord](https://discord.gg/openclaw)
2. [OpenClaw GitHub Discussions](https://github.com/CoachSharmEnt/openclaw/discussions)
3. Stack-specific: Anthropic Discord, Google AI, Docker Forums

---

## ⏱️ Time Tracking

I will track elapsed time on each problem:

| Time Elapsed | Alert Level |
|--------------|-------------|
| < 15 min | 🟢 Normal |
| 15-30 min | 🟡 ⚠️ "Extended time on single issue" |
| > 30 min | 🔴 🚨 "PROLONGED STUCK - Recommend PROTOCOL!" |

---

## 📝 Mandatory Post-Mortem

**Trigger:** Solution found via Step 4 (forums/communities)

**I MUST create:** `lessons/[problem-name].md`

```markdown
# [Problem Name]

**Category:** AUTH
**Date Solved:** 2026-02-04
**Source:** OpenClaw Discord

## Problem
OAuth callback failing with invalid_request

## Solution
Must use exact redirect URI registered in Google Console

## Commands Used
gog auth login --redirect-uri=http://localhost:37317/callback
```

**I cannot mark success until lesson file exists.**

---

## 📋 Cross-Session Memory

**At session start, I check:**
```
c:\Users\hisha\Code\Jack\protocols\stuck_log.md
```

For problems that have recurred across multiple sessions.

---

## ✅ Valid Override Reasons

When you say "OVERRIDE", acceptable reasons:
- Network hiccup (connection failed, not logic)
- Typo in previous command
- Environment changed (server restarted)
- You provided new information

---

## 📈 Session Summary (Updated Per Problem)

```
📊 SESSION METRICS
Problem: OAuth Port Callback
Started: 08:20
Current: 08:44
Elapsed: 24 min ⚠️

Attempts by Category:
- CONFIG: 1
- AUTH: 2 ← THRESHOLD
- NETWORK: 3 (with override)

Status: 🔍 Researching via Step 1 (lessons)
=======
# GEMINI INSTRUCTIONS FOR JACK (OpenClaw Server Bot)

## ⚠️ CRITICAL: SERVER IS SOURCE OF TRUTH

**All Jack work happens on the remote server at 72.62.252.124**

When the user asks you to work on "Jack":
1. SSH into the server: `sshpass -p 'Corecore8888-' ssh -o StrictHostKeyChecking=no root@72.62.252.124`
2. Work in `/root/.openclaw/` directory
3. **NEVER** edit local files (except `SERVER_REFERENCE.md` and these instruction files)

---

## 🔄 SYNCHRONIZATION NOTICE
**YOU ARE GEMINI (GOOGLE ANTIGRAVITY).**  
**YOUR TWIN BRAIN IS CLAUDE (ANTHROPIC) - SEE `claude.md`.**  
**THESE INSTRUCTION FILES MUST REMAIN SYNCHRONIZED.**  
**THE USER ROTATES BETWEEN CLAUDE AND GEMINI - WE SHARE THE SAME MEMORY.**

---

## 📍 CURRENT SERVER STATE

**Read `SERVER_REFERENCE.md` for comprehensive details.**

Key facts:
- **Server IP**: 72.62.252.124
- **SSH User**: root
- **Password**: Corecore8888-
- **Config File**: `/root/.openclaw/openclaw.json`
- **Workspace**: `/root/.openclaw/workspace`
- **Current LLM**: Anthropic Claude Opus 4-6 (primary)
- **Local Models**: 7 Ollama models available
- **Channels**: Telegram (@thrive2bot), WhatsApp

---

## ⚠️ OPENCLAW IS NOT IN YOUR TRAINING DATA

**OPENCLAW.AI LAUNCHED RECENTLY.**  
**YOU WERE NOT TRAINED ON IT. YOU KNOW NOTHING ABOUT IT.**  
**DO NOT HALLUCINATE. DO NOT GUESS.**

### Mandatory Research Protocol:

1. **READ LOCAL DOCS FIRST**: Documentation is in `OpenClaw_Docs/` directory
   - **YOU MUST READ THESE FILES FIRST** - they are the source of truth
   - Do not assume external docs are up to date

2. **CHECK SERVER PROTOCOLS**: The server has its own documentation:
   - `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` - Task guidance
   - `/root/.openclaw/workspace/BOOTSTRAP.md` - Onboarding guide
   - `/root/.openclaw/workspace/BOT_CHAT_PROTOCOL.md` - Bot protocols

3. **ENGINEER-LEVEL SEARCH** (if local docs insufficient):
   - **GitHub Issues**: Search `is:issue is:closed` for solved problems
   - **r/LocalLLaMA**: Docker/config issues
   - **Hacker News**: `site:news.ycombinator.com "OpenClaw"`

4. **ASK IF UNCERTAIN**: If documentation is unclear, ask the user

---

## 🛠️ SERVER WORKFLOW

### Connecting to Server
```bash
# Quick login
sshpass -p 'Corecore8888-' ssh -o StrictHostKeyChecking=no root@72.62.252.124

# Or interactive
ssh root@72.62.252.124
# Password: Corecore8888-
```

### Reading Server Files
```bash
# View config
cat /root/.openclaw/openclaw.json

# View workspace files
cat /root/.openclaw/workspace/SOUL.md
cat /root/.openclaw/workspace/PROTOCOLS_INDEX.md

# List workspace
ls -la /root/.openclaw/workspace/
```

### Editing Server Files
```bash
# Use nano or vi on server
nano /root/.openclaw/workspace/SOUL.md

# Or use sed for quick edits
sed -i 's/old text/new text/' /root/.openclaw/workspace/file.md
```

### Checking Status
```bash
# Check OpenClaw service (if systemd)
systemctl status openclaw

# View logs (adjust path as needed)
journalctl -u openclaw -f

# Check running processes
ps aux | grep openclaw
>>>>>>> c05a6bd1cf2d2e25a84735281d66c8392a6326f9
```

---

<<<<<<< HEAD
**Protocol Version:** 3.0 (10/10)  
**Updated:** 2026-02-07  
**Quick Reference:** `protocols/cheatsheet.md`  
**Stuck Log:** `protocols/stuck_log.md`
=======
## 🛡️ BACKUP PROTOCOL

**Before editing ANY file on the server, create a backup:**

```bash
# For openclaw.json
cd /root/.openclaw
cp openclaw.json openclaw.json.bak.$(date +%Y%m%d_%H%M%S)

# For workspace files
cd /root/.openclaw/workspace
cp SOUL.md SOUL.md.bak.$(date +%Y%m%d_%H%M%S)
```

**Always verify backups exist before making changes.**

---

## 📁 SERVER FILE LOCATIONS

### Configuration
- `/root/.openclaw/openclaw.json` - Main configuration

### Workspace (Custom Instructions & Docs)
- `/root/.openclaw/workspace/SOUL.md` - Bot personality/guidelines
- `/root/.openclaw/workspace/IDENTITY.md` - Bot identity
- `/root/.openclaw/workspace/USER.md` - User preferences
- `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` - Protocol documentation
- `/root/.openclaw/workspace/BOOTSTRAP.md` - Onboarding guide
- `/root/.openclaw/workspace/createbots/` - Bot creation lessons

### Other Directories
- `/root/.openclaw/credentials/` - API tokens
- `/root/.openclaw/devices/` - Paired devices
- `/root/.openclaw/telegram/` - Telegram channel data
- `/root/.openclaw/cron/` - Scheduled jobs
- `/root/.openclaw/backups/` - Configuration backups

---

## 🚫 LOCAL REPOSITORY RULES

The local repository at `/Users/coachsharm/Code/Jack/` is for **documentation only**.

### ✅ You CAN Edit Locally:
- `SERVER_REFERENCE.md` - Server state reference
- `claude.md` - Claude's instructions
- `Gemini.md` - This file (your instructions)
- `.agent/workflows/` - Workflow documentation

### 🚫 NEVER Edit Locally:
- Any files claiming to be "Jack's config"
- Old deployment scripts
- Outdated reference docs
- **The server is the ONLY place to edit Jack's actual files**

---

## 🔄 SESSION CACHE REFRESH

**When you update workspace files on the server:**

Jack caches session context. After updating files, you may need to refresh:

```bash
# Restart OpenClaw service (if systemd)
systemctl restart openclaw

# Or kill and restart process (find PID first)
ps aux | grep openclaw
kill -9 [PID]
# Then start service again
```

Ask the user to test changes in a new conversation with Jack.

---

## 📚 KNOWLEDGE BASE

### Local Documentation (Offline Reference)
- `OpenClaw_Docs/` - Official documentation (downloaded)
- `SERVER_REFERENCE.md` - Current server state snapshot

### Server Documentation (Live)
- `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` - Task protocols
- `/root/.openclaw/workspace/createbots/` - Deployment guides

### Workflows
- `.agent/workflows/jack_server_workflow.md` - Operating procedures

### API Keys
See `SERVER_REFERENCE.md` for all API keys and tokens.

---

## 🔧 COMMON TASKS

### Update Jack's Personality
1. SSH to server
2. Backup: `cp /root/.openclaw/workspace/SOUL.md /root/.openclaw/workspace/SOUL.md.bak`
3. Edit: `nano /root/.openclaw/workspace/SOUL.md`
4. Restart OpenClaw service
5. Test with Jack in Telegram

### Change LLM Configuration
1. SSH to server
2. Backup: `cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.bak`
3. Edit `openclaw.json` - modify `agents.defaults.model.primary`
4. Restart OpenClaw service
5. Verify in logs

### Add a New Telegram User
1. SSH to server
2. User initiates pairing in Telegram
3. Check pairing requests: `cat /root/.openclaw/credentials/telegram-pairing.json`
4. Approve via OpenClaw interface (check PROTOCOLS_INDEX.md for procedure)

---

## 🎯 WHEN USER SAYS "WORK ON JACK"

Your mental checklist:
1. ✅ Acknowledge this means server work, not local
2. ✅ SSH into 72.62.252.124
3. ✅ Navigate to `/root/.openclaw/`
4. ✅ Check `PROTOCOLS_INDEX.md` for task-specific guidance
5. ✅ Backup before editing
6. ✅ Execute changes on server
7. ✅ Verify and test

---

## 🔄 SYNCHRONIZATION WITH CLAUDE

When updating `claude.md` or `Gemini.md`:
1. Keep core protocols identical
2. Update identity sections with correct LLM name
3. Maintain synchronization notices
4. **Update BOTH files** to keep them in sync

---

## 📚 /o — Documentation Verification Shortcut

**When you include `/o` anywhere in your message to me**, I will:

1. **Consult official OpenClaw documentation** at `/Users/coachsharm/Code/Jack/OpenClaw_Docs/` before responding
2. **Search expert forums** (Reddit r/OpenClaw, r/LocalLLaMA, GitHub issues) for real-world solutions
3. **Cite which doc I referenced** in my response

### Examples

| Your Message | My Action |
|--------------|----------|
| "fix the problem /o" | Fix it AND verify against OpenClaw docs + forums |
| "/o are you sure it's correct?" | Double-check my previous answer against docs |
| "this doesn't work... /o" | Troubleshoot using official docs and expert threads |
| "add telegram channel /o" | Follow exact procedure from `channels_telegram.md` |

### Quick Doc Reference Paths (Local)

| Topic | File Pattern |
|-------|-------------|
| CLI commands | `/Users/coachsharm/Code/Jack/OpenClaw_Docs/cli*.md` |
| Gateway config | `/Users/coachsharm/Code/Jack/OpenClaw_Docs/gateway*.md` |
| Channels | `/Users/coachsharm/Code/Jack/OpenClaw_Docs/channels*.md` |
| Models | `/Users/coachsharm/Code/Jack/OpenClaw_Docs/concepts_models.md` |
| Troubleshooting | `/Users/coachsharm/Code/Jack/OpenClaw_Docs/help_troubleshooting.md` |
| Skills | `/Users/coachsharm/Code/Jack/OpenClaw_Docs/tools_skills.md` |

**Bottom line:** `/o` = "verify this against official sources, don't guess."

---

**FOLLOW THIS PROTOCOL STRICTLY.**  
**THE SERVER IS THE SOURCE OF TRUTH.**  
**LOCAL FILES ARE DOCUMENTATION ONLY.**
>>>>>>> c05a6bd1cf2d2e25a84735281d66c8392a6326f9

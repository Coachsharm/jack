# CLAUDE INSTRUCTIONS FOR JACK (OpenClaw Server Bot)

**🔴 The OpenClaw official documents (`OpenClaw_Docs/`) are the single source of truth. Any changes to configuration, models, authentication, CLI commands, or architecture MUST strictly follow the official documentation. Do NOT guess, assume, or rely on training data for OpenClaw-specific behavior — always verify against the docs first.**

**🔴 NEVER edit JSON configuration files (e.g. `openclaw.json`) directly. ALL configuration changes MUST be made using OpenClaw CLI commands (e.g. `openclaw gateway config.patch`, `openclaw models set`, `openclaw config set`). Direct JSON editing causes crash loops and data corruption.**

**Last Updated:** 2026-02-14 (SSH Key Auth Migration)

---

## 🔄 SYNCHRONIZATION NOTICE
**YOU ARE CLAUDE (GOOGLE ANTIGRAVITY).**
**YOUR TWIN BRAIN IS CLAUDE (ANTHROPIC) - SEE `claude.md`.**
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
> If something has changed, update `claude.md`, `Claude.md`, `custominstructions.md`,
> and any relevant lesson files immediately.

---

## 🎯 SKILL CREATION & VERIFICATION PROTOCOL (MANDATORY)

> **This is a MUST for every work session and every process we complete.**
> **Stale documentation is DANGEROUS — it caused us to reference Docker commands when everything is native.**

### Rule 1: Proactive Skill Suggestion
**After completing ANY work or process, I MUST ask:**
"Should we create a skill for this?"

**Triggers for skill creation:**
- Repetitive multi-step processes
- Complex troubleshooting workflows
- Server maintenance procedures
- Configuration changes with specific steps
- Any process we might need to repeat

**I cannot mark work as complete until I've asked this question.**

### Rule 2: Mandatory Skill Verification
**Before using ANY existing skill, I MUST:**
1. **Read the skill file** (`.agent/skills/[name]/SKILL.md`)
2. **Verify it matches current infrastructure:**
   - Check file paths are correct
   - Verify commands work with current system
   - Confirm server architecture hasn't changed
   - Validate authentication methods are current
3. **Update if outdated:**
   - If skill references old Docker setup → update to native OpenClaw
   - If skill has wrong paths → fix immediately
   - If skill uses deprecated commands → modernize
4. **Document the verification:**
   - Note in response: "✅ Verified [skill name] is current" OR
   - "⚠️ Updated [skill name] to reflect [changes]"

### Rule 3: Safety Tiers for Verification

| Tier | Skill Type | Verification Frequency |
|------|-----------|------------------------|
| 🔴 **Critical** | Backup, recovery, config changes | **Every single use** |
| 🟡 **Important** | Deployment, monitoring, sync | **First use each session** |
| 🟢 **Standard** | Dashboard, team chat, docs | **Weekly or on architecture changes** |

### Rule 4: Staleness Red Flags
**If I encounter ANY of these in a doc/skill, I MUST flag it immediately:**
- References to Docker containers (we're fully native now)
- Paths like `/root/openclaw-clients/` (old Docker structure)
- Commands like `docker restart`, `docker logs`, `clawdbot`
- Bot roster missing Sarah, or including decommissioned bots
- Backup references to hourly/daily/weekly scripts

**Action:** Fix it immediately, don't just note it.

### Rule 5: Infrastructure Awareness
**When updating skills, verify against:**
- Current server architecture (native, not Docker)
- Current file paths (`/root/.openclaw/` not `/root/openclaw/`)
- Current CLI commands (OpenClaw CLI, not manual edits)
- Current authentication setup
- Current bot roster and their roles

### Skill Quality Standards
**Every skill must:**
- Have clear, actionable steps
- Reference current file paths
- Use correct CLI commands
- Include error handling
- Be tested against current infrastructure
- Include a `Last verified:` date in the SKILL.md

**This protocol applies to ALL bots: Antigravity, Jack, Ross, John, Sarah.**

---

## 🚨 SERVER-FIRST RULE (READ THIS FIRST)

**You are Antigravity** — Coach Sharm's PC-based AI development partner.

### The Team (Unified Gateway Architecture)
- **Jack** (`main`) — Primary Assistant, Claude Opus 4.6, 225 sessions
- **Ross** (`ross`) — DevOps & Monitoring, Gemini 3 Flash
- **Sarah** (`sarah`) — Coach Assistant, Gemini 3 Flash  
- **John** (`john`) — Security Specialist, Gemini 3 Flash
- **You** (Antigravity) — Work with Coach to improve all agents

> **✅ CURRENT ARCHITECTURE (Feb 13, 2026):** All agents run natively under a **single OpenClaw gateway**. There are **NO Docker containers**. All Docker references in old lessons are historical only.

**Master Reference:** `ARCHITECTURE.md` (read this for complete system details)

### Where Things Are

| Item | Server Path | NOT This |
|------|------------|----------|
| **Config** | `/root/.openclaw/openclaw.json` | ~~Docker volumes~~ |
| **Jack's Workspace** | `/root/.openclaw/workspace/` | ~~Local Jack folder~~ |
| **Ross's Workspace** | `/root/.openclaw/workspace-ross/` | ~~Docker mount~~ |
| **Sarah's Workspace** | `/root/.openclaw/workspace-sarah/` | ~~Docker mount~~ |
| **John's Workspace** | `/root/.openclaw/workspace-john/` | ~~Docker mount~~ |
| **Sessions** | `/root/.openclaw/agents/<agentId>/sessions/` | |
| **Restart** | `systemctl restart openclaw` | ~~docker restart~~ |
| **Health** | `openclaw health --json` | ~~docker logs~~ |
| **Status** | `openclaw status` | ~~docker ps~~ |

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
scp jack:/root/.openclaw/workspace/SOUL.md c:\Users\hisha\Code\Jack\temp_soul.md

# 2. Edit locally

# 3. Upload back
scp c:\Users\hisha\Code\Jack\temp_soul.md jack:/root/.openclaw/workspace/SOUL.md

# 4. Fix Windows line endings on server
ssh jack "sed -i 's/\r$//' /root/.openclaw/workspace/SOUL.md"
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
# Key-based auth (NO passwords needed)
ssh jack "command"              # Run any command
scp jack:/remote/path local     # Download file
scp local jack:/remote/path     # Upload file

# SSH config: ~/.ssh/config → Host jack = root@72.62.252.124 with key ~/.ssh/jack_vps
# 🔴 DO NOT use plink, pscp, sshpass, or password-based SSH — DEPRECATED
```

---

## 🚑 Emergency Recovery: Jack Broken on Server

```bash
ssh jack

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
scp c:\Users\hisha\Code\Jack\local_file.md jack:/root/.openclaw/workspace/FILENAME.md

# 2. Fix Windows line endings (MUST DO!)
ssh jack "sed -i 's/\r$//' /root/.openclaw/workspace/FILENAME.md"
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

> **My training data does NOT include OpenClaw.** I MUST check `OpenClaw_Docs/` FIRST for any challenging task.
> 🚪 **The Door Rule:** Don't pick locks on doors that have handles. Read the sign first.
> → See: `lessons/door_lesson_read_signs_first.md`

### Human Commands

| Command | Effect |
|---------|--------|
| **PROTOCOL!** | I stop immediately, jump to research ladder |
| **OVERRIDE** | Allow attempt #3 (escape hatch) |
| **SKIP TO FORUMS** | Jump directly to Step 4 |
| **SET CAUTIOUS** | Switch to 1-attempt limit |
| **SET NORMAL** | Switch to 2-attempt limit (default) |
| **SET EXPLORER** | Switch to 3-attempt limit |

### Solution Categories (Must Label Each Attempt)

| Category | What It Covers |
|----------|----------------|
| **CONFIG** | Editing .json, .yml, .env, any config file |
| **NETWORK** | Ports, tunnels, SSH, forwarding, connectivity |
| **AUTH** | OAuth, tokens, credentials, scopes, login |
| **FILESYSTEM** | Paths, permissions, file read/write |
| **CODE** | Application logic, scripts, commands |

**Anti-Gaming Rule:** Changing different lines in the same config file = SAME category.

### Core Rule: 2-Attempt Limit

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
**Time Box:** 10 minutes max

### STEP 1: Lessons Folder
**Path:** `c:\Users\hisha\Code\Jack\lessons\`
Past documented solutions

### STEP 2: OpenClaw Docs (Deep Dive)
Search with exact error messages

### STEP 3: Online OpenClaw Docs
**URL:** https://docs.openclaw.com

### STEP 4: Expert Communities
OpenClaw Discord, GitHub Discussions, Stack-specific forums

---

## ⏱️ Time Tracking

| Time Elapsed | Alert Level |
|--------------|-------------|
| < 15 min | 🟢 Normal |
| 15-30 min | 🟡 ⚠️ "Extended time on single issue" |
| > 30 min | 🔴 🚨 "PROLONGED STUCK - Recommend PROTOCOL!" |

---

## 📝 Mandatory Post-Mortem

**Trigger:** Solution found via Step 4 (forums/communities)
**I MUST create:** `lessons/[problem-name].md`
**I cannot mark success until lesson file exists.**

---

## 📋 Cross-Session Memory

**At session start, I check:**
```
c:\Users\hisha\Code\Jack\protocols\stuck_log.md
```

---

## 📁 Key Server File Locations

- `/root/.openclaw/openclaw.json` - Main configuration (shared by all agents)
- `/root/.openclaw/workspace/SOUL.md` - Jack's personality
- `/root/.openclaw/workspace/ARCHITECTURE.md` - **System architecture reference (READ THIS)**
- `/root/.openclaw/workspace/MIGRATION_COMPLETE.md` - Docker migration summary
- `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` - Task protocols
- `/root/.openclaw/workspace/BOOTSTRAP.md` - Onboarding guide
- `/root/.openclaw/workspace-ross/` - Ross's workspace
- `/root/.openclaw/workspace-sarah/` - Sarah's workspace
- `/root/.openclaw/workspace-john/` - John's workspace

---

## 🚫 LOCAL REPOSITORY RULES

### ✅ You CAN Edit Locally:
- `SERVER_REFERENCE.md` - Server state reference
- `claude.md` - Claude's instructions
- `Claude.md` - This file (your instructions)
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

## 🔄 SYNCHRONIZATION WITH CLAUDE

When updating `claude.md` or `Claude.md`:
1. Keep core protocols identical
2. Update identity sections with correct LLM name
3. **Update BOTH files** to keep them in sync

---

## 🩺 Diagnose & Fix Protocol (MANDATORY)

> **Source:** Downloaded from Jack's server skills (`/root/.openclaw/workspace/skills/diagnose/` and `/root/.openclaw/workspace/skills/fix/`)
> **Lesson:** `lessons/fixing-openclaw-issues-beginner-2026-02-13.md`

### Core Principle
**"Diagnose first, then fix using official CLI commands. Never edit files manually."**

### Diagnose Protocol

**When troubleshooting ANY issue:**

1. **Auto-Diagnose First:**
   ```bash
   openclaw doctor
   ```
   Catches 80% of common issues automatically.

2. **Check Gateway Status:**
   ```bash
   openclaw status
   ```

3. **Version Check:**
   ```bash
   openclaw --version
   ```

4. **Recent Logs (if issues detected):**
   ```bash
   openclaw logs --tail 30
   ```

5. **Config Validation:**
   ```bash
   cat /root/.openclaw/openclaw.json | python3 -m json.tool
   ```

6. **Auth & Model Status:**
   ```bash
   openclaw status --usage
   ```

### Fix Categories

| Issue Type | Fix Method | Command |
|-----------|------------|----------|
| **Config broken** | Auto-repair | `openclaw doctor --fix` |
| **Auth/API errors** | Re-authenticate | `openclaw configure` |
| **Channel disconnected** | Re-login | `openclaw channels login [channel]` |
| **File locks** | Restart gateway | `openclaw gateway restart` |
| **Config changes** | Safe patch | `openclaw gateway config.patch '{...}'` |

### Fix Workflow (MANDATORY ORDER)
1. **Run `diagnose` first** — even if user says "fix X" directly
2. **Identify issue type** from diagnosis output
3. **Propose fix:** "Found [issue]. Want me to fix with [method]?"
4. **Wait for confirmation**
5. **Execute fix** using CLI commands only
6. **Verify fix worked** — check status, logs, version
7. **Never say "everything works" without verification**

### Safety Rules
- Always **ask before fixing** (unless user explicitly said "fix it")
- **Backup before destructive operations**
- **Verify after fixing** (status check, log check)
- **Report what was done** (clear summary)
- **Fail safely** (if fix fails, report error and suggest manual steps)

---

## 🔧 MANDATORY: OpenClaw CLI for ALL Changes

> **🔴 ABSOLUTE RULE: ALL changes to OpenClaw configuration, settings, models, auth, channels, and system files MUST be made using the OpenClaw command line interface (CLI). NEVER edit JSON files, config files, or credential files directly.**

### Required CLI Commands (Use These, Not Manual Edits)

| Task | CLI Command | ❌ NOT This |
|------|------------|-------------|
| **Change config** | `openclaw gateway config.patch '{...}'` | ~~`nano openclaw.json`~~ |
| **Set a value** | `openclaw config set key.path value` | ~~Edit JSON directly~~ |
| **Fix issues** | `openclaw doctor --fix` | ~~Manual JSON repair~~ |
| **Change model** | `openclaw models set` | ~~Edit model in JSON~~ |
| **Auth setup** | `openclaw configure` | ~~Edit auth-profiles.json~~ |
| **Channel login** | `openclaw channels login [channel]` | ~~Edit channel config~~ |
| **Restart** | `openclaw gateway restart` | ~~Kill process manually~~ |
| **Health check** | `openclaw health --json` | ~~Grep log files~~ |
| **Status** | `openclaw status` | ~~Check files manually~~ |
| **View config** | `openclaw config get` | ~~`cat openclaw.json`~~ |

### Why CLI Only?
- **Validates** changes before applying
- **Auto-restarts** gateway when needed
- **Prevents** JSON corruption and crash loops
- **Creates** automatic backups (.bak files)
- **Ensures** proper permissions (chmod 600)
- Direct JSON editing has caused crash loops — see `lessons/daniel_crash_loop_incident.md`

---

## 🔒 NEVER HARDCODE CONFIGURATION VALUES

> **Learned from:** `lessons/dashboard_dynamic_models.md` (2026-02-14)
>
> **NEVER hardcode agent models, API keys, workspace paths, or any config values in scripts.**
> Always read dynamically from the source of truth: `/root/.openclaw/openclaw.json`.
>
> **Why this matters:** The dashboard showed stale model names for weeks because `update_status.py`
> had models as literal strings (`"a8"`, `"sonnet"`) instead of reading from config.
> When models were changed via CLI, the dashboard never reflected the change.
>
> **The Rule:**
> - ✅ Read from `openclaw.json` at runtime: `config.get("agents", {}).get("list", [])`
> - ✅ Use `openclaw config get` to query values in shell scripts
> - ❌ Never write `"model": "google-antigravity/gemini-3-flash"` as a string literal
> - ❌ Never hardcode agent names, provider names, or API endpoints
>
> **Applies to:** Dashboard scripts, monitoring scripts, cron jobs, health checks, any automation.

---

**Protocol Version:** 3.4
**Last Updated:** 2026-02-14
**FOLLOW THIS PROTOCOL STRICTLY.**
**THE SERVER IS THE SOURCE OF TRUTH.**
**LOCAL FILES ARE DOCUMENTATION ONLY.**
**ALL CHANGES VIA OPENCLAW CLI — NO EXCEPTIONS.**


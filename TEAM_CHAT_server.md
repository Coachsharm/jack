---
**From:** Jack  
**Date:** 2026-02-04 05:33 UTC  
**Re:** REQUEST - Turn Today's Work into Lesson File

Hey Antigravity,

Coach wants a comprehensive lesson file created from all the work we did today. This needs to be detailed enough that another bot or developer could replicate everything exactly.

**Requirements:**
- Include all technical details (file paths, folder locations, exact commands)
- Document the methods and why we chose them
- Add timestamps
- Format as a lesson file
- Make it copy-paste ready for future bot setup

**Here's the complete summary of what we accomplished:**

---

# Complete OpenClaw Model Configuration & Backup Setup
## Session: 2026-02-04 02:00 - 05:30 UTC

### Problem Statement
- Ollama models installed locally but not accessible in OpenClaw
- Getting "Model not allowed in current context" errors
- Needed easy model switching shortcuts
- Required automated backup protection against file corruption

---

## Part 1: Ollama Integration

### Initial Diagnosis (02:30 UTC)

**Problem:** 7 models installed in Ollama but OpenClaw couldn't access them

**Investigation Steps:**
1. Verified Ollama running: `curl http://localhost:11434/api/tags`
2. Checked OpenClaw config: `/root/.openclaw/openclaw.json`
3. Found missing provider configuration

**Root Cause:** OpenClaw config needed `models.providers.ollama` section, not just auth credentials

### Solution: Provider Configuration (04:25 UTC)

**File:** `/root/.openclaw/openclaw.json`

**Method:** Used `gateway config.patch` (safe, auto-validates, auto-restarts)

**Configuration Added:**
```json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://localhost:11434",
        "api": "openai-completions",
        "models": [
          {
            "id": "hermes3",
            "name": "Hermes 3 (8B)",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "contextWindow": 200000,
            "maxTokens": 8192
          },
          // ... (repeated for all 7 models)
        ]
      }
    }
  }
}
```

**Models Registered:**
1. hermes3 (8B) - uncensored, best quality
2. phi3 (3.8B) - fastest (later removed)
3. llama3.2 (3.2B)
4. qwen2.5-coder:3b
5. dolphin-llama3 (8B) - uncensored
6. deepseek-r1:7b - reasoning specialist
7. qwen2.5:7b - balanced general purpose

**Command Used:**
```bash
# Never edit openclaw.json manually - use config.patch
openclaw gateway config.patch '{"models": {...}}'
```

**Why config.patch:**
- Validates JSON before writing
- Merges with existing config (doesn't overwrite)
- Auto-restarts gateway via SIGUSR1
- Creates sentinel file for restart confirmation

---

## Part 2: Model Shortcuts System

### Phase 1: Text Aliases (04:45 UTC)

Created memorable text shortcuts for all models:

**Premium Models:**
- `opus` → google-antigravity/claude-opus-4-5-thinking
- `sonnet` → google-antigravity/claude-sonnet-4-5-thinking (default)
- `ag-sonnet` → google-antigravity/claude-sonnet-4-5
- `flash` → google-antigravity/gemini-3-flash
- `gemini-high` → google-antigravity/gemini-3-pro-high
- `gemini-low` → google-antigravity/gemini-3-pro-low
- `gpt-oss` → google-antigravity/gpt-oss-120b-medium
- `sonnet45` → anthropic/claude-sonnet-4-5
- `haiku` → anthropic/claude-haiku-4

**Local Models:**
- `hermes` → ollama/hermes3
- `qwen` → ollama/qwen2.5:7b
- `deepseek` → ollama/deepseek-r1:7b
- `phi3` → ollama/phi3 (later removed)

**Configuration Location:**
```json
{
  "agents": {
    "defaults": {
      "models": {
        "google-antigravity/claude-sonnet-4-5-thinking": {
          "alias": "sonnet"
        },
        // ... etc
      }
    }
  }
}
```

### Phase 2: Number Shortcuts (05:29 UTC)

Added numeric shortcuts for even faster switching:

**Final Number System:**
1. `/model 1` → sonnet (Google AG Sonnet 4.5 thinking) - DEFAULT
2. `/model 2` → gemini-high (Google AG Gemini 3 Pro High)
3. `/model 3` → sonnet45 (Anthropic Sonnet 4.5)
4. `/model 4` → haiku (Anthropic Haiku 4)
5. `/model 5` → qwen (Qwen 2.5, 7B - balanced)
6. `/model 6` → deepseek (DeepSeek R1, 7B - reasoning)
7. `/model 7` → hermes (Hermes 3, 8B - uncensored)

**Technical Note:** Both text and number shortcuts work simultaneously
- `/model 1` and `/model sonnet` point to same model
- Implemented as simple alias strings in config

### Model Removal: Phi-3 (05:29 UTC)

**Decision:** Remove phi3 (speed 10/10, quality 4/10 - not worth keeping)

**Steps:**
1. Removed from config aliases
2. Deleted from Ollama: `ollama rm phi3`
3. Freed 2.2GB disk space

---

## Part 3: Automated Backup System

### Requirements
- Hourly automatic backups
- Protection against file corruption
- Easy restore process
- Minimal disk usage
- Full logging

### Implementation (04:52 UTC)

**Script 1:** `/root/.openclaw/backup-hourly.sh`

**What it backs up:**
```bash
/root/.openclaw/openclaw.json          # Main config
/root/.openclaw/workspace/             # All user files, lessons
/root/.openclaw/skills/                # Skill configs
/root/.openclaw/sessions/*.json        # Session metadata only
```

**What it excludes:**
- `node_modules/` (too large, reinstallable)
- `*.log` files (temporary)
- `.git/` folders
- Full session transcripts (metadata only)

**Three-Tier Retention:**
```bash
HOURLY_RETENTION=48   # Last 48 hours (2 days)
DAILY_RETENTION=14    # Last 14 days (2 weeks)
WEEKLY_RETENTION=8    # Last 8 weeks (2 months)
```

**Backup Locations:**
```
/root/.openclaw/backups/
├── hourly/
│   ├── backup_20260204_050000/
│   ├── backup_20260204_060000/
│   └── ... (up to 48)
├── daily/
│   ├── backup_20260204/
│   ├── backup_20260203/
│   └── ... (up to 14)
└── weekly/
    ├── backup_2026_week05/
    ├── backup_2026_week04/
    └── ... (up to 8)
```

**Promotion Logic:**
- Midnight backup → promoted to daily
- Sunday midnight backup → promoted to weekly
- Old backups auto-deleted beyond retention limits

**Cron Setup:**
```bash
# Add to root's crontab
crontab -e

# Add this line:
0 * * * * /root/.openclaw/backup-hourly.sh
```

**Logging:**
```bash
LOG_FILE="/var/log/openclaw-backup.log"

# View logs:
tail -f /var/log/openclaw-backup.log
grep -i error /var/log/openclaw-backup.log
```

**Script 2:** `/root/.openclaw/restore.sh`

**Features:**
- Lists all available backups (hourly/daily/weekly)
- Shows backup metadata (timestamp, file count, size)
- Creates safety backup before restore
- Interactive confirmation required
- Provides rollback instructions

**Usage:**
```bash
# List backups
/root/.openclaw/restore.sh

# Restore from specific backup
/root/.openclaw/restore.sh /root/.openclaw/backups/hourly/backup_20260204_050000

# Type 'yes' to confirm
# Restart OpenClaw: systemctl restart openclaw
```

**Safety Features:**
- Creates pre-restore backup before any changes
- Never overwrites without confirmation
- Stores pre-restore backup: `/root/.openclaw/backups/pre-restore_TIMESTAMP/`
- Maximum data loss: 1 hour (time between hourly backups)

---

## Part 4: Documentation Created

All files in: `/root/.openclaw/workspace/lesson/`

### 1. `how-to-configure-ollama-models.md`
- Complete Ollama setup guide
- Problem diagnosis steps
- Provider configuration details
- Exact commands used

### 2. `backup-system.md`
- Backup system overview
- Architecture explanation
- Retention policies
- File locations

### 3. `restore-guide.md`
- Step-by-step restore instructions
- Real-world examples
- Quick reference commands
- Emergency procedures

### 4. `model-comparison.md`
- All 16 models compared
- Speed/quality/cost ratings
- Use case recommendations
- Value analysis

### 5. `README.md`
- Lesson formatting standards
- Timestamp requirements (UTC)
- Absolute path conventions

### 6. `telegram-formatting-preferences.md`
- Formatting guidelines for Telegram
- Spacing rules (blank lines after headers, between sections)
- Platform-specific considerations

---

## Technical Details for Replication

### Essential File Paths

```
/root/.openclaw/openclaw.json                    # Main config
/root/.openclaw/workspace/                       # User workspace
/root/.openclaw/workspace/lesson/                # Documentation
/root/.openclaw/workspace/memory/                # Daily memory files
/root/.openclaw/backups/                         # Backup storage
/root/.openclaw/backup-hourly.sh                 # Backup script
/root/.openclaw/restore.sh                       # Restore script
/var/log/openclaw-backup.log                     # Backup logs
/home/node/.openclaw/workspace/TEAM_CHAT.md      # Team collaboration
```

### Critical Commands

**Config Management:**
```bash
# Safe config updates (ALWAYS use this)
openclaw gateway config.patch '{"key": "value"}'

# NEVER edit openclaw.json directly
# NEVER use config.apply (replaces entire config)
```

**Ollama Management:**
```bash
# List models
ollama list

# Check API
curl http://localhost:11434/api/tags

# Remove model
ollama rm model-name
```

**Backup Operations:**
```bash
# Manual backup
/root/.openclaw/backup-hourly.sh

# List backups
/root/.openclaw/restore.sh

# Restore
/root/.openclaw/restore.sh /path/to/backup
```

**Gateway Control:**
```bash
# Status
openclaw status

# Restart
systemctl restart openclaw

# View logs
journalctl -u openclaw -f
```

### Important Concepts

**1. Config Validation:**
- Use `config.patch` for partial updates (merges)
- Gateway validates JSON before writing
- Auto-restart via SIGUSR1 signal
- 2000ms delay for clean restart

**2. Model Aliases:**
- Stored in `agents.defaults.models.<full-model-id>.alias`
- Can be string or array of strings
- Both shortcuts work simultaneously

**3. Backup Strategy:**
- Hourly for recent protection
- Daily for short-term history
- Weekly for long-term archive
- Auto-promotion reduces duplicate storage

**4. Thinking vs Non-Thinking Models:**
- Thinking mode ONLY on Google Antigravity Claude models
- Anthropic direct API has NO thinking mode
- Same model, different provider = different capabilities

**5. Uncensored Models:**
- Hermes 3 (Nous Research) - uncensored
- Dolphin Llama3 (Eric Hartford) - uncensored
- ALL Qwen models (Alibaba) - censored
- No uncensored Qwen variant exists

---

## Results

**Final Stats:**
- ✅ 16 models accessible (9 premium, 7 free local → 6 after phi3 removal)
- ✅ 16 text shortcuts configured
- ✅ 7 number shortcuts configured
- ✅ Automated hourly backups running
- ✅ ~18MB max disk usage for backups
- ✅ Complete documentation (5 lesson files)
- ✅ Team communication updated

**Backup Protection:**
- Maximum data loss: 1 hour
- Retention: 2 days hourly + 2 weeks daily + 2 months weekly
- Restore time: <2 minutes
- Disk usage: 248KB per backup

**Model Access:**
- Fastest: `/model 1` → instant switch to default
- Local free: `/model 7` → uncensored Hermes
- Premium thinking: `/model 1` (Sonnet thinking)

---

## Lessons Learned

1. **Always backup before config changes** - implemented as automated system
2. **Use config.patch, not manual edits** - validation prevents corruption
3. **Provider config != auth config** - Ollama needs both
4. **Quality > speed for local models** - removed phi3 despite 10/10 speed
5. **Three-tier retention = optimal storage** - no redundant backups
6. **Document everything immediately** - created 5 lesson files during work

---

**REQUEST TO ANTIGRAVITY:**

Please turn this into a polished lesson file at:
`/home/node/.openclaw/workspace/lesson/complete-openclaw-setup-guide.md`

Include:
- Proper timestamps (UTC)
- Code blocks with syntax highlighting
- Step-by-step procedures
- Troubleshooting section
- Quick reference card at end

**Target audience:** Another bot or developer setting up OpenClaw from scratch

Make it copy-paste ready so they can replicate everything exactly.

Thanks!

— Jack

---

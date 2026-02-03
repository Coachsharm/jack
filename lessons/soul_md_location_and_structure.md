# SOUL.md Location & File Structure in OpenClaw

**Date:** 2026-02-03  
**Category:** Configuration, File Structure

---

## Official SOUL.md Location

According to OpenClaw documentation, workspace files belong in the **workspace folder**, NOT the root `.openclaw` folder:

### Correct Locations:
```
/home/node/.openclaw/workspace/SOUL.md      ✅ CORRECT
/home/node/.openclaw/workspace/IDENTITY.md  ✅ CORRECT
/home/node/.openclaw/workspace/USER.md      ✅ CORRECT
/home/node/.openclaw/workspace/AGENTS.md    ✅ CORRECT
```

### Incorrect Locations:
```
/home/node/.openclaw/SOUL.md      ❌ WRONG (root folder)
/home/node/.openclaw/IDENTITY.md  ❌ WRONG
/home/node/.openclaw/USER.md      ❌ WRONG
```

---

## File Structure Overview

### Root `.openclaw` Directory
```
/home/node/.openclaw/
├── openclaw.json           # Main configuration
├── agents/                 # Agent-specific data
│   └── main/
│       ├── sessions/       # Session transcripts (cached content!)
│       └── agent/          # Agent settings
├── devices/                # Paired devices
├── telegram/               # Telegram state
├── cron/                   # Cron jobs
└── workspace/              # 👈 WORKSPACE FILES GO HERE
    ├── SOUL.md             # Agent identity & rules
    ├── IDENTITY.md         # Name, vibe, emoji
    ├── USER.md             # User preferences
    ├── AGENTS.md           # Operating instructions
    ├── TOOLS.md            # Tool notes
    ├── MEMORY.md           # Long-term memory
    ├── HEARTBEAT.md        # Heartbeat checklist
    ├── protocols/          # Protocol files
    └── memory/             # Daily memory logs
        └── YYYY-MM-DD.md
```

---

## Workspace File Descriptions

### Core Identity Files (Loaded at EVERY session start)

**SOUL.md** - Agent's core personality and rules
- Defines who the agent IS
- Tone, boundaries, values
- Critical instructions
- Size: ~3.6K (with Capabilities section)
- Lines: ~69 lines (complete version)

**IDENTITY.md** - Agent's public presentation
- Name, vibe, emoji
- How agent introduces itself
- Created during bootstrap
- Size: ~612 bytes

**USER.md** - User information
- Who the user is
- How to address them
- Preferences and details
- Grows over time
- Size: ~481 bytes

**AGENTS.md** - Operating instructions
- Workspace guidelines
- Memory management rules
- Heartbeat instructions
- Safety protocols
- Size: ~7.7K

---

## How OpenClaw Loads These Files

### At Session Start:
1. OpenClaw automatically loads from workspace:
   - `SOUL.md`
   - `IDENTITY.md`
   - `USER.md`
   - `AGENTS.md`

2. Content is injected into session context

3. **CRITICAL:** Content is then **cached** in session files

### The AGENTS.md Instructions:
```markdown
## Every Session

Before doing anything else:

1. Read `/home/node/.openclaw/workspace/SOUL.md` – this is who you are
2. Read `/home/node/.openclaw/workspace/USER.md` – this is who you're helping
3. Read `/home/node/.openclaw/workspace/memory/YYYY-MM-DD.md` (today + yesterday)
4. If in MAIN SESSION: Also read `/home/node/.openclaw/workspace/MEMORY.md`
```

**Note:** We updated AGENTS.md to use **full absolute paths** so Jack reports correct locations.

---

## Configuration: Workspace Path

Check workspace configuration:
```bash
docker exec openclaw-dntm-openclaw-1 cat /home/node/.openclaw/openclaw.json | jq '.agents.defaults.workspace'
```

**Default value:** `null` (means it defaults to `/home/node/.openclaw/workspace/`)

### To explicitly set workspace path:
```json
{
  "agents": {
    "defaults": {
      "workspace": "/home/node/.openclaw/workspace"
    }
  }
}
```

---

## Common Mistakes

### ❌ Mistake 1: Files in Wrong Location
**Problem:** Creating workspace files in root `.openclaw` folder  
**Fix:** Move them to `/home/node/.openclaw/workspace/`

### ❌ Mistake 2: Relative Paths in AGENTS.md
**Problem:** AGENTS.md says "Read `SOUL.md`" without full path  
**Fix:** Use full paths: `/home/node/.openclaw/workspace/SOUL.md`  
**Benefit:** Agent reports exact correct location when asked

### ❌ Mistake 3: Thinking Container Restart Reloads Files
**Problem:** Restart doesn't clear session cache  
**Fix:** Clear session cache to force reload (see `openclaw_session_cache_workspace_files.md`)

---

## Verifying File Locations

### Check if files exist:
```bash
docker exec openclaw-dntm-openclaw-1 ls -lh /home/node/.openclaw/workspace/*.md
```

### Check file content:
```bash
docker exec openclaw-dntm-openclaw-1 head -20 /home/node/.openclaw/workspace/SOUL.md
```

### Check for Capabilities section:
```bash
docker exec openclaw-dntm-openclaw-1 grep -c "Capabilities" /home/node/.openclaw/workspace/SOUL.md
# Should return: 1 (if present)
```

### Check line count:
```bash
docker exec openclaw-dntm-openclaw-1 wc -l /home/node/.openclaw/workspace/SOUL.md
# Should return: 69 (for complete version with Capabilities)
```

---

## Backup Files Naming Convention

After editing workspace files, we created backups:
```
/home/node/.openclaw/workspace/SOUL.md        # Current active file
/home/node/.openclaw/workspace/SOUL.md.bak    # Most recent backup
/home/node/.openclaw/workspace/SOUL.md.bak1   # Older backup
/home/node/.openclaw/workspace/AGENTS.md.bak  # AGENTS.md backup
```

**Tip:** Use dated backups for clarity:
```bash
cp SOUL.md SOUL.md.bak_20260203
```

---

## Multi-Docker Architecture: Other Instances

On our VPS, we found SOUL.md in multiple Docker volumes:

```bash
# Jack1 (DNTM) - RUNNING - Has updated 3.6K version ✅
/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/workspace/SOUL.md

# Jack2 - STOPPED - Has older 1.7K version
/var/lib/docker/volumes/openclaw-jack2_openclaw_config/_data/workspace/SOUL.md

# Jack3 - STOPPED - Has older 1.7K version
/var/lib/docker/volumes/openclaw-jack3_openclaw_config/_data/workspace/SOUL.md

# ABVS - UNKNOWN - Has older 1.7K version
/var/lib/docker/volumes/openclaw-abvs_openclaw_config/_data/workspace/SOUL.md
```

**Note:** Each Docker container has its own volume with separate workspace files.

---

## Summary: The Golden Rules

1. ✅ **Always use workspace folder:** `/home/node/.openclaw/workspace/`
2. ✅ **Use full paths in AGENTS.md** for clarity
3. ✅ **Clear session cache** after updating workspace files
4. ✅ **Verify on disk** vs. what agent reports
5. ✅ **Create backups** before making changes

---

**Related Lessons:**
- `openclaw_session_cache_workspace_files.md` - Why agent doesn't see updated files
- `server_side_editing_workflow.md` - How to edit files safely

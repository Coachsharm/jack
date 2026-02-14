---
name: Brain Restore
description: Upload brain files to an agent's workspace and clear sessions so changes take effect. Trigger with /brain-restore or when updating any agent's brain files.
---

# 🧠 Brain Restore Skill

**Trigger:** `/brain-restore` or any task involving uploading/updating an agent's brain files

## Why This Exists

When you update an agent's brain files (SOUL.md, USER.md, IDENTITY.md, etc.) on the server, the changes **don't take effect immediately**. OpenClaw loads brain files into the system prompt when a **session is created**. Existing sessions keep using the old content until they expire or are cleared.

This skill ensures brain file changes actually reach the agent.

---

## Quick Reference

### Clear Sessions for a Specific Agent
```bash
# Delete the agent's session file (safest, targeted)
ssh jack "rm -f /root/.openclaw/agents/<AGENT_ID>/sessions/sessions.json"

# Then restart the gateway to pick up changes
ssh jack "openclaw gateway restart 2>&1"
```

### Agent Session Files
| Agent | Session File |
|---|---|
| **Jack** (main) | `/root/.openclaw/agents/main/sessions/sessions.json` |
| **Sarah** | `/root/.openclaw/agents/sarah/sessions/sessions.json` |
| **John** | `/root/.openclaw/agents/john/sessions/sessions.json` |
| **Ross** | `/root/.openclaw/agents/ross/sessions/sessions.json` |

> ⚠️ Note: Sessions are at `agents/<id>/sessions/`, NOT `agents/<id>/agent/sessions/`!

### Agent Workspace Directories (where brain files live)
| Agent | Workspace Path |
|---|---|
| **Jack** (main) | `/root/.openclaw/workspace/` |
| **Sarah** | `/root/.openclaw/workspace-sarah/` |
| **John** | `/root/openclaw-clients/john/data/.openclaw/` |
| **Ross** | `/root/openclaw-clients/ross/workspace/` |

---

## Full Procedure: Restore an Agent's Brain

### Step 1: Backup Current State
Always backup before touching anything:
```bash
ssh jack "tar czf /tmp/workspace-<AGENT>-backup-$(date +%Y%m%d_%H%M%S).tar.gz -C /root/.openclaw workspace-<AGENT>"
```

### Step 2: Upload Brain Files
Upload the core brain files from local backup to the agent's workspace:
```powershell
# Core brain files (upload all that exist in backup)
scp "<LOCAL_BACKUP_PATH>\SOUL.md" jack:<WORKSPACE_PATH>/SOUL.md
scp "<LOCAL_BACKUP_PATH>\USER.md" jack:<WORKSPACE_PATH>/USER.md
scp "<LOCAL_BACKUP_PATH>\IDENTITY.md" jack:<WORKSPACE_PATH>/IDENTITY.md
scp "<LOCAL_BACKUP_PATH>\TOOLS.md" jack:<WORKSPACE_PATH>/TOOLS.md
scp "<LOCAL_BACKUP_PATH>\AGENTS.md" jack:<WORKSPACE_PATH>/AGENTS.md
scp "<LOCAL_BACKUP_PATH>\HUMAN_TEXTING_GUIDE.md" jack:<WORKSPACE_PATH>/HUMAN_TEXTING_GUIDE.md
scp "<LOCAL_BACKUP_PATH>\MEMORY.md" jack:<WORKSPACE_PATH>/MEMORY.md
scp "<LOCAL_BACKUP_PATH>\HEARTBEAT.md" jack:<WORKSPACE_PATH>/HEARTBEAT.md
```

### Step 3: Upload Supporting Directories
```bash
# Create directories on server first
ssh jack "mkdir -p <WORKSPACE_PATH>/knowledge <WORKSPACE_PATH>/memory <WORKSPACE_PATH>/lessons <WORKSPACE_PATH>/scripts"

# Then SCP the contents
scp <LOCAL_BACKUP_PATH>\knowledge\* jack:<WORKSPACE_PATH>/knowledge/
scp <LOCAL_BACKUP_PATH>\memory\* jack:<WORKSPACE_PATH>/memory/
scp <LOCAL_BACKUP_PATH>\lessons\* jack:<WORKSPACE_PATH>/lessons/
```

### Step 4: Clear Sessions (CRITICAL)
This is the step that makes changes take effect:
```bash
# Clear the agent's sessions
ssh jack "rm -rf /root/.openclaw/agents/<AGENT_ID>/agent/sessions/*"
```

### Step 5: Restart Gateway
```bash
ssh jack "openclaw gateway restart 2>&1"
```

### Step 6: Verify
```bash
# Check files are on disk with correct sizes
ssh jack "wc -c <WORKSPACE_PATH>/*.md"

# Check gateway is healthy
ssh jack "sleep 5 && openclaw health --json 2>&1 | head -10"

# Message the agent on Telegram to test
```

---

## Key Concepts

### Why clearing sessions matters
- OpenClaw reads workspace files (SOUL.md, USER.md, etc.) when creating a **new session**
- These get baked into the **system prompt** for the LLM
- An existing session keeps the OLD system prompt until it expires
- Clearing sessions forces the next message to create a NEW session with the UPDATED files

### What NOT to do
- ❌ `openclaw reset` — This is a FULL reset (config, credentials, workspace). Way too destructive.
- ❌ Don't delete the entire `agents/<id>/agent/` directory — it contains auth profiles and other config
- ❌ Don't edit brain files locally — always upload to the server (server is source of truth)

### What's safe to delete
- ✅ `agents/<id>/sessions/sessions.json` — the session state file, recreated on next message
- ⚠️ NOT `agents/<id>/agent/sessions/` — that's a different (often empty) directory

---

## Local Backup Locations
Brain file backups are stored at:
- `c:\Users\hisha\Code\Jack\backup 13 feb\sarah\workspace-sarah\` — Sarah's Feb 13 backup
- `c:\Users\hisha\Code\Jack\backup 13 feb\jack\workspace\` — Jack's Feb 13 backup
- `c:\Users\hisha\Code\Jack\server_workspace_sync\` — Latest server workspace mirror

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Agent still shows old brain content | Clear sessions + restart gateway |
| Files uploaded but wrong size | Re-upload, check for encoding issues (UTF-16 vs UTF-8) |
| Agent not responding at all | Check Telegram binding: `agentId` must match in `openclaw.json` |
| Gateway won't restart | Check logs: `ssh jack "journalctl -u openclaw-gateway -n 50"` |

---

**Last verified:** 2026-02-14

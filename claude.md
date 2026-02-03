# PROMPT: OPERATIONAL DIRECTIVE FOR CLAUDE (ANTHROPIC) MODELS

## ⚠️ CRITICAL: OPENCLAW IS NOT IN YOUR TRAINING DATA
**OPENCLAW.AI JUST LAUNCHED A FEW DAYS AGO.**
**YOU WERE NOT TRAINED ON IT. YOU KNOW NOTHING ABOUT IT.**
**DO NOT HALLUCINATE. DO NOT GUESS.**

### MANDATORY RESEARCH PROTOCOL:
Before making ANY plan or taking ANY action related to OpenClaw/Jack:

1. **CHECK LOCAL DOCS FIRST**: Check `OpenClaw_Docs/LAST_UPDATED.txt`. If >1 day old, ask user to refresh via `node .agent/skills/sync_docs/sync.js`, then use local files.
2. **SEARCH FOR SOLUTIONS**: Look at GitHub issues, community forums, Discord, Reddit
3. **VERIFY YOUR UNDERSTANDING**: Cross-reference multiple sources
4. **ASK IF UNCERTAIN**: If documentation is unclear, ask the user before proceeding

**FAILURE TO FOLLOW THIS WILL RESULT IN BROKEN CONFIGURATIONS AND WASTED TIME.**

---

## 🔄 SYNCHRONIZATION NOTICE
**YOU ARE CLAUDE (ANTHROPIC LLM).**
**YOUR TWIN BRAIN IS GEMINI (GOOGLE ANTIGRAVITY) - SEE `Gemini.md`.**
**THESE INSTRUCTION FILES MUST REMAIN SYNCHRONIZED.**
**THE USER ROTATES BETWEEN CLAUDE AND GEMINI - WE SHARE THE SAME MEMORY.**

---

## 🔴 ZERO-TOLERANCE PROTOCOL: SERVER-ONLY
**YOU ARE FORBIDDEN FROM WORKING LOCALLY.**
**THE LOCAL FILESYSTEM IS A READ-ONLY ARCHIVE.**
**ALL ACTIONS MUST BE PERFORMED ON THE VPS (SRV1304133).**

---

### 1. IDENTITY & CONTEXT
You are working on **Jack**, an OpenClaw bot hosted on a **Hostinger VPS** (IP: 72.62.252.124).
- **SSH User**: root
- **Docker Container**: `openclaw-dntm-openclaw-1`
- **Config Path (Server)**: `/home/node/.openclaw/openclaw.json`

### 2. THE LOCAL TRAP
You will see a folder called `remote_files_preview`.
- **IT IS A TRAP.**
- It contains outdated, read-only copies of files.
- **NEVER** edit files in `remote_files_preview`.
- **NEVER** run `npm install` or `node` locally.
- **NEVER** trust local file contents over server truth.

### 3. MANDATORY WORKFLOW
When the user asks you to change something (e.g., "Add a new skill"):
1. **CONNECT**: `ssh root@72.62.252.124`
2. **VERIFY**: Read the file on the server using `docker exec ... cat ...`
3. **PROPOSE**: Show the user the exact change you will make.
4. **EXECUTE**: Use `docker exec` (sed/echo) or `docker cp` to apply the change.
5. **CONFIRM**: Restart the container and check logs.

### 4. SECRET KNOWLEDGE
- **Workflows**: Check `.agent/workflows/jack_server_workflow.md`.
- **Secrets**: Check `secrets/config.json` (Local is okay for *reading* secrets).
- **Docs**: Always refer to `docs.openclaw.ai`.

### 5. IF YOU WAKE UP TOMORROW (SIMULATION)
If the user says "Hi", your first thought must be:
> *"I am on a local machine, but the bot is on 72.62.252.124. I must not touch anything here. I must SSH into the server immediately."*

---

## 🛡️ RULE ZERO: UNIVERSAL BACKUP PROTOCOL

**Before editing ANY file (Safe Zone or Restricted Zone), you MUST maintain a rotating backup history of the last 2 versions.**

### Backup Procedure:
1. **Check** for existing backups
2. **Rotate**: Move `.bak1` to `.bak2` (overwriting old `.bak2`)
3. **Backup**: Copy current file to `.bak1`
4. **Only then** edit the original file

### Command Template (Server/Linux):
```bash
# Example for openclaw.json on server
ssh root@72.62.252.124 << 'EOF'
docker exec openclaw-dntm-openclaw-1 sh -c '
  cd /home/node/.openclaw
  mv openclaw.json.bak1 openclaw.json.bak2 2>/dev/null || true
  cp openclaw.json openclaw.json.bak1
'
EOF
# Now proceed with edit...
```

### Command Template (Local/Windows - if ever needed):
```powershell
# Example for local file (rare case)
Move-Item -Path "file.bak1" -Destination "file.bak2" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "file" -Destination "file.bak1"
# Now proceed with edit...
```

---

## 📁 FILE SYSTEM ACCESS RULES

You are categorized as a **Trusted Configuration Assistant**. You have different levels of access:

### ✅ SAFE ZONE (Autonomous Edit Allowed)
You can read and modify these files freely (always following the Backup Protocol):

- `openclaw.json` (Configuration)
- `SOUL.md` (Personality/Identity)
- `Gemini.md` (Gemini's Core Instructions/Memory)
- `claude.md` (Your Core Instructions/Memory - THIS FILE)
- `TOOLS.md` (Tool Usage Notes)
- `USER.md` (User Context)
- `workspace/` directory (All user documents, code, and output)

### ⚠️ RESTRICTED ZONE (Edit ONLY When User Provides Data)
You can edit these files, but **ONLY** when the user explicitly provides the exact content (API keys, tokens, config values):

- `.env` (API Keys & Secrets)
- `credentials/` folder (Auth Tokens)
- `docker-compose.yml` (Infrastructure config)

**Handling Rules for Restricted Zone:**
1. **Never guess** placeholder values or generate fake keys
2. **Strict Backup**: Apply the Universal Backup Protocol (2 versions) first
3. **Confirmation**: Confirm the exact content you will write before executing
4. **Exact Match**: Only write exactly what the user gives you—no additions, no modifications

### 🚫 FORBIDDEN ZONE (Do Not Touch)
**NEVER** edit or modify these:

- `state/` folder (Internal database - system managed only)
- `packages/` or `src/` (Internal source code)

---

## 🔄 SYNCHRONIZATION PROTOCOL

**CRITICAL**: When you (Claude) or Gemini update these instruction files, BOTH files must be kept in sync:

1. **Core protocols** (Backup, File Access Rules) must be identical
2. **Identity sections** should reference the correct LLM name
3. **Synchronization notices** must point to the twin file
4. **When updating**: Always update BOTH `claude.md` AND `Gemini.md`

---

**DO NOT VIOLATE THIS PROTOCOL.**
**FAILURE TO FOLLOW SERVER-ONLY RULES WILL BREAK THE PRODUCTION BOT.**
**FAILURE TO MAINTAIN BACKUPS WILL CAUSE DATA LOSS.**

# PROMPT: OPERATIONAL DIRECTIVE FOR ANTIGRAVITY (GOOGLE DEEPMIND) MODELS

## ⚠️ CRITICAL: OPENCLAW IS NOT IN YOUR TRAINING DATA
**OPENCLAW.AI JUST LAUNCHED A FEW DAYS AGO.**
**YOU WERE NOT TRAINED ON IT. YOU KNOW NOTHING ABOUT IT.**
**DO NOT HALLUCINATE. DO NOT GUESS.**

### MANDATORY RESEARCH PROTOCOL:
Before making ANY plan or taking ANY action related to OpenClaw/Jack:

1. **READ LOCAL DOCS FIRST**: The documentation is already downloaded in `OpenClaw_Docs/`.
   - **YOU MUST READ THESE FILES FIRST.** They are the source of truth.
   - Do not assume external docs are up to date or that you know the answer.

2. **ENGINEER-LEVEL SEARCH STRATEGY** (If local docs are insufficient):
   - **GitHub Issues**: Search with `is:issue is:closed` to find solved problems.
   - **r/LocalLLaMA**: Search this specific subreddit for Docker/inference config issues.
   - **Hacker News**: Query `site:news.ycombinator.com "OpenClaw"` for technical workarounds.
   - **Twitter/X**: Search for "OpenClaw independent developers" or specific engineering discussions (filter by Latest).

3. **VERIFY YOUR UNDERSTANDING**: Cross-reference strictly with the local documentation.
4. **ASK IF UNCERTAIN**: If local documentation is unclear, ask the user before proceeding.

**FAILURE TO FOLLOW THIS WILL RESULT IN BROKEN CONFIGURATIONS AND WASTED TIME.**

---

## 🔄 SYNCHRONIZATION NOTICE
**YOU ARE GEMINI (GOOGLE ANTIGRAVITY LLM).**
**YOUR TWIN BRAIN IS CLAUDE (ANTHROPIC) - SEE `claude.md`.**
**THESE INSTRUCTION FILES MUST REMAIN SYNCHRONIZED.**
**THE USER ROTATES BETWEEN CLAUDE AND GEMINI - WE SHARE THE SAME MEMORY.**

---

## 🔴 ZERO-TOLERANCE PROTOCOL: SERVER-ONLY
**YOU ARE FORBIDDEN FROM WORKING LOCALLY.**
**THE LOCAL FILESYSTEM IS A READ-ONLY ARCHIVE.**
**ALL ACTIONS MUST BE PERFORMED ON THE VPS (SRV1304133).**

---

### 1. IDENTITY & CONTEXT
You are working on **Jack**, an OpenClaw bot hosted on a **Hostinger VPS** (IP: [SERVER_IP]).
- **SSH User**: root
- **SSH Key**: `secrets/jack_vps` (passwordless)
- **Docker Container**: `openclaw-dntm-openclaw-1`
- **Config Path (Server)**: `/home/node/.openclaw/openclaw.json`

**⚠️ CRITICAL: JACK'S ISOLATION**
**Jack (the OpenClaw bot on the server) CANNOT access you (Gemini/Claude development agents).**
**Jack runs in isolation on the VPS and has no knowledge of or connection to this local development environment.**
**You (Gemini/Claude) can access Jack's server to configure him, but Jack cannot access you.**

### 2. THE LOCAL TRAP
You will see a folder called `remote_files_preview`.
- **IT IS A TRAP.**
- It contains outdated, read-only copies of files.
- **NEVER** edit files in `remote_files_preview`.
- **NEVER** run `npm install` or `node` locally.
- **NEVER** trust local file contents over server truth.

### 3. MANDATORY WORKFLOW
When the user asks you to change something (e.g., "Add a new skill"):
1. **CONNECT**: `ssh -i secrets/jack_vps root@[SERVER_IP]`
2. **VERIFY**: Read the file on the server using `docker exec ... cat ...`
3. **PROPOSE**: Show the user the exact change you will make.
4. **EXECUTE**: Use `docker exec` (sed/echo) or `docker cp` to apply the change.
5. **CONFIRM**: Restart the container and check logs.

### 4. DEPLOYMENT WORKFLOW - CRITICAL
**⚠️ A TASK IS NOT COMPLETE UNTIL FILES ARE ON THE SERVER AT THE CORRECT LOCATION.**

**USER PREFERENCE: EDIT FILES DIRECTLY ON SERVER (BEST METHOD)**

The user prefers server-side editing over file transfers. When possible:
```bash
# SSH to server and edit directly
ssh -i secrets/jack_vps root@[SERVER_IP]
docker exec -it openclaw-dntm-openclaw-1 nano /home/node/.openclaw/workspace/file.md

# OR edit via volume path on host
nano /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/workspace/file.md
```

**ALTERNATIVE (if server-side edit not possible):**
When editing Jack's files (SOUL.md, protocols, configs):
1. **Edit locally first** (in `c:\Users\hisha\Code\Jack\`)
2. **Upload to server** using `pscp` or `docker cp`:
   ```powershell
   # Upload to /tmp first
   pscp -pw "PASSWORD" -batch .\file.md root@[SERVER_IP]:/tmp/upload.md
   
   # Then docker cp to correct location
   plink -ssh -pw "PASSWORD" root@[SERVER_IP] -batch "docker cp /tmp/upload.md openclaw-dntm-openclaw-1:/home/node/.openclaw/workspace/file.md"
   ```
3. **Verify on server**: Check the file exists at the correct path inside the container
4. **Only then** consider the task complete

**Common Jack file locations (inside container):**
- **Custom Instructions (per OpenClaw docs - in workspace):**
  - SOUL.md: `/home/node/.openclaw/workspace/SOUL.md` (guidelines & transparency)
  - IDENTITY.md: `/home/node/.openclaw/workspace/IDENTITY.md` (identity & metadata)
  - USER.md: `/home/node/.openclaw/workspace/USER.md` (user preferences)
- **Other workspace files:**
  - Protocols: `/home/node/.openclaw/workspace/` (Gemini.md, claude.md, etc)
- **Config:** `/home/node/.openclaw/openclaw.json` (root .openclaw, NOT workspace)

### 5. SESSION CACHE REFRESH PROTOCOL
**⚠️ MANDATORY AFTER WORKSPACE FILE UPDATES**

When you update workspace files (AGENTS.md, SOUL.md, TOOLS.md, etc.), Jack caches the session context.
Even after file updates, Jack may recite old information due to **Session Caching** in the gateway.

**The Force Reset Protocol:**
```bash
# Step 1: Purge session cache
plink -ssh -pw "[VPS_PASSWORD]" root@[SERVER_IP] "docker exec openclaw-dntm-openclaw-1 rm -rf /home/node/.openclaw/agents/main/sessions/*"

# Step 2: Restart container
plink -ssh -pw "[VPS_PASSWORD]" root@[SERVER_IP] "docker restart openclaw-dntm-openclaw-1"

# Step 3: (User) Start new Telegram chat with Jack to see changes
```

**When to Apply:**
- After uploading AGENTS.md, SOUL.md, TOOLS.md, or any workspace instruction file
- When Jack responds with outdated information despite file updates
- After any significant configuration change

**Verification:**
Ask Jack to confirm specific details from the updated files (e.g., "What tools do you have access to?")

### 6. SECRET KNOWLEDGE
- **Workflows**: Check `.agent/workflows/jack_server_workflow.md`.
- **Secrets**: Check `secrets/config.json` (Local is okay for *reading* secrets).
- **Docs**: Always refer to `docs.openclaw.ai`.

### 7. IF YOU WAKE UP TOMORROW (SIMULATION)
If the user says "Hi", your first thought must be:
> *"I am on a local machine, but the bot is on [SERVER_IP]. I must not touch anything here. I must SSH into the server immediately."*

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
ssh -i secrets/jack_vps root@[SERVER_IP] << 'EOF'
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
- `Gemini.md` (Your Core Instructions/Memory - THIS FILE)
- `claude.md` (Claude's Core Instructions/Memory)
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

**CRITICAL**: When you (Gemini) or Claude update these instruction files, BOTH files must be kept in sync:

1. **Core protocols** (Backup, File Access Rules) must be identical
2. **Identity sections** should reference the correct LLM name
3. **Synchronization notices** must point to the twin file
4. **When updating**: Always update BOTH `Gemini.md` AND `claude.md`

---

**DO NOT VIOLATE THIS PROTOCOL.**
**FAILURE TO FOLLOW SERVER-ONLY RULES WILL BREAK THE PRODUCTION BOT.**
**FAILURE TO MAINTAIN BACKUPS WILL CAUSE DATA LOSS.**

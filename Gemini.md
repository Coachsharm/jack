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
```

---

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

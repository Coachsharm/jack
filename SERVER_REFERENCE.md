# Jack (OpenClaw) Server Reference

**Last Updated**: 2026-02-07  
**Server IP**: 72.62.252.124  
**Server User**: root  
**Server Password**: `<REDACTED>`

---

## Critical: Server is Source of Truth

All Jack development happens on the **SERVER** at `/root/.openclaw/`. Local repository is for documentation and credentials storage only.

When asked to work on "Jack", this means:
1. SSH into the server
2. Work in `/root/.openclaw/workspace`
3. Never edit local files (except this reference doc)

---

## Server Configuration

### OpenClaw Installation
- **Location**: `/root/.openclaw/`
- **Config File**: `/root/.openclaw/openclaw.json`
- **Version**: 2026.2.3-1 (last touched: 2026-02-07T12:15:01.077Z)
- **Workspace**: `/root/.openclaw/workspace`

### Current LLM Configuration
- **Primary Model**: `anthropic/claude-opus-4-6`
- **Fallbacks**: `anthropic/claude-sonnet-4-5`, `anthropic/claude-haiku-4`
- **Auth Providers**: 
  - Google Antigravity OAuth (faithinmotion88@gmail.com)
  - Anthropic (manual token)

---

## John (Production Template for Customer Bots)

**Purpose**: Secure, replicable template for selling AI bots to customers. Heavy security restrictions.

### Current Configuration
- **Primary LLM**: google-antigravity/gemini-3-flash (currently - **LLM is flexible per customer**)
- **Secondary Models**: openrouter/openai/gpt-4o-mini
- **Running As**: User 101000
- **Process IDs**: 429277 (openclaw), 429316 (openclaw-gateway)

### Telegram Bot (John)
- **Bot Token**: `<REDACTED>`
- **DM Policy**: Pairing required
- **Group Policy**: Open

### Security Configuration (The Template)
This is what makes John suitable for customers:
- **Sandbox Mode**: `all` (full sandboxing)
- **Workspace Access**: Read/Write
- **Docker Security**: Read-only root filesystem, all capabilities dropped
- **Exec Security**: Allowlist-only
- **Safe Bins**: ls, cat, echo, date, pwd, whoami, find, grep, wc, head, tail
- **Exec Ask Mode**: on-miss (asks permission for unknown commands)

### Gateway
- **Port**: 18789
- **Auth Token**: `<REDACTED>`
- **Mode**: Local

### WhatsApp
- Configuration exists (QR codes in backups)
- Status: Check server for current state

### Key Design Principles
1. **Security First**: Maximum sandboxing prevents customer misuse
2. **Flexible LLM**: Can swap models based on customer tier/budget
3. **Replicable**: Configuration can be cloned for each new customer
4. **Cost-Effective**: Currently using Gemini Flash (cheap inference)

### John vs Jack Summary

| Feature | Jack (Personal) | John (Customer Template) |
|---------|----------------|--------------------------|
| **Purpose** | Personal assistant | Customer bot template |
| **LLM** | Claude Opus 4-6 | Gemini Flash (flexible) |
| **Security** | Standard | Maximum (full sandbox) |
| **Running As** | root | User 101000 |
| **Restrictions** | Minimal | Allowlist + on-miss |
| **Cost** | Premium | Budget-friendly |

---

### Ollama Local Models
All running on `http://localhost:11434`:
- Hermes 3 (8B)
- Phi-3 (3.8B)
- Llama 3.2 (3B)
- Qwen 2.5 Coder (3B)
- Dolphin Llama 3 (8B)
- DeepSeek R1 (7B)
- Qwen 2.5 (7B)

---

## Channels & Bots

### Telegram Bot (@thrive2bot)
- **Status**: Enabled
- **Token**: `<REDACTED>`
- **DM Policy**: Pairing required
- **Group Policy**: Open (no mention required)
- **Stream Mode**: Partial

### WhatsApp
- **Status**: Enabled
- **DM Policy**: Allowlist only
- **Allowed Numbers**: +6588626460, +6591090995
- **Self Chat**: Enabled
- **Media Limit**: 50 MB

---

## Server Directory Structure

```
/root/.openclaw/
├── openclaw.json              # Main configuration file
├── workspace/                 # Working directory for files
│   ├── BOOTSTRAP.md          # Initial setup guide
│   ├── PROTOCOLS_INDEX.md    # Protocol documentation index
│   ├── TEAM_CHAT.md          # Team chat instructions
│   ├── BOT_CHAT_PROTOCOL.md  # Bot communication protocol
│   ├── AGENTS_updated.md     # Agent configuration
│   ├── createbots/           # Bot creation guides
│   │   ├── LESSON_*.md       # Server-side lessons
│   │   └── DEPLOYMENT_*.md   # Deployment documentation
│   └── tracking/             # Tracking and monitoring
├── credentials/              # API keys and tokens
├── devices/                  # Paired devices
├── telegram/                 # Telegram channel data
├── cron/                     # Scheduled jobs
└── backups/                  # Configuration backups
```

---

## Key Server Files

### Configuration
- `/root/.openclaw/openclaw.json` - Main config (2026.2.3-1)

### Documentation
- `/root/.openclaw/workspace/BOOTSTRAP.md` - Initial onboarding
- `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` - Task guidance
- `/root/.openclaw/workspace/TEAM_CHAT.md` - Chat instructions
- `/root/.openclaw/workspace/BOT_CHAT_PROTOCOL.md` - Bot protocols

### Lessons (Server-Side)
- `/root/.openclaw/workspace/createbots/LESSON_Security_Testing.md`
- `/root/.openclaw/workspace/createbots/LESSON_Docker_Security.md`
- More lessons available in `createbots/` directory

---

## API Keys

### OpenClaw
- **API Key**: `<REDACTED>`

### OpenRouter
- **API Key**: `<REDACTED>`

### OpenAI
- **API Key**: `<REDACTED>`

### Anthropic
- **API Key**: `<REDACTED>`

### DeepSeek
- **API Key**: `<REDACTED>`

### Brave Search
- **API Key**: `<REDACTED>`

---

## Gateway Configuration

- **Port**: 18789
- **Mode**: Local
- **Bind**: Loopback only
- **Auth**: Token-based
- **Token**: `<REDACTED>`

---

## SSH Access Template

```bash
# Quick login
sshpass -p '<REDACTED>' ssh -o StrictHostKeyChecking=no root@72.62.252.124

# Or interactive
ssh root@72.62.252.124
# Password: <REDACTED>
```

---

## Workflow Reminders

1. **Server-First**: All Jack work happens on the server
2. **Docs Priority**: Check `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` before any task
3. **Backup**: Always backup config before changes (see server protocols)
4. **Never Commit Secrets**: API keys stay in this local reference only
5. **OpenClaw Docs**: Refer to local `/Users/coachsharm/Code/Jack/OpenClaw_Docs/` for offline reference

---

## VPS Hardware

- **Location**: Malaysia, Kuala Lumpur
- **OS**: Ubuntu 24.04 LTS
- **Hostname**: srv1304133.hstgr.cloud
- **CPU**: 2 cores
- **RAM**: 8 GB
- **Disk**: 100 GB

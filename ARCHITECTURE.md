# Thrive Works OpenClaw Architecture
**Last Updated:** 2026-02-13  
**Status:** PRODUCTION — Unified Gateway (Post-Docker Migration)

---

## 🏗️ Current Architecture: Unified Multi-Agent Gateway

### Overview
All agents (Jack, Ross, Sarah, John) now run as **native multi-agent instances** under a **single OpenClaw gateway**. There are **NO Docker containers** for any agents.

```
┌─────────────────────────────────────────────────────────────┐
│                    Single OpenClaw Gateway                   │
│                   (systemd service: openclaw)                │
│                     PID: 1728639 (native)                    │
│                  ws://72.62.252.124:18789                    │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
   ┌──────────┐        ┌──────────┐        ┌──────────┐
   │   Jack   │        │   Ross   │        │  Sarah   │
   │  (main)  │        │  (ross)  │        │ (sarah)  │
   │ DEFAULT  │        │  AGENT   │        │  AGENT   │
   └──────────┘        └──────────┘        └──────────┘
                              │
                              ▼
                       ┌──────────┐
                       │   John   │
                       │  (john)  │
                       │  AGENT   │
                       └──────────┘
```

### Key Facts

| Aspect | Details |
|--------|---------|
| **Gateway Process** | Single native Node.js process (systemd managed) |
| **Total Agents** | 4 (Jack, Ross, Sarah, John) |
| **Docker Usage** | **NONE** — All Docker containers stopped and archived |
| **Config File** | `/root/.openclaw/openclaw.json` (single shared config) |
| **Gateway Version** | 2026.2.12 |
| **Service Management** | `systemctl status openclaw` |
| **WebSocket Endpoint** | `ws://72.62.252.124:18789` |

---

## 📁 Agent Workspaces

Each agent has its own isolated workspace directory:

| Agent | Agent ID | Workspace Path | Default Model |
|-------|----------|----------------|---------------|
| **Jack** | `main` | `/root/.openclaw/workspace` | `google-antigravity/claude-opus-4-6` |
| **Ross** | `ross` | `/root/.openclaw/workspace-ross` | `google-antigravity/gemini-3-flash` |
| **Sarah** | `sarah` | `/root/.openclaw/workspace-sarah` | `google-antigravity/gemini-3-flash` |
| **John** | `john` | `/root/.openclaw/workspace-john` | `google-antigravity/gemini-3-flash` |

### Workspace Contents
Each workspace contains:
- `SOUL.md` — Agent personality and behavior
- `AGENTS.md` — Multi-agent collaboration rules
- `USER.md` — User preferences and context
- `IDENTITY.md` — Agent identity and role
- `HEARTBEAT.md` — Periodic autonomous task definitions
- `HUMAN_TEXTING_GUIDE.md` — Communication style guide
- `lessons/` — Agent-specific learned knowledge
- `skills/` — Agent-specific skills and tools

---

## 🔧 Configuration Architecture

### Single Shared Config (`/root/.openclaw/openclaw.json`)

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "google-antigravity/claude-opus-4-6"
      }
    },
    "list": [
      {
        "id": "main",
        "default": true,
        "workspace": "/root/.openclaw/workspace",
        "heartbeat": {
          "every": "2m",
          "prompt": "Check HEARTBEAT.md and execute."
        }
      },
      {
        "id": "ross",
        "workspace": "/root/.openclaw/workspace-ross",
        "model": {
          "primary": "google-antigravity/gemini-3-flash"
        },
        "heartbeat": { "every": "2m" }
      },
      {
        "id": "sarah",
        "workspace": "/root/.openclaw/workspace-sarah",
        "model": {
          "primary": "google-antigravity/gemini-3-flash"
        },
        "heartbeat": { "every": "2m" }
      },
      {
        "id": "john",
        "workspace": "/root/.openclaw/workspace-john",
        "model": {
          "primary": "google-antigravity/gemini-3-flash"
        },
        "heartbeat": { "every": "2m" }
      }
    ]
  },
  "auth": {
    "order": {
      "google-antigravity": [
        "google-antigravity:faithinmotion88@gmail.com",
        "google-antigravity:gurufitness@gmail.com"
      ],
      "openai-codex": ["openai-codex:hisham.musa@gmail.com"]
    }
  },
  "channels": {
    "telegram": {
      "botToken": "***",
      "username": "@thrive2bot"
    },
    "whatsapp": {
      "number": "+6588626460"
    }
  }
}
```

### Auth Profiles (Shared Across All Agents)

All agents share the same authentication profiles:

1. **Primary AG:** `faithinmotion88@gmail.com` (Google Antigravity OAuth)
2. **Fallback AG:** `gurufitness@gmail.com` (Google Antigravity OAuth)
3. **Codex:** `hisham.musa@gmail.com` (OpenAI Codex OAuth)
4. **OpenRouter:** API Key (shared)

**Automatic Failover:** If `faithinmotion88` hits rate limits, the gateway automatically fails over to `gurufitness` for Claude/Gemini models.

---

## 🛣️ Message Routing

### How Messages Reach Agents

Messages are routed via `bindings` in the config:

```json
{
  "bindings": [
    {
      "agentId": "main",
      "match": { "channel": "telegram" }
    },
    {
      "agentId": "main",
      "match": { "channel": "whatsapp" }
    }
  ]
}
```

- **Default Agent:** Jack (`main`) receives all messages unless explicitly routed
- **Manual Routing:** Users can explicitly address agents (planned feature)
- **Channel Binding:** All Telegram/WhatsApp messages currently go to Jack

---

## 🔄 Session & State Management

### Session Storage (Per-Agent)

Each agent has its own session store:

```
/root/.openclaw/agents/main/sessions/          # Jack's sessions
/root/.openclaw/agents/ross/sessions/          # Ross's sessions
/root/.openclaw/agents/sarah/sessions/         # Sarah's sessions
/root/.openclaw/agents/john/sessions/          # John's sessions
```

**Session Cleanup:** Automated cron task runs every 6 hours to archive old/large sessions.

### Auth Profiles (Per-Agent)

Each agent has its own auth profile storage:

```
/root/.openclaw/agents/main/agent/auth-profiles.json
/root/.openclaw/agents/ross/agent/auth-profiles.json
/root/.openclaw/agents/sarah/agent/auth-profiles.json
/root/.openclaw/agents/john/agent/auth-profiles.json
```

---

## ⚡ Heartbeat System

All agents run heartbeats every **2 minutes** that execute tasks defined in their `HEARTBEAT.md` files.

### Current Heartbeat Configurations

| Agent | Interval | Heartbeat File |
|-------|----------|----------------|
| Jack | 2m | `/root/.openclaw/workspace/HEARTBEAT.md` |
| Ross | 2m | `/root/.openclaw/workspace-ross/HEARTBEAT.md` |
| Sarah | 2m | `/root/.openclaw/workspace-sarah/HEARTBEAT.md` |
| John | 2m | `/root/.openclaw/workspace-john/HEARTBEAT.md` |

**Example Heartbeat Tasks:**
- Monitor server health
- Check for stuck processes
- Update dashboards
- Run scheduled backups
- Send status reports

---

## 📡 Communication Channels

### Telegram
- **Bot:** `@thrive2bot`
- **Token:** Configured in gateway
- **Default Agent:** Jack (main)
- **Status:** ✅ Active

### WhatsApp
- **Number:** `+6588626460`
- **Connection:** QR code scan (linked)
- **Default Agent:** Jack (main)
- **Status:** ✅ Linked

### TEAM_CHAT (Inter-Agent)
- **Location:** `/root/.gemini/antigravity/team_chat/TEAM_CHAT.md`
- **Protocol:** All agents write messages to shared file
- **Polling:** Every 30 seconds
- **Deduplication:** Hash-based to prevent re-reading own messages

---

## 🗄️ Backup & Recovery

### Backup Strategy
1. **Rule Zero:** Always keep 2 versions of critical files
2. **Pre-Edit Backups:** `.bak` files created before modifications
3. **Config Snapshots:** Timestamped backups in `/root/.openclaw/backups/`
4. **Session Exports:** Automated archival of old sessions

### Critical Backup Locations
```
/root/.openclaw/openclaw.json.bak.*
/root/.openclaw/backups/
/root/.openclaw/workspace/.bak/
```

---

## 🚫 What Was Removed (Docker Migration)

### Docker Containers (STOPPED & ARCHIVED)
- ❌ `openclaw-ross` (Docker container) → Now native agent `ross`
- ❌ `openclaw-sarah` (Docker container) → Now native agent `sarah`
- ❌ `openclaw-john` (Docker container) → Now native agent `john`
- ❌ `/root/openclaw-clients/` (Docker mount directories)

### Old File Paths (NO LONGER VALID)
```
❌ /var/lib/docker/volumes/openclaw-ros_config/_data/
❌ /root/openclaw-clients/ross/workspace/
❌ /root/openclaw-clients/sarah/workspace/
❌ /root/openclaw-clients/john/workspace/
❌ docker exec openclaw-ross openclaw status
```

### New Correct Paths
```
✅ /root/.openclaw/workspace-ross/
✅ /root/.openclaw/workspace-sarah/
✅ /root/.openclaw/workspace-john/
✅ openclaw status (runs on native gateway)
```

---

## 🔧 System Management Commands

### Gateway Control
```bash
# Check gateway status
systemctl status openclaw

# Restart gateway (applies config changes)
systemctl restart openclaw

# View gateway logs
journalctl -u openclaw -f

# Check gateway process
ps aux | grep 'openclaw gateway'
```

### Agent Management
```bash
# List all agents
openclaw agents list

# Add new agent
openclaw agents add <agentId> --workspace ~/.openclaw/workspace-<agentId>

# View agent config
openclaw config get agents.list

# Check usage/status
openclaw status --usage
```

### Health Monitoring
```bash
# Full health check
openclaw health

# Quick status
openclaw status

# Model usage
openclaw status --usage
```

---

## 📊 Monitoring & Dashboard

### Live Dashboard
- **URL:** http://sites.thriveworks.tech/dashboard/
- **Update Script:** `/root/.openclaw/workspace/scripts/update_dashboard_json.py`
- **Cron:** Runs every 2 minutes
- **Data Source:** `openclaw status --usage` (native gateway)

### Dashboard Shows:
- ✅ All 4 agents with live status
- ✅ Gateway version and uptime
- ✅ Model usage (Claude, Gemini, Codex)
- ✅ Channel status (Telegram, WhatsApp)
- ✅ Brain capacity (workspace file sizes)
- ✅ Session counts per agent

---

## 🎯 Agent Roles & Responsibilities

### Jack (`main`) — Primary Assistant
- **Model:** Claude Opus 4.6
- **Role:** General assistant, conversation lead, decision-maker
- **Sessions:** Highest activity (~225 active)
- **Priority:** Default for all incoming messages

### Ross (`ross`) — DevOps & Monitoring
- **Model:** Gemini 3 Flash
- **Role:** Server monitoring, health checks, system alerts
- **Heartbeat Focus:** Infrastructure monitoring
- **Specialization:** Diagnostics, log analysis

### Sarah (`sarah`) — Coach Assistant
- **Model:** Gemini 3 Flash
- **Role:** Fitness coaching, client communication
- **Communication:** Addresses user as "Coach"
- **Specialization:** Fitness, nutrition, business coaching

### John (`john`) — Security Specialist
- **Model:** Gemini 3 Flash
- **Role:** Security monitoring, threat detection
- **Focus:** System hardening, permission audits
- **Specialization:** Security analysis, vulnerability scanning

---

## ⚠️ Important Agent Guidelines

### For All Agents:
1. **You are NOT in Docker** — You run natively under the shared gateway
2. **Shared config** — All agents use `/root/.openclaw/openclaw.json`
3. **Shared auth** — All agents use the same Google Antigravity accounts
4. **Own workspace** — Your files are in `/root/.openclaw/workspace-<agentId>/`
5. **Own sessions** — Your chat history is in `/root/.openclaw/agents/<agentId>/sessions/`
6. **Heartbeat autonomy** — You can execute tasks every 2 minutes via HEARTBEAT.md
7. **Inter-agent comm** — Use TEAM_CHAT.md to communicate with other agents

### What Changed (Feb 13, 2026):
- ✅ **Migrated** from multi-Docker setup to unified gateway
- ✅ **Consolidated** auth profiles (reduced ban risk)
- ✅ **Enabled** heartbeats for Ross, Sarah, John
- ✅ **Copied** all workspace files from Docker volumes to native paths
- ✅ **Stopped** all Docker containers (no longer needed)
- ✅ **Updated** dashboard to show unified gateway architecture

---

## 📚 Documentation References

### For Agents to Read:
- `/root/.openclaw/workspace/ARCHITECTURE.md` (this file) — Master reference
- `/root/.openclaw/workspace/TEAM_CHAT.md` — Inter-agent communication
- `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` — Workflow protocols
- `/root/.openclaw/workspace/AGENTS.md` — Multi-agent collaboration rules

### For System Admin:
- `/root/.openclaw/openclaw.json` — Gateway configuration
- `https://docs.openclaw.ai/concepts/multi-agent` — Official docs
- `/root/.openclaw/workspace/lessons/` — Historical lessons (some outdated)

---

## 🔄 Migration Timeline

| Date | Event |
|------|-------|
| **2026-02-10** | Ross Docker container issues identified |
| **2026-02-12** | Decision made to consolidate to unified gateway |
| **2026-02-13 AM** | Multi-agent migration completed |
| **2026-02-13 PM** | Dashboard revamped, Docker containers stopped |

---

## ✅ System Health (Current)

```
✅ Gateway: Running (v2026.2.12)
✅ Agents: 4 active (Jack, Ross, Sarah, John)
✅ Channels: Telegram + WhatsApp linked
✅ Auth: 2 Google AG accounts + Codex
✅ Heartbeats: All enabled (2m interval)
✅ Sessions: 228 total across agents
✅ Dashboard: Live and updated
```

---

**For Questions:** Consult this file first. For inter-agent coordination, use TEAM_CHAT.md.

---
name: Brain Files Reference
description: List all brain files, their purpose, locations, boot sequence, and security boundaries. Trigger with /brainfiles or /brain.
---

# 🧠 Brain Files Reference

**Trigger:** `/brainfiles` or `/brain`

## What Are Brain Files?

Brain files are the markdown files that define an OpenClaw agent's identity, knowledge, and behavior. Together they form the agent's **brain** — the complete context that shapes who the agent is and how it operates.

---

## Core Brain Files

| Brain File | Purpose | Server Path |
|---|---|---|
| **`SOUL.md`** | Core identity, personality, values, boundaries, vibe | `/root/.openclaw/workspace/SOUL.md` |
| **`USER.md`** | Knowledge about Coach (name, preferences, contact, background) | `/root/.openclaw/workspace/USER.md` |
| **`TOOLS.md`** | Available tools, auth rules, troubleshooting protocol, server ops | `/root/.openclaw/workspace/TOOLS.md` |
| **`AGENTS.md`** | Workspace rules, safety protocols, session boot order, config safety | `/root/.openclaw/workspace/AGENTS.md` |
| **`IDENTITY.md`** | Name, bot handle, creature type, gender, avatar, emoji | `/root/.openclaw/workspace/IDENTITY.md` |
| **`PROTOCOLS_INDEX.md`** | Task-specific guidance (config edits, skills, troubleshooting, research) | `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` |

---

## Boot Sequence (from AGENTS.md)

Every session, Jack reads these in order:
1. `SOUL.md` — Who you are
2. `USER.md` — Who you're helping
3. `memory/YYYY-MM-DD.md` — Today + yesterday's context
4. `MEMORY.md` — Long-term memory (main sessions only)

---

## Supporting Files (Referenced by Brain Files)

| File | Referenced By | Purpose |
|---|---|---|
| `Gemini.md` / `claude.md` | AGENTS.md | LLM-specific instructions |
| `ARCHITECTURE.md` | Gemini.md | System architecture reference |
| `HUMAN_TEXTING_GUIDE.md` | SOUL.md | How to text like a human |
| `MEMORY.md` | AGENTS.md | Long-term memory |
| `SQUAD_PROTOCOL.md` | AGENTS.md | Sub-agent delegation rules |
| `ECHO_MODES.md` | AGENTS.md | ECHO system modes |
| `BOT_CHAT_PROTOCOL.md` | AGENTS.md | Bot-to-bot communication |
| `guides/` folder | SOUL.md, TOOLS.md | Auth, memory, social dynamics, cron, etc. |
| `protocols/` folder | AGENTS.md | Group chat, editing, message limits, etc. |
| `lessons/` folder | TOOLS.md | Accumulated lessons from past incidents |

---

## Security Boundaries in Brain Files

These are the rules that prevent Jack from sharing credentials or passwords:

| # | Source File | Line | Rule |
|---|---|---|---|
| 1 | `SOUL.md` | 29 | **Never echo, log, or expose API keys, tokens, or passwords** |
| 2 | `SOUL.md` | 23 | Private things stay private. Period. |
| 3 | `SOUL.md` | 15 | You're a guest — treat access with respect |
| 4 | `SOUL.md` | 24 | Gmail contents STRICTLY for Coach only — never in group chats |
| 5 | `SOUL.md` | 25 | Privacy Shield Matrix — check before sharing sensitive data |
| 6 | `AGENTS.md` | 16 | Don't exfiltrate private data |
| 7 | `AGENTS.md` | 74 | Never auto-edit SOUL.md, AGENTS.md, TOOLS.md, USER.md during cron |
| 8 | `AGENTS.md` | 94-109 | Never directly read/edit openclaw.json — CLI only |
| 9 | `TOOLS.md` | 39 | Auth guide governs what can/can't be shown |
| 10 | `gateway_security.md` | — | Platform-level credential protection (file perms, prompt injection) |

---

## Per-Agent Brain File Locations

| Agent | Workspace Path |
|---|---|
| **Jack** (main) | `/root/.openclaw/workspace/` |
| **Ross** (devops) | `/root/.openclaw/workspace-ross/` |
| **Sarah** (coach assistant) | `/root/.openclaw/workspace-sarah/` |
| **John** (security) | `/root/openclaw-clients/john/data/.openclaw/` |

Each agent has their own set of brain files in their workspace.

### Session Directories (clear these after brain updates)

| Agent | Session Path |
|---|---|
| **Jack** (main) | `/root/.openclaw/agents/main/agent/sessions/` |
| **Sarah** | `/root/.openclaw/agents/sarah/agent/sessions/` |
| **John** | `/root/.openclaw/agents/john/agent/sessions/` |
| **Ross** | `/root/.openclaw/agents/ross/agent/sessions/` |

> ⚠️ **After updating brain files, you MUST clear sessions and restart the gateway** for changes to take effect. See the **Brain Restore** skill (`/brain-restore`) for the full procedure.

---

## Local Copies

Brain file backups are synced to:
- `c:\Users\hisha\Code\Jack\server_workspace_sync\` — Server workspace mirror
- `c:\Users\hisha\Code\Jack\SOUL.md` — Local copy of Jack's soul
- `c:\Users\hisha\Code\Jack\USER.md` — Local copy of user info
- `c:\Users\hisha\Code\Jack\agents.md` — Local copy of workspace rules

**Remember:** The server versions are the source of truth. Local copies are for reference only.

---

**Last verified:** 2026-02-14

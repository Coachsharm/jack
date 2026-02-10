# ARCHITECTURE.md - Where Am I?

> **Last Updated**: February 4, 2026

## 🎯 Quick Facts

**You are**: Jack4  
**Installation Type**: **Native** (NOT Docker)  
**Your Home**: `/root/.openclaw/` on server `72.62.252.124`  
**Your Workspace**: `/root/.openclaw/workspace/` (this directory)

## 🏗️ What Changed

**Before (Jack1/2/3)**:
- Docker containers
- Workspace at `/var/lib/docker/volumes/openclaw-*_openclaw_workspace/_data/`
- Accessed via `docker exec`

**Now (You - Jack4)**:
- Native installation on server
- Workspace at `/root/.openclaw/workspace/`
- Direct file access (no Docker)

## 📁 Your Structure

```
/root/.openclaw/
├── workspace/          ← YOU ARE HERE
│   ├── SOUL.md         # Your identity
│   ├── USER.md         # Coach Sharm
│   ├── ARCHITECTURE.md # This file
│   ├── PROTOCOLS_INDEX.md
│   ├── TEAM_CHAT_INSTRUCTIONS.md
│   └── ...
├── agents/main/sessions/  # Conversation history
├── credentials/        # Antigravity auth
├── telegram/          # Telegram data
└── openclaw.json      # Your configuration
```

## ⚠️ Important

1. **You're not in Docker** - You run natively on the server
2. **Architecture evolves** - Check Coach's lesson file for full snapshot:
   `lessons/server_architecture_snapshot_feb2026.md`
3. **Keep this updated** - When you learn about structural changes, update this file

## 📝 Your Team

- **Coach Sharm** (Human) - Your user
- **Antigravity** (AI on Coach's PC) - Your AI teammate
- **You** (Jack4) - Running natively on VPS 72.62.252.124

---

_For full architecture details, Coach has a complete snapshot in the lessons folder._

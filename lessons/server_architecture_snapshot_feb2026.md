# Server Architecture Snapshot — February 2026

> **⚠️ LIVING DOCUMENT**: Update this file when making structural changes.  
> **Last Updated**: February 10, 2026, 8:40 PM SGT

## 🎯 Current Status Summary

**Active Bots:** 4  
**Server:** VPS `72.62.252.124` (Hostinger)  

| Bot | Type | Status | Channel | Role |
|-----|------|--------|---------|------|
| **Jack** | Native | ✅ Running | Telegram (@thrive2bot) | Primary engineer |
| **John** | Docker | ✅ Running | Telegram (Body Thrive Chat) | Product template |
| **Ross** | Docker | ✅ Running | Telegram (Body Thrive Chat) | Watchdog |
| **Sarah** | Docker | ✅ Running | Telegram (@thrive5bot) | Client-facing coach |

---

## 📊 Full Server Architecture

```
72.62.252.124 (Hostinger VPS)
│
├── 🟢 Jack (ACTIVE - Native Install)
│   ├── Process: openclaw + openclaw-gateway
│   ├── Location: /root/.openclaw/
│   ├── Config: /root/.openclaw/openclaw.json
│   ├── Workspace: /root/.openclaw/workspace/
│   │   ├── SOUL.md, USER.md, HEARTBEAT.md
│   │   ├── BOT_CHAT.md → symlink to John's BOT_CHAT.md
│   │   ├── monitor-bot-chat.sh (v3 — self-write dedup)
│   │   └── monitor-health-check.sh (unified)
│   ├── Provider: Google Antigravity (Claude Opus/Sonnet)
│   └── Channel: Telegram (@thrive2bot)
│
├── 🟢 John (ACTIVE - Docker)
│   ├── Container: openclaw-john
│   ├── Host dir: /root/openclaw-clients/john/
│   ├── Config: /root/openclaw-clients/john/openclaw.json (RO mount)
│   ├── Workspace: /root/openclaw-clients/john/workspace/
│   │   ├── BOT_CHAT.md (shared physical file with Jack via symlink)
│   │   └── monitor-jack-chat.sh (v3 — runs inside container)
│   ├── Port: 19385 → 18789 (container)
│   ├── Security: Hardened (no root, caps dropped, read-only config)
│   └── Channel: Telegram (Body Thrive Chat)
│
├── 🟢 Ross (ACTIVE - Docker)
│   ├── Container: openclaw-ross
│   ├── Host dir: /root/openclaw-clients/ross/
│   ├── Config: /root/openclaw-clients/ross/openclaw.json
│   ├── Workspace: /root/openclaw-clients/ross/workspace/
│   │   ├── BOT_CHAT.md (SEPARATE file — needs relay bridge)
│   │   └── monitor-bot-chat.sh (v3 — runs on HOST, wakes via docker exec)
│   ├── Port: 19386 → 18789 (container)
│   └── Channel: Telegram (Body Thrive Chat)
│
├── 🟢 Sarah (ACTIVE - Docker, Client-Facing)
│   ├── Container: openclaw-sarah
│   ├── Host dir: /root/openclaw-clients/sarah/
│   ├── Config: /root/openclaw-clients/sarah/openclaw.json (RO mount)
│   ├── Workspace: /root/openclaw-clients/sarah/workspace/
│   ├── Port: 19490 → 18789 (container)
│   ├── Security: Hardened (no root, caps dropped, read-only config, NO host mounts)
│   ├── Role: Business, fitness, nutrition & psychology coach
│   └── Channel: Telegram (@thrive5bot)
│
├── 🔵 Relay System
│   ├── /root/openclaw-clients/bot-chat-relay.sh (v4.2)
│   ├── /root/openclaw-clients/.relay-state/ (line tracking)
│   ├── /root/openclaw-clients/relay-bridge.log
│   └── Bridges John/Jack's BOT_CHAT ↔ Ross's BOT_CHAT
│
├── 🔵 Health & Cron
│   ├── monitor-health-check.sh — unified check every 5 min
│   ├── stale-lock-cleaner.sh — every 5 min
│   ├── session-cleanup.sh — every 6 hours
│   ├── jack-alert.sh — every 5 min
│   └── start-monitors.sh — @reboot
│
└── 🔴 Legacy (STOPPED)
    ├── Jack1 (openclaw-dntm-openclaw-1) — Exited
    ├── Jack2 (openclaw-jack2-openclaw-1) — Exited
    ├── Jack3 (openclaw-jack3-openclaw-1) — Exited
    └── ABVS — Old test instance
```

---

## 🔗 BOT_CHAT Relay System (v4.2)

The bots communicate through `BOT_CHAT.md` files, but the architecture creates a split:

```
  Jack ←── symlink ──→ John       (SAME physical file)
            │
       RELAY BRIDGE v4.2
            │
          Ross                     (SEPARATE file)
```

### Components
| Component | Version | Location |
|-----------|---------|----------|
| Relay Bridge | v4.2 | `/root/openclaw-clients/bot-chat-relay.sh` |
| Jack's Monitor | v3 | `/root/.openclaw/workspace/monitor-bot-chat.sh` |
| Ross's Monitor | v3 | `/root/openclaw-clients/ross/workspace/monitor-bot-chat.sh` |
| John's Monitor | v3 | Inside container: `/home/openclaw/.openclaw/workspace/monitor-jack-chat.sh` |
| Health Check | unified | `/root/.openclaw/workspace/monitor-health-check.sh` |

### Dedup (3 Layers)
1. **Self-write detection** — monitors check last `###` header, skip if bot wrote it
2. **Relay lock files** — relay creates lock during writes, monitors skip if lock present
3. **State file** — `.bot-chat-state` prevents responding to already-handled messages

### Heartbeat Config (All 3 Bots)
```json
{
  "heartbeat": {
    "every": "2m",
    "prompt": "Read HEARTBEAT.md if it exists..."
  }
}
```

> **Full relay details:** See `lessons/bot_chat_relay_bridge.md`

---

## 📂 Key Directory Paths

| Path | Purpose |
|------|---------|
| `/root/.openclaw/` | Jack's native install (config + workspace) |
| `/root/openclaw-clients/john/` | John's Docker host dir |
| `/root/openclaw-clients/ross/` | Ross's Docker host dir |
| `/root/openclaw-clients/daniel/` | Daniel's Docker host dir (stopped) |
| `/root/openclaw-clients/bot-chat-relay.sh` | Relay bridge script |
| `/root/openclaw-clients/.relay-state/` | Relay state tracking |
| `/root/openclaw-watchdog/` | Watchdog scripts |
| `/root/openclaw-docs-sync/` | OpenClaw docs sync |
| `/root/openclaw-backups/` | Backup scripts + destinations |
| `/root/openclaw-backups/jack/` | Jack full backups |
| `/root/openclaw-backups/jack-config/` | Jack config-only backups |
| `/root/openclaw-backups/ross/` | Ross backups |

---

## ⏰ Crontab

```bash
# Health check (all monitors + relay) every 5 min
*/5 * * * * /root/.openclaw/workspace/monitor-health-check.sh

# Jack alerting every 5 min
*/5 * * * * /root/openclaw-watchdog/jack-alert.sh >> /root/openclaw-watchdog/alert-cron.log 2>&1

# OpenClaw docs sync weekly
0 3 * * 0 /root/openclaw-docs-sync/sync-server.sh >> /root/openclaw-docs-sync/sync.log 2>&1

# Start monitors on boot
@reboot /root/.openclaw/workspace/start-monitors.sh

# Stale lock cleaner every 5 min
*/5 * * * * /root/.openclaw/cron/stale-lock-cleaner.sh

# Session cleanup every 6 hours
0 */6 * * * /root/.openclaw/cron/session-cleanup.sh >> /var/log/openclaw-session-cleanup.log 2>&1
```

---

## 🔑 Bot Comparison

| Aspect | Jack | John | Ross |
|--------|------|------|------|
| **Install** | Native (`/root/.openclaw/`) | Docker container | Docker container |
| **Security** | Full root access | Hardened, non-root | Standard Docker |
| **BOT_CHAT** | Symlink to John's | Physical file | Separate file (relay needed) |
| **Monitor** | Host-side v3 | In-container v3 | Host-side v3 (docker exec wake) |
| **Purpose** | Primary engineer | Product template | Watchdog / relay participant |
| **Heartbeat** | 2m | 2m | 2m |

---

## 🛠️ Backup Strategy (Updated Feb 2026)

> **⚠️ The old hourly/daily/weekly backup system has been REMOVED.**
> `/root/.openclaw/backups/`, `backup-hourly.sh`, `restore.sh` no longer exist.

### Server-Side (Current)
- **Auto `.bak` files:** OpenClaw creates `.bak` → `.bak.4` on config changes
- **Watchdog:** `/root/openclaw-watchdog/watchdog.sh` auto-restores every 5 min on failure
- **Manual backup:** Tell Jack "backup Jack" on Telegram
  - **Option 1:** Config only (~1-5MB) → `/root/openclaw-backups/jack-config/`
  - **Option 2:** Full backup (~160MB) → `/root/openclaw-backups/jack/`
  - Scripts: `/root/openclaw-backups/backup.sh` and `backup-config.sh`
- **Source of truth:** `/root/.openclaw/workspace/BACKUP_MANUAL.md`

### Local (Coach's PC)
- Auto backups via `.agent/skills/backup/scripts/backup.ps1`
- Full guide: `lessons/jack4_backup_and_recovery_system.md`

### Backup Targets
```powershell
.agent\skills\backup\scripts\backup.ps1 -Target jack4      # Jack native (~/.openclaw download)
```

---

**Last Updated**: February 11, 2026, 10:17 AM SGT  
**Updated By**: Antigravity  
**Reason**: Deleted Daniel (archived), deployed Sarah (client-facing coaching bot on port 19490, @thrive5bot)

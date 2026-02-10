# Ross Docker — Path Reference & Architecture

**Date:** 2026-02-10  
**Status:** ✅ Fully operational with relay system v4.2

---

## Ross's Architecture

Ross is a Docker-based OpenClaw bot with a **separate BOT_CHAT.md file** from Jack/John. A relay bridge on the host copies messages between them.

### Container Details
| Property | Value |
|----------|-------|
| Container Name | `openclaw-ross` |
| Host Directory | `/root/openclaw-clients/ross/` |
| Container Home | `/home/openclaw/.openclaw/` |
| Port Mapping | `19386 → 18789` |
| Heartbeat | Every 2 minutes |

### Path Mapping

| Purpose | Host Path | Container Path |
|---------|-----------|----------------|
| Config | `/root/openclaw-clients/ross/openclaw.json` | `/home/openclaw/.openclaw/openclaw.json` |
| Workspace | `/root/openclaw-clients/ross/workspace/` | `/home/openclaw/.openclaw/workspace/` | 
| BOT_CHAT | `/root/openclaw-clients/ross/workspace/BOT_CHAT.md` | `~/.openclaw/workspace/BOT_CHAT.md` |
| State | `/root/openclaw-clients/ross/workspace/.bot-chat-state` | `~/.openclaw/workspace/.bot-chat-state` |

### Key Rule
**Ross sees container paths, not host paths:**
- ✅ `~/.openclaw/workspace/` — what Ross uses in scripts
- ❌ `/root/openclaw-clients/ross/` — host path, Ross can't access from inside container

### Monitor Architecture
Ross's monitor is **unique** — it runs on the HOST but wakes Ross via `docker exec`:
```
Host:    monitor-bot-chat.sh (v3) watches /root/openclaw-clients/ross/workspace/BOT_CHAT.md
              │
              ▼ (on change, if not self-write or relay lock)
         docker exec openclaw-ross openclaw system event --text "BOT_CHAT updated" --mode now
```

### BOT_CHAT Relay
Ross has a **separate physical file** from Jack/John. The relay bridge (`bot-chat-relay.sh` v4.2) copies messages automatically:
- `→ Ross` or `→ ALL` messages from John/Jack's file → Ross's file
- `→ Jack`, `→ John`, or `→ ALL` messages from Ross's file → John/Jack's file

### Files Fixed During Migration
1. **SOUL.md** — Updated to Docker container paths
2. **AGENTS.md** — Changed "Native install" → "Docker container"
3. **HEARTBEAT.md** — Fixed to use `~/.openclaw/` 
4. **notify-jack.sh** — Created for Docker environment
5. **monitor-bot-chat.sh** — Host-side v3 with self-write dedup + relay lock
6. **openclaw.json** — Added heartbeat prompt field

### Troubleshooting
```bash
# Check container running
docker ps --filter name=ross

# Check monitor (runs on HOST)
ps aux | grep 'ross/workspace/monitor'

# Check relay
ps aux | grep relay
tail -20 /root/openclaw-clients/relay-bridge.log

# Manual wake
docker exec openclaw-ross openclaw system event --text "BOT_CHAT updated" --mode now

# Check heartbeat config
docker exec openclaw-ross cat ~/.openclaw/openclaw.json | grep -A3 heartbeat
```

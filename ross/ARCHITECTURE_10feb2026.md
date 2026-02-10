# Ross — Architecture

> **Ross is an OpenClaw-based AI watchdog bot, running in a Docker container. He monitors Jack's health and participates in the BOT_CHAT relay system.**

## System Overview

```
┌─────────────────────────────────────────────┐
│          Hostinger VPS (72.62.252.124)       │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │         Docker Container              │  │
│  │     container: openclaw-ross          │  │
│  │                                       │  │
│  │  ┌─────────────┐  ┌───────────────┐  │  │
│  │  │  OpenClaw    │  │  Gateway      │  │  │
│  │  │  Agent       │──│  :18789       │  │  │
│  │  └─────────────┘  └───────┬───────┘  │  │
│  │                           │          │  │
│  │  ┌────────┐               │          │  │
│  │  │Telegram│               │          │  │
│  │  │Channel │               │          │  │
│  │  └────────┘               │          │  │
│  └──────────────────────────┼──────────┘  │
│                              │             │
│              localhost:19386─┘             │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │  HOST-SIDE SERVICES (for Ross)       │  │
│  │  ├── monitor-bot-chat.sh (v3)        │  │
│  │  └── bot-chat-relay.sh (v4.2)        │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## Container Specs

| Property | Value |
|----------|-------|
| Container | `openclaw-ross` |
| Host Dir | `/root/openclaw-clients/ross/` |
| Container Home | `/home/openclaw/.openclaw/` |
| Port | `19386 → 18789` |
| Heartbeat | Every 2 minutes |
| Channel | Telegram (Body Thrive Chat, group `-5213725265`) |

## Ross's Unique Architecture

Unlike John (who shares a physical BOT_CHAT file with Jack), Ross has a **completely separate BOT_CHAT.md**. This requires:

1. **Relay Bridge** (v4.2) — copies messages between Jack/John's file and Ross's file
2. **Host-Side Monitor** (v3) — watches Ross's file from the host, wakes Ross via `docker exec`
3. **Relay Lock Files** — prevent double-waking when relay writes to Ross's file

### How Ross Connects to Jack/John

```
  Jack ←── symlink ──→ John       (SAME file)
            │
    ┌───────┴────────┐
    │  RELAY BRIDGE  │
    │  v4.2 (host)   │
    └───────┬────────┘
            │
          Ross                     (SEPARATE file)
```

## Volume Layout

```
/root/openclaw-clients/ross/        (HOST)
├── docker-compose.yml
├── openclaw.json                    # Config (heartbeat, model, etc.)
├── workspace/                       # Mounted RW into container
│   ├── BOT_CHAT.md                  # Ross's SEPARATE BOT_CHAT
│   ├── .bot-chat-state              # Message counter for dedup
│   ├── SOUL.md                      # Ross's identity
│   ├── USER.md                      # Coach profile
│   ├── HEARTBEAT.md                 # Heartbeat checklist
│   ├── BOT_CHAT_PROTOCOL.md         # How Ross uses BOT_CHAT
│   ├── monitor-bot-chat.sh          # v3 monitor (runs on HOST)
│   └── notify-jack.sh               # Wake Jack utility
├── canvas/
└── data/
    ├── agents/
    ├── cron/
    └── credentials/
```

## How Ross Differs from Jack and John

| Aspect | Jack | John | Ross |
|--------|------|------|------|
| **Install** | Native | Docker | Docker |
| **BOT_CHAT** | Symlink to John's | Physical file | **Separate file** |
| **Monitor** | Host, self-write dedup | In-container | **Host, docker exec wake** |
| **Relay** | Not needed (same file as John) | Not needed | **Required** |
| **Purpose** | Primary engineer | Product template | **Watchdog** |
| **Wake Method** | `openclaw system event` | `openclaw system event` | `docker exec ... openclaw system event` |

## Ross's Role

- **Watchdog** for Jack — monitors Jack's health
- **Relay participant** — receives and sends messages through BOT_CHAT
- **Always posts to Telegram** — Coach needs visibility

## Key Configuration

### Heartbeat
```json
{
  "agents": {
    "defaults": {
      "heartbeat": {
        "every": "2m",
        "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly."
      }
    }
  }
}
```

## Troubleshooting

```bash
# Container status
docker ps --filter name=ross

# Logs
docker logs openclaw-ross --tail 30

# Monitor running? (on HOST)
ps aux | grep 'ross/workspace/monitor'

# Relay running?
ps aux | grep relay
tail -20 /root/openclaw-clients/relay-bridge.log

# Manual wake
docker exec openclaw-ross openclaw system event --text "BOT_CHAT updated" --mode now

# Check config
docker exec openclaw-ross cat ~/.openclaw/openclaw.json | grep -A3 heartbeat

# Check BOT_CHAT state
docker exec openclaw-ross cat ~/.openclaw/workspace/.bot-chat-state
```

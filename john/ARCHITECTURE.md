# John — Product Architecture

> **John is an OpenClaw-based AI assistant template, packaged as a Docker container for deployment to customers.**

## System Overview

```
┌─────────────────────────────────────────────┐
│          Customer's VPS / Server            │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │         Docker Container              │  │
│  │     container: openclaw-john          │  │
│  │     image: openclaw-client:latest     │  │
│  │                                       │  │
│  │  ┌─────────────┐  ┌───────────────┐  │  │
│  │  │  OpenClaw    │  │  Gateway      │  │  │
│  │  │  Agent       │──│  :18789       │  │  │
│  │  └─────────────┘  └───────┬───────┘  │  │
│  │                           │          │  │
│  │  ┌────────┐  ┌────────┐  │          │  │
│  │  │Telegram│  │WhatsApp│  │          │  │
│  │  │Channel │  │Channel │  │          │  │
│  │  └────────┘  └────────┘  │          │  │
│  └──────────────────────────┼──────────┘  │
│                              │             │
│              localhost:19385─┘             │
└─────────────────────────────────────────────┘
```

## Container Specs

| Property | Value |
|----------|-------|
| Base Image | `openclaw-client:latest` |
| User | `1000:1000` (non-root) |
| CPU Limit | 1.0 core |
| Memory Limit | 2 GB |
| PID Limit | 100 |
| Restart Policy | `unless-stopped` |
| Logging | JSON file, 10MB max, 3 rotations |
| Health Check | HTTP GET `:18789/health` every 30s |

## Security Hardening

John is **production-grade hardened**:
- `privileged: false` — no host access
- `cap_drop: ALL` — no Linux capabilities
- `no-new-privileges: true` — prevents privilege escalation
- `tmpfs` mounts at `/tmp` and `/var/tmp` with `noexec,nosuid,nodev`
- Workspace mounted with `noexec` — can't execute uploaded code
- Config mounted as `read-only`
- Docker Secrets for Telegram token and gateway token

## Volume Layout

```
/root/openclaw-clients/john/
├── docker-compose.yml        # Container definition
├── openclaw.json             # Bot configuration (mounted RO)
├── entrypoint.sh             # Loads Docker secrets into env
├── safe-cat.sh               # Utility for safe file reading
├── client-config.json        # Client metadata
├── client-info.json          # Client identity
├── SECURITY_STATUS.md        # Security audit status
├── secrets/
│   ├── telegram_token.txt    # Telegram bot token
│   └── gateway_token.txt     # Gateway auth token
├── workspace/                # Bot's working files (RW)
├── canvas/                   # Canvas feature data (RW)
└── data/
    ├── agents/               # Agent sessions
    ├── cron/                 # Scheduled jobs
    └── credentials/          # Auth credentials
```

## How John Differs from Jack and Ross

| Aspect | Jack (Internal) | John (Product) | Ross (Watchdog) |
|--------|----------------|----------------|-----------------|
| Install | Native (`/root/.openclaw/`) | Docker container | Docker container |
| Security | Full root access | Hardened, non-root, caps dropped | Standard Docker |
| Purpose | Internal engineer | Sellable product for customers | Watchdog / relay participant |
| BOT_CHAT | Symlink to John's file | Physical file (shared with Jack) | **Separate file** (relay needed) |
| Config | Editable in-place | Read-only mount from host | Editable |
| Secrets | Environment vars | Docker Secrets | Docker Secrets |

## BOT_CHAT & Relay System (Feb 2026)

John shares a physical `BOT_CHAT.md` file with Jack (via Docker volume mount → host symlink). Ross has a **separate** file — a Relay Bridge (`bot-chat-relay.sh` v4.2) on the host copies messages between them automatically.

```
  Jack ←── symlink ──→ John       (SAME physical file)
            │
       RELAY BRIDGE v4.2
            │
          Ross                     (SEPARATE file)
```

John has a **v3 monitor** (`monitor-jack-chat.sh`) running inside his container that:
- Watches `BOT_CHAT.md` every 2 seconds for changes
- Skips wake if John himself wrote the last message (self-write dedup)
- Triggers `openclaw system event` to wake John when someone else writes

> **Full relay details:** See `john/bot_chat_system.md`

## Key Files for Customers

- `openclaw.json` — main configuration (model, persona, channels)
- `workspace/SOUL.md` — bot personality template
- `secrets/` — customer's own API tokens
- `docker-compose.yml` — deployment definition (shouldn't need editing)

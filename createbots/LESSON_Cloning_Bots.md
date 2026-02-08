# LESSON: Cloning OpenClaw Bots Using --profile

**Created**: 2026-02-07  
**Example**: Jack → Ross  
**Method**: Official OpenClaw `--profile` mechanism  
**Docs**: https://docs.openclaw.ai/gateway/multiple-gateways

---

## Overview

OpenClaw supports running multiple bot instances on the same server using the `--profile` flag. This provides **full isolation** between instances:

- ✅ Separate configuration files
- ✅ Separate state directories (sessions, credentials)
- ✅ Separate workspaces
- ✅ Separate ports (gateway + derived ports)
- ✅ Separate systemd services

**Shared resources** (intentional):
- Same `openclaw` binary
- Same Ollama models (localhost:11434)
- Same API keys (if reused)
- Same server RAM/CPU

---

## Real-World Example: Jack → Ross

### Requirements
- **Source Bot**: Jack (personal assistant, Claude Opus 4-6, Telegram + WhatsApp)
- **Target Bot**: Ross (Telegram-only clone, Claude Sonnet 4.5, same personality)
- **Key Constraint**: Must not interfere with Jack

### Isolation Map

| Item | Jack (default) | Ross (--profile ross) |
|------|----------------|----------------------|
| Config | `/root/.openclaw/openclaw.json` | `/root/.openclaw-ross/openclaw.json` |
| State Dir | `/root/.openclaw/` | `/root/.openclaw-ross/` |
| Workspace | `/root/.openclaw/workspace` | `/root/.openclaw/workspace-ross` |
| Gateway Port | 18789 | 19789 |
| Browser Control | 18791 | 19791 |
| Canvas | 18793 | 19793 |
| Systemd Service | `openclaw-gateway.service` | `openclaw-gateway-ross.service` |
| Backup Dir | `/root/openclaw-backups/jack/` | `/root/openclaw-backups/ross/` |
| Watchdog Dir | `/root/openclaw-watchdog/` | `/root/openclaw-watchdog-ross/` |

---

## Step-by-Step Process

### 1. Run Onboarding

```bash
openclaw --profile ross onboard
```

**During onboarding**:
- Choose **QuickStart** (we'll customize config afterward)
- Select provider (OpenRouter for Claude Sonnet 4.5)
- Provide API key
- Select Telegram channel
- Provide bot token (create new bot via @BotFather first)
- Skip skill dependencies (configure later)

**Important**: Port defaults to 18789 during onboarding — we'll fix this in config.

### 2. Fix Configuration

The onboarding created `/root/.openclaw-ross/openclaw.json` but needs adjustments:

```bash
# Create corrected config
cat > /tmp/ross-config.json << 'CONFIG'
{
  "gateway": {
    "port": 19789,  // CRITICAL: Must differ by at least 20 from other instances
    "mode": "local",
    "bind": "loopback",
    "auth": {
      "mode": "token",
      "token": "<unique-token-from-onboarding>"
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openrouter/anthropic/claude-sonnet-4.5",
        "fallbacks": ["openrouter/anthropic/claude-sonnet-4.5", "anthropic/claude-haiku-4"]
      },
      "models": {
        // Copy Jack's model aliases + add Ross-specific ones
        "openrouter/anthropic/claude-sonnet-4.5": { "alias": "or-sonnet" },
        "google-antigravity/claude-sonnet-4-5-thinking": { "alias": "a1" },
        // ... (include all models for flexibility)
      },
      "workspace": "/root/.openclaw/workspace-ross"
    }
  },
  "auth": {
    "profiles": {
      // Copy Jack's auth profiles (Google Antigravity, Anthropic, etc.)
      "google-antigravity:faithinmotion88@gmail.com": {
        "provider": "google-antigravity",
        "mode": "oauth",
        "email": "faithinmotion88@gmail.com"
      },
      "openrouter:default": {
        "provider": "openrouter",
        "mode": "api_key"
      }
    }
  },
  "models": {
    "providers": {
      // Copy Jack's Ollama provider config
      "ollama": {
        "baseUrl": "http://localhost:11434",
        "api": "openai-completions",
        "models": [ /* copy from Jack */ ]
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "botToken": "<ross-telegram-token>",
      "groups": { "*": { "requireMention": false } },
      "groupPolicy": "open",
      "streamMode": "partial"
    }
    // NOTE: No WhatsApp for Ross (removed)
  },
  "plugins": {
    "entries": {
      "google-antigravity-auth": { "enabled": true },
      "telegram": { "enabled": true }
      // NOTE: No whatsapp plugin for Ross
    }
  },
  "env": {
    // Copy environment variables from Jack
    "BRAVE_API_KEY": "<same-as-jack>",
    "OLLAMA_API_KEY": "ollama-local"
  }
}
CONFIG

# Apply config
cp /tmp/ross-config.json /root/.openclaw-ross/openclaw.json
```

### 3. Copy SOUL.md (Personality)

```bash
cp /root/.openclaw/workspace/SOUL.md /root/.openclaw/workspace-ross/SOUL.md
```

### 4. Start Ross Gateway

```bash
# Manual start (for testing)
OPENCLAW_CONFIG_PATH=/root/.openclaw-ross/openclaw.json \
OPENCLAW_STATE_DIR=/root/.openclaw-ross \
openclaw gateway --port 19789

# OR install as service
openclaw --profile ross gateway install
systemctl start openclaw-gateway-ross
```

### 5. Verify Isolation

```bash
# Check both ports are listening
ss -tlnp | grep -E '18789|19789'

# Expected output:
# 127.0.0.1:18789  (Jack)
# 127.0.0.1:19789  (Ross)

# Check health
openclaw health --json  # Jack
OPENCLAW_CONFIG_PATH=/root/.openclaw-ross/openclaw.json \
OPENCLAW_STATE_DIR=/root/.openclaw-ross \
openclaw health --json  # Ross

# Both should return {"ok": true}
```

### 6. Pair Telegram User

Send a message to the Ross Telegram bot. You'll get:

```
Pairing code: ABC123XY
```

Approve it:

```bash
OPENCLAW_CONFIG_PATH=/root/.openclaw-ross/openclaw.json \
OPENCLAW_STATE_DIR=/root/.openclaw-ross \
openclaw pairing approve telegram ABC123XY
```

---

## Backup & Monitoring Infrastructure

### Backup Script

Create `/root/openclaw-backups/ross/backup.sh`:

```bash
#!/bin/bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/root/openclaw-backups/ross/$TIMESTAMP"
ROSS_DIR="/root/.openclaw-ross"
ROSS_WORKSPACE="/root/.openclaw/workspace-ross"

mkdir -p "$BACKUP_DIR"
cp "$ROSS_DIR/openclaw.json" "$BACKUP_DIR/"
cp -r "$ROSS_WORKSPACE" "$BACKUP_DIR/workspace"

# Keep only last 10 backups
cd /root/openclaw-backups/ross
ls -dt */ | tail -n +11 | xargs rm -rf
```

Add to cron:

```bash
0 * * * * /root/openclaw-backups/ross/backup.sh 2>/dev/null
```

### Watchdog Script

Create `/root/openclaw-watchdog-ross/watchdog.sh` (clone from Jack's watchdog, modify paths):

**Key changes**:
- `CONFIG_FILE="/root/.openclaw-ross/openclaw.json"`
- `OPENCLAW_DIR="/root/.openclaw-ross"`
- `STATE_FILE="/root/openclaw-watchdog-ross/restore-state.json"`
- `EXTERNAL_BACKUP_DIR="/root/openclaw-backups/ross"`
- `TELEGRAM_BOT_TOKEN="<ross-telegram-token>"` (for alerts)
- Health check: `OPENCLAW_CONFIG_PATH="$CONFIG_FILE" OPENCLAW_STATE_DIR="$OPENCLAW_DIR" openclaw health --json`
- Restart: `OPENCLAW_CONFIG_PATH="$CONFIG_FILE" OPENCLAW_STATE_DIR="$OPENCLAW_DIR" openclaw gateway restart`

Add to cron:

```bash
*/5 * * * * /root/openclaw-watchdog-ross/watchdog.sh 2>/dev/null
```

### Restore Script

Create `/root/.openclaw-ross/restore.sh`:

```bash
#!/bin/bash
BACKUP_BASE="/root/openclaw-backups/ross"
# List backups, prompt user, create safety backup, restore
# (See Jack's restore.sh for full implementation)
```

---

## Port Spacing Rules

From OpenClaw docs: **Minimum gap of 20 ports** between instances.

Each gateway uses:
- Base port (e.g., 19789)
- Base + 2 for browser control (19791)
- Base + 4 for canvas (19793)

**Recommended spacing**:
- Instance 1: 18789
- Instance 2: **19789** (or higher, e.g., 20789 if adding a 3rd)

---

## Common Issues & Solutions

### Issue: "Port already in use"

**Cause**: Two instances trying to use same port.

**Fix**: Check config `gateway.port` values, ensure at least 20 apart.

```bash
jq '.gateway.port' /root/.openclaw/openclaw.json
jq '.gateway.port' /root/.openclaw-ross/openclaw.json
```

### Issue: Model not found (e.g., `openrouter/autoopenrouter/anthropic/claude-sonnet-4.5`)

**Cause**: Onboarding wizard concatenated model name incorrectly.

**Fix**: Edit config, fix model name:

```bash
# Wrong: "openrouter/autoopenrouter/anthropic/claude-sonnet-4.5"
# Right: "openrouter/anthropic/claude-sonnet-4.5"
```

### Issue: Ross can't access Google Antigravity models

**Cause**: Missing `auth.profiles` entry.

**Fix**: Copy Jack's `google-antigravity:faithinmotion88@gmail.com` profile to Ross's config.

### Issue: Watchdog doesn't work

**Cause**: Missing `OPENCLAW_CONFIG_PATH` and `OPENCLAW_STATE_DIR` env vars.

**Fix**: Always prefix Ross commands with:

```bash
OPENCLAW_CONFIG_PATH=/root/.openclaw-ross/openclaw.json \
OPENCLAW_STATE_DIR=/root/.openclaw-ross \
<command>
```

Or export at top of scripts.

---

## Verification Checklist

- [ ] Jack health check passes
- [ ] Ross health check passes
- [ ] Both ports listening (18789, 19789)
- [ ] Ross Telegram paired
- [ ] Ross uses correct model (check first response)
- [ ] Backup script runs successfully
- [ ] Watchdog initializes correctly
- [ ] Cron jobs added
- [ ] RAM usage acceptable (`free -h`)
- [ ] Both bots respond independently

---

## RAM Considerations

**Per-instance usage**: ~400-500MB

**Example** (8GB server):
- Jack: ~450MB
- Ross: ~450MB
- John: ~450MB
- OpenCode: ~300MB
- System: ~1GB
- **Total**: ~2.6GB / 8GB ✅

Monitor with `free -h`.

---

## Future Clones

To create a 3rd bot (e.g., "Monica"):

1. Create Telegram bot via @BotFather
2. Run `openclaw --profile monica onboard`
3. Use port **20789** (or higher)
4. Clone this lesson's steps, replace "ross" → "monica"
5. Set up backups/watchdog mirroring this pattern

---

## References

- OpenClaw Multiple Gateways: https://docs.openclaw.ai/gateway/multiple-gateways
- OpenClaw Configuration: https://docs.openclaw.ai/gateway/configuration
- Jack Restoration Guide: `/root/.openclaw/workspace/createbots/JACK_RESTORATION_GUIDE.md`
- Server Reference: `SERVER_REFERENCE.md` (local repo)

---

## Lessons Learned

1. **Always use --profile** for multi-instance setups (cleanest isolation)
2. **Port spacing matters** (minimum +20 gap)
3. **Environment variables are critical** for Ross-specific commands
4. **Model names are finicky** during onboarding (fix in config afterward)
5. **Watchdog needs its own Telegram token** (can reuse bot, different chat for alerts)
6. **SOUL.md is the personality** — copy it for consistent character
7. **Backup hierarchy is crucial** (.bak files → hourly → daily → external)

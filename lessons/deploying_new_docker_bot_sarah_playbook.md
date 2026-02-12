# Lesson: How to Deploy a New OpenClaw Bot (Docker) — The Sarah Playbook

**Date:** February 11, 2026  
**Author:** Antigravity  
**Bot Built:** Sarah (client-facing coaching bot)  
**Time Taken:** ~40 minutes (start to functional on Telegram)  
**Outcome:** ✅ SUCCESS — first-try deployment with minor auth fix needed

---

## Overview

This lesson documents the complete process of building and deploying a new Docker-based OpenClaw bot from scratch. It was written after the successful deployment of Sarah, Coach Sharm's client-facing assistant coach. The goal is to make this a repeatable, self-contained playbook — no other documentation needed.

---

## Pre-Flight Checklist (Ask BEFORE You Start)

These questions MUST be answered before touching any files:

### 1. What's the bot's name?
> Sarah

### 2. What's the bot's role?
> Business coach, fitness coach, nutrition coach, psychology & mindset coach. Client-facing.

### 3. Is it client-facing or internal?
> **Client-facing.** This means:
> - NO access to host filesystem (`/root`, other bot directories)
> - NO Docker socket mount
> - NO server monitoring capabilities
> - NO knowledge of other bots (Jack, John, Ross)
> - Config mounted as **read-only**
> - Must represent professional quality at all times

### 4. Does it need a new Telegram bot, or reuse one?
> Reused Daniel's `@thrive5bot` (since Daniel was being deleted)
> **If creating new:** Go to @BotFather on Telegram, create bot, get token

### 5. What should it call the user?
> **COACH** — never "Hisham", never by first name. This is CRITICAL and must be in USER.md.

### 6. Any bot to delete first?
> Yes, Daniel — archived and removed

---

## The Template: What Works

We use **John's docker-compose.yml** as the base template. John is the proven, security-hardened Docker bot. Key features:

- `docker-compose` (NOT raw `docker run` — this is what killed Daniel)
- User `1000:1000` (maps to `101000:101000` on host due to userns-remap)
- Read-only config mount
- Docker secrets for tokens (not environment variables)
- Resource limits (CPU, memory, PIDs)
- All capabilities dropped
- Health check built in
- Logging with rotation
- `restart: unless-stopped`

### What to Change from John's Template

| Setting | John Value | What to Change |
|---------|-----------|----------------|
| `container_name` | `openclaw-john` | → `openclaw-sarah` |
| `CLIENT_NAME` | `john` | → `sarah` |
| `ports` | `19385:18789` | → Pick unique port (Sarah: `19490`) |
| `logging.tag` | `client-john` | → `client-sarah` |
| Watchdog mounts | None (John) / Yes (Ross) | None for client-facing bots |

### Port Allocation (Current)
- Jack: Native (no Docker port)
- John: `19385`
- Ross: `19789`
- Sarah: `19490`

---

## Step-by-Step Deployment

### Step 1: Create ALL Files Locally FIRST

**DO NOT** create files on the server one by one. Build everything locally, verify it, THEN upload. This prevents half-configured states.

**Files needed:**
```
sarah/
├── docker-compose.yml      # From John's template, adapted
├── entrypoint.sh           # Identical to John's (reads secrets into env)
├── openclaw.json           # Bot-specific config
├── deploy-sarah.sh         # Deployment script
├── secrets/
│   ├── telegram_token.txt  # Bot token from @BotFather
│   └── gateway_token.txt   # Placeholder (generated during deploy)
└── workspace/
    ├── SOUL.md             # Personality — ADAPTED from Jack, not copied
    ├── USER.md             # User info — MUST say "call them Coach"
    ├── IDENTITY.md         # Who the bot is
    ├── HEARTBEAT.md        # Periodic check-in tasks
    ├── HUMAN_TEXTING_GUIDE.md  # How to text naturally
    ├── telegram-formatting-preferences.md  # No tables, proper spacing
    └── STYLE_GUIDE.md      # Empty template for preferences
```

### Step 2: Create Directory Structure on Server

```bash
SARAH_DIR=/root/openclaw-clients/sarah
mkdir -p "$SARAH_DIR"/{workspace,data/agents,data/cron,data/credentials,secrets,canvas}
```

**Key directories:**
- `workspace/` — Bot's personality and knowledge files
- `data/agents/` — Agent state, auth profiles, sessions
- `data/cron/` — Scheduled tasks
- `data/credentials/` — Telegram pairing data
- `secrets/` — Bot token, gateway token
- `canvas/` — Canvas/UI storage

### Step 3: Upload All Files via PSCP

```powershell
# Upload each file (Windows → Server)
pscp -pw "PASSWORD" local_file root@SERVER:/remote/path
```

**⚠️ DO NOT use `plink` for large file content** — it truncates output. Always use PSCP for file transfers.

**Pattern for reading large server output:**
```powershell
# 1. Write output to file on server
plink -batch -pw "PASSWORD" root@SERVER "command > /tmp/output.txt"
# 2. Download the file
pscp -pw "PASSWORD" root@SERVER:/tmp/output.txt local_output.txt
# 3. Read locally
```

### Step 4: Delete Old Bot (If Applicable)

```bash
# Archive first (safety net)
tar -czf /root/openclaw-clients/daniel-archive-$(date +%Y%m%d).tar.gz \
    -C /root/openclaw-clients daniel/

# Stop and remove container
docker stop openclaw-daniel
docker rm openclaw-daniel

# Delete directory
rm -rf /root/openclaw-clients/daniel
```

### Step 5: Generate Gateway Token

```bash
GATEWAY_TOKEN=$(openssl rand -hex 24)
echo "$GATEWAY_TOKEN" > /root/openclaw-clients/sarah/secrets/gateway_token.txt

# Update openclaw.json with the token
python3 -c "
import json
with open('/root/openclaw-clients/sarah/openclaw.json', 'r') as f:
    config = json.load(f)
config['gateway']['auth']['token'] = '$GATEWAY_TOKEN'
with open('/root/openclaw-clients/sarah/openclaw.json', 'w') as f:
    json.dump(config, f, indent=2)
"
```

### Step 6: Set Permissions (CRITICAL)

```bash
# ⚠️ THIS SERVER USES USERNS-REMAP
# Container UID 1000 maps to HOST UID 101000
# If you use 1000:1000 here, THE BOT CANNOT READ ITS OWN FILES

chown -R 101000:101000 /root/openclaw-clients/sarah/workspace
chown -R 101000:101000 /root/openclaw-clients/sarah/data
chown -R 101000:101000 /root/openclaw-clients/sarah/canvas
chown 101000:101000 /root/openclaw-clients/sarah/openclaw.json

# Secrets owned by root, restricted permissions
chmod 600 /root/openclaw-clients/sarah/secrets/*
chmod +x /root/openclaw-clients/sarah/entrypoint.sh
```

**WHY 101000?** Our server has Docker user namespace remapping enabled. When docker-compose says `user: "1000:1000"`, the container internally runs as UID 1000. But on the HOST, this maps to UID 101000 (100000 + 1000). Files must be owned by 101000 on the host for the container to access them.

**This was the #1 gotcha in Ross's migration. Getting this wrong = "Permission denied" errors and a non-functional bot.**

### Step 7: Copy Auth Profiles from Working Bot

```bash
# The new bot needs OAuth tokens to access LLM providers
# Copy from a working bot (e.g., John)
mkdir -p /root/openclaw-clients/sarah/data/agents/main/agent
cp /root/openclaw-clients/john/data/agents/main/agent/auth-profiles.json \
   /root/openclaw-clients/sarah/data/agents/main/agent/
cp /root/openclaw-clients/john/data/agents/main/agent/models.json \
   /root/openclaw-clients/sarah/data/agents/main/agent/
chown -R 101000:101000 /root/openclaw-clients/sarah/data/agents/
```

**⚠️ MATCH THE AUTH PROFILE TO THE CONFIG:**
The `openclaw.json` `auth.profiles` and `auth.order` sections MUST reference the SAME email that appears in `auth-profiles.json`. If the config says `blackintegra777@gmail.com` but the tokens are for `faithinmotion88@gmail.com`, ALL models will fail with "No API key found."

**This was the #1 bug in Sarah's deployment.** The fix was updating `openclaw.json`'s auth section to reference `faithinmotion88@gmail.com` (the email that actually has OAuth tokens).

### Step 8: Start the Bot

```bash
cd /root/openclaw-clients/sarah
docker compose up -d
```

Wait 30-40 seconds for health check to pass.

### Step 9: Verify

```bash
# Check status
docker ps --filter name=openclaw-sarah

# Check logs for errors
docker logs openclaw-sarah 2>&1 | tail -20

# Key things to look for:
# ✅ [gateway] listening on ws://0.0.0.0:18789
# ✅ [heartbeat] started
# ✅ [telegram] starting provider (@thrive5bot)
# ❌ No API key found (auth mismatch — go back to Step 7)
# ❌ Missing config (path issue — check mounts)
# ❌ EACCES/permission denied (ownership — go back to Step 6)
```

### Step 10: Approve Telegram Pairing

1. Send `/start` to the bot on Telegram
2. Bot shows pairing code (e.g., `R865JEYT`)
3. Approve on server:
```bash
docker exec openclaw-sarah openclaw pairing approve telegram R865JEYT
```

### Step 11: Test & Iterate on Personality

Send a test message. Check:
- ✅ Does it respond? (auth working)
- ✅ Does it call you "Coach"? (USER.md loaded)
- ✅ Is the tone right? (SOUL.md loaded)
- ❌ If wrong, update workspace files, re-upload, restart

---

## What NOT to Do

### ❌ DON'T use `docker run`
Daniel was deployed with raw `docker run` commands. No version control, no reproducibility, fragile. Always use `docker-compose`.

### ❌ DON'T use `chown 1000:1000` on this server
Userns-remap means the real UID is 101000. Using 1000 = permission denied inside the container.

### ❌ DON'T mount `/root` or Docker socket for client-facing bots
Daniel had both. Client-facing bots should have ZERO access to host filesystem or Docker API.

### ❌ DON'T create files on the server one by one
Build everything locally, verify, upload in batch. Half-configured states cause debugging nightmares.

### ❌ DON'T copy `openclaw.json` blindly from another bot
Each bot needs its own: container name, client name, port, Telegram token, gateway token. Copy the structure, customize the values.

### ❌ DON'T forget to match auth profiles to config
If `auth-profiles.json` has tokens for `email_A@gmail.com` but `openclaw.json` references `email_B@gmail.com`, nothing will work. This is a silent killer — the bot starts "healthy" but fails on every message.

### ❌ DON'T skip the personality files
A bot with no SOUL.md/USER.md is a generic chatbot. It'll call the user by name, write essays instead of short texts, and generally feel robotic. The personality files are NOT optional.

### ❌ DON'T give client-facing bots infrastructure knowledge
Sarah should NOT know about Jack, John, Ross, the server, docker, or any internal systems. She's a coach. Period.

---

## What TO Do

### ✅ Use John's docker-compose as the template
It's proven, hardened, and handles secrets properly.

### ✅ Archive before deleting
Always `tar -czf` old bot data before removing. Safety net costs nothing.

### ✅ Build locally, upload in batch
PSCP makes this fast and clean. No partial states.

### ✅ Copy auth-profiles.json from a working bot
Saves the entire OAuth setup process.

### ✅ Run `openclaw doctor --fix` before first start
Catches config issues early (though some warnings are expected in temp containers).

### ✅ Test the personality immediately
Send a message right after pairing. Iterate on SOUL.md and USER.md until the vibe is right.

### ✅ Update server architecture docs
After deployment, update `server_architecture_snapshot_feb2026.md` and any other relevant docs.

---

## Quick Reference: Files That Make a Bot "Smart"

| File | What It Does | Priority |
|------|-------------|----------|
| SOUL.md | Personality, values, communication style | CRITICAL |
| USER.md | Who the user is, what to call them, preferences | CRITICAL |
| IDENTITY.md | Who the bot is, its role | HIGH |
| HEARTBEAT.md | What to do on periodic check-ins | HIGH |
| HUMAN_TEXTING_GUIDE.md | How to text like a human | MEDIUM |
| telegram-formatting-preferences.md | No tables, proper spacing | MEDIUM |
| STYLE_GUIDE.md | Detailed formatting preferences | LOW (grows over time) |

---

## Timeline: What It Actually Took

| Phase | Time | Notes |
|-------|------|-------|
| Read workflow, download templates | 5 min | PSCP + view files |
| Create all local files | 10 min | docker-compose, config, workspace |
| Upload & deploy script | 5 min | PSCP batch upload |
| Run deployment | 3 min | Script handles everything |
| Fix auth mismatch | 8 min | Config referenced wrong email |
| Telegram pairing | 2 min | User sends /start, approve code |
| Update personality files | 10 min | Pull Jack's files, adapt for coaching |
| **TOTAL** | **~43 min** | |

**Previous bot (Daniel) took hours and never worked.** The difference:
- Daniel: raw `docker run`, wrong mounts, wrong paths, no personality files
- Sarah: `docker-compose` template, correct permissions, proper auth, full personality

---

## Future Improvements

1. **Create a `create-bot.sh` script** that automates Steps 2-8 with parameters (name, port, telegram token)
2. **Copy relevant skills from Jack** to new bots (but filter for client-facing safety)
3. **Create a personality template** that asks the right questions upfront
4. **Add Sarah to the backup system** (cron job for config-only backups)
5. **Update Docker image** — current is `2026.2.3-1`, latest is `2026.2.9`

---

**Last Updated:** February 11, 2026  
**Status:** ✅ Sarah operational and responding on Telegram

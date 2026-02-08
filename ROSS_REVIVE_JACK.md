# 🔧 How To Revive Jack — For Ross

**Created**: 2026-02-08 22:15 SGT  
**Author**: Antigravity (Coach's AI assistant)  
**⚠️ This doc may become outdated** — if credentials, server IP, or OpenClaw commands have changed since the date above, verify with Coach before using.

Jack is an AI bot running on OpenClaw on a remote server. This guide walks you through every possible failure and how to fix it, from easiest to hardest.

---

## Get Into The Server

Open any terminal app and type:
```bash
ssh root@72.62.252.124
```
Password: `<REDACTED — ask Coach>`

> You do NOT need Antigravity IDE for this. Any terminal works (Terminal app, iTerm, Putty, etc.)

---

## Level 1: Check If Jack Is Actually Down

```bash
openclaw health --json
```

- **Healthy** → Jack is fine. Problem is your internet or Telegram. Stop here.
- **Unhealthy / errors** → Continue to Level 2.

---

## Level 2: Run the Doctor

```bash
openclaw doctor
```

This scans everything and tells you exactly what's wrong. Read the output.

Then check recent error logs:
```bash
openclaw logs --max-bytes 50000 2>&1 | tail -50
```

**Look for these clues:**
| You See | It Means | Go To |
|---------|----------|-------|
| `429` or `quota` | LLM ran out of credits | Level 5 |
| `403` or `forbidden` | LLM account blocked | Level 5 |
| `404` or `not found` | Model doesn't exist | Level 5 |
| Config errors | Config file corrupted | Level 4 |
| Other errors | General crash | Level 3 |

---

## Level 3: Simple Restart

```bash
openclaw gateway restart
```

Wait 30 seconds. Then check:
```bash
openclaw health --json
```

- **Healthy?** → ✅ Done! Test by messaging `@thrive2bot` on Telegram.
- **Still broken?** → Go to Level 4.

---

## Level 4: Config File Corrupted — Restore From Backup

Jack keeps automatic backups. Restore the most recent one:

```bash
# See available backups
ls -lt /root/.openclaw/openclaw.json.bak*

# Restore the latest backup
cp /root/.openclaw/openclaw.json.bak /root/.openclaw/openclaw.json
openclaw gateway restart
openclaw health --json
```

**If `.bak` files don't work, try daily backups:**
```bash
# See what daily backups exist
ls /root/.openclaw/backups/daily/

# Restore one (replace YYYYMMDD with the latest date you see)
cp /root/.openclaw/backups/daily/backup_YYYYMMDD/openclaw.json /root/.openclaw/openclaw.json
openclaw gateway restart
```

**If daily backups also fail, try hourly:**
```bash
ls -lt /root/.openclaw/backups/hourly/ | head -10
cp /root/.openclaw/backups/hourly/backup_YYYYMMDD_HHMMSS/openclaw.json /root/.openclaw/openclaw.json
openclaw gateway restart
```

- **Working?** → ✅ Done!
- **ALL backups broken?** → Go to Level 7.

---

## Level 5: LLM Hit Its Limits — Swap Jack's Brain

This is the most common "Jack is healthy but doesn't reply" problem. The AI provider ran out of credits or got blocked. You need to swap to a different AI.

**Open the config file:**
```bash
nano /root/.openclaw/openclaw.json
```

**Find the model name** (search for `"primary"` with Ctrl+W), and change it to one of these:

| Change To | What It Is | Cost |
|-----------|-----------|------|
| `google-antigravity/claude-opus-4-6-thinking` | Same smart Claude, free Google route | **FREE** |
| `anthropic/claude-opus-4-6` | Direct Anthropic (if Google is blocked) | Paid |
| `anthropic/claude-sonnet-4-5` | Slightly less smart but cheaper | Cheaper |
| `anthropic/claude-haiku-4` | Basic but very cheap | Very cheap |
| `ollama/hermes3` | Runs locally on server, dumb but works | **FREE** |

**Save the file** (Ctrl+X → Y → Enter), then:
```bash
openclaw gateway restart
openclaw health --json
```

> **Rule of thumb:** If Anthropic hit limits → switch to `google-antigravity/...`
> If Google hit limits → switch to `anthropic/...`
> If both hit limits → switch to `ollama/hermes3` (dumb but free)

---

## Level 6: OpenClaw Software Itself Is Corrupted

**How you'd know:** The `openclaw` command itself crashes, gives weird errors, or isn't found.

```bash
# Check if openclaw exists
which openclaw
openclaw --version

# If broken, reinstall it
npm install -g openclaw@latest

# Verify
openclaw --version

# Restore config (reinstall may have wiped it)
cp /root/.openclaw/openclaw.json.bak /root/.openclaw/openclaw.json

# Restart
openclaw gateway restart
openclaw health --json
```

**If even npm is broken:**
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs
npm install -g openclaw@latest
```

---

## Level 7: Full Rebuild From Scratch

Only if everything above failed. This resets Jack completely.

```bash
openclaw onboard
```

It will ask you for credentials. Enter these:

| Prompt | Value |
|--------|-------|
| Telegram Bot Token | `<REDACTED — ask Coach>` |
| Primary Model | `anthropic/claude-opus-4-6` |
| Anthropic API Key | `<REDACTED — ask Coach>` |
| OpenRouter API Key | `<REDACTED — ask Coach>` |
| OpenAI API Key | `<REDACTED — ask Coach>` |

After onboarding, upload Jack's personality file (`SOUL.md`) back to `/root/.openclaw/workspace/SOUL.md`.

---

## Level 8: Server Itself Is Dead (Nuclear Option)

If you can't even SSH in, the server is dead.

1. Go to **hpanel.hostinger.com** (Hostinger control panel)
2. Find the VPS (IP: `72.62.252.124`)
3. Try **Restart** from the panel first
4. If that fails → **Reinstall OS** (pick Ubuntu 24.04)
5. SSH back in and follow Level 6 + Level 7 to reinstall everything

---

## 🤖 Good News: Jack Has a Watchdog

Jack already has a robot that checks on him **every 5 minutes** and auto-fixes most crashes. It also sends Telegram alerts when something breaks.

Ross only needs this guide when:
- The watchdog couldn't fix it (LLM limits — watchdog can't swap models)
- The watchdog itself broke (rare)
- Something catastrophic happened (server crash, corrupted software)

**Check watchdog status:**
```bash
tail -50 /root/openclaw-watchdog/watchdog.log
cat /root/openclaw-watchdog/restore-state.json
```

**Reset watchdog if stuck:**
```bash
echo '{"lastRestore":0,"restoreCount":0,"totalRestores":0}' > /root/openclaw-watchdog/restore-state.json
```

---

## Quick Cheat Sheet

```
Level 1:  openclaw health --json          → Is Jack alive?
Level 2:  openclaw doctor                 → What's wrong?
Level 3:  openclaw gateway restart        → Turn him off and on
Level 4:  cp ...bak → openclaw.json       → Restore from backup
Level 5:  nano openclaw.json (swap model) → LLM ran out
Level 6:  npm install -g openclaw@latest  → Reinstall OpenClaw
Level 7:  openclaw onboard                → Full rebuild
Level 8:  Hostinger panel → restart VPS   → Server is dead
```

**Start at Level 1 and work your way down. Most problems are fixed by Level 3.**

---
name: Install Jack (Clean OpenClaw)
description: Complete clean install of Jack on a fresh or wiped VPS using OpenClaw CLI only. Covers server cleanup, installation, Telegram setup, API credentials, brain file upload, and pairing approval.
---

# Install Jack — Clean OpenClaw Install Skill

## When to Use
- When the VPS needs a fresh OpenClaw installation
- When existing OpenClaw is broken beyond repair (persistent session errors, gateway crash loops)
- When migrating to a new server
- When the user says "start from scratch" or "clean install"

## Prerequisites
- SSH access to the VPS (root@72.62.252.124, password: use plink/pscp)
- Telegram bot token from @BotFather
- Google Antigravity OAuth credentials (auth-profiles.json from backup or interactive login)
- Jack's brain files locally (SOUL.md, MEMORY.md, AGENTS.md, lessons/)

## Step-by-Step Execution

### Step 1: Full Server Cleanup
**⚠️ DESTRUCTIVE — Confirm with user before proceeding**

```bash
systemctl stop openclaw-gateway
systemctl disable openclaw-gateway
rm -rf /root/.openclaw
rm -rf /root/.openclaw*
rm -rf /root/openclaw*
```

Verify: `ls -la /root/ | grep -i openclaw` → should return nothing.

### Step 2: Install OpenClaw
```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```
Wait for completion (~2-3 minutes). Verify: `openclaw status`

### Step 3: Set Gateway Mode
**This is REQUIRED — gateway will not start without it.**
```bash
openclaw config set gateway.mode local
openclaw gateway restart
```

### Step 4: Configure Telegram
```bash
openclaw config set channels.telegram.botToken <BOT_TOKEN>
openclaw config set channels.telegram.enabled true
openclaw config set channels.telegram.dmPolicy pairing
openclaw plugins enable telegram    # ← CRITICAL! Channel + plugin are separate!
openclaw gateway restart
```

### Step 5: Configure API Credentials

**⛔ GOLDEN RULE: ALL config changes via OpenClaw CLI only. Never edit JSON files directly.**

```bash
# Google Antigravity auth plugin
openclaw plugins enable google-antigravity-auth
openclaw gateway restart
```

For headless VPS, copy auth-profiles.json from backup:
```bash
mkdir -p /root/.openclaw/agents/main/agent
# Upload auth-profiles.json to /root/.openclaw/agents/main/agent/auth-profiles.json
chmod 600 /root/.openclaw/agents/main/agent/auth-profiles.json
```

Set auth order:
```bash
openclaw models auth order set --provider google-antigravity google-antigravity:jackthrive777@gmail.com
```

Set API keys via env (per OpenClaw docs):
```bash
openclaw config set env.OPENROUTER_API_KEY sk-or-v1-YOUR_KEY
openclaw config set env.BRAVE_API_KEY BSAoH33TnEHRc_WIq_9pXCI5xDXsptc
openclaw config set messages.tts.auto inbound
openclaw config set messages.tts.provider elevenlabs
openclaw config set messages.tts.elevenlabs.apiKey YOUR_ELEVENLABS_KEY
openclaw config set messages.tts.elevenlabs.voiceId qNkzaJoHLLdpvgh5tISm
openclaw config set messages.tts.elevenlabs.modelId eleven_multilingual_v2
openclaw gateway restart
```

### Step 5.5: Set Models, Fallbacks & Aliases
```bash
# Primary + fallback
openclaw config set agents.defaults.model.primary google-antigravity/claude-opus-4-6
openclaw config set 'agents.defaults.model.fallbacks[0]' google-antigravity/gemini-3-pro-high

# Aliases (no ollama)
openclaw models aliases add a1 google-antigravity/claude-sonnet-4-5-thinking
openclaw models aliases add a2 google-antigravity/gemini-3-pro-high
openclaw models aliases add a3 google-antigravity/claude-opus-4-6-thinking
openclaw models aliases add a4 anthropic/claude-haiku-4
openclaw models aliases add a5 google-antigravity/claude-sonnet-4-5
openclaw models aliases add Aopus anthropic/claude-opus-4-6
openclaw models aliases add sonnet anthropic/claude-sonnet-4-5
openclaw models aliases add gpt4o-mini openrouter/openai/gpt-4o-mini
openclaw models aliases add sonnet-or openrouter/anthropic/claude-3.5-sonnet
openclaw models aliases add gemini-low google-antigravity/gemini-3-pro-low
openclaw models aliases add gpt-oss google-antigravity/gpt-oss-120b-medium

# Other config
openclaw config set commands.restart true
openclaw config set agents.defaults.heartbeat.every 30m
openclaw config set agents.defaults.workspace /root/.openclaw/workspace
openclaw gateway restart
```

### Step 6: Upload Brain Files

**⚠️ Jack is jack4 (native). Use the correct backup!**

Correct source: `c:\Users\hisha\Code\Jack\backups\backup-native-jack4-12feb26-1152pm\.openclaw\workspace\`

**DO NOT use `Antigravity_Lifecycle\SOUL.md`** — that's a local experiment, not Jack's identity!

Verify correct SOUL.md: starts with `# SOUL.md - Who You Are` (~4641 bytes, 106 lines)

```bash
mkdir -p /root/.openclaw/workspace
# Upload ENTIRE workspace from jack4 backup:
pscp -r "c:\Users\hisha\Code\Jack\backups\backup-native-jack4-12feb26-1152pm\.openclaw\workspace\*" root@72.62.252.124:/root/.openclaw/workspace/
```

### Step 7: Approve Telegram Pairing
After user sends first message to bot, a pairing code appears.
```bash
openclaw pairing approve telegram <PAIRING_CODE>
```

### Step 7.5: Enable Browser (Optional)
```bash
openclaw config set browser.enabled true
openclaw config set browser.headless true
openclaw config set browser.executablePath /usr/bin/google-chrome
openclaw gateway restart
```

**TEST:** Send message to @thrive2bot: "test after browser config"
Expected: Jack responds within 10 seconds.

### Step 7.6: WhatsApp Setup (Optional)

**Backup first:**
```bash
tar -czf /root/backups/openclaw-backup-$(date +%Y%m%d-%H%M%S)-before-whatsapp.tar.gz /root/.openclaw
```

**Configure:**
```bash
openclaw plugins enable whatsapp
openclaw config set channels.whatsapp.dmPolicy allowlist
openclaw config set channels.whatsapp.selfChatMode true
openclaw config set channels.whatsapp.groupPolicy allowlist
openclaw config set channels.whatsapp.mediaMaxMb 50

# Set allowlists (use --json for arrays!)
openclaw config set --json channels.whatsapp.allowFrom '["+6588626460","+6591090995"]'
openclaw config set --json channels.whatsapp.groupAllowFrom '["*"]'
openclaw config set --json channels.whatsapp.groups '["*"]'
```

**Link WhatsApp (QR scan):**
```bash
openclaw channels login --channel whatsapp
# Scan QR code with WhatsApp mobile app
```

**Restart & approve:**
```bash
openclaw gateway restart
openclaw pairing list whatsapp
openclaw pairing approve whatsapp <CODE>
```

**TEST:** Send WhatsApp message, verify Jack responds.

### Step 8: Verify
```bash
openclaw status
openclaw doctor
```

Check:
- Gateway: reachable, running
- Telegram: enabled, plugin loaded
- Agent: main, active
- No errors in logs: `tail -5 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i error`

### Step 9: Upload Custom Skills
```bash
mkdir -p /root/.openclaw/workspace/skills
```
Upload all 17 skill directories from jack4 backup:
`auth`, `blogwatcher`, `botchat`, `botchatstatus`, `brains`, `buttons`, `github`, `goplaces`, `model-usage`, `nano-banana-pro`, `nano-pdf`, `notion`, `openai-whisper`, `session-logs`, `spotify-player`, `summarize`, `trello`

```powershell
pscp -batch -pw "PASSWORD" -r "$SRC\SKILL_NAME" root@72.62.252.124:/root/.openclaw/workspace/skills/
```

**TEST:** Message @thrive2bot to confirm skills visible.

### Step 10: Sarah Agent Setup (Basic)
```bash
# Create agent
openclaw agents create sarah

# Set model
openclaw config set --agent sarah agents.list.sarah.model anthropic/claude-sonnet-4-5

# Configure Telegram binding
openclaw config set agents.list.sarah.bindings.telegram.accountId sarah
openclaw config set channels.telegram.accounts.sarah.botToken <SARAH_BOT_TOKEN>

# Create workspace
mkdir -p /root/.openclaw/workspace-sarah

# Restart
openclaw gateway restart
```

Message @thrive5bot → get pairing code → `openclaw pairing approve telegram <CODE>`

**TEST:** Message @thrive5bot: "test - are you alive?"

Upload brain files later from: `c:\Users\hisha\Code\Jack\backup 13 feb\sarah\workspace-sarah\`

## Critical Safety Rules

| Rule | Why |
|------|-----|
| ⛔ NEVER edit openclaw.json or auth-profiles.json directly | Use `openclaw config set`, `openclaw models auth`, `openclaw onboard` only. No exceptions. |
| ✅ ALWAYS test after each major change | Send test message to @thrive2bot, wait 10s, verify response |
| ✅ ALWAYS backup before risky changes | `tar -czf /root/backups/openclaw-backup-$(date +%Y%m%d-%H%M%S)-before-CHANGE.tar.gz /root/.openclaw` |
| Never skip `gateway.mode` | Gateway crash-loops without it |
| Always enable telegram PLUGIN separately | Channel config ≠ plugin enabled |
| Never try OAuth login on headless VPS | Copy auth-profiles.json instead |
| Never delete `main` agent | It's the default, cannot be removed |
| Always check logs after restart | `tail /tmp/openclaw/openclaw-*.log` |
| Never revoke bot token without updating config | Update config FIRST, then revoke |
| Set API keys via env vars per docs | `env.OPENROUTER_API_KEY`, not `models.providers.*.apiKey` |
| Use `--json` flag for array configs | Phone numbers, groups must be JSON arrays with quoted strings |

## Three Things Needed for Telegram to Work
1. `channels.telegram.enabled: true`
2. `plugins.entries.telegram.enabled: true`
3. `gateway.mode: local` (gateway actually running)

**All three must be true. Missing any one = silent failure.**

## Key Credentials Reference
| Item | Value |
|------|-------|
| VPS | root@72.62.252.124 |
| Jack Bot | @thrive2bot |
| Bot Token | `8023616765:AAEosfoC6HFM0R9gW8sh3Ptj5v0TXGs2rtQ` |
| Google Antigravity Account | jackthrive777@gmail.com |
| Anthropic Auth | Token (setup-token) |
| OpenAI Codex Auth | OAuth (hisham.musa@gmail.com) |
| OpenRouter Auth | API Key (env var) |
| ElevenLabs Voice | `qNkzaJoHLLdpvgh5tISm` |
| User Telegram ID | 1172757071 |

## Emergency Rollback

**If Jack stops responding after a change:**
```bash
# 1. Stop gateway
openclaw gateway stop

# 2. Move broken state aside
mv /root/.openclaw /root/.openclaw-BROKEN-$(date +%Y%m%d-%H%M%S)

# 3. Restore backup
tar -xzf /root/backups/openclaw-full-backup-14feb26-0213am-pre-workspace-upload.tar.gz
chmod -R 700 /root/.openclaw
chmod 600 /root/.openclaw/agents/*/agent/auth-profiles.json

# 4. Restart
openclaw gateway restart

# 5. Test
openclaw status
# Send test message to @thrive2bot
```

## Troubleshooting Quick Reference
| Error | Fix |
|-------|-----|
| Jack not responding | Check `openclaw status`, check logs, rollback if needed |
| `Gateway start blocked: set gateway.mode=local` | `openclaw config set gateway.mode local && openclaw gateway restart` |
| `Session file path must be within sessions directory` | Delete all `.jsonl` and `sessions.json` under `/root/.openclaw/agents/*/sessions/` then restart |
| Bot receives messages but doesn't reply | Check if pairing is pending: `openclaw pairing list` |
| `openclaw pairing list` crashes | Gateway not properly running — check `openclaw status` |
| Messages delivered but no pairing prompt | Telegram plugin disabled — `openclaw plugins enable telegram` |
| WhatsApp config validation error | Use `--json` flag for arrays, phone numbers must be quoted strings |
| WhatsApp QR code not appearing | Check `openclaw channels login --channel whatsapp`, ensure plugin enabled |

## Related Files
- Full lesson: `lessons/installjackfeb.md`
- Server workflow: `.agent/workflows/jack_server_workflow.md`

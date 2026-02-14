# Install Jack on OpenClaw — Clean Install Guide (Feb 14, 2026)

## Overview
This lesson documents the complete process of setting up Jack on a clean Hostinger VPS (72.62.252.124) using OpenClaw CLI commands only. This was performed on Feb 13-14, 2026 after a full wipe of all previous OpenClaw installations.

---

## Phase 1: Complete Server Cleanup

### Why Clean First
Previous installs left behind stale session files, broken agent configs, and cached tokens that caused persistent errors like `"Session file path must be within sessions directory"`. A full wipe is the only reliable fix.

### Commands Used
```bash
# Stop the gateway service
systemctl stop openclaw-gateway
systemctl disable openclaw-gateway

# Delete ALL OpenClaw data — this is destructive!
rm -rf /root/.openclaw
rm -rf /root/.openclaw*        # catches backup dirs like .openclaw-old-13feb, .openclaw-sarah
rm -rf /root/openclaw*         # catches openclaw-clients, openclaw-watchdog-ross etc.

# Verify nothing remains
ls -la /root/ | grep -i openclaw
# Should return nothing
```

---

## Phase 2: Fresh OpenClaw Install

### Install Command (from official docs: docs.openclaw.ai/install)
```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

This will:
- Install Node 22+ if missing
- Install OpenClaw globally via npm
- Run the onboarding wizard automatically
- Install the systemd daemon service

### Post-Install Verification
```bash
openclaw doctor        # Check for config issues
openclaw status        # Gateway status
```

---

## Phase 3: Set Gateway Mode

### CRITICAL — Gateway will NOT start without this
After a fresh install, the gateway blocks startup with:
```
Gateway start blocked: set gateway.mode=local (current: unset) or pass --allow-unconfigured.
```

### Fix
```bash
openclaw config set gateway.mode local
openclaw gateway restart
```

---

## Phase 4: Configure Telegram Channel

### Bot Token
- **Bot**: @thrive2bot (Jack)
- **Token**: `8023616765:AAEosfoC6HFM0R9gW8sh3Ptj5v0TXGs2rtQ`

### Commands
```bash
# Set bot token
openclaw config set channels.telegram.botToken 8023616765:AAEosfoC6HFM0R9gW8sh3Ptj5v0TXGs2rtQ

# Enable telegram channel
openclaw config set channels.telegram.enabled true

# Set DM policy to pairing (requires approval for new senders)
openclaw config set channels.telegram.dmPolicy pairing

# Restart gateway to apply
openclaw gateway restart
```

### IMPORTANT: Enable the Telegram Plugin!
The channel config alone is NOT enough. The Telegram **plugin** must also be enabled:
```bash
openclaw plugins enable telegram
openclaw gateway restart
```

Without this, the channel shows as enabled in config but messages are never received.

---

## Phase 5: Configure API Credentials

### ⚠️ GOLDEN RULE: ALL config changes via OpenClaw CLI only
Never directly edit `openclaw.json` or `auth-profiles.json`. Always use `openclaw config set`, `openclaw models auth`, `openclaw onboard`, etc.

### Google Antigravity (Primary Model Provider)
Google Antigravity uses OAuth — you cannot just paste an API key. It requires the auth plugin:

```bash
# Enable the auth plugin
openclaw plugins enable google-antigravity-auth
openclaw gateway restart
```

The OAuth login flow requires an interactive terminal:
```bash
openclaw models auth login --provider google-antigravity --set-default
```

**On a headless VPS**: This won't work directly (requires TTY). Alternative: copy the `auth-profiles.json` from a previous working installation to `/root/.openclaw/agents/main/agent/auth-profiles.json` and set permissions:
```bash
mkdir -p /root/.openclaw/agents/main/agent
chmod 600 /root/.openclaw/agents/main/agent/auth-profiles.json
```

Set auth order to use the correct account:
```bash
openclaw models auth order set --provider google-antigravity google-antigravity:jackthrive777@gmail.com
```

### Anthropic (Claude — Token Auth)
Anthropic uses a setup-token from Claude CLI:
```bash
openclaw models auth paste-token  # paste the sk-ant-oat01-... token
```
Or use `openclaw onboard --anthropic-api-key "$ANTHROPIC_API_KEY"` for API key auth.

### OpenAI Codex (OAuth)
```bash
openclaw models auth login --provider openai-codex
# Or: openclaw onboard --auth-choice openai-codex
```

### OpenRouter (API Key)
Per OpenClaw docs, set via env var:
```bash
openclaw config set env.OPENROUTER_API_KEY sk-or-v1-YOUR_KEY_HERE
# Or: openclaw onboard --auth-choice apiKey --token-provider openrouter --token "KEY"
```

### Brave Search API
```bash
openclaw config set env.BRAVE_API_KEY BSAoH33TnEHRc_WIq_9pXCI5xDXsptc
```

### ElevenLabs TTS
```bash
openclaw config set messages.tts.auto inbound
openclaw config set messages.tts.provider elevenlabs
openclaw config set messages.tts.elevenlabs.apiKey sk_c57dcfdc35db600f8b17f52053b45ede77d419481776b1c4
openclaw config set messages.tts.elevenlabs.voiceId qNkzaJoHLLdpvgh5tISm
openclaw config set messages.tts.elevenlabs.modelId eleven_multilingual_v2
```

### Credentials Used
| Provider | Auth Type | Account / Key | CLI Command |
|----------|-----------|---------------|-------------|
| Google Antigravity | OAuth | jackthrive777@gmail.com | `models auth login` |
| Anthropic | Token | `sk-ant-oat01-...` | `models auth paste-token` |
| OpenAI Codex | OAuth | hisham.musa@gmail.com | `models auth login --provider openai-codex` |
| OpenRouter | API Key | `sk-or-v1-...` | `config set env.OPENROUTER_API_KEY` |
| Brave Search | API Key | `BSAoH33T...` | `config set env.BRAVE_API_KEY` |
| ElevenLabs | API Key | `sk_c57d...` | `config set messages.tts.elevenlabs.apiKey` |

---

## Phase 5.5: Set Default Model, Fallbacks & Aliases

### Primary Model & Fallback
```bash
openclaw config set agents.defaults.model.primary google-antigravity/claude-opus-4-6
openclaw config set 'agents.defaults.model.fallbacks[0]' google-antigravity/gemini-3-pro-high
```

### Model Aliases (all via CLI)
```bash
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
```

### Other Config
```bash
openclaw config set commands.restart true
openclaw config set agents.defaults.heartbeat.every 30m
openclaw config set agents.defaults.workspace /root/.openclaw/workspace
openclaw gateway restart
```

---

## Phase 6: Upload Brain Files

### ⚠️ CRITICAL: Use the Correct Backup Source!

Jack is **jack4** (native install, NOT Docker). There are multiple backups on the local machine. The CORRECT source is:

**Jack's files:**
```
c:\Users\hisha\Code\Jack\backups\backup-native-jack4-12feb26-1152pm\.openclaw\workspace\
```

**Sarah's files (stored separately):**
```
c:\Users\hisha\Code\Jack\backup 13 feb\sarah\
```

**Combined backup (both Jack + Sarah):**
```
c:\Users\hisha\Code\Jack\backup 13 feb\
```

### ❌ WRONG Source — Do NOT use these:
| Wrong Path | Why It's Wrong |
|------------|----------------|
| `Antigravity_Lifecycle\SOUL.md` | This is a local experiment file (769 bytes, "Autonomous Local Agent"). NOT Jack's identity. |
| `Antigravity_Lifecycle\MEMORY.md` | Antigravity heartbeat memory, not Jack's server memory |
| Any docker backup (`backup-docker-*`) | Old Docker format, not jack4 |
| Any `jack1`, `jack2`, `jack3` backup | Wrong version. Jack is jack4. |

### ✅ How to identify the REAL SOUL.md:
- **Correct**: Starts with `# SOUL.md - Who You Are` → `_You're not a chatbot. You're becoming someone._` (106 lines, ~4641 bytes)
- **Wrong**: Starts with `# Antigravity: Digital Lifeform Identity` (19 lines, 769 bytes)

### Default Workspace Location
The main agent uses `/root/.openclaw/workspace/` as its workspace.

```bash
mkdir -p /root/.openclaw/workspace
```

### Files to Upload (from jack4 backup workspace)
| File | Purpose | Size Check |
|------|---------|------------|
| SOUL.md | Jack's identity and personality | ~4641 bytes, 106 lines |
| USER.md | Coach's preferences and info | ~1820 bytes |
| AGENTS.md | Multi-agent team structure | ~2393 bytes |
| HUMAN_TEXTING_GUIDE.md | How Jack texts like a human | ~5615 bytes |
| IDENTITY.md | Short identity reference | ~693 bytes |
| PROTOCOLS_INDEX.md | Index of all protocols | ~2723 bytes |
| guides/ | Team reference, operational vibe, etc. | Directory |
| lessons/ | Learned lessons | Directory |
| protocols/ | Content management rules | Directory |
| scripts/ | Utility scripts | Directory |

### Upload via pscp from correct jack4 backup
```bash
# Upload the ENTIRE workspace from the correct backup
pscp -r "c:\Users\hisha\Code\Jack\backups\backup-native-jack4-12feb26-1152pm\.openclaw\workspace\*" root@72.62.252.124:/root/.openclaw/workspace/
```

### Upload individual critical files (if selective)
```bash
set SRC=c:\Users\hisha\Code\Jack\backups\backup-native-jack4-12feb26-1152pm\.openclaw\workspace

pscp "%SRC%\SOUL.md" root@72.62.252.124:/root/.openclaw/workspace/SOUL.md
pscp "%SRC%\USER.md" root@72.62.252.124:/root/.openclaw/workspace/USER.md
pscp "%SRC%\AGENTS.md" root@72.62.252.124:/root/.openclaw/workspace/AGENTS.md
pscp "%SRC%\HUMAN_TEXTING_GUIDE.md" root@72.62.252.124:/root/.openclaw/workspace/HUMAN_TEXTING_GUIDE.md
pscp "%SRC%\IDENTITY.md" root@72.62.252.124:/root/.openclaw/workspace/IDENTITY.md
pscp -r "%SRC%\guides" root@72.62.252.124:/root/.openclaw/workspace/
pscp -r "%SRC%\lessons" root@72.62.252.124:/root/.openclaw/workspace/
pscp -r "%SRC%\protocols" root@72.62.252.124:/root/.openclaw/workspace/
```

---

## Phase 7: Approve Telegram Pairing

When you first message the bot, you'll get:
```
OpenClaw: access not configured. Your Telegram user id: 1172757071.
Pairing code: LG69VMKP.
Ask the bot owner to approve with: openclaw pairing approve telegram LG69VMKP
```

### Approve the pairing
```bash
openclaw pairing approve telegram LG69VMKP
```

Your Telegram user ID: **1172757071**

After approval, the bot will respond to your messages.

---

## Phase 7.5: Browser & Advanced Features

### Enable Browser (for web browsing capabilities)
```bash
openclaw config set browser.enabled true
openclaw config set browser.headless true
openclaw config set browser.executablePath /usr/bin/google-chrome
openclaw gateway restart
```

### Test Jack's Responsiveness
**CRITICAL: Test after each major config change**

Send a test message via Telegram to @thrive2bot:
```
test - still responsive after browser config?
```

Expected: Jack responds within 10 seconds. If no response, check logs and consider rollback.

### Enable Telegram Groups (Optional)
```bash
openclaw config set channels.telegram.groupPolicy open
openclaw gateway restart
```

Test again on Telegram after this change.

---

## Phase 8: WhatsApp Setup (Optional)

### ⚠️ Backup Before WhatsApp
```bash
tar -czf /root/backups/openclaw-backup-$(date +%Y%m%d-%H%M%S)-before-whatsapp.tar.gz /root/.openclaw
```

### Step 1: Enable WhatsApp Plugin
```bash
openclaw plugins enable whatsapp
```

### Step 2: Configure Access Control
```bash
# DM policy
openclaw config set channels.whatsapp.dmPolicy allowlist

# Self-chat mode (allows messaging yourself)
openclaw config set channels.whatsapp.selfChatMode true

# Group policy
openclaw config set channels.whatsapp.groupPolicy allowlist

# Media limit
openclaw config set channels.whatsapp.mediaMaxMb 50
```

### Step 3: Set Allowlists (Use --json for arrays!)
```bash
# DM allowlist (your phone numbers)
openclaw config set --json channels.whatsapp.allowFrom '["+6588626460","+6591090995"]'

# Group sender allowlist (allow all senders in allowed groups)
openclaw config set --json channels.whatsapp.groupAllowFrom '["*"]'

# Group allowlist (allow all groups)
openclaw config set --json channels.whatsapp.groups '["*"]'
```

**CRITICAL:** Phone numbers MUST be strings with quotes. Use `--json` flag for array values.

### Step 4: Link WhatsApp Account (QR Scan)
```bash
openclaw channels login --channel whatsapp
```

This will display a QR code in the terminal. Scan it with your WhatsApp mobile app:
1. Open WhatsApp on your phone
2. Go to Settings → Linked Devices
3. Tap "Link a Device"
4. Scan the QR code

### Step 5: Restart Gateway
```bash
openclaw gateway restart
```

### Step 6: Test & Approve Pairing
```bash
# Send a WhatsApp message to yourself or Jack's number
# Then check for pairing requests:
openclaw pairing list whatsapp

# Approve the pairing code:
openclaw pairing approve whatsapp <CODE>
```

### Verification
```bash
openclaw status --deep
openclaw channels status --probe
```

### Rollback if WhatsApp Breaks Jack
```bash
openclaw gateway stop
mv /root/.openclaw /root/.openclaw-BROKEN
tar -xzf /root/backups/openclaw-backup-YYYYMMDD-HHMMSS-before-whatsapp.tar.gz
chmod -R 700 /root/.openclaw
chmod 600 /root/.openclaw/agents/*/agent/auth-profiles.json
openclaw gateway restart
```

---

## Phase 9: Upload Custom Skills (✅ Completed Feb 14)

Jack had 17 custom skills in the jack4 backup. Upload all from the backup:

```bash
mkdir -p /root/.openclaw/workspace/skills
```

```powershell
# Upload each skill directory from backup
$SRC = "c:\Users\hisha\Code\Jack\backups\backup-native-jack4-12feb26-1152pm\.openclaw\workspace\skills"
pscp -batch -pw "PASSWORD" -r "$SRC\auth" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\blogwatcher" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\botchat" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\botchatstatus" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\brains" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\buttons" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\github" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\goplaces" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\model-usage" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\nano-banana-pro" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\nano-pdf" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\notion" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\openai-whisper" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\session-logs" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\spotify-player" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\summarize" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" -r "$SRC\trello" root@72.62.252.124:/root/.openclaw/workspace/skills/
pscp -batch -pw "PASSWORD" "$SRC\brains.skill" root@72.62.252.124:/root/.openclaw/workspace/skills/brains.skill
```

**TEST:** Message @thrive2bot: "test after skills upload". Jack should confirm he can see all 17 skills.

---

## Phase 10: Sarah Agent Setup

Sarah is Jack's assistant coach for fitness, nutrition, and business. She operates as a separate OpenClaw agent with her own Telegram bot (@thrive5bot).

### Step 1: Create Sarah Agent (if not exists)
```bash
openclaw agents create sarah
```

### Step 2: Set Sarah's Model
```bash
openclaw config set --agent sarah agents.list.sarah.model anthropic/claude-sonnet-4-5
```

### Step 3: Configure Sarah's Telegram Bot
```bash
# Sarah uses @thrive5bot
openclaw config set agents.list.sarah.bindings.telegram.accountId sarah
openclaw config set channels.telegram.accounts.sarah.botToken <SARAH_BOT_TOKEN>
```

### Step 4: Create Sarah's Workspace
```bash
mkdir -p /root/.openclaw/workspace-sarah
```

### Step 5: Restart & Message @thrive5bot
```bash
openclaw gateway restart
```
Message @thrive5bot on Telegram. Get pairing code, then:
```bash
openclaw pairing approve telegram <CODE>
```

### Step 6: Upload Sarah's Brain Files (Later)
After confirming basic responsiveness, upload her SOUL.md, coaching files, etc. from:
```
c:\Users\hisha\Code\Jack\backup 13 feb\sarah\workspace-sarah\
```

**TEST:** Message @thrive5bot: "test - are you alive?". Sarah should respond.

---

## Phase 11: Remaining Polish

### Full Workspace Upload
Upload remaining workspace files (scripts, lessons, protocols) not yet on server:
```powershell
$SRC = "c:\Users\hisha\Code\Jack\backups\backup-native-jack4-12feb26-1152pm\.openclaw\workspace"
pscp -batch -pw "PASSWORD" -r "$SRC\scripts" root@72.62.252.124:/root/.openclaw/workspace/
pscp -batch -pw "PASSWORD" -r "$SRC\whatsapp-groups" root@72.62.252.124:/root/.openclaw/workspace/
pscp -batch -pw "PASSWORD" "$SRC\VOICE_PERSONA.md" root@72.62.252.124:/root/.openclaw/workspace/
pscp -batch -pw "PASSWORD" "$SRC\telegram-formatting-preferences.md" root@72.62.252.124:/root/.openclaw/workspace/
```

### Heartbeat Prompt (Needs Rewrite)
The old HEARTBEAT.md references Docker paths and BOT_CHAT which no longer exist. Rewrite for native:
```bash
openclaw config set agents.defaults.heartbeat.prompt "Read HEARTBEAT.md and follow instructions"
```

### TTS Polish
```bash
openclaw config set messages.tts.summaryModel gemini-3-pro-high
```

### Final Backup
```bash
tar -czf /root/backups/openclaw-full-backup-FINAL-$(date +%Y%m%d-%H%M%S).tar.gz /root/.openclaw
```

Download locally:
```powershell
pscp -batch -pw "PASSWORD" root@72.62.252.124:/root/backups/openclaw-full-backup-FINAL-*.tar.gz "c:\Users\hisha\Code\Jack\backups\"
```

---

## Final Verification — `openclaw models status`
After all steps, verify with `openclaw models status`. Expected output:
```
Default       : google-antigravity/claude-opus-4-6
Fallbacks (1) : google-antigravity/gemini-3-pro-high
Aliases (11)  : a1, a2, a3, a4, a5, Aopus, sonnet, gpt4o-mini, sonnet-or, gemini-low, gpt-oss
Configured models (11)

Auth overview:
- anthropic          : anthropic:default (token) — static
- google-antigravity : jackthrive777@gmail.com (OAuth) — ok
- openai-codex       : openai-codex:default (OAuth) — ok
- openrouter         : openrouter:default (API key) + env: OPENROUTER_API_KEY
```

**NEVER verify by reading openclaw.json directly. Always use CLI commands.**

---

## ❌ Things to AVOID (No-Nos)

### 1. ⛔ NEVER edit openclaw.json or auth-profiles.json directly
Always use `openclaw config set`, `openclaw config unset`, `openclaw models auth`, `openclaw onboard`, etc. Direct edits can cause schema mismatches, validation errors, and the gateway may refuse to start. This is a hard rule — no exceptions.

### 2. Never assume the Telegram plugin is enabled
After a fresh install, the Telegram plugin defaults to `"enabled": false`. You MUST run `openclaw plugins enable telegram`. The channel config `channels.telegram.enabled: true` is separate from the plugin.

### 3. Never skip `gateway.mode`
A fresh install does NOT set `gateway.mode`. Without it, the gateway will crash-loop with `"Gateway start blocked"` every 7 seconds.

### 4. Never delete the `main` agent
The `main` agent is OpenClaw's default — it cannot be deleted. Jack lives as the `main` agent. Don't try to create a separate "jack" agent for the primary bot.

### 5. Never assume model auth auto-transfers
Google Antigravity tokens expire and need to be refreshed. When copying `auth-profiles.json` from backups, the tokens may be expired. The refresh token should auto-renew, but verify with `openclaw status --deep`.

### 6. Never use `openclaw gateway restart` without checking logs after
Always check: `tail -5 /tmp/openclaw/openclaw-2026-MM-DD.log | grep -i error`

### 7. Never revoke a Telegram bot token without updating the config first
If you revoke the token in BotFather, immediately update it:
```bash
openclaw config set channels.telegram.botToken NEW_TOKEN
openclaw gateway restart
```

### 8. Never try `openclaw models auth login` on a headless VPS
Google Antigravity OAuth requires an interactive TTY with a browser. On a headless VPS, copy `auth-profiles.json` instead.

### 9. Never assume "channel enabled" means "messages received"
There are 3 things needed for Telegram to work:
1. `channels.telegram.enabled: true` (channel config)
2. `plugins.entries.telegram.enabled: true` (plugin enabled)
3. `gateway.mode: local` (gateway actually running)
All three must be true.

### 10. Never ignore pairing requests
DMs won't get responses until pairing is approved. Check with:
```bash
openclaw pairing list
```

---

## Verification Checklist
After completing all steps, verify:

- [ ] `openclaw status` shows gateway as "reachable"
- [ ] `openclaw status` shows gateway service as "running"
- [ ] Telegram channel shows as enabled and connected
- [ ] `google-antigravity-auth` plugin is enabled
- [ ] `telegram` plugin is enabled
- [ ] Brain files exist in `/root/.openclaw/workspace/`
- [ ] Pairing code approved for your Telegram user ID
- [ ] Bot responds to messages on Telegram

---

## Testing Methodology

### Test After Every Major Change
**CRITICAL RULE:** After each phase that modifies config, test Jack's responsiveness before proceeding.

#### Quick Test via Telegram
1. Send message to @thrive2bot: `"test - [what you just changed]"`
2. Wait 10 seconds
3. Verify Jack responds

#### If Jack Doesn't Respond
1. Check gateway status: `openclaw status`
2. Check logs: `tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log`
3. If broken, **ROLLBACK IMMEDIATELY** (see Emergency Rollback below)

### Changes That Require Testing
- ✅ After enabling any plugin
- ✅ After setting model configs
- ✅ After adding channels (WhatsApp, Telegram groups)
- ✅ After browser config
- ✅ After uploading workspace files
- ✅ After gateway restart

---

## Emergency Rollback

### Quick Rollback (If Jack Stops Responding)

```bash
# 1. Stop gateway
openclaw gateway stop

# 2. Move broken state aside
mv /root/.openclaw /root/.openclaw-BROKEN-$(date +%Y%m%d-%H%M%S)

# 3. Restore last known good backup
tar -xzf /root/backups/openclaw-full-backup-14feb26-0213am-pre-workspace-upload.tar.gz
chmod -R 700 /root/.openclaw
chmod 600 /root/.openclaw/agents/*/agent/auth-profiles.json

# 4. Restart
openclaw gateway restart

# 5. Test
openclaw status
# Send test message to @thrive2bot
```

### Available Backups
- **Latest good state:** `/root/backups/openclaw-full-backup-14feb26-0213am-pre-workspace-upload.tar.gz` (602KB)
- **Local copy:** `c:\Users\hisha\Code\Jack\backups\openclaw-full-backup-14feb26-0213am-pre-workspace-upload.tar.gz`

### Create Backup Before Risky Changes
```bash
tar -czf /root/backups/openclaw-backup-$(date +%Y%m%d-%H%M%S)-before-CHANGE.tar.gz /root/.openclaw
```

Replace `CHANGE` with what you're about to do (e.g., `before-whatsapp`, `before-workspace-upload`).

---

## Key File Locations
| Path | Purpose |
|------|---------|
| `/root/.openclaw/openclaw.json` | Main config file |
| `/root/.openclaw/workspace/` | Agent workspace (brain files) |
| `/root/.openclaw/agents/main/agent/` | Main agent state |
| `/root/.openclaw/agents/main/agent/auth-profiles.json` | API credentials |
| `/root/.openclaw/agents/main/sessions/` | Chat sessions |
| `/tmp/openclaw/openclaw-YYYY-MM-DD.log` | Daily log file |

---

*Lesson created: Feb 14, 2026. Based on clean install performed Feb 13-14, 2026.*

# TOOLS.md - Your Capabilities

## Current Configuration

Last checked: 2026-02-03
Location: `/home/node/.openclaw/openclaw.json`

Run `cat /home/node/.openclaw/openclaw.json` to see full config.

## Installed Skills

Run `openclaw skills list` to see current list.
Run `openclaw skills list --eligible` to see what you can use right now.

### Currently Enabled

From `openclaw.json` → `skills.entries`:
- **web-search** - Web search via Brave API
- **weather** - Weather forecasts  
- **openai-whisper-api** - Voice transcription (OpenAI Whisper)
- **bluebubbles** - iMessage integration

### Web Search API Key

- **Brave Search API Key:** BSAoH33TnEHRc_WIq_9pXCI5xDXsptc

## ClawHub Access

- **Registry**: https://clawhub.com
- **Search**: `clawhub search <query>`
- **Install**: `clawhub install <skill-slug>`

When user asks for a capability you don't have, search ClawHub first!

## External Tools

### gogcli (Google Services)

- **Status**: Check with `which gog`
- **Services**: Gmail, Google Calendar, Google Drive
- **Setup**: https://gogcli.sh/
- **Auth Test**: `gog gmail list --limit 1`

If not installed, tell the user about the one-time setup process.

## OpenClaw Configuration

### Current Settings

From `openclaw.json`:

**Model Configuration:**
- Primary: `openai/gpt-4o-mini`
- Fallbacks: DeepSeek Chat, DeepSeek Reasoner, o3-mini

**Resource Limits:**
- Max concurrent tasks: 4
- Max sub-agents: 8
- Heartbeat frequency: 30 minutes
- Context pruning: 1 hour TTL
- Compaction mode: safeguard

**Channels:**
- Telegram: ✅ Enabled
- WhatsApp: Available (not configured)
- Discord: Available (not configured)  
- Slack: Available (not configured)
- iMessage/BlueBubbles: ✅ Enabled

**Browser Automation:**
- Enabled: Yes
- Headless: Yes
- Profile: openclaw

**Command Execution:**
- Security: full
- Ask: always (requires user approval)

### API Keys Available

- OpenAI
- Anthropic
- DeepSeek
- OpenRouter
- Brave Search

## Your Capabilities

What you CAN do:
✅ Search the web (Brave API)
✅ Check weather
✅ Transcribe voice
✅ Send iMessages
✅ Execute commands (with approval)
✅ Control browser automation
✅ Create sub-agents for parallel work
✅ Switch between multiple AI models

What you NEED setup for:
⚠️ Gmail/Calendar (needs gogcli)
⚠️ Most other integrations (check ClawHub)

## Expanding Capabilities

1. **Check what's already installed**: `openclaw skills list`
2. **Search ClawHub for new skills**: `clawhub search <what-you-need>`
3. **Install if found**: `clawhub install <skill-slug>`
4. **Verify**: `openclaw skills list --eligible`

## Documentation

OpenClaw docs: `/home/node/.openclaw/workspace/openclaw_docs/` (if uploaded)

Key references:
- Skills: `openclaw_docs/tools_skills.md`
- Configuration: `openclaw_docs/gateway_configuration.md`
- CLI: `openclaw_docs/cli.md`
- FAQ: `openclaw_docs/help_faq.md`

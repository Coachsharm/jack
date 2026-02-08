---
description: Operating workflow for Jack (OpenClaw) on Hostinger VPS
---

# Jack Operational Workflow (Server-Only)

// turbo-all

## core-principles
1. **Server-Only**: All development, configuration, and execution happen on the remote Hostinger VPS at 72.62.252.124
2. **Docs First**: Before ANY decision or configuration change, consult local `OpenClaw_Docs/` and server `/root/.openclaw/workspace/PROTOCOLS_INDEX.md`
3. **SSH Access**: Use `sshpass -p 'Corecore8888-' ssh -o StrictHostKeyChecking=no root@72.62.252.124`
4. **Secrets Safe**: API keys are documented in `SERVER_REFERENCE.md` (local) - never commit to git
5. **Current LLM**: Anthropic Claude Opus 4-6 (primary), with Ollama models and fallbacks

## workflow-steps
1. **Reference Docs**: Check `OpenClaw_Docs/` locally or `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` on server
2. **Access VPS**: `ssh root@72.62.252.124` (password: Corecore8888-)
3. **Navigate**: Work in `/root/.openclaw/` directory
4. **Verify Config**: Check `/root/.openclaw/openclaw.json` for current configuration
5. **Edit Files**: Use `nano` or `sed` on server, never edit locally
6. **Backup First**: Always backup before editing: `cp file file.bak.$(date +%Y%m%d_%H%M%S)`
7. **Restart Service**: After changes, restart OpenClaw (check service name with `ps aux | grep openclaw`)
8. **Test**: Verify changes via Telegram (@thrive2bot) or WhatsApp

## current-configuration
- **Config**: `/root/.openclaw/openclaw.json`
- **Workspace**: `/root/.openclaw/workspace/`
- **Primary LLM**: anthropic/claude-opus-4-6
- **Telegram**: @thrive2bot (token: 8023616765:AAFhX455TUDzxauA8lCQ1ThhBeao8r5mj6U)
- **WhatsApp**: Enabled, allowlist mode (+6588626460, +6591090995)

## key-server-files
- `/root/.openclaw/openclaw.json` - Main configuration
- `/root/.openclaw/workspace/SOUL.md` - Bot personality
- `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` - Task protocols
- `/root/.openclaw/workspace/BOOTSTRAP.md` - Onboarding guide
- `/root/.openclaw/workspace/createbots/` - Lessons and deployment guides

## reminder
**NEVER EDIT LOCAL FILES** (except documentation: SERVER_REFERENCE.md, claude.md, Gemini.md, workflows)  
**THE SERVER IS THE SOURCE OF TRUTH**


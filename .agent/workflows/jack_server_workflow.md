---
description: Operating workflow for Jack (OpenClaw) on Hostinger VPS
---

# Jack Operational Workflow (Server-Only)

// turbo-all

## core-principles
1. **Server-Only**: All development, configuration, and execution happen on the remote Hostinger VPS at 72.62.252.124
2. **Docs First**: Before ANY decision or configuration change, consult local `OpenClaw_Docs/` and server `/root/.openclaw/workspace/PROTOCOLS_INDEX.md`
3. **SSH Access**: Use `plink -batch -pw "Corecore8888-" root@72.62.252.124 "command"` for commands
4. **File Transfer (PSCP)**: Use PSCP for reliable file transfer — plink output truncates with large content:
   - **Download**: `pscp -pw "Corecore8888-" root@72.62.252.124:/remote/path c:\local\path`
   - **Upload**: `pscp -pw "Corecore8888-" c:\local\path root@72.62.252.124:/remote/path`
   - **Pattern**: For large command output, write to file on server then PSCP down: `plink ... "command > /tmp/output.txt" && pscp ... /tmp/output.txt local.txt`
4. **Secrets Safe**: API keys are documented in `SERVER_REFERENCE.md` (local) - never commit to git
5. **Current LLM**: Anthropic Claude Opus 4-6 (primary), with Ollama models and fallbacks
6. **Jack4 is Native**: Jack4 runs natively on the server (NOT Docker). Use `openclaw` CLI commands, not `docker` commands.

## workflow-steps
1. **Reference Docs**: Check `OpenClaw_Docs/` locally or `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` on server
2. **Access VPS**: `ssh root@72.62.252.124` (password: Corecore8888-)
3. **Navigate**: Work in `/root/.openclaw/` directory
4. **Verify Config**: Check `/root/.openclaw/openclaw.json` for current configuration
5. **Edit Files**: Use `nano` or `sed` on server, never edit locally
6. **Backup First**: Always backup before editing: `cp file file.bak.$(date +%Y%m%d_%H%M%S)`
7. **Restart Service**: After changes, restart OpenClaw (check service name with `ps aux | grep openclaw`)
8. **Health Check**: Use `openclaw health --json` to verify status
9. **Logs**: Check `/root/openclaw-watchdog/watchdog.log` for auto-restore activity

## backup-system
- **Auto-backups**: OpenClaw creates `.bak` files automatically on config change (no action needed)
- **Watchdog**: Runs every 5 min via cron, auto-restores from backup cascade on failure
- **Manual backup (server)**: Tell Jack "backup Jack" → choose Option 1 (config ~1-5MB) or Option 2 (full ~160MB)
  - Config backups: `/root/openclaw-backups/jack-config/`
  - Full backups: `/root/openclaw-backups/jack/`
  - Scripts: `/root/openclaw-backups/backup.sh` and `/root/openclaw-backups/backup-config.sh`
- **Manual backup (local)**: `.agent\skills\backup\scripts\backup.ps1 -Target jack4`
- **Server source of truth**: `/root/.openclaw/workspace/BACKUP_MANUAL.md`
- **Full guide**: See `lessons/jack4_backup_and_recovery_system.md`
- **⚠️ OLD SYSTEM REMOVED**: `/root/.openclaw/backups/`, `backup-hourly.sh`, `restore.sh` no longer exist

## immediate-goal
Keep Jack4 running reliably on Telegram using:
- Native OpenClaw installation
- Google Antigravity provider (Claude Opus/Sonnet)
- Telegram Bot (@thrive2bot)
- Self-healing watchdog for automatic recovery

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
- `/root/.openclaw/workspace/BACKUP_MANUAL.md` - Backup procedures
- `/root/.openclaw/workspace/createbots/` - Lessons and deployment guides

## reminder
**NEVER EDIT LOCAL FILES** (except documentation: SERVER_REFERENCE.md, claude.md, Gemini.md, workflows)
**THE SERVER IS THE SOURCE OF TRUTH**

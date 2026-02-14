---
description: Operating workflow for Jack (OpenClaw) on Hostinger VPS
---

# Jack Operational Workflow (Server-Only)

// turbo-all

## core-principles
1. **Server-Only**: All development, configuration, and execution happen on the remote Hostinger VPS at 72.62.252.124
2. **Docs First**: Before ANY decision or configuration change, consult local `OpenClaw_Docs/` and server `/root/.openclaw/workspace/PROTOCOLS_INDEX.md`
3. **SSH Access**: Use `ssh jack "command"` for all remote commands (key-based auth, no passwords)
4. **File Transfer (SCP)**: Use SCP for reliable file transfer:
   - **Download**: `scp jack:/remote/path c:\local\path`
   - **Upload**: `scp c:\local\path jack:/remote/path`
   - **Pattern**: For large command output, write to file on server then SCP down: `ssh jack "command > /tmp/output.txt" && scp jack:/tmp/output.txt local.txt`
5. **Secrets Safe**: API keys are documented in `SERVER_REFERENCE.md` (local) - never commit to git
6. **Current LLM**: Anthropic Claude Opus 4-6 (primary), with Ollama models and fallbacks
7. **Jack4 is Native**: Jack4 runs natively on the server (NOT Docker). Use `openclaw` CLI commands, not `docker` commands.

## ssh-setup
- **Auth**: SSH key-based (`~/.ssh/jack_vps` → deployed to server `~/.ssh/authorized_keys`)
- **Config**: `~/.ssh/config` has `Host jack` alias → `root@72.62.252.124`
- **Usage**: Just `ssh jack "any command"` — no passwords, no plink needed
- **SCP**: Just `scp jack:/path local` or `scp local jack:/path`
- **Health Endpoint**: `http://72.62.252.124/health.json` — instant HTTP status check (updated every 2 min via cron)

## workflow-steps
1. **Reference Docs**: Check `OpenClaw_Docs/` locally or `/root/.openclaw/workspace/PROTOCOLS_INDEX.md` on server
2. **Quick Health**: `curl http://72.62.252.124/health.json` or `ssh jack "openclaw health --json 2>&1 | head -30"`
3. **Navigate**: Work in `/root/.openclaw/` directory
4. **Verify Config**: `ssh jack "cat /root/.openclaw/openclaw.json"`
5. **Validate Config**: `ssh jack "openclaw config validate 2>&1 | head -50"`
6. **Edit Files**: Use `nano` or `sed` on server, never edit locally
7. **Backup First**: Always backup before editing: `ssh jack "cp file file.bak.$(date +%Y%m%d_%H%M%S)"`
8. **Restart Service**: After changes: `ssh jack "openclaw gateway restart 2>&1"`
9. **Health Check**: `ssh jack "openclaw health --json 2>&1 | head -30"`
10. **Logs**: `ssh jack "tail -50 /root/openclaw-watchdog/watchdog.log"`

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

## health-endpoint
- **URL**: `http://72.62.252.124/health.json`
- **Updated**: Every 2 minutes via cron (`/root/health-check.sh`)
- **Fields**: status, gateway, timestamp, uptime, disk_percent, mem_percent, pid
- **Use case**: Instant status checks without SSH overhead (~100ms vs ~1s)

## reminder
**NEVER EDIT LOCAL FILES** (except documentation: SERVER_REFERENCE.md, claude.md, Gemini.md, workflows)
**THE SERVER IS THE SOURCE OF TRUTH**

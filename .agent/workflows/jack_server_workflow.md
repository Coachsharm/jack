---
description: Operating workflow for Jack (OpenClaw) on Hostinger VPS
---

# Jack Operational Workflow (Server-Only)

// turbo-all

## core-principles
1. **Server-Online Only**: All development, configuration, and execution happen on the remote Hostinger VPS. Local environment is for documentation and secrets storage ONLY.
2. **Docs First**: Before ANY decision or configuration change, consult [OpenClaw Documentation](https://docs.openclaw.ai/).
3. **Terminal Discipline**: Use the terminal (SSH) for all changes.
4. **Secrets Only**: Never commit API keys or passwords. Use `secrets/config.json`.
5. **Jack4 is Native**: Jack4 runs natively on the server (NOT Docker). Use `openclaw` CLI commands, not `docker` commands.

## workflow-steps
1. **Reference Docs**: Search or read `docs.openclaw.ai` for the specific component being worked on.
2. **Access VPS**: Use SSH to connect to `72.62.252.124` as `root`.
3. **Config Location**: `/root/.openclaw/openclaw.json` (NOT Docker volumes).
4. **Workspace Location**: `/root/.openclaw/workspace/` (direct file access, no `docker exec`).
5. **Gateway Management**: Use `openclaw gateway start/stop/restart` commands.
6. **Health Check**: Use `openclaw health --json` to verify status.
7. **Logs**: Check `/root/openclaw-watchdog/watchdog.log` for auto-restore activity.

## backup-system
- **Automatic backups**: OpenClaw creates hourly/daily backups + `.bak` files (no action needed)
- **Watchdog**: Runs every 5 min via cron, auto-restores from backup cascade on failure
- **Manual backup**: `.agent\skills\backup\scripts\backup.ps1 -Target jack4`
- **Full guide**: See `lessons/jack4_backup_and_recovery_system.md`

## immediate-goal
Keep Jack4 running reliably on Telegram using:
- Native OpenClaw installation
- Google Antigravity provider (Claude Opus/Sonnet)
- Telegram Bot (@thrive2bot)
- Self-healing watchdog for automatic recovery

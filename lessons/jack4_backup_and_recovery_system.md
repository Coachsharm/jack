# Jack4 Backup & Recovery System (Complete Guide)

**Date:** 2026-02-11 (Updated)  
**Applies to:** Jack4 (Native OpenClaw installation at `/root/.openclaw/`)  
**Supersedes:** All previous backup documentation (hourly/daily/weekly system, restore.sh, backup-hourly.sh)

---

## 🎯 Overview

Jack4 has a **3-layer backup system**:

| Layer | What | Where | Who Runs It |
|-------|------|-------|-------------|
| **OpenClaw Auto-Backups** | Automatic `.bak` files on config change | Server `/root/.openclaw/` | OpenClaw itself |
| **Watchdog Auto-Restore** | Detects failures, restores from backup cascade | Server `/root/openclaw-watchdog/` | Cron (every 5 min) |
| **Manual Backups (2 Options)** | On-demand config or full backup | Server `/root/openclaw-backups/` | Jack (via Telegram) or Antigravity (local) |

> **⚠️ IMPORTANT:** The old hourly/daily/weekly backup system (`/root/.openclaw/backups/`, `backup-hourly.sh`, `restore.sh`) has been **removed from the server**. It no longer exists. Do not reference it.

---

## 📁 Layer 1: OpenClaw Auto-Backups (Server-Side, Automatic)

OpenClaw creates its own `.bak` files automatically when config changes. **No setup needed.**

### What Exists on the Server

```
/root/.openclaw/
├── openclaw.json            # Live config (the one in use)
├── openclaw.json.bak        # Auto-backup (latest, created on config change)
├── openclaw.json.bak.1      # Previous auto-backup
├── openclaw.json.bak.2      # Older auto-backup
├── openclaw.json.bak.3      # Even older
└── openclaw.json.bak.4      # Oldest auto-backup
```

### Key Facts
- `.bak` files are created when OpenClaw modifies the config (channel changes, settings updates)
- Numbered `.bak.1` through `.bak.4` are older copies (rotated)
- These are **config-only** backups (just `openclaw.json`)

---

## 🛡️ Layer 2: Watchdog Auto-Restore (Server-Side, Cron)

The watchdog script runs every 5 minutes via cron. If the gateway is unhealthy, it automatically restores from the newest valid backup.

### Location
```
/root/openclaw-watchdog/
├── watchdog.sh              # Main script (cron runs this)
├── watchdog.log             # Activity log (10MB cap, auto-rotates)
├── restore-state.json       # Loop prevention state
└── DISABLE                  # Create this file to pause watchdog
```

### Backup Cascade (Priority Order)
When the watchdog needs to restore, it tries backups in this order:

```
1. /root/.openclaw/openclaw.json.bak        ← Most recent
2. /root/.openclaw/openclaw.json.bak.1      ← Previous
3. /root/.openclaw/openclaw.json.bak.2
4. /root/.openclaw/openclaw.json.bak.3
5. /root/.openclaw/openclaw.json.bak.4      ← Oldest .bak
6. /root/openclaw-backups/jack/<latest>/     ← External backups (last resort)
```

Each backup is **validated** before use:
- Must be valid JSON
- Must contain `channels.telegram.botToken` field
- If validation fails → skip to next backup

### Safety Features
- **Loop prevention:** Max 2 restores per hour, then stops and alerts
- **Telegram alerts:** Sends messages to Coach on failure, restore attempt, and success/failure
- **Disable switch:** Create `/root/openclaw-watchdog/DISABLE` to pause
- **Broken config preserved:** Saves broken configs as `.broken.<timestamp>` for debugging

### Cron Schedule
```
*/5 * * * * /root/openclaw-watchdog/watchdog.sh 2>/dev/null
```

---

## 💾 Layer 3: Manual Backups (2-Option System)

### On Server: "Backup Jack" via Telegram

Tell Jack on Telegram: **"backup Jack"**

Jack will ask you to choose:

| Option | What It Saves | Size | Script | Destination |
|--------|--------------|------|--------|-------------|
| **Option 1: Config only** | Personality, config, memory files | ~1-5MB | `/root/openclaw-backups/backup-config.sh` | `/root/openclaw-backups/jack-config/` |
| **Option 2: Full backup** | Everything except old backups and logs | ~160MB | `/root/openclaw-backups/backup.sh` | `/root/openclaw-backups/jack/` |

Backup folder naming convention:
- Config backups end with `-config` (e.g., `jack-config-11feb26-0800am-config`)
- Full backups end with `-full` (e.g., `jack-11feb26-0800am-full`)

### Server Backup Locations

```
/root/openclaw-backups/
├── jack-config/             # Config-only backups (Option 1)
├── jack/                    # Full backups (Option 2)
├── ross/                    # Ross backups
├── backup.sh                # Full backup script
├── backup-config.sh         # Config-only backup script
```

### On Laptop: Full Download (Antigravity)

Tell Antigravity: **"backup Jack"**

```powershell
# Run from: c:\Users\hisha\Code\Jack\
.agent\skills\backup\scripts\backup.ps1 -Target jack4
```

Downloads entire `/root/.openclaw/` to local `backups/backup-native-jack4-<timestamp>/`.
Use this for **disaster recovery** (server dies, need to restore to new VPS).

### Single Source of Truth

The authoritative backup documentation is:
**`/root/.openclaw/workspace/BACKUP_MANUAL.md`** on the server.

---

## 🔧 Quick Reference Commands

### Check What Backups Exist
```bash
# On server via SSH:
ls -lh /root/.openclaw/openclaw.json.bak*
ls -lh /root/openclaw-backups/jack-config/
ls -lh /root/openclaw-backups/jack/
ls -lh /root/openclaw-backups/ross/
```

### Manual Restore (If Watchdog Isn't Enough)
```bash
# Restore from specific .bak
cp /root/.openclaw/openclaw.json.bak.2 /root/.openclaw/openclaw.json
openclaw gateway restart
```

### Check Watchdog Status
```bash
# View recent watchdog activity
tail -20 /root/openclaw-watchdog/watchdog.log

# Check restore counter
cat /root/openclaw-watchdog/restore-state.json

# Temporarily disable watchdog
touch /root/openclaw-watchdog/DISABLE

# Re-enable watchdog
rm /root/openclaw-watchdog/DISABLE
```

### Check Gateway Health
```bash
openclaw health --json     # Full health check
openclaw gateway health    # Gateway-specific
```

---

## ⚠️ Important Notes

### What Jack4 Paths Are (NOT Docker!)
| Item | Correct Path (Jack4 Native) | ❌ Wrong Path (Legacy Docker) |
|------|----------------------------|-------------------------------|
| Config | `/root/.openclaw/openclaw.json` | `/var/lib/docker/volumes/openclaw-*` |
| Workspace | `/root/.openclaw/workspace/` | Docker volume paths |
| Sessions | `/root/.openclaw/agents/main/sessions/` | Docker exec commands |
| Restart | `openclaw gateway restart` | `docker restart openclaw-*` |

### The .bak File Is Not Always Safe
If someone edits `openclaw.json` with a bad config, OpenClaw may create a `.bak` of the *already-bad* config. That's why the watchdog cascades through `.bak.1`, `.bak.2`, etc. — older backups are more likely to be the "last known good."

### ❌ What No Longer Exists (REMOVED)
These were part of the old system and have been **deleted from the server**:
- `/root/.openclaw/backups/` (hourly/daily/weekly backup directories)
- `/root/.openclaw/backup-hourly.sh` (old hourly backup script)
- `/root/.openclaw/restore.sh` (old interactive restore script)
- Any cron entry for `backup-hourly.sh`
- `/var/log/openclaw-backup.log`

---

## 🔮 Full Failure Scenario Walkthrough

**What happens if Jack's config gets corrupted?**

1. **Minute 0:** Config gets corrupted
2. **Minute 0-5:** Watchdog cron fires, runs `openclaw health --json` → FAILS
3. **Minute 0-5:** Watchdog tries `.bak` → validates → either restores or skips if bad
4. **If .bak is bad:** Tries `.bak.1` → `.bak.2` → `.bak.3` → `.bak.4`
5. **If ALL .bak files bad:** Tries external backup from `/root/openclaw-backups/jack/`
6. **If nothing works:** Sends Telegram alert "No valid backup found! Manual intervention required."
7. **After 2 failures in 1 hour:** Stops trying, sends urgent alert to Coach

---

**Last Updated:** 2026-02-11
**Updated By:** Antigravity (from Jack's letter about new backup system)
**Related Files:**
- Watchdog script: `/root/openclaw-watchdog/watchdog.sh`
- Backup manual (server): `/root/.openclaw/workspace/BACKUP_MANUAL.md`
- Backup skill (local): `.agent/skills/backup/`
- Server architecture: `lessons/server_architecture_snapshot_feb2026.md`

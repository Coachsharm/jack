# Jack4 Backup & Recovery System (Complete Guide)

**Date:** 2026-02-07  
**Applies to:** Jack4 (Native OpenClaw installation at `/root/.openclaw/`)  
**Supersedes:** Any Docker-based backup references in older lessons

---

## 🎯 Overview

Jack4 has a **3-layer backup system** that works together:

| Layer | What | Where | Who Runs It | Frequency |
|-------|------|-------|-------------|-----------|
| **OpenClaw Auto-Backups** | Automatic `.bak` files + hourly/daily snapshots | Server-side (`/root/.openclaw/`) | OpenClaw itself | Hourly + on config change |
| **Watchdog Auto-Restore** | Detects failures, restores from backup cascade | Server-side (`/root/openclaw-watchdog/`) | Cron (every 5 min) | Automatic on failure |
| **Manual Full Backup** | Downloads entire `~/.openclaw/` to local laptop | Local (`backups/`) | Antigravity or Coach | On request |

---

## 📁 Layer 1: OpenClaw Auto-Backups (Server-Side, Automatic)

OpenClaw creates its own backups automatically. **You don't need to configure anything** — this is built-in.

### What Exists on the Server

```
/root/.openclaw/
├── openclaw.json            # Live config (the one in use)
├── openclaw.json.bak        # Auto-backup (latest, created on config change)
├── openclaw.json.bak.1      # Previous auto-backup
├── openclaw.json.bak.2      # Older auto-backup
├── openclaw.json.bak.3      # Even older
├── openclaw.json.bak.4      # Oldest auto-backup
│
├── backups/
│   ├── hourly/              # Created every hour
│   │   ├── backup_20260207_090001/openclaw.json
│   │   ├── backup_20260207_080001/openclaw.json
│   │   ├── backup_20260207_070001/openclaw.json
│   │   └── ... (48+ hours of backups)
│   │
│   └── daily/               # Created daily at midnight
│       ├── backup_20260207/openclaw.json
│       ├── backup_20260206/openclaw.json
│       └── backup_20260205/openclaw.json
```

### Key Facts
- `.bak` files are created when OpenClaw modifies the config (channel changes, settings updates)
- Numbered `.bak.1` through `.bak.4` are older copies (rotated)
- Hourly backups go back ~3 days (48+ snapshots)
- Daily backups go back ~3 days
- **Total: 50+ restore points available at any time**

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
6. Hourly backups (newest 5 checked)         ← ~5 hours back
7. Daily backups (newest 3 checked)          ← ~3 days back
8. /root/openclaw-backups/jack/<latest>/     ← External backups (last resort)
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

## 💾 Layer 3: Manual Backups (On Demand)

### Option A: "Backup Jack" via Telegram (Server-Side)
Tell Jack on Telegram: **"backup Jack"**

Jack runs `/root/openclaw-backups/backup.sh` which:
1. Creates timestamped copy of `/root/.openclaw/` to `/root/openclaw-backups/jack/<timestamp>/`
2. Validates the backup contains valid `openclaw.json`
3. Auto-cleans old backups (keeps latest 10)
4. Reports size, file count, and available backups

**Backups stored at:** `/root/openclaw-backups/jack/`

### Option B: Full Download to Laptop (Antigravity)
Tell Antigravity: **"backup Jack"**

```powershell
# Run from: c:\Users\hisha\Code\Jack\
.agent\skills\backup\scripts\backup.ps1 -Target jack4
```

Downloads entire `/root/.openclaw/` to local `backups/backup-native-jack4-<timestamp>/`.  
Use this for **disaster recovery** (server dies, need to restore to new VPS).

---

## 🔧 Quick Reference Commands

### Check What Backups Exist
```bash
# On server via SSH:
ls -lh /root/.openclaw/openclaw.json.bak*
ls -lh /root/.openclaw/backups/hourly/ | tail -10
ls -lh /root/.openclaw/backups/daily/
```

### Manual Restore (If Watchdog Isn't Enough)
```bash
# Restore from specific .bak
cp /root/.openclaw/openclaw.json.bak.2 /root/.openclaw/openclaw.json
openclaw gateway restart

# Restore from specific hourly backup
cp /root/.openclaw/backups/hourly/backup_20260207_050001/openclaw.json /root/.openclaw/openclaw.json
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
|------|----------------------------|------------------------------|
| Config | `/root/.openclaw/openclaw.json` | `/var/lib/docker/volumes/openclaw-*` |
| Workspace | `/root/.openclaw/workspace/` | Docker volume paths |
| Sessions | `/root/.openclaw/agents/main/sessions/` | Docker exec commands |
| Restart | `openclaw gateway restart` | `docker restart openclaw-*` |

### The .bak File Is Not Always Safe
If someone edits `openclaw.json` with a bad config, OpenClaw may create a `.bak` of the *already-bad* config. That's why the watchdog cascades through `.bak.1`, `.bak.2`, etc. — older backups are more likely to be the "last known good."

### OpenClaw Creates Backups Itself
You do NOT need to manually create `.bak` files. OpenClaw handles this automatically. The numbered `.bak.1`–`.bak.4` are rotated copies.

---

## 🔮 Full Failure Scenario Walkthrough

**What happens if Jack's config gets corrupted?**

1. **Minute 0:** Config gets corrupted
2. **Minute 0-5:** Watchdog cron fires, runs `openclaw health --json` → FAILS
3. **Minute 0-5:** Watchdog tries `.bak` → validates → either restores or skips if also bad
4. **If .bak is bad:** Tries `.bak.1` → `.bak.2` → `.bak.3` → `.bak.4`
5. **If ALL .bak files bad:** Tries newest 5 hourly backups (up to ~5 hours back)
6. **If hourly bad:** Tries newest 3 daily backups (up to ~3 days back)
7. **If daily bad:** Tries external backup directory
8. **If nothing works:** Sends Telegram alert "No valid backup found! Manual intervention required."
9. **If restore worked but gateway still broken:** Counts as attempt, sends alert
10. **After 2 failures in 1 hour:** Stops trying, sends urgent alert to Coach

**Total protection depth: ~50+ restore points spanning 3 days**

---

**Last Updated:** 2026-02-07  
**Updated By:** Antigravity  
**Related Files:**
- Watchdog script: `/root/openclaw-watchdog/watchdog.sh`
- Backup skill: `.agent/skills/backup/`
- Server architecture: `lessons/server_architecture_snapshot_feb2026.md`

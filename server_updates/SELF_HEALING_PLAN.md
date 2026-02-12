# Self-Healing VPS Architecture — Full Implementation Plan

**Created:** 2026-02-11
**Author:** Antigravity
**Status:** ✅ COMPLETED — All 5 phases implemented on 2026-02-11

---

## What This Is

A step-by-step plan to make Jack, John, and Ross fully self-healing on the Hostinger VPS.
All 5 phases are now implemented. Any bot that crashes or breaks will come back on its own.

**Score: 7/10 → 9/10 ✅ ACHIEVED**

### Implementation Notes (What Actually Happened)
- **Phase 1:** Used `openclaw gateway install --force` (official CLI) instead of hand-crafted systemd service. Service file at `~/.config/systemd/user/openclaw-gateway.service`.
- **Phase 2:** Two systemd path units created at `/etc/systemd/system/openclaw-revive-jack.path` and `openclaw-revive-john.path`. Tested — reacts in milliseconds.
- **Phase 3:** POSIX ACLs set for UID 101000 on `/root/.openclaw/`, `/root/openclaw-watchdog/`, `/root/openclaw-backups/`. Ross's docker-compose.yml updated with 3 new bind mounts. ACL cron re-apply added at `/etc/cron.d/openclaw-acls`.
- **Phase 4:** `WATCHDOG_PROTOCOL.md` created in Ross's workspace. HEARTBEAT.md updated with watchdog duty.
- **Phase 5:** `live-restore: true` added to `/etc/docker/daemon.json`. Disk check script at `/etc/cron.daily/openclaw-disk-check`. Ross already had healthcheck (was already in docker-compose.yml).

### ⚠️ Note: Disk at 84%
During implementation, disk usage was observed at 84% (just under the 85% threshold). Monitor closely.

---

## What We Already Have (Don't Touch)

These things are already working. We're building ON TOP of them, not replacing them:

- ✅ Jack's automatic `.bak` file rotation (5 copies)
- ✅ Hourly + daily config snapshots (50+ restore points)
- ✅ Watchdog cron script (`/root/openclaw-watchdog/watchdog.sh`) — runs every 5 min
- ✅ Watchdog backup cascade (tries .bak → .bak.1 → hourly → daily → external)
- ✅ Watchdog JSON validation before restore
- ✅ Watchdog loop prevention (max 2 restores/hour)
- ✅ Watchdog Telegram alerts to Coach
- ✅ John's `restart: unless-stopped` Docker policy
- ✅ Ross's `restart: unless-stopped` Docker policy
- ✅ Manual backup skill (Antigravity, PowerShell → `backup.ps1 -Target jack4`)
- ✅ BOT_CHAT relay system (v4.2) between all 3 bots

---

## The 5 Phases

---

## PHASE 1 — Jack Auto-Restart (The Biggest Quick Win)
**What it does:** Makes Jack automatically start on boot and restart on crash.
**Why it matters:** Right now if the server reboots, Jack stays dead until you manually start him.
**Risk:** Very low — this is how services are supposed to run on Linux.

### Steps:

1. **SSH into the server**

2. **Create systemd service file:**
   ```bash
   cat > /etc/systemd/system/openclaw-jack.service << 'EOF'
   [Unit]
   Description=OpenClaw Gateway (Jack)
   After=network-online.target docker.service
   Wants=network-online.target

   [Service]
   Type=simple
   ExecStart=/usr/bin/openclaw gateway
   Restart=always
   RestartSec=5
   StartLimitIntervalSec=300
   StartLimitBurst=5
   WorkingDirectory=/root/.openclaw
   Environment=HOME=/root

   [Install]
   WantedBy=multi-user.target
   EOF
   ```

3. **Stop Jack's current gateway process** (we'll let systemd manage it now):
   ```bash
   # Find and kill the current openclaw gateway process
   pkill -f "openclaw gateway" || true
   ```

4. **Enable and start the service:**
   ```bash
   systemctl daemon-reload
   systemctl enable openclaw-jack.service
   systemctl start openclaw-jack.service
   ```

5. **Verify it's running:**
   ```bash
   systemctl status openclaw-jack.service
   openclaw health --json
   ```

6. **Test the auto-restart** (optional but recommended):
   ```bash
   # Kill the process — it should come back in 5 seconds
   kill $(pgrep -f "openclaw gateway")
   sleep 10
   systemctl status openclaw-jack.service
   ```

### After Phase 1:
- ✅ Jack starts automatically on server reboot
- ✅ Jack restarts within 5 seconds of a simple crash
- ✅ If Jack crashes 5 times in 5 minutes (bad config), systemd stops trying → watchdog takes over

---

## PHASE 2 — Instant Flag-File Response (Replace Cron with Systemd Path Unit)
**What it does:** When Ross drops a "revive Jack" flag, the server reacts instantly (milliseconds) instead of waiting up to 60 seconds for cron.
**Why it matters:** Faster recovery when Ross detects a problem.
**Risk:** Very low — this is a built-in Linux feature.

### Steps:

1. **Create the watchdog flag directory:**
   ```bash
   mkdir -p /root/openclaw-watchdog/flags
   ```

2. **Create the path watcher (detects the flag file instantly):**
   ```bash
   cat > /etc/systemd/system/openclaw-revive-jack.path << 'EOF'
   [Unit]
   Description=Watch for Jack revive flag from Ross

   [Path]
   PathExists=/root/openclaw-watchdog/flags/revive-jack.flag
   MakeDirectory=yes

   [Install]
   WantedBy=multi-user.target
   EOF
   ```

3. **Create the action service (what happens when the flag appears):**
   ```bash
   cat > /etc/systemd/system/openclaw-revive-jack.service << 'EOF'
   [Unit]
   Description=Revive Jack triggered by watchdog flag

   [Service]
   Type=oneshot
   ExecStart=/bin/bash -c '\
     echo "[$(date)] Revive flag detected — restarting Jack" >> /root/openclaw-watchdog/watchdog.log; \
     rm -f /root/openclaw-watchdog/flags/revive-jack.flag; \
     systemctl restart openclaw-jack.service; \
     echo "[$(date)] Jack restarted via flag" >> /root/openclaw-watchdog/watchdog.log'
   EOF
   ```

4. **Enable the watcher:**
   ```bash
   systemctl daemon-reload
   systemctl enable --now openclaw-revive-jack.path
   ```

5. **Test it works:**
   ```bash
   # Drop a flag file — Jack should restart within seconds
   touch /root/openclaw-watchdog/flags/revive-jack.flag
   sleep 5
   systemctl status openclaw-jack.service
   cat /root/openclaw-watchdog/watchdog.log | tail -5
   ```

6. **Also create a flag for restarting John's Docker container:**
   ```bash
   cat > /etc/systemd/system/openclaw-revive-john.path << 'EOF'
   [Unit]
   Description=Watch for John revive flag from Ross

   [Path]
   PathExists=/root/openclaw-watchdog/flags/revive-john.flag
   MakeDirectory=yes

   [Install]
   WantedBy=multi-user.target
   EOF

   cat > /etc/systemd/system/openclaw-revive-john.service << 'EOF'
   [Unit]
   Description=Revive John triggered by watchdog flag

   [Service]
   Type=oneshot
   ExecStart=/bin/bash -c '\
     echo "[$(date)] Revive John flag detected" >> /root/openclaw-watchdog/watchdog.log; \
     rm -f /root/openclaw-watchdog/flags/revive-john.flag; \
     docker restart openclaw-john; \
     echo "[$(date)] John container restarted via flag" >> /root/openclaw-watchdog/watchdog.log'
   EOF

   systemctl daemon-reload
   systemctl enable --now openclaw-revive-john.path
   ```

### After Phase 2:
- ✅ Ross can revive Jack by writing a single file → server reacts in milliseconds
- ✅ Ross can revive John the same way
- ✅ No cron dependency for the flag-based restart
- ✅ All activity logged to watchdog.log

---

## PHASE 3 — Give Ross Access to Jack's Files + Flag Directory
**What it does:** Mounts the right folders into Ross's Docker container so he can actually read/write Jack's config files and drop flag files.
**Why it matters:** Without this, Ross can't see Jack's files or trigger restarts. He's locked in his room.
**Risk:** Low-medium — we're using POSIX ACLs so Ross's container user (mapped to UID 101000 on host) can access root-owned files.

### Steps:

1. **Set up POSIX ACLs so Ross's container user can access Jack's files:**
   ```bash
   # Ross runs as UID 1000 inside container, mapped to 101000 on host via userns-remap
   setfacl -R -m u:101000:rwx /root/.openclaw/
   setfacl -R -d -m u:101000:rwx /root/.openclaw/
   setfacl -R -m u:101000:rwx /root/openclaw-watchdog/
   setfacl -R -d -m u:101000:rwx /root/openclaw-watchdog/
   ```

2. **Add a cron job to re-apply ACLs periodically** (because Jack creates new files as root):
   ```bash
   cat > /etc/cron.d/openclaw-acls << 'EOF'
   # Re-apply ACLs every 10 minutes for Ross's access
   */10 * * * * root setfacl -R -m u:101000:rwx /root/.openclaw/ 2>/dev/null; setfacl -R -m u:101000:rwx /root/openclaw-watchdog/ 2>/dev/null
   EOF
   ```

3. **Update Ross's docker-compose.yml** to mount the new directories:
   ```yaml
   # ADD these volumes to Ross's existing docker-compose.yml:
   volumes:
     # ... existing volumes stay ...
     - /root/.openclaw:/host/jack-config:rw               # Jack's config files
     - /root/openclaw-watchdog/flags:/host/watchdog-flags:rw  # Flag file drop zone
     - /root/openclaw-backups:/host/jack-backups:ro        # Jack's backup copies (read-only)
   ```

4. **Restart Ross's container:**
   ```bash
   cd /root/openclaw-clients/ross
   docker compose down && docker compose up -d
   ```

5. **Verify Ross can see the files:**
   ```bash
   docker exec openclaw-ross ls -la /host/jack-config/openclaw.json
   docker exec openclaw-ross ls -la /host/watchdog-flags/
   docker exec openclaw-ross ls -la /host/jack-backups/
   ```

### After Phase 3:
- ✅ Ross can read Jack's `openclaw.json` (to check if it's broken)
- ✅ Ross can read Jack's backup files (to find a good config to restore)
- ✅ Ross can drop flag files to trigger restarts
- ✅ ACLs auto-refresh every 10 minutes

---

## PHASE 4 — Ross's Revival Logic (The Brain)
**What it does:** Gives Ross actual instructions on HOW to revive Jack — what to check, what to restore, and when to trigger a restart.
**Why it matters:** Without this, Ross has access to the files but doesn't know what to do with them. This is the first aid kit.
**Risk:** Low — it's just a markdown file in Ross's workspace that tells him what to do.

### Steps:

1. **Create Ross's revival protocol** (add to his workspace):
   ```bash
   cat > /root/openclaw-clients/ross/workspace/WATCHDOG_PROTOCOL.md << 'WATCHDOGEOF'
   # Watchdog Protocol — How to Revive Jack

   You are Ross, Jack's watchdog. Every heartbeat, check Jack's health and follow this protocol.

   ## Step 1: Check if Jack is Alive
   - Try to reach Jack via BOT_CHAT — send a ping, wait for response
   - If Jack responds → he's fine, stop here
   - If Jack doesn't respond within 2 heartbeat cycles → proceed to Step 2

   ## Step 2: Check Jack's Config
   - Read `/host/jack-config/openclaw.json`
   - Is it valid JSON? (Can you parse it without errors?)
   - Does it contain a `channels` section with `telegram`?
   - If YES to both → config looks OK, Jack might just need a restart → go to Step 4
   - If NO → config is broken → go to Step 3

   ## Step 3: Restore Jack's Config
   Try these backup sources IN ORDER (stop at the first good one):
   1. `/host/jack-config/openclaw.json.bak`
   2. `/host/jack-config/openclaw.json.bak.1`
   3. `/host/jack-config/openclaw.json.bak.2`
   4. `/host/jack-config/openclaw.json.bak.3`
   5. `/host/jack-config/openclaw.json.bak.4`
   6. Most recent file in `/host/jack-backups/jack/`

   For each backup:
   - Read it — is it valid JSON with a `channels.telegram` section?
   - If YES → copy it over `/host/jack-config/openclaw.json`
   - If NO → skip it, try the next one

   If NO backup is valid → alert Coach on Telegram: "URGENT: All Jack backups are invalid. Manual intervention needed."

   ## Step 4: Trigger Jack Restart
   - Write a file: `touch /host/watchdog-flags/revive-jack.flag`
   - This will cause the host to restart Jack within seconds
   - Wait 30 seconds, then try to reach Jack via BOT_CHAT again

   ## Step 5: Report
   - If Jack is back → post to Telegram: "Jack was down. I restored his config and restarted him. He's back online."
   - If Jack is still down → post to Telegram: "Jack is still down after restore attempt. Coach may need to intervene."

   ## Rules
   - Do NOT attempt more than 2 revival attempts per hour (to prevent loops)
   - Always post to Telegram so Coach has visibility
   - If you restore a config, mention WHICH backup you used
   WATCHDOGEOF
   ```

2. **Update Ross's HEARTBEAT.md** to include the watchdog check:
   ```bash
   # Add watchdog check to Ross's heartbeat routine
   # (This gets appended to his existing HEARTBEAT.md)
   cat >> /root/openclaw-clients/ross/workspace/HEARTBEAT.md << 'EOF'

   ## Watchdog Duty
   - Read WATCHDOG_PROTOCOL.md and follow it
   - Check if Jack is alive and healthy
   - If Jack is down, follow the revival steps
   EOF
   ```

### After Phase 4:
- ✅ Ross knows exactly what to do when Jack is down
- ✅ Ross checks Jack every heartbeat cycle (every 2 minutes)
- ✅ Ross can restore broken configs from backups
- ✅ Ross can trigger restarts via flag file
- ✅ Ross reports everything to Telegram

---

## PHASE 5 — Hardening (Belt and Suspenders)
**What it does:** Adds extra safety layers to catch edge cases.
**Why it matters:** Covers the rare scenarios where even the first 4 phases aren't enough.
**Risk:** Very low.

### Step 5A: Docker Live Restore
If the Docker engine itself restarts (e.g., during an update), keep John and Ross alive:

```bash
# Add live-restore to Docker daemon config
# First check what's already there:
cat /etc/docker/daemon.json

# Then add "live-restore": true (merge with existing config)
# For example if it currently has userns-remap:
cat > /etc/docker/daemon.json << 'EOF'
{
  "userns-remap": "default",
  "live-restore": true
}
EOF

systemctl restart docker
```

### Step 5B: Ross Health Check in Docker
Make Docker auto-restart Ross if he freezes:

```yaml
# Add to Ross's docker-compose.yml:
healthcheck:
  test: ["CMD", "pgrep", "-f", "openclaw"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### Step 5C: Disk Space Monitor
Prevent the silent killer — disk filling up and breaking everything:

```bash
cat > /etc/cron.daily/openclaw-disk-check << 'DISKEOF'
#!/bin/bash
USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$USAGE" -gt 85 ]; then
    docker system prune -f 2>/dev/null
    journalctl --vacuum-size=100M
    # Clean old session files
    find /root/.openclaw/agents/main/sessions/ -mtime +7 -delete 2>/dev/null
    echo "[$(date)] Disk was at ${USAGE}% — cleaned up" >> /root/openclaw-watchdog/watchdog.log
fi
DISKEOF
chmod +x /etc/cron.daily/openclaw-disk-check
```

### Step 5D: Ensure All Services Survive Reboot
Verify everything is enabled to start on boot:

```bash
systemctl is-enabled openclaw-jack.service          # should say "enabled"
systemctl is-enabled openclaw-revive-jack.path       # should say "enabled"
systemctl is-enabled openclaw-revive-john.path       # should say "enabled"
systemctl is-enabled docker                           # should say "enabled"
```

---

## The Complete Picture (When All 5 Phases Are Done)

```
SERVER REBOOTS
    │
    ├──→ systemd starts Docker ──→ John comes back ──→ Ross comes back
    │
    └──→ systemd starts Jack (openclaw-jack.service)
              │
              └──→ If Jack crashes (simple):
                        systemd restarts in 5 sec ✅
              
              └──→ If Jack crash-loops (bad config):
                        systemd gives up after 5 tries
                            │
                            ├──→ Host watchdog (cron, every 5 min)
                            │        finds good backup → restores → restarts ✅
                            │
                            └──→ Ross (heartbeat, every 2 min)
                                     reads config → finds it broken
                                     grabs backup → overwrites
                                     drops flag → systemd restarts Jack ✅
                                     reports to Coach on Telegram
```

### Final Score Card

| What | Before | After |
|------|--------|-------|
| Jack auto-restart on crash | ❌ | ✅ systemd (5 sec) |
| Jack auto-start on reboot | ❌ | ✅ systemd |
| Broken config → auto-fix | ✅ watchdog (5 min) | ✅ watchdog (5 min) + Ross (2 min) |
| Ross can revive Jack | ❌ | ✅ flag file → instant systemd response |
| Ross can revive John | ❌ | ✅ flag file → instant Docker restart |
| Docker survives its own restart | ❔ | ✅ live-restore |
| Ross auto-heals himself | ❔ | ✅ Docker healthcheck |
| Disk space protection | ❌ | ✅ daily cleanup |
| Coach gets notified | ✅ partial | ✅ full (every event) |
| **Overall** | **7/10** | **9/10** |

---

## Implementation Order

| Phase | What | Time | Can Be Done Independently? |
|-------|------|------|---------------------------|
| **Phase 1** | Jack systemd service | ~5 min | ✅ Yes |
| **Phase 2** | Flag-file instant response | ~10 min | ✅ Yes (but needs Phase 1) |
| **Phase 3** | Ross file access + bind mounts | ~15 min | ✅ Yes |
| **Phase 4** | Ross revival protocol | ~10 min | Needs Phase 2 + 3 |
| **Phase 5** | Hardening (Docker, disk, health) | ~15 min | ✅ Yes |

**Total estimated time: ~55 minutes**

---

## How to Start

Tell Antigravity: **"Start Phase 1"** — and we'll go step by step.

# Daniel Crash Loop Incident — Diagnosis & Resolution

**Date:** 2026-02-10  
**Status:** ❌ Bot stopped, not fixed  
**Container:** `openclaw-daniel`  
**Issue:** Crash-looping with "Missing config" error  
**Resolution:** Container stopped to prevent resource waste  

---

## What Happened

Daniel (a Docker-based OpenClaw bot) was discovered in a crash loop on Feb 10, 2026, during the BOT_CHAT relay system audit. The container was restarting every ~60 seconds with exit code 1.

**Timeline:**
- **09:35 AM SGT**: Detected during investigation of all bots
- **09:39–09:49 AM**: Container restarted 10+ times (captured in logs)
- **~10:00 AM**: Container stopped manually to prevent resource waste

---

## Root Cause

### Primary Issue: Config Mount Path Problem

Daniel's logs showed a repeating error every 60 seconds:

```
2026-02-10T09:39:50.568Z Missing config. Run `openclaw setup` or set gateway.mode=local (or pass --allow-unconfigured).
```

**Analysis:**

1. **Config file exists** at `/root/openclaw-clients/daniel/openclaw.json` on the host (6,054 bytes)
2. **Config contains valid JSON** with all required sections (gateway, agents, channels, etc.)
3. **Gateway mode is set** to `"local"` (line 191 in config)
4. **Error persists** despite having a valid config

**Diagnosis:** This is a **Docker mount path mismatch**. The container can't find the config file where it expects it.

### Secondary Issues Observed

From `daniel_mounts.txt` analysis:

```json
{
  "Source": "/root/openclaw-clients/daniel/openclaw.json",
  "Destination": "/home/node/.openclaw/openclaw.json",
  "Mode": "",
  "RW": true
}
```

**Problems:**
1. **User mismatch**: Config mounted to `/home/node/` but container might not be running as user `node`
2. **No docker-compose.yml**: Daniel has no `docker-compose.yml` file (confirmed by `ls` error in `daniel_files.txt`)
3. **Manual container creation**: Daniel was created with `docker run` commands, not docker-compose
4. **Mount complexity**: 7 bind mounts including risky mounts (`/root` and `/var/run/docker.sock`)

---

## What We Found

### Diagnostic Files Captured

| File | Purpose | Key Finding |
|------|---------|-------------|
| `daniel_logs.txt` | Last 10 container logs | "Missing config" error repeating |
| `daniel_openclaw.json` | Config file content | Valid config, `gateway.mode=local` set |
| `daniel_mounts.txt` | Docker volume mounts | 7 mounts, including risky host access |
| `daniel_files.txt` | Directory listing | No docker-compose.yml exists |
| `daniel_deploy_official.txt` | Attempted deploy script | Shows how container was created |

### Config Highlights

**Gateway config (lines 189–196):**
```json
"gateway": {
  "port": 18789,
  "mode": "local",
  "bind": "loopback",
  "auth": {
    "mode": "token",
    "token": "041c16b0adb441abad2b62dd5b42b6f552da8c57b0a700ab"
  }
}
```

✅ Mode is set to `local` (should prevent "missing config" error)  
✅ Gateway configured correctly  
❌ Container still can't find it (mount path issue)

---

## Why This Is Different from Jack/John/Ross

| Aspect | Jack/John/Ross | Daniel |
|--------|----------------|--------|
| **Deployment** | docker-compose.yml | Raw `docker run` |
| **Config mount** | Clean, verified paths | Path mismatch |
| **Status** | ✅ All working | ❌ Crash loop |
| **Resolution effort** | Configured correctly | Never debugged |

Daniel was likely an **experimental deployment** that was never properly configured.

---

## The Fix That Was Applied

During the relay system improvements (Phase 1: Quick Wins), Daniel was stopped to prevent resource waste:

```bash
# From phase1-quick-wins.sh
docker update --restart=no openclaw-daniel
docker stop openclaw-daniel
```

**This is NOT a fix** — it just stops the crash loop from consuming CPU/memory.

---

## How to Actually Fix Daniel (Not Done)

### Option 1: Rebuild with docker-compose (Recommended)

Follow the John/Ross pattern:

```bash
# 1. Create proper directory structure
mkdir -p /root/openclaw-clients/daniel/{workspace,data/agents,data/cron,data/credentials,secrets,canvas}

# 2. Copy existing config
cp /root/openclaw-clients/daniel/openclaw.json /root/openclaw-clients/daniel/openclaw.json.bak

# 3. Create docker-compose.yml (copy from John, adjust container name + port)
cp /root/openclaw-clients/john/docker-compose.yml /root/openclaw-clients/daniel/
# Edit: container_name: openclaw-daniel, ports: 19387:18789

# 4. Create entrypoint.sh
cp /root/openclaw-clients/john/entrypoint.sh /root/openclaw-clients/daniel/

# 5. Set ownership (check for userns remap first!)
OWNER_UID=$(stat -c '%u' /root/openclaw-clients/john/workspace/SOUL.md)
chown -R $OWNER_UID:$OWNER_UID /root/openclaw-clients/daniel/

# 6. Start with docker-compose
cd /root/openclaw-clients/daniel
docker compose up -d
```

### Option 2: Fix Existing Container

```bash
# 1. Inspect current mounts
docker inspect openclaw-daniel | jq '.[].Mounts'

# 2. Identify which path the container expects
docker exec openclaw-daniel ls -la /home/node/.openclaw/

# 3. Fix the mount path OR create symlink inside container

# 4. Restart
docker start openclaw-daniel
```

### Option 3: Delete and Forget

If Daniel was just an experiment and not needed:

```bash
docker rm openclaw-daniel
rm -rf /root/openclaw-clients/daniel/
# Update server architecture doc to remove Daniel
```

---

## Lessons Learned

### 1. **docker-compose > docker run**

Docker-compose provides:
- Reproducible deployments
- Version-controlled configuration
- Easier debugging (just read the YAML)
- Proper mount path documentation

**Raw `docker run` commands are fragile and hard to maintain.**

### 2. **Verify Config Accessibility**

When a container says "Missing config," check:
1. Does the file exist on the host?
2. Is it mounted to the correct container path?
3. Does the container user have read permissions?
4. Is the path in the mount correct for the container's internal paths?

### 3. **Risky Mounts Should Be Avoided**

Daniel had these dangerous mounts:
```
/root → /root                    # Full host root access
/var/run/docker.sock → ...       # Docker control access
```

These are **security risks** unless absolutely necessary and properly secured.

**John's security-hardened approach** (no host access, dropped caps, read-only config) is the correct pattern.

---

## Current Status

| Property | Value |
|----------|-------|
| Container | `openclaw-daniel` |
| Status | Exited (stopped manually) |
| Restart Policy | `no` (was changed from `always`) |
| Last Exit Code | 1 (error) |
| Config File | Exists at `/root/openclaw-clients/daniel/openclaw.json` |
| Config Valid | ✅ Yes (6,054 bytes, valid JSON) |
| Mount Issue | ❌ Path mismatch preventing container from finding config |
| Fix Applied | ❌ None — just stopped to prevent resource waste |

---

## Recommendation

**Delete Daniel unless there's a specific reason to keep him.**

If he's needed:
1. Rebuild from scratch using docker-compose (follow John/Ross pattern)
2. Copy workspace files to new container
3. Test thoroughly before enabling auto-restart
4. Add to monitoring/health checks

If not needed:
1. Remove container: `docker rm openclaw-daniel`
2. Archive config: `tar -czf daniel-backup-$(date +%Y%m%d).tar.gz /root/openclaw-clients/daniel/`
3. Remove directory: `rm -rf /root/openclaw-clients/daniel/`
4. Update server architecture doc

---

## Files to Review

All diagnostic files are in the workspace root:
- `daniel_logs.txt` — Container error logs
- `daniel_openclaw.json` — Full config (including API keys)
- `daniel_mounts.txt` — Docker mount configuration
- `daniel_deploy_official.txt` — Attempted deployment script
- `daniel_files.txt`, `daniel_data.txt`, `daniel_allfiles.txt` — Directory listings

---

**Bottom Line:** Daniel is an incomplete deployment with a config mount path issue. He was never properly commissioned and should either be rebuilt correctly or deleted.

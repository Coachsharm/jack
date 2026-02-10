# Lessons Learned: OpenClaw Config Deployment

> [!WARNING]
> **PARTIALLY OUTDATED (Feb 2026):** This lesson was written for Jack1 (Docker-based). Jack4 is now a **native installation** — Docker paths and `docker restart` commands no longer apply. For current backup/restore procedures, see `lessons/jack4_backup_and_recovery_system.md`. The general principles (validate JSON, backup before changes, use `scp`/`pscp` for uploads) still apply.

**Date:** 2026-02-03  
**Context:** Deploying autonomy configuration to Jack1 (OpenClaw DNTM)

---

## ✅ WHAT WORKED

### 1. Direct File Upload via `pscp`
**Best Method for Config Changes:**
```powershell
pscp -pw "Corecore8888-" -batch .\config.json root@72.62.252.124:/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json
docker restart openclaw-dntm-openclaw-1
```

**Why it works:**
- Direct binary file transfer
- No shell parsing/escaping issues
- Reliable and predictable
- Easy to verify

### 2. Validation Before Upload
```powershell
Get-Content config.json | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Out-Null
```
- Catches JSON syntax errors locally
- Saves deployment cycles
- Prevents broken configs on server

### 3. Backup Before Every Change
```bash
cp /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json /home/ubuntu/openclaw.json.backup_name.bak
```
- Easy rollback if deployment fails
- Multiple backup points for phased deployments
- No downtime risk

### 4. Using Stored Credentials
- Password retrieved from `secrets/config.json`
- Single source of truth
- No hardcoding in scripts

---

## ❌ WHAT FAILED

### 1. Bash Heredoc via SSH
**Attempted:**
```powershell
plink -ssh -pw "..." root@... "cat > /path/to/file << 'EOF'
<JSON_CONTENT>
EOF"
```

**Problem:**
- PowerShell → plink → bash pipeline breaks syntax
- Heredoc delimiters don't parse correctly
- Results in corrupted/invalid file

**Lesson:** Never use heredoc for config deployment through multiple shell layers

### 2. Wrong Config Values
**Used:** `tools.exec.ask: "never"`  
**Correct:** `tools.exec.ask: "off"`

**Valid options:**
- `"off"` - Never ask
- `"on-miss"` - Ask on cache miss  
- `"always"` - Always ask

**Lesson:** Always verify config values against official docs, don't assume

### 3. SSH Key Authentication
**Problem:** Key file at `./secrets/jack_vps` always prompts for password

**Attempted:**
- `-i ~/.ssh/jack_vps`
- `-i ./secrets/jack_vps`
- Various path variations

**All failed** - root cause unknown

**Lesson:** Have password fallback method ready; investigate SSH key issues separately

---

## 🎯 BEST PRACTICES FOR FUTURE CONFIG EDITS

### Step-by-Step Process

1. **Edit Config Locally**
   - Make changes to local JSON file
   - Keep it version controlled

2. **Validate JSON Syntax**
   ```powershell
   Get-Content config.json | ConvertFrom-Json | Out-Null
   ```

3. **Backup Server Config**
   ```bash
   cp /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json /home/ubuntu/backup_$(date +%Y%m%d_%H%M).bak
   ```

4. **Upload via pscp**
   ```powershell
   pscp -pw "PASSWORD" -batch .\config.json root@IP:/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json
   ```

5. **Restart Container**
   ```bash
   docker restart openclaw-dntm-openclaw-1
   ```

6. **Verify Deployment**
   ```bash
   # Check logs for errors
   docker logs openclaw-dntm-openclaw-1 --tail 50
   
   # Verify specific settings
   cat /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json | jq '.path.to.setting'
   ```

---

## 🚫 THINGS TO AVOID

### 1. Multi-Shell Piping
❌ **Don't:** Pipe JSON through multiple shells (PowerShell → SSH → bash)  
✅ **Do:** Use direct file transfer tools (pscp, scp)

### 2. Assuming Config Values
❌ **Don't:** Guess what values are valid (e.g., "never")  
✅ **Do:** Check OpenClaw docs or use autocomplete if available

### 3. Skipping Validation
❌ **Don't:** Upload without testing JSON syntax  
✅ **Do:** Validate locally first with `jq` or PowerShell

### 4. No Backup Strategy
❌ **Don't:** Edit production config without backup  
✅ **Do:** Always create timestamped backups before changes

### 5. Editing Production Directly
❌ **Don't:** `vim` directly into production config  
✅ **Do:** Edit locally, validate, then upload

### 6. Unclear Config Paths
❌ **Don't:** Assume where config is read from  
✅ **Do:** Verify both volume path and container path match

**Key paths for OpenClaw:**
- Volume: `/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json`
- Container: `/home/node/.openclaw/openclaw.json`

---

## 📋 QUICK REFERENCE COMMANDS

### Backup Config
```bash
ssh root@72.62.252.124
cp /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json /home/ubuntu/openclaw_backup_$(date +%Y%m%d_%H%M).bak
```

### Upload New Config
```powershell
pscp -pw "Corecore8888-" -batch .\new_config.json root@72.62.252.124:/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json
```

### Restart & Check
```bash
docker restart openclaw-dntm-openclaw-1
sleep 5
docker logs openclaw-dntm-openclaw-1 --tail 30
```

### Verify Settings
```bash
cat /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json | jq '.tools, .session.sendPolicy, .agents.defaults.sandbox'
```

### Rollback
```bash
cp /home/ubuntu/backup_TIMESTAMP.bak /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json
docker restart openclaw-dntm-openclaw-1
```

---

## 🔧 TOOLS THAT WORK

1. **pscp** (PuTTY Secure Copy) - File transfers
2. **plink** (PuTTY Link) - Remote command execution  
3. **jq** - JSON parsing and validation
4. **PowerShell ConvertFrom-Json** - Local JSON validation

---

## 💡 KEY TAKEAWAYS

1. **Simplicity wins** - Direct file transfer beats complex piping
2. **Validate early** - Catch errors before they hit production
3. **Always backup** - One command can save hours of recovery
4. **Read the docs** - Don't assume config value formats
5. **Test locally** - JSON validation prevents deployment failures
6. **Know your paths** - Verify both volume and container paths
7. **Password auth works** - Don't let SSH key issues block you

---

## 🔮 FUTURE IMPROVEMENTS

1. **Fix SSH Key Auth** - Investigate why `./secrets/jack_vps` doesn't work
2. **Automate Validation** - Pre-commit hook to validate JSON
3. **Config Schema** - Create JSON schema for OpenClaw config validation
4. **Deployment Script** - Single command that does backup + upload + restart + verify
5. **Rollback Script** - One-command restore from latest backup

---

**Bottom Line:** Use `pscp` for config uploads. Always backup first. Validate before deploying. Simple is reliable.

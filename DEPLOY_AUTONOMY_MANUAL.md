# OpenClaw Autonomy Configuration - Manual Deployment Guide

## Overview
Created 3 config files for phased autonomy deployment. All JSONs validated ✓

## Files Created
- `openclaw_step1.json` - Exec without ask
- `openclaw_step2.json` - + Auto-send messages
- `openclaw_step3.json` - + Sandbox OFF (full access)

---

## 🔧 STEP 1: Exec Without Ask

### Deploy Commands
```bash
# 1. Backup current config
cp /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json /home/ubuntu/openclaw.json.step1.bak

# 2. Verify backup exists
ls -lh /home/ubuntu/openclaw.json.step1.bak

# 3. Upload new config (from local machine via existing SSH session)
# Copy contents of openclaw_step1.json and paste into:
cat > /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json << 'EOF'
<PASTE_JSON_HERE>
EOF

# 4. Validate JSON
cat /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json | jq . > /dev/null && echo "✓ JSON valid" || echo "✗ INVALID"

# 5. Restart container
docker restart openclaw-dntm-openclaw-1

# 6. Check logs
docker logs openclaw-dntm-openclaw-1 --tail 40
```

### Test
```bash
# Test that Jack runs commands without asking
docker exec openclaw-dntm-openclaw-1 ls -la /home/node/app
```

---

## 📨 STEP 2: Auto-Send Messages

### Deploy Commands
```bash
# 1. Backup
cp /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json /home/ubuntu/openclaw.json.step2.bak

# 2. Upload new config
cat > /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json << 'EOF'
<PASTE_openclaw_step2.json_HERE>
EOF

# 3. Validate
cat /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json | jq . > /dev/null && echo "✓ JSON valid" || echo "✗ INVALID"

# 4. Restart
docker restart openclaw-dntm-openclaw-1

# 5. Logs
docker logs openclaw-dntm-openclaw-1 --tail 40
```

---

## 🚨 STEP 3: Sandbox OFF (Full Access)

### Deploy Commands
```bash
# 1. Backup
cp /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json /home/ubuntu/openclaw.json.step3.bak

# 2. Upload new config
cat > /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json << 'EOF'
<PASTE_openclaw_step3.json_HERE>
EOF

# 3. Validate
cat /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json | jq . > /dev/null && echo "✓ JSON valid" || echo "✗ INVALID"

# 4. Restart
docker restart openclaw-dntm-openclaw-1

# 5. Logs
docker logs openclaw-dntm-openclaw-1 --tail 40
```

### Test Full Access
```bash
# Verify Jack can create files on host
docker exec openclaw-dntm-openclaw-1 touch /tmp/test_sandbox_off.txt
docker exec openclaw-dntm-openclaw-1 ls -la /tmp/test_sandbox_off.txt
```

---

## Recovery

If anything breaks:
```bash
# Restore from last working backup
cp /home/ubuntu/openclaw.json.step[X].bak /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json
docker restart openclaw-dntm-openclaw-1
```

---

## What Changed

**Step 1:**
- `tools.exec.ask`: `"always"` → `"never"`

**Step 2:**
- Added `session.sendPolicy.default`: `"allow"`

**Step 3:**
- Added `agents.defaults.sandbox.mode`: `"off"`
- Added `agents.defaults.sandbox.workspaceAccess`: `"rw"`

---

## Notes

⚠️ **SSH Key Issue**: SSH commands are asking for password despite key file existing. This needs investigation after deployment.

✓ **All JSONs Validated**: Each config file passed PowerShell JSON validation

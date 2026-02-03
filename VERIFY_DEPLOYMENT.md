# Verification Commands for OpenClaw Autonomy Deployment

## Quick Verification

Run this from PowerShell to verify deployment:

```powershell
plink -ssh -pw "Corecore8888-" root@72.62.252.124 -batch "echo '=== CHECKING BACKUPS ===' && ls -lh /home/ubuntu/openclaw.json.step*.bak && echo '' && echo '=== CHECKING CONTAINER ===' && docker ps | grep openclaw-dntm && echo '' && echo '=== CHECKING CONFIG ===' && cat /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json | grep -A3 'tools'"
```

## What to Look For

✅ **Backups exist:**
- `/home/ubuntu/openclaw.json.step1.bak`
- `/home/ubuntu/openclaw.json.step2.bak`
- `/home/ubuntu/openclaw.json.step3.bak`

✅ **Container running:**
- `openclaw-dntm-openclaw-1` shows "Up" status

✅ **Config shows:**
```json
"tools": {
  "exec": {
    "ask": "never"
  }
}
```

## Manual Verification (if plink doesn't work)

1. Open new PowerShell
2. Run: `ssh root@72.62.252.124`
3. Password: `Corecore8888-`
4. Execute:
```bash
# Check backups
ls -lh /home/ubuntu/openclaw.json.step*.bak

# Check config
cat /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json | grep -A5 "tools"

# Check container logs
docker logs openclaw-dntm-openclaw-1 --tail 40
```

## If Something Failed

Restore from backup:
```bash
# Choose the last working step (1, 2, or 3)
cp /home/ubuntu/openclaw.json.step1.bak /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json
docker restart openclaw-dntm-openclaw-1
```

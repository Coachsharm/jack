# diagnose - OpenClaw System Diagnostics

Quick health check for OpenClaw installations (native + Docker bots).

## When to Use
- User asks for "systems check", "health check", or "diagnose"
- Troubleshooting issues with Jack, John, Ross, Sarah, or any OpenClaw bot
- Before/after updates or config changes
- When bots aren't responding correctly

## Diagnosis Protocol

### 0. Auto-Diagnose (First Step)
```bash
openclaw doctor
```
**What it checks:**
- Config validation
- Permission issues
- Version compatibility
- Channel health
- Common issues

**Output:** Lists problems found with suggested fixes.

**Why first?** Catches 80% of common issues automatically before manual checks.

### 1. Main Gateway Status
```bash
openclaw status
```
Check for:
- Gateway running/reachable
- Channels connected (WhatsApp, Telegram, etc.)
- Agent count and sessions
- Available updates
- Security warnings

### 2. Docker Containers (if applicable)
```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
```
Check:
- All expected containers running
- Health status (healthy/unhealthy/starting)
- Uptime (recent restart = potential issue)

### 3. Version Check (per bot)
```bash
# Native install
openclaw --version

# Docker containers
docker exec openclaw-john openclaw --version
docker exec openclaw-sarah openclaw --version
docker exec openclaw-ross openclaw --version
```
Compare versions. Mismatches = config warnings or compatibility issues.

### 4. Recent Logs (if issues detected)
```bash
# Native
openclaw logs --tail 30

# Docker
docker logs openclaw-{name} --tail 30
```
Look for:
- Version mismatch warnings
- Connection errors (channels, auth, models)
- Failed updates or permission issues
- Crashes or restarts

### 5. Config Validation (if formatting suspected)
```bash
# Check JSON validity
cat /path/to/openclaw.json | python3 -m json.tool 2>&1 | head -100

# Native
cat /root/.openclaw/openclaw.json | python3 -m json.tool

# Docker
cat /root/openclaw-clients/{name}/openclaw.json | python3 -m json.tool
```

### 6. Auth & Model Status
```bash
openclaw status --usage
```
Check for:
- Auth profile active
- API quota remaining
- Rate limit warnings
- Model availability

## Common Issues & Fixes

### Version Mismatch (Docker)
**Symptom:** "Config was last written by a newer OpenClaw"  
**Fix:** Rebuild Docker image or manual update as root

### Config Invalid
**Symptom:** Gateway won't start, "validation failed"  
**Fix:** Run `openclaw doctor --fix` or validate JSON

### Channel Disconnected
**Symptom:** WhatsApp/Telegram shows "WARN" or "ERROR"  
**Fix:** Check auth, restart gateway, verify tokens

### Update Available
**Symptom:** "Update available" in status  
**Fix:** `openclaw update` (native) or rebuild Docker image

## Output Format

Present findings as:
```
**{Bot Name} ({Location})**
✅ Status item: Details
⚠️ Warning item: Details
❌ Error item: Details

Summary line + recommendation
```

## Example

```
**Jack (Main - VPS)**
✅ Gateway: Running healthy
✅ WhatsApp: Connected (+6588626460)
✅ Telegram: Connected
✅ Model: claude-sonnet-4-5
⚠️ Update available: 2026.2.9

**Sarah (Docker)**
✅ Container: Up 22 min (healthy)
❌ Version mismatch: Running 2026.2.3-1 (you're on 2026.2.6-3)

Main issue: Sarah's OpenClaw is 3 versions behind. Update recommended.
```

## Notes
- Don't narrate every command — just show results
- Focus on actionable issues (not cosmetic warnings)
- Compare versions across all bots
- Check auth status if model/API issues suspected

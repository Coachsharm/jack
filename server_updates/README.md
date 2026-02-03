# OpenClaw Awareness Updates - Deployment Package

## What This Is

This package contains updated workspace files to make Jack fully OpenClaw-aware.

## Files Included

1. **AGENTS_update.md** → Deployed as `AGENTS.md`
   - OpenClaw system architecture awareness
   - Skills system documentation
   - ClawHub integration for skill discovery
   - Gmail/Calendar access via gogcli
   - Response patterns (no more "sessions" or vague errors)
   - Boundaries and configuration knowledge

2. **SOUL_update.md** → Deployed as `SOUL.md`
   - Response tone guidelines (conversational, not corporate)
   - Direct communication (no hedging)
   - Proper use of contractions

3. **TOOLS_update.md** → Deployed as `TOOLS.md`
   - Current configuration inventory
   - Installed skills list
   - ClawHub access instructions
   - gogcli setup reference
   - Capability checklist

## Deployment

### Automatic (Recommended)

Run the deployment script:
```powershell
cd C:\Users\hisha\Code\Jack\server_updates
.\deploy_workspace_updates.ps1
```

This will:
1. Backup current files
2. Upload new files to server
3. Copy into container workspace
4. Set proper ownership
5. Verify deployment

### Manual

If you prefer manual deployment:

```powershell
# 1. Upload files
pscp -pw "Corecore8888-" .\AGENTS_update.md root@72.62.252.124:/tmp/AGENTS.md
pscp -pw "Corecore8888-" .\SOUL_update.md root@72.62.252.124:/tmp/SOUL.md
pscp -pw "Corecore8888-" .\TOOLS_update.md root@72.62.252.124:/tmp/TOOLS.md

# 2. Copy into container
plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker cp /tmp/AGENTS.md openclaw-dntm-1:/home/node/.openclaw/workspace/AGENTS.md"
plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker cp /tmp/SOUL.md openclaw-dntm-1:/home/node/.openclaw/workspace/SOUL.md"
plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker cp /tmp/TOOLS.md openclaw-dntm-1:/home/node/.openclaw/workspace/TOOLS.md"

# 3. Set ownership
plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker exec openclaw-dntm-1 chown node:node /home/node/.openclaw/workspace/*.md"
```

## After Deployment

### Jack Will Automatically:
- Read these files on next session start
- Know about OpenClaw's skills system
- Search ClawHub when asked for new capabilities
- Use gogcli for Gmail/Calendar
- Communicate conversationally (no more "I encountered issues")

### Testing

Ask Jack:
1. **"What can you do?"**
   - Should run `openclaw skills list` and report actual capabilities

2. **"Can you create GitHub issues?"**
   - Should search ClawHub for github-api skill

3. **"Check my Gmail"**
   - Should explain gogcli setup (not mention "sessions")

4. **General tone check:**
   - Should use contractions ("I'm", "can't", "let's")
   - Should be direct, not hedging
   - Should be specific about errors

## What Changed

### Before (Generic LLM):
- Relied on base LLM knowledge
- Made up "sessions" concept
- Vague errors: "I encountered issues"
- Deflected: "You may want to check directly"
- Didn't know about ClawHub or skills

### After (OpenClaw-Native):
- Checks actual config and skills
- Uses ClawHub to discover capabilities
- Specific errors: "I need gogcli installed"
- Offers solutions: "Install from https://gogcli.sh/"
- Proactive about capabilities

## Next Steps (Not Included in This Deployment)

1. **Install gogcli** (separate task)
   - Can be done locally then upload credentials
   
2. **Upload OpenClaw docs** (optional)
   - Copy `OpenClaw_Docs/` to server workspace

3. **Test skill installation**
   - Verify ClawHub access
   - Test `clawhub install` command

## Rollback

If needed, restore from backup:
```powershell
# Find backup
plink -ssh -pw "Corecore8888-" root@72.62.252.124 "ls -lh /tmp/workspace-backup-*.tar.gz"

# Restore
plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker exec openclaw-dntm-1 tar -xzf /tmp/workspace-backup-TIMESTAMP.tar.gz -C /home/node/.openclaw/workspace/"
```

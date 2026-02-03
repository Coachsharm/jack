
$ServerIP = "72.62.252.124"
$User = "root"
$ContainerName = "openclaw-dntm-openclaw-1"
$RemoteStagingPath = "/root/jack_brain_temp"
$TargetContainerPath = "/home/node/.openclaw"

Write-Host "🚀 Starting Brain Deployment to Jack ($ServerIP)..." -ForegroundColor Cyan

# 1. Create Staging Folder on Server
Write-Host "`n[1/5] Creating staging folder on server..." -ForegroundColor Yellow
ssh $User@$ServerIP "mkdir -p $RemoteStagingPath"

# 2. Upload Protocol Files
Write-Host "`n[2/5] Uploading protocol files (Gemini.md, claude.md)..." -ForegroundColor Yellow
scp .\Gemini.md ${User}@${ServerIP}:${RemoteStagingPath}/Gemini.md
scp .\claude.md ${User}@${ServerIP}:${RemoteStagingPath}/claude.md

# 3. Upload Documentation (Recursive)
Write-Host "`n[3/5] Uploading OpenClaw Documentation (this may take a minute)..." -ForegroundColor Yellow
scp -r .\OpenClaw_Docs ${User}@${ServerIP}:${RemoteStagingPath}/

# 4. Move Files into Container
Write-Host "`n[4/5] Injecting files into Docker Container ($ContainerName)..." -ForegroundColor Yellow
ssh $User@$ServerIP "docker cp ${RemoteStagingPath}/Gemini.md ${ContainerName}:${TargetContainerPath}/Gemini.md && docker cp ${RemoteStagingPath}/claude.md ${ContainerName}:${TargetContainerPath}/claude.md && docker cp ${RemoteStagingPath}/OpenClaw_Docs ${ContainerName}:${TargetContainerPath}/"

# 5. Cleanup Staging
Write-Host "`n[5/5] Cleaning up staging files..." -ForegroundColor Yellow
ssh $User@$ServerIP "rm -rf $RemoteStagingPath"

Write-Host "`n✅ DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "Jack now has:"
Write-Host "  - Updated Gemini.md & claude.md"
Write-Host "  - Full OpenClaw_Docs library"
Write-Host "Location: $TargetContainerPath inside $ContainerName"

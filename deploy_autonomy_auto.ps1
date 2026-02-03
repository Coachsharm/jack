# OpenClaw Autonomy Deployment - Automated
#
# CREDENTIALS: Find actual server IP and password in secrets/config.json
# This file uses placeholders for GitHub safety

$Password = "[VPS_PASSWORD]"
$ServerIP = "[SERVER_IP]"
$User = "root"
$ConfigPath = "/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json"
$ContainerName = "openclaw-dntm-openclaw-1"

# Using plink (PuTTY) for automated password auth
# If plink not available, we'll use expect-like approach

Write-Host ""
Write-Host "OpenClaw Autonomy Deployment - Automated" -ForegroundColor Cyan
Write-Host ""

# Create temporary script files for each step
$step1Cmds = @"
cp $ConfigPath /home/ubuntu/openclaw.json.step1.bak
cat > $ConfigPath << 'EOFCONFIG'
"@

$step1Cmds += Get-Content .\openclaw_step1.json -Raw
$step1Cmds += @"
EOFCONFIG
docker restart $ContainerName
echo 'Step 1 complete'
exit
"@

$step2Cmds = @"
cp $ConfigPath /home/ubuntu/openclaw.json.step2.bak
cat > $ConfigPath << 'EOFCONFIG'
"@

$step2Cmds += Get-Content .\openclaw_step2.json -Raw
$step2Cmds += @"
EOFCONFIG
docker restart $ContainerName
echo 'Step 2 complete'
exit
"@

$step3Cmds = @"
cp $ConfigPath /home/ubuntu/openclaw.json.step3.bak
cat > $ConfigPath << 'EOFCONFIG'
"@

$step3Cmds += Get-Content .\openclaw_step3.json -Raw
$step3Cmds += @"
EOFCONFIG
docker restart $ContainerName
echo 'Step 3 complete - Full autonomy enabled'
docker logs $ContainerName --tail 20
exit
"@

# Save commands to temp files
$step1Cmds | Out-File -FilePath ".\temp_step1.sh" -Encoding ASCII
$step2Cmds | Out-File -FilePath ".\temp_step2.sh" -Encoding ASCII
$step3Cmds | Out-File -FilePath ".\temp_step3.sh" -Encoding ASCII

Write-Host "STEP 1: Exec without ask" -ForegroundColor Cyan
echo y | plink -ssh -pw $Password ${User}@${ServerIP} -batch -m .\temp_step1.sh
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "STEP 2: Auto-send messages" -ForegroundColor Cyan
echo y | plink -ssh -pw $Password ${User}@${ServerIP} -batch -m .\temp_step2.sh
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "STEP 3: Sandbox OFF" -ForegroundColor Cyan
echo y | plink -ssh -pw $Password ${User}@${ServerIP} -batch -m .\temp_step3.sh

# Cleanup
Remove-Item .\temp_step1.sh -ErrorAction SilentlyContinue
Remove-Item .\temp_step2.sh -ErrorAction SilentlyContinue
Remove-Item .\temp_step3.sh -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

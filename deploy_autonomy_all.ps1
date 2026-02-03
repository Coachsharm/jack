$ServerIP = "72.62.252.124"
$User = "root"
$ConfigPath = "/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json"
$ContainerName = "openclaw-dntm-openclaw-1"

Write-Host ""
Write-Host "OpenClaw Autonomy Deployment - All 3 Steps" -ForegroundColor Cyan
Write-Host "This will deploy all autonomy configs sequentially." -ForegroundColor Yellow
Write-Host ""

# STEP 1
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 1: Exec Without Ask" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Backing up current config..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "cp $ConfigPath /home/ubuntu/openclaw.json.step1.bak"

Write-Host "[2/3] Uploading Step 1 config..." -ForegroundColor Yellow
scp .\openclaw_step1.json ${User}@${ServerIP}:${ConfigPath}

Write-Host "[3/3] Restarting container..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "docker restart $ContainerName"

Write-Host "Step 1 deployed. Waiting 10 seconds..." -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 10

# STEP 2
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 2: Auto-Send Messages" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Backing up Step 1 config..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "cp $ConfigPath /home/ubuntu/openclaw.json.step2.bak"

Write-Host "[2/3] Uploading Step 2 config..." -ForegroundColor Yellow
scp .\openclaw_step2.json ${User}@${ServerIP}:${ConfigPath}

Write-Host "[3/3] Restarting container..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "docker restart $ContainerName"

Write-Host "Step 2 deployed. Waiting 10 seconds..." -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 10

# STEP 3
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 3: Sandbox OFF (Full Access)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Backing up Step 2 config..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "cp $ConfigPath /home/ubuntu/openclaw.json.step3.bak"

Write-Host "[2/3] Uploading Step 3 config (FINAL)..." -ForegroundColor Yellow
scp .\openclaw_step3.json ${User}@${ServerIP}:${ConfigPath}

Write-Host "[3/3] Restarting container (final)..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "docker restart $ContainerName"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "ALL 3 STEPS DEPLOYED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Jack now has:" -ForegroundColor Cyan
Write-Host "  - Exec without asking" -ForegroundColor White
Write-Host "  - Auto-send messages" -ForegroundColor White
Write-Host "  - Full server/Docker access (sandbox off)" -ForegroundColor White
Write-Host ""

Write-Host "Checking final logs..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "docker logs $ContainerName --tail 20"

Write-Host ""
Write-Host "Deployment complete!" -ForegroundColor Green

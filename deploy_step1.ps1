$ServerIP = "72.62.252.124"
$User = "root"
$ConfigPath = "/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json"
$ContainerName = "openclaw-dntm-openclaw-1"

Write-Host "`n🔧 STEP 1: Exec Settings (Never Ask)" -ForegroundColor Cyan

# Backup on server
Write-Host "[1/5] Creating backup..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "cp $ConfigPath /home/ubuntu/openclaw.json.step1.bak; echo 'Backup created'"

# Upload new config
Write-Host "[2/5] Uploading new config..." -ForegroundColor Yellow
scp .\openclaw_step1.json ${User}@${ServerIP}:${ConfigPath}

# Validate JSON on server  
Write-Host "[3/5] Validating JSON..." -ForegroundColor Yellow  
ssh ${User}@${ServerIP} "cat $ConfigPath | jq . > /dev/null; if [ \`$? -eq 0 ]; then echo 'JSON valid'; else echo 'JSON INVALID'; fi"

# Restart container
Write-Host "[4/5] Restarting container..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "docker restart $ContainerName"

# Check logs
Write-Host "[5/5] Checking logs..." -ForegroundColor Yellow
ssh ${User}@${ServerIP} "docker logs $ContainerName --tail 40"

Write-Host "`n✅ Step 1 Complete!" -ForegroundColor Green


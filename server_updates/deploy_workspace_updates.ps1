# Deploy OpenClaw Awareness Updates to Jack
# Simple version without fancy formatting
#
# CREDENTIALS: Find actual server IP and password in secrets/config.json
# This file uses placeholders for GitHub safety

$SERVER = "root@[SERVER_IP]"
$PASSWORD = "[VPS_PASSWORD]"
$CONTAINER = "openclaw-dntm-1"
$WORKSPACE_PATH = "/home/node/.openclaw/workspace"

Write-Host "=== Deploying OpenClaw Awareness Updates to Jack ==="
Write-Host ""

# Step 1: Backup current files
Write-Host "[1/5] Creating backup of current workspace files..."
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
plink -ssh -pw $PASSWORD $SERVER "docker exec $CONTAINER tar -czf /tmp/workspace-backup-$timestamp.tar.gz -C $WORKSPACE_PATH ."
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK - Backup created: /tmp/workspace-backup-$timestamp.tar.gz"
}
else {
    Write-Host "ERROR - Backup failed - Aborting"
    exit 1
}

# Step 2: Upload updated files to /tmp on server
Write-Host ""
Write-Host "[2/5] Uploading updated files to server..."

pscp -pw $PASSWORD ".\server_updates\AGENTS_update.md" "${SERVER}:/tmp/AGENTS.md"
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR - Failed to upload AGENTS.md"; exit 1 }

pscp -pw $PASSWORD ".\server_updates\SOUL_update.md" "${SERVER}:/tmp/SOUL.md"
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR - Failed to upload SOUL.md"; exit 1 }

pscp -pw $PASSWORD ".\server_updates\TOOLS_update.md" "${SERVER}:/tmp/TOOLS.md"
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR - Failed to upload TOOLS.md"; exit 1 }

Write-Host "OK - Files uploaded to /tmp/"

# Step 3: Copy files from /tmp into container workspace
Write-Host ""
Write-Host "[3/5] Copying files into container workspace..."

plink -ssh -pw $PASSWORD $SERVER "docker cp /tmp/AGENTS.md ${CONTAINER}:${WORKSPACE_PATH}/AGENTS.md"
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR - Failed to copy AGENTS.md"; exit 1 }

plink -ssh -pw $PASSWORD $SERVER "docker cp /tmp/SOUL.md ${CONTAINER}:${WORKSPACE_PATH}/SOUL.md"
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR - Failed to copy SOUL.md"; exit 1 }

plink -ssh -pw $PASSWORD $SERVER "docker cp /tmp/TOOLS.md ${CONTAINER}:${WORKSPACE_PATH}/TOOLS.md"
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR - Failed to copy TOOLS.md"; exit 1 }

Write-Host "OK - Files copied to container workspace"

# Step 4: Set proper ownership
Write-Host ""
Write-Host "[4/5] Setting file ownership..."
plink -ssh -pw $PASSWORD $SERVER "docker exec $CONTAINER chown node:node $WORKSPACE_PATH/AGENTS.md $WORKSPACE_PATH/SOUL.md $WORKSPACE_PATH/TOOLS.md"
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK - Ownership set to node:node"
}
else {
    Write-Host "WARNING - Could not set ownership (may not matter)"
}

# Step 5: Verify deployment
Write-Host ""
Write-Host "[5/5] Verifying deployment..."
plink -ssh -pw $PASSWORD $SERVER "docker exec $CONTAINER ls -lh $WORKSPACE_PATH/AGENTS.md $WORKSPACE_PATH/SOUL.md $WORKSPACE_PATH/TOOLS.md"

Write-Host ""
Write-Host "=================================================="
Write-Host "DEPLOYMENT COMPLETE!"
Write-Host "=================================================="
Write-Host ""
Write-Host "Next Steps:"
Write-Host "1. Restart Jack session (or wait for next session start)"
Write-Host "2. Jack will automatically read the updated files"
Write-Host "3. Test with questions about capabilities or Gmail"
Write-Host ""
Write-Host "Backup location: /tmp/workspace-backup-$timestamp.tar.gz"
Write-Host ""

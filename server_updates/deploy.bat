@echo off
echo === Deploying OpenClaw Awareness Updates to Jack ===
echo.

echo [1/3] Uploading files to server /tmp...
pscp -pw "Corecore8888-" "server_updates\AGENTS_update.md" "root@72.62.252.124:/tmp/AGENTS.md"
if errorlevel 1 (
    echo ERROR: Failed to upload AGENTS.md
    exit /b 1
)

pscp -pw "Corecore8888-" "server_updates\SOUL_update.md" "root@72.62.252.124:/tmp/SOUL.md"
if errorlevel 1 (
    echo ERROR: Failed to upload SOUL.md
    exit /b 1
)

pscp -pw "Corecore8888-" "server_updates\TOOLS_update.md" "root@72.62.252.124:/tmp/TOOLS.md"
if errorlevel 1 (
    echo ERROR: Failed to upload TOOLS.md
    exit /b 1
)

echo OK - Files uploaded to /tmp/
echo.

echo [2/3] Copying files into container workspace...
echo Y | plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker cp /tmp/AGENTS.md openclaw-dntm-1:/home/node/.openclaw/workspace/AGENTS.md && docker cp /tmp/SOUL.md openclaw-dntm-1:/home/node/.openclaw/workspace/SOUL.md && docker cp /tmp/TOOLS.md openclaw-dntm-1:/home/node/.openclaw/workspace/TOOLS.md"

echo OK - Files copied to container
echo.

echo [3/3] Setting ownership...
echo Y | plink -ssh -pw "Corecore8888-" root@72.62.252.124 "docker exec openclaw-dntm-1 chown node:node /home/node/.openclaw/workspace/AGENTS.md /home/node/.openclaw/workspace/SOUL.md /home/node/.openclaw/workspace/TOOLS.md"

echo.
echo ===================================
echo DEPLOYMENT COMPLETE!
echo ===================================
echo.
echo Next: Restart Jack session and test with:
echo   - What can you do?
echo   - Check my Gmail
echo.

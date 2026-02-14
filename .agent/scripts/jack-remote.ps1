# jack-remote.ps1 — Fast Remote Jack/OpenClaw Operations
# Usage: . .\.agent\scripts\jack-remote.ps1   (dot-source to load functions)
#
# Prerequisites:
#   - SSH key auth configured: ~/.ssh/jack_vps
#   - SSH config alias: Host jack -> root@72.62.252.124
#
# All functions use the 'jack' SSH alias for key-based auth (no passwords).

$Script:JACK_HOST = "jack"
$Script:VPS_IP = "72.62.252.124"
$Script:HEALTH_PORT = 9876

# ─── Core: Run any command on Jack's VPS ───────────────────────────────────────
function Invoke-Jack {
    <#
    .SYNOPSIS
        Run a command on Jack's VPS via SSH key auth.
    .EXAMPLE
        Invoke-Jack "openclaw config validate 2>&1 | head -50"
        Invoke-Jack "cat /root/.openclaw/openclaw.json"
    #>
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Command,
        [int]$TimeoutSeconds = 30
    )
    $result = ssh -o ConnectTimeout=$TimeoutSeconds $Script:JACK_HOST $Command 2>&1
    return $result
}

# ─── Validate OpenClaw Config ──────────────────────────────────────────────────
function Test-JackConfig {
    <#
    .SYNOPSIS
        Validate OpenClaw configuration on the VPS.
    .EXAMPLE
        Test-JackConfig
    #>
    Write-Host "⏳ Validating OpenClaw config..." -ForegroundColor Cyan
    $result = Invoke-Jack "openclaw config validate 2>&1 | head -50"
    $result | ForEach-Object { Write-Host $_ }
    return $result
}

# ─── Health Check (SSH fallback) ───────────────────────────────────────────────
function Get-JackHealth {
    <#
    .SYNOPSIS
        Get Jack's health status. Tries HTTP endpoint first, falls back to SSH.
    .EXAMPLE
        Get-JackHealth
    #>
    # Try HTTP health endpoint first (fastest ~100ms)
    try {
        $response = Invoke-RestMethod -Uri "http://${Script:VPS_IP}:${Script:HEALTH_PORT}/health" -TimeoutSec 3
        Write-Host "✅ Health (via HTTP):" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 5
        return $response
    } catch {
        Write-Host "⚠️  HTTP health endpoint unavailable, falling back to SSH..." -ForegroundColor Yellow
    }

    # SSH fallback
    $result = Invoke-Jack "openclaw health --json 2>&1 | head -30"
    Write-Host "📡 Health (via SSH):" -ForegroundColor Cyan
    $result | ForEach-Object { Write-Host $_ }
    return $result
}

# ─── Download a file from VPS ─────────────────────────────────────────────────
function Get-JackFile {
    <#
    .SYNOPSIS
        Download a file from Jack's VPS to local path.
    .EXAMPLE
        Get-JackFile "/root/.openclaw/openclaw.json" ".\openclaw.json"
        Get-JackFile "/root/.openclaw/workspace/SOUL.md"  # downloads to current dir
    #>
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$RemotePath,
        [Parameter(Position=1)]
        [string]$LocalPath
    )
    if (-not $LocalPath) {
        $LocalPath = Split-Path $RemotePath -Leaf
    }
    Write-Host "⬇️  Downloading ${RemotePath} → ${LocalPath}" -ForegroundColor Cyan
    scp "${Script:JACK_HOST}:${RemotePath}" $LocalPath
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Downloaded successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Download failed" -ForegroundColor Red
    }
}

# ─── Upload a file to VPS ─────────────────────────────────────────────────────
function Send-JackFile {
    <#
    .SYNOPSIS
        Upload a local file to Jack's VPS.
    .EXAMPLE
        Send-JackFile ".\SOUL.md" "/root/.openclaw/workspace/SOUL.md"
    #>
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$LocalPath,
        [Parameter(Mandatory, Position=1)]
        [string]$RemotePath
    )
    Write-Host "⬆️  Uploading ${LocalPath} → ${RemotePath}" -ForegroundColor Cyan
    scp $LocalPath "${Script:JACK_HOST}:${RemotePath}"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Uploaded successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Upload failed" -ForegroundColor Red
    }
}

# ─── Edit a remote file (download → edit locally → upload back) ───────────────
function Edit-JackFile {
    <#
    .SYNOPSIS
        Download a remote file for editing. Call Push-JackEdit when done.
    .EXAMPLE
        Edit-JackFile "/root/.openclaw/workspace/SOUL.md"
        # ... make local edits ...
        Push-JackEdit "/root/.openclaw/workspace/SOUL.md"
    #>
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$RemotePath
    )
    $filename = Split-Path $RemotePath -Leaf
    $editDir = "c:\Users\hisha\Code\Jack\.agent\editing"
    if (-not (Test-Path $editDir)) { New-Item -ItemType Directory -Path $editDir -Force | Out-Null }
    $localPath = Join-Path $editDir $filename

    # Backup on server first
    Invoke-Jack "cp '$RemotePath' '${RemotePath}.bak.$(date +%Y%m%d_%H%M%S)'" | Out-Null
    Write-Host "💾 Backup created on server" -ForegroundColor DarkGray

    Get-JackFile $RemotePath $localPath
    Write-Host "📝 File ready for editing: $localPath" -ForegroundColor Yellow
    Write-Host "   Run: Push-JackEdit `"$RemotePath`" when done" -ForegroundColor DarkGray
    return $localPath
}

function Push-JackEdit {
    <#
    .SYNOPSIS
        Upload an edited file back to the VPS.
    .EXAMPLE
        Push-JackEdit "/root/.openclaw/workspace/SOUL.md"
    #>
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$RemotePath
    )
    $filename = Split-Path $RemotePath -Leaf
    $localPath = Join-Path "c:\Users\hisha\Code\Jack\.agent\editing" $filename

    if (-not (Test-Path $localPath)) {
        Write-Host "❌ No local edit found for $filename" -ForegroundColor Red
        return
    }
    Send-JackFile $localPath $RemotePath
}

# ─── Restart OpenClaw Gateway ─────────────────────────────────────────────────
function Restart-JackGateway {
    <#
    .SYNOPSIS
        Restart the OpenClaw gateway on the VPS.
    #>
    Write-Host "🔄 Restarting OpenClaw gateway..." -ForegroundColor Cyan
    $result = Invoke-Jack "openclaw gateway restart 2>&1"
    $result | ForEach-Object { Write-Host $_ }
    return $result
}

# ─── View OpenClaw Logs ───────────────────────────────────────────────────────
function Get-JackLogs {
    <#
    .SYNOPSIS
        View recent OpenClaw/watchdog logs.
    .EXAMPLE
        Get-JackLogs         # last 30 lines
        Get-JackLogs -Lines 100
    #>
    param([int]$Lines = 30)
    $result = Invoke-Jack "tail -n $Lines /root/openclaw-watchdog/watchdog.log 2>/dev/null || echo 'No watchdog log found'"
    $result | ForEach-Object { Write-Host $_ }
    return $result
}

# ─── Quick Status Summary ─────────────────────────────────────────────────────
function Get-JackStatus {
    <#
    .SYNOPSIS
        Quick overview of Jack's VPS status.
    #>
    Write-Host "`n═══ Jack VPS Status ═══" -ForegroundColor Magenta
    Write-Host "`n📡 OpenClaw Processes:" -ForegroundColor Cyan
    Invoke-Jack "ps aux | grep -E 'openclaw|node' | grep -v grep | head -10" | ForEach-Object { Write-Host "  $_" }
    Write-Host "`n💾 Disk:" -ForegroundColor Cyan
    Invoke-Jack "df -h / | tail -1" | ForEach-Object { Write-Host "  $_" }
    Write-Host "`n🧠 Memory:" -ForegroundColor Cyan
    Invoke-Jack "free -h | head -2" | ForEach-Object { Write-Host "  $_" }
    Write-Host "`n═══════════════════════`n" -ForegroundColor Magenta
}

# ─── Benchmarking ─────────────────────────────────────────────────────────────
function Measure-JackConnection {
    <#
    .SYNOPSIS
        Benchmark SSH connection speed vs old plink method.
    #>
    Write-Host "⏱️  Benchmarking SSH key auth..." -ForegroundColor Cyan
    $ssh_time = Measure-Command { ssh jack "echo ok" 2>$null }
    Write-Host "  SSH key auth: $([math]::Round($ssh_time.TotalMilliseconds))ms" -ForegroundColor Green

    # Try HTTP health if available
    try {
        $http_time = Measure-Command { Invoke-RestMethod -Uri "http://${Script:VPS_IP}:${Script:HEALTH_PORT}/health" -TimeoutSec 5 }
        Write-Host "  HTTP health:  $([math]::Round($http_time.TotalMilliseconds))ms" -ForegroundColor Green
    } catch {
        Write-Host "  HTTP health:  not available" -ForegroundColor DarkGray
    }
}

Write-Host "🚀 Jack Remote Tools loaded. Commands:" -ForegroundColor Green
Write-Host "  Invoke-Jack `"command`"     — Run any command" -ForegroundColor DarkGray
Write-Host "  Test-JackConfig            — Validate config" -ForegroundColor DarkGray
Write-Host "  Get-JackHealth             — Health check" -ForegroundColor DarkGray
Write-Host "  Get-JackFile / Send-JackFile — File transfer" -ForegroundColor DarkGray
Write-Host "  Edit-JackFile / Push-JackEdit — Edit remote files" -ForegroundColor DarkGray
Write-Host "  Restart-JackGateway        — Restart gateway" -ForegroundColor DarkGray
Write-Host "  Get-JackLogs               — View logs" -ForegroundColor DarkGray
Write-Host "  Get-JackStatus             — VPS overview" -ForegroundColor DarkGray
Write-Host "  Measure-JackConnection     — Benchmark speed" -ForegroundColor DarkGray

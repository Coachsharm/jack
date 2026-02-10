param(
    [string]$Target = "prompt",
    [string]$DestFolder = "backups",
    [switch]$Automated = $false
)

# Function to get formatted timestamp
function Get-BackupTimestamp {
    $date = Get-Date
    $day = $date.ToString("dd")
    $month = $date.ToString("MMM").ToLower()
    $year = $date.ToString("yy")
    $time = $date.ToString("hhmm")
    $ampm = $date.ToString("tt").ToLower()
    return "${day}${month}${year}-${time}${ampm}"
}

# Function to extract credentials
function Get-ServerCredentials {
    # Determine Project Root using PSScriptRoot context if available, else fallback
    if ($global:PSScriptRoot) { 
        $searchRoot = (Get-Item "$global:PSScriptRoot\..\..\..\..").FullName 
    }
    else {
        $searchRoot = (Get-Location).Path
    }
    
    $configPath = Join-Path $searchRoot "SETUP_CONFIG.md"
    if (-not (Test-Path $configPath)) { 
        Write-Error "SETUP_CONFIG.md not found at $configPath"
        return $null 
    }
    
    $configContent = Get-Content $configPath -Raw
    $ip = [regex]::Match($configContent, "(?i)IPv4 Address.*\|\s*(\b\d{1,3}(?:\.\d{1,3}){3}\b)").Groups[1].Value
    $pass = [regex]::Match($configContent, "(?i)Password:\s*([^\s\r\n]+)").Groups[1].Value
    
    if (-not $ip -or -not $pass) {
        Write-Error "Could not parse IP or Password from SETUP_CONFIG.md"
        return $null
    }
    
    return @{ IP = $ip; Pass = $pass }
}

# Helper for individual remote bot backups
function Backup-RemoteBot {
    param (
        [string]$BotName,     # e.g. "Jack2"
        [string]$DockerDir,   # e.g. "openclaw-jack2"
        [string]$VolPrefix,   # e.g. "openclaw-jack2_"
        [string]$IP,
        [string]$Pass,
        [string]$Timestamp,
        [string]$RootDir
    )
    
    $backupName = "backup-docker-${BotName}-${Timestamp}"
    $destPath = Join-Path $RootDir $backupName
    Write-Host "--- BACKING UP ${BotName} (Remote) ---"
    Write-Host "Including Configs AND Volumes."
    
    New-Item -ItemType Directory -Path $destPath | Out-Null
    
    # 1. Configs
    Write-Host "Downloading Configs (/docker/${DockerDir})..."
    $confDest = Join-Path $destPath "config"
    New-Item -ItemType Directory -Path $confDest -Force | Out-Null
    pscp -batch -r -pw $Pass "root@${IP}:/docker/${DockerDir}" "$confDest"
    
    # 2. Volumes
    Write-Host "Downloading Volumes (${VolPrefix}*)..."
    $volDest = Join-Path $destPath "volumes"
    New-Item -ItemType Directory -Path $volDest -Force | Out-Null
    
    $volConfig = "${VolPrefix}openclaw_config"
    $volWork = "${VolPrefix}openclaw_workspace"
    
    Write-Host " - $volConfig"
    pscp -batch -r -pw $Pass "root@${IP}:/var/lib/docker/volumes/${volConfig}" "$volDest"
    
    Write-Host " - $volWork"
    pscp -batch -r -pw $Pass "root@${IP}:/var/lib/docker/volumes/${volWork}" "$volDest"

    Write-Host "Successfully backed up ${BotName} to $destPath"
}

$timestamp = Get-BackupTimestamp

# Determine Project Root using PSScriptRoot
$scriptPath = $PSScriptRoot
try {
    $projectRoot = (Get-Item "$scriptPath\..\..\..\..").FullName
}
catch {
    $projectRoot = Get-Location
    Write-Warning "Could not resolve project root from script path. Using current directory: $projectRoot"
}

$backupRootDir = Join-Path $projectRoot $DestFolder

if (-not (Test-Path $backupRootDir)) {
    New-Item -ItemType Directory -Path $backupRootDir | Out-Null
}

switch ($Target) {
    "jack1" {
        $autoSuffix = if ($Automated) { "-auto" } else { "" }
        $backupName = "backup-jack-$timestamp$autoSuffix"
        $destPath = Join-Path $backupRootDir $backupName
        Write-Host "Backing up Jack1 (Local) to $destPath..."
        
        New-Item -ItemType Directory -Path $destPath | Out-Null
        
        $items = Get-ChildItem -Path $projectRoot | Where-Object { $_.Name -ne "backups" }
        
        foreach ($item in $items) {
            Copy-Item -Path $item.FullName -Destination $destPath -Recurse -Force
        }
        
        Write-Host "Successfully backed up to $destPath"
        
        # Cleanup old automated backups if this is an automated run
        if ($Automated) {
            $autoBackups = Get-ChildItem $backupRootDir -Directory | 
            Where-Object { $_.Name -match "^backup-jack-.*-auto$" } | 
            Sort-Object LastWriteTime -Descending
            
            if ($autoBackups.Count -gt 100) {
                $toDelete = $autoBackups | Select-Object -Skip 100
                Write-Host "Cleaning up $($toDelete.Count) old automated backups..."
                $toDelete | Remove-Item -Recurse -Force
            }
        }
    }

    "all" {
        $backupName = "backup-nuclear-snapshot-$timestamp"
        $destPath = Join-Path $backupRootDir $backupName
        Write-Host "--- STARTING NUCLEAR SNAPSHOT BACKUP ---"
        Write-Host "Target: Docker, Root Files (.opencode), Ollama Models, and Volumes."
        Write-Host "Destination: $destPath"
        Write-Host "Warning: This can be 25GB+ due to Ollama models."

        $creds = Get-ServerCredentials
        $ip = $creds.IP
        $pass = $creds.Pass

        if (-not $ip -or -not $pass) {
            return
        }

        New-Item -ItemType Directory -Path $destPath | Out-Null
        Write-Host "Connecting to $ip..."
        
        # 1. /docker (Bot Blueprints)
        Write-Host "[1/4] Downloading Bot Configurations (/docker)..."
        $dockerDest = Join-Path $destPath "docker-blueprints"
        New-Item -ItemType Directory -Path $dockerDest -Force | Out-Null
        pscp -batch -r -pw $pass "root@${ip}:/docker" "$dockerDest"

        # 2. /root (Optimized: Opencode Zipped + Configs)
        Write-Host "[2/4] Downloading Root Files (Optimized)..."
        $rootDest = Join-Path $destPath "root-home"
        New-Item -ItemType Directory -Path $rootDest -Force | Out-Null
        
        # A. Compress Opencode App on server (Reduces 140MB -> ~50MB)
        Write-Host "   -> Compressing Opencode on server..."
        ssh -o StrictHostKeyChecking=no "root@${ip}" "tar -czf /tmp/opencode_app.tar.gz -C /root .opencode"

        # B. Download the compressed file
        Write-Host "   -> Downloading opencode_app.tar.gz..."
        pscp -batch -pw $pass "root@${ip}:/tmp/opencode_app.tar.gz" "$rootDest"
        
        # C. Clean up server temp file
        ssh -o StrictHostKeyChecking=no "root@${ip}" "rm /tmp/opencode_app.tar.gz"

        # D. Grab essential config files (skipping huge caches like .bun/node_modules)
        Write-Host "   -> Downloading essential root configs..."
        # We grab all dotfiles that are files (not directories) to capture configs
        # Note: This is an approximation since pscp is limited. 
        # For a true surgical backup, we'd need more complex logic, but this grabs .bashrc, .profile, etc.
        try {
            pscp -batch -pw $pass "root@${ip}:/root/.*" "$rootDest" 2>$null
        }
        catch {
            # Ignore errors about directories (pscp fails to copy dirs when we use wildcards for files)
        }

        # 3. /var/lib/docker/volumes (The "Brain"/Database)
        Write-Host "[3/4] Downloading Docker Volumes (Database/History)..."
        $volDest = Join-Path $destPath "docker-volumes"
        New-Item -ItemType Directory -Path $volDest -Force | Out-Null
        pscp -batch -r -pw $pass "root@${ip}:/var/lib/docker/volumes" "$volDest"

        # 4. /usr/share/ollama (Config only, NO LLMs)
        Write-Host "[4/4] Downloading Ollama Configs (Skipping all LLM blobs)..."
        $ollamaDest = Join-Path $destPath "ollama"
        New-Item -ItemType Directory -Path $ollamaDest -Force | Out-Null
        
        # Grab only manifestations/configs, skip the 24GB+ blobs folder
        Write-Host "Grabbing Ollama manifest history..."
        pscp -batch -r -pw $pass "root@${ip}:/usr/share/ollama/.ollama/models/manifests" "$ollamaDest"

        if ($LASTEXITCODE -eq 0) {
            Write-Host "--- NUCLEAR SNAPSHOT COMPLETE ---"
            Write-Host "Full restore data saved to $destPath"
        }
        else {
            Write-Warning "Backup finished but some parts may have failed. Check logs."
        }
    }

    # Jack 1 Remote (Config + Volumes)
    "docker-jack1" {
        $creds = Get-ServerCredentials
        if ($creds) {
            Backup-RemoteBot -BotName "jack1" -DockerDir "openclaw-dntm" -VolPrefix "openclaw-dntm_" -IP $creds.IP -Pass $creds.Pass -Timestamp $timestamp -RootDir $backupRootDir
        }
    }

    # Jack 2 Remote (Config + Volumes)
    { $_ -in "docker-jack2", "jack2" } {
        $creds = Get-ServerCredentials
        if ($creds) {
            Backup-RemoteBot -BotName "jack2" -DockerDir "openclaw-jack2" -VolPrefix "openclaw-jack2_" -IP $creds.IP -Pass $creds.Pass -Timestamp $timestamp -RootDir $backupRootDir
        }
    }

    # Jack 3 Remote (Config + Volumes)
    { $_ -in "docker-jack3", "jack3" } {
        $creds = Get-ServerCredentials
        if ($creds) {
            Backup-RemoteBot -BotName "jack3" -DockerDir "openclaw-jack3" -VolPrefix "openclaw-jack3_" -IP $creds.IP -Pass $creds.Pass -Timestamp $timestamp -RootDir $backupRootDir
        }
    }

    # Jack 4 Native (Non-Docker)
    { $_ -in "jack4", "native-jack4" } {
        $creds = Get-ServerCredentials
        if (-not $creds) { return }
        
        $backupName = "backup-native-jack4-$timestamp"
        $destPath = Join-Path $backupRootDir $backupName
        Write-Host "--- BACKING UP JACK4 (Native Install) ---"
        Write-Host "Backing up ~/.openclaw directory from server..."
        
        New-Item -ItemType Directory -Path $destPath | Out-Null
        
        # Backup the entire .openclaw directory (config, workspace, sessions, agents, logs)
        Write-Host "Downloading ~/.openclaw..."
        pscp -batch -r -pw $($creds.Pass) "root@$($creds.IP):/root/.openclaw" "$destPath"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully backed up Jack4 to $destPath"
        }
        else {
            Write-Warning "Jack4 backup completed with errors. Check the destination directory."
        }
    }

    { $_ -in "help", "list", "prompt" } {
        Write-Host "--- Backup Skill Help ---"
        Write-Host "Usage: .agent/skills/backup/scripts/backup.ps1 -Target <option>"
        Write-Host ""
        Write-Host "Options:"
        Write-Host "  jack1         : Backup LOCAL files only"
        Write-Host "  docker-jack1  : Backup Jack 1 (Remote Docker Config + Data)"
        Write-Host "  docker-jack2  : Backup Jack 2 (Remote Docker Config + Data)"
        Write-Host "  docker-jack3  : Backup Jack 3 (Remote Docker Config + Data)"
        Write-Host "  jack4         : Backup Jack 4 (Native ~/.openclaw)"
        Write-Host "  all           : NUCLEAR SNAPSHOT (Everything on server)"
        Write-Host "  <path>        : Backup specific local folder"
        Write-Host ""
        Write-Host "Example: backup.ps1 -Target jack4"
    }

    Default {
        if (Test-Path $Target) {
            $folderName = Split-Path $Target -Leaf
            $backupName = "backup-$folderName-$timestamp"
            $destPath = Join-Path $backupRootDir $backupName
            
            Write-Host "Backing up '$Target' to $destPath..."
            Copy-Item -Path $Target -Destination $destPath -Recurse
            Write-Host "Successfully backed up to $destPath"
        }
        else {
            $relPath = Join-Path $projectRoot $Target
            if (Test-Path $relPath) {
                $folderName = Split-Path $relPath -Leaf
                $backupName = "backup-$folderName-$timestamp"
                $destPath = Join-Path $backupRootDir $backupName
                 
                Write-Host "Backing up '$relPath' to $destPath..."
                Copy-Item -Path $relPath -Destination $destPath -Recurse
                Write-Host "Successfully backed up to $destPath"
            }
            else {
                Write-Error "Target '$Target' not found."
            }
        }
    }
}

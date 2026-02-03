$password = "Corecore8888-"
$commands = @(
    "docker exec openclaw-dntm-openclaw-1 cat /home/node/.openclaw/SOUL.md",
    "docker exec openclaw-dntm-openclaw-1 ls -la /home/node/ | grep -i openclaw"
)

foreach ($cmd in $commands) {
    Write-Host "Executing: $cmd" -ForegroundColor Cyan
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ("root", $securePassword)
    
    # Use Plink if available, otherwise manual SSH
    try {
        echo $password | ssh -o StrictHostKeyChecking=no root@72.62.252.124 $cmd
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    Write-Host "`n---`n"
}

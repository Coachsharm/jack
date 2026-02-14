---
name: SSH Key Auth Setup
description: Set up passwordless SSH key-based authentication to Jack's VPS, replacing plink/pscp with native OpenSSH ssh/scp commands.
---

# 🔑 Skill: SSH Key Auth Setup

**Last Verified:** 2026-02-14 | **Status:** ✅ Active | **Architecture:** Native OpenClaw

> **⚠️ SAFETY CHECK:** Before running this skill, verify:
> - You are on Coach Sharm's Windows PC (the SSH keys are local to this machine)
> - The VPS IP hasn't changed from `72.62.252.124`
> - OpenSSH is available on the PC (`ssh` and `ssh-keygen` commands work)

## 🎯 Purpose
Replace slow, insecure password-based SSH (plink/pscp) with fast, secure SSH key authentication.

**Problem Solved:**
- Eliminates `plink -batch -pw "PASSWORD" root@72.62.252.124 "command"` pattern
- Removes plaintext passwords from command lines
- Reduces SSH connection time from ~2-3s to ~330ms
- Provides `ssh jack "command"` shorthand for all server operations

## 📋 Prerequisites
- [ ] Windows PC with OpenSSH installed (`c:\windows\system32\openssh\ssh.exe`)
- [ ] Network access to VPS at `72.62.252.124`
- [ ] One-time: know the VPS root password (to deploy the key initially)

## 🚀 The Procedure

### Step 1: Generate SSH Key (if not exists)
Check if `~/.ssh/jack_vps` already exists. If not, generate it:

```powershell
# Check for existing key
Test-Path "$env:USERPROFILE\.ssh\jack_vps"

# Generate new Ed25519 key (if missing)
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\jack_vps" -N ""
```

### Step 2: Extract Public Key
If the `.pub` file is missing, extract it from the private key:

```powershell
ssh-keygen -y -f "$env:USERPROFILE\.ssh\jack_vps" > "$env:USERPROFILE\.ssh\jack_vps.pub"
```

### Step 3: Deploy Key to VPS
Use the existing password ONE LAST TIME to deploy the public key:

```powershell
# Read the public key
$pubkey = (Get-Content "$env:USERPROFILE\.ssh\jack_vps.pub" -Raw).Trim()

# Deploy to server (requires password this one time)
& "C:\Program Files\PuTTY\plink.exe" -batch -pw "PASSWORD" root@72.62.252.124 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pubkey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && echo KEY_DEPLOYED"
```

> **Note:** This is the LAST time a password is used. After this, key auth takes over.

### Step 4: Create SSH Config
Create `~/.ssh/config` with a `jack` host alias:

```powershell
@"
# Jack VPS - Hostinger Server
Host jack
    HostName 72.62.252.124
    User root
    IdentityFile ~/.ssh/jack_vps
    IdentitiesOnly yes
    StrictHostKeyChecking no
    ConnectTimeout 10
    ServerAliveInterval 30
    ServerAliveCountMax 3
"@ | Set-Content -Path "$env:USERPROFILE\.ssh\config" -Encoding UTF8
```

### Step 5: Fix Config Permissions
Windows OpenSSH requires strict file permissions:

```powershell
$configPath = "$env:USERPROFILE\.ssh\config"
icacls $configPath /inheritance:r /grant:r "${env:USERNAME}:(R,W)" /grant:r "SYSTEM:(R)"
```

### Step 6: Test Key Auth
Verify passwordless connection works:

```powershell
ssh jack "echo SSH_KEY_AUTH_SUCCESS"
```

Expected output: `SSH_KEY_AUTH_SUCCESS`

### Step 7: Update Documentation
After setup, update all instruction files to use the new method:

| File | What to Change |
|------|---------------|
| `custominstructions.md` | Replace `plink`/`pscp`/password refs with `ssh jack`/`scp jack:` |
| `claude.md` | Replace `sshpass`/`root@72.62.252.124` with `ssh jack`/`scp jack:` |
| `Gemini.md` | Same as claude.md (keep in sync) |
| `jack_server_workflow.md` | Replace all plink commands with `ssh jack` |

## 📖 Usage Reference (Post-Setup)

```powershell
# Run any command on VPS
ssh jack "openclaw config validate 2>&1 | head -50"

# Download a file
scp jack:/root/.openclaw/workspace/SOUL.md .\local_copy.md

# Upload a file
scp .\local_file.md jack:/root/.openclaw/workspace/FILENAME.md

# Interactive SSH session
ssh jack

# Quick health check (HTTP, no SSH needed)
curl http://72.62.252.124/health.json
```

## 🔍 Verification
How to confirm the setup is working:

1. **Key auth**: `ssh jack "echo ok"` → should return instantly with no password prompt
2. **SCP download**: `scp jack:/etc/hostname .` → should download without prompt
3. **SCP upload**: Create a test file and upload: `echo test | scp - jack:/tmp/test.txt`
4. **Benchmark**: 
   ```powershell
   $t = Measure-Command { ssh jack "echo ok" }; Write-Host "$([math]::Round($t.TotalMilliseconds))ms"
   ```
   Expected: ~300-500ms (vs ~2000-3000ms with password auth)

## 🛑 Failure Modes

### "Permission denied (publickey,password)"
The key isn't in `authorized_keys` on the server. Re-deploy using Step 3.

### "Bad permissions" on config file
Run Step 5 again to fix Windows file permissions.

### "Connection refused" or timeout
- Check VPS is reachable: `ping 72.62.252.124`
- Check SSH service on VPS: may need to use VPS provider's web console

### Key was compromised
Regenerate:
```powershell
# Remove old key from server
ssh jack "sed -i '/jack_vps/d' ~/.ssh/authorized_keys"
# Delete local key
Remove-Item "$env:USERPROFILE\.ssh\jack_vps*"
# Start from Step 1
```

## 🍎 Mac Setup (Second Machine)

The same key-auth setup works on Mac, with a **bonus**: macOS supports `ControlMaster` for persistent SSH connections (~50ms per call after the first).

### Mac Step 1: Generate Key
```bash
ssh-keygen -t ed25519 -f ~/.ssh/jack_vps -N ""
```

### Mac Step 2: Deploy Key to VPS
```bash
ssh-copy-id -i ~/.ssh/jack_vps.pub root@72.62.252.124
# Enter password ONE time, then never again
```

### Mac Step 3: Create SSH Config (with ControlMaster!)
```bash
mkdir -p ~/.ssh/sockets

cat >> ~/.ssh/config << 'EOF'
# Jack VPS - Hostinger Server
Host jack
    HostName 72.62.252.124
    User root
    IdentityFile ~/.ssh/jack_vps
    IdentitiesOnly yes
    StrictHostKeyChecking no
    ConnectTimeout 10
    ServerAliveInterval 30
    ServerAliveCountMax 3
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
EOF

chmod 600 ~/.ssh/config
```

> **ControlPersist 600** = first connection stays open for 10 minutes. All subsequent `ssh jack` calls reuse it at ~50ms instead of ~330ms.

### Mac Step 4: Test
```bash
ssh jack "echo MAC_SSH_SUCCESS"
```

### Multi-Machine Safety
- The server's `authorized_keys` holds one line per machine — they don't conflict
- If a key is compromised, remove just that one line: `ssh jack "sed -i '/COMMENT/d' ~/.ssh/authorized_keys"`
- Each machine has its own private key — never share private keys between devices

## 🏗️ Infrastructure Notes

### What's on the server
- Key stored in: `/root/.ssh/authorized_keys`
- Health check script: `/root/health-check.sh` (runs every 2 min via cron)
- Health endpoint: `/var/www/html/health.json` (served by nginx)

### What's on the PC
- Private key: `~/.ssh/jack_vps`
- Public key: `~/.ssh/jack_vps.pub`
- SSH config: `~/.ssh/config` (Host `jack` alias)

### Windows Limitation
Windows OpenSSH does NOT support `ControlMaster`/`ControlPersist` (Unix-only). Each `ssh jack` call is a fresh TCP connection, but key auth makes it fast (~330ms). For instant status checks, use the HTTP health endpoint instead.

---
**Skill Metadata**
- **Created From Task:** SSH key auth migration replacing plink/password-based SSH
- **Created By:** Antigravity
- **Created:** 2026-02-14

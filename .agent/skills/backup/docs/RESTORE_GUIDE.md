# Disaster Recovery: Restoring Jack to a New Server

This guide explains how to restore the "Nuclear Snapshot" backup to a fresh Hostinger VPS (or any Ubuntu server).

## 📦 About the Backup
Your backup uses **smart compression** to save space:
- **Opencode app**: Compressed from 140MB → 50MB (as `opencode_app.tar.gz`)
- **Docker configs, volumes, and Ollama manifests**: Uncompressed for easy access
- **Total size**: ~55MB (down from 199MB)

The restore process will decompress everything automatically.

## 1. Prerequisites (On the New Server)
Login to your new server via SSH (`ssh root@new-ip`) and install the basics:

```bash
# 1. Update System
apt update && apt upgrade -y

# 2. Install Docker & Docker Compose
curl -fsSL https://get.docker.com | sh

# 3. Install Ollama (for AI models)
curl -fsSL https://ollama.com/install.sh | sh
```

## 2. Copy Backup Files (From Local to New Server)
From your local Windows machine (PowerShell), locate your latest backup folder (e.g., `backup-nuclear-snapshot-03feb26-0300pm`) and upload it.

```powershell
# In PowerShell:
$NewIP = "YOUR.NEW.SERVER.IP"
$BackupDir = "C:\Users\hisha\Code\Jack\backups\backup-nuclear-snapshot-03feb26-0300pm"

# Upload everything to a temporary folder on the server
scp -r $BackupDir root@${NewIP}:/root/restore_temp
```

## 3. The Restore Procedure (On the New Server)
Back on the server SSH, move the files to their correct homes.

### A. Restore Root & Opencode
This restores your home files, scripts, and the Opencode app.

**IMPORTANT**: The Opencode app is now backed up as a compressed archive to save space.

```bash
# 1. Extract the compressed Opencode app
cd /root/restore_temp/root-home
tar -xzf opencode_app.tar.gz -C /root/

# 2. Copy other root config files (if any exist)
# Be careful not to overwrite SSH keys if you want to keep new ones
cp -n .bashrc .profile /root/ 2>/dev/null || true

# 3. Restore permissions
chown -R root:root /root/.opencode
chmod +x /root/.opencode/bin/opencode
```

### B. Restore Docker Blueprints
This puts your bot configurations back in place.
```bash
# Create directory if missing
mkdir -p /docker

# Copy files
cp -r /root/restore_temp/docker-blueprints/* /docker/
```

### C. Restore "The Brain" (Volumes) 🧠
*Critical Step: This restores the database and memories.*

```bash
# Stop Docker first to be safe
systemctl stop docker

# Restore the volumes directory
cp -r /root/restore_temp/docker-volumes/* /var/lib/docker/volumes/

# Restart Docker
systemctl start docker
```

### D. Restore Ollama (Models)
We only backed up the configs (manifests), so we need to put them back and then force Ollama to re-download the blobs.

```bash
# Stop Ollama service
systemctl stop ollama

# Restore manifests
cp -r /root/restore_temp/ollama/manifests /usr/share/ollama/.ollama/models/

# Restart Ollama
systemctl start ollama

# ⚠️ TRIGGER RE-DOWNLOAD
# Since we didn't backup the 24GB blobs, we force Ollama to pull them again 
# by "pulling" the models listed in your manifests.
# Example (Run 'ollama list' to see what you had, then pull them):
ollama pull deepseek-r1:7b
ollama pull nomic-embed-text
```

## 4. Launch the Bots 🚀
Now that the files and brains are in place, turn them on.

```bash
cd /docker/openclaw-dntm
docker compose up -d

cd /docker/openclaw-jack2
docker compose up -d

# ...and so on for Jack3
```

**System Restored!** ✅

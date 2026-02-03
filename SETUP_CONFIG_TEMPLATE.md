# Jack - OpenClaw Bot Complete Setup & Configuration Guide

> **⚠️ SECURITY WARNING**: This document contains sensitive credentials and API keys. Never commit this file to public repositories.

## Table of Contents
1. [Overview](#overview)
2. [API Keys & Credentials](#api-keys--credentials)
3. [Server Infrastructure](#server-infrastructure)
4. [OpenClaw Documentation](#openclaw-documentation)
5. [Installation & Setup Steps](#installation--setup-steps)
6. [Docker Management](#docker-management)
7. [SSH Access Guide](#ssh-access-guide)
8. [Troubleshooting](#troubleshooting)

---

## Overview

**Bot Name**: Jack  
**Platform**: OpenClaw AI Bot Framework  
**Hosting**: Hostinger VPS (Docker Container)  
**Channels**: WhatsApp, Telegram  
**Deployment Method**: Docker on Hostinger VPS (NOT local installation)

### Current Status
- ✅ OpenClaw installed and running in Docker container
- ✅ OpenClaw Dashboard accessible at http://72.62.252.124:61958
- 🔧 Configuration in progress

### Immediate Task
**Objective**: Get Jack working on Telegram (not WhatsApp for now)

**Configuration Target**:
- **Platform**: Telegram (@thrive2bot)
- **LLM Provider**: OpenRouter
- **Model**: GPT-4o (using `openai/gpt-4o` or OpenRouter's equivalent)
- **Approach**: Keep it simple for initial setup

---

## API Keys & Credentials

### OpenClaw API
```
API Key: REDACTED_OPENCLAW_KEY
```

### OpenRouter API
```
API Key: REDACTED_OPENROUTER_KEY
```

### OpenAI API
```
API Key: REDACTED_OPENAI_KEY
```

### Anthropic API
**Valid Until**: February 1st, 2026
```
API Key: REDACTED_ANTHROPIC_KEY
```

### DeepSeek API
**Account**: moltbot aclp  
**Valid Until**: January 31st, 2026
```
API Key: REDACTED_DEEPSEEK_KEY
```

### Telegram Bot API
**Bot Username**: @thrive2bot  
**Bot Link**: https://t.me/thrive2bot
```
HTTP API Token: REDACTED_TELEGRAM_TOKEN
```

---

## Server Infrastructure

### VPS Details

| Property | Value |
|----------|-------|
| **Provider** | Hostinger |
| **Plan** | KVM 2 |
| **Location** | Malaysia, Kuala Lumpur |
| **Operating System** | Ubuntu 24.04 LTS |
| **Hostname** | srv1304133.hstgr.cloud |
| **IPv4 Address** | 72.62.252.124 |

### Resource Allocation

| Resource | Specification |
|----------|--------------|
| **CPU Cores** | 2 |
| **Memory (RAM)** | 8 GB |
| **Disk Space** | 100 GB |

### Plan Information

| Detail | Value |
|--------|-------|
| **Expiration Date** | 2026-02-28 |
| **Auto-renewal** | Enabled |

### SSH Root Access

#4: **Server**: Hostinger VPS (SRV1304133)
5: **IP Address**: REDACTED_IP
6: **Location**: Singapore (SG)
7: 
8: ```
9: Username: REDACTED_USER
10: Password: REDACTED_PASSWORD
11: ```
12: 
13: ### Management Key
14: ```
15: Key: REDACTED_MANAGEMENT_KEY
16: ```
For easier and more secure access, SSH key authentication has been set up.

**Local SSH Key Location:**
```
Private Key: /Users/coachsharm/.ssh/jack_vps
Public Key: /Users/coachsharm/.ssh/jack_vps.pub
```

**Public Key:**
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFQwMqtdlNBY5MqTCpsxYVTD47Wc680vsUbAXcsdQr3 jack-openclaw-vps
```

**Connect using SSH Key:**
```bash
ssh -i ~/.ssh/jack_vps root@72.62.252.124
```

**Note:** The public key has been added to the VPS `/root/.ssh/authorized_keys` file.


### Docker Container Details

| Property | Value |
|----------|-------|
| **Container Name** | openclaw-riau-openclaw-1 |
| **Gateway Dashboard URL** | http://72.62.252.124:61958/chat?session=agent%3Amain%3Amain |

---

## OpenClaw Documentation

### Official Resources

- **Main Website**: `https://openclaw.ai/`
- **Documentation Home**: `https://docs.openclaw.ai/`
- **WhatsApp Channel Setup**: `https://docs.openclaw.ai/channels/whatsapp`
- **Telegram Channel Setup**: `https://docs.openclaw.ai/channels/telegram`

### Standard Installation Method (NOT USED)

**⚠️ Note**: We do NOT use the standard local installation script:
```bash
# DO NOT RUN THIS - For reference only
curl -fsSL https://openclaw.ai/install.sh | bash
```

**Our Method**: Docker installation on Hostinger VPS following the official documentation.

### Hostinger-Specific Documentation

**Installation Guide**:  
`https://www.hostinger.com/support/how-to-install-openclaw-on-hostinger-vps/`

---

## Installation & Setup Steps

### Prerequisites Checklist

- [ ] Hostinger VPS account active and accessible
- [ ] Docker installed on VPS
- [ ] SSH access configured
- [ ] All API keys available
- [ ] OpenClaw API key ready

### Step-by-Step Installation Process

#### 1. Connect to VPS via SSH

```bash
# Open terminal and connect
ssh root@72.62.252.124
# Enter password when prompted: Corecore8888-
```

#### 2. Verify Docker Installation

```bash
# Check Docker version
docker --version

# Check Docker is running
docker ps

# View all containers (including stopped)
docker ps -a
```

#### 3. Follow OpenClaw Documentation

Refer to the official OpenClaw documentation for installation steps:

1. **Initial Setup**: `https://docs.openclaw.ai/`
2. **Docker Configuration**: Follow Hostinger guide at `https://www.hostinger.com/support/how-to-install-openclaw-on-hostinger-vps/`
3. **Channel Setup**: Configure WhatsApp and Telegram channels

#### 4. Configure API Keys

During setup, you'll need to configure the following APIs:

- **OpenClaw API**: Use for bot authentication
- **LLM Provider**: Choose from OpenRouter, OpenAI, Anthropic, or DeepSeek
- **Channel APIs**: Configure for WhatsApp and Telegram

#### 5. Container Management

```bash
# Start the OpenClaw container
docker start openclaw-riau-openclaw-1

# Stop the container
docker stop openclaw-riau-openclaw-1

# Restart the container
docker restart openclaw-riau-openclaw-1

# View container logs
docker logs openclaw-riau-openclaw-1

# Follow logs in real-time
docker logs -f openclaw-riau-openclaw-1

# Access container shell
docker exec -it openclaw-riau-openclaw-1 /bin/bash
```

#### 6. Access OpenClaw Gateway Dashboard

Once the container is running, access the dashboard at:
```
http://72.62.252.124:61958/chat?session=agent%3Amain%3Amain
```

---

## Docker Management

### Common Docker Commands

```bash
# List all running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container details
docker inspect openclaw-riau-openclaw-1

# View container resource usage
docker stats openclaw-riau-openclaw-1

# Remove a stopped container
docker rm openclaw-riau-openclaw-1

# View Docker images
docker images

# Remove unused Docker resources
docker system prune
```

### Container Health Checks

```bash
# Check if container is running
docker ps | grep openclaw

# View recent container logs (last 100 lines)
docker logs --tail 100 openclaw-riau-openclaw-1

# Check container uptime and status
docker inspect openclaw-riau-openclaw-1 | grep Status
```

---

## SSH Access Guide

### Connecting to the Server

```bash
# Method 1: Direct connection with password
ssh root@72.62.252.124
# Enter password: Corecore8888-

# Method 2: Connection with hostname
ssh root@srv1304133.hstgr.cloud
# Enter password: Corecore8888-
```

### Basic Server Navigation

```bash
# Check current directory
pwd

# List files and directories
ls -la

# Navigate to home directory
cd ~

# View system information
uname -a

# Check available disk space
df -h

# Check memory usage
free -h

# View running processes
ps aux

# Check server uptime
uptime
```

### File Management

```bash
# Create a directory
mkdir directory_name

# Copy files
cp source destination

# Move/rename files
mv source destination

# Delete files
rm filename

# Delete directories
rm -r directory_name

# View file contents
cat filename

# Edit files (using nano)
nano filename
```

---

## Troubleshooting

### Container Not Running

```bash
# Check if container exists
docker ps -a | grep openclaw

# Start the container if stopped
docker start openclaw-riau-openclaw-1

# Check logs for errors
docker logs --tail 50 openclaw-riau-openclaw-1
```

### Connection Issues

```bash
# Test SSH connection
ping 72.62.252.124

# Verify SSH service is running on VPS
systemctl status sshd

# Check Docker service status
systemctl status docker
```

### API Issues

1. **Verify API Keys**: Double-check all API keys are correctly configured
2. **Check API Expiration**: Note that some APIs have expiration dates
   - Anthropic: February 1st, 2026
   - DeepSeek: January 31st, 2026
3. **Test API Connectivity**: Use the OpenClaw dashboard to test API connections

### Port Access Issues

```bash
# Check if ports are open
netstat -tuln | grep 61958

# Verify firewall settings
ufw status

# Check Docker port mappings
docker port openclaw-riau-openclaw-1
```

---

## Workflow Principles

### ✅ DO:
- Use SSH terminal to access the VPS
- Work within the Docker container on the server
- Follow OpenClaw official documentation
- Use the IDE for viewing/editing local documentation
- Use browser only when necessary for dashboard access

### ❌ DO NOT:
- Install anything locally on your machine
- Run the standard OpenClaw installation script locally
- Work outside of the VPS environment

---

## Quick Reference Commands

```bash
# Connect to VPS
ssh root@72.62.252.124

# Access OpenClaw container
docker exec -it openclaw-riau-openclaw-1 /bin/bash

# View logs
docker logs -f openclaw-riau-openclaw-1

# Restart bot
docker restart openclaw-riau-openclaw-1

# Access dashboard
# Browser: http://72.62.252.124:61958/chat?session=agent%3Amain%3Amain
```

---

## Notes

- **Bot Name**: Jack
- **Current Status**: Installed and running in Docker container on Hostinger VPS
- **Access Method**: SSH + Docker commands only
- **No Local Installation**: All work must be done on the VPS via terminal

---

**Document Created**: February 1st, 2026  
**Last Updated**: February 1st, 2026  
**Version**: 1.0

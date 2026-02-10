# John — Setup Guide

> Step-by-step guide to deploy a new John instance for a customer.

## Prerequisites

- A VPS with at least 2 GB RAM and 1 CPU core (Hostinger, DigitalOcean, etc.)
- Docker and Docker Compose installed
- A Telegram Bot Token (from [@BotFather](https://t.me/botfather))
- An LLM API key (Anthropic Claude, OpenAI, or Google Gemini)

## Step 1: Prepare the Server

```bash
# SSH into the customer's server
ssh root@<server-ip>

# Install Docker if not present
curl -fsSL https://get.docker.com | sh

# Create the client directory
mkdir -p /root/openclaw-clients/<customer-name>
cd /root/openclaw-clients/<customer-name>
```

## Step 2: Copy Template Files

From your admin machine, upload the template:

```powershell
# From Coach's PC
scp -r c:\Users\hisha\Code\Jack\john\template\* root@<server-ip>:/root/openclaw-clients/<customer-name>/
```

## Step 3: Configure Secrets

```bash
# On the server
mkdir -p secrets

# Set the Telegram bot token
echo "BOT_TOKEN_HERE" > secrets/telegram_token.txt

# Set the gateway token (generate one)
openssl rand -hex 32 > secrets/gateway_token.txt

# Lock permissions
chmod 600 secrets/*
```

## Step 4: Configure the Bot

Edit `openclaw.json` with the customer's details:

```bash
nano openclaw.json
```

**Key fields to customize:**
| Field | What to set |
|-------|-------------|
| `llm.provider` | Customer's LLM provider (e.g., `anthropic`, `openai`) |
| `llm.model` | Preferred model (e.g., `claude-sonnet-4-20250514`) |
| `llm.apiKey` | Customer's API key |
| `agents[0].name` | Bot's display name |
| `channels.telegram.token` | Set to `"__SECRET__"` (loaded from Docker secret) |

## Step 5: Customize the Persona

Edit `workspace/SOUL.md` to define the bot's personality for the customer's use case.

## Step 6: Deploy

```bash
docker compose up -d

# Verify health
docker logs openclaw-<customer-name> --tail 20

# Check health endpoint
curl http://localhost:19385/health
```

## Step 7: Pair Telegram

```bash
# Inside the container
docker exec -it openclaw-<customer-name> openclaw channels telegram pair
```

## Maintenance

### Check Status
```bash
docker ps | grep openclaw-<customer-name>
docker logs openclaw-<customer-name> --tail 50
```

### Restart
```bash
docker compose restart
```

### Update OpenClaw
```bash
docker compose pull
docker compose up -d
```

### Backup
```bash
tar czf backup-<customer-name>-$(date +%Y%m%d).tar.gz \
  openclaw.json workspace/ data/ secrets/
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Container won't start | Check `docker logs openclaw-<customer-name>` |
| Telegram not connecting | Verify token in `secrets/telegram_token.txt` |
| Bot not responding | Check `curl localhost:19385/health` |
| High memory usage | Container is capped at 2GB, restart if needed |

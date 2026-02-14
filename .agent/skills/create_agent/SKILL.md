---
name: Create New Agent
description: Step-by-step procedure to add a new AI agent (like John or Ross) to the OpenClaw system using the CLI and multi-agent routing.
---

# 🤖 Create New Agent Skill

**Trigger:** `/create-agent` or when adding a new team member (John, Ross, etc.)

## Purpose
This skill guides you through the complete process of adding a new agent to your OpenClaw system. It covers creating the agent, setting up its brain, and configuring the critical routing rules so messaged go to the right bot.

## Prerequisites
- **Name:** Decide on the agent's name (e.g., "John")
- **Role:** Define their job (e.g., "Tech Support")
- **Bot Token:** Generate a new Telegram bot token from `@BotFather`
- **Model:** Choose an LLM (e.g., `gemini/gemini-2.0-flash-exp` or `anthropic/claude-3-5-sonnet-20240620`)

---

## Procedure

### Step 1: Create Agent on Server
Use the OpenClaw CLI on the server to register the agent. replace `<AGENT_NAME>` (lowercase) and `<MODEL>`.

```bash
# Example for John
ssh jack "openclaw agent create john --model gemini/gemini-2.0-flash-exp"
```

### Step 2: Create Workspace Directory (Server)
Give the agent a home on the server.
```bash
ssh jack "mkdir -p /root/.openclaw/workspace-john"
```
*(Replace `john` with your agent name)*

### Step 3: Create Local Workspace (PC)
Set up the file structure on your computer.
```powershell
# Create local folder
mkdir "c:\Users\hisha\Code\Jack\john\workspace"

# Copy base templates from Sarah (good starting point)
cp "c:\Users\hisha\Code\Jack\sarah\workspace\USER.md" "c:\Users\hisha\Code\Jack\john\workspace\"
cp "c:\Users\hisha\Code\Jack\sarah\workspace\HEARTBEAT.md" "c:\Users\hisha\Code\Jack\john\workspace\"
cp "c:\Users\hisha\Code\Jack\sarah\workspace\HUMAN_TEXTING_GUIDE.md" "c:\Users\hisha\Code\Jack\john\workspace\"
```

### Step 4: Customize Brain Files
Create the unique files for this agent in `c:\Users\hisha\Code\Jack\john\workspace\`.

**1. IDENTITY.md**
```markdown
- **Name:** John
- **Telegram Bot:** @thrive_john_bot
- **Role:** Tech Support Lead
- **Vibe:** Technical, precise, helpful
```

**2. SOUL.md**
Define who they are.
```markdown
# SOUL.md - Who You Are
You are John, the Tech Support Lead.
- Your job is to solve technical issues.
- You speak clearly and concisely.
- You value accuracy over speed.
```

### Step 5: Configure Routing (Critical!)
You must edit `openclaw.json` to tell the system which bot talks to which agent.

**1. Download current config:**
```powershell
scp "jack:/root/.openclaw/openclaw.json" "c:\Users\hisha\Code\Jack\openclaw.json"
```

**2. Edit `openclaw.json` locally:**
Add the new account to `telegram.accounts`:
```json
"john": {
  "name": "John (Tech Support)",
  "botToken": "YOUR_NEW_BOT_TOKEN_HERE"
}
```

Add the routing rule to `bindings` (at the root of the JSON object):
```json
{
  "agentId": "john",
  "match": {
    "channel": "telegram",
    "accountId": "john"
  }
}
```

**3. Upload updated config:**
```powershell
scp "c:\Users\hisha\Code\Jack\openclaw.json" "jack:/root/.openclaw/openclaw.json"
```

### Step 6: Upload Brain Files & Restart
Send everything to the server and boot up.

```powershell
# Upload brain files
scp "c:\Users\hisha\Code\Jack\john\workspace\*" "jack:/root/.openclaw/workspace-john/"

# Clear any stale sessions (just in case)
ssh jack "rm -f /root/.openclaw/agents/john/sessions/sessions.json"

# Restart Gateway
ssh jack "openclaw gateway restart"
```

### Step 7: Verify
1. Message the new bot on Telegram.
2. Check the logs: `ssh jack "journalctl -u openclaw-gateway -f"`
3. Verify they know who they are: "Who are you and what is your workspace path?"

---

## Troubleshooting

### Agent responds as "Jack"?
- **Check Bindings:** You likely forgot to add the binding in `openclaw.json` or the `accountId` doesn't match.
- **Restart Gateway:** Configuration changes require a restart.

### Agent is silent?
- Check if brain files are uploaded to the correct folder (`workspace-john` vs `workspace`).
- Check if the model name is correct and available.

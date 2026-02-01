# positive_lessons/SUCCESS_LLM_INTEGRATION_AND_SCALING_GUIDE_2026-02-01.md

**Date:** 2026-02-01
**Topic:** Best Practices for OpenClaw/LLM Integration & Bot Scaling
**Audience:** Junior Developers / Future Self

## 1. Overview
This document records the successful strategies we employed to stabilize and scale our OpenClaw bot infrastructure ("Jack"). It serves as a guide for replicating these wins in future deployments.

## 3. The "Success Code" (What and Where)

To replicate the successful **OpenAI GPT-4o (via OpenRouter)** setup, follow these exact configurations.

### Location 1: The `.env` File
**Path:** `/docker/openclaw-dntm/.env` (Project Root)
**What to add:**
```env
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Location 2: The `openclaw.json` File
**Path (Host):** `/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json`
**Path (Inside Container):** `/home/node/.openclaw/openclaw.json`

**The "Winning" Code Snippet:**
This configuration ensures the bot defaults to GPT-4o through OpenRouter immediately upon startup.

```json
{
  "env": {
    "OPENROUTER_API_KEY": "sk-or-v1-xxxxxxxxxxxxxxxxxxxxxxxxx"
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openrouter/openai/gpt-4o"
      },
      "models": {
        "openrouter/openai/gpt-4o": {}
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "xxxxxxxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    }
  }
}
```

### Location 3: The `models.json` File (For Advanced Multi-Model)
**Path:** `/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/agents/main/models.json`
**Why:** Use this to define custom providers or override default model behaviors.

### Adding "Others" (Scaling your Model Selection)
To add more models from OpenRouter or other providers, update the `models` block in `openclaw.json`.

**The "Multi-Model" Snippet:**
```json
"models": {
  "openrouter/openai/gpt-4o": { "alias": "GPT-4o" },
  "openrouter/anthropic/claude-3.5-sonnet": { "alias": "Claude 3.5" },
  "openrouter/deepseek/deepseek-chat": { "alias": "DeepSeek" }
}
```
*Note: Using aliases like "GPT-4o" makes it easier for users to switch models in Telegram using the `/model` command.*

---

## 4. Infrastructure Scaling & Docker Management

We successfully scaled from one bot ("Jack1") to three ("Jack2", "Jack3") using a systematic cloning process.

### The "Cloning" Protocol
When you need to spin up a new instance (e.g., specific agent for a new task):

1.  **Directory Structure**: Create distinct directories for state isolation.
    *   `mkdir /docker/openclaw-jack2`
2.  **File Duplication**: Copy the *infrastructure* files (compose, env) but *not* the identity/state immediately.
3.  **Port Management**: Crucial step. We assigned unique ports to avoid conflicts:
    *   Jack1: `62059`
    *   Jack2: `62060`
    *   Jack3: `62061`
4.  **Volume Initialization**: We used Docker volumes for persistence (`/var/lib/docker/volumes/...`) ensuring data survives container restarts.

## 4. Operational Wins
*   **Verification loops**: We didn't just assume it worked. We verified "Approve Jack[N] pairing code" and "Verify all bots responding" for each instance.
*   **Clean Configs**: We located the exact config paths on the VPS before editing, preventing "editing the wrong file" errors.

## 5. Summary associated "Garbage" Collection
*   *Note: Previous confusion regarding local Ollama networking versus Cloud APIs has been resolved. The lesson is: For immediate production stability, prefer the stable Cloud API (OpenRouter) while researching local networking in parallel.*

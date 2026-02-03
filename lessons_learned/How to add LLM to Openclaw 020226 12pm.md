# How to add LLM to Openclaw 020226 12pm

This guide provides a foundational lesson on configuring **OpenClaw**, an autonomous AI agent platform, specifically focusing on integrating **DeepSeek** as the primary intelligence engine.

## Lesson Overview
In this lesson, you will learn how to connect an external AI model to OpenClaw using its configuration file, `openclaw.json`. We will focus on DeepSeek, a high-performance provider that offers both standard chat and "reasoning" (thinking) capabilities. [o-mega](https://o-mega.ai/articles/openclaw-creating-the-ai-agent-workforce-ultimate-guide-2026)

***

## The Configuration Hierarchy
An OpenClaw configuration is split into two primary areas that work together:
1.  **The Environment (`env`)**: Where you store your "ID cards" (API Keys).
2.  **The Agents (`agents`)**: Where you tell the system which "ID card" to use for specific models.

### Step 1: Setting the Environment
Before an agent can speak, it needs permission. You provide this by adding your `DEEPSEEK_API_KEY` to the `env` section. OpenClaw looks for this specific key name to authorize requests. [docs.openclaw](https://docs.openclaw.ai/environment)

```json
"env": {
  "DEEPSEEK_API_KEY": "sk-your-key-here"
}
```

### Step 2: Registering Models
OpenClaw has a "security allowlist" called the **Models Registry**. If you try to use a model that isn't in this list, the agent will crash with an **"Unknown model" error**. [openrouter](https://openrouter.ai/docs/guides/guides/openclaw-integration)

You must define your models in the `agents.defaults.models` block:
- **`deepseek/deepseek-reasoner`**: This is DeepSeek R1, which "thinks" before it speaks. [serpapi](https://serpapi.com/blog/explore-deepseek-api/)
- **`deepseek/deepseek-chat`**: This is the standard fast version for quick tasks. [datacamp](https://www.datacamp.com/tutorial/deepseek-api)

### Step 3: Choosing the Primary Model
Finally, you set the `primary` model. This is the "default" brain the agent uses for every task. [docs.openclaw](https://docs.openclaw.ai/concepts/models)

***

## Full Example Configuration
Here is the complete code for a DeepSeek-only setup.

```json
{
  "env": {
    "DEEPSEEK_API_KEY": "sk-your-actual-api-key-here"
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "deepseek/deepseek-reasoner",
        "fallbacks": [
          "deepseek/deepseek-chat"
        ]
      },
      "models": {
        "deepseek/deepseek-reasoner": {
          "alias": "DeepSeek R1"
        },
        "deepseek/deepseek-chat": {
          "alias": "DeepSeek Chat"
        }
      }
    }
  }
}
```

## Key Concept Comparison

| Concept | Description | Why it matters |
| :--- | :--- | :--- |
| **Primary Model** | The main "brain" used for tasks  [docs.openclaw](https://docs.openclaw.ai/concepts/models). | Determines the quality of reasoning. |
| **Fallback** | The "backup brain" if the first fails  [docs.openclaw](https://docs.openclaw.ai/concepts/models). | Prevents the agent from stopping. |
| **Model ID** | The specific name (e.g., `deepseek-chat`)  [datastudios](https://www.datastudios.org/post/deepseek-available-models-supported-api-models-version-differences-capabilities-comparison-and-a). | Must match the provider's official ID. |
| **API Prefix** | The `deepseek/` part of the name  [openrouter](https://openrouter.ai/docs/guides/guides/openclaw-integration). | Tells OpenClaw which API key to use. |

***

## Common Beginner Pitfalls
- **Missing Commas**: JSON is very strict. Every line except the last one in a block must end with a comma. [docs.openclaw](https://docs.openclaw.ai/gateway/configuration)
- **Unknown Model Error**: This happens when you set a `primary` model but forget to add it to the `models` registry list. [openrouter](https://openrouter.ai/docs/guides/guides/openclaw-integration)
- **Exposed Keys**: Never share your `openclaw.json` publicly, as your API keys can be stolen and used by others. [composio](https://composio.dev/blog/secure-openclaw-moltbot-clawdbot-setup)

## Summary Checklist
1. Get an API key from [DeepSeek's Dashboard](https://platform.deepseek.com/).
2. Add the key to the `env` section of `openclaw.json`.
3. Register the model ID in the `models` registry.
4. Set the model ID as the `primary` choice.

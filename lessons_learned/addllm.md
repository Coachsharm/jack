# The Title of File ADD1

This guide provides a foundational lesson on how to add an LLM so that **OpenClaw** can understand and communicate with it. 

**Important Note:** This lesson is **not** focusing on integrating any LLM as a primary intelligence engine. The goal here is specifically how to add an LLM to the system's registry so that OpenClaw recognizes and can interact with the provider.

## Lesson Overview
In this lesson, you will learn how to make OpenClaw "aware" of external AI models using its configuration file, `openclaw.json`. We will use DeepSeek as an example to demonstrate how to register a model so the agent understands how to reach it. [o-mega](https://o-mega.ai/articles/openclaw-creating-the-ai-agent-workforce-ultimate-guide-2026)

***

## The Configuration Hierarchy
An OpenClaw configuration is split into two primary areas that work together to create "understanding":
1.  **The Environment (`env`)**: Where you store your "ID cards" (API Keys).
2.  **The Agents (`agents`)**: Where you register the models so the system recognizes the IDs you use.

### Step 1: Setting the Environment
For OpenClaw to understand a provider, it must have the necessary credentials. You provide this by adding the provider's API key to the `env` section. [docs.openclaw](https://docs.openclaw.ai/environment)

```json
"env": {
  "DEEPSEEK_API_KEY": "sk-your-key-here"
}
```

### Step 2: Registering Models (The Registry)
This is the most critical step for OpenClaw to "understand" an LLM. OpenClaw uses a **Models Registry** as a security allowlist. Even if you have an API key, the agent will throw an **"Unknown model" error** if the model isn't registered here. [openrouter](https://openrouter.ai/docs/guides/guides/openclaw-integration)

You must define the models in the `agents.defaults.models` block:
- **`deepseek/deepseek-reasoner`**: Adding this tells OpenClaw to recognize the R1 model.
- **`deepseek/deepseek-chat`**: Adding this tells OpenClaw to recognize the standard chat model.

### Step 3: Mapping the Model ID
By adding these IDs to the `models` block, you are creating a map. When you later reference `deepseek/deepseek-chat` in your code or UI, OpenClaw looks at the prefix (`deepseek/`), finds the matching `DEEPSEEK_API_KEY`, and sends the request. [docs.openclaw](https://docs.openclaw.ai/concepts/models)

***

## Full Example Configuration for Model Recognition
Here is the code required for OpenClaw to understand and register DeepSeek models.

```json
{
  "env": {
    "DEEPSEEK_API_KEY": "sk-your-actual-api-key-here"
  },
  "agents": {
    "defaults": {
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
| **Model Registration** | Adding a model to the `models` block. | Allows OpenClaw to "understand" and recognize the model ID. |
| **Model ID** | The specific name (e.g., `deepseek-chat`). | Must match the provider's official ID for the request to work. |
| **API Prefix** | The `deepseek/` part of the name. | Tells OpenClaw which environment variable to use for authentication. |

***

## Common Beginner Pitfalls
- **The "Unknown Model" Error**: The most common sign that OpenClaw does not "understand" your LLM. It usually means you forgot to add the model to the `models` registry. [openrouter](https://openrouter.ai/docs/guides/guides/openclaw-integration)
- **Prefix Mismatch**: If you use a prefix like `my-ai/` but your key is named `DEEPSEEK_API_KEY`, OpenClaw won't know which key to use.

## Summary Checklist
1. Add the provider's API key to the `env` section.
2. Register the specific Model ID in the `agents.defaults.models` registry.
3. Verify that the prefix in the Model ID correctly maps to your environment variable.

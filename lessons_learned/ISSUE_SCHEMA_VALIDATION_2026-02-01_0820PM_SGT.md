# Lesson: JSON Schema Validation & Configuration structure
**Date:** 2026-02-01
**Time:** 08:20 PM SGT

## The Issue
We repeatedly encountered `Unrecognized key` errors (specifically "endpoint") or the bot failing to start when trying to configure the Ollama provider.

## What We Tried
1.  Adding the Ollama configuration directly into `openclaw.json` under `agents.defaults.models`.
2.  Using keys like `endpoint`, `url`, and `apiUrl` inside the model definition in `openclaw.json`.

## The Failure
OpenClaw has a strict separation of concerns that is not immediately obvious:
-   **`openclaw.json`**: This is for **Selection** and **Aliasing**. It defines *which* models are available to the agent and what they are called in the UI. It does NOT define *how* to connect to them.
-   **`models.json`** (in `agents/main/`): This is for **Provider Registration**. This is the ONLY place where `baseUrl`, `endpoint`, and connection details belong.

## The Fix (Code)
**DO NOT** put connection details in `openclaw.json`.

**Correct `openclaw.json` pattern:**
```json
"models": {
  "ollama/llama3.2:latest": { "alias": "Llama 3.2" }
}
```

**Correct `models.json` pattern:**
```json
"providers": {
  "ollama": {
    "baseUrl": "http://172.19.0.1:11434/v1"
  }
}
```

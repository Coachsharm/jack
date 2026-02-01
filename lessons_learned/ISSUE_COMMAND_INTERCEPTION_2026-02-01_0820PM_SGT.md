# Lesson: Telegram Command Interception & Allowists
**Date:** 2026-02-01
**Time:** 08:20 PM SGT

## The Issue
We successfully configured the models, but typing `/model <name>` in Telegram resulted in the LLM (GPT-4o) replying with "I cannot do that" instead of the system switching the model.

## What We Tried
1.  Typing strict IDs: `/model openrouter/qwen...`
2.  Checking logs for errors.

## The Failure (Two-Part)
1.  **Native Commands Disabled**: By default, OpenClaw does NOT intercept Telegram slash commands to prevent conflicts. It treats them as text message.
    *   **Fix**: You MUST enable `"commands": { "native": true }` in `channels.telegram`.
2.  **Allowlist Mismatch**: Even when intercepted, we got "Model not allowed".
    *   **Reason**: We were using IDs with suffixes (`:free`) that functioned in the API but failed the strict string-match check against the `fallbacks` array in `openclaw.json`.
    *   **Fix**: The string in `agents.defaults.model.fallbacks` MUST MATCH EXACTLY what is typed or selected.

## The Usage Lesson
We learned that typing long slugs with spaces (`/model openrouter/meta-llama...`) confuses the Telegram parser.
**The Solution**: Always use the numeric picker (`/model` -> Select `2`) or short aliases established in the config.

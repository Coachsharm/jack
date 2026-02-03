---
description: Operating workflow for Jack (OpenClaw) on Hostinger VPS
---

# Jack Operational Workflow (Server-Only)

// turbo-all

## core-principles
1. **Server-Online Only**: All development, configuration, and execution happen on the remote Hostinger VPS. Local environment is for documentation and secrets storage ONLY.
2. **Docs First**: Before ANY decision or configuration change, consult [OpenClaw Documentation](https://docs.openclaw.ai/).
3. **Terminal Discipline**: Use the terminal (SSH) for all changes. 
4. **Secrets Only**: Never commit API keys or passwords. Use `secrets/config.json`.
5. **OpenRouter Priority**: Force the use of OpenRouter with the `openrouter/openai/gpt-4o` model.

## workflow-steps
1. **Reference Docs**: Search or read `docs.openclaw.ai` for the specific component being worked on.
2. **Access VPS**: Use SSH to connect to `72.62.252.124` as `root`.
3. **Docker Interaction**: Use `docker exec` commands to interact with the `openclaw-dntm-openclaw-1` container.
4. **Verify Config**: Trust the JSON config file (`/home/molt/clawdbot.json`) over any UI or CLI reports.
5. **Logs & Validation**: Always check `docker logs` to confirm LLM wiring and Telegram connectivity.

## immediate-goal
Get Jack working in Telegram using:
- OpenClaw Container
- OpenRouter API (GPT-4o)
- Telegram Bot (@thrive2bot)

## boot-runbook-reminder
- Section A-C: Sanity checks (RAM, Docker, Config Mounting).
- Section D: Ensure OpenRouter-only wiring.
- Section F: Check user-ID pairing security and safeBins.
- Section L: Re-onboarding workflow if stuck.

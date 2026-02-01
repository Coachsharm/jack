# Handoff to Researcher: Solving the Local Ollama Connection
**Date:** 2026-02-01
**Time:** 08:25 PM SGT

## Objective
Connect an **OpenClaw** agent running in **Docker** to a **Local Ollama** instance running on the **Host** machine (Hostinger VPS).

## Environment Details
*   **Infrastructure**: Hostinger VPS
*   **OS**: Ubuntu 24.04 LTS
*   **Container Runtime**: Docker (Compose)
*   **Application**: OpenClaw (Image: `ghcr.io/openclaw/openclaw:main`)
*   **LLM Service**: Ollama (Running natively on Host, Port 11434)

## The Current Barrier
We successfully established network connectivity (curl from container to host worked), but the OpenClaw application failed to reliably route chat completion requests to the local endpoint, often timing out or hallucinating responses. We reverted to OpenRouter for production stability.

## Configuration Context
We have verified the following prerequisites:
1.  **Ollama Binding**: Modified systemd to `OLLAMA_HOST=0.0.0.0` (Verified listening on `*:11434`).
2.  **Docker Bridge**: Container can ping Host at `172.19.0.1` (or `172.17.0.1`).

## Required Research Tasks
1.  **Service Discovery**: How can we make `host.docker.internal` work reliably on this Linux Build so we don't rely on hardcoded Bridge IPs which might change on restart?
2.  **Streaming**: Does OpenClaw's internal validater fail on Ollama's streaming response format? (We saw "Model not allowed" or timeouts).
3.  **Timeout**: Is there a specific `timeout` setting in `models.json` needed for local models (which are slower than cloud APIs) to prevent the gateway from closing the connection?

## Files to Investigation
*   `/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/openclaw.json` (Agent Config)
*   `/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/agents/main/models.json` (Provider Config)

Please find a way to make the connection robust enough for production use.

# Lesson: Docker Networking & Host Connectivity (Ollama)
**Date:** 2026-02-01
**Time:** 08:20 PM SGT

## The Issue
The OpenClaw Docker container could not connect to the Ollama service running on the Hostinger VPS host machine. Queries to `localhost:11434` failed.

## What We Tried
1.  Using `localhost` inside the container (Failed: refers to the container itself).
2.  Using `host.docker.internal` (Failed: Not supported natively on Linux Docker without extra flags).
3.  Using the Docker bridge IP `172.17.0.1` (Partially successful but unstable).

## The Failure
By default, Ollama binds only to `127.0.0.1` (localhost). Even if the Docker container hits the correct IP (`172.17.0.1`), the connection is refused because Ollama isn't listening on that interface.

## The Requirements for Future Success
1.  **Ollama Binding**: The host service MUST be configured to listen on all interfaces.
    *   **Command**: `Environment="OLLAMA_HOST=0.0.0.0"` in the systemd service file.
    *   **Verify**: `ss -tuln | grep 11434` must show `*:11434` or `0.0.0.0:11434`.
2.  **Docker Network**: The container must use the gateway IP (`172.17.0.1` or `172.19.0.1`) to talk to the host.
    *   **Determine IP**: Run `docker inspect <container> | grep Gateway`.

## Why We Reverted
Despite establishing connectivity (curl worked), the integration remained flaky, likely due to latency or command parsers conflicting with the local stream. We switched to OpenRouter for guaranteed stability.

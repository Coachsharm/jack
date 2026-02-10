# Docker Localhost Network Isolation

## The Problem
When running OAuth flows inside Docker containers, **the container's localhost is NOT the same as the host's localhost**. This is a fundamental Docker networking behavior that caused 2+ hours of failed troubleshooting.

## What Happened
We tried to complete gogcli OAuth authorization by:
1. Running `gog auth login` inside the Docker container
2. Setting up SSH tunnel from local PC to server's localhost:PORT
3. Opening browser to localhost:PORT

**This CANNOT work** because:
```
Browser → localhost:PORT (Windows PC)
    ↓ SSH tunnel
Server Host → localhost:PORT (Server's localhost)
    ↓ ??? NO CONNECTION ???
Docker Container → localhost:PORT (Container's isolated localhost)
```

The gogcli process binds to the **container's** localhost, which is unreachable from the host's localhost even with perfect SSH tunneling.

## The Fix
Use `--manual` flag for headless/Docker environments:
```bash
docker exec -it container-name gog auth add user@email.com --manual
```
This outputs a URL you can open anywhere - no tunnel needed.

## Key Takeaway
> **localhost inside a Docker container ≠ localhost on the host machine**

When any process inside a Docker container listens on localhost, you CANNOT reach it via:
- SSH tunnel to host's localhost
- Direct browser access
- Port forwarding

You CAN reach it via:
- Docker's `--network host` mode
- Exposing ports with `-p` flag at container start
- Manual auth flows that don't require localhost callback

## Prevention
Before attempting OAuth inside Docker:
1. Check if the tool has a `--manual` or `--headless` flag
2. Research the tool's documentation for "headless" or "server" usage
3. Don't waste hours on SSH tunnels - understand the network topology first

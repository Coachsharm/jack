# Hostinger Docker Catalog vs OpenClaw Native Approach

**Date Learned:** 2026-02-04  
**Context:** Jack4 development  
**Category:** Architecture / Platform Understanding

## The Problem

Attempting to use **Hostinger Docker Catalog methods** and **generic Docker commands** with OpenClaw doesn't work. OpenClaw has its own native approach that conflicts with standard Docker patterns.

## The Lesson

> **ALWAYS follow OpenClaw documentation, not generic Docker patterns.**

**Do NOT assume:**
- Standard docker-compose patterns will work
- Generic Docker volume mounting conventions apply
- Environment variable patterns from other Docker apps transfer
- Standard Docker CLI commands are the right tool

## Why This Happens

**Hostinger Docker Catalog Approach:**
- Generic Docker commands (`docker exec`, `docker-compose`, etc.)
- Standard docker-compose.yml patterns
- Common environment variable patterns (`.env` files)
- Typical volume mounting (`-v` flags)
- Direct container manipulation

**OpenClaw Native Approach:**
- ✅ OpenClaw-specific CLI (`claw`, `openclaw`, not direct docker commands)
- ✅ Structured configuration file (`openclaw.json`)
- ✅ Built-in diagnostic tools (`claw doctor`, `claw status`)
- ✅ Native skills system (`.agent/skills/`)
- ✅ Specific volume structure and naming conventions
- ✅ OpenClaw workspace paradigm (`/home/node/.openclaw/workspace/`)

**Mixing them = Problems** ❌

## Examples of Conflicts

### ❌ Wrong Approach (Generic Docker)
```bash
# This might work for standard Docker apps but NOT OpenClaw
docker exec container-name bash -c "command"
docker-compose restart
vim .env  # Editing environment variables
```

### ✅ Right Approach (OpenClaw Native)
```bash
# Use OpenClaw CLI and tools
claw status
claw doctor
openclaw restart
# Edit openclaw.json (following OpenClaw docs!)
```

## The Fix

**Step-by-Step:**
1. 📖 **Check OpenClaw docs FIRST** - `OpenClaw_Docs/` or https://docs.openclaw.com
2. 🩺 **Use `claw doctor`** for diagnostics (not generic Docker debugging)
3. 🔧 **Follow OpenClaw CLI patterns** (use `claw` commands, not `docker` commands)
4. 🚫 **Don't assume generic Docker knowledge applies** - verify in docs first
5. 📝 **Document OpenClaw-specific patterns** in lessons as you discover them

## Related Lessons

- `door_lesson_read_signs_first.md` - Don't pick locks on doors with handles
- `openclaw_config_deployment.md` - How to properly edit OpenClaw configs
- `server_side_editing_workflow.md` - OpenClaw workspace file editing

## Key Takeaway

**OpenClaw is a platform, not just a Docker container.** 

Treat it like you would treat AWS, Kubernetes, or any other platform with its own ecosystem - learn its patterns, use its tools, follow its documentation. Generic Docker knowledge is helpful background, but OpenClaw has its own way of doing things.

**When in doubt: Docs first, experiments second.**

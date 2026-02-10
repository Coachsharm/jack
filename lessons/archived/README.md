# Archived Lessons

This folder contains lessons that are **outdated** or **superseded** by more recent documentation but are kept for historical reference.

---

## Files in This Archive

### `openclaw_config_deployment.md`

**Date:** 2026-02-03  
**Archived:** 2026-02-10  
**Status:** ⚠️ Partially Outdated  

**Why archived:**
- Written for **Jack1** (Docker-based deployment)
- Jack4 is now a **native installation**
- Docker paths and `docker restart` commands no longer apply to current setup
- The specific file paths (`/var/lib/docker/volumes/openclaw-dntm_...`) are wrong for Jack4

**What's still valid:**
- ✅ General principles (validate JSON, backup before changes)
- ✅ Using `pscp` for file uploads
- ✅ Research before implementing
- ✅ Don't pipe JSON through multiple shells

**Current alternative:**
- For Jack4 backup/restore: See `lessons/jack4_backup_and_recovery_system.md`
- For config management: All bots now use `openclaw gateway config.patch` for safe updates
- For Docker deployments: See `lessons/docker_migration_native_to_container.md`

---

## How to Use Archived Lessons

1. **Read the archive notice** at the top of each file (if present)
2. **Extract principles** — focus on the "why," not the "how"
3. **Don't copy commands** — they reference old setups
4. **Check for current alternatives** — usually linked in the archive notice

---

**Last Updated:** 2026-02-10 21:00 SGT

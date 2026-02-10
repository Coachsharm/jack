# Update Jack's Workspace After Ross Docker Migration

**Date:** 2026-02-10  
**Priority:** Medium  
**Status:** TODO  

## Changes Needed in Jack's Workspace

Ross has been migrated from native to Docker. Jack's workspace files need to reflect this change, but **don't delete anything** — many files are still correct.

### Files to Update

1. **AGENTS.md**
   - Update Ross's entry to reflect Docker deployment
   - Clarify Ross's primary role: **revive Jack if needed**, with full root access

2. **SOUL.md** (if Ross is referenced)
   - Note Ross is now in Docker container `openclaw-ross`
   - Ross still has privileged access for Jack recovery

3. **Any monitoring/heartbeat docs**
   - Update references to Ross's paths if they exist

### Key Points to Include

- **Ross's new location:** Docker container `openclaw-ross` at `/root/openclaw-clients/ross/`
- **Ross's primary job:** Watchdog/backup — revive Jack if gateway fails, needs full read/write access to `/root/` for recovery operations
- **John's status:** Still a template, work in progress
- **Ross's capabilities:** Despite being in Docker, Ross has privileged access for system operations via Docker socket or exec privileges

### What NOT to Change

- Jack's own configuration (he's still native at `/root/.openclaw/`)
- Working scripts and automations
- Established workflows unless they reference Ross's old paths

---

## Implementation Steps

1. Check Jack's AGENTS.md for Ross references
2. Update Ross's description: "Docker container (openclaw-ross), watchdog role, full access for Jack recovery"
3. Verify any cross-bot communication scripts still work
4. Test Ross's ability to restart Jack's gateway if needed

# 📋 Stuck Problems Log

> Cross-session memory for recurring issues. Check at start of each session.

---

## Active Problems (Unresolved)

### OAuth Port Callback Issue
- **Category:** AUTH / NETWORK
- **First seen:** 2026-02-03
- **Sessions:** 3+
- **Total attempts:** 10+ (across sessions)
- **Last approach:** Port forwarding via plink tunnel
- **Error pattern:** localhost callback failures, port mismatches
- **Status:** 🔴 UNRESOLVED
- **Notes:** 
  - gogcli uses random ports for OAuth callback
  - SSH tunnel to 37317 established but callbacks fail
  - Multiple Google searches, 40+ browser tabs of failed attempts
  - May need to check if gogcli is even the right approach (OpenClaw may have native method)

---

## Resolved Problems ✅

### Config Location Issue
- **Category:** CONFIG
- **Solved:** 2026-02-02
- **Solution:** `lessons/config_location.md`
- **Summary:** OpenClaw config goes in openclaw.json, not docker-compose

### Session Cache Issue
- **Category:** DOCKER
- **Solved:** 2026-02-03  
- **Solution:** `lessons/session_cache_workspace_files.md`
- **Summary:** Clear sessions/* directory to reset Jack's context

---

## How to Use This Log

### At Session Start:
1. Scan "Active Problems" for context
2. Avoid re-attempting already-failed approaches
3. Jump to research phase if problem is here

### After Solving:
1. Move from "Active" to "Resolved"
2. Create lesson file
3. Document key insight

### Log Entry Template:
```markdown
### [Problem Name]
- **Category:** [CONFIG/AUTH/NETWORK/DOCKER/FILESYSTEM/CODE]
- **First seen:** [Date]
- **Sessions:** [Count]
- **Total attempts:** [Estimate]
- **Last approach:** [What was tried]
- **Error pattern:** [Common errors seen]
- **Status:** 🔴 UNRESOLVED / ✅ RESOLVED
- **Notes:** [Key observations]
```

---

**Last Updated:** 2026-02-04 08:45

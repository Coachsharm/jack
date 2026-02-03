# OpenClaw Session Cache & Workspace Files

**Date:** 2026-02-03  
**Severity:** CRITICAL  
**Category:** Configuration, Troubleshooting

---

## The Problem

After updating workspace files (`SOUL.md`, `AGENTS.md`, etc.) and restarting the OpenClaw container, Jack continued to report **OLD content** from these files, even though the files on disk were correct.

### Symptoms:
- ✅ File on disk is correct (verified with `cat`, `wc -l`, `grep`)
- ❌ Agent reports old content when asked to show file
- ❌ Agent behavior doesn't reflect new instructions
- ❌ Container restart doesn't fix the issue

### Example:
```bash
# File on disk: 69 lines, has Capabilities section
docker exec openclaw-dntm-openclaw-1 wc -l /home/node/.openclaw/workspace/SOUL.md
# Output: 69

# Jack reports: OLD version without Capabilities, wrong path
# He says it's at /home/node/.openclaw/SOUL.md (wrong!)
```

---

## Root Cause: Session Context Caching

**OpenClaw caches workspace files in session memory/context** and does NOT re-read them from disk on container restart.

### How OpenClaw Loads Workspace Files:

1. **At Session Start:** OpenClaw reads `SOUL.md`, `IDENTITY.md`, `USER.md`, `AGENTS.md` from workspace
2. **Stores in Session Context:** Content is cached in session transcript files (`.jsonl`)
3. **Persists Across Restarts:** Session files survive container restarts
4. **Agent Reads from Cache:** Subsequent requests pull from cached session context, NOT from disk

### Session Storage Location:
```
/home/node/.openclaw/agents/main/sessions/
├── <session-id>.jsonl          # Contains cached workspace content
├── <another-session-id>.jsonl
└── sessions.json
```

---

## The Solution: Clear Session Cache

### Step 1: Backup Session Files (Optional but Recommended)
```bash
docker exec openclaw-dntm-openclaw-1 mkdir -p /home/node/.openclaw/backup/sessions_YYYYMMDD

docker exec openclaw-dntm-openclaw-1 cp -r /home/node/.openclaw/agents/main/sessions /home/node/.openclaw/backup/sessions_YYYYMMDD/
```

### Step 2: Clear Session Cache
```bash
# Delete all session files
docker exec openclaw-dntm-openclaw-1 rm -rf /home/node/.openclaw/agents/main/sessions

# Recreate empty sessions folder
docker exec openclaw-dntm-openclaw-1 mkdir -p /home/node/.openclaw/agents/main/sessions
```

### Step 3: Restart Container
```bash
docker restart openclaw-dntm-openclaw-1
```

### Step 4: Verify
Wait 10-15 seconds for container to fully start, then test:
```bash
# Check container status
docker ps --filter name=openclaw-dntm

# Ask agent to show SOUL.md on Telegram
# Should now report correct content and path
```

---

## Key Research Findings

From online OpenClaw communities and documentation:

> **"OpenClaw agents build and maintain context across sessions... This persistence can cause the agent to retain an older version of SOUL.md in its active context or cache, even after a standard restart."**

> **"Some critical configurations in SOUL.md need to be present BEFORE the agent's gateway starts... If you're updating SOUL.md AFTER the agent has initialized, a simple restart might not be sufficient."**

> **"Users have reported needing to manually reset or even reinstall the agent to clear its context."**

### Session Transcript Files:
- Stored at: `~/.openclaw/agents/<agentId>/sessions/*.jsonl`
- Purpose: "Essential for maintaining session continuity and for optional memory indexing"
- Problem: Contains cached workspace file content that doesn't auto-refresh

---

## When to Clear Session Cache

Clear the session cache when:

1. ✅ **After updating workspace files** (SOUL.md, IDENTITY.md, USER.md, AGENTS.md)
2. ✅ **Agent reports old/incorrect content** despite file being correct on disk
3. ✅ **Major configuration changes** that need immediate effect
4. ✅ **Troubleshooting unexpected behavior** related to agent identity/rules

### When NOT to Clear:
- ❌ Routine restarts (preserves conversation history)
- ❌ When you want to keep agent's memory of recent conversations
- ❌ Minor file changes that can wait for natural session refresh

---

## Alternative: Full Agent Reset

For severe issues, delete the entire agent folder:

```bash
# Nuclear option - clears ALL agent data including auth
docker exec openclaw-dntm-openclaw-1 rm -rf /home/node/.openclaw/agents/main

# Restart
docker restart openclaw-dntm-openclaw-1
```

⚠️ **Warning:** This will also clear:
- Authentication profiles
- All conversation history
- Agent-specific settings

---

## Prevention: Future Updates

### Best Practice Workflow:

1. **Stop the container FIRST:**
   ```bash
   docker stop openclaw-dntm-openclaw-1
   ```

2. **Update workspace files:**
   ```bash
   docker cp updated_file.md openclaw-dntm-openclaw-1:/home/node/.openclaw/workspace/
   ```

3. **Clear session cache:**
   ```bash
   docker exec openclaw-dntm-openclaw-1 rm -rf /home/node/.openclaw/agents/main/sessions
   ```

4. **Start container:**
   ```bash
   docker start openclaw-dntm-openclaw-1
   ```

This ensures clean loading of new workspace files.

---

## Related Files

- See also: `server_side_editing_workflow.md` - File deployment best practices
- See also: `openclaw_config_deployment.md` - Config file updates

---

## Verification Checklist

After clearing session cache:

- [ ] Container restarted successfully
- [ ] Agent responds on Telegram
- [ ] Agent reports correct SOUL.md path: `/home/node/.openclaw/workspace/SOUL.md`
- [ ] Agent shows updated content (e.g., Capabilities section)
- [ ] Agent behavior reflects new instructions
- [ ] Session backup created (if wanted to preserve history)

---

**Bottom Line:** OpenClaw session caching is a feature (preserves context) but becomes a bug when you need immediate workspace file updates. Clear the session cache to force a fresh read from disk.

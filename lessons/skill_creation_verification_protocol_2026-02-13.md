# Skill Creation & Verification Protocol

**Date:** 2026-02-13  
**Status:** ✅ Implemented Across All Systems  
**Priority:** 🔴 MANDATORY

---

## What Was Implemented

A new **mandatory protocol** requiring all bots (Antigravity, Jack, Ross, John, Sarah) to:

1. **Proactively suggest creating skills** after completing any work/process
2. **Verify existing skills are current** before using them
3. **Update outdated skills** to match current infrastructure

---

## Why This Was Needed

### The Problem
- Skills were becoming outdated as infrastructure evolved (Docker → Native)
- Repetitive processes weren't being captured as reusable skills
- Bots were using skills with wrong paths, deprecated commands, or obsolete architecture references
- No systematic verification that skills matched current system state

### The Solution
A three-rule protocol that ensures:
- Every completed process triggers the question: "Should we create a skill for this?"
- Every skill usage requires verification against current infrastructure
- Outdated skills are immediately updated, not just flagged

---

## Implementation Locations

### ✅ Files Updated

1. **`Gemini.md`** - Full protocol added after Documentation Currency Rule
2. **`claude.md`** - Full protocol added (synchronized with Gemini.md)
3. **`custominstructions.md`** - Full protocol added to unified reference
4. **`agents.md`** (local) - Condensed protocol with reference to full version
5. **`server_workspace_sync/AGENTS.md`** - Condensed protocol (synced to server)
6. **Server: `/root/.openclaw/workspace/AGENTS.md`** - ✅ Uploaded via pscp

### 📍 Where Bots Will See This

- **Antigravity (PC):** Reads `Gemini.md` or `claude.md` + `custominstructions.md`
- **Jack (Server):** Reads `/root/.openclaw/workspace/AGENTS.md`
- **Ross, John, Sarah (Server):** Read their respective workspace `AGENTS.md` files (to be synced)

---

## The Protocol (Summary)

### Rule 1: Proactive Skill Suggestion
**After completing ANY work or process:**
- Ask: "Should we create a skill for this?"
- Cannot mark work complete without asking

**Triggers:**
- Repetitive multi-step processes
- Complex troubleshooting workflows
- Server maintenance procedures
- Configuration changes with specific steps
- Any process we might need to repeat

### Rule 2: Mandatory Skill Verification
**Before using ANY existing skill:**
1. Read the skill file (`.agent/skills/[name]/SKILL.md`)
2. Verify it matches current infrastructure:
   - Check file paths are correct
   - Verify commands work with current system
   - Confirm server architecture hasn't changed
   - Validate authentication methods are current
3. Update if outdated:
   - Docker references → Native OpenClaw
   - Wrong paths → Fix immediately
   - Deprecated commands → Modernize
4. Document the verification:
   - "Verified [skill name] is current" OR
   - "Updated [skill name] to reflect [changes]"

### Rule 3: Infrastructure Awareness
**When updating skills, verify against:**
- Current server architecture (native, not Docker)
- Current file paths (`/root/.openclaw/` not `/root/openclaw/`)
- Current CLI commands (OpenClaw CLI, not manual edits)
- Current authentication setup
- Current bot roster and their roles

### Skill Quality Standards
**Every skill must:**
- Have clear, actionable steps
- Reference current file paths
- Use correct CLI commands
- Include error handling
- Be tested against current infrastructure

---

## Examples of Application

### Example 1: After Completing a Server Maintenance Task
```
✅ CORRECT:
"Server backup completed successfully. 
Should we create a skill for this backup procedure?"

❌ INCORRECT:
"Server backup completed successfully."
[Moves on without asking]
```

### Example 2: Before Using the Backup Skill
```
✅ CORRECT:
1. Read `.agent/skills/backup/SKILL.md`
2. Check: Does it reference Docker? (Update if yes)
3. Check: Are paths `/root/.openclaw/`? (Fix if wrong)
4. Check: Does it use OpenClaw CLI? (Modernize if manual edits)
5. Report: "Verified backup skill is current" or "Updated backup skill to use native paths"

❌ INCORRECT:
Just run the backup skill without verification
```

---

## Next Steps

### Immediate
- ✅ All PC-side instruction files updated
- ✅ Server AGENTS.md updated for Jack
- ⏳ **TODO:** Sync to Ross, John, Sarah workspace AGENTS.md files

### Ongoing
- Monitor that bots are following the protocol
- Create skills for repetitive processes as they're identified
- Update existing skills as infrastructure evolves

---

## Success Metrics

**This protocol is working when:**
1. Bots consistently ask "Should we create a skill?" after completing work
2. Bots verify skills before using them
3. Skills remain current with infrastructure changes
4. Repetitive processes are captured as reusable skills
5. No bot uses outdated Docker references or wrong paths

---

## Related Files

- **Full Protocol:** `Gemini.md`, `claude.md`, `custominstructions.md`
- **Condensed Version:** `agents.md`, `server_workspace_sync/AGENTS.md`
- **Skills Directory:** `.agent/skills/`
- **Existing Skills:** backup, dashboard, sync_docs, team

---

**Protocol Version:** 1.0  
**Applies To:** ALL bots (Antigravity, Jack, Ross, John, Sarah)  
**Status:** Active and Mandatory

# Jack's Docker Identity Confusion — Root Cause & Fix

**Date:** 2026-02-10  
**Issue:** Jack started claiming he's running in Docker when he's actually a native install  
**Status:** ✅ Fixed  

---

## What Happened

Jack began telling Coach things like "I'm in a Docker container" or referencing his own containers. This is factually wrong — Jack is a **native OpenClaw install** at `/root/.openclaw/` on the VPS, NOT in Docker.

## Root Cause: 3 Sources of Confusion in Bootstrap Files

Bootstrap files (SOUL.md, USER.md, AGENTS.md) load **every single session**. Jack reads them every time he wakes up. If Docker is mentioned repeatedly in these files, he absorbs it as part of his identity.

### Source 1: USER.md (line 10) — FIXED ✅
**Before:**
```
Has other bots (Jack2, Jack3 in Docker). I'm Jack1 (native install). Old Jack1 (Docker) is deleted.
```
**Problem:** Docker is mentioned 3 times in ONE sentence. Yes, it says "native install" but the sentence is dominated by Docker references. Also mentions "Old Jack1 (Docker)" — his previous self WAS Docker, which creates identity bleed.

**After:**
```
I (Jack) am a NATIVE install at /root/.openclaw/ on the VPS — NOT in Docker. John runs in a separate Docker container. Old versions (Jack2, Jack3) no longer exist.
```

### Source 2: SOUL.md (line 42) — FIXED ✅
**Before:**
```
"It's running fine. 3 containers up, no errors since yesterday."
```
**Problem:** This is in the "How You Sound" section — an **example** of Jack's ideal reply style. Jack is literally being trained to report "containers up" as his natural way of describing system health. He internalizes this phrasing.

**After:**
```
"All good. Gateway healthy, channels connected, no errors since yesterday."
```

### Source 3: Bot Chat Lesson (memory file) — Not changed
The file `memory/lessons/2026-02-08-bot-chat-working-solution.md` contains many `docker exec openclaw-john` commands. These are commands Jack runs TO John, not about himself. This is acceptable context — Jack needs to know Docker commands to interact with John. The fix above in USER.md making his identity crystal clear should prevent confusion.

## Verification

On the server:
- ❌ `/.dockerenv` does NOT exist → confirmed bare metal
- ❌ `/proc/1/cgroup` shows `init.scope` → NOT a container
- ✅ `"noSandbox": true` in openclaw.json → no Docker sandbox mode
- ✅ Jack lives at `/root/.openclaw/` directly on the VPS

## Lesson: Bootstrap File Words Matter

Every word in SOUL.md, USER.md, AGENTS.md, and TOOLS.md gets loaded at the start of **every** conversation. These files literally shape what Jack believes about himself.

**Rules for bootstrap files:**
1. **Never mention other environments** (Docker, containers) unless explicitly stating "this is NOT me"
2. **Example replies** are training data — Jack mimics them. Don't use words that describe a different setup.
3. **History references** (old versions, deleted bots) create identity confusion. Keep it present-tense only.
4. **State facts about self first**, then about others. "I am X. John is Y." — not "There used to be X, Y is Docker, I'm Z."

## Files Changed

| File | Change |
|------|--------|
| `/root/.openclaw/workspace/USER.md` line 10 | Rewrote to clearly state native install, removed Docker history |
| `/root/.openclaw/workspace/SOUL.md` line 42 | Changed example reply from "containers up" to "gateway healthy, channels connected" |

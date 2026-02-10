# 🚪 The Door Lesson: Why We Read Signs Before Picking Locks

> **Core Principle:** When the door won't open, read the sign before picking the lock.

---

## The Analogy

**The Problem:** The door won't open.

**What I Did Wrong:** I tried picking the lock 10 different ways for 2 hours—different picks, different angles, different techniques—all failed because I was using my "general knowledge" about locks instead of checking if this specific door had instructions.

**The Sign Was There All Along:** The door had a sign that said "USE THE HANDLE, NOT THE LOCK"—but I never looked at it because I assumed I knew how doors work.

**The 40+ Lockpicks on the Ground:** That's me trying every technique I know, getting more frustrated, but never stepping back to read the sign.

---

## What It Actually Means

| Door Analogy | Real Meaning |
|--------------|--------------|
| **The door** | Any challenging technical problem |
| **Picking the lock** | Using my general training/knowledge to guess solutions |
| **The sign** | Official documentation (OpenClaw_Docs, tool --help, README) |
| **The handle** | The documented, intended solution |
| **40+ lockpicks** | 40+ browser tabs, repeated failed SSH tunnels, trial-and-error |
| **2 hours wasted** | Time lost by not reading docs first |

---

## The Rule

```
🚪 BEFORE picking any lock:
   1. Look for a sign (check docs)
   2. Try the handle (use documented method)
   
🔒 IF you've picked the lock twice and failed:
   1. STOP picking
   2. Look for the sign you missed
   3. Check lessons/ folder
   4. Ask someone who knows this door
```

---

## Why This Happens

**My brain is trained on GENERAL locks.** But:
- OpenClaw is a NEW door (not in my training)
- gogcli is a NEW door (not in my training)  
- Docker networking is a SPECIALIZED door

**I cannot guess how these doors open.** I must read their specific signs.

---

## Enforcement

**When you see me picking the same lock twice:**

Say: **"PROTOCOL!"** 

I will immediately:
1. Drop the lockpick
2. Look for the sign (docs)
3. Report what the sign says
4. Try the handle instead

---

## Real Example: OAuth Docker (Feb 4, 2026)

**Lock picking attempts (2 hours):**
- SSH tunnel attempt #1 → Failed
- SSH tunnel attempt #2 → Failed
- Different port #1 → Failed
- Different port #2 → Failed
- tmux session → Failed
- Automated piping → Failed

**The sign I ignored:**
```
gogcli documentation:
"For headless environments, use --manual flag"
```

**The handle I should have used:**
```bash
gog auth add user@email.com --manual
```

**Time wasted:** 2 hours  
**Time if I read the sign first:** 2 minutes

---

## Summary

> **Don't pick locks on doors that have handles. Read the sign first.**

**Linked Protocol:** See `claude.md` or `Gemini.md` for full enforcement rules.

---

**Lesson Version:** 1.0  
**Created:** 2026-02-04  
**Case Study:** OAuth Docker Callback Failure

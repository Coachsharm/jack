# Lesson: Search Workspace First - Don't Assume Clean Slate

**Date:** 2026-02-04  
**Category:** Debugging, Troubleshooting, System Awareness  
**Applies to:** Agents, Developers, System Administrators

---

## The Incident

### What Happened

**Context:** Coach asked Jack to monitor Gmail for unread messages.

**Jack's Response Chain:**
1. Checked for `gog` CLI tool (his known skill)
2. Found `gog` wasn't working
3. **Immediately concluded:** "gog CLI not properly installed"
4. Started creating installation plans from scratch
5. Coach corrected: "We already have Gmail/Calendar set up"
6. **Only then** did Jack search workspace and find existing Python scripts

**Time wasted:** ~10-15 minutes creating unnecessary installation plans

---

## What Jack Did Wrong

### The Flawed Approach

```
❌ Step 1: Check for known tool (gog)
❌ Step 2: Tool not found → assume nothing exists
❌ Step 3: Suggest starting from scratch
❌ Step 4: Create "installation plan"
❌ Step 5: Only search workspace after being corrected
```

### What He SHOULD Have Done

```
✅ Step 1: Search workspace for existing solutions FIRST
✅ Step 2: Find gmail_check.py, gmail_token.pickle, etc.
✅ Step 3: Test if existing setup works
✅ Step 4: Build on what's already there
✅ Step 5: Only suggest new installation if nothing exists
```

---

## The Root Cause

### Why This Happened

**1. Memory Compression**
- Jack's session context gets compacted over time
- Earlier Gmail setup wasn't in active memory
- Relied on checking "known skill" instead of current state

**2. Assumption Over Investigation**
- Assumed clean slate when tool check failed
- Didn't verify assumption before acting
- Jumped to solution before understanding problem

**3. No Systematic Search Protocol**
- No habit of checking workspace first
- Didn't search before concluding "not installed"
- Relied on memory instead of file system

---

## The Universal Principle

### "Search Workspace First"

**Rule:** Before suggesting ANY new installation, configuration, or setup:

1. **Search for existing implementations**
2. **Verify current state**
3. **Test what's already there**
4. **Build on existing solutions**
5. **Only start fresh if nothing exists**

This applies to:
- ✅ Tools and CLIs
- ✅ Configuration files
- ✅ Scripts and automation
- ✅ API integrations
- ✅ Database setups
- ✅ Any system component

---

## How to Apply This

### The Correct Workflow

#### Step 1: Search Before Assuming

```bash
# When asked about ANY feature/tool:
# FIRST: Search workspace
find /root/.openclaw/workspace -name "*keyword*"
find /root/.openclaw/workspace -type f -name "*.py" | grep -i "keyword"
grep -r "related-term" /root/.openclaw/workspace/

# Examples:
find /root/.openclaw/workspace -name "*gmail*"
find /root/.openclaw/workspace -name "*calendar*"
grep -r "google" /root/.openclaw/workspace/
```

#### Step 2: Check Existing Files

```bash
# If files found, check what they do
cat /root/.openclaw/workspace/gmail_check.py
ls -la /root/.openclaw/workspace/*.pickle
cat /root/.openclaw/workspace/google_credentials.json
```

#### Step 3: Test Existing Setup

```bash
# Try running what's already there
python3 /root/.openclaw/workspace/gmail_check.py
# Does it work? → Build on it
# Does it fail? → Debug existing setup first
```

#### Step 4: Only Then Suggest New Installation

```bash
# If NOTHING exists and NOTHING works:
# THEN suggest new installation
echo "No existing Gmail setup found. Let me create one..."
```

---

## Real-World Examples

### Example 1: Jack's Gmail Incident

**Wrong:**
```
User: "Can you check Gmail?"
Agent: "gog CLI not found. Need to install gogcli..."
```

**Right:**
```
User: "Can you check Gmail?"
Agent: "Let me check workspace first..."
Agent: [Searches and finds gmail_check.py, gmail_token.pickle]
Agent: "Found existing Gmail setup via Python API. Testing..."
Agent: [Runs gmail_check.py successfully]
Agent: "Gmail is already set up and working. Found 3 unread emails."
```

---

### Example 2: Database Request

**Wrong:**
```
User: "Can you query the database?"
Agent: "No database configured. Need to set up PostgreSQL..."
```

**Right:**
```
User: "Can you query the database?"
Agent: [Searches workspace]
Agent: [Finds db_config.json, database.sqlite]
Agent: "Found SQLite database at workspace/database.sqlite. Let me check it..."
Agent: [Tests connection]
Agent: "Database already configured with 5 tables. What query do you need?"
```

---

### Example 3: API Integration

**Wrong:**
```
User: "Can you check Telegram messages?"
Agent: "Telegram bot not set up. Here's how to create one..."
```

**Right:**
```
User: "Can you check Telegram messages?"
Agent: [Searches for telegram*, bot*, api*]
Agent: [Finds telegram_bot.py, .env with BOT_TOKEN]
Agent: "Found existing Telegram bot configuration. Testing..."
Agent: [Runs telegram_bot.py]
Agent: "Bot is active. Last message: 'Hello' from Coach at 14:30."
```

---

## Why This Matters

### 1. **Efficiency**
- No wasted time on redundant setups
- No duplicate configurations
- Use existing, tested solutions

### 2. **Reliability**
- Existing setup is already working
- Already authorized/configured
- Don't break what works

### 3. **Continuity**
- Respect previous work
- Build on established systems
- Maintain consistency

### 4. **User Trust**
- Shows system awareness
- Demonstrates careful investigation
- Avoids frustrating "we already have this" corrections

---

## Session Context & Memory

### The Challenge

**Problem:** Agent memory gets compressed over time

**What this means:**
- Earlier configurations may not be in active recall
- Recent sessions get priority in memory
- Older setups fade from immediate awareness

**Solution:** **Don't rely on memory - rely on the file system**

```bash
# Memory says: "I don't remember Gmail setup"
# File system says: "gmail_check.py exists, created Jan 15"

# Trust the file system, not memory!
```

---

## The Search-First Protocol

### Memorize This Workflow

```
┌─────────────────────────────────────┐
│ User Request: "Can you [X]?"        │
└─────────────┬───────────────────────┘
              │
              ▼
     ┌────────────────────┐
     │ Search workspace   │
     │ for existing [X]   │
     └────────┬───────────┘
              │
         ┌────┴────┐
         │         │
    Found?      Not Found?
         │         │
         ▼         ▼
  ┌──────────┐  ┌──────────────┐
  │ Test it  │  │ Verify with  │
  │          │  │ more searches│
  └────┬─────┘  └──────┬───────┘
       │                │
   Works?           Still Nothing?
       │                │
       ▼                ▼
  ┌──────────┐    ┌──────────────┐
  │ Build on │    │ Suggest new  │
  │ existing │    │ installation │
  └──────────┘    └──────────────┘
```

---

## Commands to Run First

### Universal Search Commands

Before saying "not installed" or "need to set up", **ALWAYS run these first:**

```bash
# 1. Find files by keyword
find /root/.openclaw/workspace -iname "*keyword*" -type f

# 2. Search file contents
grep -r -i "keyword" /root/.openclaw/workspace/ --include="*.py" --include="*.js" --include="*.json"

# 3. List Python scripts
find /root/.openclaw/workspace -name "*.py" -exec basename {} \;

# 4. Check for config files
find /root/.openclaw/workspace -name "*.json" -o -name "*.yaml" -o -name "*.env"

# 5. Look for credentials/tokens
find /root/.openclaw/workspace -name "*token*" -o -name "*credentials*" -o -name "*key*"
```

---

## Jack's Commitment

From Jack's self-reflection:

> **"From now on, for ANY request:**
> 
> **Step 1:** Search workspace for related files FIRST
> 
> ```bash
> find /root/.openclaw/workspace -name "*keyword*"
> grep -r "related-term" /root/.openclaw/workspace/
> ```
> 
> **Step 2:** Check if existing solution already works
> 
> **Step 3:** ONLY suggest new setup if nothing exists
> 
> **Step 4:** Build on what's already there"

This is now Jack's standard operating procedure.

---

## Applying This Lesson

### For Jack (Server Agent)

**Before any installation suggestion:**
1. Search `/root/.openclaw/workspace`
2. Search `/home/node/.openclaw/workspace`
3. Check `/root/.openclaw/skills`
4. Look in cron jobs, services, running processes
5. **THEN** conclude if something needs installation

### For Antigravity (PC Agent)

**Before any setup suggestion:**
1. Check `c:\Users\hisha\Code\Jack\` for existing files
2. Search lessons folder for documentation
3. Check secrets folder for credentials
4. Review conversation history for context
5. **THEN** suggest new implementation

### For Any Developer

**Before writing new code:**
1. Search codebase for existing implementations
2. Check for similar functions/modules
3. Look for configuration files
4. Review documentation
5. **THEN** write new code if truly needed

---

## Related Lessons

This principle connects to:

1. **"Research Before Implementing"** (OAuth case study)
   - Search documentation before trial-and-error
   - Same concept: investigate first, act second

2. **"Don't Repeat Yourself (DRY)"**
   - Reuse existing code/config
   - Don't duplicate what exists

3. **"Understand Before Acting"**
   - Know current state before changing it
   - Verify assumptions before proceeding

---

## Quick Reference Card

### The 5-Second Check

Before suggesting ANY installation or new setup:

```bash
# 1. Quick search (5 seconds)
find /root/.openclaw/workspace -name "*keyword*"

# If found → investigate existing
# If not found → search broader
# If still nothing → THEN suggest new installation
```

**Remember:** 5 seconds of searching beats 10 minutes of redundant work!

---

## Conclusion

**The Lesson:**  
**"Search workspace first. Don't assume clean slate."**

**Why it matters:**
- Saves time (no redundant setups)
- Builds on existing work
- Shows system awareness
- Prevents user frustration

**How to apply:**
- Search before suggesting
- Test existing before creating new
- Trust file system over memory
- Build incrementally, don't start fresh

**Jack's mistake was valuable** - it created a clear lesson that improves both agents' workflows. The principle is universal: **investigate current state before changing it**.

**Time saved by following this rule:** 10-15 minutes per incident  
**Applies to:** Every technical request  
**ROI:** Massive - prevents countless redundant installations

---

**Status:** ✅ Lesson learned and protocol established  
**Applied by:** Jack (server), Antigravity (PC), all future agents  
**Result:** More efficient, aware, and respectful of existing systems

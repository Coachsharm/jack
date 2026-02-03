# Team Chat Instructions

**Read this when Coach says "write to Antigravity" or "let Antigravity know"**

---

## The Setup

You (Jack) and Antigravity collaborate through a shared message file:

**File:** `/home/node/.openclaw/workspace/TEAM_CHAT.md`

Messages are **newest on top** (like WhatsApp). This saves tokens - you only read the recent messages.

---

## How To Send a Message

### Step 1: Read Recent Context (Optional)
```bash
# Only read the top 50 lines to see recent messages
head -50 /home/node/.openclaw/workspace/TEAM_CHAT.md
```

### Step 2: Create Your Message
```bash
# Prepare your message
MESSAGE="---
**From:** Jack  
**Date:** $(date '+%Y-%m-%d %H:%M')  
**Re:** [Brief topic - e.g., 'Need help with Telegram auth']

[Your message here - be concise]

"
```

### Step 3: Prepend to File (Add to Top)
```bash
# Add your message to the top, pushing old messages down
echo "$MESSAGE" | cat - /home/node/.openclaw/workspace/TEAM_CHAT.md > /tmp/temp_chat.md && mv /tmp/temp_chat.md /home/node/.openclaw/workspace/TEAM_CHAT.md
```

---

## Message Format Example

```markdown
---
**From:** Jack  
**Date:** 2026-02-03 17:20  
**Re:** Telegram channel not responding

Telegram stopped working after I updated the config. Logs show "auth token expired". 
Need guidance on re-authentication process.

---
**From:** Antigravity  
**Date:** 2026-02-03 12:30  
**Re:** Gmail skill deployment plan

I've researched the Gmail skill structure. Here's the config to use:
[config details...]

---
**From:** Jack  
**Date:** 2026-02-03 10:00  
**Re:** Status update

Gmail skill deployed successfully. All tests passing.
```

---

## When To Use This

**Use team chat when:**
- You need help with complex research (saves your tokens!)
- You're stuck on a problem
- Antigravity has instructions/plans for you
- You want to update Antigravity on progress

**Don't use for:**
- Simple questions Coach can answer directly
- Urgent issues (tell Coach directly on Telegram)

---

## Token Efficiency

- **Only read the top 50-100 lines** (recent messages)
- **Keep messages concise** - both you and Antigravity save tokens
- **Don't re-read old messages** unless needed for context

**This saves tokens:** Instead of spending 1000+ tokens researching alone, ask Antigravity. Antigravity does research on the PC (free for you), then writes the answer here.

---

## The Team

1. **You (Jack)** - Server bot at `72.62.252.124` in `openclaw-dntm-openclaw-1`
2. **Coach Sharm** - Your human, mostly on Telegram
3. **Antigravity** - AI on Coach's PC, helps with research and planning

Coach connects you both - he shows Antigravity your messages when on the PC.

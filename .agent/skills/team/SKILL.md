---
name: Team Chat
description: Send messages to Jack OR check for his messages - two-way team communication
---

# Team Chat Skill

## Purpose
Two-way communication with Jack:
1. **Send messages:** User provides message, you send it to Jack
2. **Check messages:** Download, read, process Jack's messages and take action

## Usage

### **Format 1: Send Message to Jack**
```
User: "/team [message for Jack]"
```

**Example:**
```
User: "/team Great job fixing that OAuth bug!"
```

### **Format 2: Check for Jack's Messages**
```
User: "/team"
```

---

## Instructions

### **If User Provides a Message (Format 1):**

**Step 1: Format the Message**
Create properly formatted message:
```markdown
---
**From:** Antigravity  
**Date:** [Current UTC datetime - e.g., 2026-02-04 14:40 UTC]  
**Re:** [Auto-generate brief subject from message content]

[User's message here]

— Antigravity
```

**Step 2: Download Current TEAM_CHAT.md**
```bash
pscp -batch -pw "Corecore8888-" root@72.62.252.124:/root/.openclaw/workspace/TEAM_CHAT.md "c:\Users\hisha\Code\Jack\TEAM_CHAT.md"
```

**Step 3: Prepend Message**
- Add your formatted message to the TOP of TEAM_CHAT.md
- Keep existing messages below

**Step 4: Upload**
```bash
pscp -batch -pw "Corecore8888-" "c:\Users\hisha\Code\Jack\TEAM_CHAT.md" root@72.62.252.124:/home/node/.openclaw/workspace/
```

**Step 5: Confirm**
Tell user: "✅ Message sent to Jack!"

---

### **If User Provides No Message (Format 2):**

**Step 1: Download Current Team Chat**
```bash
pscp -batch -pw "Corecore8888-" root@72.62.252.124:/root/.openclaw/workspace/TEAM_CHAT.md "c:\Users\hisha\Code\Jack\TEAM_CHAT.md"
```

**Step 2: Read the File**
- Open and read `c:\Users\hisha\Code\Jack\TEAM_CHAT.md`
- Identify any NEW messages from Jack (at the top of the file)
- Check if there are any requests or questions for Antigravity

**Step 3: Process Each Message from Jack**

For each unprocessed message from Jack:

**A. Understand the Request**
- What is Jack asking for?
- What action needs to be taken?

**B. Take Action (Not Just Reply!)**
Examples:
- If Jack asks to update a file → Edit the file locally
- If Jack asks for research → Do the research
- If Jack asks to create something → Create it
- If Jack asks a question → Answer it thoroughly

**C. Upload Any Modified Files**
If you edited files, upload them to the server:
```bash
pscp -batch -pw "Corecore8888-" "c:\Users\hisha\Code\Jack\[filename]" root@72.62.252.124:/home/node/.openclaw/workspace/[filename]
```

**D. Reply to Jack**
Prepend your reply to TEAM_CHAT.md:
```markdown
---
**From:** Antigravity  
**Date:** [Current UTC datetime]  
**Re:** [Brief subject - e.g., "COMPLETE - Updated SOUL.md"]

[Your message with results]
✅ [What you did]
✅ [Files modified/created]
✅ [Next steps if any]

— Antigravity
```

**E. Archive Jack's Original Message**
- Copy Jack's message (the one you just processed)
- Append to `c:\Users\hisha\Code\Jack\TEAM_CHAT_ARCHIVE\[YYYY-MM].md`
- Remove it from TEAM_CHAT.md

**Step 4: Upload Updated Files**
```bash
# Upload updated TEAM_CHAT.md
pscp -batch -pw "Corecore8888-" "c:\Users\hisha\Code\Jack\TEAM_CHAT.md" root@72.62.252.124:/home/node/.openclaw/workspace/

# Upload updated archive
pscp -batch -pw "Corecore8888-" "c:\Users\hisha\Code\Jack\TEAM_CHAT_ARCHIVE\*.md" root@72.62.252.124:/home/node/.openclaw/workspace/TEAM_CHAT_ARCHIVE/
```

**Step 5: Report to User**
Summarize what you found and what you did:
```markdown
**Team Chat Summary:**
- [X] new messages from Jack
- Processed: [brief description of each]
- Actions taken: [what you did]
- Files modified: [list]
- Replied to Jack: [confirmation]
```

---

## Important Notes

- **Take action, don't just reply!** If Jack asks for something, do it.
- **Archive after processing** - Keep TEAM_CHAT.md clean
- **Always upload changes** - Both TEAM_CHAT.md and any modified files
- **Be proactive** - If Jack's request needs follow-up, do it

## Token Savings
Using this skill keeps TEAM_CHAT.md small, saving ~30,000 tokens/day (86% reduction).

## Example Usage

### **Example 1: Send Message**
**User:** `/team Great job on the backup automation!`

**You:**
1. Format message with headers (From/Date/Re)
2. Download TEAM_CHAT.md
3. Prepend message to top
4. Upload
5. Confirm: "✅ Message sent to Jack!"

### **Example 2: Check Messages**
**User:** `/team`

**You:**
1. Download TEAM_CHAT.md
2. See Jack asked: "Update SOUL.md to add Calendar capability"
3. Edit SOUL.md locally (add Calendar section)
4. Upload SOUL.md to server
5. Reply to Jack: "Done! Added Calendar capability to SOUL.md"
6. Archive Jack's message
7. Upload updated TEAM_CHAT.md
8. Tell user: "Processed 1 message from Jack. Updated SOUL.md with Calendar capability."

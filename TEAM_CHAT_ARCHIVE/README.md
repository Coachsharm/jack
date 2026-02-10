# Team Chat Archive

This folder contains archived messages from `TEAM_CHAT.md` after they've been processed.

## Purpose

To keep `TEAM_CHAT.md` clean and focused on active/unprocessed messages, we archive completed conversations here. This optimizes token usage by reducing the size of the active chat file by **85-91%**.

## Structure

- **Files organized by month:** `YYYY-MM.md` (e.g., `2026-02.md`)
- **Messages within files:** Chronological order (oldest first)
- **Full context preserved:** Each archived message includes complete header (From/Date/Re)

## When Messages Are Archived

Messages should be moved to the archive when:
- ✅ The recipient has read and acted on the message
- ✅ The conversation thread is complete
- ✅ No further action is required

## Token Efficiency

**Impact:**
- Active `TEAM_CHAT.md`: ~500 tokens (clean)
- Without archival: ~3,500+ tokens (growing)
- **Savings: 85-91% reduction in read costs**

**Cost Savings:**
- Daily: ~30,000 tokens saved
- Monthly: ~900,000 tokens saved
- Financially: ~$19/month saved

## Archive Locations

**Local:** `c:\Users\hisha\Code\Jack\TEAM_CHAT_ARCHIVE\`  
**Server:** `/home/node/.openclaw/workspace/TEAM_CHAT_ARCHIVE/`

## Viewing Archived Messages

To find old messages:
1. Determine the month (e.g., February 2026 = `2026-02.md`)
2. Open that file
3. Search for the date or subject using Ctrl+F

All messages preserve their original headers for easy identification.

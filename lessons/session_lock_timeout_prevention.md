# Session Lock Timeout Prevention — Complete Guide

**Date:** 2026-02-10  
**Author:** Antigravity  
**Applies to:** Any OpenClaw bot (Jack, Ross, John, or future bots)  

---

## The Problem

OpenClaw uses `.jsonl` session files to store conversation history. Each file has a **file lock** — only one process can write at a time. If a session file grows too large (5+ MB), writing takes longer than the 10-second lock timeout. Any concurrent request (heartbeat, cron, second message) fails with:

```
"session file locked (timeout 10000ms)" — all models failed
```

### Analogy

Imagine a librarian who writes everything in one giant logbook. When the logbook is 500 pages, flipping to the end to add a new entry takes 2 seconds — no problem. When it's 5,000 pages, it takes 15 seconds — and everyone waiting in line gives up.

---

## Why OpenClaw Doesn't Handle This Automatically

OpenClaw has a **compaction** system that summarizes old messages to keep the LLM's context window manageable. But compaction works on the **AI's memory**, not the **disk file**. The `.jsonl` file keeps growing because:

- Compaction appends summaries (doesn't replace old entries)
- `.deleted` files are marked but not removed from disk
- No built-in cron or timer to clean session files
- The `prune.idleHours` / `prune.maxAgeDays` settings only apply to Docker **sandbox containers**, not session files

Most OpenClaw users run it as a personal assistant on macOS with light usage. A 24/7 server bot with Telegram + WhatsApp + heartbeats + cron jobs generates WAY more session data — exposing this gap.

---

## The Fix: 3-Tier Session Maintenance

### Tier 1: Stale Lock Cleaner (every 5 minutes)
**What:** Removes `.lock` files older than 30 seconds  
**Why:** Prevents cascade failures — if a lock gets stuck, it's cleared within 5 minutes instead of causing hours of "all models failed"  
**Script:** `/root/.openclaw/cron/stale-lock-cleaner.sh`  
**Impact:** Near-zero — only touches stale locks, doesn't affect active operations  

### Tier 2: Full Session Cleanup (every 6 hours)
**What:** Archives sessions >5 days old, removes `.deleted` and `.bak` files, warns about oversized active sessions  
**Why:** Keeps total session disk usage manageable  
**Script:** `/root/.openclaw/cron/session-cleanup.sh`  
**Impact:** Archives inactive sessions to `sessions-archive/` — Jack loses conversation history for old, inactive threads  

### Cron Entries
```cron
# === OpenClaw Session Maintenance (3-tier) ===
# Tier 1: Stale lock cleaner - every 5 min (prevents cascade failures)
*/5 * * * * /root/.openclaw/cron/stale-lock-cleaner.sh
# Tier 2: Full session cleanup - every 6 hours (archives old/big sessions)
0 */6 * * * /root/.openclaw/cron/session-cleanup.sh >> /var/log/openclaw-session-cleanup.log 2>&1
```

### Log Location
`/var/log/openclaw-session-cleanup.log`

---

## Where Do These Scripts Go? (Native vs Docker)

### Native Install (Jack, Ross)
- **Scripts go on the HOST** at `/root/.openclaw/cron/`
- **Cron is system cron** (`crontab -e`)
- **Sessions live at:** `/root/.openclaw/agents/main/sessions/`
- **Ross sessions at:** `/root/.openclaw-ross/agents/main/sessions/` (separate)

### Docker Install (John, future bots)
- **Scripts go on the HOST**, NOT inside the container
- **Sessions are mounted from host** (Docker mounts `~/.openclaw/` from the host)
- **Cron is system cron** on the host machine
- **Path inside container:** `/home/node/.openclaw/agents/main/sessions/`
- **Path on host:** Whatever you mounted, e.g., `/root/john-openclaw/agents/main/sessions/`
- **Important:** Docker containers get rebuilt — never put cron scripts inside the container. Always on the host.

### Template for New Bots

When creating ANY new OpenClaw bot, add these during setup:

```bash
# 1. Create the cron directory
mkdir -p /path/to/openclaw-home/cron/

# 2. Copy the scripts
cp /root/.openclaw/cron/stale-lock-cleaner.sh /path/to/openclaw-home/cron/
cp /root/.openclaw/cron/session-cleanup.sh /path/to/openclaw-home/cron/

# 3. Edit SESSIONS_DIR in both scripts to point to the correct path
#    Native: /path/to/openclaw-home/agents/main/sessions/
#    Docker: /path/to/host-mounted-openclaw/agents/main/sessions/

# 4. Make executable
chmod +x /path/to/openclaw-home/cron/*.sh

# 5. Add to cron (adjust paths)
crontab -l > /tmp/cron.bak
echo '*/5 * * * * /path/to/openclaw-home/cron/stale-lock-cleaner.sh' >> /tmp/cron.bak
echo '0 */6 * * * /path/to/openclaw-home/cron/session-cleanup.sh >> /var/log/openclaw-session-cleanup.log 2>&1' >> /tmp/cron.bak
crontab /tmp/cron.bak
```

---

## What Sessions Are (And What Deleting Them Does)

| What | Description |
|------|-------------|
| **Session file** | A `.jsonl` file containing the full conversation history for one chat thread |
| **One per channel** | Your Telegram DM = one session. Group chat = another session. Heartbeat = another. |
| **Grows forever** | Every message + tool call + response gets appended. Compaction adds summaries but doesn't shrink the file. |
| **Deleting = amnesia** | If you delete a session, Jack forgets that entire conversation. He'll start fresh. |
| **Safe to delete old ones** | Old sessions (>3 days of inactivity) are safe to archive or delete. Jack rarely references them. |
| **`.deleted` files** | OpenClaw marked them for deletion but never cleaned up. Safe to remove immediately. |

---

## Emergency Fix (If It Happens Again)

```bash
# 1. Immediately clear stuck locks
find /root/.openclaw/agents/main/sessions/ -name "*.lock" -delete

# 2. Run full cleanup
/root/.openclaw/cron/session-cleanup.sh

# 3. Restart gateway
openclaw gateway restart

# 4. Verify
openclaw health --json
```

---

## Prevention Checklist for New Bots

- [ ] Session cleanup scripts installed in `/cron/` directory
- [ ] Stale lock cleaner in cron (every 5 min)
- [ ] Full cleanup in cron (every 6 hours)
- [ ] Scripts point to correct sessions directory
- [ ] Scripts are executable (`chmod +x`)
- [ ] Log file path is writable
- [ ] Archive directory exists (`sessions-archive/`)
- [ ] Verified with: `crontab -l | grep session`

---

## Key Findings from Feb 10, 2026 Incident

- **100 session files** accumulated over 6+ days
- **Largest:** 8.7 MB (single conversation thread)
- **18 `.deleted` files** orphaned on disk (1.1 MB wasted)
- **Ross was NOT the cause** — separate install, separate sessions
- **Root cause:** No automatic session file cleanup + heavy 24/7 usage
- **OpenClaw gap:** Compaction handles LLM memory, NOT disk cleanup
- **Fix:** 3-tier maintenance system (lock cleaner + session cleanup + archive rotation)

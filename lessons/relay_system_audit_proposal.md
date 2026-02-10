# BOT_CHAT Relay System — Full Audit & Improvement Proposal
**Date:** 2026-02-10 18:15 SGT  
**Status:** System is functional, but has several inefficiencies and bugs

---

## 🟢 What's Working

| Component | Status | Notes |
|-----------|--------|-------|
| Relay bridge (`bot-chat-relay.sh`) | ✅ Running | Correctly copies messages between John/Jack ↔ Ross |
| Jack's monitor (`monitor-bot-chat.sh`) | ✅ Running (PID 35862, since Feb 8) | Watches John's file, wakes Jack |
| John's monitor (`monitor-jack-chat.sh`) | ✅ Running (PID 809804, inside container) | Watches shared file, wakes John |
| Ross's monitor (`monitor-bot-chat.sh`) | ✅ Running (PID 1201775) | Watches Ross's file, wakes Ross |
| Relay health check (cron) | ✅ Every 5 min | Auto-restarts relay if dead |
| Monitor health check (cron) | ✅ Every 5 min | Auto-restarts Jack + John monitors |
| Message delivery | ✅ All messages relaying | #1→#7 all delivered in test |
| Auto-start on boot | ✅ `@reboot start-monitors.sh` | Starts Jack monitor, John monitor, relay |

---

## 🔴 Bugs Found

### Bug 1: Duplicate Messages from Jack (#3 appeared twice, #6 appeared twice)

**Root Cause:** Jack gets **double-woken** on every relayed Ross message:
1. **The relay bridge** copies Ross's reply to John's file → Ross's file monitor (`monitor-bot-chat.sh`) detects the change → triggers `openclaw system event` for Jack
2. **Jack's own monitor** (`monitor-bot-chat.sh`) ALSO detects the same change to John's file → triggers ANOTHER `openclaw system event` for Jack

Both fire within seconds. Jack wakes twice, reads the same message twice, writes his reply twice.

**Evidence:**
```
John BOT_CHAT.md lines 15-24: Jack → John (#3) appears TWICE
John BOT_CHAT.md lines 132-141: Jack → John (#6) appears TWICE
```

**Severity:** 🟡 Medium — causes message duplication, bloats BOT_CHAT, wastes LLM tokens

---

### Bug 2: Ross's Monitor Watches the WRONG PATH

**Found in audit section 7:**
```bash
# Ross monitor (host-side)
WATCH_FILE="/home/openclaw/.openclaw/workspace/BOT_CHAT.md"
```

This is the **container-internal path**, not the host path. On the host, this file is at `/root/openclaw-clients/ross/workspace/BOT_CHAT.md`. The monitor works because Docker mounts this path... but it's watching via the container mount, which is fragile and could break if Docker stops.

**Severity:** 🟡 Medium — works now but is architecturally wrong

---

### Bug 3: Relay Log `integer expression expected` Errors

**Found in relay log:**
```
/root/openclaw-clients/bot-chat-relay.sh: line 62: [: 0\n0: integer expression expected
```

**Root Cause:** When `wc -l` outputs the line count, it can include a trailing newline. The `MATCHES_ROSS=$(echo "$HEADER_LINES" | grep -ciE 'Ross|ALL' 2>/dev/null || echo "0")` command returns `0\n0` or similar when grep fails with empty input, creating a multi-line value that's not a valid integer.

**Severity:** 🟢 Low — cosmetic, relay still works

---

### Bug 4: Ross's Monitor AND Relay BOTH Wake Ross (Double-Waking)

Ross gets woken by:
1. **The relay bridge** — `docker exec openclaw-ross openclaw system event --text "New BOT_CHAT message..."` 
2. **Ross's own monitor** — detects the file change the relay just made → `docker exec openclaw-ross openclaw system event --text "BOT_CHAT updated"`

This is the same double-wake problem as Bug 1 but on Ross's side. Ross is more resilient because his HEARTBEAT.md checks state numbers, but it's still wasteful.

**Severity:** 🟢 Low — wastes tokens but doesn't cause duplication (Ross's state file prevents it)

---

### Bug 5: `notify-jack.sh` in Ross's Container Uses Wrong Args

**Found in audit section 15:**
```bash
# Ross's notify-jack.sh
openclaw agent \
  --message "$MSG" \
  --session-id "agent:main:telegram:group:-5213725265" \
  --timeout 120 &
```

This creates a **new agent session** on Ross's instance to talk to Jack's Telegram group. This doesn't actually wake Jack — it makes Ross post to Telegram pretending to be in Jack's session. This is architecturally wrong and likely a no-op or error.

**Severity:** 🟢 Low — the relay bridge has replaced this functionality anyway

---

### Bug 6: `openclaw-daniel` Container Stuck in Restart Loop

**From process list:**
```
openclaw-daniel   Restarting (1) 29 seconds ago
```

Daniel is crash-looping but this is outside the bot-chat system.

**Severity:** 🟡 Medium (separate issue, resource waste)

---

### Bug 7: Jack's `start-wake-bridge.sh` — Zombie Process

**From process list:**
```
root 33438  0.0  0.0  7740  2816 ?  S  Feb08  0:56 /bin/bash /root/.openclaw/workspace/start-wake-bridge.sh
```

This is a script from Feb 8 that's been running for 2+ days. It's likely an older version of the bridge/wake mechanism that was superseded by the relay bridge we just built. It's doing redundant work.

**Severity:** 🟡 Medium — running unnecessarily, could interfere with new relay

---

### Bug 8: Monitor Health Check Missing Ross

**Found in section 22:** The `monitor-health-check.sh` only checks Jack's and John's monitors. It does NOT check or restart Ross's monitor or the relay bridge. If Ross's monitor dies, nothing auto-restarts it (except the separate `relay-health-check.sh` for the relay itself).

**Severity:** 🟡 Medium — Ross's monitor could die and nobody would restart it

---

### Bug 9: Jack Config Has NO Heartbeat Prompt

**From section 21 (Jack config):** The `agents.defaults` section has NO `heartbeat` block at all. Jack only runs heartbeat when manually triggered or when the monitor fires `system event`.

Compare to Ross's config which has:
```json
"heartbeat": {
  "every": "2m",
  "prompt": "Read HEARTBEAT.md if it exists..."
}
```

Jack has no such prompt. When Jack's heartbeat fires, he may not read HEARTBEAT.md consistently.

**Severity:** 🟡 Medium — Jack may not follow the HEARTBEAT.md protocol reliably

---

### Bug 10: John Config Has NO Heartbeat Prompt

**From section 19 (John config):** Same issue as Jack — no `heartbeat` block. John's agent model is `gemini-3-flash` with no heartbeat prompt configured.

**Severity:** 🟡 Medium — same issue as Jack

---

## 🔧 Improvement Proposals

### Proposal 1: Eliminate Double-Waking (Fixes Bug 1 + Bug 4)
**Priority:** 🔴 HIGH — this is the most impactful fix

**Problem:** When the relay copies a message to a file, the file's monitor ALSO detects the change and fires a redundant wake. This causes Jack to write duplicate messages.

**Solution:** Add a **relay lock file** mechanism:
1. Before the relay writes to a file, it creates a lock: `touch /root/openclaw-clients/.relay-state/relay-writing-john`
2. The monitor checks for this lock before firing: `if [ -f .relay-writing-john ]; then skip; fi`
3. The relay removes the lock after writing: `rm .relay-writing-john`

**Alternative (simpler):** Remove Jack's dedicated monitor entirely. The relay bridge already wakes Jack when it detects Ross→Jack messages. However, Jack's monitor also catches John→Jack messages (which don't go through the relay since they share a file). So:

**Best approach:** Make Jack's monitor **only wake Jack for messages NOT from the relay**. Add a dedup check: if the last change was from the relay (check a flag file), skip the wake.

**Risk:** Low — adding a file-based semaphore is simple and non-breaking.

---

### Proposal 2: Fix Ross's Monitor Path (Fixes Bug 2)
**Priority:** 🟡 MEDIUM

**Change:** In `/root/openclaw-clients/ross/workspace/monitor-bot-chat.sh`:
```bash
# FROM:
WATCH_FILE="/home/openclaw/.openclaw/workspace/BOT_CHAT.md"
# TO:
WATCH_FILE="/root/openclaw-clients/ross/workspace/BOT_CHAT.md"
```

**Risk:** None — this is a pure correctness fix.

---

### Proposal 3: Add Heartbeat Config to Jack & John (Fixes Bug 9 + Bug 10)
**Priority:** 🟡 MEDIUM

**Change:** Add to both Jack's and John's `openclaw.json`:
```json
"heartbeat": {
  "every": "2m",
  "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK."
}
```

**Risk:** Low — this just makes them consistent with Ross. They'll check HEARTBEAT.md every 2 minutes. This increases LLM costs slightly but ensures reliable BOT_CHAT monitoring.

---

### Proposal 4: Fix Relay Integer Expression Bug (Fixes Bug 3)
**Priority:** 🟢 LOW

**Change:** In the relay script, sanitize the grep count:
```bash
# FROM:
MATCHES_ROSS=$(echo "$HEADER_LINES" | grep -ciE 'Ross|ALL' 2>/dev/null || echo "0")
# TO:
MATCHES_ROSS=$(echo "$HEADER_LINES" | grep -ciE 'Ross|ALL' 2>/dev/null | tr -d '[:space:]')
[ -z "$MATCHES_ROSS" ] && MATCHES_ROSS=0
```

**Risk:** None — pure bug fix.

---

### Proposal 5: Kill `start-wake-bridge.sh` Zombie (Fixes Bug 7)
**Priority:** 🟡 MEDIUM

**Actions:**
1. Kill PID 33438: `kill 33438`
2. Remove from any cron/startup if it's still referenced
3. Verify what `start-wake-bridge.sh` does — if it's fully superseded by the relay bridge, archive it

**Risk:** Low — but should verify this script isn't needed for anything else.

---

### Proposal 6: Consolidate Monitor Health Check (Fixes Bug 8)
**Priority:** 🟡 MEDIUM

**Change:** Update `monitor-health-check.sh` to also check and restart:
- Ross's monitor (`pgrep -f 'monitor-bot-chat.sh' | grep ross`)
- Relay bridge (already handled by `relay-health-check.sh`, but could consolidate)

**Better approach:** Merge `relay-health-check.sh` INTO `monitor-health-check.sh` so there's ONE health check script that covers ALL components:
- Jack's monitor ✅ (already covered)
- John's monitor ✅ (already covered)
- Ross's monitor ❌ (add)
- Relay bridge ❌ (add, consolidate from separate script)

**Risk:** Low — just expanding existing health check.

---

### Proposal 7: Reduce Redundant Monitoring Scripts
**Priority:** 🟢 LOW (optimization)

**Current state:** There are 4 separate scripts polling files every 2 seconds:
1. Jack's `monitor-bot-chat.sh` — polls John's BOT_CHAT.md
2. John's `monitor-jack-chat.sh` — polls the same file (inside container)
3. Ross's `monitor-bot-chat.sh` — polls Ross's BOT_CHAT.md
4. Relay bridge `bot-chat-relay.sh` — polls BOTH files

Scripts #1 and #4 are BOTH polling John's BOT_CHAT.md on the host. Script #3 and #4 are BOTH polling Ross's BOT_CHAT.md. This is redundant.

**Potential optimization:** The relay bridge could subsume the monitor responsibilities entirely:
- Instead of just relaying cross-file messages, it could also wake the local bot when it detects changes
- This would eliminate scripts #1 and #3 entirely
- John's in-container monitor (#2) would still be needed for container-internal wake

**Risk:** Medium — this is a larger architectural change. More moving parts to test. Recommend deferring until the simpler fixes are validated.

---

### Proposal 8: Stop Daniel's Crash Loop (Fixes Bug 6)
**Priority:** 🟢 LOW (separate issue)

**Action:** Either fix Daniel's config or `docker stop openclaw-daniel` to stop the restart loop from consuming resources.

**Risk:** None for the relay system.

---

## 📊 Priority Summary

| # | Fix | Priority | Risk | Effort |
|---|-----|----------|------|--------|
| 1 | Eliminate double-waking (dedup) | 🔴 HIGH | Low | Medium |
| 2 | Fix Ross monitor path | 🟡 MED | None | Trivial |
| 3 | Add heartbeat config to Jack & John | 🟡 MED | Low | Small |
| 4 | Fix relay integer expression | 🟢 LOW | None | Trivial |
| 5 | Kill wake-bridge zombie | 🟡 MED | Low | Trivial |
| 6 | Consolidate health checks | 🟡 MED | Low | Small |
| 7 | Reduce redundant monitors | 🟢 LOW | Med | Large |
| 8 | Stop Daniel crash loop | 🟢 LOW | None | Trivial |

---

## 🎯 Recommended Execution Order

1. **Quick wins first:** Fix #2 (Ross path), #4 (integer bug), #5 (kill zombie), #8 (stop Daniel)
2. **Core fix:** Fix #1 (dedup mechanism) — this is the most impactful
3. **Config alignment:** Fix #3 (heartbeat config for Jack & John)
4. **Consolidate:** Fix #6 (unified health check)
5. **Defer:** Fix #7 (monitor consolidation) until everything else is stable

---

## 📋 Architecture After All Fixes

```
  ┌───────────────────────────────────────────────────────┐
  │                    HOST (root)                        │
  │                                                       │
  │   ┌──────────────┐        ┌──────────────────────┐   │
  │   │    JACK       │        │    RELAY BRIDGE       │   │
  │   │   (native)    │←──────→│   bot-chat-relay.sh   │   │
  │   │  heartbeat:2m │        │   polls every 2s      │   │
  │   └───────┬───────┘        │   dedup-aware         │   │
  │           │ symlink         └──────┬───────┬────────┘   │
  │   ┌───────┴───────┐               │       │            │
  │   │ John BOT_CHAT │←──────────────┘       │            │
  │   │ (shared file)  │                       │            │
  │   └───────┬────────┘                       │            │
  │           │ Docker mount                   │            │
  │   ┌───────┴───────┐              ┌────────┴──────┐    │
  │   │    JOHN        │              │    ROSS        │    │
  │   │   (Docker)     │              │   (Docker)     │    │
  │   │  heartbeat:2m  │              │  heartbeat:2m  │    │
  │   │  monitor:2s    │              │  Ross BOT_CHAT │    │
  │   └────────────────┘              └────────────────┘    │
  │                                                         │
  │   ┌─────────────────────────────────────────────────┐  │
  │   │ UNIFIED HEALTH CHECK (every 5 min)               │  │
  │   │ - Jack monitor ✓  - John monitor ✓               │  │
  │   │ - Ross monitor ✓  - Relay bridge ✓               │  │
  │   └─────────────────────────────────────────────────┘  │
  └─────────────────────────────────────────────────────────┘
```

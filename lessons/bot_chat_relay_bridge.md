# BOT_CHAT Relay System — How It Works (v4.2)

**Date:** 2026-02-10  
**Status:** ✅ Production — Fully Deployed & Tested  
**Supersedes:** `bot_chat_relay_bridge.md` (v1), `ross_botchat_heartbeat_missing_prompt.md`

---

## Architecture

Jack, John, and Ross communicate through `BOT_CHAT.md` files. Because of how the server is set up, there are actually **two separate files** that need to be bridged:

```
  ┌──────────┐                    ┌──────────┐
  │   JACK   │ ←── symlink ────→ │   JOHN   │
  │ (native) │                    │ (Docker) │
  │          │    SAME PHYSICAL   │          │
  │ BOT_CHAT ├────────────────────┤ BOT_CHAT │
  └────┬─────┘                    └────┬─────┘
       │                               │
       │      ┌────────────────┐       │
       │      │  RELAY BRIDGE  │       │
       └──────┤  (host-side)   ├───────┘
              │  v4.2          │
              └───────┬────────┘
                      │
              ┌───────┴────────┐
              │     ROSS       │
              │   (Docker)     │
              │  SEPARATE FILE │
              │   BOT_CHAT.md  │
              └────────────────┘
```

- **Jack's BOT_CHAT.md** is a symlink → **John's BOT_CHAT.md** (same physical file)
- **Ross's BOT_CHAT.md** is a completely separate file on a different Docker volume
- The **Relay Bridge** copies messages between the two files

## Components (5 total)

| Component | Location (Server) | Version | Purpose |
|-----------|-------------------|---------|---------|
| **Relay Bridge** | `/root/openclaw-clients/bot-chat-relay.sh` | v4.2 | Copies messages between John/Jack's and Ross's BOT_CHAT files |
| **Jack's Monitor** | `/root/.openclaw/workspace/monitor-bot-chat.sh` | v3 | Watches shared file, wakes Jack when someone else writes |
| **Ross's Monitor** | `/root/openclaw-clients/ross/workspace/monitor-bot-chat.sh` | v3 | Watches Ross's file, wakes Ross when someone else writes |
| **John's Monitor** | Inside `openclaw-john` container at `/home/openclaw/.openclaw/workspace/monitor-jack-chat.sh` | v3 | Watches shared file, wakes John when someone else writes |
| **Health Check** | `/root/.openclaw/workspace/monitor-health-check.sh` | unified | Restarts any dead component every 5 min (cron) |

## Dedup System (3 Layers)

The #1 problem we solved was **duplicate messages** — bots getting woken by their own writes. Three layers prevent this:

### Layer 1: Self-Write Detection (Monitors v3)
Each monitor checks the LAST `###` header in the file. If the bot itself wrote it, skip the wake:
```bash
LAST_HEADER=$(grep '###' "$WATCH_FILE" | tail -1)
if echo "$LAST_HEADER" | grep -qi -- 'SGT - Jack'; then
    echo "Skipping — Jack wrote it (self-write dedup)"
fi
```
**Key:** The `--` before the pattern is mandatory — without it, grep interprets `- Jack` as a flag.

### Layer 2: Relay Lock Files
When the relay bridge copies messages to a file, it creates a temporary lock:
```
/root/openclaw-clients/.relay-state/relay-writing-john   (for John/Jack's file)
/root/openclaw-clients/.relay-state/relay-writing-ross   (for Ross's file)
```
Monitors check for the lock and skip if present. Lock is removed 1 second after write.

### Layer 3: State File
Each bot's HEARTBEAT.md checks `.bot-chat-state` (a number) to avoid responding to messages already handled. This is the bot-level dedup.

## Relay Bridge Details (v4.2)

The relay runs every 2 seconds and:

1. **Checks Ross → Jack/John FIRST** (critical ordering)
   - If Ross wrote new messages, copy them to John's file + wake Jack/John
2. **Then checks John/Jack → Ross**
   - If Jack or John wrote new messages for Ross, copy to Ross's file + wake Ross

**Why order matters:** If we checked John→Ross first and wrote to Ross's file, the line count update would swallow any messages Ross wrote between polls. By checking Ross FIRST, we catch his outbound messages before potentially modifying his file.

### Truncation Detection
If a BOT_CHAT file is cleared (e.g., for a clean restart test), the relay detects the line count dropped below stored state and auto-resets:
```bash
if [ "$ROSS_CURRENT" -lt "$ROSS_LAST" ]; then
    log "RESET: Ross file truncated, resetting state"
    ROSS_LAST=0
fi
```

## File Paths

| Bot | BOT_CHAT.md Location | Config |
|-----|---------------------|--------|
| **Jack** (native) | `/root/.openclaw/workspace/BOT_CHAT.md` → symlink to John's | `/root/.openclaw/openclaw.json` |
| **John** (Docker) | `/root/openclaw-clients/john/workspace/BOT_CHAT.md` | `/root/openclaw-clients/john/openclaw.json` |
| **Ross** (Docker) | `/root/openclaw-clients/ross/workspace/BOT_CHAT.md` | `/root/openclaw-clients/ross/openclaw.json` |

## Heartbeat Config (All 3 Bots)

All bots have identical heartbeat configuration:
```json
{
  "agents": {
    "defaults": {
      "heartbeat": {
        "every": "2m",
        "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK."
      }
    }
  }
}
```

## Message Format

```
### 2026-02-10 19:32:15 SGT - Jack → Ross (#1)
Message content here

⏱ 07:32:15pm SGT
```

- `###` header is required — the relay and monitors parse it
- `SGT - [Sender]` pattern is how dedup identifies who wrote the message
- `→ [Recipient]` is how the relay decides where to copy

## Cron (Auto-Start & Self-Healing)

```bash
# On boot: start all monitors + relay
@reboot /root/.openclaw/workspace/start-monitors.sh

# Every 5 min: health check restarts dead components
*/5 * * * * /root/.openclaw/workspace/monitor-health-check.sh
```

## Troubleshooting

### Bot not responding to BOT_CHAT messages
1. Check monitor is running: `ps aux | grep monitor`
2. Check relay is running: `ps aux | grep relay`
3. Check heartbeat config: `grep -A3 heartbeat /root/.openclaw/openclaw.json`
4. Manual wake: `openclaw system event --text "BOT_CHAT updated" --mode now`

### Duplicate messages appearing
1. Check monitor version (should be v3): `head -3 /root/.openclaw/workspace/monitor-bot-chat.sh`
2. Check for `grep -qi -- 'SGT - Jack'` pattern (the `--` is critical)
3. Check relay lock cleanup: `ls /root/openclaw-clients/.relay-state/`

### Messages not crossing between bots
1. Check relay log: `tail -20 /root/openclaw-clients/relay-bridge.log`
2. Check state files: `cat /root/openclaw-clients/.relay-state/*-relayed-lines`
3. Compare to actual line counts: `wc -l /root/openclaw-clients/*/workspace/BOT_CHAT.md`

## Bugs Fixed (2026-02-10)

| Bug | Fix |
|-----|-----|
| Jack wrote duplicate messages | v3 monitor self-write dedup |
| Ross monitor watched wrong path | Fixed to host path `/root/openclaw-clients/ross/workspace/` |
| `integer expression expected` errors | Sanitized all `wc`/`grep` output with `tr -d '[:space:]'` |
| Zombie `start-wake-bridge.sh` process | Killed, not needed anymore |
| Daniel in crash loop | `docker stop openclaw-daniel` |
| Jack & John had no heartbeat prompt | Added matching config to both |
| Redundant health check cron entries | Consolidated into single unified check |
| Race condition: Ross messages swallowed | Reordered relay to check Ross→Jack FIRST |
| `grep` treated `- Jack` as flag | Added `--` before pattern in all monitors |
| File truncation broke relay state | Added auto-reset when line count drops |

# BOT_CHAT System — John's Guide

**Date:** 2026-02-10  
**John runs in:** Docker container `openclaw-john`  
**Version:** Monitor v3 with self-write dedup

---

## How John Communicates

John shares a physical `BOT_CHAT.md` file with Jack (via Docker volume mount). Ross has a separate file — a **Relay Bridge** on the host copies messages between them automatically.

### John's File Paths (Inside Container)
```
BOT_CHAT.md:      /home/openclaw/.openclaw/workspace/BOT_CHAT.md
State file:       /home/openclaw/.openclaw/workspace/.bot-chat-state
Monitor:          /home/openclaw/.openclaw/workspace/monitor-jack-chat.sh
Config:           /home/openclaw/.openclaw/openclaw.json
```

### How It Maps to Host
```
Container path:   /home/openclaw/.openclaw/workspace/BOT_CHAT.md
Host path:        /root/openclaw-clients/john/workspace/BOT_CHAT.md
Jack's symlink:   /root/.openclaw/workspace/BOT_CHAT.md → John's file
```

## Sending a Message

```bash
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
MESSAGE="Your message here"
RECIPIENT="Jack"  # or Ross, or ALL

cat >> ~/.openclaw/workspace/BOT_CHAT.md << EOF

### ${TIMESTAMP} SGT - John → ${RECIPIENT} (#N)
${MESSAGE}

⏱ $(date '+%I:%M:%S%P') SGT
EOF
```

Then post to Telegram so Coach sees:
```bash
message --action send --channel telegram --target -5213725265 \
  --message "📋 John → ${RECIPIENT} (#N): [brief summary]"
```

## Receiving Messages

John's **monitor** (`monitor-jack-chat.sh` v3) watches BOT_CHAT.md every 2 seconds:
1. Detects file change (md5 hash comparison)
2. Checks last `###` header — if John wrote it, **skips** (self-write dedup)
3. If someone else wrote → triggers `openclaw system event` to wake John
4. John's heartbeat (every 2m) also checks BOT_CHAT via HEARTBEAT.md

### What Triggers John
- ✅ Jack writes a message → monitor wakes John
- ✅ Ross writes a message (via relay bridge) → monitor wakes John
- ❌ John writes a message → monitor **skips** (self-write dedup)

## The Relay Bridge

John doesn't need to worry about the relay — it's automatic:
- When John writes `→ Ross`, the relay copies his message to Ross's separate file
- When Ross writes `→ John` or `→ ALL`, the relay copies to John's file
- The relay sets a lock file during copies so John's monitor doesn't double-trigger

## Heartbeat Config

```json
{
  "agents": {
    "defaults": {
      "heartbeat": {
        "every": "2m",
        "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly."
      }
    }
  }
}
```

## Message Format (Always Use This)

```
### 2026-02-10 19:14:15 SGT - John → Jack (#9)
Message content here

⏱ 07:14:15pm SGT
```

**Critical:** The `SGT - John` pattern in the header is how the dedup system identifies John's messages. Always include it.

## Bot Network

| Bot | Type | Role |
|-----|------|------|
| **Jack** | Native | Primary bot, shares BOT_CHAT file with John |
| **John** | Docker | You — reads same physical file as Jack |
| **Ross** | Docker | Separate file, connected via relay bridge |

## Troubleshooting

**John not responding:**
```bash
# From host, check monitor
docker exec openclaw-john pgrep -a -f monitor-jack-chat.sh

# Check heartbeat
docker exec openclaw-john cat ~/.openclaw/openclaw.json | grep -A3 heartbeat

# Manual wake
docker exec openclaw-john openclaw system event --text "BOT_CHAT updated" --mode now
```

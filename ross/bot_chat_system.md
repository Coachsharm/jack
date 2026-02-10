# BOT_CHAT System — Ross's Guide

**Date:** 2026-02-10  
**Ross runs in:** Docker container `openclaw-ross`  
**Version:** Monitor v3 with self-write dedup  
**Supersedes:** `server_updates/ross-BOT_CHAT_PROTOCOL.md` (outdated)

---

## How Ross Communicates

Ross has his **own separate** `BOT_CHAT.md` file, different from Jack/John's shared file. A **Relay Bridge** on the host automatically copies messages between the two files.

### Ross's File Paths (Inside Container)
```
BOT_CHAT.md:      ~/.openclaw/workspace/BOT_CHAT.md
State file:       ~/.openclaw/workspace/.bot-chat-state
Config:           ~/.openclaw/openclaw.json
```

### How It Maps to Host
```
Container path:   /home/openclaw/.openclaw/workspace/BOT_CHAT.md
Host path:        /root/openclaw-clients/ross/workspace/BOT_CHAT.md
Monitor (host):   /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh
```

**Important:** Ross's monitor runs on the **host** (not inside the container), but wakes Ross via `docker exec`.

## Sending a Message

```bash
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
MESSAGE="Your message here"
RECIPIENT="Jack"  # or John, or ALL

cat >> ~/.openclaw/workspace/BOT_CHAT.md << EOF

### ${TIMESTAMP} SGT - Ross → ${RECIPIENT} (#N)
${MESSAGE}

⏱ $(date '+%I:%M:%S%P') SGT
EOF
```

Then post to Telegram so Coach sees:
```bash
message --action send --channel telegram --target -5213725265 \
  --message "📋 Ross → ${RECIPIENT} (#N): [brief summary]"
```

## Receiving Messages

Ross's **monitor** runs on the host and watches the host-path file every 2 seconds:
1. Detects file change (md5 hash comparison)
2. Checks for relay lock — if present, **skips** (relay bridge just wrote)
3. Checks last `###` header — if Ross wrote it, **skips** (self-write dedup)
4. If someone else wrote → triggers `docker exec openclaw-ross openclaw system event` to wake Ross

### What Triggers Ross
- ✅ Jack writes a message (via relay bridge) → monitor wakes Ross
- ✅ John writes a message (via relay bridge) → monitor wakes Ross
- ❌ Ross writes a message → monitor **skips** (self-write dedup)
- ❌ Relay writes to file → monitor **skips** (relay lock)

## The Relay Bridge

The relay bridge is **critical** for Ross because without it, he can't see Jack/John's messages:
- Jack/John's BOT_CHAT and Ross's BOT_CHAT are **different physical files**
- The relay copies `→ Ross` or `→ ALL` messages from Jack/John's file to Ross's file
- The relay copies `→ Jack`, `→ John`, or `→ ALL` messages from Ross's file to Jack/John's file
- The relay processes **Ross → Jack/John FIRST** each cycle (prevents race conditions)

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
### 2026-02-10 19:09:30 SGT - Ross → Jack (#1)
Message content here

⏱ 07:09:30pm SGT
```

**Critical:** The `SGT - Ross` pattern in the header is how the dedup system identifies Ross's messages. Always include it.

## Bot Network

| Bot | Type | Role |
|-----|------|------|
| **Jack** | Native | Primary bot, connected to Ross via relay |
| **John** | Docker | Shares physical file with Jack |
| **Ross** | Docker | You — separate file, relay bridge required |

## Bugs That Were Fixed (2026-02-10)

| Issue | Fix |
|-------|-----|
| Ross's monitor watched container path | Fixed to host path `/root/openclaw-clients/ross/workspace/` |
| Ross had no heartbeat prompt | Added `prompt` field to match Jack/John |
| Messages from Jack/John never arrived | Relay bridge deployed to copy between files |
| Double-wake when relay wrote | Relay lock file mechanism added |

## Troubleshooting

**Ross not responding:**
```bash
# Check monitor running (from host)
ps aux | grep 'ross/workspace/monitor'

# Check container running
docker ps --filter name=ross

# Check heartbeat config
docker exec openclaw-ross cat ~/.openclaw/openclaw.json | grep -A3 heartbeat

# Manual wake
docker exec openclaw-ross openclaw system event --text "BOT_CHAT updated" --mode now

# Check relay log
tail -20 /root/openclaw-clients/relay-bridge.log
```

**Ross's messages not reaching Jack/John:**
```bash
# Check relay bridge running
ps aux | grep relay

# Check relay state
cat /root/openclaw-clients/.relay-state/ross-relayed-lines

# Compare to actual line count
wc -l /root/openclaw-clients/ross/workspace/BOT_CHAT.md
```

---

**Remember:** Ross uses Docker paths (`~/.openclaw/`) inside the container. All scripts inside the container must use these paths, not host paths.

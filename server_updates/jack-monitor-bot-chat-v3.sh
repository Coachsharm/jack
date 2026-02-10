#!/bin/bash
# Monitor John's BOT_CHAT.md for changes and trigger Jack's heartbeat
# v3: Dedup — skips wake if:
#   1. Relay bridge just wrote (lock file), OR
#   2. Jack himself wrote the last message (self-write dedup)
WATCH_FILE="/root/openclaw-clients/john/workspace/BOT_CHAT.md"
RELAY_LOCK="/root/openclaw-clients/.relay-state/relay-writing-john"
LAST_HASH=""

while true; do
    if [ -f "$WATCH_FILE" ]; then
        CURRENT_HASH=$(md5sum "$WATCH_FILE" | awk '{print $1}')

        if [ -n "$LAST_HASH" ] && [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
            if [ -f "$RELAY_LOCK" ]; then
                echo "$(date): BOT_CHAT changed but relay lock active — skipping wake"
            else
                LAST_HEADER=$(grep '###' "$WATCH_FILE" | tail -1)
                if echo "$LAST_HEADER" | grep -qi -- 'SGT - Jack'; then
                    echo "$(date): BOT_CHAT changed but Jack wrote it — skipping wake (self-write dedup)"
                else
                    openclaw system event --text "BOT_CHAT updated" --mode now &
                    echo "$(date): BOT_CHAT changed, triggered heartbeat"
                fi
            fi
        fi

        LAST_HASH="$CURRENT_HASH"
    fi

    sleep 2
done

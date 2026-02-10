#!/bin/bash
# Monitor Jack's messages in BOT_CHAT.md (runs inside John's container)
# v3: Dedup — skips wake if John himself wrote the last message
WATCH_FILE="/home/openclaw/.openclaw/workspace/BOT_CHAT.md"
LAST_HASH=""

while true; do
    if [ -f "$WATCH_FILE" ]; then
        CURRENT_HASH=$(md5sum "$WATCH_FILE" | awk '{print $1}')

        if [ -n "$LAST_HASH" ] && [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
            LAST_HEADER=$(grep '###' "$WATCH_FILE" | tail -1)
            if echo "$LAST_HEADER" | grep -qi -- 'SGT - John'; then
                echo "$(date): BOT_CHAT changed but John wrote it — skipping wake (self-write dedup)"
            else
                openclaw system event --text "BOT_CHAT updated by Jack" --mode now &
                echo "$(date): BOT_CHAT changed, triggered heartbeat"
            fi
        fi

        LAST_HASH="$CURRENT_HASH"
    fi

    sleep 2
done

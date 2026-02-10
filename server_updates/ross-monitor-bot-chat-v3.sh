#!/bin/bash
# Ross's BOT_CHAT monitor - watches for messages from Jack/John
# v3: Dedup — skips wake if:
#   1. Relay bridge just wrote (lock file), OR
#   2. Ross himself wrote the last message (self-write dedup)
# Runs on HOST, watches HOST path, talks to Docker container
WATCH_FILE="/root/openclaw-clients/ross/workspace/BOT_CHAT.md"
RELAY_LOCK="/root/openclaw-clients/.relay-state/relay-writing-ross"
LAST_HASH=""

while true; do
    if [ -f "$WATCH_FILE" ]; then
        CURRENT_HASH=$(md5sum "$WATCH_FILE" | awk '{print $1}')

        if [ -n "$LAST_HASH" ] && [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
            if [ -f "$RELAY_LOCK" ]; then
                echo "$(date): BOT_CHAT changed but relay lock active — skipping wake"
            else
                LAST_HEADER=$(grep '###' "$WATCH_FILE" | tail -1)
                if echo "$LAST_HEADER" | grep -qi -- 'SGT - Ross'; then
                    echo "$(date): BOT_CHAT changed but Ross wrote it — skipping wake (self-write dedup)"
                else
                    docker exec openclaw-ross openclaw system event --text "BOT_CHAT updated" --mode now &
                    echo "$(date): BOT_CHAT changed, triggered heartbeat"
                fi
            fi
        fi

        LAST_HASH="$CURRENT_HASH"
    fi

    sleep 2
done

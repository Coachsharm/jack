#!/bin/bash
# Monitor John's BOT_CHAT.md for changes and trigger Jack's heartbeat
# v2: Added relay lock check — skips wake if relay bridge just wrote to this file
WATCH_FILE="/root/openclaw-clients/john/workspace/BOT_CHAT.md"
RELAY_LOCK="/root/openclaw-clients/.relay-state/relay-writing-john"
LAST_HASH=""

while true; do
    if [ -f "$WATCH_FILE" ]; then
        CURRENT_HASH=$(md5sum "$WATCH_FILE" | awk '{print $1}')
        
        if [ -n "$LAST_HASH" ] && [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
            # File changed! But check if the relay bridge caused this change
            if [ -f "$RELAY_LOCK" ]; then
                echo "$(date): BOT_CHAT changed but relay lock active — skipping wake"
            else
                openclaw system event --text "BOT_CHAT updated" --mode now &
                echo "$(date): BOT_CHAT changed, triggered heartbeat"
            fi
        fi
        
        LAST_HASH="$CURRENT_HASH"
    fi
    
    sleep 2
done

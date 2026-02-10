#!/bin/bash
# Ross's BOT_CHAT monitor - watches for messages from Jack/John
# UPDATED: 2026-02-10 — Ross now runs in Docker
# Location: /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh
# Runs on HOST, talks to Docker container

WATCH_FILE="/root/openclaw-clients/ross/workspace/BOT_CHAT.md"
LAST_HASH=""

while true; do
    if [ -f "$WATCH_FILE" ]; then
        CURRENT_HASH=$(md5sum "$WATCH_FILE" | awk '{print $1}')
        
        if [ -n "$LAST_HASH" ] && [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
            # File changed! Trigger Ross's heartbeat via Docker
            docker exec openclaw-ross openclaw system event --text "BOT_CHAT updated" --mode now &
            echo "$(date): BOT_CHAT changed, triggered heartbeat"
        fi
        
        LAST_HASH="$CURRENT_HASH"
    fi
    
    sleep 2
done

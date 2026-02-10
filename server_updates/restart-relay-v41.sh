#!/bin/bash
# Restart relay v4.1
PID=$(pgrep -f bot-chat-relay.sh)
if [ -n "$PID" ]; then
    kill $PID
    sleep 1
    echo "Killed old relay PID $PID"
fi
nohup /root/openclaw-clients/bot-chat-relay.sh >> /root/openclaw-clients/relay-bridge.log 2>&1 &
echo "RELAY_STARTED PID=$!"

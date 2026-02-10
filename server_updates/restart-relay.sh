#!/bin/bash
# Kill old relay, clear state, restart
pkill -f bot-chat-relay 2>/dev/null
sleep 1
rm -f /root/openclaw-clients/.relay-state/john-relayed-lines
rm -f /root/openclaw-clients/.relay-state/ross-relayed-lines
chmod +x /root/openclaw-clients/bot-chat-relay.sh
nohup /root/openclaw-clients/bot-chat-relay.sh > /root/openclaw-clients/relay-bridge.log 2>&1 &
echo "Relay restarted. PID: $!"

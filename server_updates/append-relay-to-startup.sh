#!/bin/bash
# Append relay bridge startup to start-monitors.sh

cat >> /root/.openclaw/workspace/start-monitors.sh << 'EOF'

# Start BOT_CHAT Relay Bridge (John/Jack <-> Ross)
if ! pgrep -f 'bot-chat-relay.sh' > /dev/null; then
    nohup /root/openclaw-clients/bot-chat-relay.sh > /root/openclaw-clients/relay-bridge.log 2>&1 &
    echo "[$TIMESTAMP] Started BOT_CHAT relay bridge (PID: $!)" >> "$LOG_DIR/monitor-startup.log"
else
    echo "[$TIMESTAMP] Relay bridge already running" >> "$LOG_DIR/monitor-startup.log"
fi
EOF

echo "✅ Relay bridge added to start-monitors.sh"

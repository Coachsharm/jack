#!/bin/bash
# BOT_CHAT Relay Bridge health check
# Ensures the relay bridge is running, restarts if not
# Add to cron: */5 * * * * /root/openclaw-clients/relay-health-check.sh

if ! pgrep -f 'bot-chat-relay.sh' > /dev/null; then
    echo "$(date): Relay bridge NOT running, restarting..." >> /root/openclaw-clients/relay-bridge.log
    nohup /root/openclaw-clients/bot-chat-relay.sh >> /root/openclaw-clients/relay-bridge.log 2>&1 &
    echo "$(date): Relay bridge restarted (PID: $!)" >> /root/openclaw-clients/relay-bridge.log
fi

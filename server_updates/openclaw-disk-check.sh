#!/bin/bash
USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$USAGE" -gt 85 ]; then
    docker system prune -f 2>/dev/null
    journalctl --vacuum-size=100M 2>/dev/null
    find /root/.openclaw/agents/main/sessions/ -mtime +7 -delete 2>/dev/null
    echo "[$(date)] Disk was at ${USAGE}% — cleaned up" >> /root/openclaw-watchdog/watchdog.log
fi

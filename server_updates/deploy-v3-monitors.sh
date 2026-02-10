#!/bin/bash
# Deploy v3 monitors with self-write dedup
echo "=== DEPLOYING v3 MONITORS (self-write dedup) ==="

# 1. Deploy Jack's monitor v3
echo "[1/3] Jack's monitor v3..."
cp /tmp/jack-monitor-v3.sh /root/.openclaw/workspace/monitor-bot-chat.sh
chmod +x /root/.openclaw/workspace/monitor-bot-chat.sh
# Restart Jack's monitor
PID=$(pgrep -f 'openclaw/workspace/monitor-bot-chat.sh')
[ -n "$PID" ] && kill "$PID" 2>/dev/null
sleep 1
nohup /root/.openclaw/workspace/monitor-bot-chat.sh >> /root/.openclaw/workspace/monitor-bot-chat.log 2>&1 &
echo "  Jack monitor v3 deployed (PID: $!)"

# 2. Deploy Ross's monitor v3
echo "[2/3] Ross's monitor v3..."
cp /tmp/ross-monitor-v3.sh /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh
chmod +x /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh
# Restart Ross's monitor
PID=$(pgrep -f 'ross/workspace/monitor-bot-chat.sh')
[ -n "$PID" ] && kill "$PID" 2>/dev/null
sleep 1
nohup /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh >> /root/openclaw-clients/ross/workspace/monitor-bot-chat.log 2>&1 &
echo "  Ross monitor v3 deployed (PID: $!)"

# 3. Deploy John's monitor v3 (inside container)
echo "[3/3] John's monitor v3..."
cp /tmp/john-monitor-v3.sh /root/openclaw-clients/john/workspace/monitor-jack-chat.sh
chmod +x /root/openclaw-clients/john/workspace/monitor-jack-chat.sh
# Restart John's monitor inside container
docker exec openclaw-john bash -c 'PID=$(pgrep -f monitor-jack-chat.sh); [ -n "$PID" ] && kill $PID'
sleep 1
docker exec openclaw-john bash -c 'nohup /home/openclaw/.openclaw/workspace/monitor-jack-chat.sh > /home/openclaw/.openclaw/workspace/monitor-jack-chat.log 2>&1 &'
echo "  John monitor v3 deployed (inside container)"

echo ""
echo "=== ALL v3 MONITORS DEPLOYED ==="
echo ""
echo "Verify:"
ps aux | grep 'monitor-' | grep -v grep
echo "---"
docker exec openclaw-john pgrep -a -f 'monitor-jack-chat.sh'

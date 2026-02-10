#!/bin/bash
# ============================================================
# RELAY SYSTEM IMPROVEMENTS — Phase 2: Core Dedup Fix
# ============================================================
# Fixes: Bug 1 (double-waking), Bug 3 (integer expression)
# Deploys: v4 relay bridge, v2 monitors with lock support
# ============================================================

echo "=== PHASE 2: CORE DEDUP FIX ==="
echo ""

# Kill existing relay and monitors
echo "[1/4] Stopping relay and monitors..."
pkill -f 'bot-chat-relay.sh' 2>/dev/null
sleep 1
pkill -f 'openclaw/workspace/monitor-bot-chat.sh' 2>/dev/null
pkill -f 'ross/workspace/monitor-bot-chat.sh' 2>/dev/null
sleep 1
echo "  Stopped"

# Deploy v4 relay
echo "[2/4] Deploying v4 relay bridge..."
# Already uploaded via SCP before running this script
chmod +x /root/openclaw-clients/bot-chat-relay.sh
echo "  v4 relay deployed"

# Deploy v2 Jack monitor
echo "[3/4] Deploying v2 Jack monitor..."
cp /tmp/jack-monitor-v2.sh /root/.openclaw/workspace/monitor-bot-chat.sh
chmod +x /root/.openclaw/workspace/monitor-bot-chat.sh
echo "  v2 Jack monitor deployed"

# Deploy v2 Ross monitor
echo "[4/4] Deploying v2 Ross monitor..."
cp /tmp/ross-monitor-v2.sh /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh
chmod +x /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh
echo "  v2 Ross monitor deployed"

# Clean relay state (fresh start)
echo ""
echo "Resetting relay state for clean start..."
rm -f /root/openclaw-clients/.relay-state/john-relayed-lines
rm -f /root/openclaw-clients/.relay-state/ross-relayed-lines
rm -f /root/openclaw-clients/.relay-state/relay-writing-john
rm -f /root/openclaw-clients/.relay-state/relay-writing-ross

# Start everything back up
echo "Starting all components..."
nohup /root/openclaw-clients/bot-chat-relay.sh >> /root/openclaw-clients/relay-bridge.log 2>&1 &
echo "  Relay bridge started (PID: $!)"

nohup /root/.openclaw/workspace/monitor-bot-chat.sh >> /root/.openclaw/workspace/monitor-bot-chat.log 2>&1 &
echo "  Jack monitor started (PID: $!)"

nohup /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh >> /root/openclaw-clients/ross/workspace/monitor-bot-chat.log 2>&1 &
echo "  Ross monitor started (PID: $!)"

# Verify John's monitor is still running inside container
if docker exec openclaw-john pgrep -f 'monitor-jack-chat.sh' > /dev/null 2>&1; then
    echo "  John monitor still running (inside container)"
else
    docker exec openclaw-john bash -c 'nohup /home/openclaw/.openclaw/workspace/monitor-jack-chat.sh > /home/openclaw/.openclaw/workspace/monitor-jack-chat.log 2>&1 &'
    echo "  John monitor restarted (inside container)"
fi

echo ""
echo "=== PHASE 2 COMPLETE ==="
echo ""
echo "Running processes:"
ps aux | grep -E 'monitor|relay' | grep -v grep

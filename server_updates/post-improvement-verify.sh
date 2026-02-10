#!/bin/bash
# Post-improvement verification
echo "=== POST-IMPROVEMENT VERIFICATION ==="
echo ""

echo "1. RUNNING PROCESSES:"
ps aux | grep -E 'monitor|relay' | grep -v grep
echo ""

echo "2. ZOMBIE CHECK (start-wake-bridge):"
if pgrep -f 'start-wake-bridge.sh' > /dev/null; then
    echo "  ⚠️ STILL RUNNING"
else
    echo "  ✅ Dead (as expected)"
fi
echo ""

echo "3. DANIEL STATUS:"
docker ps -a --filter name=daniel --format '{{.Names}} {{.Status}}'
echo ""

echo "4. RELAY BRIDGE VERSION:"
head -5 /root/openclaw-clients/bot-chat-relay.sh | grep -i 'v[0-9]'
echo ""

echo "5. JACK MONITOR VERSION:"
head -3 /root/.openclaw/workspace/monitor-bot-chat.sh
echo ""

echo "6. ROSS MONITOR PATH:"
grep 'WATCH_FILE=' /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh
echo ""

echo "7. LOCK FILE SUPPORT:"
grep 'RELAY_LOCK' /root/.openclaw/workspace/monitor-bot-chat.sh | head -1
grep 'RELAY_LOCK' /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh | head -1
echo ""

echo "8. JACK HEARTBEAT CONFIG:"
python3 -c "import json; c=json.load(open('/root/.openclaw/openclaw.json')); print(json.dumps(c.get('agents',{}).get('defaults',{}).get('heartbeat',{}), indent=2))"
echo ""

echo "9. JOHN HEARTBEAT CONFIG:"
python3 -c "import json; c=json.load(open('/root/openclaw-clients/john/openclaw.json')); print(json.dumps(c.get('agents',{}).get('defaults',{}).get('heartbeat',{}), indent=2))"
echo ""

echo "10. ROSS HEARTBEAT CONFIG:"
python3 -c "import json; c=json.load(open('/root/openclaw-clients/ross/openclaw.json')); print(json.dumps(c.get('agents',{}).get('defaults',{}).get('heartbeat',{}), indent=2))"
echo ""

echo "11. HEALTH CHECK COVERAGE:"
grep 'check_and_restart' /root/.openclaw/workspace/monitor-health-check.sh
echo ""

echo "12. CRONTAB (clean):"
crontab -l 2>/dev/null
echo ""

echo "13. RELAY LOG (fresh):"
tail -10 /root/openclaw-clients/relay-bridge.log
echo ""

echo "=== VERIFICATION COMPLETE ==="

#!/bin/bash
# Full diagnostic dump for audit
OUT="/tmp/audit-dump.txt"

echo "=== AUDIT DUMP $(date) ===" > "$OUT"

echo "" >> "$OUT"
echo "===== 1. RUNNING PROCESSES =====" >> "$OUT"
ps aux | grep -E 'monitor|relay|openclaw' | grep -v grep >> "$OUT"

echo "" >> "$OUT"
echo "===== 2. DOCKER CONTAINERS =====" >> "$OUT"
docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' >> "$OUT"

echo "" >> "$OUT"
echo "===== 3. CRONTAB =====" >> "$OUT"
crontab -l 2>/dev/null >> "$OUT"

echo "" >> "$OUT"
echo "===== 4. START-MONITORS.SH =====" >> "$OUT"
cat /root/.openclaw/workspace/start-monitors.sh >> "$OUT"

echo "" >> "$OUT"
echo "===== 5. JACK MONITOR (host) =====" >> "$OUT"
cat /root/.openclaw/workspace/monitor-bot-chat.sh >> "$OUT"

echo "" >> "$OUT"
echo "===== 6. JOHN MONITOR (inside container) =====" >> "$OUT"
cat /root/openclaw-clients/john/workspace/monitor-jack-chat.sh >> "$OUT"

echo "" >> "$OUT"
echo "===== 7. ROSS MONITOR (host) =====" >> "$OUT"
cat /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh >> "$OUT"

echo "" >> "$OUT"
echo "===== 8. RELAY BRIDGE =====" >> "$OUT"
cat /root/openclaw-clients/bot-chat-relay.sh >> "$OUT"

echo "" >> "$OUT"
echo "===== 9. RELAY HEALTH CHECK =====" >> "$OUT"
cat /root/openclaw-clients/relay-health-check.sh >> "$OUT"

echo "" >> "$OUT"
echo "===== 10. JACK HEARTBEAT.md =====" >> "$OUT"
cat /root/.openclaw/workspace/HEARTBEAT.md >> "$OUT"

echo "" >> "$OUT"
echo "===== 11. JOHN HEARTBEAT.md =====" >> "$OUT"
cat /root/openclaw-clients/john/workspace/HEARTBEAT.md >> "$OUT"

echo "" >> "$OUT"
echo "===== 12. ROSS HEARTBEAT.md =====" >> "$OUT"
cat /root/openclaw-clients/ross/workspace/HEARTBEAT.md >> "$OUT"

echo "" >> "$OUT"
echo "===== 13. JACK NOTIFY =====" >> "$OUT"
cat /root/.openclaw/workspace/notify-jack.sh 2>/dev/null >> "$OUT"

echo "" >> "$OUT"
echo "===== 14. JOHN NOTIFY =====" >> "$OUT"
cat /root/openclaw-clients/john/workspace/notify-jack.sh >> "$OUT"

echo "" >> "$OUT"
echo "===== 15. ROSS NOTIFY =====" >> "$OUT"
cat /root/openclaw-clients/ross/workspace/notify-jack.sh >> "$OUT"

echo "" >> "$OUT"
echo "===== 16. FILE RELATIONSHIPS =====" >> "$OUT"
echo "Jack BOT_CHAT.md:" >> "$OUT"
ls -la /root/.openclaw/workspace/BOT_CHAT.md >> "$OUT"
readlink -f /root/.openclaw/workspace/BOT_CHAT.md >> "$OUT"
echo "John BOT_CHAT.md:" >> "$OUT"
ls -la /root/openclaw-clients/john/workspace/BOT_CHAT.md >> "$OUT"
echo "Ross BOT_CHAT.md:" >> "$OUT"
ls -la /root/openclaw-clients/ross/workspace/BOT_CHAT.md >> "$OUT"

echo "" >> "$OUT"
echo "===== 17. RELAY STATE =====" >> "$OUT"
echo "John state: $(cat /root/openclaw-clients/.relay-state/john-relayed-lines 2>/dev/null)" >> "$OUT"
echo "Ross state: $(cat /root/openclaw-clients/.relay-state/ross-relayed-lines 2>/dev/null)" >> "$OUT"

echo "" >> "$OUT"
echo "===== 18. BOT CHAT STATES =====" >> "$OUT"
echo "Jack .bot-chat-state: $(cat /root/.openclaw/workspace/.bot-chat-state 2>/dev/null)" >> "$OUT"
echo "John .bot-chat-state: $(cat /root/openclaw-clients/john/workspace/.bot-chat-state 2>/dev/null)" >> "$OUT"
echo "Ross .bot-chat-state: $(cat /root/openclaw-clients/ross/workspace/.bot-chat-state 2>/dev/null)" >> "$OUT"

echo "" >> "$OUT"
echo "===== 19. JOHN CONFIG (agents section) =====" >> "$OUT"
python3 -c "import json; c=json.load(open('/root/openclaw-clients/john/openclaw.json')); print(json.dumps(c.get('agents',{}), indent=2))" >> "$OUT" 2>&1

echo "" >> "$OUT"
echo "===== 20. ROSS CONFIG (agents section) =====" >> "$OUT"
python3 -c "import json; c=json.load(open('/root/openclaw-clients/ross/openclaw.json')); print(json.dumps(c.get('agents',{}), indent=2))" >> "$OUT" 2>&1

echo "" >> "$OUT"
echo "===== 21. JACK CONFIG (agents section) =====" >> "$OUT"
python3 -c "import json; c=json.load(open('/root/.openclaw/openclaw.json')); print(json.dumps(c.get('agents',{}), indent=2))" >> "$OUT" 2>&1

echo "" >> "$OUT"
echo "===== 22. MONITOR HEALTH CHECK =====" >> "$OUT"
cat /root/.openclaw/workspace/monitor-health-check.sh 2>/dev/null >> "$OUT"

echo "" >> "$OUT"
echo "===== 23. RELAY LOG =====" >> "$OUT"
cat /root/openclaw-clients/relay-bridge.log >> "$OUT"

echo "" >> "$OUT"
echo "===== 24. MONITOR LOGS =====" >> "$OUT"
echo "--- Jack monitor log (last 20) ---" >> "$OUT"
tail -20 /root/.openclaw/workspace/monitor-bot-chat.log 2>/dev/null >> "$OUT"
echo "--- John monitor log (last 20) ---" >> "$OUT"
tail -20 /root/openclaw-clients/john/workspace/monitor-jack-chat.log 2>/dev/null >> "$OUT"
echo "--- Ross monitor log (last 20) ---" >> "$OUT"
tail -20 /root/openclaw-clients/ross/workspace/monitor-bot-chat.log 2>/dev/null >> "$OUT"

echo "" >> "$OUT"
echo "===== 25. JOHN BOT_CHAT_PROTOCOL.md =====" >> "$OUT"
cat /root/openclaw-clients/john/workspace/BOT_CHAT_PROTOCOL.md >> "$OUT"

echo "" >> "$OUT"
echo "===== 26. ROSS BOT_CHAT_PROTOCOL.md =====" >> "$OUT"
cat /root/openclaw-clients/ross/workspace/BOT_CHAT_PROTOCOL.md >> "$OUT"

echo "" >> "$OUT"
echo "===== 27. CURRENT BOT_CHAT FILES =====" >> "$OUT"
echo "--- John/Jack BOT_CHAT.md ---" >> "$OUT"
cat /root/openclaw-clients/john/workspace/BOT_CHAT.md >> "$OUT"
echo "" >> "$OUT"
echo "--- Ross BOT_CHAT.md ---" >> "$OUT"
cat /root/openclaw-clients/ross/workspace/BOT_CHAT.md >> "$OUT"

echo "" >> "$OUT"
echo "===== AUDIT COMPLETE =====" >> "$OUT"
echo "Dump saved to $OUT"

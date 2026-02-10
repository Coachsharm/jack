#!/bin/bash
# Clean test: John → Ross → Jack relay chain
# Clears BOT_CHAT files, writes a fresh John→Ross message, monitors response

echo "=== CLEANING BOT_CHAT FILES ==="

# Reset John's BOT_CHAT.md
cat > /root/openclaw-clients/john/workspace/BOT_CHAT.md << 'EOF'
# BOT_CHAT - Relay Bridge Test

### 2026-02-10 18:05:00 SGT - John → Ross (#1)
Ross, this is John. Message #1 for you. Please acknowledge receipt and send #2 to Jack!

⏱ 06:05:00pm SGT
EOF
chown 101000:101000 /root/openclaw-clients/john/workspace/BOT_CHAT.md

# Reset Ross's BOT_CHAT.md (clean, just header)  
cat > /root/openclaw-clients/ross/workspace/BOT_CHAT.md << 'EOF'
# BOT_CHAT - Relay Bridge Test
EOF
chown 101000:101000 /root/openclaw-clients/ross/workspace/BOT_CHAT.md

# Reset state files
echo "0" > /root/openclaw-clients/john/workspace/.bot-chat-state
echo "0" > /root/openclaw-clients/ross/workspace/.bot-chat-state
echo "0" > /root/.openclaw/workspace/.bot-chat-state
chown 101000:101000 /root/openclaw-clients/john/workspace/.bot-chat-state
chown 101000:101000 /root/openclaw-clients/ross/workspace/.bot-chat-state

# Reset relay state to BEFORE the message
echo "0" > /root/openclaw-clients/.relay-state/john-relayed-lines
echo "0" > /root/openclaw-clients/.relay-state/ross-relayed-lines

echo "=== FILES RESET ==="
echo "John BOT_CHAT: $(wc -l < /root/openclaw-clients/john/workspace/BOT_CHAT.md) lines"
echo "Ross BOT_CHAT: $(wc -l < /root/openclaw-clients/ross/workspace/BOT_CHAT.md) lines"
echo ""
echo "=== WAITING FOR RELAY TO PICK UP (10 seconds) ==="
sleep 10

echo "=== RELAY LOG ==="
tail -10 /root/openclaw-clients/relay-bridge.log

echo ""
echo "=== ROSS BOT_CHAT AFTER RELAY ==="
cat /root/openclaw-clients/ross/workspace/BOT_CHAT.md

echo ""
echo "=== NOW WAIT 2-3 MINUTES FOR ROSS TO RESPOND VIA HEARTBEAT ==="
echo "Check: tail -20 /root/openclaw-clients/ross/workspace/BOT_CHAT.md"
echo "Check: docker logs openclaw-ross --since 3m --tail 30"

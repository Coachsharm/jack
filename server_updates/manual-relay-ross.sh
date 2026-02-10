#!/bin/bash
# Manual relay of Ross's #1-4 to John/Jack's file
# These were missed due to a race condition in the relay

echo "Manually relaying Ross's #1-4 to John/Jack's BOT_CHAT..."

# Get Ross's messages (lines 3-30, which contain #1-4)
ROSS_MSGS=$(sed -n '3,30p' /root/openclaw-clients/ross/workspace/BOT_CHAT.md)

# Set lock to prevent monitor double-wake
touch /root/openclaw-clients/.relay-state/relay-writing-john

# Append to John's BOT_CHAT
printf "\n%s\n" "$ROSS_MSGS" >> /root/openclaw-clients/john/workspace/BOT_CHAT.md
chown 101000:101000 /root/openclaw-clients/john/workspace/BOT_CHAT.md

# Update John state
JOHN_LINES=$(wc -l < /root/openclaw-clients/john/workspace/BOT_CHAT.md | tr -d '[:space:]')
echo "$JOHN_LINES" > /root/openclaw-clients/.relay-state/john-relayed-lines

sleep 1
rm -f /root/openclaw-clients/.relay-state/relay-writing-john

# Wake Jack
openclaw system event \
    --text "New BOT_CHAT message from Ross. FOLLOW HEARTBEAT.md: Read BOT_CHAT.md, write reply to BOT_CHAT.md, post to Telegram -5213725265, update state. Ross sent #1-4, your turn for #5-8." --mode now &

echo "Done! Ross #1-4 relayed to Jack. Jack woken."
echo "John state updated to $JOHN_LINES"

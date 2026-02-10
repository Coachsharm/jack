#!/bin/bash
# Ross (Docker) → Jack notification
# Runs INSIDE Ross's Docker container
MSG="${1:-Check BOT_CHAT}"

# Use openclaw CLI (runs inside container)
# Target Jack's Telegram group session
openclaw agent \
  --message "$MSG" \
  --session-id "agent:main:telegram:group:-5213725265" \
  --timeout 120 &

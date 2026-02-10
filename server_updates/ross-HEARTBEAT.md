# HEARTBEAT

**MANDATORY: DO NOT NARRATE. EXECUTE COMMANDS ONLY.**

## Step 1: Check State
```bash
cat ~/.openclaw/workspace/.bot-chat-state 2>/dev/null || echo "0"
```

## Step 2: Check Current Messages
```bash
tail -20 ~/.openclaw/workspace/BOT_CHAT.md
```

## Step 3: Compare and Act

**IF latest message number > state number AND message is NOT from Ross:**

Execute ALL of these commands IN ORDER:

### 3a. Write your reply to BOT_CHAT.md
```bash
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
cat >> ~/.openclaw/workspace/BOT_CHAT.md << EOF

### ${TIMESTAMP} SGT - Ross → [TARGET] (#[NEXT_NUMBER])
[Your reply here]

⏱ $(date '+%I:%M:%S%P') SGT
EOF
```

### 3b. Post to Telegram (MANDATORY - Coach MUST see this)
```bash
message --action send --channel telegram --target -5213725265 --message "📋 Ross → [TARGET] (#[N]): [brief summary of your reply]"
```

### 3c. Update state file
```bash
echo "[N]" > ~/.openclaw/workspace/.bot-chat-state
```

**IF no new messages (state is current):**
Reply ONLY: `NO_REPLY`

## CRITICAL RULES
- **EXECUTE the bash commands above. Do NOT just think about them.**
- **Step 3b is MANDATORY.** If you skip the Telegram post, Coach cannot see your reply. This is a failure.
- **Every response must be written to BOT_CHAT.md AND posted to Telegram. Both. Always.**

**NO TALKING. NO NARRATING. JUST EXECUTE THE COMMANDS.**

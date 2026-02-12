# HEARTBEAT

**ZERO NARRATION. ZERO ANALYSIS. ZERO EXPLANATION.**

**Your ENTIRE response must be ONLY commands or the single word NO_REPLY. Nothing else. Ever.**

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
Reply with ONLY this exact word, nothing before it, nothing after it:
HEARTBEAT_OK

## FORBIDDEN — NEVER DO THESE:
- ❌ "State is 17" — DO NOT report the state number
- ❌ "The latest message is from..." — DO NOT describe what you see
- ❌ "I don't see any new messages" — DO NOT explain your reasoning
- ❌ "Since there's no new message..." — DO NOT justify your decision
- ❌ "The system said..." — DO NOT narrate what happened
- ❌ ANY text that is not a bash command or HEARTBEAT_OK

**Coach sees EVERYTHING you write. If you narrate, Coach reads your internal analysis. That is embarrassing and confusing. STOP IT.**

Your output is EITHER:
1. Bash commands (Steps 3a + 3b + 3c) — if there's a new message to respond to
2. The single word `HEARTBEAT_OK` — if there's nothing new

**NOTHING ELSE. NOT ONE EXTRA WORD.**

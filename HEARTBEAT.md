# HEARTBEAT

**MANDATORY: DO NOT NARRATE.**

## 0. KILL SWITCH CHECK
`if [ -f /root/.openclaw/workspace/.BOT_CHAT_DISABLED ]; then exit 0; fi`

## 1. BOT_CHAT Check
1. Check state: `cat /root/.openclaw/workspace/.bot-chat-state 2>/dev/null || echo "0"`
2. Read BOT_CHAT: `tail -30 /root/openclaw-clients/john/workspace/BOT_CHAT.md`
3. Check if there are new messages (number > state OR newer timestamp)
4. If new messages exist:
   - **Check message age:** How recent is the latest message?
   - **If < 10 seconds old:** Wait 5 seconds, re-check for message burst
   - **Read and decide:** Is this relevant to Jack?
   - Relevant = addressed to Jack, "all", "guys", "everyone", "staff", "stuff" (voice error for staff), or Jack can add value/insight
   - If relevant: Respond (write to BOT_CHAT, post to Telegram, wake target)
   - Update state: `echo "N" > /root/.openclaw/workspace/.bot-chat-state`
5. Else: continue to next check

**JUDGMENT CALL:** Use "Know When to Speak" rules from AGENTS.md - respond when mentioned, can add value, something funny/witty, or correcting misinfo.

**MESSAGE BURST:** Let people finish their thought before responding. If very recent message, wait to see if more coming.

## 2. Body Thrive Fitness Group (WhatsApp) — MANDATORY
**Group JID:** 6591090995-1377865458@g.us
**Instructions:** `/root/.openclaw/workspace/whatsapp-groups/body-thrive-fitness.md`

Check this WhatsApp group for unresponded attendance list updates. When a client posts an updated list:
- Read `body-thrive-fitness.md` for response style, guardrails, and examples
- Acknowledge their update (who signed up, which session)
- Sign off with a fresh creative signature as "Jack"
- Notify HQ GuruFitness group (6591090995-1567242884@g.us) about the update
- **NEVER skip this.** Coach expects every attendance update to be acknowledged.

## 3. Rate Limit Monitor (every ~30min)
Check file: `cat /root/.openclaw/workspace/.last-usage-check 2>/dev/null || echo "0"`
If >30 min since last check:
1. Run: `openclaw status --usage 2>&1 | grep -E "left|error|403"`
2. If ANY line shows ≤10% left → send Auth Status Panel to Coach (procedures/auth-switch.md)
3. Update: `date +%s > /root/.openclaw/workspace/.last-usage-check`

## 4. If nothing needs attention
Reply ONLY: `NO_REPLY`

**NO TALKING. JUST DO.**


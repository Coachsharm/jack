#!/bin/bash
# =============================================================================
# BOT_CHAT Relay Bridge — Host-Side (v4)
# =============================================================================
# PURPOSE: Bridges John/Jack's shared BOT_CHAT.md ←→ Ross's separate BOT_CHAT.md
#
# v4 CHANGES:
#   - Fixed integer expression bug (sanitize grep output)
#   - Added relay lock files to prevent double-waking
#   - Monitors skip wake when relay lock is present
# =============================================================================

JOHN_BOTCHAT="/root/openclaw-clients/john/workspace/BOT_CHAT.md"
ROSS_BOTCHAT="/root/openclaw-clients/ross/workspace/BOT_CHAT.md"
RELAY_LOG="/root/openclaw-clients/relay-bridge.log"
RELAY_STATE_DIR="/root/openclaw-clients/.relay-state"
JOHN_STATE="$RELAY_STATE_DIR/john-relayed-lines"
ROSS_STATE="$RELAY_STATE_DIR/ross-relayed-lines"
# Lock files — monitors check these to avoid double-waking
JOHN_LOCK="$RELAY_STATE_DIR/relay-writing-john"
ROSS_LOCK="$RELAY_STATE_DIR/relay-writing-ross"

mkdir -p "$RELAY_STATE_DIR"

# Initialize state files to current line counts (skip existing content)
if [ ! -f "$JOHN_STATE" ]; then
    wc -l < "$JOHN_BOTCHAT" 2>/dev/null | tr -d '[:space:]' > "$JOHN_STATE"
fi
if [ ! -f "$ROSS_STATE" ]; then
    wc -l < "$ROSS_BOTCHAT" 2>/dev/null | tr -d '[:space:]' > "$ROSS_STATE"
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$RELAY_LOG"
}

log "===== RELAY BRIDGE v4 STARTED ====="
log "John file: $JOHN_BOTCHAT"
log "Ross file: $ROSS_BOTCHAT"

LOOP_COUNT=0

while true; do
    # =============================================
    # IMPORTANT: Process Ross→Jack/John FIRST
    # This ensures we catch Ross's outbound messages
    # BEFORE we write to Ross's file (which would
    # advance the state past Ross's own messages)
    # =============================================
    
    # =============================================
    # Ross → Jack/John (CHECK FIRST)
    # =============================================
    ROSS_LAST=$(cat "$ROSS_STATE" 2>/dev/null | tr -d '[:space:]')
    [ -z "$ROSS_LAST" ] && ROSS_LAST=0
    ROSS_CURRENT=$(wc -l < "$ROSS_BOTCHAT" 2>/dev/null | tr -d '[:space:]')
    [ -z "$ROSS_CURRENT" ] && ROSS_CURRENT=0
    
    # Handle file truncation (file was cleared/reset)
    if [ "$ROSS_CURRENT" -lt "$ROSS_LAST" ] 2>/dev/null; then
        log "RESET: Ross file truncated ($ROSS_LAST → $ROSS_CURRENT lines), resetting state"
        ROSS_LAST=0
        echo "0" > "$ROSS_STATE"
    fi
    
    if [ "$ROSS_CURRENT" -gt "$ROSS_LAST" ] 2>/dev/null; then
        NEW_LINES=$(tail -n "+$((ROSS_LAST + 1))" "$ROSS_BOTCHAT")
        
        HEADER_LINES=$(echo "$NEW_LINES" | grep '###' || true)
        MATCHES_JACK=0
        if [ -n "$HEADER_LINES" ]; then
            MATCHES_JACK=$(echo "$HEADER_LINES" | grep -ciE 'Jack|John|ALL' 2>/dev/null || true)
            [ -z "$MATCHES_JACK" ] && MATCHES_JACK=0
        fi
        
        if [ "$MATCHES_JACK" -gt 0 ] 2>/dev/null; then
            log "RELAY: Ross → Jack/John detected (lines $ROSS_LAST → $ROSS_CURRENT)"
            
            # Set lock BEFORE writing (tells Jack's monitor to skip this change)
            touch "$JOHN_LOCK"
            
            # Append to John's file (Jack reads via symlink)
            printf "\n%s\n" "$NEW_LINES" >> "$JOHN_BOTCHAT"
            chown 101000:101000 "$JOHN_BOTCHAT" 2>/dev/null
            
            # Update John state to prevent echo-back
            JOHN_NOW=$(wc -l < "$JOHN_BOTCHAT" 2>/dev/null | tr -d '[:space:]')
            echo "$JOHN_NOW" > "$JOHN_STATE"
            
            # Small delay then remove lock
            sleep 1
            rm -f "$JOHN_LOCK"
            
            # Wake target(s)
            if echo "$HEADER_LINES" | grep -qiE 'Jack|ALL'; then
                openclaw system event \
                    --text "New BOT_CHAT message from Ross. FOLLOW HEARTBEAT.md: Read BOT_CHAT.md, write reply, post to Telegram -5213725265, update state. ALL STEPS MANDATORY." --mode now >> "$RELAY_LOG" 2>&1 &
                log "RELAY: Woke Jack (native)"
            fi
            if echo "$HEADER_LINES" | grep -qiE 'John|ALL'; then
                docker exec openclaw-john openclaw system event \
                    --text "New BOT_CHAT message from Ross. FOLLOW HEARTBEAT.md: Read BOT_CHAT.md, write reply, post to Telegram -5213725265, update state. ALL STEPS MANDATORY." --mode now >> "$RELAY_LOG" 2>&1 &
                log "RELAY: Woke John (Docker)"
            fi
            
            log "RELAY: Relayed to John/Jack"
        else
            log "SKIP: Ross file +$((ROSS_CURRENT - ROSS_LAST)) lines, not for Jack/John"
        fi
        
        # Update Ross state AFTER processing outbound
        echo "$ROSS_CURRENT" > "$ROSS_STATE"
    fi
    
    # =============================================
    # John/Jack → Ross (CHECK SECOND)
    # =============================================
    JOHN_LAST=$(cat "$JOHN_STATE" 2>/dev/null | tr -d '[:space:]')
    [ -z "$JOHN_LAST" ] && JOHN_LAST=0
    JOHN_CURRENT=$(wc -l < "$JOHN_BOTCHAT" 2>/dev/null | tr -d '[:space:]')
    [ -z "$JOHN_CURRENT" ] && JOHN_CURRENT=0
    
    # Handle file truncation (file was cleared/reset)
    if [ "$JOHN_CURRENT" -lt "$JOHN_LAST" ] 2>/dev/null; then
        log "RESET: John file truncated ($JOHN_LAST → $JOHN_CURRENT lines), resetting state"
        JOHN_LAST=0
        echo "0" > "$JOHN_STATE"
    fi
    
    if [ "$JOHN_CURRENT" -gt "$JOHN_LAST" ] 2>/dev/null; then
        NEW_LINES=$(tail -n "+$((JOHN_LAST + 1))" "$JOHN_BOTCHAT")
        
        # Check if any ### header line mentions Ross or ALL
        HEADER_LINES=$(echo "$NEW_LINES" | grep '###' || true)
        MATCHES_ROSS=0
        if [ -n "$HEADER_LINES" ]; then
            MATCHES_ROSS=$(echo "$HEADER_LINES" | grep -ciE 'Ross|ALL' 2>/dev/null || true)
            [ -z "$MATCHES_ROSS" ] && MATCHES_ROSS=0
        fi
        
        if [ "$MATCHES_ROSS" -gt 0 ] 2>/dev/null; then
            log "RELAY: John/Jack → Ross detected (lines $JOHN_LAST → $JOHN_CURRENT)"
            
            # IMPORTANT: Read Ross's current line count BEFORE writing
            # This preserves any lines Ross wrote between our polls
            ROSS_BEFORE_WRITE=$(wc -l < "$ROSS_BOTCHAT" 2>/dev/null | tr -d '[:space:]')
            
            # Set lock BEFORE writing (tells Ross's monitor to skip this change)
            touch "$ROSS_LOCK"
            
            # Append to Ross's file
            printf "\n%s\n" "$NEW_LINES" >> "$ROSS_BOTCHAT"
            chown 101000:101000 "$ROSS_BOTCHAT" 2>/dev/null
            
            # Update Ross state to the NEW total (after our write)
            # This is safe because we already processed Ross→Jack above
            ROSS_NOW=$(wc -l < "$ROSS_BOTCHAT" 2>/dev/null | tr -d '[:space:]')
            echo "$ROSS_NOW" > "$ROSS_STATE"
            
            # Small delay then remove lock
            sleep 1
            rm -f "$ROSS_LOCK"
            
            # Wake Ross with EXPLICIT instructions
            docker exec openclaw-ross openclaw system event \
                --text "New BOT_CHAT message for you. FOLLOW HEARTBEAT.md NOW: 1) Read BOT_CHAT.md 2) Write your reply to BOT_CHAT.md 3) Post summary to Telegram group -5213725265 using message tool 4) Update .bot-chat-state. ALL STEPS MANDATORY." --mode now >> "$RELAY_LOG" 2>&1 &
            
            log "RELAY: Relayed to Ross + woke Ross"
        else
            log "SKIP: John file +$((JOHN_CURRENT - JOHN_LAST)) lines, not for Ross"
        fi
        
        echo "$JOHN_CURRENT" > "$JOHN_STATE"
    fi
    
    # Trim log every ~5 min
    LOOP_COUNT=$((LOOP_COUNT + 1))
    if [ $((LOOP_COUNT % 150)) -eq 0 ]; then
        LOG_LINES=$(wc -l < "$RELAY_LOG" 2>/dev/null | tr -d '[:space:]')
        if [ "${LOG_LINES:-0}" -gt 500 ]; then
            tail -200 "$RELAY_LOG" > "$RELAY_LOG.tmp" && mv "$RELAY_LOG.tmp" "$RELAY_LOG"
        fi
    fi
    
    sleep 2
done

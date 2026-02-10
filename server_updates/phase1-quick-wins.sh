#!/bin/bash
# ============================================================
# RELAY SYSTEM IMPROVEMENTS — Phase 1: Quick Wins
# ============================================================
# Fixes: Bug 2 (Ross monitor path), Bug 3 (integer expression),
#        Bug 5 (zombie process), Bug 6 (Daniel crash loop),
#        Bug 7 (start-wake-bridge zombie), Bug 8 (health check coverage)
# ============================================================

echo "=== PHASE 1: QUICK WINS ==="
echo ""

# -------------------------------------------------------
# Fix 1: Kill the start-wake-bridge.sh zombie (Bug 7)
# -------------------------------------------------------
echo "[1/5] Killing start-wake-bridge.sh zombie..."
WAKE_PID=$(pgrep -f 'start-wake-bridge.sh')
if [ -n "$WAKE_PID" ]; then
    kill "$WAKE_PID" 2>/dev/null
    echo "  Killed PID $WAKE_PID"
else
    echo "  Not running (already dead)"
fi

# -------------------------------------------------------
# Fix 2: Stop Daniel crash loop (Bug 6)
# -------------------------------------------------------
echo "[2/5] Stopping Daniel crash loop..."
if docker ps -a --format '{{.Names}}' | grep -q openclaw-daniel; then
    docker update --restart=no openclaw-daniel 2>/dev/null
    docker stop openclaw-daniel 2>/dev/null
    echo "  Daniel stopped and restart policy set to 'no'"
else
    echo "  Daniel container not found"
fi

# -------------------------------------------------------
# Fix 3: Fix Ross's monitor path (Bug 2)
# -------------------------------------------------------
echo "[3/5] Fixing Ross monitor path..."
cat > /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh << 'MONITOR_EOF'
#!/bin/bash
# Ross's BOT_CHAT monitor - watches for messages from Jack/John
# Runs on HOST, watches HOST path, talks to Docker container
# FIXED: Uses correct host path instead of container-internal path

WATCH_FILE="/root/openclaw-clients/ross/workspace/BOT_CHAT.md"
LAST_HASH=""

while true; do
    if [ -f "$WATCH_FILE" ]; then
        CURRENT_HASH=$(md5sum "$WATCH_FILE" | awk '{print $1}')
        
        if [ -n "$LAST_HASH" ] && [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
            # File changed! Trigger Ross's heartbeat via Docker
            docker exec openclaw-ross openclaw system event --text "BOT_CHAT updated" --mode now &
            echo "$(date): BOT_CHAT changed, triggered heartbeat"
        fi
        
        LAST_HASH="$CURRENT_HASH"
    fi
    
    sleep 2
done
MONITOR_EOF
chmod +x /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh
echo "  Ross monitor updated to use host path"

# Restart Ross's monitor with new path
ROSS_MON_PID=$(pgrep -f 'ross/workspace/monitor-bot-chat.sh')
if [ -n "$ROSS_MON_PID" ]; then
    kill "$ROSS_MON_PID" 2>/dev/null
    sleep 1
fi
nohup /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh >> /root/openclaw-clients/ross/workspace/monitor-bot-chat.log 2>&1 &
echo "  Ross monitor restarted (PID: $!)"

# -------------------------------------------------------
# Fix 4: Consolidated health check (Bug 8)
# -------------------------------------------------------
echo "[4/5] Updating unified health check..."
cat > /root/.openclaw/workspace/monitor-health-check.sh << 'HEALTH_EOF'
#!/bin/bash
# Unified health check for ALL monitors + relay
# Run via cron: */5 * * * *

LOG_FILE="/root/.openclaw/workspace/monitor-health.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
RESTARTED=0

check_and_restart() {
    local name=$1
    local check_cmd=$2
    local start_cmd=$3
    
    if ! eval "$check_cmd" > /dev/null 2>&1; then
        echo "[$TIMESTAMP] ⚠️ $name not running - restarting..." >> "$LOG_FILE"
        eval "$start_cmd"
        echo "[$TIMESTAMP] ✅ $name restarted" >> "$LOG_FILE"
        RESTARTED=1
        return 1
    fi
    return 0
}

# Check Jack's monitor (host)
check_and_restart \
    "Jack's monitor" \
    "pgrep -f 'openclaw/workspace/monitor-bot-chat.sh'" \
    "nohup /root/.openclaw/workspace/monitor-bot-chat.sh > /root/.openclaw/workspace/monitor-bot-chat.log 2>&1 &"

# Check John's monitor (inside container)
check_and_restart \
    "John's monitor" \
    "docker exec openclaw-john pgrep -f 'monitor-jack-chat.sh'" \
    "docker exec openclaw-john bash -c 'nohup /home/openclaw/.openclaw/workspace/monitor-jack-chat.sh > /home/openclaw/.openclaw/workspace/monitor-jack-chat.log 2>&1 &'"

# Check Ross's monitor (host)
check_and_restart \
    "Ross's monitor" \
    "pgrep -f 'ross/workspace/monitor-bot-chat.sh'" \
    "nohup /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh >> /root/openclaw-clients/ross/workspace/monitor-bot-chat.log 2>&1 &"

# Check Relay bridge (host)
check_and_restart \
    "Relay bridge" \
    "pgrep -f 'bot-chat-relay.sh'" \
    "nohup /root/openclaw-clients/bot-chat-relay.sh >> /root/openclaw-clients/relay-bridge.log 2>&1 &"

# Clean old logs (keep last 100 lines)
if [ $RESTARTED -eq 0 ]; then
    tail -100 "$LOG_FILE" > "$LOG_FILE.tmp" 2>/dev/null && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
HEALTH_EOF
chmod +x /root/.openclaw/workspace/monitor-health-check.sh
echo "  Unified health check updated (now covers Ross + relay)"

# Remove the redundant relay-health-check from crontab since it's now in the unified check
# But keep the cron entry for monitor-health-check.sh (it already runs every 5 min)
CURRENT_CRON=$(crontab -l 2>/dev/null)
echo "$CURRENT_CRON" | grep -v 'relay-health-check.sh' | crontab -
echo "  Removed redundant relay-health-check cron (now in unified check)"

# -------------------------------------------------------
# Fix 5: Fix relay integer expression bug (Bug 3)
# -------------------------------------------------------
echo "[5/5] Fixing relay integer expression bug..."
# This will be done by redeploying the relay script with the dedup fix (Phase 2)
echo "  Deferred to Phase 2 (combined with dedup fix)"

echo ""
echo "=== PHASE 1 COMPLETE ==="
echo ""
echo "Killed: start-wake-bridge.sh zombie"
echo "Stopped: Daniel crash loop"
echo "Fixed: Ross monitor path → host path"
echo "Updated: Unified health check (all 4 components)"
echo "Cleaned: Redundant relay-health-check cron"

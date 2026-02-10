#!/bin/bash
# stale-lock-cleaner.sh - Remove stale session lock files
# Runs every 5 minutes via cron
# Prevents cascading "session file locked" failures
#
# Created: 2026-02-10 by Antigravity
# Location: /root/.openclaw/cron/stale-lock-cleaner.sh

SESSIONS_DIR="/root/.openclaw/agents/main/sessions"
LOCK_MAX_AGE_SECONDS=30

# Find and remove lock files older than 30 seconds
found=0
while IFS= read -r -d '' lockfile; do
    lock_age=$(( $(date +%s) - $(stat -c %Y "$lockfile") ))
    if [ "$lock_age" -gt "$LOCK_MAX_AGE_SECONDS" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [LOCK-CLEANER] Removed stale lock: $(basename "$lockfile") (age: ${lock_age}s)" >> /var/log/openclaw-session-cleanup.log
        rm -f "$lockfile"
        found=$((found + 1))
    fi
done < <(find "$SESSIONS_DIR" -name "*.lock" -print0 2>/dev/null)

# Only log if we actually found something (keep log clean)
if [ "$found" -gt 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [LOCK-CLEANER] Removed $found stale lock(s)" >> /var/log/openclaw-session-cleanup.log
fi

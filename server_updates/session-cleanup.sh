#!/bin/bash
# session-cleanup.sh - Automated Session Maintenance for Jack
# Prevents session lock timeouts by keeping session files manageable
#
# Created: 2026-02-10 by Antigravity
# Runs: Daily at 4 AM SGT (via cron)
# Location: /root/.openclaw/cron/session-cleanup.sh

set -euo pipefail

SESSIONS_DIR="/root/.openclaw/agents/main/sessions"
ARCHIVE_DIR="/root/.openclaw/agents/main/sessions-archive"
LOG_FILE="/var/log/openclaw-session-cleanup.log"
SESSIONS_JSON="${SESSIONS_DIR}/sessions.json"

# Thresholds
MAX_FILE_AGE_DAYS=3          # Delete .deleted files older than 3 days
MAX_INACTIVE_DAYS=5          # Archive sessions inactive >5 days
MAX_SESSION_SIZE_MB=3        # Warn about sessions larger than 3MB
LOCK_MAX_AGE_SECONDS=60      # Remove lock files older than 60 seconds

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SESSION-CLEANUP] $*" | tee -a "$LOG_FILE"
}

log "=== Session Cleanup Started ==="

# Ensure archive directory exists
mkdir -p "$ARCHIVE_DIR"

# ─────────────────────────────────────────────
# STEP 1: Remove stale .lock files
# These are the direct cause of "session file locked" errors
# ─────────────────────────────────────────────
STALE_LOCKS=0
while IFS= read -r -d '' lockfile; do
    lock_age=$(( $(date +%s) - $(stat -c %Y "$lockfile") ))
    if [ "$lock_age" -gt "$LOCK_MAX_AGE_SECONDS" ]; then
        log "Removing stale lock: $(basename "$lockfile") (age: ${lock_age}s)"
        rm -f "$lockfile"
        STALE_LOCKS=$((STALE_LOCKS + 1))
    fi
done < <(find "$SESSIONS_DIR" -name "*.lock" -print0 2>/dev/null)
log "Step 1: Removed $STALE_LOCKS stale lock files"

# ─────────────────────────────────────────────
# STEP 2: Remove .deleted session files
# OpenClaw marks these for deletion but doesn't always clean up
# ─────────────────────────────────────────────
DELETED_COUNT=0
DELETED_SIZE=0
while IFS= read -r -d '' delfile; do
    fsize=$(stat -c %s "$delfile" 2>/dev/null || echo 0)
    DELETED_SIZE=$((DELETED_SIZE + fsize))
    log "Removing deleted session: $(basename "$delfile") ($(numfmt --to=iec $fsize))"
    rm -f "$delfile"
    DELETED_COUNT=$((DELETED_COUNT + 1))
done < <(find "$SESSIONS_DIR" -name "*.deleted.*" -print0 2>/dev/null)
log "Step 2: Removed $DELETED_COUNT deleted files (freed $(numfmt --to=iec $DELETED_SIZE))"

# ─────────────────────────────────────────────
# STEP 3: Remove old .bak session files
# ─────────────────────────────────────────────
BAK_COUNT=0
while IFS= read -r -d '' bakfile; do
    log "Removing session backup: $(basename "$bakfile")"
    rm -f "$bakfile"
    BAK_COUNT=$((BAK_COUNT + 1))
done < <(find "$SESSIONS_DIR" -name "*.bak*" -mtime +$MAX_FILE_AGE_DAYS -print0 2>/dev/null)
log "Step 3: Removed $BAK_COUNT old backup files"

# ─────────────────────────────────────────────
# STEP 4: Archive large, inactive sessions
# Moves sessions >5 days old AND >500KB to archive
# (Won't touch sessions.json or active sessions)
# ─────────────────────────────────────────────
ARCHIVED_COUNT=0
ARCHIVED_SIZE=0
while IFS= read -r -d '' session; do
    basename=$(basename "$session")
    # Never archive sessions.json or probe files
    [[ "$basename" == "sessions.json" ]] && continue
    [[ "$basename" == probe-* ]] && continue

    fsize=$(stat -c %s "$session" 2>/dev/null || echo 0)
    log "Archiving inactive session: $basename ($(numfmt --to=iec $fsize))"
    mv "$session" "$ARCHIVE_DIR/"
    ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
    ARCHIVED_SIZE=$((ARCHIVED_SIZE + fsize))
done < <(find "$SESSIONS_DIR" -maxdepth 1 -name "*.jsonl" -mtime +$MAX_INACTIVE_DAYS -size +500k -print0 2>/dev/null)
log "Step 4: Archived $ARCHIVED_COUNT large inactive sessions ($(numfmt --to=iec $ARCHIVED_SIZE))"

# ─────────────────────────────────────────────
# STEP 5: Report on oversized active sessions (warning only)
# ─────────────────────────────────────────────
OVERSIZED=0
while IFS= read -r -d '' bigfile; do
    basename=$(basename "$bigfile")
    fsize=$(stat -c %s "$bigfile" 2>/dev/null || echo 0)
    fsize_mb=$((fsize / 1048576))
    if [ "$fsize_mb" -ge "$MAX_SESSION_SIZE_MB" ]; then
        log "WARNING: Large active session: $basename (${fsize_mb}MB) — may cause lock timeouts"
        OVERSIZED=$((OVERSIZED + 1))
    fi
done < <(find "$SESSIONS_DIR" -maxdepth 1 -name "*.jsonl" -print0 2>/dev/null)

# ─────────────────────────────────────────────
# STEP 6: Clean up old archived sessions (>14 days)
# ─────────────────────────────────────────────
OLD_ARCHIVE=0
while IFS= read -r -d '' oldfile; do
    log "Removing old archived session: $(basename "$oldfile")"
    rm -f "$oldfile"
    OLD_ARCHIVE=$((OLD_ARCHIVE + 1))
done < <(find "$ARCHIVE_DIR" -name "*.jsonl" -mtime +14 -print0 2>/dev/null)
log "Step 6: Removed $OLD_ARCHIVE old archived sessions"

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
REMAINING=$(find "$SESSIONS_DIR" -maxdepth 1 -name "*.jsonl" 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh "$SESSIONS_DIR" 2>/dev/null | cut -f1)

log "=== Cleanup Summary ==="
log "  Lock files removed:    $STALE_LOCKS"
log "  Deleted files removed: $DELETED_COUNT"
log "  Backups removed:       $BAK_COUNT"
log "  Sessions archived:     $ARCHIVED_COUNT"
log "  Old archives removed:  $OLD_ARCHIVE"
log "  Oversized warnings:    $OVERSIZED"
log "  Remaining sessions:    $REMAINING"
log "  Total session size:    $TOTAL_SIZE"
log "=== Session Cleanup Complete ==="

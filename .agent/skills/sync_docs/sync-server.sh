#!/bin/bash
# OpenClaw Documentation Auto-Sync Script
# Created: 2026-02-08
# Runs weekly to keep documentation fresh

set -e

DOCS_DIR="/home/node/OpenClaw_Docs"
SCRIPT_DIR="/root/openclaw-docs-sync"
LOG_FILE="$SCRIPT_DIR/sync.log"
TIMESTAMP_FILE="$DOCS_DIR/LAST_UPDATED.txt"

# Ensure directories exist
mkdir -p "$DOCS_DIR"
mkdir -p "$SCRIPT_DIR"

# Log start
echo "=== OpenClaw Docs Sync Started: $(date '+%Y-%m-%d %H:%M:%S %Z') ===" >> "$LOG_FILE"

# Change to script directory
cd "$SCRIPT_DIR"

# Run the sync (expects sync.js and node_modules to be in this directory)
if node sync.js >> "$LOG_FILE" 2>&1; then
    echo "Sync completed successfully" >> "$LOG_FILE"
    
    # Update timestamp file
    cat > "$TIMESTAMP_FILE" << EOF
Last synced: $(date '+%Y-%m-%d %H:%M:%S %Z')
Source: https://docs.openclaw.ai
Status: Fresh
EOF
    
    echo "=== Sync Completed Successfully ===" >> "$LOG_FILE"
    exit 0
else
    echo "ERROR: Sync failed" >> "$LOG_FILE"
    echo "=== Sync Failed ===" >> "$LOG_FILE"
    exit 1
fi

#!/bin/bash
# Pre-improvement backup of ALL bots + relay system
# Date: 2026-02-10 19:02 SGT
TIMESTAMP="10feb26-0702pm"
BACKUP_DIR="/root/backups/pre-relay-improvements-${TIMESTAMP}"

echo "=== CREATING PRE-IMPROVEMENT BACKUP ==="
echo "Destination: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# 1. Jack (native) — config + workspace
echo "[1/6] Backing up Jack (native)..."
mkdir -p "$BACKUP_DIR/jack-native"
cp -r /root/.openclaw/openclaw.json "$BACKUP_DIR/jack-native/"
cp -r /root/.openclaw/workspace/ "$BACKUP_DIR/jack-native/workspace/"
echo "  Jack config + workspace backed up"

# 2. John (Docker) — host-side workspace + config
echo "[2/6] Backing up John (Docker host-side)..."
mkdir -p "$BACKUP_DIR/john-docker"
cp -r /root/openclaw-clients/john/openclaw.json "$BACKUP_DIR/john-docker/"
cp -r /root/openclaw-clients/john/workspace/ "$BACKUP_DIR/john-docker/workspace/"
echo "  John config + workspace backed up"

# 3. Ross (Docker) — host-side workspace + config
echo "[3/6] Backing up Ross (Docker host-side)..."
mkdir -p "$BACKUP_DIR/ross-docker"
cp -r /root/openclaw-clients/ross/openclaw.json "$BACKUP_DIR/ross-docker/"
cp -r /root/openclaw-clients/ross/workspace/ "$BACKUP_DIR/ross-docker/workspace/"
echo "  Ross config + workspace backed up"

# 4. Relay bridge + health check
echo "[4/6] Backing up relay system..."
mkdir -p "$BACKUP_DIR/relay-system"
cp /root/openclaw-clients/bot-chat-relay.sh "$BACKUP_DIR/relay-system/"
cp /root/openclaw-clients/relay-health-check.sh "$BACKUP_DIR/relay-system/"
cp /root/openclaw-clients/relay-bridge.log "$BACKUP_DIR/relay-system/"
cp -r /root/openclaw-clients/.relay-state/ "$BACKUP_DIR/relay-system/.relay-state/"
echo "  Relay system backed up"

# 5. Monitor scripts + health check
echo "[5/6] Backing up monitor scripts..."
mkdir -p "$BACKUP_DIR/monitors"
cp /root/.openclaw/workspace/monitor-bot-chat.sh "$BACKUP_DIR/monitors/jack-monitor-bot-chat.sh"
cp /root/.openclaw/workspace/monitor-health-check.sh "$BACKUP_DIR/monitors/monitor-health-check.sh"
cp /root/.openclaw/workspace/start-monitors.sh "$BACKUP_DIR/monitors/start-monitors.sh"
cp /root/.openclaw/workspace/start-wake-bridge.sh "$BACKUP_DIR/monitors/start-wake-bridge.sh" 2>/dev/null
cp /root/openclaw-clients/ross/workspace/monitor-bot-chat.sh "$BACKUP_DIR/monitors/ross-monitor-bot-chat.sh"
echo "  Monitor scripts backed up"

# 6. Crontab
echo "[6/6] Backing up crontab..."
crontab -l > "$BACKUP_DIR/crontab-backup.txt" 2>/dev/null
echo "  Crontab backed up"

# Summary
echo ""
echo "=== BACKUP COMPLETE ==="
du -sh "$BACKUP_DIR"
echo ""
echo "Contents:"
find "$BACKUP_DIR" -maxdepth 2 -type f | wc -l
echo " files backed up"
find "$BACKUP_DIR" -maxdepth 2 -type d | sort

#!/bin/bash
# OpenClaw Health Check — writes status to /var/www/html/health.json
# Runs via cron every 2 minutes

OUT=/var/www/html/health.json
TMP=/tmp/health_tmp.json

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
UPTIME=$(uptime -p 2>/dev/null || echo unknown)

# Check OpenClaw process
OC_PID=$(pgrep -f 'openclaw' | head -1)
if [ -n "$OC_PID" ]; then
    OC_STATUS="running"
else
    OC_STATUS="stopped"
fi

# Check gateway port (3000 is default)
if ss -tlnp | grep -q ':3000'; then
    GW_STATUS="listening"
else
    GW_STATUS="down"
fi

# Disk & memory
DISK_USED=$(df -h / | awk 'NR==2{print $5}')
MEM_USED=$(free | awk '/Mem:/{printf "%.0f", $3/$2*100}')

cat > "$TMP" << EOF
{
  "status": "$OC_STATUS",
  "gateway": "$GW_STATUS",
  "timestamp": "$TIMESTAMP",
  "uptime": "$UPTIME",
  "disk_percent": "$DISK_USED",
  "mem_percent": "${MEM_USED}%",
  "pid": "$OC_PID"
}
EOF
mv "$TMP" "$OUT"

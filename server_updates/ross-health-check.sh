#!/bin/bash
# Ross Health Check — runs hourly
# UPDATED: 2026-02-10 — Ross now runs in Docker
# Location: /root/openclaw-clients/ross/ross-health-check.sh
# Reports: Ross container, gateway, Telegram, memory, disk, load

CONTAINER_NAME="openclaw-ross"

echo "=== ROSS HEALTH CHECK ==="
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo ""

# Container status
CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' $CONTAINER_NAME 2>/dev/null || echo "not found")
CONTAINER_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null || echo "unknown")
echo "Container: $CONTAINER_STATUS (health: $CONTAINER_HEALTH)"

# Gateway status via health endpoint
HEALTH_RESPONSE=$(curl -s http://localhost:19789/health 2>/dev/null)
if [ -n "$HEALTH_RESPONSE" ]; then
  echo "Gateway: REACHABLE (port 19789)"
else
  echo "Gateway: UNREACHABLE"
fi

# Telegram check via docker exec
TG_STATUS=$(docker exec $CONTAINER_NAME openclaw channels status 2>&1 | grep -i telegram | head -1)
if [ -n "$TG_STATUS" ]; then
  echo "Telegram: $TG_STATUS"
else
  echo "Telegram: UNKNOWN"
fi

# Config validity (check host file)
CONFIG="/root/openclaw-clients/ross/openclaw.json"
if [ -f "$CONFIG" ]; then
  python3 -c "import json; json.load(open('$CONFIG'))" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "Config: VALID"
  else
    echo "Config: INVALID (parse error)"
  fi
else
  echo "Config: MISSING"
fi

# Container resource usage
DOCKER_STATS=$(docker stats $CONTAINER_NAME --no-stream --format "CPU: {{.CPUPerc}} | MEM: {{.MemUsage}}" 2>/dev/null)
echo "Resources: $DOCKER_STATS"

# Server-wide metrics
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_PCT=$((MEM_USED * 100 / MEM_TOTAL))
echo "Server Memory: ${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PCT}%)"

DISK_PCT=$(df / | awk 'NR==2 {gsub(/%/,""); print $5}')
DISK_AVAIL=$(df -h / | awk 'NR==2 {print $4}')
echo "Disk: ${DISK_PCT}% used (${DISK_AVAIL} free)"

LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo "Load: $LOAD"

# Container uptime
UPTIME=$(docker inspect --format='{{.State.StartedAt}}' $CONTAINER_NAME 2>/dev/null)
echo "Started: $UPTIME"

# Other bots status (brief)
JACK_PORT=$(ss -tlnp 2>/dev/null | grep -c ":18789")
JOHN_STATUS=$(docker inspect --format='{{.State.Status}}' openclaw-john 2>/dev/null || echo "not found")
echo "Jack: $([ "$JACK_PORT" -gt 0 ] && echo 'RUNNING' || echo 'DOWN')"
echo "John: $JOHN_STATUS"

echo ""
echo "=== END ==="

#!/bin/bash
# Deploy Sarah — Full deployment script
# Based on lessons learned from Ross migration and Daniel's failures
# Created: 2026-02-11
set -e

echo "============================================"
echo "  Sarah Deployment — Coach & Mentor Bot"
echo "============================================"
echo ""

# =============================================
# PHASE 1: Delete Daniel completely
# =============================================
echo "=== PHASE 1: Removing Daniel ==="

echo "1.1 Stopping Daniel container..."
docker stop openclaw-daniel 2>/dev/null || echo "  (already stopped)"

echo "1.2 Removing Daniel container..."
docker rm openclaw-daniel 2>/dev/null || echo "  (already removed)"

echo "1.3 Archiving Daniel's data..."
if [ -d /root/openclaw-clients/daniel ]; then
    tar -czf /root/openclaw-clients/daniel-archive-$(date +%Y%m%d_%H%M%S).tar.gz -C /root/openclaw-clients daniel/
    echo "  ✅ Archived to /root/openclaw-clients/daniel-archive-*.tar.gz"
    rm -rf /root/openclaw-clients/daniel
    echo "  ✅ Daniel directory deleted"
else
    echo "  (Daniel directory not found, skipping)"
fi

echo "✅ Phase 1 complete — Daniel is gone"
echo ""

# =============================================
# PHASE 2: Create Sarah's directory structure
# =============================================
echo "=== PHASE 2: Creating Sarah's directory structure ==="

SARAH_DIR=/root/openclaw-clients/sarah

# Create all needed directories
# (Lesson: docker_migration — create the full structure upfront)
mkdir -p "$SARAH_DIR"/{workspace,data/agents,data/cron,data/credentials,secrets,canvas}
echo "✅ Directory structure created"
echo ""

# =============================================
# PHASE 3: Files will be uploaded via PSCP
# =============================================
echo "=== PHASE 3: Checking uploaded files ==="

# Verify critical files exist
MISSING=0
for f in docker-compose.yml entrypoint.sh openclaw.json workspace/SOUL.md workspace/USER.md workspace/HEARTBEAT.md secrets/telegram_token.txt secrets/gateway_token.txt; do
    if [ ! -f "$SARAH_DIR/$f" ]; then
        echo "  ❌ Missing: $f"
        MISSING=1
    else
        echo "  ✅ Found: $f"
    fi
done

if [ "$MISSING" -eq 1 ]; then
    echo ""
    echo "❌ Some files are missing! Upload them via PSCP first."
    exit 1
fi

echo "✅ All files present"
echo ""

# =============================================
# PHASE 4: Generate gateway token
# =============================================
echo "=== PHASE 4: Generating gateway token ==="

# Generate a random gateway token
GATEWAY_TOKEN=$(openssl rand -hex 24)
echo "$GATEWAY_TOKEN" > "$SARAH_DIR/secrets/gateway_token.txt"

# Update openclaw.json with the gateway token
# (Lesson: use python for JSON manipulation, not sed)
python3 -c "
import json
with open('$SARAH_DIR/openclaw.json', 'r') as f:
    config = json.load(f)
config['gateway']['auth']['token'] = '$GATEWAY_TOKEN'
with open('$SARAH_DIR/openclaw.json', 'w') as f:
    json.dump(config, f, indent=2)
print('  Gateway token set: ${GATEWAY_TOKEN:0:8}...')
"

echo "✅ Gateway token generated and set"
echo ""

# =============================================
# PHASE 5: Set permissions
# =============================================
echo "=== PHASE 5: Setting permissions ==="

# Lesson: userns-remap means UID 101000, NOT 1000!
# (docker_migration_native_to_container.md — Problem 9)
OWNER_UID=101000
echo "  Using UID $OWNER_UID (userns-remap active on this server)"

# Set ownership on all files
chown -R $OWNER_UID:$OWNER_UID "$SARAH_DIR"/workspace
chown -R $OWNER_UID:$OWNER_UID "$SARAH_DIR"/data
chown -R $OWNER_UID:$OWNER_UID "$SARAH_DIR"/canvas
chown $OWNER_UID:$OWNER_UID "$SARAH_DIR"/openclaw.json

# Secrets owned by root, readable by container
chmod 600 "$SARAH_DIR"/secrets/*
chmod +x "$SARAH_DIR"/entrypoint.sh

echo "✅ Permissions set"
echo ""

# =============================================
# PHASE 6: Run openclaw doctor
# =============================================
echo "=== PHASE 6: Running openclaw doctor ==="

# Lesson: Run doctor with gateway stopped, in temp container
# (docker_migration — Problem 4, 5)
docker run --rm --user root \
  -v "$SARAH_DIR/openclaw.json:/home/openclaw/.openclaw/openclaw.json:rw" \
  openclaw-client:latest openclaw doctor --fix 2>&1 || echo "  (doctor completed with warnings)"

echo "✅ Doctor check done"
echo ""

# =============================================
# PHASE 7: Start Sarah
# =============================================
echo "=== PHASE 7: Starting Sarah ==="

cd "$SARAH_DIR"
docker compose up -d

echo "  Waiting 20 seconds for startup..."
sleep 20

echo ""
echo "=== PHASE 8: Verification ==="

# Check container status
echo "Container status:"
docker ps --filter name=openclaw-sarah --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo ""

# Check for errors in logs
echo "Checking logs for errors..."
ERRORS=$(docker logs openclaw-sarah 2>&1 | grep -i 'error\|EACCES\|EPERM\|permission\|fail\|missing config' | head -10)
if [ -n "$ERRORS" ]; then
    echo "⚠️  Errors found:"
    echo "$ERRORS"
else
    echo "✅ No errors in logs"
fi

echo ""
echo "Recent logs (last 10 lines):"
docker logs openclaw-sarah 2>&1 | tail -10

echo ""
echo "============================================"
echo "  Deployment Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Open Telegram and search for @thrive5bot"
echo "2. Send: /start"
echo "3. Sarah will pair with you"
echo "4. Port: 19490 (localhost)"
echo ""

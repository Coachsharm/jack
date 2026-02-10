#!/bin/bash
# setup-ross-docker.sh — Sets up Ross in Docker
set -e

ROSS_DIR="/root/openclaw-clients/ross"

# Extract tokens from config
TELEGRAM_TOKEN=$(python3 -c "import json; c=json.load(open('$ROSS_DIR/openclaw.json')); print(c['channels']['telegram']['botToken'])")
GATEWAY_TOKEN=$(python3 -c "import json; c=json.load(open('$ROSS_DIR/openclaw.json')); print(c['gateway']['auth']['token'])")

echo "$TELEGRAM_TOKEN" > "$ROSS_DIR/secrets/telegram_token.txt"
echo "$GATEWAY_TOKEN" > "$ROSS_DIR/secrets/gateway_token.txt"
echo "Tokens extracted."

# Update openclaw.json for Docker:
# - Change gateway bind from loopback to lan
# - Change workspace path to Docker internal path
# - Change port to 19789
python3 << 'PYEOF'
import json

with open("/root/openclaw-clients/ross/openclaw.json") as f:
    c = json.load(f)

# Gateway adjustments for Docker
c["gateway"]["bind"] = "lan"
c["gateway"]["port"] = 18789  # internal port (Docker maps it)

# Workspace path inside the container
c["agents"]["defaults"]["workspace"] = "/home/openclaw/.openclaw/workspace"

# Remove botToken from config (will come from secrets)
# Actually keep it - the entrypoint will override if needed

with open("/root/openclaw-clients/ross/openclaw.json", "w") as f:
    json.dump(c, f, indent=2)

print("Config updated for Docker.")
PYEOF

# Copy entrypoint from John
cp /root/openclaw-clients/john/entrypoint.sh "$ROSS_DIR/entrypoint.sh"
echo "Entrypoint copied from John."

# Create docker-compose.yml
cat > "$ROSS_DIR/docker-compose.yml" << 'COMPOSE'
services:
  openclaw:
    image: openclaw-client:latest
    container_name: openclaw-ross

    entrypoint: ["/home/openclaw/entrypoint.sh"]
    command: ["openclaw", "gateway", "--bind", "lan"]

    extra_hosts:
      - "host.docker.internal:host-gateway"

    user: "1000:1000"

    volumes:
      - ./workspace:/home/openclaw/.openclaw/workspace:rw,noexec
      - ./openclaw.json:/home/openclaw/.openclaw/openclaw.json:ro
      - ./entrypoint.sh:/home/openclaw/entrypoint.sh:ro
      - ./canvas:/home/openclaw/.openclaw/canvas:rw,noexec
      - ./data/agents:/home/openclaw/.openclaw/agents:rw
      - ./data/cron:/home/openclaw/.openclaw/cron:rw
      - ./data/credentials:/home/openclaw/.openclaw/credentials:rw

    tmpfs:
      - /tmp:size=100M,noexec,nosuid,nodev
      - /var/tmp:size=50M,noexec,nosuid,nodev

    secrets:
      - telegram_token
      - gateway_token

    environment:
      - CLIENT_NAME=ross
      - NODE_ENV=production

    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 2G
          pids: 100
        reservations:
          cpus: '0.25'
          memory: 512M

    networks:
      - client-network

    ports:
      - "127.0.0.1:19789:18789"

    privileged: false
    cap_drop:
      - ALL

    security_opt:
      - no-new-privileges:true

    sysctls:
      - net.ipv4.ip_forward=0
      - net.ipv4.conf.all.send_redirects=0
      - net.ipv4.conf.all.accept_redirects=0

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        tag: "client-ross"

    restart: unless-stopped

    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:18789/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  client-network:
    driver: bridge

secrets:
  telegram_token:
    file: ./secrets/telegram_token.txt
  gateway_token:
    file: ./secrets/gateway_token.txt
COMPOSE

echo "docker-compose.yml created."

# Fix ownership - Docker runs as uid 1000
chown -R 1000:1000 "$ROSS_DIR/workspace" "$ROSS_DIR/data" "$ROSS_DIR/canvas" "$ROSS_DIR/secrets"
chmod 600 "$ROSS_DIR/secrets/"*
chmod +x "$ROSS_DIR/entrypoint.sh"

echo ""
echo "=== SETUP COMPLETE ==="
echo "Directory: $ROSS_DIR"
echo "Telegram token: $(cat $ROSS_DIR/secrets/telegram_token.txt | head -c 20)..."
echo "Gateway token: $(cat $ROSS_DIR/secrets/gateway_token.txt | head -c 20)..."
echo ""
echo "To start: cd $ROSS_DIR && docker compose up -d"

#!/bin/bash
# Jack4 Preparation Script
# Run this on the VPS after SSHing in

set -e  # Exit on error

echo "=== Jack4 Docker Setup - Phase 1: Preparation ==="

# Step 1: Create blueprint directory
echo "Step 1/3: Creating blueprint directory..."
mkdir -p /root/docker-blueprints/openclaw-jack4
cd /root/docker-blueprints/openclaw-jack4
echo "✓ Directory created: /root/docker-blueprints/openclaw-jack4"

# Step 2: Clone OpenClaw repository
echo ""
echo "Step 2/3: Cloning OpenClaw repository..."
if [ -d ".git" ]; then
    echo "Repository already exists, pulling latest..."
    git pull
else
    echo "Cloning from GitHub..."
    git clone https://github.com/clawdhub/openclaw.git .
fi
echo "✓ Repository cloned"

# Step 3: Prepare configuration volumes
echo ""
echo "Step 3/3: Creating configuration volumes..."
mkdir -p /root/jack4-config /root/jack4-workspace
chown -R 1000:1000 /root/jack4-config /root/jack4-workspace
echo "✓ Configuration volumes created and permissions set"

echo ""
echo "=== Preparation Complete! ==="
echo ""
echo "Next step: Run the Docker setup wizard"
echo "Command: ./docker-setup.sh"
echo ""
echo "The wizard will ask you to:"
echo "  1. Choose LLM provider (select: OpenRouter)"
echo "  2. Enter API key (your OpenRouter key)"
echo "  3. Choose model (use: openrouter/openai/gpt-4o)"
echo ""

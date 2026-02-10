#!/bin/bash
# Jack4 Complete Installation Script
# Following OpenClaw official documentation

set -e

echo "=== Jack4 Installation - Official OpenClaw Method ==="
echo ""

# Step 1: Download and run official installer
echo "Step 1: Running official OpenClaw installer..."
curl -fsSL https://openclaw.ai/install.sh | bash

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "The OpenClaw installer has set up everything for you."
echo ""
echo "Next steps:"
echo "1. The installer will ask you questions - answer them as follows:"
echo "   - LLM Provider: OpenRouter"
echo "   - API Key: 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"
echo "   - Model: openrouter/openai/gpt-4o"
echo ""
echo "2. After setup, add Telegram channel:"
echo "   openclaw channels add --channel telegram --token '8023616765:AAFhX455TUDzxauA8lCQ1ThhBeao8r5mj6U'"
echo ""
echo "3. Check status:"
echo "   openclaw doctor"
echo ""

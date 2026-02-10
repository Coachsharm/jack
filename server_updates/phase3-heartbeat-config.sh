#!/bin/bash
# ============================================================
# RELAY SYSTEM IMPROVEMENTS — Phase 3: Heartbeat Config Alignment
# ============================================================
# Fixes: Bug 9 (Jack no heartbeat prompt), Bug 10 (John no heartbeat prompt)
# ============================================================

echo "=== PHASE 3: HEARTBEAT CONFIG ALIGNMENT ==="
echo ""

# Add heartbeat config to Jack's openclaw.json
echo "[1/2] Adding heartbeat config to Jack..."
python3 << 'PYEOF'
import json

with open('/root/.openclaw/openclaw.json', 'r') as f:
    config = json.load(f)

if 'agents' not in config:
    config['agents'] = {}
if 'defaults' not in config['agents']:
    config['agents']['defaults'] = {}

# Only add if not already present
if 'heartbeat' not in config['agents']['defaults']:
    config['agents']['defaults']['heartbeat'] = {
        "every": "2m",
        "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK."
    }
    with open('/root/.openclaw/openclaw.json', 'w') as f:
        json.dump(config, f, indent=2)
    print("  Added heartbeat config to Jack")
else:
    print("  Jack already has heartbeat config (skipped)")
PYEOF

# Add heartbeat config to John's openclaw.json
echo "[2/2] Adding heartbeat config to John..."
python3 << 'PYEOF'
import json

with open('/root/openclaw-clients/john/openclaw.json', 'r') as f:
    config = json.load(f)

if 'agents' not in config:
    config['agents'] = {}
if 'defaults' not in config['agents']:
    config['agents']['defaults'] = {}

# Only add if not already present
if 'heartbeat' not in config['agents']['defaults']:
    config['agents']['defaults']['heartbeat'] = {
        "every": "2m",
        "prompt": "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK."
    }
    with open('/root/openclaw-clients/john/openclaw.json', 'w') as f:
        json.dump(config, f, indent=2)
    print("  Added heartbeat config to John")
else:
    print("  John already has heartbeat config (skipped)")
PYEOF

echo ""
echo "=== PHASE 3 COMPLETE ==="
echo ""
echo "Jack and John now have matching heartbeat config (every 2m, reads HEARTBEAT.md)"
echo "Note: This takes effect on next gateway restart or agent session"

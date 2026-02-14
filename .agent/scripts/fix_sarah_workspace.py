#!/usr/bin/env python3
import json

# Read config
with open('/root/.openclaw/openclaw.json', 'r') as f:
    cfg = json.load(f)

# Find and update Sarah
agents_list = cfg.get('agents', {}).get('list', [])
for agent in agents_list:
    if agent.get('id') == 'sarah':
        old_workspace = agent.get('workspace')
        agent['workspace'] = '/root/.openclaw/workspace-sarah'
        print(f"Updated Sarah workspace:")
        print(f"  FROM: {old_workspace}")
        print(f"  TO:   {agent['workspace']}")
        break

# Write back
with open('/root/.openclaw/openclaw.json', 'w') as f:
    json.dump(cfg, f, indent=2)

print('Config saved!')

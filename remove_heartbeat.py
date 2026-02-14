import json

with open('/root/.openclaw/openclaw.json') as f:
    cfg = json.load(f)

# Remove heartbeat from defaults entirely (disables it)
if 'heartbeat' in cfg['agents']['defaults']:
    del cfg['agents']['defaults']['heartbeat']
    print('Removed heartbeat from defaults')

with open('/root/.openclaw/openclaw.json', 'w') as f:
    json.dump(cfg, f, indent=2)

print('Config saved')

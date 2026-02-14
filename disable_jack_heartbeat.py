import json

with open('/root/.openclaw/openclaw.json') as f:
    cfg = json.load(f)

# Disable heartbeat in defaults
cfg['agents']['defaults']['heartbeat'] = {'enabled': False}

with open('/root/.openclaw/openclaw.json', 'w') as f:
    json.dump(cfg, f, indent=2)

print('Jack heartbeat disabled in defaults')

#!/usr/bin/env python3
import json

config_path = '/root/openclaw-clients/ross/openclaw.json'

with open(config_path, 'r') as f:
    config = json.load(f)

config['agents']['defaults']['thinkingDefault'] = 'off'

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print('SUCCESS: thinkingDefault set to off')

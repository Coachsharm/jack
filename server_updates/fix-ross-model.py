#!/usr/bin/env python3
import json

config_path = '/root/openclaw-clients/ross/openclaw.json'

with open(config_path, 'r') as f:
    config = json.load(f)

# Switch primary from thinking to non-thinking variant
old_primary = config['agents']['defaults']['model']['primary']
config['agents']['defaults']['model']['primary'] = 'google-antigravity/claude-sonnet-4-5'

# Also update fallbacks to remove thinking variants
old_fallbacks = config['agents']['defaults']['model']['fallbacks']
new_fallbacks = []
for fb in old_fallbacks:
    new_fallbacks.append(fb.replace('-thinking', ''))
config['agents']['defaults']['model']['fallbacks'] = new_fallbacks

print(f'Primary: {old_primary} -> {config["agents"]["defaults"]["model"]["primary"]}')
print(f'Fallbacks: {old_fallbacks} -> {new_fallbacks}')
print('SUCCESS')
    
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

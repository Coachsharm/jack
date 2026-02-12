#!/usr/bin/env python3
import json
import shutil
from datetime import datetime

config_path = '/root/.openclaw/openclaw.json'

# Backup first
backup_path = f'{config_path}.bak.{datetime.now().strftime("%Y%m%d_%H%M%S")}'
shutil.copy2(config_path, backup_path)
print(f'Backup: {backup_path}')

with open(config_path, 'r') as f:
    config = json.load(f)

# Fix: change anthropic/claude-opus-4-6 to google-antigravity/claude-opus-4-6
old_primary = config['agents']['defaults']['model']['primary']
config['agents']['defaults']['model']['primary'] = 'google-antigravity/claude-opus-4-6'

print(f'Primary: {old_primary} -> {config["agents"]["defaults"]["model"]["primary"]}')

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print('SUCCESS - Config updated')

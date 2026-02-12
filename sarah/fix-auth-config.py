#!/usr/bin/env python3
"""Fix Sarah's openclaw.json auth section to match available auth-profiles.json tokens"""
import json

config_path = '/root/openclaw-clients/sarah/openclaw.json'

with open(config_path, 'r') as f:
    config = json.load(f)

# Update auth to include faithinmotion88 (which has actual OAuth tokens)
config['auth'] = {
    "profiles": {
        "google-antigravity:faithinmotion88@gmail.com": {
            "provider": "google-antigravity",
            "mode": "oauth",
            "email": "faithinmotion88@gmail.com"
        },
        "google-antigravity:blackintegra777@gmail.com": {
            "provider": "google-antigravity",
            "mode": "oauth"
        },
        "anthropic:manual": {
            "provider": "anthropic",
            "mode": "token"
        }
    },
    "order": {
        "google-antigravity": [
            "google-antigravity:faithinmotion88@gmail.com",
            "google-antigravity:blackintegra777@gmail.com"
        ]
    }
}

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print("SUCCESS: Auth config updated with faithinmotion88 as primary + anthropic")

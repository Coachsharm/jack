import json

config_path = "/root/openclaw-clients/ross/openclaw.json"
with open(config_path) as f:
    config = json.load(f)

# Add heartbeat prompt
if "agents" not in config:
    config["agents"] = {}
if "defaults" not in config["agents"]:
    config["agents"]["defaults"] = {}
if "heartbeat" not in config["agents"]["defaults"]:
    config["agents"]["defaults"]["heartbeat"] = {}

# Set the heartbeat prompt (same as Jack's)
config["agents"]["defaults"]["heartbeat"]["prompt"] = "Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK."

# Keep the "every" setting
if "every" not in config["agents"]["defaults"]["heartbeat"]:
    config["agents"]["defaults"]["heartbeat"]["every"] = "2m"

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)

print("✅ Added heartbeat prompt to Ross's config")
print(f"Heartbeat config: {config['agents']['defaults']['heartbeat']}")

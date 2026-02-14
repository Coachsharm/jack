import json

with open("/root/.openclaw/openclaw.json") as f:
    cfg = json.load(f)

agents_list = cfg.get("agents", {}).get("list", [])
sarah = next((a for a in agents_list if a.get("id") == "sarah"), None)

if sarah:
    print("Sarah config:")
    print(f"  id: {sarah.get('id')}")
    print(f"  workspace: {sarah.get('workspace')}")
    print(f"  agentDir: {sarah.get('agentDir')}")
    print(f"  model: {sarah.get('model')}")
else:
    print("Sarah not found in agents list!")

import json

with open("/root/openclaw-clients/ross/openclaw.json") as f:
    c = json.load(f)

# Fix 1: dmPolicy open requires allowFrom *
c["channels"]["telegram"]["allowFrom"] = ["*"]
c["channels"]["telegram"]["dmPolicy"] = "open"

# Fix 2: Remove invalid heartbeat.enabled key
hb = c.get("agents", {}).get("defaults", {}).get("heartbeat", {})
if "enabled" in hb:
    del hb["enabled"]
    print("Removed heartbeat.enabled")

# Fix 3: Ensure WhatsApp allowFrom is correct too
if "whatsapp" in c.get("channels", {}):
    wa = c["channels"]["whatsapp"]
    if "allowFrom" not in wa:
        wa["allowFrom"] = ["+6588626460", "+6591090995"]
        print("Added WhatsApp allowFrom")

with open("/root/openclaw-clients/ross/openclaw.json", "w") as f:
    json.dump(c, f, indent=2)

# Verify
with open("/root/openclaw-clients/ross/openclaw.json") as f:
    v = json.load(f)
print(f"dmPolicy: {v['channels']['telegram']['dmPolicy']}")
print(f"allowFrom: {v['channels']['telegram']['allowFrom']}")
print("Config fixed successfully")

#!/bin/bash
# fix-ross-config.sh — Fix invalid config keys
import json
with open("/root/openclaw-clients/ross/openclaw.json") as f:
    c = json.load(f)
hb = c.get("agents",{}).get("defaults",{}).get("heartbeat",{})
if "enabled" in hb:
    del hb["enabled"]
    print("Removed heartbeat.enabled")
with open("/root/openclaw-clients/ross/openclaw.json","w") as f:
    json.dump(c, f, indent=2)
print("Config fixed")

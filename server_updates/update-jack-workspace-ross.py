import re

# SOUL.md fix
soul_path = "/root/.openclaw/workspace/SOUL.md"
with open(soul_path) as f:
    soul = f.read()

# Replace line 109: Ross's old path
soul = soul.replace(
    '- **Ross** — native install at `/root/.openclaw-ross/`',
    '- **Ross** (@riskbot) — **Docker container** `openclaw-ross` at `/root/openclaw-clients/ross/`. Primary role: **watchdog for Jack** — monitors Jack\'s health, revives gateway if needed. Has privileged access (full root read/write) for recovery operations.'
)

with open(soul_path, "w") as f:
    f.write(soul)
print("✅ SOUL.md updated: Ross is now Docker with watchdog role")

# AGENTS.md is already correct (line 257 says Docker), no changes needed
print("✅ AGENTS.md already correct (Ross listed as Docker)")

print("\n📝 Summary:")
print("- Ross listed as Docker container (not native)")
print("- Primary role: watchdog/backup for Jack")
print("- Privileged access noted for recovery operations")
print("- John remains listed as template/WIP")

import json, sys, os, glob

# Check cron jobs
print("=== CRON JOBS ===")
os.system("openclaw cron list 2>&1 | col -b > /tmp/cron_clean.txt")
with open("/tmp/cron_clean.txt") as f:
    print(f.read())

# Check Sarah's sessions
print("\n=== SARAH SESSIONS ===")
session_dir = "/root/.openclaw/agents/sarah/agent/sessions"
if os.path.exists(session_dir):
    for root, dirs, files in os.walk(session_dir):
        for f in files:
            path = os.path.join(root, f)
            size = os.path.getsize(path)
            print(f"  {path} ({size} bytes)")
    if not any(os.walk(session_dir)):
        print("  (empty)")
else:
    print("  Directory does not exist")

# Check all session dirs
print("\n=== ALL AGENT SESSIONS ===")
agents_dir = "/root/.openclaw/agents"
if os.path.exists(agents_dir):
    for agent in os.listdir(agents_dir):
        sess_path = os.path.join(agents_dir, agent, "agent", "sessions")
        if os.path.exists(sess_path):
            count = sum(len(files) for _, _, files in os.walk(sess_path))
            print(f"  {agent}: {count} session files")

# Check Sarah's workspace SOUL.md first line
print("\n=== SARAH SOUL.MD CHECK ===")
soul_path = "/root/.openclaw/workspace-sarah/SOUL.md"
if os.path.exists(soul_path):
    with open(soul_path) as f:
        content = f.read()
    print(f"  Size: {len(content)} bytes")
    print(f"  First 200 chars: {content[:200]}")
    if "Sarah" in content or "coach assistant" in content.lower() or "fitness" in content.lower():
        print("  ✅ Contains Sarah-specific content")
    else:
        print("  ❌ Looks like generic template!")
else:
    print("  FILE NOT FOUND!")

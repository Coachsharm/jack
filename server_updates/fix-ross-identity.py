import os, re

workspace = "/root/openclaw-clients/ross/workspace"
host_path = "/root/openclaw-clients/ross"
container_path = "/home/openclaw/.openclaw"

# Fix all workspace files — replace HOST paths with CONTAINER paths
# (but leave the migration lesson alone — that's historical)
identity_files = ["SOUL.md", "AGENTS.md", "USER.md", "IDENTITY.md", 
                  "TOOLS.md", "HEARTBEAT.md", "BOT_CHAT.md", 
                  "GROUP_CHAT_MAP.md", "STYLE_GUIDE.md"]

for fname in identity_files:
    path = os.path.join(workspace, fname)
    if not os.path.exists(path):
        continue
    with open(path) as f:
        content = f.read()
    
    count = content.count(host_path)
    if count > 0:
        content = content.replace(host_path, container_path)
        with open(path, "w") as f:
            f.write(content)
        print(f"  {fname}: fixed {count} host path references -> container path")
    else:
        print(f"  {fname}: clean")

# Now update the SOUL.md environment block to be accurate from Ross's POV
soul_path = os.path.join(workspace, "SOUL.md")
with open(soul_path) as f:
    content = f.read()

# Replace the environment block with one that makes sense from INSIDE the container
old_block = """## My Environment (Ross)
- **Deployment:** Docker container `openclaw-ross`
- **Host path:** `/root/openclaw-clients/ross/`
- **Container path:** `/home/openclaw/.openclaw/`
- **Gateway port:** 19789 (external) → 18789 (internal)
- **I am NOT native.** I run inside Docker. I do NOT have access to `/root/openclaw-clients/ross/`.
- **To run CLI commands:** They execute inside my container automatically."""

new_block = """## My Environment (Ross)
- **Deployment:** Docker container `openclaw-ross`
- **My home directory:** `/home/openclaw/.openclaw/`
- **My workspace:** `/home/openclaw/.openclaw/workspace/`
- **My sessions:** `/home/openclaw/.openclaw/agents/main/sessions/`
- **Gateway port:** 18789 (inside container)
- **I am running in Docker.** I am NOT a native install. All my files are at `/home/openclaw/.openclaw/`.
- **To run CLI commands:** They execute inside my container automatically.
- **Host-side location (for Coach/Antigravity):** `/root/openclaw-clients/ross/` — I cannot see this path."""

if old_block in content:
    content = content.replace(old_block, new_block)
    print("  SOUL.md: replaced environment block with container-aware version")
else:
    # Try partial match
    if "My Environment (Ross)" in content and "I do NOT have access" in content:
        # Replace everything between ## My Environment and the next ##
        lines = content.split("\n")
        new_lines = []
        skip = False
        for line in lines:
            if "## My Environment (Ross)" in line:
                skip = True
                new_lines.append("")
                new_lines.append(new_block)
                continue
            if skip and line.startswith("## "):
                skip = False
            if skip and line.startswith("- **"):
                continue
            if not skip:
                new_lines.append(line)
        content = "\n".join(new_lines)
        print("  SOUL.md: replaced environment block (partial match)")
    else:
        print("  SOUL.md: could not find environment block to replace")

with open(soul_path, "w") as f:
    f.write(content)

print("\nAll done. Ross now sees container paths only.")

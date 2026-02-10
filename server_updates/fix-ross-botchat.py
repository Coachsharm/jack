with open("/root/openclaw-clients/ross/workspace/BOT_CHAT.md") as f:
    c = f.read()

c = c.replace("running native at", "now running in Docker container openclaw-ross at")
c = c.replace("/root/.openclaw-ross", "/root/openclaw-clients/ross")

with open("/root/openclaw-clients/ross/workspace/BOT_CHAT.md", "w") as f:
    f.write(c)

print("BOT_CHAT.md updated")

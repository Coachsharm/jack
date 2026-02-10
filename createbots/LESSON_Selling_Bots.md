# LESSON: Selling OpenClaw Bots (Docker Method)

**Created**: 2026-02-08

---

## How It Works

John runs inside Docker = a sealed box. He:
- ✅ Can only see his own files (`/home/openclaw/.openclaw/`)
- ❌ Cannot see `/root` or host server files
- ❌ Cannot see other bots
- ❌ Cannot install software
- ❌ Cannot run docker commands
- ❌ Cannot write outside his workspace

This makes John **safe to sell as a product** — customers get their own isolated copy.

---

## Two Deployment Options

### Option A: Same Server (You Host)

Customer pays you, you run:

```bash
/root/openclaw-product/deploy-bot.sh
```

It asks for:
1. **Bot name** (e.g. `sarah`)
2. **Telegram token** (customer creates via @BotFather)
3. **API key** (optional)
4. Choose **L** for local

→ Spins up a new isolated Docker container on your server.

### Option B: Customer's Server

Same script, choose **P** for package:

→ Creates a `.tar.gz` file. Send to customer.

Customer runs:
```bash
tar -xzf sarah.tar.gz
cd sarah
docker compose up -d
```

Done. Their own bot on their own server.

---

## What Each Customer Gets

```
sarah/
├── docker-compose.yml    ← Start/stop
├── openclaw.json         ← Bot config
├── entrypoint.sh         ← Loads secrets
├── secrets/              ← Their tokens (private)
├── workspace/            ← SOUL.md personality
│   └── SOUL.md           ← Customize this
├── canvas/               ← Web UI assets
├── data/                 ← Sessions, memory
└── README.md             ← Instructions
```

## What Customers Customize

| What | File | Example |
|------|------|---------|
| Personality | `workspace/SOUL.md` | "You are a fitness coach..." |
| AI Model | `openclaw.json` → `agents.defaults.model.primary` | `gemini-3-flash` |
| Bot name | `openclaw.json` + Telegram @BotFather | `@sarahbot` |
| Allowed commands | `openclaw.json` → `tools.exec.safeBins` | Add/remove tools |

---

## Security (Already Built In)

| Protection | How |
|-----------|-----|
| Non-root user | `user: "1000:1000"` in compose |
| No capabilities | `cap_drop: ALL` |
| No privilege escalation | `no-new-privileges:true` |
| Config read-only | `openclaw.json:ro` |
| Workspace noexec | Can't run binaries |
| Resource limits | 1 CPU, 2GB RAM, 100 PIDs |
| Network isolated | Own bridge network |
| Tool allowlist | Only safe commands |
| No Docker socket | Can't control host |

---

## Pricing Ideas

- **Hosted (Option A)**: Monthly fee (you manage server)
- **Self-hosted (Option B)**: One-time fee (they manage)
- **Premium**: Custom SOUL.md + setup support

---

## Deploy Script Location

```
/root/openclaw-product/deploy-bot.sh
```

# John — Features & Capabilities

> What John can do out of the box and how to extend him.

## Core Features

### 🤖 AI-Powered Conversations
- Multi-model support (Claude, GPT, Gemini)
- Persistent memory across sessions
- Context-aware responses with compaction
- Natural language understanding

### 📱 Multi-Channel Messaging
- **Telegram** — Personal and group chats
- **WhatsApp** — Personal and group messaging
- Both channels active simultaneously

### ⏰ Scheduled Tasks (Cron)
- Built-in cron system via `openclaw cron add`
- Timezone-aware scheduling (Asia/Singapore default)
- Use cases: daily summaries, reminders, recurring check-ins

### 🧠 Agent Workspace
- Markdown-based knowledge files
- `SOUL.md` — defines personality and behavior
- `TOOLS.md` — available commands and integrations
- Editable by the bot itself (self-improving)

### 🔒 Security
- Runs as non-root user in Docker
- All Linux capabilities dropped
- No privilege escalation possible
- Read-only config, Docker Secrets for tokens
- Resource-limited (CPU, memory, PIDs)

### ❤️ Health & Reliability
- Automatic health checks every 30 seconds
- Auto-restart on crashes (`unless-stopped`)
- Structured JSON logging with rotation
- Heartbeat system for liveness monitoring

---

## Customizable for Sale

### What Customers Get
| Component | Customizable? | How |
|-----------|:---:|-----|
| Bot personality | ✅ | Edit `workspace/SOUL.md` |
| Bot name | ✅ | Set in `openclaw.json` |
| LLM model | ✅ | Set provider/model in config |
| Channels | ✅ | Add Telegram, WhatsApp, or both |
| Cron jobs | ✅ | Add via `openclaw cron add` |
| Knowledge files | ✅ | Add `.md` files to `workspace/` |
| Security rules | ✅ | Set allow/deny lists in config |
| Resource limits | ✅ | Adjust in `docker-compose.yml` |

### Use Case Templates

John can be packaged for different verticals:

| Template | Description | Key customizations |
|----------|-------------|-------------------|
| **Personal Assistant** | Daily briefings, reminders, calendar | Cron jobs, email integration |
| **Customer Support** | Handle FAQ, route tickets | Knowledge base in workspace |
| **Community Manager** | Manage Telegram/WhatsApp groups | Group message handling, moderation |
| **Coach/Mentor** | Provide guidance, track progress | Personality in SOUL.md, memory |

---

## Pricing Tiers (Proposed)

| Tier | What's Included | Target Price |
|------|----------------|:---:|
| **Basic** | Single channel, 1 agent, standard persona | $29/mo |
| **Pro** | Multi-channel, cron jobs, custom persona | $79/mo |
| **Enterprise** | Multi-agent, custom tools, priority support | $199/mo |

> [!NOTE]
> Prices exclude LLM API costs (customer provides their own API key).

---

## Roadmap

### Near-term
- [ ] Customer onboarding wizard script
- [ ] Pre-built workspace templates per vertical
- [ ] Automated backup/restore for customer data

### Mid-term
- [ ] Web dashboard for customer self-management
- [ ] Plugin marketplace for extending capabilities
- [ ] Multi-tenant mode (multiple customers, single server)

### Long-term
- [ ] White-label branding
- [ ] SaaS hosted offering (no customer VPS needed)
- [ ] Mobile app companion

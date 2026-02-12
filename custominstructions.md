# Custom Instructions Reference

This file serves as a unified reference to all custom instruction protocols for this project.

**Last Updated:** 2026-02-11

---

## 🔃 DOCUMENTATION CURRENCY RULE

> **All local documentation, lessons, and instruction files MUST be kept current.**
> When systems change on the server (backup procedures, cron jobs, scripts, architecture),
> the corresponding local files MUST be updated or deleted. Stale docs are dangerous.
>
> **Periodic check:** At the start of each session, quickly verify that key references
> (backup system, server architecture, bot roster) haven't been superseded.
> If something has changed, update `claude.md`, `Gemini.md`, `custominstructions.md`,
> and any relevant lesson files immediately.

---

## 🧠 Who You Are & The Team

**You are Antigravity** — Coach Sharm's PC-based AI development partner.

```
    👤 Coach Sharm (The Boss)
    ├── At PC ────► 🤖 Antigravity (You) — development & ops partner
    └── Away ─────► 💬 Jack (Telegram) — always-on engineer

    ═══════════ VPS 72.62.252.124 ═══════════

    🟢 Jack (Native)                 🟠 John (Docker)          🔴 Ross (Docker)
    /root/.openclaw/                 /root/openclaw-clients/   /root/openclaw-clients/
    Main engineer, internal use      john/ — Fitness bot       ross/ — Watchdog bot
```

| Bot | Install | Location | Role |
|-----|---------|----------|------|
| **Jack** | Native | `/root/.openclaw/` | Engineer & Coach's daily assistant |
| **John** | Docker | `/root/openclaw-clients/john/` | Fitness coaching bot (Body Thrive clients) |
| **Ross** | Docker | `/root/openclaw-clients/ross/` | Watchdog/monitoring bot |

**The Mission:** Keep the ecosystem running & improving.

---

## 🚨 SERVER-FIRST RULE (CRITICAL)

> **ALL bot files live on the server, NOT locally.**
> - Jack: `/root/.openclaw/` (native — use `openclaw gateway restart`)
> - John: `/root/openclaw-clients/john/` (Docker — use `docker restart`)
> - **DO NOT** create or edit bot files locally — download → edit → upload back
> - Use `scp` for file transfers, `ssh` for commands
> - SSH password: `Corecore8888-`
> - See `Gemini.md` or `claude.md` for exact upload commands

---

## ⏰ Cron Job Rule (DO NOT DUPLICATE)

> **Use OpenClaw's built-in cron** (`openclaw cron add`) for anything involving agents or messaging.
> **Use system crontab** (`crontab -e`) ONLY for infrastructure (watchdog, log rotation, backups).
> **NEVER put the same job in both systems** — this causes silent failures and false confidence.
>
> See: `lessons/cron_duplication_openclaw_vs_system.md`

---

## 🚨 Troubleshooting Priority (FOLLOW THIS ORDER)

When encountering problems, follow this priority order **BEFORE** trying to find your own solution:

### 1. 📖 Check OpenClaw Documentation FIRST
- **Why:** LLMs are NOT trained on OpenClaw data
- **Path:** `c:\Users\hisha\Code\Jack\OpenClaw_Docs\`
- **Online:** https://docs.openclaw.com
- **Action:** Search for your error/feature before attempting fixes

### 2. 🩺 Use `claw doctor`
- **Why:** The built-in diagnostic tool catches most common issues
- **Command:** `claw doctor` (or `clawdbot doctor` in Docker)
- **Action:** Run this before manual debugging—it often identifies the root cause

### 3. 📚 Then proceed with normal research
- Check `lessons/` folder for past solutions
- Follow the Research Ladder in `Gemini.md` / `claude.md`
- Only then attempt manual solutions

> ⚠️ **Do NOT skip steps 1 and 2!** Most problems have documented solutions or are caught by the doctor.

---

## 🚑 Emergency Recovery: Jack Broken on Server

**FASTEST FIX** when Jack stops responding after config changes:

### Symptoms
- Jack not responding in WhatsApp/Telegram
- Recent manual edits to `openclaw.json`
- Config changes that might have broken things

### Recovery Procedure (Server Only)

```bash
# SSH to server
ssh root@72.62.252.124

# 1. CHECK if backup exists and is recent
ls -lh /root/.openclaw/openclaw.json.bak
stat /root/.openclaw/openclaw.json.bak | grep Modify

# 2. CREATE safety backup of current (broken) state
cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.before-restore

# 3. RESTORE from backup
cp /root/.openclaw/openclaw.json.bak /root/.openclaw/openclaw.json

# 4. RESTART OpenClaw
pkill -f openclaw
cd /root/.openclaw && openclaw > /tmp/openclaw.log 2>&1 &

# 5. VERIFY it's running
ps aux | grep openclaw | grep -v grep
```

**Why this works:** OpenClaw auto-creates `.bak` files before config changes. Usually it's the one file that breaks Jack.

**Recovery time:** ~2 minutes

---

## Protocol Files

When I say **"look at custom instructions"** or **"check custom instructions"**, refer to these files:

### 1. Gemini.md
- **Purpose:** Instructions specific to Google Gemini (Anti-gravity) agent
- **Contains:** Stuck loop detection protocol, research ladder, server document upload procedures, **Team Chat Auto-Check Protocol**
- **Path:** `c:\Users\hisha\Code\Jack\Gemini.md`

### 2. claude.md  
- **Purpose:** Instructions specific to Claude/Anthropic agent
- **Contains:** Stuck loop detection protocol, research ladder, server document upload procedures, **Team Chat Auto-Check Protocol**
- **Path:** `c:\Users\hisha\Code\Jack\claude.md`

---

## Update Protocol

When I say **"update custom instructions"**, you must:

1. ✅ Update BOTH `Gemini.md` AND `claude.md`
2. ✅ Keep the updates synchronized across both files
3. ✅ Maintain protocol version consistency
4. ✅ Update the "Last Updated" timestamp in both files

**Why both?** These files contain nearly identical protocols tailored for different LLM platforms. They should remain in sync to ensure consistent behavior regardless of which agent is active.

---

## Quick Links

- Gemini Protocol: `Gemini.md`
- Claude Protocol: `claude.md`
- Lessons Learned: `lessons/`
- OpenClaw Docs: `OpenClaw_Docs/`

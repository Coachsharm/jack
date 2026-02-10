# Lesson: OpenClaw Cron vs System Crontab — Never Duplicate

**Date:** 2026-02-07  
**Category:** CONFIG  
**Context:** Morning 6AM report wasn't firing despite Jack saying it was set up

---

## Problem

The 6AM daily report was set up in **two** places:
1. **Linux system crontab** (`crontab -l`) — bash script at `0 22 * * 0-4` (only weekdays)
2. **OpenClaw built-in cron** (`openclaw cron list`) — agent-based at `0 6 * * * @ Asia/Singapore`

Both showed "ok" or had a log entry, but **neither was actually delivering messages** because:
- The system crontab version only ran weekdays
- The OpenClaw cron ran but gateway channels were `running: false` — so messages couldn't be sent
- No error handling in the bash script meant silent failures

## Root Cause

When Jack sets up a "cron job," he often uses OpenClaw's built-in cron system (`openclaw cron add`). But external agents (like Antigravity or manual setup) sometimes add system crontab entries (`crontab -e`) for the same task. This creates duplicates that:
- Can fire twice
- Give false confidence ("it's set up!") when one of them is broken
- Are harder to debug (two places to check)

## Solution

**Rule: Use OpenClaw's built-in cron for ANYTHING that involves the LLM agent or sending messages through OpenClaw channels (Telegram/WhatsApp).**

- `openclaw cron add` — for agent tasks, messaging, anything that needs the gateway running
- System crontab — ONLY for infrastructure (watchdog, log rotation, system backups)

### How to check
```bash
# OpenClaw cron jobs (agent-level)
openclaw cron list

# System cron jobs (infrastructure-level)
crontab -l
```

### If a cron "says it ran" but nothing happened
1. Check `openclaw health --json` — are channels `running: true`?
2. If `running: false` → restart gateway: `openclaw gateway restart`
3. Check logs: `/var/log/6am-report.log` or `openclaw cron logs <job-id>`

## Prevention

- Never add the same task to both systems
- OpenClaw cron for messages/agent → System cron for infrastructure
- When setting up a new scheduled task, first check BOTH systems for duplicates

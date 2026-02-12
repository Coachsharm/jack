# Protocol Index - Hybrid Pointer System

**Read this when working on OpenClaw tasks.**

---

## Critical: Backup First (Rule Zero)

**Before editing ANY file, read:** `/root/.openclaw/workspace/protocols/backup.md`

This contains the mandatory 2-version backup procedure. Non-negotiable.

---

## Task-Specific Guidance

### Editing Config Files (openclaw.json)
1. **Backup first** (read protocols/backup.md)
2. **Field reference:** `/root/OpenClaw_Docs/gateway_configuration.md`
   - Lines 1-100: Overview and structure
   - Search for your specific field (gateway, models, channels, etc.)
3. **Examples:** `/root/OpenClaw_Docs/gateway_configuration-examples.md`
4. **Validate JSON** after editing: `cat openclaw.json | jq .`

---

### Adding or Modifying Skills
1. **Backup first** (read protocols/backup.md)
2. **Skill documentation:** `/root/OpenClaw_Docs/tools_skills.md` (read entire file)
3. **Slash commands:** `/root/OpenClaw_Docs/tools_slash-commands.md`
4. **Check existing skills** in openclaw.json for examples

---

### Troubleshooting Errors
1. **Start here:** `/root/OpenClaw_Docs/help_troubleshooting.md`
2. **Common questions:** `/root/OpenClaw_Docs/help_faq.md`
3. **Check logs:** `journalctl -u openclaw-gateway --tail 100` or `openclaw logs --lines 100`
4. **Search closed GitHub issues** for similar errors

---

### Learning About OpenClaw
1. **Getting started:** `/root/OpenClaw_Docs/getting-started.md`
2. **Core concepts:** `/root/OpenClaw_Docs/start_openclaw.md`
3. **CLI commands:** `/root/OpenClaw_Docs/cli.md`
4. **Specific topics:** Search `/root/OpenClaw_Docs/` for relevant files

---

### Infrastructure & Bot Management
1. **Migrating native→Docker:** `docker_migration_native_to_container.md`
   - Complete guide for moving OpenClaw bots from native to Docker
   - Covers userns-remap, path replacement, permission fixes
   - Use when spinning up new bots or moving existing ones
2. **Quick start checklist:** `NEW_BOT_CHECKLIST.md`
   - 13-step procedure without the "why" context
   - Fast reference for creating/migrating bots

---

## Research Protocol

**CRITICAL:** OpenClaw is NOT in your training data. Do not hallucinate.

1. **Read local docs first:** `/root/OpenClaw_Docs/` (source of truth)
2. **Check freshness:** `cat /root/OpenClaw_Docs/LAST_UPDATED.txt`
3. **If docs insufficient:**
   - Search GitHub Issues (closed): `is:issue is:closed [your problem]`
   - Search r/LocalLLaMA for Docker/config issues
   - Search Hacker News: `site:news.ycombinator.com "OpenClaw"`

---

**Token efficiency:** This index points you to official docs instead of duplicating content. Only load what you need.

# Lesson: Dashboard Model Display Not Updating

**Date:** 2026-02-14  
**Category:** Dashboard / Configuration Sync  
**Severity:** High — causes stale/incorrect data to be displayed

---

## Problem

The Thrive Command Center dashboard showed **hardcoded model names** (e.g., `a8`, `a3`, `sonnet`, `Aopus`) that never changed, even after updating agent models via the OpenClaw CLI. Pressing "Refresh" on the dashboard did nothing — it only re-read the same stale `status.json`.

## Root Cause (3 separate issues)

### 1. Hardcoded Models in `update_status.py`
The server-side Python script (`/var/www/sites/dashboard/update_status.py`) had model names as **literal Python dictionaries**, NOT read from `openclaw.json`:

```python
# ❌ OLD — HARDCODED (never updates!)
"model": {
    "main": "google-antigravity/gemini-3-flash",
    "sarah": "google-antigravity/claude-opus-4-6",
}[agent_id],
```

### 2. Refresh Button Was Cosmetic
The dashboard JavaScript `manualRefresh()` only re-fetched `status.json` — it did **NOT** call `trigger_update.php` to regenerate the data:

```javascript
// ❌ OLD — just re-reads same stale file
function manualRefresh() {
    fetchStatus();  // re-reads status.json, doesn't regenerate it
}
```

### 3. PHP Trigger Pointed to Wrong Script
`trigger_update.php` referenced a script at `/root/.openclaw/workspace/scripts/update_dashboard_json.py` which **did not exist** on the server. The local repo had a different/better version (`update_dashboard_json.py`) that was never uploaded.

## Fix Applied

### A. Dynamic Model Reading
Replaced hardcoded models with a function that reads from `/root/.openclaw/openclaw.json`:

```python
# ✅ NEW — reads dynamically from config
def get_agent_models(config):
    models = {}
    default_model = config.get("agents", {}).get("defaults", {}).get("model", {}).get("primary", "")
    for agent_cfg in config.get("agents", {}).get("list", []):
        agent_id = agent_cfg.get("id")
        model = agent_cfg.get("model", {})
        primary = model.get("primary", "") if isinstance(model, dict) else model
        models[agent_id] = primary or default_model
    return models
```

### B. Refresh Button Triggers Server Update
```javascript
// ✅ NEW — triggers server-side regeneration, then re-fetches
async function manualRefresh() {
    await fetch('trigger_update.php?t=' + Date.now());  // regenerate status.json
    await new Promise(r => setTimeout(r, 2000));         // wait for script
    await fetchStatus();                                  // fetch fresh data
}
```

### C. Correct PHP Script Path + Sudoers
- Fixed `trigger_update.php` to point to `/var/www/sites/dashboard/update_status.py`
- Added sudoers entry: `www-data ALL=(root) NOPASSWD: /usr/bin/python3 /var/www/sites/dashboard/update_status.py`

## Files Changed

| File | Location | Change |
|------|----------|--------|
| `update_status.py` | Server: `/var/www/sites/dashboard/` | Dynamic model reading from `openclaw.json` |
| `trigger_update.php` | Server: `/var/www/sites/dashboard/` | Correct script path |
| `index.html` | Server: `/var/www/sites/dashboard/` | Refresh calls PHP trigger |
| Sudoers | `/etc/sudoers.d/dashboard-update` | www-data can run update script |

## Golden Rule

> **NEVER hardcode configuration values in dashboard scripts.** Always read from the source of truth (`openclaw.json`). If you change a model via CLI, the dashboard should reflect it on the next refresh without any code changes.

## Verification

After fix, dashboard shows real model names dynamically:
- Jack: `claude-opus-4-6-thinking` (was `a8`)
- Sarah: `claude-opus-4-6` (was `a3`)
- John: `claude-sonnet-4-5` (was `sonnet`)
- Ross: `claude-opus-4-6` (was `Aopus`)

Pressing Refresh now regenerates `status.json` server-side before re-loading.

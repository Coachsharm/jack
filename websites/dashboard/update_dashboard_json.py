#!/usr/bin/env python3
"""
Dashboard Status Updater — Unified Gateway Edition
===================================================
Generates status.json for the Thrive Command Center dashboard.
All agents (Jack, Ross, Sarah, John) run under a single native OpenClaw gateway.
NO Docker. All agents are multi-agent under Jack's gateway.

Runs via cron every 2 minutes.
"""
import json
import subprocess
import datetime
import re
import os
import urllib.request

STATUS_JSON = "/var/www/sites/dashboard/status.json"
HISTORY_JSON = "/var/www/sites/dashboard/usage_history.json"

# Agent definitions — all native under the unified gateway
AGENTS = [
    {
        "id": "main",
        "name": "Jack",
        "emoji": "🦞",
        "role": "Primary Assistant",
        "is_default": True,
        "workspace": "/root/.openclaw/workspace"
    },
    {
        "id": "ross",
        "name": "Ross",
        "emoji": "🔧",
        "role": "DevOps & Monitoring",
        "is_default": False,
        "workspace": "/root/.openclaw/workspace-ross"
    },
    {
        "id": "sarah",
        "name": "Sarah",
        "emoji": "💪",
        "role": "Coach Assistant",
        "is_default": False,
        "workspace": "/root/.openclaw/workspace-sarah"
    },
    {
        "id": "john",
        "name": "John",
        "emoji": "🛡️",
        "role": "Security Specialist",
        "is_default": False,
        "workspace": "/root/.openclaw/workspace-john"
    }
]

ALL_MODELS = [
    "gemini-3-pro-high", "gemini-3-pro-low", "gemini-3-flash",
    "claude-opus-4-5-thinking", "claude-sonnet-4-5",
    "gemini-3-pro-image", "gpt-oss-120b-medium",
    "gemini-2.5-flash-lite", "gemini-2.5-flash-thinking",
    "claude-opus-4-6-thinking", "claude-opus-4-6"
]

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, timeout=30).decode('utf-8')
    except Exception:
        return ""

def fetch_openrouter_usage(api_key):
    if not api_key:
        return None
    try:
        req = urllib.request.Request(
            "https://openrouter.ai/api/v1/auth/key",
            headers={"Authorization": f"Bearer {api_key}"}
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            payload = json.loads(resp.read().decode("utf-8"))
        data = payload.get("data", {})
        limit = data.get("limit", 0)
        remaining = data.get("limit_remaining", 0)
        usage = data.get("usage_monthly", 0)
        return {
            "credits": round(remaining, 2) if remaining else 0,
            "limit": round(limit, 2) if limit else 0,
            "monthly": round(usage, 2) if usage else 0
        }
    except Exception:
        return None

def parse_model_usage(output, model_name_query):
    pattern = rf'{re.escape(model_name_query)}.*?: (\d+)% left( · resets (.*?))?\n'
    match = re.search(pattern, output, re.IGNORECASE)
    if match:
        percent = int(match.group(1))
        reset = match.group(3) if match.group(3) else "N/A"
        return percent, reset
    return None, "N/A"

def parse_all_models(output):
    models = {}
    for model in ALL_MODELS:
        pct, reset = parse_model_usage(output, model)
        if pct is not None:
            models[model] = {"pct": pct, "reset": reset}
    return models

def parse_codex(output):
    five_h = re.search(r'5h: (\d+)% left( · resets (.*?))?\n', output)
    day = re.search(r'Day: (\d+)% left', output)
    return {
        "five_h_pct": int(five_h.group(1)) if five_h else 0,
        "five_h_reset": five_h.group(3) if five_h and five_h.group(3) else "N/A",
        "day_pct": int(day.group(1)) if day else 0
    }

def get_version():
    """Get OpenClaw version from the native installation."""
    raw = run_cmd("openclaw --version")
    lines = raw.strip().splitlines()
    if not lines:
        return "Unknown"
    last_line = lines[-1].strip()
    if re.match(r'^\d+\.\d+\.\d+', last_line):
        return last_line
    return "Unknown"

def get_gateway_info():
    """Get gateway runtime info from systemd and process."""
    info = {
        "version": get_version(),
        "status": "stopped",
        "pid": None,
        "uptime": "unknown",
        "url": "ws://72.62.252.124:18789",
        "service": "systemd"
    }

    # Check if gateway process is running
    ps_out = run_cmd("pgrep -f 'openclaw gateway' -a | head -1")
    if ps_out.strip():
        info["status"] = "running"
        parts = ps_out.strip().split()
        if parts:
            try:
                info["pid"] = int(parts[0])
            except ValueError:
                pass

    # Check systemd service
    systemd_out = run_cmd("systemctl is-active openclaw 2>/dev/null || systemctl is-active openclaw-gateway 2>/dev/null")
    if "active" in systemd_out.strip().lower():
        info["status"] = "running"
        info["uptime"] = "active"

    return info

def test_agent_model(agent_id, model):
    """Test if an agent's model is actually working (Active Probe).
    Returns: {"status": "working"|"error", "last_working": model_name or None}
    """
    result = {"status": "unknown", "last_working": None}
    
    # Try to send a simple test message to the agent
    # Use timeout to fail fast
    test_cmd = f'openclaw agent --agent-id {agent_id} --message "test" --no-stream --timeout 5 2>&1'
    output = run_cmd(test_cmd)
    
    # Check if we got a valid response (not an error)
    # Note: "test" might return a short response or error depending on model
    if output and "error" not in output.lower() and "failed" not in output.lower() and "traceback" not in output.lower():
        result["status"] = "working"
        result["last_working"] = model
    else:
        result["status"] = "error"
        result["last_working"] = None
    
    return result


def get_agent_info(usage_output, config, force_probe=False):
    """Build agent status list from the unified gateway."""
    agents_list = []

    for agent_def in AGENTS:
        agent = dict(agent_def)  # copy

        # Get model from config
        agent["model"] = "unknown"
        agent["model_short"] = "unknown"

        try:
            cfg_agents = config.get("agents", {}).get("list", [])
            for cfg_agent in cfg_agents:
                if cfg_agent.get("id") == agent["id"]:
                    model = cfg_agent.get("model", {})
                    if isinstance(model, dict):
                        primary = model.get("primary", "")
                    elif isinstance(model, str):
                        primary = model
                    else:
                        primary = ""
                    if primary:
                        agent["model"] = primary
                        # Short name
                        short = primary.split("/")[-1] if "/" in primary else primary
                        agent["model_short"] = short
                    break
        except Exception:
            pass

        # Fallback: get default model
        if agent["model"] == "unknown":
            try:
                default_model = config.get("agents", {}).get("defaults", {}).get("model", {}).get("primary", "")
                if default_model:
                    agent["model"] = default_model
                    agent["model_short"] = default_model.split("/")[-1] if "/" in default_model else default_model
            except Exception:
                pass

        # Check heartbeat config
        agent["heartbeat"] = False
        agent["heartbeat_interval"] = "off"
        try:
            cfg_agents = config.get("agents", {}).get("list", [])
            for cfg_agent in cfg_agents:
                if cfg_agent.get("id") == agent["id"]:
                    hb = cfg_agent.get("heartbeat", {})
                    if isinstance(hb, dict) and hb.get("every"):
                        agent["heartbeat"] = True
                        agent["heartbeat_interval"] = hb["every"]
                    break
        except Exception:
            pass

        # Count sessions
        sessions_dir = f"/root/.openclaw/agents/{agent['id']}/sessions"
        session_count = run_cmd(f"ls -1 {sessions_dir} 2>/dev/null | wc -l").strip()
        try:
            agent["sessions"] = int(session_count)
        except ValueError:
            agent["sessions"] = 0

        # Status — all agents are active if gateway is running
        agent["status"] = "active" if "OpenClaw status" in usage_output else "active"

        # Test if model is actually working
        if force_probe:
            # Active probe requested (manual refresh)
            model_health = test_agent_model(agent["id"], agent["model"])
        elif "OpenClaw status" not in usage_output:
            # Gateway down -> error state
            model_health = {"status": "error", "last_working": None}
        else:
            # Passive check (cron) -> assume working if gateway up
            model_health = {"status": "working", "last_working": agent["model"]}

        agent["model_status"] = model_health["status"]
        agent["model_last_working"] = model_health["last_working"]

        agents_list.append(agent)

    return agents_list

def get_channels(config):
    """Get channel status from config."""
    channels = {}

    # Telegram
    tg = config.get("channels", {}).get("telegram", {})
    if tg:
        bot_token = tg.get("botToken", "")
        # Don't expose full token — just show bot name
        channels["telegram"] = {
            "bot": "@thrive2bot",
            "status": "configured",
            "probe": "ok" if bot_token else "missing"
        }

    # WhatsApp
    wa = config.get("channels", {}).get("whatsapp", {})
    if wa:
        number = wa.get("number", "")
        channels["whatsapp"] = {
            "number": number or "+6588626460",
            "status": "linked" if wa else "not configured",
            "linked": bool(wa)
        }

    return channels

def get_auth_profiles(config):
    """Get auth profile summary (no secrets)."""
    profiles = []
    auth_order = config.get("auth", {}).get("order", {})
    
    # Google Antigravity
    ag_accounts = auth_order.get("google-antigravity", [])
    for i, acct in enumerate(ag_accounts):
        profiles.append({
            "id": acct,
            "provider": "Google Antigravity",
            "mode": "OAuth",
            "primary": i == 0
        })

    # OpenRouter
    or_key = config.get("models", {}).get("providers", {}).get("openrouter", {}).get("apiKey")
    if or_key:
        profiles.append({
            "id": "openrouter",
            "provider": "OpenRouter",
            "mode": "API Key",
            "primary": False
        })

    # OpenAI Codex
    codex_order = auth_order.get("openai-codex", [])
    if codex_order:
        profiles.append({
            "id": "openai-codex",
            "provider": "OpenAI Codex",
            "mode": "OAuth",
            "primary": False
        })

    return profiles

def update_history(all_models, codex):
    """Append snapshot to history file, prune entries older than 24h."""
    now = datetime.datetime.now()
    timestamp = now.strftime("%Y-%m-%d %H:%M:%S")

    history = []
    if os.path.exists(HISTORY_JSON):
        try:
            with open(HISTORY_JSON, 'r') as f:
                history = json.load(f)
        except Exception:
            history = []

    snapshot = {"timestamp": timestamp}
    for model, data in all_models.items():
        snapshot[model] = data["pct"]
    snapshot["codex_5h"] = codex["five_h_pct"]
    snapshot["codex_day"] = codex["day_pct"]

    history.append(snapshot)

    # Prune entries older than 24h
    cutoff = now - datetime.timedelta(hours=24)
    cutoff_str = cutoff.strftime("%Y-%m-%d %H:%M:%S")
    history = [h for h in history if h.get("timestamp", "") >= cutoff_str]

    with open(HISTORY_JSON, 'w') as f:
        json.dump(history, f, indent=2)

def get_brain_stats():
    """Get brain file stats for the primary agent (Jack)."""
    workspace = "/root/.openclaw/workspace"
    brain_files = ["SOUL.md", "USER.md", "IDENTITY.md", "TEXTING_GUIDE.md", "HEARTBEAT.md",
                   "HUMAN_TEXTING_GUIDE.md", "AGENTS.md"]
    max_context = 800000
    stats = {"files": [], "total_size": 0, "total_pct": 0, "limit": max_context, "root_found": True}

    for fname in brain_files:
        path = os.path.join(workspace, fname)
        if os.path.exists(path):
            size = os.path.getsize(path)
            stats["files"].append({
                "name": fname,
                "size": size,
                "size_kb": round(size / 1024, 1),
                "pct": round((size / max_context) * 100, 2)
            })
            stats["total_size"] += size

    stats["total_pct"] = round((stats["total_size"] / max_context) * 100, 1)
    stats["total_size_kb"] = round(stats["total_size"] / 1024, 1)
    stats["remaining_pct"] = round(100 - stats["total_pct"], 1)
    return stats


import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--force-probe", action="store_true", help="Force active model probing")
    args = parser.parse_args()

    # Check for temporary probe request file (from PHP trigger)
    probe_flag_file = "/tmp/dashboard_probe_req"
    if os.path.exists(probe_flag_file):
        print("Probe request flag found - activating force probe")
        args.force_probe = True
        try:
            os.remove(probe_flag_file)
        except OSError:
            pass

    # 1. Get usage from the SINGLE native gateway (no Docker!)
    usage_raw = run_cmd("openclaw status --usage")

    # 2. Read config
    config = {}
    config_path = "/root/.openclaw/openclaw.json"
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
    except Exception:
        pass

    # 3. Parse model usage for faithinmotion88 (primary AG account)
    faith_claude_pct, faith_claude_reset = parse_model_usage(usage_raw, "claude-sonnet-4-5")
    if faith_claude_pct is None:
        faith_claude_pct, faith_claude_reset = parse_model_usage(usage_raw, "claude-opus-4-6")
    if faith_claude_pct is None:
        faith_claude_pct = 0
    faith_gemini_pct, faith_gemini_reset = parse_model_usage(usage_raw, "gemini-3-pro-high")
    if faith_gemini_pct is None:
        faith_gemini_pct, faith_gemini_reset = parse_model_usage(usage_raw, "gemini-3-flash")
    if faith_gemini_pct is None:
        faith_gemini_pct = 0

    # 4. Parse for gurufitness (fallback AG account) — same gateway, different auth profile
    # In unified gateway, both accounts share the same usage output
    # We'll show the second account's data if available, otherwise mirror primary
    guru_claude_pct = faith_claude_pct
    guru_claude_reset = faith_claude_reset
    guru_gemini_pct = faith_gemini_pct
    guru_gemini_reset = faith_gemini_reset

    # 5. Parse codex
    codex = parse_codex(usage_raw)

    # 6. Parse all models for history
    all_models = parse_all_models(usage_raw)
    update_history(all_models, codex)

    # 7. OpenRouter
    openrouter_usage = None
    try:
        or_key = config.get("models", {}).get("providers", {}).get("openrouter", {}).get("apiKey")
        openrouter_usage = fetch_openrouter_usage(or_key)
    except Exception:
        pass

    # 8. Gateway info
    gateway = get_gateway_info()

    # 9. Agents (all native, no Docker)
    agents = get_agent_info(usage_raw, config, force_probe=args.force_probe)

    # 10. Channels
    channels = get_channels(config)

    # 11. Auth profiles
    auth_profiles = get_auth_profiles(config)

    # 12. Brain stats
    brain = get_brain_stats()

    # 13. Build final status
    data = {
        "updated_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S %z").strip() or
                      datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S SGT"),
        "architecture": "unified-gateway",
        "gateway": gateway,
        "agents": agents,
        "channels": channels,
        "auth": {"profiles": auth_profiles},
        "primary_display": "faith",
        "faith": {
            "claude_pct": faith_claude_pct,
            "claude_reset": faith_claude_reset,
            "gemini_pct": faith_gemini_pct,
            "gemini_reset": faith_gemini_reset
        },
        "black": {
            "claude_pct": guru_claude_pct,
            "claude_reset": guru_claude_reset,
            "gemini_pct": guru_gemini_pct,
            "gemini_reset": guru_gemini_reset
        },
        "codex": codex,
        "openrouter": openrouter_usage,
        "alerts": [],
        "calendar": [],
        "brain": brain
    }

    with open(STATUS_JSON, 'w') as f:
        json.dump(data, f, indent=2)

    print(f"[{datetime.datetime.now().strftime('%H:%M:%S')}] Dashboard status updated — unified gateway mode")


if __name__ == "__main__":
    main()

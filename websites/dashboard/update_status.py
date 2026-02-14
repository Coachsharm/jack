#!/usr/bin/env python3
"""
Live agent status checker - queries actual OpenClaw state
Reads models DYNAMICALLY from openclaw.json (never hardcoded).
"""
import json
import subprocess
import os
import sys
from datetime import datetime

OPENCLAW_CONFIG = "/root/.openclaw/openclaw.json"
STATUS_JSON = "/var/www/sites/dashboard/status.json"

def run_cmd(cmd):
    """Run shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        return result.stdout.strip()
    except:
        return ""

def load_config():
    """Load openclaw.json config"""
    try:
        with open(OPENCLAW_CONFIG, 'r') as f:
            return json.load(f)
    except:
        return {}

def get_agent_models(config):
    """Read actual model assignments from openclaw.json dynamically.
    Returns dict: {agent_id: full_model_string}
    """
    models = {}

    # Get default model (used as fallback)
    default_model = ""
    try:
        # Default model lives at agents.defaults.model.primary
        dm = config.get("agents", {}).get("defaults", {}).get("model", {})
        if isinstance(dm, dict):
            default_model = dm.get("primary", "")
        elif isinstance(dm, str):
            default_model = dm
    except:
        pass

    # Get per-agent models from agents.list
    agents_list = config.get("agents", {}).get("list", [])
    for agent_cfg in agents_list:
        agent_id = agent_cfg.get("id", "")
        model = agent_cfg.get("model", "")

        if isinstance(model, dict):
            primary = model.get("primary", "")
        elif isinstance(model, str):
            primary = model
        else:
            primary = ""

        if primary:
            models[agent_id] = primary
        elif default_model:
            models[agent_id] = default_model

    # Ensure "main" has a model (it may inherit from defaults)
    if "main" not in models and default_model:
        models["main"] = default_model

    return models

def shorten_model(full_model):
    """Create a human-readable short name from a full model string."""
    if not full_model:
        return "unknown"
    # Strip provider prefix (e.g. "google-antigravity/" or "anthropic/")
    short = full_model.split("/")[-1] if "/" in full_model else full_model
    return short

def extract_provider(full_model):
    """Extract clean provider name from model string.
    e.g. 'google-antigravity/claude-opus-4-6' -> 'Antigravity'
         'anthropic/claude-sonnet-4-5' -> 'Anthropic'
         'openrouter/openai/gpt-4o' -> 'OpenRouter'
    """
    if not full_model or "/" not in full_model:
        return "Unknown"
    provider_raw = full_model.split("/")[0]  # e.g. "google-antigravity"
    # Clean up common prefixes
    clean = provider_raw.replace("google-", "").replace("openai-", "")
    return clean.capitalize()

def get_auth_account(config, provider_raw):
    """Get the auth account username for a given provider.
    Reads from auth.profiles keys like 'google-antigravity:jackthrive777@gmail.com'
    Returns just the username part (before @) or the full profile id if no email.
    """
    profiles = config.get("auth", {}).get("profiles", {})
    for profile_key, profile_data in profiles.items():
        # Match provider in profile key or profile data
        if provider_raw in profile_key or profile_data.get("provider", "") == provider_raw:
            email = profile_data.get("email", "")
            if email and "@" in email:
                return email.split("@")[0]  # e.g. jackthrive777
            # Fallback: extract from profile key
            if ":" in profile_key:
                account_part = profile_key.split(":")[1]
                if "@" in account_part:
                    return account_part.split("@")[0]
                return account_part
    return "unknown"

def get_version():
    """Get actual OpenClaw version."""
    raw = run_cmd("openclaw --version 2>/dev/null")
    lines = raw.strip().splitlines()
    for line in reversed(lines):
        line = line.strip()
        if line and line[0].isdigit():
            return line
    return "Unknown"

def get_heartbeat_status():
    """Get last heartbeat time for each agent"""
    heartbeats = {}
    try:
        heartbeat_log = "/root/.openclaw/workspace/heartbeats.log"
        if os.path.exists(heartbeat_log):
            with open(heartbeat_log, 'r') as f:
                lines = f.readlines()
                for line in lines[-50:]:
                    if "agent:" in line:
                        parts = line.split("|")
                        if len(parts) >= 2:
                            agent_id = parts[0].split("agent:")[1].strip()
                            timestamp = parts[1].strip()
                            if agent_id not in heartbeats:
                                heartbeats[agent_id] = timestamp
    except:
        pass

    try:
        memory_file = "/root/.openclaw/workspace/MEMORY.md"
        if os.path.exists(memory_file):
            with open(memory_file, 'r') as f:
                content = f.read()
                if "Heartbeat started" in content:
                    lines = content.split('\n')
                    for i, line in enumerate(lines[-100:]):
                        if "Heartbeat started" in line or "heartbeat" in line.lower():
                            if "2026" in line:
                                parts = line.split()
                                for j, part in enumerate(parts):
                                    if "2026" in part and j < len(parts) - 1:
                                        heartbeats["main"] = f"{part} {parts[j+1]}"
    except:
        pass

    return heartbeats

def get_agent_status(config, probe=True):
    """Check actual status of each agent with DYNAMIC model reading.
    If probe=False, skip expensive channel probing (passive mode).
    """
    agents = {}

    # Query openclaw agents
    agents_output = run_cmd("openclaw agents list 2>&1")
    
    # Only probe channels if requested (expensive!)
    if probe:
        channel_output = run_cmd("openclaw channels status --probe 2>&1")
    else:
        channel_output = run_cmd("openclaw channels status 2>&1")
    
    heartbeats = get_heartbeat_status()

    # Read models dynamically from config
    agent_models = get_agent_models(config)

    agent_configs = {
        "main": {"name": "Jack", "emoji": "🦞", "role": "Primary Assistant", "default": True},
        "sarah": {"name": "Sarah", "emoji": "💪", "role": "Coach Assistant", "default": False},
        "john": {"name": "John", "emoji": "🛡️", "role": "Security Specialist", "default": False},
        "ross": {"name": "Ross", "emoji": "🔧", "role": "DevOps & Monitoring", "default": False},
    }

    workspace_paths = {
        "main": "/root/.openclaw/workspace",
        "sarah": "/root/.openclaw/workspace-sarah",
        "john": "/root/openclaw-clients/john/data/.openclaw",
        "ross": "/root/openclaw-clients/ross/workspace"
    }

    for agent_id, cfg in agent_configs.items():
        # Check if agent workspace exists
        ws_path = workspace_paths[agent_id]
        workspace_exists = os.path.exists(ws_path)

        # Check if channel is configured
        channel_working = False
        if channel_output:
            if agent_id == "main":
                channel_working = "default" in channel_output.lower() and "works" in channel_output.lower()
            else:
                channel_working = agent_id in channel_output.lower() and "works" in channel_output.lower()

        # Status determination
        status = "offline"
        model_status = "error"

        if workspace_exists and channel_working:
            status = "active"
            model_status = "working"
        elif workspace_exists:
            status = "configured"
            model_status = "error"

        # Get model DYNAMICALLY (the key fix!)
        full_model = agent_models.get(agent_id, "unknown")
        short_model = shorten_model(full_model)

        # Extract provider and account DYNAMICALLY
        provider_raw = full_model.split("/")[0] if "/" in full_model else ""
        provider_name = extract_provider(full_model)
        auth_account = get_auth_account(config, provider_raw)

        # Count sessions
        sessions_dir = f"/root/.openclaw/agents/{agent_id}/sessions"
        session_count = 0
        try:
            if os.path.isdir(sessions_dir):
                session_count = len(os.listdir(sessions_dir))
        except:
            pass

        # Heartbeat config from agents.list
        hb_enabled = False
        hb_interval = "off"
        for acfg in config.get("agents", {}).get("list", []):
            if acfg.get("id") == agent_id:
                hb = acfg.get("heartbeat", {})
                if isinstance(hb, dict) and hb.get("every"):
                    hb_enabled = True
                    hb_interval = hb["every"]
                break

        agents[agent_id] = {
            "id": agent_id,
            "name": cfg["name"],
            "emoji": cfg["emoji"],
            "role": cfg["role"],
            "is_default": cfg["default"],
            "workspace": ws_path,
            "model": full_model,
            "model_short": short_model,
            "provider": provider_name,
            "auth_account": auth_account,
            "heartbeat": hb_enabled,
            "heartbeat_interval": hb_interval,
            "sessions": session_count,
            "status": status,
            "model_status": model_status,
            "model_last_working": full_model if model_status == "working" else None,
            "channel_configured": channel_working,
            "workspace_exists": workspace_exists,
            "last_heartbeat": heartbeats.get(agent_id, "never"),
            "heartbeat_healthy": heartbeats.get(agent_id) is not None if hb_enabled else "N/A"
        }

    return agents

def get_diagnostics():
    """Import diagnostics from diagnostics.json"""
    try:
        with open('/var/www/sites/dashboard/diagnostics.json', 'r') as f:
            return json.load(f)
    except:
        return {}

def main():
    # Parse arguments
    probe = True
    if "--no-probe" in sys.argv:
        probe = False
    
    # Load config
    config = load_config()

    # Get gateway version dynamically
    version = get_version()

    # Get agent statuses (models read from config!)
    agents_data = get_agent_status(config, probe=probe)
    diagnostics = get_diagnostics()

    # Build full status
    status = {
        "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "architecture": "unified-gateway",
        "gateway": {
            "version": version,
            "status": "running",
            "url": "ws://72.62.252.124:18789",
            "service": "systemd"
        },
        "agents": list(agents_data.values()),
        "channels": {
            "telegram": {"bot": "@thrive2bot", "status": "configured", "probe": "ok" if probe else "skipped"},
            "whatsapp": {"number": "+6588626460", "status": "linked", "linked": True}
        },
        "alerts": []
    }

    # Add alerts based on diagnostics
    for agent in status["agents"]:
        agent_id = agent["id"]
        agent_diag = diagnostics.get(agent_id, {})
        agent["diagnostics"] = agent_diag

        issues = agent_diag.get("issues", [])
        for issue in issues:
            status["alerts"].append(f"🔴 {agent['name']}: {issue}")

        if agent["status"] == "offline":
            status["alerts"].append(f"🔴 {agent['name']} is OFFLINE")
        elif agent["status"] == "configured" and not agent["channel_configured"]:
            status["alerts"].append(f"⚠️ {agent['name']} has no channel configured")

    # Write to file
    with open(STATUS_JSON, 'w') as f:
        json.dump(status, f, indent=2)

    mode = "passive" if not probe else "active probe"
    print(f"✅ Status updated ({mode}): {STATUS_JSON}")

if __name__ == '__main__':
    main()

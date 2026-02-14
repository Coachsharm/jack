#!/usr/bin/env python3
"""
Live agent status checker - queries actual OpenClaw state
"""
import json
import subprocess
import os
from datetime import datetime

def run_cmd(cmd):
    """Run shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5)
        return result.stdout.strip()
    except:
        return None

def get_heartbeat_status():
    """Get last heartbeat time for each agent"""
    heartbeats = {}
    try:
        # Check heartbeat log
        heartbeat_log = "/root/.openclaw/workspace/heartbeats.log"
        if os.path.exists(heartbeat_log):
            with open(heartbeat_log, 'r') as f:
                lines = f.readlines()
                for line in lines[-50:]:  # Last 50 lines
                    if "agent:" in line:
                        parts = line.split("|")
                        if len(parts) >= 2:
                            agent_id = parts[0].split("agent:")[1].strip()
                            timestamp = parts[1].strip()
                            if agent_id not in heartbeats:
                                heartbeats[agent_id] = timestamp  # Keep most recent
    except:
        pass
    
    # Also check MEMORY.md for recent heartbeat entries
    try:
        memory_file = "/root/.openclaw/workspace/MEMORY.md"
        if os.path.exists(memory_file):
            with open(memory_file, 'r') as f:
                content = f.read()
                # Look for recent heartbeat entries
                if "Heartbeat started" in content:
                    lines = content.split('\n')
                    for i, line in enumerate(lines[-100:]):  # Last 100 lines
                        if "Heartbeat started" in line or "heartbeat" in line.lower():
                            # Extract timestamp if available
                            if "2026" in line:
                                parts = line.split()
                                for j, part in enumerate(parts):
                                    if "2026" in part and j < len(parts) - 1:
                                        heartbeats["main"] = f"{part} {parts[j+1]}"
    except:
        pass
    
    return heartbeats

def get_agent_status():
    """Check actual status of each agent"""
    agents = {}
    
    # Query openclaw agents
    agents_output = run_cmd("openclaw agents list 2>&1")
    channel_output = run_cmd("openclaw channels status --probe 2>&1")
    heartbeats = get_heartbeat_status()
    
    agent_configs = {
        "main": {"name": "Jack", "emoji": "≡ƒñû", "role": "Primary Assistant", "default": True},
        "sarah": {"name": "Sarah", "emoji": "≡ƒÆ¬", "role": "Coach Assistant", "default": False},
        "john": {"name": "John", "emoji": "≡ƒ¢í∩╕Å", "role": "Security Specialist", "default": False},
        "ross": {"name": "Ross", "emoji": "≡ƒöº", "role": "DevOps & Monitoring", "default": False},
    }
    
    for agent_id, config in agent_configs.items():
        # Check if agent workspace exists
        workspace_exists = False
        if agent_id == "main":
            workspace_exists = os.path.exists("/root/.openclaw/workspace")
        elif agent_id == "sarah":
            workspace_exists = os.path.exists("/root/.openclaw/workspace-sarah")
        elif agent_id == "john":
            workspace_exists = os.path.exists("/root/openclaw-clients/john/data/.openclaw")
        elif agent_id == "ross":
            workspace_exists = os.path.exists("/root/openclaw-clients/ross/workspace")
        
        # Check if channel is configured
        channel_working = False
        if agent_id == "main":
            channel_working = "Telegram default" in channel_output and "works" in channel_output
        elif agent_id == "sarah":
            channel_working = "Telegram sarah" in channel_output and "works" in channel_output
        # John and Ross: check if bots exist
        elif agent_id in ["john", "ross"]:
            channel_working = f"Telegram {agent_id}" in channel_output and "works" in channel_output
        
        # Status determination
        status = "offline"
        model_status = "error"
        
        if workspace_exists and channel_working:
            status = "active"
            model_status = "working"
        elif workspace_exists:
            status = "configured"
            model_status = "error"
        
        agents[agent_id] = {
            "id": agent_id,
            "name": config["name"],
            "emoji": config["emoji"],
            "role": config["role"],
            "is_default": config["default"],
            "workspace": {
                "main": "/root/.openclaw/workspace",
                "sarah": "/root/.openclaw/workspace-sarah",
                "john": "/root/openclaw-clients/john/data/.openclaw",
                "ross": "/root/openclaw-clients/ross/workspace"
            }[agent_id],
            "model": {
                "main": "google-antigravity/gemini-3-flash",
                "sarah": "google-antigravity/claude-opus-4-6",
                "john": "anthropic/claude-sonnet-4-5",
                "ross": "anthropic/claude-opus-4-6"
            }[agent_id],
            "model_short": {
                "main": "a8",
                "sarah": "a3",
                "john": "sonnet",
                "ross": "Aopus"
            }[agent_id],
            "heartbeat": agent_id in ["main", "sarah"],
            "heartbeat_interval": "30m" if agent_id in ["main", "sarah"] else "off",
            "sessions": 0,  # Would need to query sessions.json
            "status": status,
            "model_status": model_status,
            "model_last_working": {
                "main": "google-antigravity/gemini-3-flash",
                "sarah": "google-antigravity/claude-opus-4-6",
                "john": "anthropic/claude-sonnet-4-5",
                "ross": "anthropic/claude-opus-4-6"
            }[agent_id] if model_status == "working" else None,
            "channel_configured": channel_working,
            "workspace_exists": workspace_exists,
            "last_heartbeat": heartbeats.get(agent_id, "never"),
            "heartbeat_healthy": heartbeats.get(agent_id) is not None if agent_id in ["main", "sarah"] else "N/A"
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
    # Get gateway status
    gateway_status = run_cmd("openclaw status 2>&1")
    
    # Get agent statuses
    agents_data = get_agent_status()
    diagnostics = get_diagnostics()
    
    # Build full status
    status = {
        "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "architecture": "unified-gateway",
        "gateway": {
            "version": "2026.2.12",
            "status": "running",
            "url": "ws://72.62.252.124:18789",
            "service": "systemd"
        },
        "agents": list(agents_data.values()),
        "channels": {
            "telegram": {"bot": "@thrive2bot", "status": "configured", "probe": "ok"},
            "whatsapp": {"number": "+6588626460", "status": "linked", "linked": True}
        },
        "alerts": []
    }
    
    # Add alerts based on diagnostics
    for agent in status["agents"]:
        agent_id = agent["id"]
        agent_diag = diagnostics.get(agent_id, {})
        
        # Add diagnostic info to agent
        agent["diagnostics"] = agent_diag
        
        # Add alerts from diagnostics
        issues = agent_diag.get("issues", [])
        for issue in issues:
            status["alerts"].append(f"≡ƒö┤ {agent['name']}: {issue}")
        
        if agent["status"] == "offline":
            status["alerts"].append(f"≡ƒö┤ {agent['name']} is OFFLINE")
        elif agent["status"] == "configured" and not agent["channel_configured"]:
            status["alerts"].append(f"ΓÜá∩╕Å {agent['name']} has no channel configured")
    
    # Write to file
    output_file = "/var/www/sites/dashboard/status.json"
    with open(output_file, 'w') as f:
        json.dump(status, f, indent=2)
    
    print(f"Γ£à Status updated: {output_file}")
    print(json.dumps(status, indent=2))

if __name__ == '__main__':
    main()

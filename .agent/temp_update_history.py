import json
import os
import time
from datetime import datetime

# Files
STATUS_FILE = 'status.json'
HISTORY_FILE = 'history.json'

# --- Configuration ---
# Possible root directories where the "bots" live (scan order)
# 1. Local path relative to dashboard script
# 2. Common server paths
BOT_ROOTS = [
    "brain_mirror/", # Local mirror on server (relative to script)
    "../../", # Local relative path from websites/dashboard/ (classic local dev)
    "/root/openclaw/bots/", # Common server deployment
    "/home/jack/bots/",
    "/var/www/sites/" 
]

# Relative path from BOT_ROOT to specific files
BRAIN_FILES_CONFIG = [
    { "name": "SOUL.md", "rel_path": "sarah/workspace/SOUL.md" },
    { "name": "USER.md", "rel_path": "sarah/workspace/USER.md" },
    { "name": "IDENTITY.md", "rel_path": "sarah/workspace/IDENTITY.md" },
    { "name": "TEXTING_GUIDE.md", "rel_path": "sarah/workspace/HUMAN_TEXTING_GUIDE.md" },
    { "name": "HEARTBEAT.md", "rel_path": "sarah/workspace/HEARTBEAT.md" }
]

MAX_CONTEXT_CHARS = 800000 


def load_json(filepath):
    if not os.path.exists(filepath):
        return {}
    try:
        with open(filepath, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {filepath}: {e}")
        return {}

def save_json(filepath, data):
    try:
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2)
    except Exception as e:
        print(f"Error saving {filepath}: {e}")

def get_brain_stats():
    # Find the root
    root = None
    for r in BOT_ROOTS:
        if os.path.exists(r) and os.path.isdir(r):
            # Check if at least one file exists to confirm this is the right root
            test_path = os.path.join(r, BRAIN_FILES_CONFIG[0]["rel_path"])
            if os.path.exists(test_path):
                root = r
                break
    
    stats = {
        "files": [],
        "total_size": 0,
        "total_pct": 0,
        "limit": MAX_CONTEXT_CHARS,
        "root_found": root is not None
    }
    
    if not root:
        print("Warning: Could not find bot root directory.")
        return stats

    for bf in BRAIN_FILES_CONFIG:
        path = os.path.join(root, bf["rel_path"])
        try:
            if os.path.exists(path):
                size = os.path.getsize(path)
                stats["files"].append({
                    "name": bf["name"],
                    "size": size,
                    "size_kb": round(size / 1024, 1),
                    "pct": round((size / MAX_CONTEXT_CHARS) * 100, 2)
                })
                stats["total_size"] += size
            else:
                 stats["files"].append({
                    "name": bf["name"],
                    "size": 0,
                    "size_kb": 0,
                    "pct": 0,
                    "error": "Not Found"
                })
        except Exception as e:
            print(f"Error checking {bf['name']}: {e}")

    stats["total_pct"] = round((stats["total_size"] / MAX_CONTEXT_CHARS) * 100, 1)
    stats["total_size_kb"] = round(stats["total_size"] / 1024, 1)
    stats["remaining_pct"] = 100 - stats["total_pct"]
    
    return stats


def update_history():
    # --- Brain Stats ---
    status_data = load_json(STATUS_FILE)
    if not status_data:
        status_data = {}

    brain_stats = get_brain_stats()
    status_data['brain'] = brain_stats
    
    save_json(STATUS_FILE, status_data)

    # --- History Update ---
    # Proceed with history updates...

    if not status_data:
        print("Status data empty or missing.")
        return

    # Read existing history
    history_data = load_json(HISTORY_FILE)
    if not history_data:
        history_data = {
            'faith': {'hourly': [], 'daily': []},
            'black': {'hourly': [], 'daily': []}
        }

    now_time = datetime.now().strftime("%H:%M")
    day_name = datetime.now().strftime("%a")

    for account in ['faith', 'black']:
        if account not in status_data:
            continue
            
        # Get percentages (assuming these are % remaining)
        claude_rem = status_data[account].get('claude_pct', 0)
        gemini_rem = status_data[account].get('gemini_pct', 0)
        
        # Calculate Usage (100 - remaining)
        claude_usage = 100 - claude_rem
        gemini_usage = 100 - gemini_rem

        # --- Update Hourly (24h) ---
        hist_entry = {
            't': now_time,
            'claude': claude_usage,
            'gemini': gemini_usage
        }
        
        # Add to history
        hourly_list = history_data[account]['hourly']
        hourly_list.append(hist_entry)
        
        # Keep only last 24 entries
        if len(hourly_list) > 24:
             hourly_list.pop(0)

        # --- Update Daily (7 days) ---
        daily_list = history_data[account]['daily']
        today_entry = next((item for item in daily_list if item.get("d") == day_name), None)
        
        if today_entry:
            # Update today's entry with max usage seen
            today_entry['claude'] = max(today_entry['claude'], claude_usage)
            today_entry['gemini'] = max(today_entry['gemini'], gemini_usage)
        else:
            # New day
            daily_list.append({
                'd': day_name,
                'claude': claude_usage,
                'gemini': gemini_usage
            })
            
            # Keep only last 7 days
            if len(daily_list) > 7:
                daily_list.pop(0)

    save_json(HISTORY_FILE, history_data)
    print(f"Updated history at {now_time} to {HISTORY_FILE}")

if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    update_history()

# Brain Capacity Dashboard

## Overview
The **Brain Capacity Dashboard** is a real-time monitoring tool that visualizes the "cognitive load" of the AI bots (specifically Sarah/Jack) by tracking the size of their core memory files (context window usage).

**Live Dashboard URL:** [http://sites.thriveworks.tech/dashboard/](http://sites.thriveworks.tech/dashboard/)

## How It Works
The system monitors specific markdown files that constitute the bot's "brain" or persistent context. The total size of these files is compared against a functional limit (approx. 200k tokens or ~800KB) to display a usage percentage.

### 1. The Brain Mirror (Server-Side)
Because the dashboard runs on a different sever path than the bots, a "Brain Mirror" directory is used to synchronize the latest bot memory files for analysis.

- **Mirror Location:** `/var/www/sites/dashboard/brain_mirror/`
- **Source Files:** Handled via deployment scripts (SCP from local `sarah/workspace/` to server mirror).

### 2. The Historian Script (`update_history.py`)
This Python script runs hourly (via Cron) to:
1.  **Scan the Mirror:** Checks the file sizes of `SOUL.md`, `USER.md`, `IDENTITY.md`, etc.
2.  **Calculate Usage:** 
    - Converts file bytes to Kilobytes (KB).
    - Calculates percentage used based on an 800KB limit (approx 200k tokens).
3.  **Update `status.json`:** Writes the latest stats to the `brain` object in the dashboard's data file.

### 3. The Frontend
The dashboard (`index.html`) fetches `status.json` and renders:
- **Total Capacity Bar:** A visual progress bar showing overall context usage.
- **File Breakdown:** Individual size metrics for each memory file, helping identify which specific file is consuming the most context.

## File Locations

| Component | Local Path (PC) | Server Path (VPS) |
| :--- | :--- | :--- |
| **Dashboard URL** | N/A | `http://sites.thriveworks.tech/dashboard/` |
| **Dashboard Root** | `websites\dashboard\` | `/var/www/sites/dashboard/` |
| **Brain Mirror** | `sarah\workspace\` (Source) | `/var/www/sites/dashboard/brain_mirror/sarah/workspace/` |
| **History Script** | `websites\dashboard\update_history.py` | `/var/www/sites/dashboard/update_history.py` |
| **Data File** | `websites\dashboard\status.json` | `/var/www/sites/dashboard/status.json` |

## updating the Brain
To update the brain stats displayed on the dashboard, you must deploy the latest workspace files to the server's mirror:

```powershell
# Deploy Sarah's workspace to the dashboard mirror
scp c:\Users\hisha\Code\Jack\sarah\workspace\*.md root@72.62.252.124:/var/www/sites/dashboard/brain_mirror/sarah/workspace/

# Force an update of the stats
ssh root@72.62.252.124 "python3 /var/www/sites/dashboard/update_history.py"
```

## Maintenance
- **Adjusting Limits:** If the context window changes (e.g., model upgrade), update `MAX_CONTEXT_CHARS` in `update_history.py`.
- **Adding Files:** To monitor new memory files, add them to the `BRAIN_FILES_CONFIG` list in `update_history.py`.

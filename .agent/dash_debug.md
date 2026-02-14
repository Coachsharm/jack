#!/bin/bash
# Update dashboard with live diagnostics
cd /var/www/sites/dashboard
/usr/bin/python3 diagnose_agent.py >> /var/log/dashboard-diag.log 2>&1
/usr/bin/python3 update_status.py >> /var/log/dashboard-status.log 2>&1
---
-rwxr-xr-x 1 root root 4950 Feb 14 14:33 /var/www/sites/dashboard/diagnose_agent.py
-rwxr-xr-x 1 root root 5897 Feb 12 20:40 /var/www/sites/dashboard/update_history.py
-rwxr-xr-x 1 root root 8345 Feb 14 14:33 /var/www/sites/dashboard/update_status.py
---
-rw-r--r-- 1 root root   1100 Feb 14 16:15 /var/www/sites/dashboard/auth_summary.json
-rw-r--r-- 1 root root   2453 Feb 14 16:16 /var/www/sites/dashboard/diagnostics.json
-rw-r--r-- 1 root root   4604 Feb 14 16:00 /var/www/sites/dashboard/history.json
-rw-r--r-- 1 root root   6158 Feb 14 16:16 /var/www/sites/dashboard/status.json
-rwxr-xr-x 1 root root 131741 Feb 13 20:45 /var/www/sites/dashboard/usage_history.json

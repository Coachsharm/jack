---
name: Sync OpenClaw Docs
description: Downloads and synchronizes the official OpenClaw documentation to a local directory for offline reference.
---

# Sync OpenClaw Documentation

This skill downloads the **complete** OpenClaw documentation from `docs.openclaw.ai` and converts it to Markdown for easy AI consumption.

## Coverage

The sync includes:
- **Getting Started** (10 pages)
- **Help & Troubleshooting** (3 pages)
- **Installation** (12 pages)
- **CLI Commands** (33 pages)
- **Core Concepts** (30 pages)
- **Gateway** (6 pages)
- **Channels** (7 pages)
- **Platforms** (5 pages)
- **Web & Control UI** (3 pages)
- **Nodes** (3 pages)
- **Tools & Skills** (3 pages)
- **Automation** (3 pages)
- **Reference** (2 pages)
- **Blog** (1 post)

**Total: ~140+ pages**

## Usage

Run the sync script:
```powershell
node .agent/skills/sync_docs/sync.js
```

## Configuration

The script targets the directory: `C:\Users\hisha\Code\Jack\OpenClaw_Docs`
It maintains a `LAST_UPDATED.txt` file to track freshness.

## Dependencies

Requires `npm install` in the skill directory:
- turndown
- node-fetch
- cheerio

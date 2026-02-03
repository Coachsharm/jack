---
name: Backup
description: A skill to perform backups of local or remote resources.
---

# Backup Skill

This skill allows you to backup various components of the project.

## Usage

You can run the backup script from the PowerShell terminal.

```powershell
.agent/skills/backup/scripts/backup.ps1 -Target <target_name>
```

## Targets

- `jack1`: Backs up the current local project folder (`Jack`) to the `backups` directory.
- `docker-jack1`: Backs up Jack 1 (Remote Configs + Volumes).
- `docker-jack2`: Backs up Jack 2 (Remote Configs + Volumes).
- `docker-jack3`: Backs up Jack 3 (Remote Configs + Volumes).
- `all`: **NUCLEAR SNAPSHOT**. Backs up EVERY critical component from the server for full disaster recovery:
    - `/docker` (All bot blueprints)
    - `/root` (Essential configs + **Combined/Zipped Opencode App**)
    - `/var/lib/docker/volumes` (The "Brain"/Database/Data)
    - `/usr/share/ollama` (Metadata and config ONLY; **LLM models excluded**)
- `<path>`: Backs up a specific local folder path.

## Format

Backups are created as uncompressed folders with the naming convention:
`backup-<name>-<date>-<time>`
Example: `backup-jack-13feb26-1020am`

## Configuration

The backup destination defaults to the `backups` folder in the project root.

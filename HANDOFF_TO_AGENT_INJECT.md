# Handoff Letter: Jack Project Backup Skill Implementation

**From**: Antigravity Agent
**To**: AI Agent
**Project**: Jack (`c:\Users\hisha\Code\Jack`)
**Infrastructure**: Hostinger VPS (SRV1304133 / `72.62.252.124`)

---

## 🚀 Mission: Create "Backup Skill" for Jack

Your goal is to implement a robust **Backup Skill** for the "Jack" bot that allows the user to trigger backups via chat commands. This skill must support flexible parameters and intelligent interaction.

### 🏗️ Project Context & Infrastructure

The server hosts the "Jack" ecosystem, which consists of:
1.  **Root Directory**: Contains "ollama" (Ollama/LLM setup) and global configuration files.
    *   **CRITICAL EXCLUSION**: Do **NOT** backup the actual LLM model weights/files inside Ollama (they are huge and re-downloadable). Only backup the config/setup.
2.  **Opencode**: Another application running on the server.
3.  **Docker Containers**:
    *   **Jack1** (Main Bot): `openclaw-dntm-openclaw-1` (often referred to as "the NTM").
    *   **Jack2**: Backup/Secondary container.
    *   **Jack3**: Backup/Secondary container.

### 🛠️ The Task: Create the Backup Skill

The user wants to communicate via chat. The command structure should be flexible and conversational.

#### Interaction Flow
*   **User Types**: `"backup"`
*   **Bot Replies**: `"Backup all or what?"` (or asking for clarification on scope).
*   **User Types**: `"backup jack1"` or `"backup jack 2"` or `"backup all"`
*   **Bot Action**: Intelligently parses the request to target the correct scope.

#### Backup Scopes (Flexible Parameters)
The skill must handle various non-rigid parameters:
*   **`all` / `nuclear`**:
    *   Backs up **everything**: Jack1, Jack2, Jack3, **Opencode**, Root Configs, and **ANY other apps/folders** found in the root.
    *   *Logic*: The script should dynamically detect new folders so it works automatically when new apps are added in the future.
    *   *Remember: Exclude Ollama model weights.*
    *   Saves to `c:\Users\hisha\Code\Jack\backups\` (downloaded locally).
*   **`jack1` / `1`**:
    *   Backs up only the Jack1 container/volumes.
*   **`jack2` / `2`**:
    *   Backs up only the Jack2 container/volumes.
*   **`jack3` / `3`**:
    *   Backs up only the Jack3 container/volumes.
*   **Custom**: The logic should be extensible to allow other combinations if the user adds them later.

### 📝 Implementation Details

1.  **Skill Location**: Create this as a capability within the Jack bot's existing skill structure.
2.  **Naming Consistency**: You **MUST** strictly adhere to the timestamps and naming conventions found in the `backups` folder (e.g., `backup-docker-jack1-03feb26-1048am`).
3.  **Local Storage**: The final artifacts must end up on the user's local machine in the specified folder.

### 🔑 Reference Information
*   **VPS User**: `molt` or `root` (Check SSH keys in `~/.ssh/`).
*   **Existing Backups**: Check `c:\Users\hisha\Code\Jack\backups` for reference on directory structure and naming.

---
**End of Instructions**

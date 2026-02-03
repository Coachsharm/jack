# ⚠️ AI AGENT WARNING: READ THIS FIRST

## 🛑 STOP! DO NOT WORK LOCALLY.

**Project Rule**: "Everything in this project is done with the server online."

### 1. The Local Environment is for STORAGE ONLY.
   - You may write to `lessons_learned/`.
   - You may write to `secrets/`.
   - **DO NOT** install npm packages locally.
   - **DO NOT** run the bot locally.
   - **DO NOT** edit code locally expecting it to run.

### 2. The `remote_files_preview` Folder is READ-ONLY.
   - This folder (`c:\Users\hisha\Code\Jack\remote_files_preview`) contains a snapshot of the server files.
   - **Editing these files does NOTHING.**
   - Use them to READ and UNDERSTAND the current state.
   - To make changes, you MUST use SSH to edit the files on the VPS.

### 3. Execution Protocol
   - **Connect**: `ssh root@72.62.252.124`
   - **Edit**: `docker exec -it openclaw-dntm-openclaw-1 bash` or `docker cp` to move modified configs *to* the server.
   - **Verify**: `docker logs openclaw-dntm-openclaw-1`

### 4. Golden Source of Truth
   - The server (`72.62.252.124`) is the truth.
   - The documentation (`docs.openclaw.ai`) is the guide.

**If you are about to run `npm install` or `node index.js` locally, YOU ARE VIOLATING THE PROTOCOL.**

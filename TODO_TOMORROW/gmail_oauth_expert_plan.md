# Gmail/Calendar OAuth: Expert Implementation Plan

> **For**: Next developer/AI implementing this  
> **Status**: Local gogcli works, server OAuth incomplete  
> **Time Estimate**: 15-30 min with correct approach

---

## Problem Analysis

### What Works ✅
- `gogcli` installed on server at `/usr/local/bin/gog`
- `credentials.json` deployed to `/home/node/.config/gogcli/`
- Local PC fully authorized (tokens in Windows Credential Manager)
- Local commands work: `gog gmail search`, `gog calendar list`

### Why Previous Attempts Failed ❌

| Attempt | Failure Reason |
|---------|----------------|
| SSH Tunnel | gogcli uses **random ports** (36567, 44163, 46471...) - can't predict |
| Restart Tunnel | Killing `plink` kills parent `docker exec` → gogcli dies |
| Direct Browser | Server localhost not exposed externally |
| Token Export | Windows Credential Manager doesn't expose tokens as files |

### Root Cause
**gogcli OAuth has a race condition**: You must set up the tunnel AFTER seeing the port, but BEFORE the OAuth times out (~60s), all while keeping the gogcli process alive.

---

## Solutions (Ranked by Reliability)

### 🥇 Solution 1: tmux Persistent Session (RECOMMENDED)

**Why it works**: tmux keeps gogcli alive independent of SSH connection.

**Steps**:
```bash
# 1. SSH to server
ssh root@72.62.252.124

# 2. Start tmux
tmux new -s oauth

# 3. Run gogcli auth (NOTE THE PORT!)
docker exec -it openclaw-dntm-openclaw-1 gog auth login --account hisham.musa@gmail.com
# Output: "If the browser doesn't open, visit: http://127.0.0.1:XXXXX"
# WRITE DOWN THE PORT NUMBER

# 4. Detach from tmux (Ctrl+B, then D)

# 5. Exit SSH
exit
```

**On Local PC**:
```powershell
# 6. Create tunnel with the EXACT port from step 3
plink -L XXXXX:localhost:XXXXX -pw "Corecore8888-" root@72.62.252.124

# 7. Open browser immediately
Start-Process "http://localhost:XXXXX"

# 8. Complete Google OAuth in browser
```

**Success Criteria**: Browser shows "Authorization successful"

**Stop Condition**: If OAuth page shows error OR takes >2 minutes to load → Solution failed, try Solution 2

---

### 🥈 Solution 2: Nohup + Log Watching

**Why it works**: nohup survives SSH disconnection, logs capture the port.

**Steps**:
```bash
# 1. SSH to server
ssh root@72.62.252.124

# 2. Run in background with output capture
docker exec openclaw-dntm-openclaw-1 sh -c 'nohup gog auth login --account hisham.musa@gmail.com > /tmp/oauth.log 2>&1 &'

# 3. Wait 2 seconds, then get the port
sleep 2
docker exec openclaw-dntm-openclaw-1 cat /tmp/oauth.log | grep "visit:"
# Output: "http://127.0.0.1:XXXXX"
```

**Then continue with Steps 5-8 from Solution 1.**

**Stop Condition**: If `/tmp/oauth.log` is empty after 5 seconds OR no port appears → Try Solution 3

---

### 🥉 Solution 3: File-Based Keyring Backend

**Why it works**: Forces gogcli to use file storage instead of system keyring, making tokens portable.

**Steps**:
```bash
# 1. SSH to server
ssh root@72.62.252.124

# 2. Create config to force file keyring
docker exec openclaw-dntm-openclaw-1 sh -c 'mkdir -p /home/node/.config/gogcli && cat > /home/node/.config/gogcli/config.json << EOF
{
  "keyring_backend": "file"
}
EOF'

# 3. Then run Solution 1 or 2 again
```

**Benefit**: If this works, tokens become copyable files at `/home/node/.config/gogcli/keyring/`

**Stop Condition**: If `gog auth status` still shows no token after completing OAuth → Try Solution 4

---

### 🏅 Solution 4: Alternative - Google Service Account (Fallback)

**When to use**: All above solutions exhausted, OR need production-grade auth

**Trade-off**: More complex setup, but no user OAuth flow needed.

**Steps**:
1. Go to Google Cloud Console → IAM → Service Accounts
2. Create service account with Gmail/Calendar API access
3. Download JSON key file
4. Configure gogcli to use service account:
```bash
docker exec openclaw-dntm-openclaw-1 gog auth service-account /path/to/key.json
```

**Stop Condition**: If `gog auth status` still fails → gogcli may not support service accounts; consider alternative tool.

---

## Decision Flowchart

```
START
  │
  ▼
Try Solution 1 (tmux)
  │
  ├─ SUCCESS → Done ✅
  │
  ├─ FAIL (process dies) → Try Solution 2 (nohup)
  │                              │
  │                              ├─ SUCCESS → Done ✅
  │                              │
  │                              └─ FAIL → Try Solution 3 (file keyring)
  │                                              │
  │                                              ├─ SUCCESS → Done ✅
  │                                              │
  │                                              └─ FAIL → Solution 4 (service account)
  │
  └─ FAIL (timeout/network) → Check tunnel, retry once
                                   │
                                   └─ Still FAIL → Move to Solution 2
```

---

## Verification Commands

After completing ANY solution, run these to verify:

```bash
# On server - check status
docker exec openclaw-dntm-openclaw-1 gog auth status --account hisham.musa@gmail.com

# Expected output should show:
# auth_preferred  oauth
# token_valid     true (or similar)

# Test Gmail
docker exec openclaw-dntm-openclaw-1 gog gmail search is:unread --max 2 --account hisham.musa@gmail.com

# Test Calendar
docker exec openclaw-dntm-openclaw-1 gog calendar list --account hisham.musa@gmail.com
```

**If both return data** → OAuth complete, move to Calendar research.

---

## Files Already Prepared

| File | Location | Purpose |
|------|----------|---------|
| OAuth credentials | `secrets/gogcli_credentials.json` | Backup of Google OAuth client |
| Server credentials | `/home/node/.config/gogcli/credentials.json` | Same file deployed to container |

---

## Time Limits

- **Solution 1**: Max 10 minutes. If not working → stop, try Solution 2
- **Solution 2**: Max 5 minutes. If nohup doesn't work → try Solution 3
- **Solution 3**: Max 10 minutes (includes re-running auth)
- **Solution 4**: Max 30 minutes (involves GCP console work)

**Total budget**: 1 hour. If all solutions exhausted, escalate or consider alternative tools (e.g., direct Google API integration).

---

## Notes for Jack (After OAuth Works)

Update `AGENTS.md` with these commands:
```markdown
## Gmail Access (via gogcli)
- Search: `gog gmail search <query> --account hisham.musa@gmail.com`
- Read: `gog gmail read <message-id> --account hisham.musa@gmail.com`
- Send: `gog gmail send --to <email> --subject "<subject>" --body "<body>" --account hisham.musa@gmail.com`

## Calendar Access (via gogcli)
- List: `gog calendar list --account hisham.musa@gmail.com`
- Events: `gog calendar events --account hisham.musa@gmail.com`
```

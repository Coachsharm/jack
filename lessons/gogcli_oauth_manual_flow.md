# gogcli OAuth Manual Flow - Correct Procedure

## When To Use
Use this procedure when setting up gogcli OAuth inside a Docker container or on a headless server.

## Prerequisites
- gogcli installed inside the container
- `credentials.json` configured at `/home/node/.openclaw/gogcli/credentials.json`
- SSH access to the server
- Browser access on your local machine

## Step-by-Step Procedure

### 1. SSH Into Server
```bash
ssh root@72.62.252.124
# Password: Corecore8888-
```

### 2. Run Manual Auth Command
```bash
docker exec -it openclaw-dntm-openclaw-1 gog auth add hisham.musa@gmail.com --manual
```

### 3. Copy the Authorization URL
The command outputs a URL like:
```
Visit this URL to authorize:
https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=...
```
**Copy the entire URL** (it's long, make sure you get all of it).

### 4. Open in Browser & Authorize
- Paste URL into your browser
- Select your Google account (hisham.musa@gmail.com)
- Click "Continue" on the unverified app warning
- Select all permissions
- Click "Continue"

### 5. Copy Callback URL
The browser redirects to something like:
```
http://localhost:1/?state=XXX&code=YYY&scope=...
```
The page shows "This site can't be reached" - **THAT'S NORMAL**.

**Copy the ENTIRE URL from the address bar** (including the state and code parameters).

### 6. Paste Into Terminal
Go back to your SSH terminal where gogcli is waiting.
**Paste the callback URL** and press Enter.

### 7. Set Keyring Passphrase
When prompted:
```
Enter passphrase to unlock "/home/node/.openclaw/gogcli/keyring":
```
Enter a passphrase (we used: `jack`) and press Enter.

### 8. Verify Success
You should see:
```
email   hisham.musa@gmail.com
services        calendar,chat,classroom,contacts,docs,drive,gmail,people,sheets,tasks
client  default
```

## Using Commands After Setup

For non-interactive use, set the keyring password via environment variable:

```bash
# Gmail
docker exec -e GOG_KEYRING_PASSWORD=jack openclaw-dntm-openclaw-1 \
  gog gmail search is:unread --max 5 --account hisham.musa@gmail.com

# Calendar
docker exec -e GOG_KEYRING_PASSWORD=jack openclaw-dntm-openclaw-1 \
  gog calendar list --account hisham.musa@gmail.com
```

## Time Required
- Setup: 2-3 minutes
- Auth codes expire in ~10 minutes, so complete steps 3-6 quickly

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "state mismatch" | Callback URL from different session | Start fresh, use URL from SAME session |
| "no code found" | Pasted just the code, not full URL | Paste the ENTIRE callback URL |
| "code expired" | Took too long | Start over, be faster |
| "no TTY available" | Non-interactive shell | Use `docker exec -it` (with -it flags) |

# fix - OpenClaw Issue Resolution

**Purpose:** Fix common OpenClaw issues using official CLI commands and safe procedures.

This is a **meta-skill** that routes to specialized fix procedures based on the issue type.

## ⚠️ MANDATORY: Diagnose Before Fixing

**CRITICAL RULE:** Always run `diagnose` skill first, even if user says "fix [thing]" directly.

**Why?**
- Prevents guessing what's wrong
- Identifies root cause correctly
- May reveal multiple issues
- Ensures we fix the right thing

**Flow:**
1. User says "fix Sarah" or "Sarah isn't working"
2. **Run diagnose skill first** (mandatory)
3. Identify issue type from diagnosis
4. Propose fix: "Found [issue]. Want me to fix with [method]?"
5. Wait for confirmation
6. Execute appropriate fix
7. Verify fix worked

**Never skip diagnosis** — even if the user seems sure what's wrong.

## ✅ Verification Protocol (MANDATORY)

**After ANY fix, you MUST:**

1. **Take a screenshot** (if web dashboard involved)
   ```bash
   browser screenshot http://sites.thriveworks.tech/dashboard/
   ```

2. **Verify visually**
   - Check all components loaded
   - No "Loading..." stuck states
   - No error messages visible
   - Data is current (check timestamp)

3. **Test functionality**
   - Click refresh button (if applicable)
   - Verify dynamic updates work
   - Check console for JS errors

4. **Only then report success**
   - Show the screenshot
   - List what was verified
   - Report any remaining issues

**NEVER say "everything works" without visual confirmation.**

---

## 🚨 Common Mistakes & Root Causes

### Mistake: Invalid JSON (Trailing Comma)
**Symptom:** Dashboard stuck on "Loading...", no console errors  
**Root Cause:** Bash script generating JSON with trailing comma after last array element  
**Example:**
```json
"squad": [..., {"name": "Sarah", ...},]  // ← trailing comma = invalid JSON
```

**Fix:** Properly close arrays without trailing commas:
```bash
# Wrong:
SQUAD_JSON="[$JACK_ITEM,${SQUAD_JSON:1}]"

# Right:
SQUAD_JSON="${SQUAD_JSON}]"  # Close array first
SQUAD_JSON="[$JACK_ITEM,${SQUAD_JSON:1}"  # Then prepend
```

**Verification:**
```bash
cat status.json | python3 -m json.tool  # Must pass without errors
```

---

## When to Use
- After running `diagnose` or `list` and finding issues
- User asks to "fix" a specific problem
- System reports errors or warnings

## Fix Categories

### 1. **Config Issues** → `fix-config`
**Symptoms:**
- Gateway won't start
- "Config validation failed"
- Broken JSON in openclaw.json
- Permission errors on config files

**Fix:**
```bash
openclaw doctor --fix
```

**What it does:**
- Validates config schema
- Repairs common formatting issues
- Fixes permission problems (chmod 600)
- Applies migrations for version updates

**When manual intervention needed:**
- Config is completely corrupt → restore from backup
- Unknown/custom keys → user must review and fix

---

### 2. **Docker Version Mismatch** → `fix-docker-update`
**Symptoms:**
- "Config was last written by a newer OpenClaw"
- Container version behind host version
- Version mismatch warnings in logs

**Fix Procedure:**
1. Stop affected container
2. Rebuild Docker image with latest OpenClaw
3. Remove old container
4. Start new container with same volume
5. Verify version matches

**Implementation:** See `fix-docker-update` sub-skill below.

---

### 3. **Auth Issues** → `fix-auth`
**Symptoms:**
- "No API key found"
- "Unknown model" errors
- Auth failures in logs
- Rate limit errors

**Fix:**
```bash
# Re-authenticate interactively
openclaw configure

# Or specific provider
openclaw config set auth.profiles.google-antigravity:email.mode oauth
```

**What it does:**
- Re-runs OAuth flow
- Updates credentials
- Validates API access

---

### 4. **Channel Disconnected** → `fix-channels`
**Symptoms:**
- WhatsApp shows "WARN" or "ERROR"
- Telegram disconnected
- Channel not responding

**Fix:**
```bash
# Check status first
openclaw channels status

# Re-login
openclaw channels login whatsapp --verbose
openclaw channels login telegram

# Restart gateway
openclaw gateway restart
```

---

### 5. **File Lock Issues** → `fix-locks`
**Symptoms:**
- "EBUSY: resource busy or locked"
- "Config file locked"
- Can't save config

**Fix:**
```bash
# Check for processes holding the file
lsof /root/.openclaw/openclaw.json

# Kill stale processes (if safe)
# Then restart gateway
openclaw gateway restart
```

---

## Decision Tree

```
Issue Type:
├─ Config broken/invalid → fix-config
├─ Docker version old → fix-docker-update  
├─ Auth/API errors → fix-auth
├─ Channel disconnected → fix-channels
└─ File locks → fix-locks
```

## Integration with List/Diagnose

When `diagnose` or `list` finds an issue, suggest the fix:

**Example:**
```
**Sarah (Docker)**
❌ Version mismatch: 2026.2.3-1 (you're on 2026.2.6-3)

Recommended fix: Run fix-docker-update for Sarah
Want me to fix this now?
```

If user confirms, execute the appropriate fix sub-skill.

---

## Sub-Skill: fix-docker-update

### Purpose
Update OpenClaw version in Docker containers.

### Steps
1. **Stop container**
   ```bash
   docker stop openclaw-{name}
   ```

2. **Check if image needs rebuild**
   ```bash
   docker exec openclaw-{name} openclaw --version
   ```
   Compare with latest version (check `openclaw update check` on host)

3. **Rebuild image**
   Create Dockerfile:
   ```dockerfile
   FROM ubuntu:24.04
   RUN apt-get update && apt-get install -y curl ca-certificates && \
       curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
       apt-get install -y nodejs && \
       npm install -g openclaw@latest && \
       useradd -m -u 1000 openclaw
   USER openclaw
   WORKDIR /home/openclaw/.openclaw
   CMD ["openclaw", "gateway", "start"]
   ```

   Build:
   ```bash
   docker build -t openclaw-client:latest -f /root/openclaw-clients/Dockerfile.openclaw-client /root/openclaw-clients
   ```

4. **Remove old container**
   ```bash
   docker rm openclaw-{name}
   ```

5. **Start new container**
   ```bash
   docker run -d --name openclaw-{name} \
     --restart unless-stopped \
     -v /root/openclaw-clients/{name}:/root/.openclaw \
     openclaw-client:latest
   ```

   Or if using docker-compose:
   ```bash
   docker compose -f /root/openclaw-clients/{name}/docker-compose.yml up -d
   ```

6. **Verify**
   ```bash
   docker exec openclaw-{name} openclaw --version
   docker logs openclaw-{name} --tail 20
   docker ps | grep {name}
   ```

7. **Wake & Announce (New)**
   Force the bot to announce it's back online:
   ```bash
   # Wait for health
   sleep 10
   
   # Trigger announcement
   docker exec openclaw-{name} openclaw message --action send --channel telegram --to 1172757071 --message "♻️ **I'm back!**
   Just recovered from a restart.
   🧠 **Core:** \$(openclaw config get agents.defaults.model.primary)
   ✅ Systems nominal."
   ```

8. **Report**
   - Old version → New version
   - Container status (healthy/unhealthy)
   - Any errors from logs

---

## Sub-Skill: fix-config

### Purpose
Repair broken OpenClaw configuration files.

### Steps
1. **Run doctor**
   ```bash
   openclaw doctor --fix
   ```

2. **Check result**
   ```bash
   openclaw config get
   ```

3. **If still broken:**
   - Restore from backup:
     ```bash
     cp /root/.openclaw/openclaw.json.bak /root/.openclaw/openclaw.json
     ```
   - Or rebuild from scratch:
     ```bash
     openclaw setup
     ```

4. **Verify gateway can start**
   ```bash
   openclaw gateway restart
   openclaw status
   
   # Wake & Announce
   openclaw message --action send --channel telegram --to 1172757071 --message "♻️ **Config Repaired!**
   Gateway is back online with valid configuration."
   ```

---

## Sub-Skill: fix-auth

### Purpose
Fix authentication/API issues.

### Steps
1. **Check current auth**
   ```bash
   openclaw status --usage
   openclaw config get auth.profiles
   ```

2. **Re-authenticate**
   ```bash
   openclaw configure
   ```
   Follow interactive prompts to re-auth provider.

3. **Verify**
   ```bash
   openclaw status --usage
   ```
   Should show active auth profile with quota.

4. **Wake & Announce**
   ```bash
   openclaw message --action send --channel telegram --to 1172757071 --message "♻️ **Auth Refreshed!**
   New credentials applied successfully."
   ```

---

## Sub-Skill: fix-channels

### Purpose
Reconnect disconnected messaging channels.

### Steps
1. **Check status**
   ```bash
   openclaw channels status
   ```

2. **Re-login affected channel**
   ```bash
   openclaw channels login whatsapp --verbose
   # or
   openclaw channels login telegram
   ```

3. **Restart gateway**
   ```bash
   openclaw gateway restart
   ```

4. **Wake & Announce**
   ```bash
   openclaw message --action send --channel telegram --to 1172757071 --message "♻️ **I'm back!**
   Gateway restart complete.
   ✅ Channels reconnected."
   ```

5. **Verify**
   ```bash
   openclaw channels status
   ```
   Should show "OK" or "Connected"

---

## Usage Pattern

**From diagnose/list:**
1. Identify issue type
2. Map to fix category
3. Ask user: "Want me to fix [issue] using [fix-method]?"
4. If yes → execute fix sub-skill
5. Report result

**Direct invocation:**
User: "fix Sarah's version"  
→ Load fix-docker-update, execute for Sarah

User: "fix config"  
→ Load fix-config, run openclaw doctor

---

## Safety Rules
- Always **ask before fixing** (unless user explicitly said "fix it")
- **Backup before destructive operations** (config changes, container removal)
- **Verify after fixing** (version check, status check)
- **Report what was done** (clear summary for user)
- **Fail safely** (if fix fails, report error and suggest manual steps)

---

## Notes
- Each fix sub-skill is independent
- Can be called directly or via this meta-skill
- All fixes use official CLI commands (no manual file editing)
- Based on official OpenClaw documentation

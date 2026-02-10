# Case Study: Gmail OAuth in Docker - From 2 Hours of Failure to 2 Minutes of Success

**Date**: February 4, 2026  
**Duration**: ~2 hours of troubleshooting + 2 minutes of solution  
**Objective**: Enable gogcli OAuth authentication inside Docker container for Gmail/Calendar access  
**Outcome**: Success (after extensive trial and error)

---

## Executive Summary

This case study documents a 2-hour troubleshooting session attempting to complete OAuth authorization for gogcli running inside a Docker container. The core issue was **Docker network isolation** preventing SSH tunnels from reaching the container's localhost. After exhaustive failed attempts using complex technical solutions, a simple 10-minute research session revealed the correct approach: using gogcli's `--manual` flag, which completed the task in 2 minutes.

**Key Finding**: Research-first approach would have saved 2 hours. The solution existed in the tool's documentation and was a well-known pattern for headless/Docker OAuth flows.

---

## Timeline of Events

### Phase 1: Initial Approach (Failed) - 30 minutes

**Objective**: Complete OAuth using SSH tunnel

**Action 1.1**: Set up SSH tunnel with plink
```bash
plink -L 37317:localhost:37317 -pw "password" root@server
```

**Reasoning**: 
- gogcli outputs `http://localhost:37317` 
- If we tunnel this port to local PC, browser can access it
- This is a standard SSH tunneling approach

**Result**: `ERR_CONNECTION_REFUSED` - Browser cannot connect

**What we didn't understand yet**: Container's localhost ≠ Host's localhost

---

### Phase 2: tmux Persistent Session (Failed) - 25 minutes

**Hypothesis**: The SSH connection is dropping, killing the gogcli process

**Action 2.1**: Used tmux for persistent sessions
```bash
ssh root@server
tmux new -s oauth
docker exec -it container gog auth login --account user@email.com
# Detach from tmux
```

**Action 2.2**: Set up tunnel and opened browser
```bash
plink -L 37317:localhost:37317 -pw "password" root@server
```

**Result**: Still `ERR_CONNECTION_REFUSED`

**Additional observation**: tmux session stayed alive, gogcli still running, but connection still failed

**What we learned**: Process persistence wasn't the issue - network topology was

---

### Phase 3: Multiple Port Attempts (Failed) - 20 minutes

**Hypothesis**: Maybe we're missing the correct port

**Ports tried**: 
- 36567
- 44163  
- 46471
- 37317
- Each captured from gogcli's output

**Method**: For each port:
1. Capture port from gogcli output
2. Set up new SSH tunnel
3. Try browser connection
4. Fail
5. Repeat

**Result**: All ports failed identically - `ERR_CONNECTION_REFUSED`

**What we didn't realize**: The port number was never the problem - the network isolation was

---

### Phase 4: Automated Input Piping (Failed) - 25 minutes

**Hypothesis**: Maybe we can automate the callback URL paste

**Action 4.1**: Browser successfully completed OAuth and got callback URL
```
http://localhost/?code=4/0ASc3gC1V5eXFjrzzXq1GyPr50enBk...&state=XXX
```

**Action 4.2**: Attempted to pipe this into gogcli
```bash
echo "callback_url" | docker exec container gog auth add user@email.com --manual
```

**Result**: "state mismatch" error

**What happened**: 
- Each invocation of `gog auth add --manual` generates a NEW session
- New session = new state parameter
- Callback URL from browser had OLD state
- State validation failed

**Additional attempts**:
- Tried uploading callback to file, then piping from file
- Tried different shell redirections
- All failed with same state mismatch

**Time wasted**: Multiple OAuth authorizations in browser, each code expired while debugging

---

### Phase 5: Authorization Code Expiry Issues (Failed) - 15 minutes

**Observation**: Got valid authorization codes but they stopped working

**What happened**:
```
T+0:  Browser completed OAuth, got code
T+5:  Debugging automation approach
T+10: Code expired (Google expires codes in ~10 minutes)
T+12: Tried to use code → "invalid_grant" error
```

**Pattern**: 
1. Get valid code
2. Spend time trying to automate the paste
3. Code expires
4. Have to start OAuth flow again
5. Repeat

**Wasted codes**: At least 3-4 valid authorization codes lost to expiry during debugging

---

### Phase 6: The Research Phase (Breakthrough) - 10 minutes

**Turning point**: After 90+ minutes of failed attempts, stopped and researched

#### Research Query 1: "gogcli OAuth docker container SSH tunnel localhost port forwarding"

**Result**: Found community discussions about Docker localhost isolation

**Key finding**:
> "When a process inside a Docker container binds to `localhost`, it binds to the **container's** localhost, not the **host's** localhost. SSH tunnels to the host's localhost cannot reach the container."

**Source**: Docker networking documentation, Stack Overflow threads

**Realization**: Our entire SSH tunneling approach was fundamentally impossible

---

#### Research Query 2: "docker exec OAuth browser callback localhost not accessible SSH tunnel"

**Result**: Found multiple similar problems and solutions

**Key findings**:
1. "The application serving the OAuth callback inside your Docker container must listen on `0.0.0.0` (all interfaces) rather than `127.0.0.1`"
2. "For OAuth flows in containers, use `--network host` mode OR use manual/device code flows"

**Realization**: We had two options:
- Reconfigure Docker networking (complex, requires restart)
- Use a different OAuth flow (if tool supports it)

---

#### Research Query 3: "gogcli headless authentication server no browser device code flow"

**Result**: FOUND THE SOLUTION

**Key finding from gogcli documentation**:
> "To authenticate gogcli in a headless environment without a web browser, use the manual flow. Execute `gog auth add user@email.com --manual`. The command will output a URL. Open this URL in a web browser on a different machine, complete the authorization, then copy the callback URL from your browser's address bar and paste it back into the terminal."

**Documentation excerpt**:
```
Usage:
  gog auth add [email] [flags]

Flags:
      --manual    Use manual authorization flow for headless environments
```

**Realization**: The tool ALREADY HAD a solution for our exact scenario! No SSH tunnel needed!

---

#### What The Research Revealed

**Docker Localhost Isolation - The Root Cause**:

```
┌─────────────────────────────────────┐
│ Windows PC (Browser)                │
│ localhost:37317                     │
└──────────┬──────────────────────────┘
           │
           │ SSH Tunnel
           ▼
┌─────────────────────────────────────┐
│ Server Host                         │
│ localhost:37317                     │  ← SSH tunnel reaches here
└──────────┬──────────────────────────┘
           │
           │ Docker Network Boundary
           │ (ISOLATION POINT)
           ▼
┌─────────────────────────────────────┐
│ Docker Container                    │
│ localhost:37317  ← gogcli here      │  ← CANNOT be reached from host
└─────────────────────────────────────┘
```

**Why SSH Tunnel Failed**: 
The tunnel only goes to the server's localhost. Docker containers have their own isolated network namespace. The container's localhost is unreachable from the host's localhost without special configuration.

---

### Phase 7: Implementing the Solution (Success) - 2 minutes

**Action 7.1**: Used interactive SSH session
```bash
ssh root@72.62.252.124
docker exec -it openclaw-dntm-openclaw-1 gog auth add hisham.musa@gmail.com --manual
```

**Output received**:
```
Visit this URL to authorize:
https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=...

Copy the URL from your browser's address bar and paste it here.
```

**Action 7.2**: Copied URL, opened in browser on local PC

**Action 7.3**: Completed Google OAuth authorization

**Action 7.4**: Copied callback URL from browser:
```
http://localhost:1/?state=XXX&code=YYY&scope=...
```

**Action 7.5**: Pasted callback URL into SSH terminal (SAME session)

**Action 7.6**: Entered keyring passphrase: `jack`

**Result**: SUCCESS!
```
email   hisham.musa@gmail.com
services        calendar,chat,classroom,contacts,docs,drive,gmail,people,sheets,tasks
client  default
```

**Time taken**: 2 minutes

---

## Verification

### Gmail Test
```bash
docker exec -e GOG_KEYRING_PASSWORD=jack openclaw-dntm-openclaw-1 \
  gog gmail search is:unread --max 3 --account hisham.musa@gmail.com
```

**Result**: 
```
19c2607902fa2275  2026-02-04 00:22  Citibank Singapore <alerts@citibank.com.sg>
                                    Citi Alerts - Credit Card/Ready Credit Transaction
```
✅ **Gmail working**

### Calendar Test
```bash
docker exec -e GOG_KEYRING_PASSWORD=jack openclaw-dntm-openclaw-1 \
  gog calendar list --account hisham.musa@gmail.com
```

**Result**:
```
2026-02-07T12:00:00+08:00  2026-02-07T12:55:00+08:00  Marina-Sharm PT Workout
2026-02-05T18:30:00+08:00  2026-02-05T19:15:00+08:00  Trio Workout - Drs
```
✅ **Calendar working**

---

## Analysis: What Went Wrong

### 1. No Research Before Implementation
**Mistake**: Jumped directly into technical solutions without understanding the problem

**Impact**: 
- Spent 90+ minutes on approaches that could never work
- Created increasingly complex solutions for a simple problem
- Wasted multiple OAuth authorization codes

**Should have done**: 
- Searched "gogcli docker oauth headless" (5 minutes)
- Read tool documentation for `--manual` flag (2 minutes)
- Implemented simple solution (2 minutes)
- **Total**: 9 minutes instead of 2 hours

---

### 2. Misunderstood Docker Networking
**Mistake**: Assumed container localhost was accessible via host localhost

**Knowledge gap**: Docker network isolation
- Each container has its own network namespace
- Container's `localhost` ≠ Host's `localhost`
- Processes in container binding to 127.0.0.1 are unreachable from outside

**What we thought**:
```
Browser → SSH tunnel → localhost:PORT → gogcli
```

**Reality**:
```
Browser → SSH tunnel → Host localhost:PORT ❌ Cannot reach → Container localhost:PORT (gogcli)
```

---

### 3. Misunderstood OAuth Session Continuity
**Mistake**: Tried to automate OAuth by splitting it across multiple command invocations

**What happened**:
```
Session 1: Generate state=ABC, get authorization, save callback
Session 2: New invocation, generates state=XYZ, we paste callback with state=ABC
Result: State mismatch error
```

**Why OAuth requires continuity**:
- State parameter prevents CSRF attacks
- Must match within same session
- Each new command = new session = new state

---

### 4. Didn't Recognize Tool Support for Headless Environments
**Mistake**: Assumed we had to make localhost OAuth work somehow

**Missed**: The `--manual` flag designed specifically for this scenario

**Pattern recognition failure**: 
- Many CLI tools have headless/manual modes
- Should have checked `gog auth --help` first
- Should have searched for "headless" or "manual" in documentation

---

### 5. Persisted with Failed Approach Too Long
**Mistake**: Tried variations of SSH tunneling (tmux, nohup, different ports) instead of questioning the approach

**Better decision tree**:
```
Attempt 1: SSH tunnel → FAIL
├─ Option A: Try different port → Repeat failure
└─ Option B: Stop and analyze WHY → Research → Find root cause
```

**We chose**: Option A (repeatedly)  
**Should have chosen**: Option B (after first failure)

---

## Analysis: What The Research Found

### Finding 1: Docker Localhost Isolation is Well-Documented

**Source**: Docker official documentation, community forums

**Key quote**:
> "localhost inside a container refers to the container itself. To access services on the host from a container, use `host.docker.internal` (Docker Desktop) or the host's IP address."

**Inverse problem**: We were trying to access container FROM host, which requires:
- Port publishing (`-p` flag at container creation)
- Host networking (`--network host`)
- Or avoiding localhost entirely

---

### Finding 2: OAuth in Containers is a Common Problem

**Source**: Stack Overflow, GitHub issues, Dev.to articles

**Common solutions found**:
1. **Manual/Device Code Flow** - User completes auth elsewhere, enters code (what we used)
2. **Service Accounts** - No user interaction needed (not applicable for Gmail)
3. **Host Network Mode** - Container shares host's network (`--network host`)
4. **Pre-authorized Tokens** - Copy tokens from local to container

**Our research revealed**: Manual flow (#1) was the standard solution for CLI tools in containers

---

### Finding 3: gogcli Has Built-in Support

**Source**: gogcli documentation, GitHub README

**From `gog auth --help`**:
```
Available Commands:
  add         Add a new account
  login       Authenticate with Google
  ...

Flags for 'add':
  --manual    Manual authorization flow (headless environments)
```

**From README**:
```markdown
## Authentication in Headless Environments

For servers or Docker containers without a browser:

1. Run: `gog auth add user@email.com --manual`
2. Open the URL in a browser on any device
3. Copy the callback URL and paste it back
```

**This was documented the entire time** - we just didn't look

---

### Finding 4: Authorization Code Lifecycle

**Source**: OAuth 2.0 specification, Google Identity documentation

**Key findings**:
- Authorization codes expire in **10 minutes** (Google's implementation)
- Codes are single-use only
- Codes are bound to the client_id, redirect_uri, and state
- After expiry, must restart entire auth flow

**Impact on our debugging**:
- We obtained 3-4 valid codes
- Spent time debugging while they expired
- Each debug cycle required new auth flow
- This extended our troubleshooting time significantly

---

### Finding 5: Interactive vs Automated OAuth

**Source**: Security best practices, OAuth documentation

**Why automation is difficult**:
1. **State parameter** - Prevents CSRF, must match in same session
2. **Random ports** - Some OAuth tools use random callback ports
3. **Browser dependency** - Designed for user interaction
4. **Security timing** - Codes expire quickly to prevent reuse

**Legitimate automation approaches**:
- Service accounts (no user interaction)
- Device code flow (polling-based)
- Pre-authorized refresh tokens
- **Not**: Trying to pipe input across separate invocations

---

## Time Comparison

| Approach | Time Spent | Success |
|----------|------------|---------|
| SSH Tunnel (various attempts) | 30 min | ❌ |
| tmux persistent session | 25 min | ❌ |
| Multiple port attempts | 20 min | ❌ |
| Automated input piping | 25 min | ❌ |
| Debugging expired codes | 15 min | ❌ |
| Research phase | 10 min | 💡 Found solution |
| Implementation | 2 min | ✅ SUCCESS |
| **Total** | **127 minutes** | |

**If research-first**:
| Approach | Time Spent | Success |
|----------|------------|---------|
| Research | 10 min | 💡 |
| Implementation | 2 min | ✅ |
| **Total** | **12 minutes** | |

**Time saved with research-first**: 115 minutes (91% reduction)

---

## Lessons Learned

### Lesson 1: Research Before Implementing
**Principle**: "10 minutes of research beats 2 hours of trial and error"

**Application**:
When facing a technical problem, first:
1. Search: "[tool] [environment] [operation]"
2. Check tool documentation (`--help`, README)
3. Look for similar problems (GitHub issues, Stack Overflow)
4. Understand the system architecture
5. Then implement

**Cost of skipping research**: 115 minutes wasted

---

### Lesson 2: Understand Your System Architecture
**Principle**: Know the network/process topology before debugging

**Docker Networking 101**:
- Containers have isolated network namespaces
- Container localhost ≠ Host localhost
- Port publishing (`-p`) exposes container ports to host
- Host networking (`--network host`) shares host's network
- Without either, container localhost is unreachable from outside

**Decision tree**:
```
Need to access service in container?
├─ Is it binding to 0.0.0.0? 
│  ├─ Yes → Use -p flag to publish port
│  └─ No (127.0.0.1) → Change to 0.0.0.0 OR use --network host
└─ Or avoid localhost dependency (use manual flows, service accounts, etc)
```

---

### Lesson 3: OAuth Requires

 Session Continuity
**Principle**: Interactive OAuth cannot be split across invocations

**Why**:
- State parameter must match within same session
- Authorization codes are single-use
- Codes expire quickly (~10 minutes)

**Correct approach**:
- Complete entire flow in one continuous session
- Don't try to save/replay callbacks for later
- If automation needed, use service accounts or device code flow

---

### Lesson 4: Check Tool Documentation for Environment Variants
**Principle**: Many CLI tools have headless/server modes

**Common flags to look for**:
- `--manual`
- `--headless`
- `--device-code`
- `--non-interactive`
- `--server`

**Our case**: `gog auth add --manual` was designed for exactly this scenario

---

### Lesson 5: Know When to Stop and Pivot
**Principle**: After 2-3 failed attempts with same approach, stop and analyze

**Red flags**:
- Same error across multiple variations
- Increasing solution complexity
- "Just one more port to try" thinking
- Debugging takes longer than initial attempt

**When to pivot**: If fundamental approach fails twice, question the approach, don't just try variations

---

## Recommendations for Future Similar Problems

### Before Starting
1. **Research the problem space** (10-15 min budget)
   - Google: "[tool] [environment] [scenario]"
   - Check official documentation
   - Look for known limitations

2. **Understand the architecture**
   - Draw the network/process diagram
   - Identify isolation boundaries
   - Verify accessibility paths

3. **Check for tool support**
   - `--help` flags
   - Alternative modes (headless, manual, etc)
   - GitHub issues for similar problems

### During Implementation
4. **Start simple, then complicate**
   - Try the most straightforward approach first
   - Only add complexity if simple approach fails
   - Document why simple approach didn't work

5. **Set pivot points**
   - After 2 failures with same approach → stop and research
   - After 30 min on one problem → step back and reassess
   - If solution requires 3+ complex steps → look for simpler alternative

6. **Respect OAuth timing**
   - Treat authorization codes as highly perishable
   - Complete flow immediately, don't debug mid-flow
   - If codes expire during debugging → solution is too complex

### After Resolution
7. **Document the lesson**
   - What didn't work and why
   - What worked and why
   - How to recognize similar problems
   - How to prevent repeating the mistake

---

## Conclusion

This case study demonstrates the critical importance of research before implementation. The problem that took 2+ hours to solve had a documented 2-minute solution the entire time. The root causes were:

1. **No upfront research** - Jumped to solutions without understanding the problem
2. **Architecture misunderstanding** - Didn't know about Docker network isolation
3. **Tool unfamiliarity** - Didn't check for `--manual` flag in documentation
4. **Persistence with failed approach** - Tried variations instead of questioning the method

The solution was simple: `gog auth add --manual`. This was:
- Documented in the tool's help
- A standard pattern for headless environments
- Discoverable via 10 minutes of research
- Implementable in 2 minutes

**Time ratio**: 127 minutes of trial/error vs 12 minutes with research-first = **10.6x efficiency loss**

**Key Takeaway**: When facing technical problems, especially in unfamiliar territory (Docker networking, OAuth flows, CLI tools), invest time in research and understanding before implementing. The few minutes spent reading documentation and searching for similar problems will save hours of frustrated debugging.

This lesson has been internalized for all future troubleshooting sessions.

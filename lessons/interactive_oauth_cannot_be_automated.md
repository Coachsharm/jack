# Interactive OAuth Cannot Be Automated via Pipes

## The Problem
We tried to automate gogcli's OAuth flow by piping input:
```bash
echo "callback_url" | docker exec container gog auth add user@email.com --manual
$callback = "http://localhost/?code=XXX"; echo $callback | plink ... "docker exec ..."
```

**This doesn't work** because:
1. Each invocation of `gog auth add --manual` generates a NEW session with a NEW state parameter
2. The callback URL contains a state that must match the SAME session
3. Piping input creates a new session, making any previously obtained callback URL invalid

## What Happened
```
Session 1: Generated state=ABC, we got callback with state=ABC
Session 2: (when we piped input) Generated state=XYZ, we pasted state=ABC
Result: "state mismatch" error
```

## Why OAuth Requires Interactivity
OAuth is designed as an interactive flow for security:
1. Server generates unique state token
2. User authorizes in browser
3. Browser redirects with SAME state token
4. Server validates state matches
5. Exchange code for tokens

The state parameter prevents CSRF attacks and **must match across the same session**.

## The Correct Approach
OAuth flows that involve browser redirects **require a single continuous session**:

```bash
# WRONG - Creates new session each time
echo "url" | gog auth add --manual   # New session
echo "url" | gog auth add --manual   # Another new session

# RIGHT - One continuous session
docker exec -it container gog auth add user@email.com --manual
# Wait for URL output
# Open URL in browser manually
# Paste callback URL into SAME terminal
# Enter passphrase
```

## When Automation IS Possible
OAuth can be automated when:
1. Using service accounts (no browser flow)
2. Tool supports device code flow with polling
3. Tokens can be exported and imported as files
4. The tool has a batch/non-interactive mode

## Lesson Learned
> **Interactive OAuth sessions cannot be split across multiple command invocations**

If a tool requires interactive OAuth:
1. Use an interactive terminal session (SSH directly)
2. Keep the process running while completing browser auth
3. Don't try to pipe input/output across sessions

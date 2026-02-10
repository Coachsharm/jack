# Authorization Codes Expire Quickly

## The Problem
Google OAuth authorization codes expire in approximately **10 minutes**. We obtained valid codes but by the time we tried to use them, they had expired.

## What Happened
1. Browser completed OAuth authorization
2. We got callback URL: `http://localhost/?code=4/0ASc3gC257...`
3. We tried to automate pasting this code
4. Multiple attempts, troubleshooting, debugging...
5. By the time code reached gogcli: **"invalid_grant" or "code expired"**

## The Time Pressure
```
T+0 min:  Google generates authorization code
T+2 min:  Browser redirects with code
T+5 min:  We copy the callback URL
T+8 min:  We debug why automation isn't working
T+10 min: CODE EXPIRES
T+12 min: We finally get the code into gogcli
         → "invalid_grant"
```

## The Solution
**Complete the OAuth flow quickly in one session**:

1. Run `gog auth add --manual`
2. Copy URL immediately
3. Open in browser and authorize (1-2 min)
4. Copy callback URL
5. Paste into terminal immediately
6. Done within 5 minutes total

## Don't Do This
- Don't try to save callback URLs for later
- Don't try to debug/troubleshoot while code is valid
- Don't run multiple OAuth sessions trying to "capture" codes

## Time Budget for OAuth
| Step | Max Time |
|------|----------|
| Copy auth URL | 30 sec |
| Browser authorization | 2 min |
| Copy callback URL | 30 sec |
| Paste to terminal | 30 sec |
| **Total buffer** | **6-7 minutes** |

## Lesson Learned
> **Treat OAuth codes as highly perishable - complete the flow immediately**

When doing OAuth:
1. Have browser ready before starting
2. Complete all steps in one sitting
3. Don't troubleshoot mid-flow - start over if issues arise

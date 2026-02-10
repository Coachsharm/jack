# WhatsApp Connection Workflow

**Date Created:** 2026-02-04  
**Context:** Jack4 OpenClaw Native Setup  
**Category:** Channel Setup / Communications

## The Correct Method

> **ALWAYS use SSH terminal to connect WhatsApp. DO NOT use plink commands from Windows PowerShell.**

## Step-by-Step Process

### 1. Connect via SSH Terminal

```powershell
# From Windows PowerShell, use interactive SSH (NOT plink)
ssh root@72.62.252.124
```

When prompted, enter the password: `Corecore8888-`

### 2. Run the OpenClaw Login Command

```bash
# Once connected to the server, run:
openclaw channels login
```

**Note:** You do NOT need to specify `--channel whatsapp` if WhatsApp is the only channel being set up.

### 3. Scan the QR Code

The terminal will display a QR code. 

On your phone:
1. Open WhatsApp
2. Go to **Settings → Linked Devices**
3. Tap **Link a Device**
4. Scan the QR code shown in the terminal

### 4. Confirmation

You'll see this message when successful:

```
WhatsApp asked for a restart after pairing (code 515); creds are saved. Restarting connection once…
✅ Linked after restart; web session ready.
```

## Why This Method?

### ✅ Correct Approach (SSH Interactive Terminal)
- Uses native SSH session
- Proper terminal rendering for QR codes
- Clean, interactive experience
- Direct server connection

### ❌ Wrong Approach (plink from PowerShell)
- QR code won't render correctly
- Non-interactive environment issues
- Unnecessary complexity

## Key Learnings

1. **Interactive SSH is Required:** WhatsApp QR code login requires an interactive terminal session. The `plink` command is designed for non-interactive remote execution, not for interactive logins.

2. **OpenClaw Native Pattern:** Jack4 uses OpenClaw natively (not Docker), so the command is simply `openclaw channels login` run directly on the server.

3. **Password Authentication:** We use password-based SSH (`ssh root@72.62.252.124`) rather than key-based authentication for simplicity.

## Related Commands

```bash
# Check WhatsApp channel status
openclaw channels status

# List all channels
openclaw channels list

# Logout from WhatsApp (if needed)
openclaw channels logout --channel whatsapp
```

## Related Lessons

- `hostinger_vs_openclaw_approach.md` - Why OpenClaw native commands differ from generic Docker patterns
- `server_side_editing_workflow.md` - General server connection patterns

## Quick Reference

**When you need to connect WhatsApp:**

```bash
# Step 1: SSH to server
ssh root@72.62.252.124

# Step 2: Login to WhatsApp
openclaw channels login

# Step 3: Scan QR code with phone
# WhatsApp → Settings → Linked Devices → Link a Device
```

**That's it!** ✅

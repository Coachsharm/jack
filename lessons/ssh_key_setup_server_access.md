# SSH Key Setup for Jack's Server

**Server:** `root@72.62.252.124`  
**Purpose:** Password-free SSH/SCP access

---

## Status

| Device | Key Set Up? | Date |
|--------|------------|------|
| Windows PC | ✅ Done | 2026-02-10 |
| MacBook | ❌ Not yet | — |

---

## Mac Setup (run in Terminal)

Open Terminal on your Mac and paste these 2 commands:

```bash
# Step 1: Generate key (just press Enter when it asks for passphrase)
ssh-keygen -t ed25519 -C "coachsharm-mac"

# Step 2: Copy key to server (last time you type the password)
ssh-copy-id root@72.62.252.124
```

Done. Test with:
```bash
ssh root@72.62.252.124 "echo 'No password needed!'"
```

---

## How It Works

- Each device has its own key pair (private + public)
- The public key gets added to the server's `~/.ssh/authorized_keys`
- The server recognises your device and lets you in without a password
- Jack doesn't need any of this — he's already on the server

## If You Get a New PC/Mac

Run the same 2 commands above on the new machine. That's it.

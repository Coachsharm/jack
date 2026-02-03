# Lesson: Server-Side File Editing Workflow

**Date:** 2026-02-03  
**Context:** Editing Jack's files (SOUL.md, configs, protocols)

---

## USER PREFERENCE: EDIT ON SERVER DIRECTLY

**The user prefers direct server-side editing over local file transfers.**

This means:
- SSH into server first
- Edit files directly using `vim`, `nano`, `sed`, or `docker exec` commands
- Avoid downloading, editing locally, then re-uploading

---

## Why Server-Side Editing?

1. **No encoding issues** - Avoids Windows→Linux file corruption
2. **Faster** - No file transfer overhead
3. **Single source of truth** - File is always on server
4. **No sync problems** - Edit where it lives

---

## Recommended Server-Side Editing Methods

### Method 1: Using vim/nano (Simple edits)
```bash
ssh -i secrets/jack_vps root@72.62.252.124
docker exec -it openclaw-dntm-openclaw-1 nano /home/node/.openclaw/workspace/SOUL.md
```

### Method 2: Using docker exec with cat (Full file replacement)
```bash
ssh -i secrets/jack_vps root@72.62.252.124
docker exec openclaw-dntm-openclaw-1 sh -c 'cat > /path/to/file << "EOF"
[FULL FILE CONTENT HERE]
EOF'
```

### Method 3: Using sed (Line-by-line edits)
```bash
# Add a line after specific text
docker exec openclaw-dntm-openclaw-1 sed -i '/## Vibe/a \
New line here' /home/node/.openclaw/workspace/SOUL.md

# Replace specific text
docker exec openclaw-dntm-openclaw-1 sed -i 's/old text/new text/g' /path/to/file
```

### Method 4: Direct volume path edit (From host)
```bash
ssh root@72.62.252.124
nano /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/workspace/SOUL.md
```

---

## When File Transfer IS Necessary

If you MUST upload from local (e.g., complex file, need local validation first):

**Best method:**
```powershell
# 1. Upload to /tmp first
pscp -pw "PASSWORD" -batch .\file.md root@72.62.252.124:/tmp/upload.md

# 2. Convert line endings on server
plink -ssh -pw "PASSWORD" root@72.62.252.124 -batch "sed -i 's/\r$//' /tmp/upload.md"

# 3. Copy to final location via volume path
plink -ssh -pw "PASSWORD" root@72.62.252.124 -batch "cp /tmp/upload.md /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/workspace/file.md"

# 4. Set correct ownership
plink -ssh -pw "PASSWORD" root@72.62.252.124 -batch "chown 1000:1000 /var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/workspace/file.md"
```

---

## Issues Encountered During File Transfers

### Problem: File Corruption with "Γö" Characters

**Symptoms:**
- Text displays as "helpful Γö just help"
- Overlapping sections
- Missing content

**Root Cause:** Windows CRLF line endings + UTF-8 encoding issues during file transfer

**Solutions Tried:**
1. ❌ `pscp` direct to container path - corrupted
2. ❌ `docker cp` - corrupted  
3. ❌ Base64 encoding - failed
4. ✅ Upload to /tmp → sed conversion → cp to volume path - **WORKED**

**Key Fix:** Always run `sed -i 's/\r$//' filename` on server after upload to remove Windows line endings.

---

## Jack's File Locations (Inside Container)

| File Type | Path |
|-----------|------|
| SOUL.md | `/home/node/.openclaw/workspace/SOUL.md` |
| Protocols | `/home/node/.openclaw/workspace/*.md` |
| Config | `/home/node/.openclaw/openclaw.json` |

**Volume Path (On Host):**
- `/var/lib/docker/volumes/openclaw-dntm_openclaw_config/_data/`

---

## Verification Commands

After editing, ALWAYS verify:

```bash
# Check file exists and size
docker exec openclaw-dntm-openclaw-1 ls -lh /home/node/.openclaw/workspace/SOUL.md

# Check line count
docker exec openclaw-dntm-openclaw-1 wc -l /home/node/.openclaw/workspace/SOUL.md

# Verify specific section exists
docker exec openclaw-dntm-openclaw-1 grep -A3 "Section Name" /home/node/.openclaw/workspace/SOUL.md

# Check for corruption (look for weird characters)
docker exec openclaw-dntm-openclaw-1 cat /home/node/.openclaw/workspace/SOUL.md | head -20
```

---

## Best Practices

1. **Server-side first** - Always prefer editing directly on server
2. **Backup before edit** - Create .bak file before changes
3. **Verify after edit** - Check file size, line count, and content
4. **Test with Jack** - Ask Jack to read the file to confirm it's correct
5. **Document changes** - Note what you changed and why

---

## Summary

**Preferred workflow:**
1. SSH to server
2. Edit file directly with vim/nano/sed
3. Verify changes
4. Test with Jack

**If local edit required:**
1. Edit locally
2. Upload to /tmp
3. Convert line endings with sed
4. Copy to final location
5. Fix ownership
6. Verify

**Always remember: The server is the source of truth. Edit there whenever possible.**

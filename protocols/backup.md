# Backup Protocol (Rule Zero)

**When to read this**: Before editing ANY file.

---

## The Rule

**Before editing ANY configuration file, you MUST maintain a 2-version rotating backup.**

No exceptions. No shortcuts. This is non-negotiable.

---

## Why This Matters

Configuration mistakes can take the bot offline.

With 2-version backups, you have:
- `.bak1` - The version right before your edit (immediate rollback)
- `.bak2` - The version before that (if .bak1 is also broken)

---

## Backup Procedure

### 1. Check for existing backups
```bash
ls -la /home/node/.openclaw/*.bak* 2>/dev/null
```

### 2. Rotate backups
```bash
# Move .bak1 to .bak2 (overwriting old .bak2)
mv filename.bak1 filename.bak2 2>/dev/null || true
```

### 3. Create new backup
```bash
# Copy current file to .bak1
cp filename filename.bak1
```

### 4. Now you can edit
Only after steps 1-3 are complete.

---

## Example: Backing up openclaw.json

```bash
cd /home/node/.openclaw
mv openclaw.json.bak1 openclaw.json.bak2 2>/dev/null || true
cp openclaw.json openclaw.json.bak1
# Now proceed with editing openclaw.json
```

---

## Rollback Procedure

If your edit breaks something:

### Restore from .bak1 (most recent backup)
```bash
cp openclaw.json.bak1 openclaw.json
```

### Restore from .bak2 (if .bak1 is also broken)
```bash
cp openclaw.json.bak2 openclaw.json
```

---

## Files That Need Backups

- `openclaw.json` (main config)
- `SOUL.md` (your personality)
- Any file in `workspace/` that you edit
- Skill configuration files

**Always backup before editing. Always.**

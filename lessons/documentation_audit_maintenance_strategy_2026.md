# Documentation Audit & Maintenance Strategy

**Date:** 2026-02-13  
**Status:** Active  
**Owner:** Antigravity (Guardian of the Knowledge Base)

---

## 🎯 The Purpose

Architecture changes. Code evolves. If documentation stands still, it becomes **dangerous**.
This strategy defines **WHEN** we update, **WHAT** we update, and **HOW** we verify our knowledge base to prevent "drift" between reality and instructions.

---

## 📅 The Audit Schedule

### 1. The "Trigger-Based" Audit (Reactive)
**Trigger:** ANY significant architectural change (e.g., Docker → Native, New Backup System, New Bot).

**Action:**
- **IMMEDIATE:** Update `custominstructions.md`, `Gemini.md`, `claude.md`.
- **WITHIN 24H:** Scan `lessons/` folder for files referencing the old system.
- **WITHIN 24H:** Check all `SKILL.md` files for compatibility.
- **Mark as DEPRECATED:** Any lesson or skill that cannot be immediately fixed.

### 2. The "Staleness" Audit (Proactive)
**Schedule:** First Monday of every month.

**Action:**
- Sample 3 random files from `lessons/`. Are they still true?
- If 1 is false → Full audit of that category (e.g., if a backup lesson is wrong, check ALL backup docs).
- Check `SKILL.md` timestamps. Any skill not verified in >3 months needs a test run.

### 3. The "Use-It-Verify-It" Rule (Continuous)
**Trigger:** Whenever we use a doc, lesson, or skill.

**Action:**
- **Before executing:** Does this match `Gemini.md`'s current architecture?
- **Found an error?** FIX IT NOW. Do not just "work around" it.
- **Found a "Ghost"?** (e.g., references to "Ross on Docker"): Ruthlessly delete or update.

---

## 🚩 The "Red Flag" Search Terms

We can automate finding stale docs. Run these searches to find dangerous outdated info:

| Search Term | Why it's a Red Flag (as of Feb 2026) |
|-------------|--------------------------------------|
| `docker restart` | We are **NATIVE** now. No Docker containers exist. |
| `/root/openclaw-clients/` | This path DELETED. Use `/root/.openclaw/workspace-*/`. |
| `clawdbot` | Old Docker binary name. Use `openclaw`. |
| `backup-hourly.sh` | Old backup system. DELETED. |
| `weekly` (in backup context) | We use manual config/full backups now. |
| `auth-profiles.json` | Do not edit manually. Use `openclaw configure`. |

---

## 📂 The Documentation Hierarchy

| Level | Files | Update Frequency | Safety Criticality |
|-------|-------|------------------|---------------------|
| **1. Source of Truth** | `Gemini.md`, `claude.md`, `custominstructions.md` | **IMMEDIATE** | 🔴 **CRITICAL** (System breaks if wrong) |
| **2. Active Skills** | `.agent/skills/*/SKILL.md` | **On Use / Monthly** | 🟡 **HIGH** (Operations fail if wrong) |
| **3. Lessons** | `lessons/*.md` | **Ad-hoc / On Reference** | 🟢 **MEDIUM** (Contextual knowledge) |
| **4. Server Docs** | `/root/.openclaw/workspace/*.md` | **Sync with Level 1** | 🔴 **CRITICAL** (Jack's brain) |

---

## 🗑️ Deprecation Protocol

When a document is hopelessly outdated but contains historical value:

1. **Rename it:** `lessons/ARCHIVED_v1_docker_setup.md`
2. **Add Header:** 
   ```markdown
   > ⚠️ **ARCHIVED / DEPRECATED**
   > This document reflects a past architecture (Docker). 
   > **DO NOT USE for current native setup.**
   > Kept for historical reference only.
   ```
3. **Move it:** Create `lessons/archive/` folder if clutter grows.

---

## 🛠️ The "Skill" of Updating Skills

**When we create a new skill, it MUST include:**
1. **Prerequisites:** What state must the system be in?
2. **Verification Command:** How do we know it worked?
3. **"Last Verified" Date:** Today's date.
4. **Architecture Tag:** e.g., `(Native OpenClaw v4.x)`

---

## 📝 Usage for Antigravity & User

**User Command:** "Run the doc audit."
**My Response:** 
1. I will grep for "Red Flags" across `lessons/` and `skills/`.
2. I will list files that seem dangerous.
3. I will propose:
   - 🗑️ **Archive** (if useless)
   - 🔄 **Update** (if critical)
   - ⚠️ **Flag** (if unsure)

---
**Status:** Implemented effective 2026-02-13.

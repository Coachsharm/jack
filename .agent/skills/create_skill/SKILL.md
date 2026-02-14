---
name: create_skill
description: Analyze a completed task and crystallize it into a reusable, verified Skill.
---

# 🏭 The Skill Factory: Creating New Skills

> **Purpose:** Use this skill to transform a chaotic, successful task into a permanent, reusable asset for the team. 
> **Input:** Recent conversation/process + Goal of the new skill.
> **Output:** A new `.agent/skills/[name]/SKILL.md` file.

## Protocol for Creating a Skill

### Step 1: Analyze the Source Material
Look at the recent conversation or the files changed. Identify the **Golden Path** — the set of steps that actually worked, ignoring the dead ends and mistakes.

**Ask:**
- What problem did we just solve?
- What were the critical commands?
- What dependencies (API keys, files) were needed?
- Did we drift from standard infrastructure (e.g., using Docker by mistake)?

### Step 2: Extract & Generalize
Don't just copy-paste.
- **Abstract Ids:** Replace specific IDs like `12345` with `[id]`.
- **Standardize Paths:** Ensure paths are `/root/.openclaw/` (Native), not `/root/openclaw-clients/` (Old).
- **Modernize Commands:** If the chat used `docker restart`, replace with `openclaw gateway restart`.

### Step 3: Create the Skill Directory
1. Pick a clear, short name (e.g., `update_status`, `restart_server`, `debug_logs`).
2. Run: `mkdir .agent/skills/[name]`

### Step 4: Draft the SKILL.md
Use the `template.md` in this folder as a guide. The new skill MUST have:
1.  **YAML Frontmatter:** Name & Description.
2.  **Safety Check:** Header warning to verify infrastructure match.
3.  **Prerequisites:** What is needed before starting?
4.  **Steps:** Clear, numbered commands.
5.  **Verification:** How to prove it worked.

### Step 5: The "Red Team" Review (Self-Correction)
Before finalizing, critique your own draft:
- Does it reference Docker? -> **FAIL** (Fix it).
- Does it use unsafe `rm -rf` without checks? -> **FAIL** (Add checks).
- Is it clear enough for a junior dev to follow? -> **Improve it**.

### Step 6: Save & Notify
1. Save the file to `.agent/skills/[name]/SKILL.md`.
2. Tell the user: "✅ Skill '[name]' created successfully. I have verified it matches our current native architecture."

---

## 🛠️ Commands

**To view the template:**
`view_file .agent/skills/create_skill/template.md`

**To create a new directory:**
`run_command "mkdir .agent/skills/[new_skill_name]"`

**To write the new skill:**
`write_to_file .agent/skills/[new_skill_name]/SKILL.md`

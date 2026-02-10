# 🛑 PROTOCOL CHEAT SHEET (1-Page Reference)

```
┌─────────────────────────────────────────────────────────────┐
│                    STUCK LOOP PROTOCOL                      │
│                      Quick Reference                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  🎯 STEP 0: CHECK OPENCLAW DOCS FIRST (ALWAYS!)            │
│  Path: OpenClaw_Docs/                                       │
│  I am NOT trained on OpenClaw - cannot guess!               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  📊 CATEGORIES (Label Every Attempt)                        │
├─────────────────────────────────────────────────────────────┤
│  CONFIG   │ .json, .yml, .env files                         │
│  NETWORK  │ Ports, tunnels, SSH, connectivity               │
│  AUTH     │ OAuth, tokens, credentials, scopes              │
│  DOCKER   │ Containers, compose, builds                     │
│  FILESYSTEM│ Paths, permissions                             │
│  CODE     │ Application logic, scripts                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  🔴 THE RULE                                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Same Category + 2 Failures = STOP & RESEARCH              │
│                                                             │
│   🔴 SAME ERROR    → I'm stuck, must research               │
│   🟡 DIFFERENT ERROR → Progress, may continue               │
│   🟢 PARTIAL SUCCESS → Keep iterating                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  📚 RESEARCH LADDER (After 2 Failures)                      │
├─────────────────────────────────────────────────────────────┤
│  STEP 0 │ OpenClaw_Docs/     │ grep search (10 min max)     │
│  STEP 1 │ lessons/           │ Your documented solutions    │
│  STEP 2 │ OpenClaw_Docs/     │ Deep dive with error msgs    │
│  STEP 3 │ docs.openclaw.com  │ Online (if local stale)      │
│  STEP 4 │ Discord/GitHub     │ Expert communities           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  ⚡ HUMAN COMMANDS                                          │
├─────────────────────────────────────────────────────────────┤
│  PROTOCOL!      │ Stop immediately, start research          │
│  OVERRIDE       │ Allow one more attempt                    │
│  SKIP TO FORUMS │ Jump to Step 4                            │
│  SET CAUTIOUS   │ 1-attempt limit                           │
│  SET NORMAL     │ 2-attempt limit (default)                 │
│  SET EXPLORER   │ 3-attempt limit                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  ⏱️ TIME ALERTS                                             │
├─────────────────────────────────────────────────────────────┤
│  < 15 min  │ 🟢 Normal                                      │
│  15-30 min │ 🟡 Extended - consider PROTOCOL!               │
│  > 30 min  │ 🔴 Prolonged - strongly recommend research     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  📝 AFTER SUCCESS (From Forums)                             │
├─────────────────────────────────────────────────────────────┤
│  → Create lessons/[problem].md                              │
│  → Log in protocols/stuck_log.md                            │
│  → Cannot mark complete until lesson exists                 │
└─────────────────────────────────────────────────────────────┘

Protocol V3 (10/10) | 2026-02-04
```

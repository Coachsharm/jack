# LESSON: Troubleshooting Model 404 / "Entity Not Found" Errors

**Created**: 2026-02-08  
**Context**: Debugging `/model ag-opus46` 404 error on Jack  
**Resolution**: Google Antigravity API doesn't expose all models the same way

---

## The Problem

Using `/model ag-opus46` (→ `google-antigravity/claude-opus-4-6`) in Telegram returned:

```
Cloud Code Assist API error (404): Requested entity was not found.
```

Meanwhile, `opus46` (→ `anthropic/claude-opus-4-6`) via Anthropic API key worked fine.

---

## Root Cause

**Google Antigravity's Cloud Code Assist API doesn't expose every model their Desktop IDE supports.**

- ✅ Desktop Antigravity IDE → uses Opus 4.6 fine (internal IDE routes)
- ❌ Cloud Code Assist API → returns 404 for Opus 4.6 (not yet in API catalog)
- ✅ Cloud Code Assist API → Opus 4.6 **Thinking** variant works

This is a **Google-side limitation**, not an OpenClaw bug. Google cherry-picks which models to expose via the API.

---

## Key Forum Sources

### Reddit Threads (Feb 2026)
- **r/OpenClaw / r/LocalLLaMA / r/ClawdBot** — Multiple users reported the same 404:
  - *"Opus 4.6 does not appear in the available model list through the Antigravity API. The Desktop Antigravity UI uses Opus 4.6 fine, suggesting the IDE supports it but the API route used by OpenClaw does not yet expose it."*
  - Users also saw `Cloud Code Assist API error (403)` for Gemini (ToS violations) — a separate issue
  - **Search terms**: `reddit openclaw antigravity "opus 4.6" "entity was not found" 404`

### GitHub: Antigravity-Manager Changelog
- **v4.1.8 (Feb 8, 2026)** officially added Claude Opus 4.6 support
- **v4.1.7 (Feb 6, 2026)** added "Claude 403 Error Handling & Account Rotation Optimization"
- **Repo**: Search GitHub for `antigravity-manager` changelog

### OpenClaw pi-ai Catalog
- OpenClaw's model catalog comes from `@mariozechner/pi-ai` npm package
- Version `0.52.0+` includes Claude Opus 4.6 for `anthropic` provider
- But **NOT** for `google-antigravity` provider — Opus 4.6 wasn't in the Antigravity model list
- **File**: `/usr/lib/node_modules/openclaw/node_modules/@mariozechner/pi-ai/dist/models.generated.js`

---

## Diagnostic Steps (Use These in Future)

### 1. Check if model shows as "missing"
```bash
openclaw models list --provider google-antigravity
# Look for: configured,missing → means not in provider's catalog
# Working models show: text+image 195k no yes
```

### 2. Check the pi-ai catalog directly
```bash
grep -B3 'provider.*google-antigravity' \
  /usr/lib/node_modules/openclaw/node_modules/@mariozechner/pi-ai/dist/models.generated.js
```

### 3. Run openclaw doctor
```bash
openclaw doctor
```

### 4. Check logs for specific error
```bash
openclaw logs --max-bytes 50000 2>&1 | grep -C3 '404\|entity\|error.*model'
```

---

## How We Fixed It

### Step 1: Patched the pi-ai catalog
Added `claude-opus-4-6` and `claude-opus-4-6-thinking` to `models.generated.js`:

```bash
# Location of catalog file
/usr/lib/node_modules/openclaw/node_modules/@mariozechner/pi-ai/dist/models.generated.js

# Added entries modeled after existing claude-opus-4-5-thinking entry:
# - Same baseUrl: https://daily-cloudcode-pa.sandbox.googleapis.com
# - Same api: google-gemini-cli
# - Same provider: google-antigravity
```

### Step 2: Discovered non-thinking variant still fails
- `claude-opus-4-6-thinking` → ✅ Works via Antigravity API
- `claude-opus-4-6` (non-thinking) → ❌ Still 404 from Google's API

### Step 3: Updated aliases
- `/model opus` → `google-antigravity/claude-opus-4-6-thinking` (FREE via Antigravity)
- `/model Aopus` → `anthropic/claude-opus-4-6` (via Anthropic API key)
- Removed broken `ag-opus46` alias

### Step 4: Gateway restart
```bash
openclaw gateway restart
openclaw models list  # Verify all show auth:yes
```

---

## Key Lessons

1. **"configured,missing"** in `openclaw models list` = model not in provider's catalog
2. **Google Antigravity ≠ Anthropic** — they expose different model subsets
3. **Thinking variants may be available when non-thinking aren't** — Google prioritizes reasoning models
4. **pi-ai catalog can be manually patched** but gets overwritten on `openclaw update`
5. **Always check forums** — search Reddit for `openclaw antigravity <model-name> 404`
6. **Desktop Antigravity working ≠ API working** — they use different routes
7. **`openclaw models list`** is the fastest diagnostic — check for `missing` tag

---

## Future-Proofing

When a new Claude model releases:
1. Check `openclaw models list --provider google-antigravity` for `missing` tag
2. If missing, search Reddit/GitHub for known workarounds  
3. Try the **thinking variant** first (more likely to be available)
4. Patch `models.generated.js` if needed (use existing entries as template)
5. Fall back to `anthropic/<model>` via API key if Antigravity doesn't support it yet

> **⚠️ WARNING**: Running `openclaw update` will overwrite `models.generated.js` patches. Re-apply after updates if needed.

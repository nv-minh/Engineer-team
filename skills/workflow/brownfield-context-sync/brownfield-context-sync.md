---
name: brownfield-context-sync
description: "Detect and resolve drift between .em-brownfield/ context artifacts and the actual codebase. Validates per-module CODE-MAP references, checks for new undocumented routes, detects interface contract breaks across module boundaries, and suggests targeted fixes. Run periodically or before investigation."
version: "5.0.0"
category: "workflow"
origin: "EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "sync brownfield"
  - "check context drift"
  - "update brownfield context"
  - "validate brownfield"
  - "context freshness check"
intent: "Keep .em-brownfield/ artifacts accurate over time by detecting code changes that invalidate existing documentation, with special attention to cross-module contract breaks that could cause silent failures."
scenarios:
  - "Before investigation — verify context is fresh for the affected module"
  - "After a sprint — check what changed and update flow documentation"
  - "After major refactoring — re-validate all module references"
  - "New developer onboarding — ensure context artifacts are current"
  - "CI/CD integration — flag drift warnings on commits that touch documented code"
best_for: "Brownfield context maintenance, pre-investigation validation, post-refactor verification"
estimated_time: "10-30 min"
anti_patterns:
  - "Checking only the directly changed module without following the dependency chain"
  - "Auto-fixing references without user confirmation"
  - "Ignoring CONTRACT_BREAK severity — these must be resolved before investigation"
  - "Marking modules as OK when function signatures changed but file/name stayed same"
related_skills: [brownfield-onboarding, flow-discovery, codebase-architecture]
input_schema:
  type: object
  required: [brownfield_path]
  properties:
    brownfield_path:
      type: string
      default: ".em-brownfield"
      description: "Path to brownfield context directory"
    scope:
      type: string
      enum: [full, module, changed]
      default: full
      description: "full: all modules, module: specific module only, changed: only modules with git changes since last sync"
    target_module:
      type: string
      description: "Required if scope=module — which module to sync"
    auto_fix:
      type: boolean
      default: false
      description: "If true, apply simple fixes (renamed functions) automatically. CONTRACT_BREAK always requires user confirmation."
output_schema:
  type: object
  required: [status, drift_report]
  properties:
    status:
      type: string
      enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED]
    drift_report:
      type: object
      properties:
        modules_checked: { type: integer }
        modules_ok: { type: integer }
        modules_stale: { type: integer }
        modules_contract_break: { type: integer }
        modules_missing: { type: integer }
        details:
          type: array
          items:
            type: object
            properties:
              module: { type: string }
              status: { type: string, enum: [OK, STALE, CONTRACT_BREAK, MISSING, OUTDATED] }
              issues: { type: array, items: { type: string } }
              chain_impact: { type: array, items: { type: string } }
    fixes_applied: { type: integer }
    fixes_pending: { type: integer }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    attempted_action: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Brownfield Context Sync

[ROLE]
You are a context integrity validator. Detect drift between `.em-brownfield/` documentation and the actual codebase, with special focus on cross-module contract breaks that could cause silent failures during investigation.

[OBJECTIVE]
Validate all `.em-brownfield/` artifacts against current code state, classify drift by severity, analyze chain impact across module dependencies, and suggest targeted fixes — all with user confirmation before applying changes.

[RULES]
1. <thought>Before scanning, determine scope: full sync, single module, or changed-files-only. Plan the validation strategy.</thought>
2. **Module-aware drift detection.** Drift in module A can cascade to modules B, C that depend on A. Always check the dependency chain.
3. **CONTRACT_BREAK is highest priority.** Interface changes between modules (return types, API shapes, event payloads) must be resolved before any investigation can use these artifacts.
4. **Verify at function level, not just file level.** A file can exist but a function within it may have been renamed, moved, or had its signature changed.
5. **Never auto-fix CONTRACT_BREAK.** These require user understanding of the business impact. Simple renames (STALE) can be auto-fixed if `auto_fix: true`.
6. **Update INDEX.md Last Verified dates** only for modules confirmed as OK.
7. Every interaction should teach: explain WHY a drift was classified at its severity level.

[AVAILABLE SKILLS]
- brownfield-onboarding (for full re-scan if drift is too extensive)
- codebase-architecture (for pattern detection in new code)

[PROCESS]

### Step 1: SCAN PER MODULE (thorough)

For each module in scope (from INDEX.md):

#### 1a. CODE-MAP.md Validation (symbol-based)

For every reference in CODE-MAP.md, the validator:

1. Reads the `Symbol` column (e.g., `OrderService.create`).
2. Runs symbol resolver script: `bash scripts/brownfield/symbol-resolver.sh {symbol}`.
3. Resolver returns: `{found: true|false, file: ..., line: ..., signature: ...}`.

Classification:
- Symbol found, file unchanged → OK (update Line column if it moved)
- Symbol found, file moved → STALE (auto-fixable: update File column)
- Symbol renamed (heuristic match) → STALE with suggestion (e.g., `createOrder` → `createOrderV2`)
- Symbol not found anywhere → STALE (function deleted — needs manual review)
- Symbol found but signature changed (params/return type differ) → **CONTRACT_BREAK** (if used cross-module)

This eliminates false-positive STALE alerts caused by refactors that move code without renaming.

#### 1b. FLOWS.md Validation
- For each flow → verify entry points (routes/endpoints) still exist in code
- Check: are there NEW routes in this module's source directories not in FLOWS.md?
- Check: do business rules references match current code logic?

#### 1c. INTEGRATIONS.md Validation
- Check external SDK versions in package.json vs documented version
- Verify API endpoints are still called (grep for URLs/SDK methods)
- Detect new external calls not documented

#### 1d. DOMAIN.md Validation
- Check for new DB migrations since Last Verified date
- Compare entity model files: new attributes? removed attributes? type changes?
- Verify relationship references still valid

### Step 2: CROSS-MODULE DRIFT DETECTION

**This is the critical step that prevents silent failures.**

For each module with drift (STALE or worse):
1. Read its **Dependencies** → "Module A changed function X. Module B calls X. Is B affected?"
2. Read its **Depended By** → "Module A's output changed. Modules C, D consume this. Are they stale?"
3. Detect interface contract breaks:
   - Function return type changed → consumers may parse incorrectly
   - API response shape changed → clients may break
   - Event payload changed → subscribers may fail silently
   - DB schema change affecting shared tables → multiple modules affected

Classify each module:
| Status | Meaning | Priority |
|--------|---------|----------|
| OK | All references valid | — |
| STALE | Direct references broken (file/function gone/renamed) | Medium |
| CONTRACT_BREAK | Interface between modules changed | **HIGH** |
| MISSING | New code not documented in any artifact | Low |
| OUTDATED | Integration version drift (may still work) | Low |

### Step 3: REPORT

Generate drift report with chain impact analysis:

```markdown
## Drift Report — YYYY-MM-DD

### Summary
- Modules checked: N
- OK: N | Stale: N | Contract Break: N | Missing: N

### Per-Module Status
| Module | Status | Issues | Chain Impact | Action |
|--------|--------|--------|-------------|--------|

### Contract Breaks (resolve first)
1. **{module}.{function}()** — return type changed from `{old}` to `{new}`
   - Called by: [{module_B}](modules/{module_B}/CODE-MAP.md) at {file}:{line}
   - Impact: {module_B} may parse response incorrectly → silent data corruption
   - **Action:** Update FLOWS.md + CODE-MAP.md in BOTH modules

### Stale References
1. **{module}/CODE-MAP.md** line N — `functionName()` renamed to `functionNameV2()`
   - Auto-fixable: Yes
   - **Action:** Update reference

### Missing Documentation
1. New endpoint `POST /api/v2/orders` in module {order-management}
   - **Action:** Add to FLOWS.md as new flow or append to existing flow
```

Update INDEX.md "Last Verified" dates for OK modules only.

### Step 4: SUGGEST + FIX

For each issue, grouped by priority:

**CONTRACT_BREAK (always requires user confirmation):**
- Present: "PaymentService.charge() now returns `{id, status, receipt_url}` instead of `{id, status}`. Module 'order' reads this at order.service.ts:89. Should I update CODE-MAP + FLOWS for both modules?"
- User: APPROVE / SKIP / needs discussion

**STALE (auto-fixable if auto_fix=true):**
- "Function renamed from createOrder to createOrderV2. Updating CODE-MAP.md line 5."
- If auto_fix=false → present and wait for approval

**MISSING (suggest):**
- "New endpoint POST /api/v2/orders detected. Want me to add it to order-management/FLOWS.md?"

After all fixes → re-validate cross-references to ensure consistency.

[RESPONSE FORMAT]
Return results matching output_schema:
```json
{
  "status": "DONE_WITH_CONCERNS",
  "drift_report": {
    "modules_checked": 5,
    "modules_ok": 3,
    "modules_stale": 1,
    "modules_contract_break": 1,
    "modules_missing": 0,
    "details": [
      { "module": "payment", "status": "CONTRACT_BREAK", "issues": ["charge() return type changed"], "chain_impact": ["order", "notification"] }
    ]
  },
  "fixes_applied": 2,
  "fixes_pending": 1
}
```

[VERIFICATION]
- [ ] All modules in INDEX.md were checked (or scoped subset)
- [ ] Cross-module dependencies were traced for every drifted module
- [ ] CONTRACT_BREAK issues were presented to user with full chain impact
- [ ] INDEX.md Last Verified dates updated only for OK modules
- [ ] HEALTH-CHECK.md Context Drift History updated with new findings
- [ ] All fixes applied with user confirmation (or auto_fix for STALE only)
- [ ] Post-fix re-validation shows no remaining inconsistencies

[HANDOFF]
Output consumed by:
- `brownfield-investigation` workflow (Stage 0 checks drift status before loading context)
- Pre-commit hook (optional: flag drift warnings)
- `brownfield-onboarding` (triggers full re-scan if drift is too extensive)

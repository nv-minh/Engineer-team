# Investigation Report — {YYYY-MM-DD}

## Metadata
- **Investigation ID:** {shortid}
- **Date:** {YYYY-MM-DD}
- **Investigator:** {user/agent}
- **Symptom Module:** {module}
- **Root Cause Module:** {module} (may differ)
- **Severity:** P{N}
- **GitHub Issue:** #{number}

## Bug Summary
{1-2 sentence summary in business terms}

## Reproduction
Steps from FLOWS.md happy path:
1. {Step 1} — PASS
2. {Step 2} — PASS
3. {Step 3} — **FAIL** ← bug occurs

## Root Cause
- **Module Chain:** {symptom} → {intermediate} → {root}
- **File:** `{path}`
- **Function:** `{name}`
- **Explanation:** {what's wrong and why, including business reasoning}

## Blast Radius
| Module | Status | Affected Flow | Reason |
|---|---|---|---|
| {name} | AFFECTED | {flow} | {reason} |
| {name} | AT_RISK | {flow} | {reason} |

## Acceptance Criteria Violated
- AC-{MODULE}-{NNN}: {text}

## Evidence
- Video: `{path}`
- Screenshots: `{paths}`
- Network logs: `{path}`
- Manifest: `EVIDENCE.json`

## Context Updates Applied
- [ ] FLOWS.md Known Issues updated for {module}
- [ ] Cross-module dependency added (if applicable)
- [ ] HEALTH-CHECK Investigation History appended
- [ ] INDEX.md Last Verified date updated

---
**Template Version:** 5.4.0
**Created By:** brownfield-investigation workflow Stage 5

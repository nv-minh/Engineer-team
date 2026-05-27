# New Feature Workflow: Idea to PR

`/em-wf:new-feature` is a 6-stage lifecycle that takes a feature from a raw description to a reviewed, shippable PR — with quality gates between every stage.

---

## Quick Start

```bash
/em-wf:new-feature Implement a user profile page with avatar upload and bio editing
```

The workflow handles everything: spec → plan → build → verify → review → ship. You're consulted at each gate.

---

## 6-Stage Lifecycle

```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP
```

### Stage 1: DEFINE

**Agent:** product-manager  
**Output:** Feature specification (`SPEC.md`)

The spec covers:
- Business requirements + user stories
- Acceptance criteria (the "what done looks like")
- API contracts + database schema
- Non-functional requirements (performance, security, accessibility)
- Risk tier declaration (P0/P1/P2/P3) — drives test ratio requirements

**Gate 1:** Spec must pass testability check (⛔ hard gate). Spec is blocked until all ACs are verifiable and contradictions are resolved.

### Stage 2: PLAN

**Agent:** planner  
**Output:** `PLAN.md` — implementation plan with bite-sized tasks

The plan includes:
- Files to create/modify with exact paths
- Database migrations, API endpoints, frontend components
- Test strategy per layer (unit / integration / E2E)
- Security considerations specific to this feature
- Estimated effort per task

### Stage 3: BUILD

**Agent:** executor  
**Protocol:** Atomic commits — one commit per task

Every task follows TDD:
1. Write failing test
2. Implement minimal code to pass
3. Refactor
4. Commit

**Stage 3.5 (if brownfield):** Before building, agent loads `.em-brownfield/` context for affected modules. After build, agent updates FLOWS.md if new behavior was added.

### Stage 4: VERIFY

**Agents:** brownfield-test-engineer → test-verifier  
**Order within VERIFY stage:**

```
Step 5.1: code-review diff scan (FIRST — review fixes before tests)
Step 5.2: verify spec coverage
Step 5.3: generate/update TC-REGISTRY
Step 5.4: run tests + collect evidence
Step 5.5: test-verifier double-check (max 3 retries)
```

Code review runs **before** the test suite — so any review findings are fixed and then re-validated by tests. This ordering prevents review fixes from introducing test-breaking changes silently.

**Gate 4:** TC-code coverage = 100% per layer. Every TC-ID has a `test()` block or `test.todo()`. Confidence score ≥ 80%.

### Stage 5: REVIEW

**Agent:** code-reviewer (Standard 5-axis) + security-reviewer (if any auth/input/data changes)

5-axis review:
1. Correctness — logic, edge cases, error handling
2. Security — OWASP Top 10 relevant to the change
3. Performance — N+1 queries, missing indexes, bundle size
4. Maintainability — naming, complexity, abstractions
5. Testing — coverage, mutation immunity, regression risk

Cross-file impact scan (Step 4.5): if changes touch >5 callers or shared state, review escalates to architect.

**Gate 5:** All CRITICAL and HIGH findings resolved. Review sign-off in `REVIEW.md`.

### Stage 6: SHIP

**Agent:** verifier → executor (git operations)

1. Rollback readiness gate — verify `git revert` is safe
2. Final verification run
3. Version bump (if applicable)
4. PR creation with auto-filled description

---

## With Brownfield Context

If `.em-brownfield/` exists, the workflow gains extra stages:

| Extra step | When | What |
|------------|------|------|
| Stage 0.5: Context Load | Before DEFINE | Loads INDEX + affected module FLOWS + CODE-MAP |
| Stage 3.5: Spec alignment | After BUILD | Checks build matches FLOWS acceptance criteria |
| Stage 5.7: Context Update | After REVIEW passes | Adds new flows/ACs to FLOWS.md, updates CODE-MAP symbols |

This means the brownfield knowledge base grows with every new feature — next investigation has better context.

---

## Example Walkthrough

```bash
/em-wf:new-feature Add Stripe payment method management (list, add, delete cards)
```

**Stage 1 — DEFINE:**
```
Spec created: SPEC.md
  ACs defined:
    - AC-001: User can list saved cards (last 4, expiry)
    - AC-002: User can add card via Stripe Elements
    - AC-003: User can delete a card (with confirmation)
    - AC-004: Cannot delete last card if active subscription
  Risk tier: P0 (payment data, PCI scope)
  ⛔ TESTABILITY GATE: PASS
```

**Stage 2 — PLAN:**
```
Files to create:
  - src/payment/payment-methods.controller.ts
  - src/payment/payment-methods.service.ts
  - src/payment/dto/add-card.dto.ts
Files to modify:
  - src/payment/payment.module.ts
  - frontend/src/pages/settings/payment.tsx
Tasks: 8 tasks (TDD, atomic commits)
```

**Stage 3 — BUILD:**
```
8/8 tasks committed
Last commit: feat(payment): prevent delete of last card with active subscription
```

**Stage 4 — VERIFY:**
```
Step 5.1 code-review: 2 HIGH findings fixed → re-committed
TC-REGISTRY: 28 TCs (P0 ratios: 40% negative ✅, 18% abuse ✅, 12% non-func ✅)
Tests: 28/28 PASS — confidence: 93%
```

**Stage 5 — REVIEW:**
```
code-reviewer: 0 CRITICAL, 1 HIGH (SQL injection in raw query) — FIXED
security-reviewer: PCI scope confirmed, no card data in logs ✅
Review PASS
```

**Stage 6 — SHIP:**
```
Rollback gate: PASS
PR created: feat/payment-method-management
  Title: Add payment method management (list, add, delete cards)
  Body: auto-filled from spec + review findings
```

---

## Verification Gates Summary

| Gate | Checks | Block condition |
|------|--------|-----------------|
| Gate 1 (Spec) | Testability, contradictions | ACs not verifiable or conflicting |
| Gate 4 (Verify) | TC coverage, test pass | TC-IDs without test(), confidence < 80% |
| Gate 5 (Review) | CRITICAL + HIGH findings | Any unresolved CRITICAL; HIGH by default |
| Gate 6 (Ship) | Rollback readiness | `git revert` would break unrelated features |

---

**Version:** 5.5.0
**Last Updated:** 2026-05-27

See also: [Brownfield Intelligence](brownfield.md) · [Test Automation Chain](test-automation.md) · [Code Review](code-review.md)

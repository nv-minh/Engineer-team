# Brownfield Intelligence Guide

Build a living knowledge graph of your existing codebase so every agent — debugger, verifier, test writer — understands your business flows before it starts work.

---

## What is Brownfield Intelligence?

Brownfield Intelligence is a module-based context system that turns a legacy codebase into a machine-readable knowledge graph stored in `.em-brownfield/`. Once built, every EM-Team agent loads the relevant module context automatically — no more "what does this code actually do?" at the start of every investigation.

**Key properties:**
- Organized by **business domain** (bounded contexts), not technical directories
- Stable `FLOW-{MODULE}-{NNN}` and `AC-{MODULE}-{NNN}` IDs survive refactors
- Symbol-first `CODE-MAP` references (`PaymentService.charge`, not `src/payment/service.ts:142`)
- Quality gate before shipping: `validate-refs.sh` + `quality-score.sh`

---

## Prerequisites

- Claude Code with EM-Team v5.5.0 installed
- A codebase with at least one identifiable business domain (payments, auth, orders, etc.)
- Recommended: NestJS, React, or monorepo — auto-detection scripts cover these

---

## Quickstart

```bash
# Step 1: Onboard (one time, ~10-30 min)
/em-skill:brownfield-onboarding

# Step 2: Investigate a bug using loaded context
/em-wf:brownfield-investigation Fix the checkout timeout affecting 5% of orders

# Step 3: Check PR impact before merge
/em-skill:brownfield-pr-impact

# Step 4: Keep context fresh after changes
/em-skill:brownfield-context-sync
```

---

## Step 1: Onboard — `/em-skill:brownfield-onboarding`

Run once per project (re-run after major restructures).

**What it does:**
1. Runs `scripts/brownfield/detect-stack.sh` to identify your stack (NestJS, React, monorepo, etc.)
2. Scans stack-specific entrypoints (`scan-nestjs.sh`, `scan-react.sh`, `scan-monorepo.sh`)
3. Discovers **business domains** from your code structure — proposes module names
4. **You confirm or adjust** the module list (semi-auto: agent proposes, you decide)
5. Generates per-module artifacts:
   - `FLOWS.md` + `FLOWS.json` — business flows with acceptance criteria (AC-{MODULE}-{NNN})
   - `DOMAIN.md` — entities, relationships, ubiquitous language, PII table
   - `INTEGRATIONS.md` — external services + internal module dependencies
   - `CODE-MAP.md` + `CODE-MAP.json` — flow steps → `Class.method` symbols
6. Builds root artifacts: `INDEX.md`, `INDEX.json`, `DOMAIN-PROFILE.md`, `DOMAIN-PROFILE.yaml`
7. Runs quality gate

### Quality Gate

Before the skill marks onboarding complete, it runs:

```bash
bash scripts/brownfield/validate-refs.sh .em-brownfield/   # all cross-module refs resolve
bash scripts/brownfield/quality-score.sh .em-brownfield/   # Grade A = ready to use
```

Grade A means all required sections present, no broken references, all flows have IDs.

### Output Structure

```
.em-brownfield/
├── INDEX.md                     # Module registry + dependency graph
├── INDEX.json                   # Machine-readable index (schema_version: "5.4.0")
├── DOMAIN-PROFILE.md            # Project-wide: tech stack, DB, auth, compliance
├── DOMAIN-PROFILE.yaml          # Structured domain profile for agent tooling
├── BACKLINKS.json               # Reverse-dependency index (auto-built)
├── QUALITY-SCORE.json           # Per-module grades (A/B/C/D)
├── HEALTH-CHECK.md              # Per-module health scores
└── modules/
    ├── payment/
    │   ├── FLOWS.md             # Flows with AC-PAYMENT-001, AC-PAYMENT-002, etc.
    │   ├── FLOWS.json           # JSON sidecar for programmatic AC→TC mapping
    │   ├── DOMAIN.md            # Payment entity, PII fields (card_number, etc.)
    │   ├── INTEGRATIONS.md      # Stripe, order-module dependency
    │   ├── CODE-MAP.md          # FLOW-PAYMENT-001 → PaymentService.charge
    │   └── CODE-MAP.json        # JSON sidecar for agent tooling
    ├── auth/
    ├── order/
    └── ...
```

---

## Step 2: Investigate a Bug — `/em-wf:brownfield-investigation`

Context-aware bug investigation. The workflow auto-loads the relevant module context before any analysis.

```bash
/em-wf:brownfield-investigation Fix the checkout timeout affecting 5% of orders
```

**Stages:**
1. **CONTEXT LOAD** — reads `INDEX.md`, identifies affected modules (e.g., `payment`, `order`), loads their FLOWS + CODE-MAP
2. **REPRODUCE** — attempts to reproduce the bug with precise module context
3. **ROOT CAUSE** — traces through the CODE-MAP symbols; uses `symbol-resolver.sh` to find current `file:line`
4. **EVIDENCE** — produces an evidence package with `EVIDENCE.json` manifest
5. **HUMAN GATE** — presents findings; you decide next steps
6. **CONTEXT UPDATE** — updates FLOWS.md if the investigation reveals undocumented behavior

### Understanding FLOW and AC IDs

Every flow and acceptance criterion has a stable ID:

| ID format | Example | What it means |
|-----------|---------|---------------|
| `FLOW-PAYMENT-001` | Charge customer at checkout | A complete business flow |
| `AC-PAYMENT-001` | Payment succeeds with valid card | An acceptance criterion within a flow |
| `AC-PAYMENT-003` | Payment fails gracefully on expired card | Another criterion (happy/sad path) |

These IDs are referenced by agents, tests, and evidence packages. They **don't change** when you refactor method names or move files.

---

## Step 3: Pre-merge Check — `/em-skill:brownfield-pr-impact`

Run before merging any PR that touches business logic.

```bash
/em-skill:brownfield-pr-impact
```

**What it checks:**
- Which `FLOW-*` flows are touched by the diff
- Which `AC-*` acceptance criteria are at risk
- Cross-module contract breaks (interface changes that break downstream modules)

**Output:**

```
AC-at-risk:
  AC-PAYMENT-003 (payment fails gracefully) — PaymentService.charge signature changed
  AC-ORDER-007 (order total recalculated) — OrderService.recalculate touched

CONTRACT_BREAK:
  payment → order: OrderService.confirm(orderId) removed
  Impact: order module expects this call after payment succeeds
```

A `CONTRACT_BREAK` finding blocks merge until the consuming module is updated.

---

## Step 4: Write Tests — `/em-agent:brownfield-test-engineer`

Generates tests directly from the brownfield context — no need to re-explain your flows.

```bash
/em-agent:brownfield-test-engineer Write tests for the payment module
```

**How FLOWS.json → AC → TC mapping works:**

1. Agent reads `modules/payment/FLOWS.json` — gets all `AC-PAYMENT-*` criteria
2. Agent reads `modules/payment/DOMAIN.md` — extracts entity shapes for test fixtures
3. Agent reads `modules/payment/INTEGRATIONS.md` — discovers external deps → negative TCs (Stripe timeout, etc.)
4. Reads `DOMAIN-PROFILE.yaml` → sets `risk_tier` (P0 for payments, P1 for notifications, etc.)
5. Generates `TC-REGISTRY.md` with 12-column format
6. Writes test files with `test("AC-PAYMENT-001: ...")` — TC IDs match AC IDs
7. Hands to `test-verifier` for execution verification

---

## Keep Context Fresh — `/em-skill:brownfield-context-sync`

Run after significant code changes (refactors, new features, deleted endpoints).

```bash
/em-skill:brownfield-context-sync
```

**Symbol-based drift detection:**
- Uses `symbol-resolver.sh` to check whether `Class.method` refs in `CODE-MAP` still resolve
- Detects `CONTRACT_BREAK` when an interface used by another module changes
- Proposes specific FLOWS.md + CODE-MAP.md updates for your review

---

## `.em-brownfield/` Reference

| File | Updated by | Purpose |
|------|-----------|---------|
| `INDEX.md` | onboarding, context-sync | Module registry with dependency graph |
| `INDEX.json` | same | Machine-readable for agent tooling |
| `DOMAIN-PROFILE.yaml` | onboarding | Stack, DB engine, auth method, compliance flags |
| `BACKLINKS.json` | `build-backlinks.sh` | Reverse deps (who depends on this module?) |
| `QUALITY-SCORE.json` | `quality-score.sh` | Per-module A/B/C/D grades |
| `modules/*/FLOWS.json` | onboarding, investigation | Structured flows with stable AC IDs |
| `modules/*/CODE-MAP.json` | onboarding, context-sync | Symbol refs for agent tooling |

---

## Common Mistakes

| Mistake | What goes wrong | Fix |
|---------|-----------------|-----|
| Organizing modules by technical layer (controllers/, services/) | Flows span layers — context becomes fragmented | Use business domains: payment, auth, order |
| Skipping quality gate | Agents load broken context → hallucinated flows | Always run `validate-refs.sh` before first use |
| Not re-running onboarding after major refactor | CODE-MAP refs break silently | Run `brownfield-context-sync` after each large PR |
| Editing FLOWS.json manually | JSON schema breaks → agents can't parse | Edit FLOWS.md; run onboarding to regenerate JSON |
| Using file:line refs in CODE-MAP | Fragile — breaks on any file move | Use `Class.method` symbols; let `symbol-resolver.sh` resolve at runtime |

---

**Version:** 5.5.0
**Last Updated:** 2026-05-27

See also: [Test Automation Chain](test-automation.md) · [New Feature Workflow](new-feature-workflow.md)

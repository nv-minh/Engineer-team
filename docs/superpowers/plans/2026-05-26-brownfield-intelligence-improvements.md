# Brownfield Intelligence Improvements — Master Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the brownfield system (onboarding → context → investigation → verify) work reliably on real projects by closing 25 identified gaps across 4 phases.

**Architecture:** Phased upgrade of 5 existing artifacts (`brownfield-onboarding`, `brownfield-investigation`, `brownfield-context-sync`, `brownfield-test-engineer`, `flow-discovery`) + integration into `verifier`, `debugger`, `new-feature`, `bug-fix` + 1 new skill (`brownfield-pr-impact`) + concrete scan tooling. Each phase ships independently.

**Tech Stack:** Markdown skill/workflow/agent files (Hermes protocol), bash + node CLI scripts, optional tree-sitter/madge for code analysis, JSON sidecars for programmatic access.

---

## Background — Review Findings

Read review summary: 25 gaps identified across 5 severity bands. Confirmed by:
1. Static reading of 5 brownfield files (~1500 lines)
2. Reading verifier + debugger agents + new-feature + bug-fix workflows (~1600 lines)
3. Real-project test against `ras-app/` (monorepo: apps/api NestJS, apps/web Vite, packages/shared-types)

**Top confirmed gaps (in this plan):**

| ID | Severity | Title |
|---|---|---|
| G1 | CRITICAL | CODE-MAP uses line numbers → drift on every refactor |
| G2 | CRITICAL | No concrete framework-aware scan scripts |
| G3 | CRITICAL | flow-discovery × brownfield matching is brittle |
| G4 | HIGH | Verifier agent + new-feature VERIFY don't use brownfield context |
| G5 | HIGH | Investigation Stage 5 (CONTEXT UPDATE) is passive — flags but never updates |
| G6 | HIGH | DOMAIN-PROFILE not enforced downstream (vague "use domain knowledge") |
| G7 | HIGH | Evidence package has no concrete schema |
| G8 | MEDIUM | No stable flow IDs (rename = broken refs) |
| G9 | MEDIUM | Drift detection reactive only, no PR-aware check |
| G10 | MEDIUM | brownfield-test-engineer underutilizes loaded context |
| G11 | LOW | No example .em-brownfield/ for agents to learn from |
| G12 | LOW | No quality gate on onboarding output |
| G13 | LOW | No privacy / PII guidance |
| G14 | LOW | No JSON sidecars for programmatic access |
| G21 | NEW | Domain table missing "workforce/resource management" + others |
| G22 | NEW | Monorepo / cross-stack module handling not specified |
| G23 | NEW | Test discovery assumes co-location with code |
| G24 | NEW | bug-fix.md doesn't auto-route to brownfield-investigation |
| G25 | NEW | new-feature.md doesn't pre-load brownfield module context |

---

## Phase Breakdown

| Phase | Focus | Gaps Closed | Ships |
|---|---|---|---|
| **Phase 1: Verify Integration** | Wire brownfield into `verifier`, `debugger`, `new-feature`, `bug-fix` | G4, G24, G25, G6, G7 | Verifier checks AC-{MODULE}-{NNN}; bug-fix auto-routes; new-feature loads module |
| **Phase 2: Robustness** | Symbol-based refs, concrete scan tools, JSON sidecars | G1, G2, G14, G22, G23 | Scan scripts per framework; symbol resolver; sidecars |
| **Phase 3: Active Sync** | Bidirectional flow-discovery, PR-impact, stable IDs, active context update | G3, G5, G8, G9 | New `brownfield-pr-impact` skill; flow-discovery proposes FLOWS.md updates |
| **Phase 4: Polish** | Examples, quality gate, privacy, expand domain table, test-engineer integration | G10, G11, G12, G13, G21 | Reference example; quality scoring; PII guidance |

Each phase produces working software. Stop after any phase and the system is in a better state than before.

---

## File Structure (changes summary)

### Phase 1 — Verify Integration
- Modify: `agents/verifier.md` — Add Phase 0 (brownfield context load) + Phase 3 cross-ref AC-{MODULE}-{NNN}
- Modify: `agents/debugger.md` — Add Phase 0 (brownfield context load)
- Modify: `workflows/new-feature.md` — Stage 0 + Stage 5 brownfield integration
- Modify: `workflows/bug-fix.md` — Stage 0 auto-route logic
- Modify: `workflows/brownfield-investigation.md` — Activate Stage 5 (CONTEXT UPDATE)
- Create: `templates/brownfield/EVIDENCE-MANIFEST.json.template` — Concrete evidence schema
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md` — Make DOMAIN-PROFILE structured (YAML sidecar)
- Create: `templates/brownfield/DOMAIN-PROFILE.yaml.template` — Machine-readable domain profile

### Phase 2 — Robustness
- Create: `scripts/brownfield-scan.sh` — Top-level entry point dispatcher
- Create: `scripts/brownfield/detect-stack.sh` — Stack detection (NestJS, Next.js, Spring, Django, etc.)
- Create: `scripts/brownfield/scan-nestjs.sh` — Controller/module discovery
- Create: `scripts/brownfield/scan-react.sh` — Routes/pages discovery (Next.js + Vite + RR)
- Create: `scripts/brownfield/scan-monorepo.sh` — apps/ + packages/ awareness
- Create: `scripts/brownfield/symbol-resolver.sh` — File:line → file:function:line lookup
- Modify: `templates/brownfield/MODULE-CODE-MAP.md` — Symbol-first format
- Create: `templates/brownfield/*.json.template` (sidecars for INDEX, MODULE-FLOWS, MODULE-CODE-MAP, HEALTH-CHECK)
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md` — Use new scan scripts in Phase 1
- Modify: `skills/workflow/brownfield-context-sync/brownfield-context-sync.md` — Validate via symbols not lines

### Phase 3 — Active Sync
- Create: `skills/workflow/brownfield-pr-impact/brownfield-pr-impact.md` — New skill (diff → impact)
- Modify: `skills/quality/flow-discovery/flow-discovery.md` — Bidirectional: propose FLOWS.md updates
- Modify: `templates/brownfield/MODULE-FLOWS.md` — Add FLOW-{MODULE}-{NNN} stable IDs
- Modify: `templates/brownfield/INDEX.md` — Add backlinks section
- Create: `scripts/brownfield/validate-refs.sh` — Reference integrity checker
- Modify: `workflows/brownfield-investigation.md` — Stage 5 actively writes (with confirmation)
- Create: `hooks/brownfield-pr-check` — Optional pre-push hook

### Phase 4 — Polish
- Create: `examples/brownfield/ras-app/.em-brownfield/` — Full reference example
- Create: `scripts/brownfield/quality-score.sh` — Onboarding output quality gate
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md` — Add quality gate + PII guidance + expanded domain table
- Modify: `agents/brownfield-test-engineer.md` — Explicit AC→TC mapping, DOMAIN→fixture, INTEGRATIONS→negative TC

---

# PHASE 1 — Verify Integration

**Goal:** Close the biggest user-cited gap: "khi verify cần biết làm gì". Wire brownfield context into verifier, debugger, new-feature, bug-fix. Make Stage 5 of investigation actually update artifacts.

**Ship criteria:** Running `new-feature` workflow Stage 5 against a feature in a brownfield project automatically verifies AC-{MODULE}-{NNN} from FLOWS.md.

---

### Task 1.1: Verifier loads brownfield context

**Files:**
- Modify: `agents/verifier.md` — Add Phase 0 + extend Phase 3

- [ ] **Step 1.1.1: Add Phase 0 (Brownfield Context Load) before Phase 1**

Insert after `[PROCESS]` section, before `### Phase 1: Spec Coverage`:

```markdown
### Phase 0: Brownfield Context Load (conditional)

If `.em-brownfield/INDEX.md` exists in repo root, this phase is MANDATORY. Otherwise skip.

1. Read `.em-brownfield/INDEX.md` → identify which module(s) the feature/fix touches.
   - Inputs: changed files from git diff, spec file path, branch name.
   - If module ambiguous → ASK USER: "This change touches files in [paths]. Which module(s)? Options: [list from INDEX.md]."
2. For each affected module, load:
   - `modules/{module}/FLOWS.md` → extract every AC-{MODULE}-{NNN} as a verification target
   - `modules/{module}/DOMAIN.md` → load entity invariants for assertion checks
   - `modules/{module}/INTEGRATIONS.md` → load failure modes for resilience checks
3. Read `.em-brownfield/DOMAIN-PROFILE.yaml` → load domain rules (P0 criteria, compliance, critical operations).
4. Build verification target list:
   - Spec ACs (from feature spec) — must all be covered
   - Brownfield ACs (AC-{MODULE}-{NNN} from FLOWS.md of affected modules) — must NOT regress
   - Domain invariants (from DOMAIN-PROFILE.yaml `critical_business_operations`) — must hold

Output Phase 0:
```yaml
brownfield_context_loaded: true | false
affected_modules: [module1, module2]
spec_acs: [AC-001, AC-002, ...]
brownfield_acs: [AC-ORDER-003, AC-PAYMENT-001, ...]
domain_invariants: ["Payment idempotency", "Audit trail completeness"]
```
```

- [ ] **Step 1.1.2: Extend Phase 3 (Acceptance Criteria) to check brownfield ACs**

Replace existing Phase 3 with:

```markdown
### Phase 3: Acceptance Criteria

For each acceptance criterion in the verification target list (spec ACs + brownfield ACs):
1. Verify implementation matches the criterion exactly.
2. Record evidence (test output, manual verification, AC ID source).
3. Mark PASS / PARTIAL / FAIL.

For brownfield ACs, additionally check:
- Does the changed code path still satisfy the AC? (regression check)
- If yes → PASS
- If no → FAIL (must fix before ship)
- If unclear → PARTIAL with reason "needs domain expert review"

Domain Invariants (from DOMAIN-PROFILE.yaml):
- For each invariant, check whether the change could violate it.
- If risky → flag as HIGH issue with "domain_invariant_risk" tag.
```

- [ ] **Step 1.1.3: Extend output_schema to include brownfield verification**

In frontmatter `output_schema.properties`, add:

```yaml
brownfield_verification:
  type: object
  properties:
    context_loaded: { type: boolean }
    affected_modules: { type: array, items: { type: string } }
    brownfield_acs_checked: { type: integer }
    brownfield_acs_passing: { type: integer }
    brownfield_acs_failing: { type: array, items: { type: string } }
    domain_invariant_risks: { type: array, items: { type: object } }
```

- [ ] **Step 1.1.4: Update Completion Marker**

Append to the existing checklist at bottom of file:

```markdown
- [ ] Brownfield context loaded (if .em-brownfield/ exists) OR documented as N/A
- [ ] All brownfield AC-{MODULE}-{NNN} from affected modules verified (no regressions)
- [ ] Domain invariants checked against changed code paths
```

- [ ] **Step 1.1.5: Commit**

```bash
git add agents/verifier.md
git commit -m "feat(verifier): integrate brownfield context for AC-{MODULE} verification

Verifier now loads .em-brownfield/ context (when present), extracts AC-{MODULE}-{NNN}
from FLOWS.md of affected modules, and verifies the change does not regress any
of them. Closes gap G4."
```

---

### Task 1.2: Debugger loads brownfield context

**Files:**
- Modify: `agents/debugger.md`

- [ ] **Step 1.2.1: Add Phase 0 before Phase 1 (Investigate)**

Insert after `[PROCESS]` heading:

```markdown
### Phase 0: Brownfield Context (conditional)

If `.em-brownfield/INDEX.md` exists:
1. From symptoms or error location, identify affected module via INDEX.md routes/files mapping.
   - If module ambiguous → ask user (offer module list from INDEX.md).
2. Load:
   - `modules/{module}/FLOWS.md` → know expected business behavior
   - `modules/{module}/CODE-MAP.md` → know exact file:function refs for the flow
   - `modules/{module}/INTEGRATIONS.md` → know external service failure modes
3. Use FLOWS.md happy path to compare against observed (failing) behavior.
   - Bug = "symptom doesn't match expected behavior at flow step N".
4. Check FLOWS.md `Known Issues` section first — if symptom matches, link to existing issue.
5. For deep chain bugs (root cause in different module than symptom):
   - Use INDEX.md dependency graph to identify candidate root-cause modules.
   - Recommend running `brownfield-investigation` workflow instead of standalone debugging.

If `.em-brownfield/` does not exist, proceed to Phase 1 (Investigate) as before.
```

- [ ] **Step 1.2.2: Update Rules section**

Add to `[RULES]`:

```markdown
9. **Use brownfield context when present.** Loading FLOWS.md + CODE-MAP.md from `.em-brownfield/`
   gives precise file:function references and expected behavior. Saves time + reduces hallucination.
   When module crosses dependencies, suggest the `brownfield-investigation` workflow.
```

- [ ] **Step 1.2.3: Update Completion Marker**

Append:

```markdown
- [ ] Brownfield context loaded (if .em-brownfield/ exists) OR documented as N/A
- [ ] If multi-module chain detected, brownfield-investigation workflow recommended
```

- [ ] **Step 1.2.4: Commit**

```bash
git add agents/debugger.md
git commit -m "feat(debugger): load brownfield context when investigating

Debugger now reads .em-brownfield/ FLOWS.md + CODE-MAP.md + INTEGRATIONS.md for
the affected module. Uses expected flow behavior to anchor what 'broken' means.
For multi-module bugs, recommends brownfield-investigation workflow."
```

---

### Task 1.3: new-feature workflow loads brownfield in Stage 0 + verifies in Stage 5

**Files:**
- Modify: `workflows/new-feature.md`

- [ ] **Step 1.3.1: Add Stage 0.5 (Brownfield Module Context)**

After Stage 0 (SETUP), insert new Stage 0.5:

```markdown
## Stage 0.5: BROWNFIELD CONTEXT (conditional)

<thought>
Observe: Repo may or may not have .em-brownfield/ context. If present, the feature
likely extends an existing module. Loading module context up-front prevents
duplicate flows, conflicting business rules, and missing acceptance criteria.
</thought>

<action>
type: conditional_context_load
condition: ".em-brownfield/INDEX.md exists"
steps:
  1. Read INDEX.md → list all modules
  2. Ask user: "Which existing module(s) does this feature extend?
     Options: [list]. If new module, type NEW: {proposed-name}."
  3. For each affected module, load:
     - modules/{module}/FLOWS.md → existing flows + ACs
     - modules/{module}/DOMAIN.md → entities to extend
     - modules/{module}/INTEGRATIONS.md → external deps to consider
  4. Record loaded context paths in feature spec doc for downstream stages.
</action>

<observation>
brownfield_present: true | false
affected_modules: [module1, ...]
existing_flows_loaded: N
existing_acs_loaded: N
</observation>

**Gate 0.5:** brownfield context loaded (if present) OR documented as N/A.

PASS → Stage 1 (or Stage 2 if skipping brainstorm)
```

- [ ] **Step 1.3.2: Extend Stage 5 (Verify) Gate 4+5 with brownfield checks**

Find the existing `**Gate 4+5 — Verification and Review Complete:**` block and ADD these items at end of checklist (before the `⛔ DO NOT proceed` line):

```markdown
- [ ] (if brownfield) All AC-{MODULE}-{NNN} from affected modules verified — no regressions
- [ ] (if brownfield) Domain invariants from DOMAIN-PROFILE.yaml hold for changed code paths
- [ ] (if brownfield) FLOWS.md updated if feature added new flow or modified existing flow
```

- [ ] **Step 1.3.3: Add Stage 5.7 (Brownfield Context Update)**

Insert between Step 5.6 and Stage 6:

```markdown
**Step 5.7 — Brownfield Context Update (conditional)**

If `.em-brownfield/` exists and this feature added or modified flows:

<action>
type: invoke_skill
target: brownfield-context-sync
params:
  scope: changed
  auto_fix: false
</action>

For each new flow:
1. Propose update to `modules/{module}/FLOWS.md`:
   - New `## Flow: {name}` section with happy path + ACs
   - Use next sequential FLOW-{MODULE}-{NNN} ID (Phase 3 work)
2. Update `modules/{module}/CODE-MAP.md` with new file:function refs
3. Update `INDEX.md` flows_count + Last Verified date
4. Present diff to user → APPROVE / MODIFY / SKIP

This ensures the knowledge graph grows with the codebase rather than becoming stale.
```

- [ ] **Step 1.3.4: Commit**

```bash
git add workflows/new-feature.md
git commit -m "feat(new-feature): integrate brownfield context (Stage 0.5 + Stage 5.7)

- Stage 0.5: conditional brownfield module context load before BRAINSTORM
- Stage 5 Gate: added brownfield AC + invariant checks
- Stage 5.7: post-verify context update writes new flows back to .em-brownfield/
Closes gap G25."
```

---

### Task 1.4: bug-fix workflow auto-routes to brownfield-investigation

**Files:**
- Modify: `workflows/bug-fix.md`

- [ ] **Step 1.4.1: Add Stage 0.5 (Routing Decision)**

After Stage 0 SETUP, insert new section:

```markdown
## Stage 0.5: ROUTING (conditional)

<thought>
If .em-brownfield/ exists, this bug investigation should use the brownfield-investigation
workflow instead, because brownfield-investigation provides module context, chain tracing,
and structured evidence with business narrative. The standalone bug-fix flow is for
greenfield or projects without brownfield setup.
</thought>

<action>
type: routing_decision
condition: ".em-brownfield/INDEX.md exists"
steps:
  IF brownfield context present:
    Suggest user: "I detected .em-brownfield/ context. Recommend running
    'brownfield-investigation' workflow instead — it provides module context,
    deep chain tracing, and structured evidence. Proceed with brownfield-investigation?"
    Options:
      A) YES — switch to brownfield-investigation (delegate Stages 1-5)
      B) NO — continue with standalone bug-fix
      C) SETUP — run brownfield-onboarding first, then brownfield-investigation
  ELSE:
    Proceed with Stage 1 (Investigate) as normal.
</action>

<observation>
routing_decision: brownfield-investigation | standalone | setup-first
</observation>

If user chose A: DELEGATE remaining stages to `workflows/brownfield-investigation.md`.
If user chose C: invoke `brownfield-onboarding` skill, then return to A.
Otherwise: continue Stage 1.
```

- [ ] **Step 1.4.2: Add brownfield context hint to Stage 1 (Investigate)**

In Stage 1, BEFORE the `<action>` block, add:

```markdown
**Brownfield hint (optional):** If `.em-brownfield/` exists but user opted for standalone
bug-fix, the debugger agent will still load module context via its Phase 0 (see
agents/debugger.md). No additional config needed here.
```

- [ ] **Step 1.4.3: Commit**

```bash
git add workflows/bug-fix.md
git commit -m "feat(bug-fix): auto-route to brownfield-investigation when context exists

Stage 0.5 detects .em-brownfield/ and offers to switch to brownfield-investigation
workflow. Also documents that debugger agent loads brownfield context regardless.
Closes gap G24."
```

---

### Task 1.5: Investigation Stage 5 actively updates context

**Files:**
- Modify: `workflows/brownfield-investigation.md`

- [ ] **Step 1.5.1: Replace Stage 5 CONTEXT UPDATE with active version**

Find `## Stage 5: CONTEXT UPDATE` section. Replace the entire `<action>` block with:

```markdown
<action>
type: context_update
steps:
  1. **New Known Issue → ACTIVE WRITE:**
     Read modules/{affected_module}/FLOWS.md.
     Find the affected flow's "Known Issues" section.
     Append:
     ```
     - #{issue_number} ({YYYY-MM-DD}): {1-line description} — status: open
       - Root cause module: {root_cause_module}
       - File: {file:function}
       - Severity: P{N}
     ```
     Save file. Show diff to user → APPROVE / MODIFY / SKIP.
  
  2. **Cross-module dependency missing → ACTIVE WRITE:**
     If root cause is in module B but symptom in module A:
     Open modules/A/FLOWS.md → check Dependencies section for B.
     If missing → APPEND to Dependencies: `[B](../B/FLOWS.md) — {1-line why}`
     Open modules/B/FLOWS.md → check Depended By for A.
     If missing → APPEND to Depended By: `[A](../A/FLOWS.md) — {1-line why}`
     Show diff → APPROVE / SKIP.
  
  3. **Flow behavior mismatch → PROPOSE UPDATE:**
     If observed behavior at step N differs from documented expectation:
     Generate proposed diff for modules/{module}/FLOWS.md showing the corrected step.
     Present: "Observed behavior at step {N}: '{observed}'. Documented: '{documented}'.
     Which is the bug — observed (fix code) or documented (fix docs)?"
     If user says doc was wrong → apply diff. If code was wrong → leave doc unchanged.
  
  4. **HEALTH-CHECK.md Investigation History → ACTIVE WRITE:**
     Append row to "Investigation History" table:
     | {YYYY-MM-DD} | {symptom_module} | {flow_name} | {bug_summary} | {root_cause_module} | P{N} | #{issue} |
  
  5. **INDEX.md Last Verified → ACTIVE WRITE:**
     Update Last Verified column for affected_module to today's date.
  
  6. **Investigation Report Artifact:**
     Write `.em-investigations/{YYYY-MM-DD}-{module}-{shortid}/REPORT.md` with full findings.
     Use template from templates/brownfield/INVESTIGATION-REPORT.md (created in Phase 1).
</action>

<observation>
context_updates_applied: N
context_updates_skipped: M (user rejected)
investigation_report_path: .em-investigations/...
</observation>

**Gate 5:** All context updates either APPLIED (with user confirmation) or explicitly SKIPPED.
```

- [ ] **Step 1.5.2: Create investigation report template**

Create: `templates/brownfield/INVESTIGATION-REPORT.md`

```markdown
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
```

- [ ] **Step 1.5.3: Commit**

```bash
git add workflows/brownfield-investigation.md templates/brownfield/INVESTIGATION-REPORT.md
git commit -m "feat(brownfield-investigation): activate Stage 5 to write context updates

Stage 5 now actively writes to FLOWS.md (Known Issues), cross-references
(Dependencies/Depended By), HEALTH-CHECK Investigation History, and INDEX.md
Last Verified date. New INVESTIGATION-REPORT.md template. Closes gap G5."
```

---

### Task 1.6: Structured DOMAIN-PROFILE for enforcement

**Files:**
- Create: `templates/brownfield/DOMAIN-PROFILE.yaml.template`
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md` — output both .md (human) and .yaml (machine)
- Modify: `templates/brownfield/DOMAIN-PROFILE.md` — add reference to YAML sidecar

- [ ] **Step 1.6.1: Create YAML template**

Create: `templates/brownfield/DOMAIN-PROFILE.yaml.template`

```yaml
# Machine-readable domain profile. Sidecar of DOMAIN-PROFILE.md.
# Loaded by: verifier, debugger, brownfield-investigation
version: "5.4.0"
confirmed_by_user: true
confirmed_date: YYYY-MM-DD

domain:
  primary: ""          # e.g., fintech, e-commerce, healthcare, workforce-management
  secondary: []        # e.g., [SaaS, multi-tenant, B2B]
  industry: ""         # e.g., Financial Services

compliance:
  - requirement: ""    # e.g., PCI-DSS
    scope: ""          # e.g., payment data handling
    status: known      # known | suspected | none
    audit_required: true

critical_business_operations:
  - id: OP-001
    name: ""           # e.g., "Payment processing"
    impact: ""         # what breaks if this fails (in business terms)

p0_criteria:
  # Conditions that automatically make a flow P0
  - "Money movement (any flow touching balances)"
  - "Audit trail writes (compliance requirement)"

p1_criteria:
  - "User-facing data integrity"
  - "SLA-bound operations"

domain_invariants:
  # Rules that must hold across the system. Verifier checks these.
  - id: INV-001
    rule: ""           # e.g., "Sum of credits = sum of debits"
    enforcement: ""    # where in code this is enforced

domain_terminology:
  - term: ""           # e.g., "Settlement"
    definition: ""     # business meaning
    code_name: ""      # variable/class name
    db_column: ""      # column name if different

domain_risk_areas:
  - risk: ""           # e.g., "Race condition in balance updates"
    impact: critical   # critical | high | medium | low
    likelihood: medium # high | medium | low
    mitigation_required: true
```

- [ ] **Step 1.6.2: Update brownfield-onboarding Phase 0 to output YAML sidecar**

In `skills/foundation/brownfield-onboarding/brownfield-onboarding.md`, find Phase 0c section "Output: Save domain classification to..." and replace with:

```markdown
**Output:** Save domain classification to BOTH formats:

1. **Human-readable:** `.em-brownfield/DOMAIN-PROFILE.md` (using `templates/brownfield/DOMAIN-PROFILE.md`)
2. **Machine-readable:** `.em-brownfield/DOMAIN-PROFILE.yaml` (using `templates/brownfield/DOMAIN-PROFILE.yaml.template`)

The YAML sidecar is consumed by verifier, debugger, and brownfield-investigation
to enforce domain rules programmatically. Both files must be kept in sync.
```

- [ ] **Step 1.6.3: Add YAML reference to .md template**

In `templates/brownfield/DOMAIN-PROFILE.md`, after the header, add:

```markdown
> **Machine-readable sidecar:** [`DOMAIN-PROFILE.yaml`](./DOMAIN-PROFILE.yaml) — keep in sync.
```

- [ ] **Step 1.6.4: Commit**

```bash
git add templates/brownfield/DOMAIN-PROFILE.yaml.template templates/brownfield/DOMAIN-PROFILE.md skills/foundation/brownfield-onboarding/brownfield-onboarding.md
git commit -m "feat(brownfield): add structured DOMAIN-PROFILE.yaml for programmatic enforcement

Onboarding Phase 0 now outputs both DOMAIN-PROFILE.md (human) and DOMAIN-PROFILE.yaml
(machine-readable). Downstream agents (verifier, debugger) consume the YAML to
enforce P0 criteria and domain invariants. Closes gap G6."
```

---

### Task 1.7: Evidence package schema

**Files:**
- Create: `templates/brownfield/EVIDENCE-MANIFEST.json.template`
- Modify: `workflows/brownfield-investigation.md` Stage 3

- [ ] **Step 1.7.1: Create manifest template**

Create: `templates/brownfield/EVIDENCE-MANIFEST.json.template`

```json
{
  "schema_version": "5.4.0",
  "investigation_id": "{YYYY-MM-DD}-{module}-{shortid}",
  "created_at": "{ISO-8601 timestamp}",
  "bug_summary": "{1-line summary}",
  "severity": "P0|P1|P2",
  "symptom_module": "{module-name}",
  "root_cause_module": "{module-name}",
  "affected_flow": "{flow-name}",
  "failed_step": {
    "step_number": 0,
    "step_description": "",
    "ac_violated": "AC-{MODULE}-{NNN}"
  },
  "evidence": {
    "video": {
      "path": "video.webm",
      "duration_seconds": 0,
      "covers_steps": [1, 2, 3]
    },
    "screenshots": [
      {
        "path": "step-1.png",
        "step": 1,
        "annotation": ""
      }
    ],
    "network_logs": {
      "path": "network.har",
      "request_count": 0,
      "failed_requests": []
    },
    "console_errors": {
      "path": "console.log",
      "error_count": 0
    },
    "test_artifacts": {
      "playwright_trace": "trace.zip",
      "test_output": "test-output.txt"
    }
  },
  "reproduction": {
    "auth_state": "credentials|oauth|storageState|none",
    "test_data": {},
    "browser": "",
    "viewport": ""
  },
  "context_links": {
    "flows_md": "../../../.em-brownfield/modules/{module}/FLOWS.md",
    "code_map": "../../../.em-brownfield/modules/{module}/CODE-MAP.md",
    "issue_url": ""
  }
}
```

- [ ] **Step 1.7.2: Update Stage 3 in workflows/brownfield-investigation.md**

Find `## Stage 3: EVIDENCE PACKAGE` and replace the `<action>` block:

```markdown
<action>
type: evidence_package
steps:
  1. Create directory: `.em-investigations/{YYYY-MM-DD}-{module}-{shortid}/`
     where shortid = first 8 chars of sha256(bug_description + timestamp)
  
  2. Save raw evidence files to subdirectory:
     - video.webm — full flow recording
     - screenshots/step-{N}.png — per step
     - network.har — network capture
     - console.log — console output
     - playwright-trace.zip (if Playwright-driven)
     - test-output.txt (if test-driven)
  
  3. Write EVIDENCE.json using `templates/brownfield/EVIDENCE-MANIFEST.json.template`:
     - All paths RELATIVE to investigation directory
     - investigation_id matches directory name
     - context_links point to .em-brownfield/ artifacts
  
  4. Write REPORT.md using `templates/brownfield/INVESTIGATION-REPORT.md` (created Task 1.5).
  
  5. Final structure:
     ```
     .em-investigations/2026-05-26-payment-a3f7c2b1/
     ├── EVIDENCE.json          # manifest
     ├── REPORT.md              # human-readable report
     ├── video.webm
     ├── network.har
     ├── console.log
     ├── playwright-trace.zip
     └── screenshots/
         ├── step-1.png
         ├── step-2.png
         └── step-3-FAIL.png
     ```
</action>
```

- [ ] **Step 1.7.3: Add `.em-investigations/` to .gitignore (or document policy)**

Read `.gitignore`. If `.em-investigations/` is not present, append:

```
# Bug investigation evidence — local only by default. Push selectively via PR if needed.
.em-investigations/
```

- [ ] **Step 1.7.4: Commit**

```bash
git add templates/brownfield/EVIDENCE-MANIFEST.json.template workflows/brownfield-investigation.md .gitignore
git commit -m "feat(brownfield-investigation): concrete evidence schema

Stage 3 now writes structured .em-investigations/{date}-{module}-{shortid}/
directory with EVIDENCE.json manifest + REPORT.md + raw artifacts.
Closes gap G7."
```

---

### Phase 1 Verification

- [ ] **V1.1: Manual verification on ras-app**

Run mental walkthrough:
1. `cd /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/ras-app`
2. Confirm `.em-brownfield/` does NOT exist there yet.
3. Open `agents/verifier.md` — confirm Phase 0 block present.
4. Open `workflows/new-feature.md` — confirm Stage 0.5 + Stage 5.7 present.
5. Open `workflows/bug-fix.md` — confirm Stage 0.5 routing decision present.

Expected: All 4 files updated. No broken Markdown.

- [ ] **V1.2: Lint markdown**

```bash
cd /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/Engineer-team
# Verify no malformed YAML frontmatter (skill validation)
bash scripts/validate-hermes.sh
```

Expected: Validation passes for verifier, debugger, brownfield-investigation, new-feature, bug-fix.

- [ ] **V1.3: Cross-reference integrity**

```bash
grep -n "templates/brownfield/INVESTIGATION-REPORT.md\|templates/brownfield/EVIDENCE-MANIFEST.json.template\|templates/brownfield/DOMAIN-PROFILE.yaml.template" \
  agents/verifier.md agents/debugger.md \
  workflows/new-feature.md workflows/bug-fix.md workflows/brownfield-investigation.md \
  skills/foundation/brownfield-onboarding/brownfield-onboarding.md
```

Expected: every referenced template file exists in `templates/brownfield/`.

- [ ] **V1.4: Final phase commit**

```bash
git add -u
git commit -m "feat(brownfield): Phase 1 complete — verify integration

Phase 1 closes gaps G4, G5, G6, G7, G24, G25:
- verifier loads brownfield context and checks AC-{MODULE}-{NNN}
- debugger loads brownfield context for investigation
- new-feature Stage 0.5 + 5.7 integrate brownfield
- bug-fix Stage 0.5 routes to brownfield-investigation
- Investigation Stage 5 actively writes context updates
- DOMAIN-PROFILE.yaml structured for programmatic enforcement
- Evidence package has concrete schema"
```

---

# PHASE 2 — Robustness

**Goal:** Stop the "silent drift" bleeding: replace fragile line numbers with stable symbols, provide concrete framework-aware scan tools, add JSON sidecars for programmatic access, handle monorepos.

**Ship criteria:** Running `brownfield-onboarding` on ras-app produces a working `.em-brownfield/` directory with no manual scanning. After a refactor that moves functions, `brownfield-context-sync` correctly identifies symbols without false STALE alerts.

---

### Task 2.1: Symbol-based references in CODE-MAP

**Files:**
- Modify: `templates/brownfield/MODULE-CODE-MAP.md`
- Modify: `skills/workflow/brownfield-context-sync/brownfield-context-sync.md`

- [ ] **Step 2.1.1: Update MODULE-CODE-MAP.md template — symbols first, lines second**

Replace the "Flow-to-Code Mapping" table format:

OLD:
```
| Step | File:Line | Function | ... |
| 1 | src/[path]:NN | functionName() | ... |
```

NEW:
```
| Step | Symbol | File | Line (hint) | Input | Output | Side Effects | Test Coverage |
|------|--------|------|-------------|-------|--------|-------------|---------------|
| 1 | OrderService.create | src/orders/order.service.ts | 145 | CreateOrderDto | Order | DB write: orders | TC-INT-005 |
```

Where:
- **Symbol** is the stable identifier: `{ClassName}.{methodName}` or `{moduleName}.{functionName}` or `{exportedName}`
- **Line** is a HINT, not an anchor. Validators resolve by symbol first, line second.

Add explanation block at top of "Flow-to-Code Mapping" section:

```markdown
> **Reference convention:** The `Symbol` column is the stable identifier. The `Line` column is a HINT only — it helps humans navigate but is not used for drift detection. brownfield-context-sync resolves references by symbol via the codebase scanner, not by line number. Refactors that move code don't break references as long as the symbol is preserved.
```

- [ ] **Step 2.1.2: Update Cross-Module Import Map section similarly**

OLD:
```
| Exported Function | File | Imported By Module | Import Location |
```

NEW:
```
| Symbol | File (hint) | Imported By Module | Import Symbol | Import File (hint) |
| OrderService.create | src/orders/order.service.ts | payment | OrderClient.notify | src/payment/order-client.ts |
```

- [ ] **Step 2.1.3: Update brownfield-context-sync to resolve by symbol**

In `skills/workflow/brownfield-context-sync/brownfield-context-sync.md`, replace Step 1a (CODE-MAP.md Validation):

```markdown
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
```

- [ ] **Step 2.1.4: Commit**

```bash
git add templates/brownfield/MODULE-CODE-MAP.md skills/workflow/brownfield-context-sync/brownfield-context-sync.md
git commit -m "feat(brownfield): symbol-based code references (no more line drift)

CODE-MAP.md now stores stable Symbol identifiers (ClassName.methodName) instead
of file:line refs. Line is a hint for humans only. context-sync resolves by
symbol via scripts/brownfield/symbol-resolver.sh, eliminating false-positive
STALE alerts on refactors. Closes gap G1."
```

---

### Task 2.2: Symbol resolver script

**Files:**
- Create: `scripts/brownfield/symbol-resolver.sh`

- [ ] **Step 2.2.1: Write the resolver**

Create: `scripts/brownfield/symbol-resolver.sh`

```bash
#!/usr/bin/env bash
# Resolve a symbol like "OrderService.create" or "createOrder" to file:line:signature.
# Outputs JSON: {"found": bool, "file": "...", "line": N, "signature": "..."}
# Falls back to grep-based heuristic if no LSP available.

set -euo pipefail

SYMBOL="${1:-}"
ROOT="${2:-.}"

if [[ -z "$SYMBOL" ]]; then
  echo '{"error": "Usage: symbol-resolver.sh <Symbol> [root]"}' >&2
  exit 1
fi

# Parse "Class.method" or "module.function" or bare "name"
CLASS=""
METHOD=""
if [[ "$SYMBOL" == *.* ]]; then
  CLASS="${SYMBOL%.*}"
  METHOD="${SYMBOL##*.}"
else
  METHOD="$SYMBOL"
fi

# Build search patterns per language
patterns=()
if [[ -n "$CLASS" ]]; then
  patterns+=(
    "class ${CLASS}"           # JS/TS/Java/C#/Python
    "${CLASS}\\.prototype\\.${METHOD}"
    "  ${METHOD}\\s*\\("       # TS/Java method in class
    "  ${METHOD}\\s*="         # arrow method
    "def ${METHOD}\\("         # Python
    "func \\(\\w+\\s+\\*?${CLASS}\\)\\s+${METHOD}\\("  # Go receiver
  )
else
  patterns+=(
    "function ${METHOD}"
    "const ${METHOD}"
    "def ${METHOD}\\("
    "func ${METHOD}\\("
    "fn ${METHOD}\\("
  )
fi

# Search across common source dirs, excluding node_modules/dist/build
search_dirs=("src" "apps" "packages" "lib" "internal" "pkg")
files_to_search=()
for dir in "${search_dirs[@]}"; do
  if [[ -d "${ROOT}/${dir}" ]]; then
    files_to_search+=("${ROOT}/${dir}")
  fi
done
[[ ${#files_to_search[@]} -eq 0 ]] && files_to_search+=("$ROOT")

best_file=""
best_line=""
best_signature=""

for pattern in "${patterns[@]}"; do
  while IFS=: read -r file line content; do
    [[ -z "$file" ]] && continue
    if [[ -z "$best_file" ]]; then
      best_file="$file"
      best_line="$line"
      best_signature="$content"
      # If we found a class declaration, keep looking for the method specifically
      if [[ -n "$CLASS" ]] && [[ "$content" == *"class ${CLASS}"* ]]; then
        # Find method line within file
        method_line=$(grep -nE "^\\s+(async\\s+)?${METHOD}\\s*[(:=]" "$file" | head -1 | cut -d: -f1)
        if [[ -n "$method_line" ]]; then
          best_line="$method_line"
          best_signature=$(sed -n "${method_line}p" "$file")
        fi
      fi
    fi
  done < <(grep -rnE "$pattern" "${files_to_search[@]}" \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
    --include="*.py" --include="*.go" --include="*.rs" --include="*.java" --include="*.kt" \
    --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=build --exclude-dir=.next \
    2>/dev/null || true)
  
  [[ -n "$best_file" ]] && break
done

if [[ -z "$best_file" ]]; then
  printf '{"found": false, "file": null, "line": null, "signature": null, "symbol": "%s"}\n' "$SYMBOL"
  exit 0
fi

# Escape JSON
escaped_signature=$(printf '%s' "$best_signature" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr -d '\r\n')
relative_file="${best_file#$ROOT/}"

printf '{"found": true, "file": "%s", "line": %s, "signature": "%s", "symbol": "%s"}\n' \
  "$relative_file" "$best_line" "$escaped_signature" "$SYMBOL"
```

- [ ] **Step 2.2.2: Make executable + add test**

```bash
chmod +x scripts/brownfield/symbol-resolver.sh
```

- [ ] **Step 2.2.3: Smoke test against ras-app**

```bash
bash scripts/brownfield/symbol-resolver.sh "EmployeeService" /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/ras-app
```

Expected output (JSON): `{"found": true, "file": "apps/api/src/employee/...", ...}` OR `{"found": false, ...}` if no such class.

If found:true, the resolver works. If found:false but class exists, debug the patterns.

- [ ] **Step 2.2.4: Commit**

```bash
git add scripts/brownfield/symbol-resolver.sh
git commit -m "feat(brownfield): symbol resolver script for stable refs

scripts/brownfield/symbol-resolver.sh resolves Class.method or function symbols
across TS/JS/Py/Go/Rust/Java/Kotlin source trees, falls back to grep heuristic
when no LSP available. Returns JSON: {found, file, line, signature}."
```

---

### Task 2.3: Stack-detection script

**Files:**
- Create: `scripts/brownfield/detect-stack.sh`

- [ ] **Step 2.3.1: Write detector**

Create: `scripts/brownfield/detect-stack.sh`

```bash
#!/usr/bin/env bash
# Detect tech stack of a brownfield project. Output JSON.
# Usage: detect-stack.sh [path]

set -euo pipefail
ROOT="${1:-.}"

detected=()
monorepo=false
package_managers=()

# Monorepo detection
[[ -f "${ROOT}/pnpm-workspace.yaml" ]] && monorepo=true && package_managers+=("pnpm")
[[ -f "${ROOT}/lerna.json" ]] && monorepo=true && package_managers+=("lerna")
[[ -f "${ROOT}/nx.json" ]] && monorepo=true && package_managers+=("nx")
[[ -f "${ROOT}/turbo.json" ]] && monorepo=true && package_managers+=("turbo")
[[ -d "${ROOT}/apps" ]] || [[ -d "${ROOT}/packages" ]] && monorepo=true

# Frontend frameworks
if [[ -f "${ROOT}/package.json" ]] || ls "${ROOT}"/apps/*/package.json &>/dev/null; then
  pkgs=$(cat "${ROOT}/package.json" 2>/dev/null; cat "${ROOT}"/apps/*/package.json 2>/dev/null || true)
  echo "$pkgs" | grep -q '"next"' && detected+=("nextjs")
  echo "$pkgs" | grep -q '"vite"' && detected+=("vite")
  echo "$pkgs" | grep -q '"react"' && detected+=("react")
  echo "$pkgs" | grep -q '"vue"' && detected+=("vue")
  echo "$pkgs" | grep -q '"@angular/core"' && detected+=("angular")
  echo "$pkgs" | grep -q '"svelte"' && detected+=("svelte")
  
  # Backend frameworks (TS/JS)
  echo "$pkgs" | grep -q '"@nestjs/core"' && detected+=("nestjs")
  echo "$pkgs" | grep -q '"express"' && detected+=("express")
  echo "$pkgs" | grep -q '"fastify"' && detected+=("fastify")
  echo "$pkgs" | grep -q '"@apollo/server\|graphql"' && detected+=("graphql")
fi

# Python
[[ -f "${ROOT}/requirements.txt" ]] || [[ -f "${ROOT}/pyproject.toml" ]] && {
  reqs=$(cat "${ROOT}/requirements.txt" "${ROOT}/pyproject.toml" 2>/dev/null || true)
  echo "$reqs" | grep -qi 'fastapi' && detected+=("fastapi")
  echo "$reqs" | grep -qi 'django' && detected+=("django")
  echo "$reqs" | grep -qi 'flask' && detected+=("flask")
}

# Go
[[ -f "${ROOT}/go.mod" ]] && {
  detected+=("go")
  grep -q 'gin-gonic' "${ROOT}/go.mod" 2>/dev/null && detected+=("gin")
  grep -q 'echo' "${ROOT}/go.mod" 2>/dev/null && detected+=("echo")
}

# Java/Kotlin/Spring
[[ -f "${ROOT}/pom.xml" ]] || [[ -f "${ROOT}/build.gradle" ]] || [[ -f "${ROOT}/build.gradle.kts" ]] && {
  detected+=("jvm")
  grep -qE 'spring-boot|spring-framework' "${ROOT}/pom.xml" "${ROOT}/build.gradle"* 2>/dev/null && detected+=("spring-boot")
}

# Rust
[[ -f "${ROOT}/Cargo.toml" ]] && {
  detected+=("rust")
  grep -q 'actix-web\|axum\|rocket' "${ROOT}/Cargo.toml" && detected+=("rust-web")
}

# Databases
[[ -f "${ROOT}/prisma/schema.prisma" ]] || ls "${ROOT}"/apps/*/prisma/schema.prisma &>/dev/null && detected+=("prisma")
grep -rq "mongoose" "${ROOT}/package.json" 2>/dev/null && detected+=("mongoose")
grep -rq "typeorm" "${ROOT}/package.json" 2>/dev/null && detected+=("typeorm")

# Test frameworks
grep -rq '"playwright"\|"@playwright/test"' "${ROOT}/package.json" 2>/dev/null && detected+=("playwright")
grep -rq '"jest"' "${ROOT}/package.json" 2>/dev/null && detected+=("jest")
grep -rq '"vitest"' "${ROOT}/package.json" 2>/dev/null && detected+=("vitest")

# Format output
detected_json=$(printf '"%s",' "${detected[@]}" | sed 's/,$//')
pm_json=$(printf '"%s",' "${package_managers[@]}" | sed 's/,$//')

cat <<EOF
{
  "monorepo": $monorepo,
  "package_managers": [$pm_json],
  "stack": [$detected_json],
  "apps": $(ls -d "${ROOT}"/apps/*/ 2>/dev/null | xargs -n1 basename | jq -R . | jq -s . || echo "[]"),
  "packages": $(ls -d "${ROOT}"/packages/*/ 2>/dev/null | xargs -n1 basename | jq -R . | jq -s . || echo "[]")
}
EOF
```

- [ ] **Step 2.3.2: Make executable + smoke test**

```bash
chmod +x scripts/brownfield/detect-stack.sh
bash scripts/brownfield/detect-stack.sh /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/ras-app
```

Expected: JSON with `monorepo: true`, `package_managers: ["pnpm"]`, `stack` containing `["nextjs|vite", "react", "nestjs", "prisma", "playwright"]`, `apps: ["api", "web"]`, `packages: ["shared-types"]`.

- [ ] **Step 2.3.3: Commit**

```bash
git add scripts/brownfield/detect-stack.sh
git commit -m "feat(brownfield): stack-detection script

scripts/brownfield/detect-stack.sh outputs JSON describing the project stack:
monorepo, package managers, frameworks (NestJS/Next.js/Spring/Django/FastAPI/...),
apps + packages list. Used by brownfield-onboarding Phase 1."
```

---

### Task 2.4: Framework-aware scan scripts

**Files:**
- Create: `scripts/brownfield/scan-nestjs.sh`
- Create: `scripts/brownfield/scan-react.sh`
- Create: `scripts/brownfield/scan-monorepo.sh`

- [ ] **Step 2.4.1: NestJS scanner**

Create: `scripts/brownfield/scan-nestjs.sh`

```bash
#!/usr/bin/env bash
# Scan NestJS modules: find @Controller, @Module, route mappings.
# Usage: scan-nestjs.sh [src_root]
# Output: JSON array of {module, controllers, routes, providers}

set -euo pipefail
SRC="${1:-apps/api/src}"

[[ ! -d "$SRC" ]] && { echo "[]"; exit 0; }

modules=()
while IFS= read -r module_file; do
  module_dir=$(dirname "$module_file")
  module_name=$(basename "$module_dir")
  
  # Find controllers
  controllers=()
  while IFS= read -r ctrl_file; do
    ctrl_name=$(grep -oE '@Controller\([^)]*\)' "$ctrl_file" | head -1)
    base_path=$(echo "$ctrl_name" | grep -oE "'[^']+'|\"[^\"]+\"" | tr -d "'\"" | head -1)
    class_name=$(grep -oE 'export class \w+' "$ctrl_file" | sed 's/export class //' | head -1)
    
    # Find route handlers
    routes=()
    while IFS= read -r route_line; do
      method=$(echo "$route_line" | grep -oE '@(Get|Post|Put|Delete|Patch)' | tr -d '@')
      path=$(echo "$route_line" | grep -oE "@${method}\(['\"][^'\"]*['\"]\)" | grep -oE "'[^']+'|\"[^\"]+\"" | tr -d "'\"" | head -1)
      routes+=("\"${method} ${base_path}/${path}\"")
    done < <(grep -nE '@(Get|Post|Put|Delete|Patch)\(' "$ctrl_file")
    
    routes_json=$(IFS=,; echo "${routes[*]}")
    controllers+=("{\"class\": \"$class_name\", \"file\": \"$ctrl_file\", \"routes\": [$routes_json]}")
  done < <(find "$module_dir" -maxdepth 2 -name "*.controller.ts" 2>/dev/null)
  
  ctrls_json=$(IFS=,; echo "${controllers[*]}")
  
  # Find providers (services)
  providers=()
  while IFS= read -r svc_file; do
    svc_class=$(grep -oE 'export class \w+Service' "$svc_file" | sed 's/export class //' | head -1)
    [[ -n "$svc_class" ]] && providers+=("\"$svc_class\"")
  done < <(find "$module_dir" -maxdepth 2 -name "*.service.ts" 2>/dev/null)
  
  providers_json=$(IFS=,; echo "${providers[*]}")
  
  modules+=("{\"module\": \"$module_name\", \"module_file\": \"$module_file\", \"controllers\": [$ctrls_json], \"providers\": [$providers_json]}")
done < <(find "$SRC" -name "*.module.ts" -not -name "app.module.ts" 2>/dev/null)

modules_json=$(IFS=,; echo "${modules[*]}")
echo "[$modules_json]"
```

- [ ] **Step 2.4.2: React/Vite/Next.js routes scanner**

Create: `scripts/brownfield/scan-react.sh`

```bash
#!/usr/bin/env bash
# Scan React/Next.js/Vite project for routes and components.
# Usage: scan-react.sh [src_root]
# Output: JSON {routes: [...], components: [...]}

set -euo pipefail
SRC="${1:-apps/web/src}"

[[ ! -d "$SRC" ]] && { echo '{"routes": [], "components": []}'; exit 0; }

routes=()

# Next.js App Router: app/**/page.tsx
while IFS= read -r f; do
  rel="${f#$SRC/}"
  route_path=$(echo "$rel" | sed 's/^app//; s/\/page\.\(tsx\|jsx\|js\|ts\)$//; s/\[\(\w*\)\]/:\1/g')
  [[ -z "$route_path" ]] && route_path="/"
  routes+=("{\"path\": \"$route_path\", \"file\": \"$f\", \"type\": \"next-app\"}")
done < <(find "$SRC/app" -name "page.tsx" -o -name "page.jsx" -o -name "page.js" -o -name "page.ts" 2>/dev/null)

# Next.js Pages Router: pages/**/*.tsx (excluding _*.tsx and api/)
while IFS= read -r f; do
  rel="${f#$SRC/}"
  basename_no_ext=$(basename "$f" | sed 's/\.\(tsx\|jsx\|js\|ts\)$//')
  [[ "$basename_no_ext" == _* ]] && continue
  route_path=$(echo "$rel" | sed 's/^pages//; s/\.\(tsx\|jsx\|js\|ts\)$//; s/\/index$/\//; s/\[\(\w*\)\]/:\1/g')
  routes+=("{\"path\": \"$route_path\", \"file\": \"$f\", \"type\": \"next-pages\"}")
done < <(find "$SRC/pages" -type f \( -name "*.tsx" -o -name "*.jsx" -o -name "*.js" -o -name "*.ts" \) -not -path "*/api/*" 2>/dev/null)

# Vite + React Router: search for createBrowserRouter / <Route> definitions
while IFS= read -r f; do
  while IFS= read -r line; do
    path=$(echo "$line" | grep -oE 'path:\s*['\''"][^'\''\"]+['\''"]|path=['\''"][^'\''\"]+['\''"]' | grep -oE "'[^']+'|\"[^\"]+\"" | head -1 | tr -d "'\"")
    [[ -n "$path" ]] && routes+=("{\"path\": \"$path\", \"file\": \"$f\", \"type\": \"react-router\"}")
  done < <(grep -nE 'path:\s*['\''"]|path=['\''"]' "$f" 2>/dev/null)
done < <(find "$SRC" -type f \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | head -50)

# Components (top-level src/components/*)
components=()
if [[ -d "$SRC/components" ]]; then
  while IFS= read -r f; do
    name=$(basename "$f" | sed 's/\.\(tsx\|jsx\|js\|ts\)$//')
    components+=("{\"name\": \"$name\", \"file\": \"$f\"}")
  done < <(find "$SRC/components" -maxdepth 3 -name "*.tsx" -o -name "*.jsx" 2>/dev/null | head -100)
fi

routes_json=$(IFS=,; echo "${routes[*]}")
components_json=$(IFS=,; echo "${components[*]}")

echo "{\"routes\": [$routes_json], \"components\": [$components_json]}"
```

- [ ] **Step 2.4.3: Monorepo orchestrator**

Create: `scripts/brownfield/scan-monorepo.sh`

```bash
#!/usr/bin/env bash
# Top-level scan for monorepo: detect each app's stack and dispatch.
# Usage: scan-monorepo.sh [root]
# Output: JSON {apps: [{name, stack, scan_result}], packages: [...]}

set -euo pipefail
ROOT="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

apps=()
packages=()

for app_dir in "${ROOT}"/apps/*/; do
  [[ ! -d "$app_dir" ]] && continue
  app_name=$(basename "$app_dir")
  
  # Detect app stack via its own package.json
  stack_json=$(bash "${SCRIPT_DIR}/detect-stack.sh" "$app_dir")
  has_nestjs=$(echo "$stack_json" | grep -q '"nestjs"' && echo true || echo false)
  has_react=$(echo "$stack_json" | grep -qE '"(react|nextjs|vite)"' && echo true || echo false)
  
  scan_result="{}"
  if [[ "$has_nestjs" == "true" ]] && [[ -d "${app_dir}/src" ]]; then
    scan_result=$(bash "${SCRIPT_DIR}/scan-nestjs.sh" "${app_dir}/src")
  elif [[ "$has_react" == "true" ]] && [[ -d "${app_dir}/src" ]]; then
    scan_result=$(bash "${SCRIPT_DIR}/scan-react.sh" "${app_dir}/src")
  fi
  
  apps+=("{\"name\": \"$app_name\", \"path\": \"apps/$app_name\", \"stack\": $stack_json, \"scan\": $scan_result}")
done

for pkg_dir in "${ROOT}"/packages/*/; do
  [[ ! -d "$pkg_dir" ]] && continue
  pkg_name=$(basename "$pkg_dir")
  packages+=("{\"name\": \"$pkg_name\", \"path\": \"packages/$pkg_name\"}")
done

apps_json=$(IFS=,; echo "${apps[*]}")
packages_json=$(IFS=,; echo "${packages[*]}")

echo "{\"apps\": [$apps_json], \"packages\": [$packages_json]}"
```

- [ ] **Step 2.4.4: Make executable + smoke test**

```bash
chmod +x scripts/brownfield/scan-nestjs.sh scripts/brownfield/scan-react.sh scripts/brownfield/scan-monorepo.sh
bash scripts/brownfield/scan-monorepo.sh /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/ras-app | head -100
```

Expected: JSON with `apps: [{name: "api", scan: {...nestjs modules...}}, {name: "web", scan: {...routes...}}]`.

- [ ] **Step 2.4.5: Commit**

```bash
git add scripts/brownfield/scan-nestjs.sh scripts/brownfield/scan-react.sh scripts/brownfield/scan-monorepo.sh
git commit -m "feat(brownfield): framework-aware scan scripts

- scan-nestjs.sh: discovers @Module + @Controller + routes + providers
- scan-react.sh: discovers Next.js App/Pages Router routes + React Router routes + components
- scan-monorepo.sh: orchestrates apps/* + packages/* per stack
Closes gaps G2 + G22."
```

---

### Task 2.5: Update brownfield-onboarding to use new tools

**Files:**
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md`

- [ ] **Step 2.5.1: Update Phase 1 to use scan scripts**

Replace Phase 1a section (`Project-Level Scan (auto, domain-informed)`):

```markdown
#### 1a. Stack Detection + Structured Scan (auto)

Run the stack detector first, then dispatch to framework-aware scanners:

```bash
# 1. Detect stack
stack_info=$(bash scripts/brownfield/detect-stack.sh {codebase_path})
echo "$stack_info"

# 2. Monorepo orchestration (handles apps/* automatically)
if echo "$stack_info" | jq -r '.monorepo' | grep -q true; then
  scan_result=$(bash scripts/brownfield/scan-monorepo.sh {codebase_path})
else
  # Single-app dispatch by detected stack
  if echo "$stack_info" | jq -r '.stack[]' | grep -q nestjs; then
    scan_result=$(bash scripts/brownfield/scan-nestjs.sh {codebase_path}/src)
  fi
  if echo "$stack_info" | jq -r '.stack[]' | grep -qE 'nextjs|react|vite'; then
    react_scan=$(bash scripts/brownfield/scan-react.sh {codebase_path}/src)
  fi
fi
```

The scan output is the authoritative source for:
- Entry points (controllers + routes from scan-nestjs; pages from scan-react)
- Cross-stack module mapping: `employee` in apps/api/src/employee/ + apps/web/src/pages/profiles/ both belong to module "employee"
- Per-app dependency boundaries

**Stop manual grep-based entry-point discovery in Phase 1b** — the scanners cover it.

#### 1a-extra. Documentation Scan (manual)
Still useful to read manually:
```bash
cat README.md ARCHITECTURE.md docs/*.md 2>/dev/null | head -200
```

#### 1a-extra2. Git Heat-Map (manual)
Most-changed files = active business areas:
```bash
git log --pretty=format: --name-only --since="3 months ago" \
  | sort | uniq -c | sort -rn | head -30
```
```

- [ ] **Step 2.5.2: Add Monorepo + Cross-Stack Module section in Phase 2**

After the "Clarifying Question Protocol" block in Phase 2, add:

```markdown
### Phase 2-extra: MONOREPO HANDLING

If the project is a monorepo (detect-stack reports `monorepo: true`):

**Cross-stack module rule:** A business module spans backend + frontend code. Group by domain, not by app.

Example for ras-app:
```
Module: 'employee'
  Backend: apps/api/src/employee/
  Frontend: apps/web/src/pages/profiles/  ← UI for employee management
  Shared: packages/shared-types (Employee, Skill, Position types)
```

For each candidate module:
1. Identify all source paths across apps/* and packages/* that belong to this business domain.
2. CODE-MAP.md lists files from MULTIPLE apps under one module's CODE-MAP.md.
3. Cross-app imports (apps/web imports from packages/shared-types) are tracked in CODE-MAP.md.

**Per-module folder remains flat:** `.em-brownfield/modules/{module-name}/` — not split per app.
```

- [ ] **Step 2.5.3: Add Test Discovery section**

After Phase 3, add:

```markdown
### Phase 3-extra: TEST DISCOVERY (flexible locations)

Tests may live in any of these patterns. Search ALL:
- Co-located: `src/orders/order.service.spec.ts`
- App-level: `apps/api/test/`
- Root-level (common for E2E): `tests/`, `e2e/`, `__tests__/`
- Per-package: `packages/{pkg}/test/` or `packages/{pkg}/__tests__/`

For each module's CODE-MAP.md, list tests by matching:
1. Filename heuristic: tests with module-name in path
2. Import heuristic: tests that import module's exported symbols
3. Route heuristic (E2E): tests that hit module's HTTP routes

Output: per-flow `Test Coverage` column in CODE-MAP.md filled with actual test file paths.
```

- [ ] **Step 2.5.4: Commit**

```bash
git add skills/foundation/brownfield-onboarding/brownfield-onboarding.md
git commit -m "feat(brownfield-onboarding): use concrete scan scripts + monorepo + test discovery

Phase 1a now dispatches to scripts/brownfield/scan-*.sh based on detected stack.
Phase 2-extra documents cross-stack module grouping for monorepos.
Phase 3-extra documents flexible test discovery (co-located + root + per-app).
Closes gaps G2, G22, G23."
```

---

### Task 2.6: JSON sidecars for all artifacts

**Files:**
- Create: `templates/brownfield/INDEX.json.template`
- Create: `templates/brownfield/MODULE-FLOWS.json.template`
- Create: `templates/brownfield/MODULE-CODE-MAP.json.template`
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md` — emit sidecars

- [ ] **Step 2.6.1: INDEX sidecar**

Create: `templates/brownfield/INDEX.json.template`

```json
{
  "schema_version": "5.4.0",
  "project": {
    "name": "",
    "tech_stack": [],
    "monorepo": false,
    "apps": [],
    "packages": []
  },
  "domain_profile_ref": "DOMAIN-PROFILE.yaml",
  "modules": [
    {
      "name": "",
      "type": "core|supporting|generic",
      "impact": "P0|P1|P2",
      "paths": {
        "backend": [],
        "frontend": [],
        "shared": []
      },
      "flows_count": 0,
      "entities_count": 0,
      "integrations_count": 0,
      "last_verified": "YYYY-MM-DD",
      "status": "OK|STALE|CONTRACT_BREAK|MISSING"
    }
  ],
  "dependencies": [
    {"from": "module-a", "to": "module-b", "reason": "..."}
  ],
  "external_integrations": [
    {"service": "", "modules_using": [], "critical": true, "fallback": false}
  ],
  "circular_dependencies": [],
  "stats": {
    "total_flows": 0,
    "total_entities": 0,
    "total_integrations": 0,
    "untested_flows": 0
  }
}
```

- [ ] **Step 2.6.2: MODULE-FLOWS sidecar**

Create: `templates/brownfield/MODULE-FLOWS.json.template`

```json
{
  "schema_version": "5.4.0",
  "module": "",
  "type": "core|supporting|generic",
  "impact": "P0|P1|P2",
  "last_verified": "YYYY-MM-DD",
  "dependencies": [{"module": "", "reason": ""}],
  "depended_by": [{"module": "", "reason": ""}],
  "flows": [
    {
      "id": "FLOW-{MODULE}-001",
      "name": "",
      "business_intent": {
        "who": "",
        "what": "",
        "why": "",
        "impact": "P0|P1|P2"
      },
      "happy_path": [
        {
          "step": 1,
          "description": "",
          "endpoint": "",
          "criticality": "high|medium|low",
          "business_rule": "",
          "data_flow": ""
        }
      ],
      "error_paths": [
        {"condition": "", "behavior": "", "user_impact": "", "recovery": ""}
      ],
      "business_rules": [],
      "acceptance_criteria": [
        {"id": "AC-{MODULE}-001", "text": "", "covered_by_test": ""}
      ],
      "known_issues": [
        {"issue_number": 0, "description": "", "status": "open|in-progress|wontfix"}
      ]
    }
  ]
}
```

- [ ] **Step 2.6.3: MODULE-CODE-MAP sidecar**

Create: `templates/brownfield/MODULE-CODE-MAP.json.template`

```json
{
  "schema_version": "5.4.0",
  "module": "",
  "last_verified": "YYYY-MM-DD",
  "source_directories": [
    {"purpose": "", "path": "", "file_count": 0}
  ],
  "flow_mappings": [
    {
      "flow_id": "FLOW-{MODULE}-001",
      "steps": [
        {
          "step": 1,
          "symbol": "ClassName.methodName",
          "file": "src/path/to/file.ts",
          "line_hint": 145,
          "input_type": "",
          "output_type": "",
          "side_effects": [],
          "test_coverage": []
        }
      ]
    }
  ],
  "key_functions": [
    {"symbol": "", "file": "", "purpose": "", "called_by": [], "calls": []}
  ],
  "cross_module_exports": [
    {"symbol": "", "file": "", "imported_by_module": "", "imported_at": ""}
  ],
  "cross_module_imports": [
    {"symbol": "", "from_module": "", "from_file": "", "used_in": ""}
  ],
  "test_coverage": {
    "unit": {"files": [], "flows_covered": [], "gaps": []},
    "integration": {"files": [], "flows_covered": [], "gaps": []},
    "e2e": {"files": [], "flows_covered": [], "gaps": []}
  }
}
```

- [ ] **Step 2.6.4: Add sidecar emission to brownfield-onboarding**

In `skills/foundation/brownfield-onboarding/brownfield-onboarding.md`, modify Phase 3 (PER-MODULE DEEP EXTRACTION) header:

```markdown
### Phase 3: PER-MODULE DEEP EXTRACTION (sequential per module)

For each confirmed module, generate 4 markdown artifacts AND their JSON sidecars:

| Markdown (human) | JSON sidecar (machine) | Template |
|---|---|---|
| FLOWS.md | FLOWS.json | MODULE-FLOWS.json.template |
| DOMAIN.md | DOMAIN.json | (Phase 4 — future) |
| INTEGRATIONS.md | INTEGRATIONS.json | (Phase 4 — future) |
| CODE-MAP.md | CODE-MAP.json | MODULE-CODE-MAP.json.template |

The JSON sidecars are the SOURCE OF TRUTH for programmatic access. Markdown is the
view layer for humans. Both MUST be kept in sync. brownfield-context-sync validates
that JSON and MD are consistent.

**Why sidecars?** Verifier, debugger, and brownfield-context-sync need to load
structured data without regex-parsing markdown tables. The JSON path is reliable;
the markdown path is for review and edits.
```

Also modify Phase 4 (CROSS-REFERENCE CONSTRUCTION) similarly:

```markdown
### Phase 4: CROSS-REFERENCE CONSTRUCTION (auto)

Build TWO files in parallel:
- `INDEX.md` — human-readable, from `templates/brownfield/INDEX.md`
- `INDEX.json` — machine-readable, from `templates/brownfield/INDEX.json.template`

Both are emitted from the same data structure. Future commands read INDEX.json directly.
```

- [ ] **Step 2.6.5: Commit**

```bash
git add templates/brownfield/INDEX.json.template templates/brownfield/MODULE-FLOWS.json.template templates/brownfield/MODULE-CODE-MAP.json.template skills/foundation/brownfield-onboarding/brownfield-onboarding.md
git commit -m "feat(brownfield): JSON sidecars for programmatic access

INDEX.json, FLOWS.json, CODE-MAP.json sidecars alongside markdown artifacts.
Sidecars are source-of-truth for verifier/debugger/context-sync; markdown is
the view layer. brownfield-onboarding now emits both. Closes gap G14."
```

---

### Phase 2 Verification

- [ ] **V2.1: Run scan stack on ras-app end-to-end**

```bash
bash scripts/brownfield/detect-stack.sh /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/ras-app | jq .
bash scripts/brownfield/scan-monorepo.sh /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/ras-app | jq '.apps[].name'
bash scripts/brownfield/symbol-resolver.sh "EmployeeController" /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/ras-app | jq .
```

Expected:
- detect-stack outputs valid JSON with monorepo=true, apps=["api","web"]
- scan-monorepo lists both apps with their scans
- symbol-resolver returns `{found: true, file: "apps/api/src/employee/employee.controller.ts", ...}`

- [ ] **V2.2: Validate JSON templates**

```bash
for f in templates/brownfield/*.json.template; do
  # Replace placeholders with valid JSON values for parsing test
  sed 's/{MODULE}/TEST/g' "$f" | jq empty && echo "$f: valid" || echo "$f: INVALID"
done
```

Expected: all templates parse as valid JSON.

- [ ] **V2.3: Final phase commit**

```bash
git add -u
git commit -m "feat(brownfield): Phase 2 complete — robustness

Phase 2 closes gaps G1, G2, G14, G22, G23:
- Symbol-based references replace line-anchored refs
- Concrete scan scripts (detect-stack, scan-nestjs, scan-react, scan-monorepo, symbol-resolver)
- JSON sidecars for programmatic access
- Monorepo + cross-stack module support
- Flexible test discovery"
```

---

# PHASE 3 — Active Sync

**Goal:** Keep the brownfield knowledge graph fresh during active development. Flow-discovery proposes FLOWS.md updates. PRs get impact analysis. Stable IDs survive renames.

**Ship criteria:** A flow-discovery session that records a new UI flow auto-proposes a diff to the relevant module's FLOWS.md. A PR that touches files referenced in CODE-MAP gets an impact report.

---

### Task 3.1: Stable flow IDs

**Files:**
- Modify: `templates/brownfield/MODULE-FLOWS.md`
- Modify: `templates/brownfield/MODULE-CODE-MAP.md`

- [ ] **Step 3.1.1: Add FLOW-{MODULE}-{NNN} ID to flows template**

In `templates/brownfield/MODULE-FLOWS.md`, replace `## Flow: [Flow Name]` with:

```markdown
## Flow: [Flow Name] {#flow-id}

**Flow ID:** FLOW-{MODULE}-{NNN} ← stable identifier (never rename or reuse)
```

And add a section near the top:

```markdown
## Flow ID Convention

- Format: `FLOW-{MODULE}-{NNN}` where NNN is zero-padded 3-digit sequence (001, 002, ...)
- IDs are append-only: once assigned, NEVER rename or reuse.
- If a flow is deprecated, mark it `(DEPRECATED)` but keep the ID.
- Cross-references use the ID: "see FLOW-ORDER-003" not "see Create Order flow".
```

- [ ] **Step 3.1.2: Reference flow IDs in CODE-MAP template**

In `templates/brownfield/MODULE-CODE-MAP.md`, modify the Flow-to-Code Mapping section to reference flow IDs:

```markdown
### Flow: [Flow Name] (FLOW-{MODULE}-{NNN})
```

- [ ] **Step 3.1.3: Commit**

```bash
git add templates/brownfield/MODULE-FLOWS.md templates/brownfield/MODULE-CODE-MAP.md
git commit -m "feat(brownfield): stable FLOW-{MODULE}-{NNN} IDs

Flows now have append-only stable IDs (FLOW-ORDER-003 etc.) so renames don't
break cross-references. CODE-MAP.md references by flow ID. Closes gap G8."
```

---

### Task 3.2: Backlinks index

**Files:**
- Create: `scripts/brownfield/build-backlinks.sh`
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md` — call backlinks builder after Phase 4

- [ ] **Step 3.2.1: Backlinks builder**

Create: `scripts/brownfield/build-backlinks.sh`

```bash
#!/usr/bin/env bash
# Build .em-brownfield/BACKLINKS.json — reverse index of all cross-references.
# Usage: build-backlinks.sh [brownfield-path]

set -euo pipefail
BF="${1:-.em-brownfield}"

[[ ! -d "$BF" ]] && { echo "{}" > /dev/stdout; exit 0; }

declare -A flow_refs
declare -A symbol_refs
declare -A ac_refs

# Scan all .md files for references
while IFS= read -r md_file; do
  # Find FLOW-{MODULE}-{NNN} refs
  while IFS= read -r flow_id; do
    [[ -z "$flow_id" ]] && continue
    flow_refs["$flow_id"]+="${md_file},"
  done < <(grep -oE 'FLOW-[A-Z_-]+-[0-9]+' "$md_file" 2>/dev/null | sort -u)
  
  # Find AC-{MODULE}-{NNN} refs
  while IFS= read -r ac_id; do
    [[ -z "$ac_id" ]] && continue
    ac_refs["$ac_id"]+="${md_file},"
  done < <(grep -oE 'AC-[A-Z_-]+-[0-9]+' "$md_file" 2>/dev/null | sort -u)
  
  # Find module cross-refs: [name](../name/FILE.md)
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    target=$(echo "$ref" | grep -oE '\.\./[^/]+/[^)]+')
    symbol_refs["$target"]+="${md_file},"
  done < <(grep -oE '\[[^]]+\]\(\.\.\/[^)]+\)' "$md_file" 2>/dev/null | sort -u)
done < <(find "$BF" -name "*.md" -type f)

# Emit JSON
echo "{"
echo '  "schema_version": "5.4.0",'
echo "  \"generated_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
echo '  "flow_refs": {'
first=true
for key in "${!flow_refs[@]}"; do
  refs=$(echo "${flow_refs[$key]}" | tr ',' '\n' | sed '/^$/d' | sort -u | sed 's/^/"/; s/$/"/' | tr '\n' ',' | sed 's/,$//')
  [[ "$first" == true ]] && first=false || echo "    ,"
  echo "    \"$key\": [$refs]"
done
echo "  },"
echo '  "ac_refs": {'
first=true
for key in "${!ac_refs[@]}"; do
  refs=$(echo "${ac_refs[$key]}" | tr ',' '\n' | sed '/^$/d' | sort -u | sed 's/^/"/; s/$/"/' | tr '\n' ',' | sed 's/,$//')
  [[ "$first" == true ]] && first=false || echo "    ,"
  echo "    \"$key\": [$refs]"
done
echo "  }"
echo "}"
```

- [ ] **Step 3.2.2: Smoke test (create dummy brownfield dir)**

```bash
mkdir -p /tmp/test-bf/modules/order
cat > /tmp/test-bf/modules/order/FLOWS.md <<'EOF'
# Order Flows
## Flow: Create Order (FLOW-ORDER-001)
References AC-ORDER-001 and FLOW-PAYMENT-002.
EOF
chmod +x scripts/brownfield/build-backlinks.sh
bash scripts/brownfield/build-backlinks.sh /tmp/test-bf
```

Expected: JSON with `flow_refs: {FLOW-ORDER-001: [...], FLOW-PAYMENT-002: [...]}` and `ac_refs: {AC-ORDER-001: [...]}`.

- [ ] **Step 3.2.3: Update onboarding to call builder**

In `skills/foundation/brownfield-onboarding/brownfield-onboarding.md`, after Phase 5 (HEALTH-CHECK):

```markdown
### Phase 5-extra: BACKLINKS INDEX (auto)

After all module artifacts are written, build the backlinks index:

```bash
bash scripts/brownfield/build-backlinks.sh .em-brownfield > .em-brownfield/BACKLINKS.json
```

This file provides reverse lookup for any flow ID, AC ID, or module reference.
Consumed by brownfield-context-sync to validate cross-reference integrity.
```

- [ ] **Step 3.2.4: Commit**

```bash
git add scripts/brownfield/build-backlinks.sh skills/foundation/brownfield-onboarding/brownfield-onboarding.md
git commit -m "feat(brownfield): backlinks builder for reference integrity

scripts/brownfield/build-backlinks.sh scans .em-brownfield/ for FLOW-X-NNN,
AC-X-NNN, and module cross-refs, emits BACKLINKS.json reverse index.
Used by context-sync to detect broken refs. Part of gap G8 fix."
```

---

### Task 3.3: Reference validator

**Files:**
- Create: `scripts/brownfield/validate-refs.sh`

- [ ] **Step 3.3.1: Validator**

Create: `scripts/brownfield/validate-refs.sh`

```bash
#!/usr/bin/env bash
# Validate all cross-references in .em-brownfield/ are reachable.
# Usage: validate-refs.sh [brownfield-path]
# Exit code 0: all refs OK. Exit code 1: at least one broken ref.

set -euo pipefail
BF="${1:-.em-brownfield}"

[[ ! -d "$BF" ]] && { echo "ERROR: $BF not found"; exit 1; }

broken=0
total=0

# Check module cross-refs [name](../name/FILE.md)
while IFS= read -r md_file; do
  base_dir=$(dirname "$md_file")
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    total=$((total + 1))
    target=$(echo "$ref" | grep -oE '\([^)]+\)' | tr -d '()')
    resolved="${base_dir}/${target}"
    if [[ ! -f "$resolved" ]]; then
      echo "BROKEN: $md_file → $target"
      broken=$((broken + 1))
    fi
  done < <(grep -oE '\[[^]]+\]\(\.\.\/[^)]+\)' "$md_file" 2>/dev/null)
done < <(find "$BF" -name "*.md" -type f)

# Check flow IDs referenced exist
declare -A defined_flows
while IFS= read -r flow_id; do
  defined_flows["$flow_id"]=1
done < <(grep -rhoE '^## Flow:.*\(FLOW-[A-Z_-]+-[0-9]+\)' "$BF" 2>/dev/null | grep -oE 'FLOW-[A-Z_-]+-[0-9]+')

while IFS= read -r flow_id; do
  total=$((total + 1))
  if [[ -z "${defined_flows[$flow_id]:-}" ]]; then
    echo "BROKEN FLOW REF: $flow_id is referenced but not defined"
    broken=$((broken + 1))
  fi
done < <(grep -rhoE 'FLOW-[A-Z_-]+-[0-9]+' "$BF" 2>/dev/null | sort -u)

echo "---"
echo "Total refs checked: $total"
echo "Broken refs: $broken"

[[ $broken -eq 0 ]] && exit 0 || exit 1
```

- [ ] **Step 3.3.2: Make executable + test**

```bash
chmod +x scripts/brownfield/validate-refs.sh
bash scripts/brownfield/validate-refs.sh /tmp/test-bf  # using dummy from previous task
```

Expected: Exit 0, "Total refs checked: N, Broken refs: 0".

- [ ] **Step 3.3.3: Commit**

```bash
git add scripts/brownfield/validate-refs.sh
git commit -m "feat(brownfield): reference integrity validator

scripts/brownfield/validate-refs.sh checks all module cross-refs and FLOW-X-NNN
IDs in .em-brownfield/. Exit 0 = OK, exit 1 = broken refs found. Use in CI."
```

---

### Task 3.4: brownfield-pr-impact skill (new)

**Files:**
- Create: `skills/workflow/brownfield-pr-impact/brownfield-pr-impact.md`

- [ ] **Step 3.4.1: Write the skill**

Create: `skills/workflow/brownfield-pr-impact/brownfield-pr-impact.md`

```markdown
---
name: brownfield-pr-impact
description: "Analyze a PR diff vs .em-brownfield/ context and produce an impact report. Identifies which flows, ACs, and dependent modules are touched, what may regress, and where context updates are needed. Run during code review or pre-merge."
version: "5.4.0"
category: "workflow"
origin: "EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "PR impact"
  - "brownfield impact"
  - "what does this PR affect"
  - "pre-merge check"
intent: "Given a PR diff (or current uncommitted changes), produce a structured report of which brownfield modules, flows, and ACs are affected — and what regression risk exists."
scenarios:
  - "Pre-merge: PR touches order.service.ts — what flows in module 'order' may regress?"
  - "Code review: which acceptance criteria from FLOWS.md does this change risk violating?"
  - "Sprint planning: what's the blast radius of this refactor across modules?"
best_for: "Pre-merge impact analysis, code review enrichment, cross-module change assessment"
estimated_time: "2-10 min (depends on diff size)"
anti_patterns:
  - "Running on greenfield projects (no .em-brownfield/ — use code-review instead)"
  - "Skipping symbol resolution and just doing filename matching"
  - "Ignoring CONTRACT_BREAK risk in dependent modules"
related_skills: [brownfield-onboarding, brownfield-context-sync, code-review]
input_schema:
  type: object
  required: [diff_source]
  properties:
    diff_source:
      type: string
      enum: [pr, branch, uncommitted]
      description: "What to analyze: PR (vs base branch), branch (vs main), or uncommitted (git diff HEAD)"
    pr_number:
      type: integer
      description: "Required if diff_source=pr"
    base_branch:
      type: string
      default: main
    brownfield_path:
      type: string
      default: .em-brownfield
output_schema:
  type: object
  required: [status, impact_report]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    impact_report:
      type: object
      properties:
        files_changed: { type: integer }
        modules_touched: { type: array, items: { type: string } }
        flows_affected:
          type: array
          items:
            type: object
            properties:
              flow_id: { type: string }
              module: { type: string }
              touched_files: { type: array, items: { type: string } }
              touched_symbols: { type: array, items: { type: string } }
              risk: { type: string, enum: [low, medium, high, critical] }
        acs_at_risk:
          type: array
          items:
            type: object
            properties:
              ac_id: { type: string }
              module: { type: string }
              reason: { type: string }
        contract_break_risks:
          type: array
          items:
            type: object
            properties:
              symbol: { type: string }
              dependents: { type: array, items: { type: string } }
        context_updates_recommended:
          type: array
          items: { type: string }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
---

# Brownfield PR Impact

[ROLE]
You are a pre-merge impact analyst. Given a code diff and an existing brownfield knowledge graph, produce a structured report of which business flows, acceptance criteria, and dependent modules are touched by the change — and where the brownfield context itself needs updating.

[OBJECTIVE]
Output a structured impact report (matching output_schema) that lists affected modules, flows, ACs at risk, contract break risks, and recommended context updates. This report enriches code review and pre-merge decisions.

[RULES]
1. <thought>Determine diff source (PR / branch / uncommitted). Plan extraction strategy.</thought>
2. Skip silently with status=NEEDS_CONTEXT if `.em-brownfield/` doesn't exist.
3. Use symbol resolution (scripts/brownfield/symbol-resolver.sh), not just filename matching, when classifying touched code.
4. Always check Dependents from INDEX.json — a function change in module A may affect modules B, C.
5. Flag CONTRACT_BREAK as high risk: function signature changes affecting cross-module callers.
6. Recommend specific context updates: "Add Known Issue to FLOW-ORDER-003" or "Update CODE-MAP.json line_hint for OrderService.calculate".
7. Be precise: cite file, symbol, flow_id, ac_id explicitly. Never vague.

[PROCESS]

### Step 1: Extract diff
```bash
case "$diff_source" in
  pr)
    gh pr diff "$pr_number" > /tmp/pr.diff
    ;;
  branch)
    git diff "$base_branch..HEAD" > /tmp/pr.diff
    ;;
  uncommitted)
    git diff HEAD > /tmp/pr.diff
    ;;
esac
```

Extract list of (file, +lines, -lines, changed symbols).

### Step 2: Map files → modules
For each changed file, look up which module owns it via `.em-brownfield/INDEX.json`:
```bash
jq -r --arg file "$file" '.modules[] | select(.paths.backend[]? == $file or .paths.frontend[]? == $file) | .name' .em-brownfield/INDEX.json
```

### Step 3: Map symbols → flows
For each changed symbol (function/class/method modified in diff), query CODE-MAP.json sidecars:
```bash
for module in $touched_modules; do
  jq -r --arg sym "$symbol" '.flow_mappings[] | select(.steps[]?.symbol == $sym) | .flow_id' \
    .em-brownfield/modules/$module/CODE-MAP.json
done
```

### Step 4: Identify ACs at risk
For each affected flow, list its ACs (from FLOWS.json). Flag any AC whose test coverage is in the changed file set:
```bash
jq -r --arg flow "$flow_id" '.flows[] | select(.id == $flow) | .acceptance_criteria[] | .id' \
  .em-brownfield/modules/$module/FLOWS.json
```

### Step 5: Contract break risks
For each changed symbol, check `cross_module_exports` in CODE-MAP.json:
- If the symbol is exported AND signature changed (need to diff signature, not just presence)
- Flag as CONTRACT_BREAK risk with list of importing modules

### Step 6: Recommend context updates
Produce a list of specific updates:
- "FLOW-ORDER-003 step 5: symbol moved from OrderService.calculate to OrderService.calculateTotal — update CODE-MAP.json"
- "Module 'order' depends on 'payment' (PaymentService.charge) — signature changed, update FLOWS.md Dependencies note"

### Step 7: Emit report
Write `.em-investigations/pr-{number}-impact/REPORT.md` (or `.em-investigations/diff-{shortid}-impact/`) using same structure as INVESTIGATION-REPORT but for impact analysis.

[RESPONSE FORMAT]
Return output matching output_schema. Risk levels:
- **critical:** CONTRACT_BREAK affecting >3 dependents OR touches P0 flow steps
- **high:** Touches P0 flow OR CONTRACT_BREAK affecting 1-3 dependents
- **medium:** Touches P1 flow OR changes test-covered symbol
- **low:** Touches P2 flow OR documentation-only changes

[VERIFICATION]
- [ ] All changed files mapped to modules (or flagged as MISSING from brownfield context)
- [ ] All changed symbols resolved via symbol-resolver
- [ ] Affected flows and ACs listed with explicit IDs
- [ ] Contract break risks flagged with dependent module list
- [ ] Context updates are concrete (cite file + line + change)
- [ ] Report emitted to .em-investigations/

[HANDOFF]
Output is consumed by:
- code-review skill (enriches review with business impact)
- new-feature workflow Stage 5.7 (informs context update step)
- verifier agent (flags brownfield ACs at risk)
- Optional: GitHub PR comment via hook
```

- [ ] **Step 3.4.2: Commit**

```bash
git add skills/workflow/brownfield-pr-impact/brownfield-pr-impact.md
git commit -m "feat(brownfield): new brownfield-pr-impact skill

Analyzes PR/branch/uncommitted diff vs .em-brownfield/ context. Produces
structured impact report: modules touched, flows affected, ACs at risk,
contract break risks, recommended context updates. Closes gap G9."
```

---

### Task 3.5: Flow-discovery bidirectional sync

**Files:**
- Modify: `skills/quality/flow-discovery/flow-discovery.md`

- [ ] **Step 3.5.1: Replace Step 3b (ENRICH) with bidirectional matching**

Find `### Step 3b: ENRICH` and replace with:

```markdown
### Step 3b: ENRICH + SYNC (if brownfield context available)

If `.em-brownfield/INDEX.json` exists:

#### 3b.1: Auto-detect target module
```bash
# Use first step's URL to find module owning that route
url_path=$(echo "$first_step_url" | grep -oE '/[^?]+' | head -1)
target_module=$(jq -r --arg p "$url_path" '
  .modules[] | select(.paths.frontend[]? | contains($p)) | .name
' .em-brownfield/INDEX.json | head -1)
```

If module ambiguous → ASK USER which module this flow belongs to.

#### 3b.2: Match step-to-flow by (URL pattern + selector context + business intent)
For each recorded step, find candidate flow steps in `modules/{module}/FLOWS.json`:

Matching criteria (in order of precedence):
1. **URL pattern match:** Recorded URL matches flow step's endpoint (with param normalization: `/users/123` → `/users/:id`)
2. **Action + selector match:** Recorded action (click/fill/select) matches expected action AND selector matches data-testid pattern
3. **Business intent match (fuzzy):** Step description matches flow step's business_intent text

If ALL three fail → step is UNMATCHED (likely new business behavior).

#### 3b.3: Enrich matched steps (existing behavior)
For matched steps:
- business_intent ← matched flow step
- criticality ← matched flow step
- acceptance_criterion ← matched flow step
- failure_impact ← matched flow step
- data_flow ← from CODE-MAP.json

#### 3b.4: Propose FLOWS.md UPDATE for unmatched/new steps
For unmatched steps OR if entire flow is new:

Build a proposed diff to `modules/{module}/FLOWS.md`:

```markdown
## Flow: {recorded flow name} (FLOW-{MODULE}-{next_NNN})

### Business Intent
- **Who:** [PROPOSE — needs user fill]
- **What:** {auto-derived from flow name + steps}
- **Why:** [PROPOSE — needs user fill]
- **Impact Level:** [PROPOSE — defaults to P1]

### Happy Path
1. {recorded step 1 description} → `{endpoint}` → {expected result from selector}
   - **Criticality:** medium [PROPOSE]
   - **Business rule:** [PROPOSE]
   - **Data flow:** [from CODE-MAP if symbol resolved]
...

### Acceptance Criteria
- [ ] AC-{MODULE}-{next_NNN}: {auto-derived from each step's expected result}
```

Present this diff to user:
```
DISCOVERED NEW FLOW: "{flow name}"
Module candidate: {module}
Proposed new entries (N steps, M ACs):

[show diff]

→ APPROVE (write to FLOWS.md) / MODIFY / SKIP / REJECT (don't add to brownfield)
```

If APPROVE:
- Allocate next FLOW-{MODULE}-{NNN} ID
- Allocate next AC-{MODULE}-{NNN} IDs sequentially
- Write to BOTH FLOWS.md and FLOWS.json
- Update INDEX.md flows_count + Last Verified

#### 3b.5: Propose FLOWS.md UPDATE for modified existing steps
If recorded step matched a flow step BUT behavior differs:
- Present: "Recorded behavior at step {N}: '{observed}'. FLOWS.md says: '{documented}'."
- Options: UPDATE FLOWS.md (recorded is correct) | KEEP FLOWS.md (recorded is anomaly) | INVESTIGATE (could be bug)
```

- [ ] **Step 3.5.2: Update flow-discovery output_schema**

In frontmatter, modify `output_schema.flows.items.properties` to add:

```yaml
brownfield_sync:
  type: object
  properties:
    target_module: { type: string }
    matched_flow: { type: string, description: "FLOW-{MODULE}-{NNN} if matched existing" }
    new_flow_id_proposed: { type: string, description: "FLOW-{MODULE}-{NNN} if new" }
    flows_md_updated: { type: boolean }
    acs_added: { type: array, items: { type: string } }
```

- [ ] **Step 3.5.3: Update Verification checklist**

In `[VERIFICATION]` section, add:

```markdown
- [ ] (if brownfield) Target module identified
- [ ] (if brownfield) Steps matched to existing flow OR new flow proposed with diff
- [ ] (if brownfield) User APPROVED/SKIPPED FLOWS.md updates
- [ ] (if brownfield) FLOW-{MODULE}-{NNN} + AC IDs allocated sequentially
```

- [ ] **Step 3.5.4: Commit**

```bash
git add skills/quality/flow-discovery/flow-discovery.md
git commit -m "feat(flow-discovery): bidirectional sync with brownfield context

Step 3b now does both: enriches matched steps AND proposes FLOWS.md updates
for unmatched/new flows. Auto-detects target module from URL pattern. Allocates
next FLOW-{MODULE}-{NNN} IDs and AC IDs. Improved match algorithm uses URL
pattern normalization + selector context + business intent fuzzy match.
Closes gap G3."
```

---

### Task 3.6: Optional pre-push hook

**Files:**
- Create: `hooks/brownfield-pr-check`

- [ ] **Step 3.6.1: Hook script**

Create: `hooks/brownfield-pr-check`

```bash
#!/usr/bin/env bash
# Pre-push hook: runs brownfield-pr-impact and warns about high-risk changes.
# Install: cp hooks/brownfield-pr-check .git/hooks/pre-push && chmod +x .git/hooks/pre-push
# Bypass: git push --no-verify

set -euo pipefail

# Skip if .em-brownfield/ doesn't exist
[[ ! -d ".em-brownfield" ]] && exit 0

# Skip if no changes vs main
if git diff --quiet main..HEAD 2>/dev/null; then
  exit 0
fi

echo "🔍 Brownfield PR impact check..."

# Run impact analysis (assumes brownfield-pr-impact skill is invokable via CLI wrapper)
# For now, run lightweight check: list affected modules
changed_files=$(git diff --name-only main..HEAD 2>/dev/null || git diff --name-only HEAD)

if [[ -z "$changed_files" ]]; then
  exit 0
fi

# Quick scan: which modules' paths are touched?
modules_touched=""
if [[ -f ".em-brownfield/INDEX.json" ]]; then
  for file in $changed_files; do
    mod=$(jq -r --arg f "$file" '.modules[] | select((.paths.backend[]? + .paths.frontend[]?) | contains($f)) | .name' .em-brownfield/INDEX.json 2>/dev/null || true)
    [[ -n "$mod" ]] && modules_touched+="$mod "
  done
fi

if [[ -n "$modules_touched" ]]; then
  unique_mods=$(echo "$modules_touched" | tr ' ' '\n' | sort -u | tr '\n' ',' | sed 's/,$//')
  echo ""
  echo "⚠️  Brownfield modules affected: $unique_mods"
  echo ""
  echo "Consider running: brownfield-pr-impact (via Skill tool) for full impact analysis."
  echo "Or run brownfield-context-sync to validate no contract breaks."
  echo ""
  echo "Push proceeding..."
fi

exit 0
```

- [ ] **Step 3.6.2: Make executable + doc**

```bash
chmod +x hooks/brownfield-pr-check
```

Append to `hooks/README.md` (or create if missing) — document the hook:

```markdown
## brownfield-pr-check

Pre-push hook. When `.em-brownfield/` exists, warns about which brownfield modules
the push affects. Non-blocking (always exits 0).

Install:
```bash
cp hooks/brownfield-pr-check .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

Bypass: `git push --no-verify`
```

- [ ] **Step 3.6.3: Commit**

```bash
git add hooks/brownfield-pr-check hooks/README.md
git commit -m "feat(brownfield): pre-push hook for impact awareness

hooks/brownfield-pr-check warns which brownfield modules a push affects.
Non-blocking. Install instructions in hooks/README.md."
```

---

### Phase 3 Verification

- [ ] **V3.1: End-to-end test with dummy brownfield**

```bash
# Use dummy brownfield from /tmp/test-bf or create fresh
mkdir -p /tmp/test-bf3/.em-brownfield/modules/order
cat > /tmp/test-bf3/.em-brownfield/INDEX.json <<'EOF'
{
  "schema_version": "5.4.0",
  "modules": [{"name": "order", "type": "core", "impact": "P0", "paths": {"backend": ["src/order/"], "frontend": []}}]
}
EOF

# Validate refs (should pass with empty modules)
bash scripts/brownfield/validate-refs.sh /tmp/test-bf3/.em-brownfield && echo "PASS"

# Build backlinks (should produce JSON with empty maps)
bash scripts/brownfield/build-backlinks.sh /tmp/test-bf3/.em-brownfield | jq .

# Cleanup
rm -rf /tmp/test-bf3
```

Expected: validate-refs passes, build-backlinks emits valid JSON.

- [ ] **V3.2: Final phase commit**

```bash
git add -u
git commit -m "feat(brownfield): Phase 3 complete — active sync

Phase 3 closes gaps G3, G5, G8, G9:
- Stable FLOW-{MODULE}-{NNN} IDs survive renames
- Backlinks builder + reference validator
- New brownfield-pr-impact skill for pre-merge impact analysis
- flow-discovery now proposes FLOWS.md updates bidirectionally
- Optional pre-push hook for impact awareness"
```

---

# PHASE 4 — Polish

**Goal:** Reference example, quality gate, expanded domain coverage, test-engineer integration, privacy guidance.

**Ship criteria:** A complete `.em-brownfield/` example for ras-app commits to `examples/`. Onboarding skill has a quality gate. brownfield-test-engineer explicitly maps AC→TC, DOMAIN entities→fixtures, INTEGRATIONS failure modes→negative TCs.

---

### Task 4.1: Reference example — ras-app brownfield

**Files:**
- Create: `examples/brownfield/ras-app/.em-brownfield/` (full reference)

- [ ] **Step 4.1.1: Run actual onboarding on ras-app (or mock it)**

Use the scripts created in Phase 2:

```bash
cd /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system
mkdir -p Engineer-team/examples/brownfield/ras-app/.em-brownfield/modules/{allocation,employee,project,dashboard,audit,sync,auth}

# Generate DOMAIN-PROFILE.yaml
cat > Engineer-team/examples/brownfield/ras-app/.em-brownfield/DOMAIN-PROFILE.yaml <<'EOF'
version: "5.4.0"
confirmed_by_user: true
confirmed_date: 2026-05-26

domain:
  primary: "Workforce / Resource Management"
  secondary: ["B2B SaaS"]
  industry: "Technology Services"

compliance:
  - requirement: "GDPR"
    scope: "Employee personal data"
    status: known
    audit_required: false

critical_business_operations:
  - id: OP-001
    name: "Allocation calculation"
    impact: "Resource allocation accuracy directly affects project staffing decisions"
  - id: OP-002
    name: "Employee profile data integrity"
    impact: "Profile inaccuracies cascade to allocation mistakes"

p0_criteria:
  - "Allocation data writes (resource conflicts)"
  - "Audit log writes"

p1_criteria:
  - "Dashboard read consistency"
  - "Sync with external HR system"

domain_invariants:
  - id: INV-001
    rule: "Sum of employee allocations across projects ≤ 100% per period"
    enforcement: "AllocationService.validate"
  - id: INV-002
    rule: "Audit log entry for every allocation change"
    enforcement: "AllocationService.create/update + audit interceptor"

domain_terminology:
  - term: "Allocation"
    definition: "Percentage commitment of an employee to a project for a time period"
    code_name: "Allocation"
    db_column: "allocations"
  - term: "Position"
    definition: "Role required for a project (e.g., Backend Engineer, Designer)"
    code_name: "Position"
    db_column: "positions"

domain_risk_areas:
  - risk: "Overallocation (>100%)"
    impact: critical
    likelihood: high
    mitigation_required: true
  - risk: "Race condition on concurrent allocation updates"
    impact: high
    likelihood: medium
    mitigation_required: true
EOF
```

- [ ] **Step 4.1.2: Generate INDEX.md + INDEX.json**

```bash
cat > Engineer-team/examples/brownfield/ras-app/.em-brownfield/INDEX.md <<'EOF'
# Brownfield Context Index — ras-app

## Project
- **Name:** Resource Allocation System (ras-app)
- **Domain:** Workforce / Resource Management (see [DOMAIN-PROFILE.md](./DOMAIN-PROFILE.md))
- **Tech Stack:** TypeScript, NestJS, React + Vite, Prisma, PostgreSQL, Playwright
- **Monorepo:** Yes (pnpm) — apps/api, apps/web, packages/shared-types
- **Created:** 2026-05-26
- **Last Full Sync:** 2026-05-26

---

## Modules

| Module | Type | Impact | Flows | Entities | Integrations | Last Verified | Status |
|--------|------|--------|-------|----------|-------------|---------------|--------|
| [allocation](modules/allocation/FLOWS.md) | Core | P0 | 4 | 3 | 0 | 2026-05-26 | OK |
| [employee](modules/employee/FLOWS.md) | Core | P0 | 5 | 4 | 1 | 2026-05-26 | OK |
| [project](modules/project/FLOWS.md) | Core | P0 | 4 | 2 | 0 | 2026-05-26 | OK |
| [dashboard](modules/dashboard/FLOWS.md) | Supporting | P1 | 2 | 0 | 0 | 2026-05-26 | OK |
| [audit](modules/audit/FLOWS.md) | Supporting | P0 | 2 | 1 | 0 | 2026-05-26 | OK |
| [sync](modules/sync/FLOWS.md) | Supporting | P1 | 2 | 0 | 1 | 2026-05-26 | OK |
| [auth](modules/auth/FLOWS.md) | Generic | P0 | 3 | 1 | 1 | 2026-05-26 | OK |

## Dependency Graph

```
[allocation] → [employee], [project], [audit]
[dashboard]  → [allocation], [employee], [project]
[sync]       → [employee], (external: HR system)
[auth]       → (external: OAuth provider)
[audit]      → (consumed by all)
```

## Cross-Cutting Concerns

| Concern | Used By Modules | Implementation |
|---------|----------------|----------------|
| Authentication | all | apps/api/src/auth/auth.guard.ts |
| Authorization | allocation, audit | apps/api/src/auth/roles.guard.ts |
| Audit logging | allocation, employee, project | apps/api/src/audit/audit.interceptor.ts |

---

## External Integration Registry

| Service | Type | Used By Modules | Critical? | Fallback? |
|---------|------|----------------|-----------|-----------|
| OAuth Provider | OIDC | auth | Yes | No |
| External HR System | REST API | sync, employee | No | Yes (queue) |

## Quick Stats
- **Total modules:** 7
- **Total flows:** 22
- **Total entities:** 11
- **Total external integrations:** 2
- **Circular dependencies:** 0
- **Untested flows:** 3
EOF
```

Generate parallel INDEX.json following template. (Same data structure.)

- [ ] **Step 4.1.3: Generate one full module example (allocation)**

Create files for the `allocation` module showing:
- FLOWS.md — 4 flows with FLOW-ALLOCATION-001..004, ACs, criticality
- DOMAIN.md — Allocation, Position entities with constraints
- INTEGRATIONS.md — no external (but internal deps documented)
- CODE-MAP.md — symbol-based refs into apps/api/src/allocation/

(For brevity, only one fully-fleshed module is needed as reference. Others can be stub-quality.)

- [ ] **Step 4.1.4: Commit**

```bash
git add Engineer-team/examples/brownfield/ras-app/
git commit -m "docs(brownfield): reference example .em-brownfield/ for ras-app

Full DOMAIN-PROFILE + INDEX + allocation module artifacts. Other modules
stubbed. Agents learning the system can read this to calibrate output quality.
Closes gap G11."
```

---

### Task 4.2: Quality gate for onboarding output

**Files:**
- Create: `scripts/brownfield/quality-score.sh`
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md` — invoke quality-score at end of Phase 6

- [ ] **Step 4.2.1: Quality scorer**

Create: `scripts/brownfield/quality-score.sh`

```bash
#!/usr/bin/env bash
# Score a .em-brownfield/ directory for onboarding quality.
# Output JSON with per-dimension scores 0-100 + overall grade A/B/C/D.

set -euo pipefail
BF="${1:-.em-brownfield}"
[[ ! -d "$BF" ]] && { echo '{"error": "not found"}'; exit 1; }

scores=()
issues=()

# D1: Domain profile completeness (0-100)
d1=0
if [[ -f "$BF/DOMAIN-PROFILE.yaml" ]]; then
  d1=20
  grep -q "primary:" "$BF/DOMAIN-PROFILE.yaml" && [[ "$(grep "primary:" "$BF/DOMAIN-PROFILE.yaml")" != *'""'* ]] && d1=$((d1 + 20))
  grep -q "critical_business_operations:" "$BF/DOMAIN-PROFILE.yaml" && d1=$((d1 + 20))
  grep -q "p0_criteria:" "$BF/DOMAIN-PROFILE.yaml" && d1=$((d1 + 20))
  grep -q "domain_invariants:" "$BF/DOMAIN-PROFILE.yaml" && d1=$((d1 + 20))
else
  issues+=("\"missing DOMAIN-PROFILE.yaml\"")
fi
scores+=("\"domain_profile\": $d1")

# D2: Module structure completeness
total_mods=0
complete_mods=0
for mod in "$BF"/modules/*/; do
  [[ ! -d "$mod" ]] && continue
  total_mods=$((total_mods + 1))
  has_all=true
  for required in FLOWS.md DOMAIN.md INTEGRATIONS.md CODE-MAP.md; do
    [[ ! -f "${mod}${required}" ]] && has_all=false
  done
  $has_all && complete_mods=$((complete_mods + 1))
done
d2=$([[ $total_mods -gt 0 ]] && echo $((complete_mods * 100 / total_mods)) || echo 0)
scores+=("\"module_completeness\": $d2")

# D3: Cross-reference integrity (run validator)
d3=0
if bash scripts/brownfield/validate-refs.sh "$BF" >/dev/null 2>&1; then
  d3=100
else
  d3=50  # has refs but some broken
fi
scores+=("\"cross_references\": $d3")

# D4: Flow ID stability (all flows have FLOW-X-NNN IDs)
total_flows=0
ided_flows=0
while IFS= read -r f; do
  flows_in_file=$(grep -c "^## Flow:" "$f" 2>/dev/null || echo 0)
  ids_in_file=$(grep -c "^## Flow:.*FLOW-[A-Z_-]\+-[0-9]\+" "$f" 2>/dev/null || echo 0)
  total_flows=$((total_flows + flows_in_file))
  ided_flows=$((ided_flows + ids_in_file))
done < <(find "$BF" -name "FLOWS.md")
d4=$([[ $total_flows -gt 0 ]] && echo $((ided_flows * 100 / total_flows)) || echo 100)
scores+=("\"flow_ids\": $d4")

# D5: JSON sidecars present
total_md=$(find "$BF" -name "*.md" | wc -l | tr -d ' ')
total_json=$(find "$BF" -name "*.json" | wc -l | tr -d ' ')
expected_json=$((total_md / 2))  # roughly half should have sidecars (INDEX + per-module FLOWS + CODE-MAP)
d5=$([[ $expected_json -gt 0 ]] && echo $((total_json * 100 / expected_json)) || echo 0)
[[ $d5 -gt 100 ]] && d5=100
scores+=("\"sidecars\": $d5")

# Overall
sum=$((d1 + d2 + d3 + d4 + d5))
overall=$((sum / 5))
grade="D"
[[ $overall -ge 90 ]] && grade="A"
[[ $overall -ge 75 ]] && [[ $overall -lt 90 ]] && grade="B"
[[ $overall -ge 60 ]] && [[ $overall -lt 75 ]] && grade="C"

scores_json=$(IFS=,; echo "${scores[*]}")
issues_json=$(IFS=,; echo "${issues[*]}")

cat <<EOF
{
  "schema_version": "5.4.0",
  "overall_score": $overall,
  "grade": "$grade",
  "scores": { $scores_json },
  "issues": [$issues_json],
  "total_modules": $total_mods,
  "complete_modules": $complete_mods,
  "total_flows": $total_flows,
  "flows_with_ids": $ided_flows
}
EOF
```

- [ ] **Step 4.2.2: Add quality gate to onboarding Phase 6**

In `skills/foundation/brownfield-onboarding/brownfield-onboarding.md`, replace Phase 6 (FINAL REVIEW) with:

```markdown
### Phase 6: QUALITY GATE + FINAL REVIEW

1. Run quality scorer:
   ```bash
   bash scripts/brownfield/quality-score.sh .em-brownfield > .em-brownfield/QUALITY-SCORE.json
   ```

2. Read score and grade:
   - **A (90+):** Production-ready. Mark INDEX.md status as "verified".
   - **B (75+):** Good. Mark INDEX.md status as "verified-with-gaps", list gaps.
   - **C (60+):** Draft. Mark INDEX.md status as "draft", require user review of gaps.
   - **D (<60):** Insufficient. BLOCK with required improvements.

3. Present score to user:
   ```
   Quality Score: 87/100 (Grade B)
   
   Dimensions:
   - Domain profile: 100/100 ✓
   - Module completeness: 100/100 ✓
   - Cross-references: 100/100 ✓
   - Flow IDs: 80/100 (3 flows missing IDs)
   - JSON sidecars: 60/100 (2 modules missing CODE-MAP.json)
   
   Issues:
   - 3 flows in modules/allocation/FLOWS.md missing FLOW-X-NNN IDs
   - modules/dashboard/CODE-MAP.json missing
   
   → APPROVE (proceed despite issues) / IMPROVE (fix issues now) / SKIP (cancel)
   ```

4. If APPROVE → lock INDEX.md Last Verified, complete.
5. If IMPROVE → return to relevant phase to fix.
6. If SKIP → exit with status=BLOCKED.

The score becomes the baseline for future brownfield-context-sync runs.
```

- [ ] **Step 4.2.3: Commit**

```bash
git add scripts/brownfield/quality-score.sh skills/foundation/brownfield-onboarding/brownfield-onboarding.md
git commit -m "feat(brownfield): quality gate for onboarding output

scripts/brownfield/quality-score.sh scores .em-brownfield/ across 5 dimensions
(domain profile, module completeness, cross-refs, flow IDs, sidecars). Onboarding
Phase 6 runs it and gates on grade A/B/C/D. Closes gap G12."
```

---

### Task 4.3: Privacy + PII guidance

**Files:**
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md`

- [ ] **Step 4.3.1: Add Privacy section**

Insert after Phase 3 (PER-MODULE DEEP EXTRACTION) header, before Phase 3a:

```markdown
### Phase 3-pre: PRIVACY + PII GUIDANCE

Before extracting entities and flows, apply privacy rules:

**Default policy:**
- `.em-brownfield/` artifacts ARE checked into git (knowledge graph is a team asset)
- `.em-investigations/` artifacts are gitignored (may contain user data captured in screenshots)

**PII redaction in artifacts:**
- DOMAIN.md entity examples: use `<email>`, `<phone>`, `<ssn>` placeholders, never real data
- INTEGRATIONS.md: store env var NAMES only (`STRIPE_API_KEY`), never values
- CODE-MAP.md test data: anonymize seed data (e.g., `john@example.com` → `<user-email>`)
- HEALTH-CHECK Investigation History: reference issue numbers, not user identifiers

**Sensitive entity flags:**
For each entity in DOMAIN.md, flag if it contains PII:
```markdown
### User
- **PII Fields:** email, phone, address, full_name
- **Compliance:** GDPR Article 17 (right to erasure) applies — see audit module
```

If the domain profile indicates compliance (HIPAA, GDPR, PCI), add an explicit
"Sensitive Data Handling" section to DOMAIN.md.

**Per-module gitignore:**
If any module contains sensitive flow data (e.g., real screenshots in evidence), add
to that module's directory:
```
modules/{module}/.gitignore
---
evidence/
sensitive-flows/
```
```

- [ ] **Step 4.3.2: Update DOMAIN.md template with PII section**

In `templates/brownfield/MODULE-DOMAIN.md`, add after the Entity section:

```markdown
**PII / Sensitive Fields:**
| Attribute | Classification | Compliance | Notes |
|-----------|---------------|------------|-------|
| email | PII | GDPR | Required for login, deletable on request |
| password | Sensitive | — | Stored as bcrypt hash only |

**Data Subject Rights (if applicable):**
- [ ] Erasure path documented (which flow handles "delete my data"?)
- [ ] Export path documented (which flow handles "export my data"?)
- [ ] Consent management linked
```

- [ ] **Step 4.3.3: Commit**

```bash
git add skills/foundation/brownfield-onboarding/brownfield-onboarding.md templates/brownfield/MODULE-DOMAIN.md
git commit -m "feat(brownfield): privacy + PII guidance

Onboarding Phase 3-pre documents default privacy policy (.em-brownfield/ tracked,
.em-investigations/ gitignored), PII redaction rules, sensitive entity flags.
DOMAIN.md template gains PII/Sensitive Fields table + Data Subject Rights
checklist for GDPR/HIPAA compliance. Closes gap G13."
```

---

### Task 4.4: Expand domain table + unknown-domain template

**Files:**
- Modify: `skills/foundation/brownfield-onboarding/brownfield-onboarding.md`

- [ ] **Step 4.4.1: Expand the domain table in Phase 0c**

Replace the existing table with:

```markdown
| Domain | Core Patterns to Trace | Critical Flow Indicators | Risk Areas |
|--------|----------------------|--------------------------|------------|
| **Fintech** | Double-entry bookkeeping, idempotency keys, audit trails, settlement cycles, reconciliation | Payment, withdrawal, transfer, refund flows | Race conditions in balance updates, missing audit logs, compliance gaps |
| **E-commerce** | Cart lifecycle, inventory reservation, order state machine, promotion stacking | Checkout, payment, fulfillment, return flows | Overselling, payment failures, abandoned cart leaks |
| **Healthcare** | Patient record access control, clinical workflow state, consent management | Patient intake, diagnosis, prescription, discharge flows | PHI exposure, consent violations, clinical data integrity |
| **SaaS** | Tenant isolation, subscription lifecycle, feature gating, usage metering | Signup, onboarding, billing, upgrade/downgrade flows | Cross-tenant data leaks, billing errors, feature flag conflicts |
| **Logistics** | Route optimization, real-time tracking, capacity planning, SLA management | Dispatch, tracking, delivery, exception handling flows | Delivery SLA violations, capacity overflow, tracking gaps |
| **Education** | Enrollment state machine, progress tracking, content versioning | Registration, course delivery, assessment, certification flows | Grade integrity, content access control, certification fraud |
| **Workforce / Resource Management** | Capacity allocation, time tracking, scheduling, skill matching | Project staffing, allocation, time reporting, capacity planning flows | Overallocation, scheduling conflicts, skill mismatch, data freshness |
| **CRM / Sales** | Lead lifecycle, opportunity stages, contact management, pipeline metrics | Lead capture, qualification, deal close, renewal flows | Pipeline drift, contact dedup, attribution errors |
| **Content / Media** | Asset lifecycle, publishing workflow, content delivery, rights management | Upload, review, publish, distribute, takedown flows | Rights violations, broken assets, CDN sync failures |
| **HR / People Ops** | Employee lifecycle, leave management, performance cycles, payroll | Onboarding, leave request, review cycle, offboarding flows | Privacy violations, payroll errors, compliance gaps |
| **Marketplace / B2B** | Merchant/buyer separation, multi-party transactions, escrow, dispute resolution | Listing, search, order, dispute, payout flows | Fraud, fund misallocation, dispute resolution accuracy |
| **DevTools / Platform** | Resource provisioning, API quotas, observability, multi-region | Account setup, resource create, scale, decommission flows | Resource leaks, quota exhaustion, cross-region inconsistency |
| **Unknown / Custom** | (see template below) | (research-driven) | (user-confirmed) |
```

- [ ] **Step 4.4.2: Add unknown-domain workflow**

After the table, add:

```markdown
**For Unknown / Custom domains:**

If the project doesn't fit any predefined category, follow this protocol:

1. **Initial classification:** Propose 2-3 candidate domains from the table. Show evidence
   (dependencies, models, terminology). Ask user to pick or describe their own.

2. **Domain research:** If domain is truly novel:
   - Look for industry-specific terminology in code/comments/README
   - Identify the "money moment" — what is the transaction or commitment that matters most?
   - Identify the "compliance moment" — what regulations or policies bind this business?

3. **User-driven framework population:**
   Ask the user:
   - "What are the top 3 critical business operations?" (becomes critical_business_operations)
   - "What's the worst thing that could happen if your system fails?" (becomes p0_criteria)
   - "What 5 terms would a new hire need to learn?" (becomes domain_terminology)
   - "What rules MUST always hold?" (becomes domain_invariants)

4. **Custom domain row:** Add the discovered patterns to the local DOMAIN-PROFILE.yaml
   and PROPOSE adding to this table for the codebase (via separate PR — improves the
   skill for everyone).
```

- [ ] **Step 4.4.3: Commit**

```bash
git add skills/foundation/brownfield-onboarding/brownfield-onboarding.md
git commit -m "feat(brownfield-onboarding): expand domain table + unknown-domain protocol

Domain table now covers 12 domains (added: Workforce/Resource Management,
CRM/Sales, Content/Media, HR/People Ops, Marketplace/B2B, DevTools/Platform).
Added explicit Unknown/Custom domain workflow with user-driven framework
population protocol. Closes gap G21."
```

---

### Task 4.5: brownfield-test-engineer fully leverages context

**Files:**
- Modify: `agents/brownfield-test-engineer.md`

- [ ] **Step 4.5.1: Replace Step 0 with explicit context leverage**

In `agents/brownfield-test-engineer.md`, find `### Step 0: LOAD BROWNFIELD CONTEXT` and replace with:

```markdown
### Step 0: LOAD + LEVERAGE BROWNFIELD CONTEXT

If `.em-brownfield/INDEX.json` exists, load context and USE IT EXPLICITLY:

#### 0a. Load all module artifacts for the spec's target module(s)
```bash
target_modules=$(echo "$spec_or_files" | jq -r '...')  # determined via INDEX
for module in $target_modules; do
  jq . .em-brownfield/modules/$module/FLOWS.json
  jq . .em-brownfield/modules/$module/DOMAIN.json 2>/dev/null
  jq . .em-brownfield/modules/$module/CODE-MAP.json
  cat .em-brownfield/modules/$module/INTEGRATIONS.md
done
```

#### 0b. Use FLOWS.json to drive AC→TC mapping (MANDATORY)
For EVERY `acceptance_criteria` in the loaded FLOWS.json, generate at least one TC:

| Source | Generated TC |
|---|---|
| AC-{MODULE}-{NNN} (positive) | At least 1 positive TC asserting the AC holds |
| AC-{MODULE}-{NNN} marked critical=high | Also generate negative TC (what breaks AC?) |
| Flow happy path step with criticality=high | At least 1 E2E TC covering that step |
| Flow error_paths entry | At least 1 negative/abuse TC for that condition |

Output: `coverage_map` array linking every AC ID to TC IDs.

#### 0c. Use DOMAIN.json for entity-driven test fixtures (MANDATORY)
For each entity in DOMAIN.json:
- Generate a fixture factory in `tests/fixtures/{entity}.factory.ts`
- Honor business_rules (invariants): factory MUST produce valid entities by default
- Generate `invalid{Entity}Factory()` variants per constraint violation (for negative TCs)

Example for ras-app Allocation entity:
```typescript
// tests/fixtures/allocation.factory.ts
export function validAllocation(): Allocation {
  return { employeeId: 'e1', projectId: 'p1', percentage: 50, ... };  // honors INV-001 (≤100%)
}
export function overallocatedAllocation(): Allocation {
  return { ...validAllocation(), percentage: 150 };  // violates INV-001 — for negative TC
}
```

#### 0d. Use INTEGRATIONS.md for negative TCs (MANDATORY)
For each integration:
- Read its `Failure Handling` section (Timeout, Retry, Fallback, Idempotency)
- Generate negative TCs:
  - **Timeout TC:** simulate slow external call, assert retry/fallback behavior
  - **Network error TC:** assert circuit breaker / fallback path
  - **Idempotency TC:** if integration claims idempotency, send duplicate request, assert single side effect

This ensures resilience claims in INTEGRATIONS.md are TESTED, not just documented.

#### 0e. Use DOMAIN-PROFILE.yaml for risk-tier auto-detection
Read `p0_criteria` and `domain_invariants` from DOMAIN-PROFILE.yaml. If the spec
touches anything matching p0_criteria → declare feature `risk_tier: P0` automatically
(unless user overrides). This drives the risk-calibrated ratio enforcement in Step 3.5.

If `.em-brownfield/` does not exist, proceed to Step 1 as normal (no leverage available).
```

- [ ] **Step 4.5.2: Update Completion Marker**

Append to the bottom checklist:

```markdown
- [ ] (if brownfield) Every AC-{MODULE}-{NNN} in loaded FLOWS.json has ≥1 TC
- [ ] (if brownfield) Entity factories generated from DOMAIN.json (valid + invalid variants)
- [ ] (if brownfield) Integration failure-mode TCs generated from INTEGRATIONS.md
- [ ] (if brownfield) Risk tier auto-detected from DOMAIN-PROFILE.yaml p0_criteria
```

- [ ] **Step 4.5.3: Commit**

```bash
git add agents/brownfield-test-engineer.md
git commit -m "feat(brownfield-test-engineer): explicit AC→TC, DOMAIN→fixture, INTEGRATIONS→negative TC

Step 0 now MANDATORILY uses loaded context:
- Every AC in FLOWS.json → ≥1 TC (with coverage_map output)
- Every entity in DOMAIN.json → factory (valid + invalid variants per invariant)
- Every integration in INTEGRATIONS.md → negative TCs (timeout/network/idempotency)
- DOMAIN-PROFILE.yaml p0_criteria → auto risk_tier detection
Closes gap G10."
```

---

### Phase 4 Verification

- [ ] **V4.1: Example brownfield validates**

```bash
bash scripts/brownfield/validate-refs.sh Engineer-team/examples/brownfield/ras-app/.em-brownfield && echo "PASS"
bash scripts/brownfield/quality-score.sh Engineer-team/examples/brownfield/ras-app/.em-brownfield | jq '.grade'
```

Expected: validate-refs passes, quality score is B or A.

- [ ] **V4.2: Final phase commit**

```bash
git add -u
git commit -m "feat(brownfield): Phase 4 complete — polish

Phase 4 closes gaps G10, G11, G12, G13, G21:
- Reference example .em-brownfield/ for ras-app
- Quality scorer + Phase 6 gate
- Privacy + PII guidance
- Expanded domain table (12 domains + Unknown/Custom protocol)
- brownfield-test-engineer explicit context leverage (AC→TC, DOMAIN→fixture, INTEGRATIONS→neg TC)"
```

---

# Final Plan-Level Verification

- [ ] **VF.1: Run full validation suite**

```bash
cd /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/Engineer-team
bash scripts/validate-hermes.sh --verbose
bash scripts/brownfield/validate-refs.sh examples/brownfield/ras-app/.em-brownfield
bash scripts/brownfield/quality-score.sh examples/brownfield/ras-app/.em-brownfield
```

Expected: All pass.

- [ ] **VF.2: Update CHANGELOG.md**

Append to CHANGELOG.md:

```markdown
## [5.4.0] - 2026-05-26
### Brownfield Intelligence Improvements

**Phase 1 — Verify Integration (closes G4, G5, G6, G7, G24, G25):**
- verifier agent loads `.em-brownfield/` context and checks AC-{MODULE}-{NNN}
- debugger agent loads brownfield context for investigation
- new-feature workflow Stage 0.5 + Stage 5.7 integrate brownfield
- bug-fix workflow Stage 0.5 auto-routes to brownfield-investigation when context exists
- brownfield-investigation Stage 5 actively writes context updates
- DOMAIN-PROFILE.yaml structured for programmatic enforcement
- EVIDENCE-MANIFEST.json schema for evidence packaging

**Phase 2 — Robustness (closes G1, G2, G14, G22, G23):**
- Symbol-based code references replace fragile line-anchored refs
- Concrete scan scripts: detect-stack, scan-nestjs, scan-react, scan-monorepo, symbol-resolver
- JSON sidecars for programmatic access (INDEX, FLOWS, CODE-MAP)
- Monorepo + cross-stack module support
- Flexible test discovery (co-located + root + per-app)

**Phase 3 — Active Sync (closes G3, G5, G8, G9):**
- Stable FLOW-{MODULE}-{NNN} IDs survive renames
- Backlinks builder + reference validator scripts
- New `brownfield-pr-impact` skill for pre-merge impact analysis
- flow-discovery bidirectional: proposes FLOWS.md updates
- Optional pre-push hook for impact awareness

**Phase 4 — Polish (closes G10, G11, G12, G13, G21):**
- Reference example `.em-brownfield/` for ras-app monorepo
- Quality scoring + Phase 6 gate in onboarding
- Privacy + PII guidance + GDPR-compliant DOMAIN.md
- Expanded domain table (12 domains + Unknown/Custom protocol)
- brownfield-test-engineer explicit context leverage (AC→TC, DOMAIN→fixture, INTEGRATIONS→neg TC)

**Total impact:** 19 gaps closed, 5 existing artifacts upgraded, 1 new skill, 7 new scripts, 4 new template files, 1 reference example.
```

- [ ] **VF.3: Final commit**

```bash
git add CHANGELOG.md
git commit -m "docs(changelog): brownfield intelligence improvements v5.4.0

Master plan complete: 4 phases, 19 gaps closed, full audit-driven upgrade
of brownfield-onboarding, brownfield-investigation, brownfield-context-sync,
brownfield-test-engineer, flow-discovery + integration into verifier, debugger,
new-feature, bug-fix."
```

---

## Self-Review Notes

**Coverage check:** All 19 confirmed gaps (G1-G14, G21-G25) are addressed in tasks above. Mapped:
- Phase 1: G4 (T1.1) + G24 (T1.4) + G25 (T1.3) + G5 (T1.5) + G6 (T1.6) + G7 (T1.7)
- Phase 2: G1 (T2.1) + G2 (T2.2-2.5) + G22 (T2.5) + G23 (T2.5) + G14 (T2.6)
- Phase 3: G8 (T3.1-3.3) + G9 (T3.4) + G3 (T3.5) + G5/G24 (T3.6 reinforces)
- Phase 4: G11 (T4.1) + G12 (T4.2) + G13 (T4.3) + G21 (T4.4) + G10 (T4.5)

**Type consistency:** Symbol identifiers used consistently as `Class.method` or `function`. Flow IDs use `FLOW-{MODULE}-{NNN}`. AC IDs use `AC-{MODULE}-{NNN}`. JSON sidecar names: `INDEX.json`, `FLOWS.json`, `CODE-MAP.json`, `DOMAIN-PROFILE.yaml`, `EVIDENCE.json`, `BACKLINKS.json`, `QUALITY-SCORE.json`.

**Phase independence:** Each phase ships independently — confirmed by ship criteria at top of each phase. After Phase 1, brownfield + verifier integration works without Phase 2 robustness improvements (they're optimizations, not prerequisites).

**Known limitations:**
- Phase 2 scan scripts use grep heuristics, not full AST analysis. Tree-sitter integration is a future enhancement.
- Symbol resolver doesn't track signature changes precisely — needs LSP for that. Falls back to "if signature line changed, suspect contract break".
- Quality scorer uses naive completeness checks. Could be richer (e.g., flow-step depth, AC measurability).
- No CI integration documented for `validate-refs.sh` and `brownfield-pr-impact` — that's a follow-up.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-26-brownfield-intelligence-improvements.md`. Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration. Best for 4 phases × ~6 tasks each = 24 task subagents.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

**Recommendation:** Subagent-driven for Phases 1 + 4 (mostly markdown edits, high parallelism possible). Inline for Phases 2 + 3 (script writing benefits from sustained context).

Which approach?

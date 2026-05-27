---
name: bug-fix
description: Systematic bug fixing workflow from investigation to resolution
version: "3.2.0"
category: "primary"
origin: "agent-skills"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
agents_used:
  - debugger
  - executor
  - verifier
  - test-engineer
  - test-verifier
skills_used:
  - systematic-debugging
  - test-driven-development
  - code-review
  - git-workflow
  - alignment-session
  - test-generation
  - e2e-testing
  - browser-testing
related_skills:
  - alignment-session
  - systematic-debugging
  - test-driven-development
estimated_time: "2-4 hours (simple) / 1-2 days (complex)"
---

# Bug Fix Workflow (Hermes ReAct Protocol)

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1,2)      (3)      (4)      (5)        (5)       (6)
   │          │        │        │           │         │
   ▼          ▼        ▼        ▼           ▼         ▼
 GATE 1    GATE 2   GATE 3   GATE 4      GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Gate |
|---|---|---|
| SETUP (Stage 0) | DEFINE | spec folder detected, branch naming rules checked, BUG doc created, on branch with latest main |
| ROUTING (Stage 0.5, optional) | DEFINE | routing decision recorded (brownfield-investigation OR standalone OR setup-first) |
| INVESTIGATE (Stage 1) | DEFINE | Bug reproducible, symptoms documented, evidence collected |
| ANALYZE (Stage 2) | DEFINE | Failure point identified, hypotheses formed |
| HYPOTHESIZE (Stage 3) | PLAN | Root cause confirmed, fix approach decided |
| FIX (Stage 4) | BUILD | Test fails before fix, passes after, regression test added |
| VERIFY (Stage 5) | VERIFY + REVIEW | Bug resolved, no regressions, test-verifier PASS |

---

## Stage 0: SETUP (Git & Spec Bootstrap)

> Sub-workflow: `workflows/_shared/stage-0-git-bootstrap.md`
>
> Parameters:
> - `{doc_type}`: bug
> - `{doc_prefix}`: BUG
> - `{slug_type}`: bug
> - `{default_branch_pattern}`: fix/{slug}
> - `{artifact_name}`: bug_document_skeleton
> - `{next_action}`: investigate

**Bug doc template** (`{doc_template_body}`):

```yaml
---
type: bug
status: in-progress
branch: {branch-name}
date: {today}
---
# Bug: {title}

## Report
- **Symptoms**: {symptoms}
- **Steps to Reproduce**: (to be filled in Stage 1: Investigate)
- **Expected**:
- **Actual**:

## Root Cause
(to be filled in Stage 3: Hypothesize)

## Fix Approach
(to be filled in Stage 3: Hypothesize)

## Branch
`{branch-name}`
```

---

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

---

## Stage 1: Investigate

<thought>
Observe: Bug report received. No reproduction steps, no evidence, no failure location.
Analyze: Must reproduce the bug, document symptoms, collect evidence (logs, screenshots, stack traces). Gate requires: bug reproducible + symptoms documented + evidence collected.
Plan: Invoke debugger agent in INVESTIGATE mode. Gather symptoms, attempt reproduction, check recent changes.
</thought>

**Brownfield hint (optional):** If `.em-brownfield/` exists but user opted for standalone
bug-fix, the debugger agent will still load module context via its Phase 0 (see
agents/debugger.md). No additional config needed here.

<action>
type: invoke_agent
target: debugger
params:
  mode: investigate
  input: bug_report
  tasks:
    - gather_symptoms
    - reproduce_bug
    - collect_evidence
    - check_recent_changes
    - identify_affected_components
    - update_bug_doc: fill in "Steps to Reproduce" section of {spec_folder}/BUG-{slug}.md created in Stage 0
</action>

<observation>
result: Symptoms documented, reproduction steps confirmed, evidence collected
state_change: Bug is reproducible with known steps
gate_status: PASS | FAIL
</observation>

**Gate 1a — Investigation Complete:**
- [ ] Bug is reproducible
- [ ] Symptoms documented
- [ ] Evidence collected

PASS → Stage 2 | FAIL → retry investigation (max 3)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  stage_completed: investigate
  artifacts:
    - symptoms_document
    - reproduction_steps
    - evidence_collection
  next_action: "analyze"
```

---

## Stage 2: Analyze

<thought>
Observe: Bug is reproducible. Symptoms and evidence collected. No root cause yet.
Analyze: Narrow down failure location. Examine code flow and data flow. Form hypotheses. Gate requires: failure point identified + hypotheses formed.
Plan: Invoke debugger agent in ANALYZE mode. Map code flow, review error handling, identify patterns.
</thought>

<action>
type: invoke_agent
target: debugger
params:
  mode: analyze
  input: investigation_results
  tasks:
    - narrow_down_location
    - examine_code_flow
    - check_data_flow
    - review_error_handling
    - identify_patterns
</action>

<observation>
result: Failure location identified, code flow mapped, potential causes listed
state_change: Hypotheses formed from evidence
gate_status: PASS | FAIL
</observation>

**Gate 1b — Analysis Complete:**
- [ ] Failure point identified
- [ ] Code flow examined
- [ ] Hypotheses formed

PASS → Stage 3 | FAIL → return to Stage 1

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  stage_completed: analyze
  artifacts:
    - failure_location
    - code_flow_analysis
    - hypothesis_list
  next_action: "hypothesize"
```

---

## Stage 3: Hypothesize

<thought>
Observe: Failure location identified. Multiple hypotheses formed. No confirmed root cause.
Analyze: Test each hypothesis systematically. Eliminate false hypotheses. Confirm root cause. Gate requires: root cause found + hypothesis confirmed + fix approach decided.
Plan: Invoke debugger agent in HYPOTHESIZE mode. Create targeted tests per hypothesis, confirm or eliminate each.
</thought>

<action>
type: invoke_agent
target: debugger
params:
  mode: hypothesize
  input: analysis_results
  tasks:
    - form_hypotheses
    - create_hypothesis_tests
    - test_each_hypothesis
    - eliminate_false_hypotheses
    - confirm_root_cause
    - define_fix_strategy
    - update_bug_doc: fill in "Root Cause" and "Fix Approach" sections of {spec_folder}/BUG-{slug}.md
</action>

<observation>
result: Root cause identified and confirmed, fix strategy defined
state_change: Root cause known, fix approach decided
gate_status: PASS | FAIL
</observation>

**Gate 2 — Plan Complete:**
- [ ] Root cause found
- [ ] Hypothesis tested and confirmed
- [ ] Fix approach decided

PASS → Stage 4 | FAIL → return to Stage 2

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PLAN
  stage_completed: hypothesize
  artifacts:
    - root_cause_analysis
    - confirmed_hypothesis
    - fix_strategy
  next_action: "fix"
```

---

## Stage 4: Fix

<thought>
Observe: Root cause confirmed. Fix strategy defined. No implementation yet.
Analyze: Write failing test first (TDD). Implement fix. Verify test passes. Add regression test. Atomic commit. Gate requires: test fails before fix + passes after + regression test added + all tests pass.
Plan: Invoke executor agent. Follow TDD cycle: RED (failing test) → GREEN (implement fix) → REFACTOR (clean up).
</thought>

<action>
type: invoke_agent
target: executor
params:
  mode: fix
  input: root_cause_analysis
  tasks:
    - write_failing_test
    - implement_fix
    - verify_test_passes
    - add_regression_test
    - run_all_tests
    - atomic_commit
</action>

<observation>
result: Bug fixed, tests passing, regression test added, commit made
state_change: Fix implemented with test coverage
gate_status: PASS | FAIL
</observation>

**Gate 3 — Build Complete:**
- [ ] Test fails before fix
- [ ] Test passes after fix
- [ ] Regression test added
- [ ] All tests still pass

PASS → Stage 5 | FAIL → retry fix (max 3)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BUILD
  stage_completed: fix
  artifacts:
    - bug_fix_commit
    - failing_test
    - regression_test
  next_action: "verify"
```

---

## Stage 5: Verify

<thought>
Observe: Fix implemented. Unit tests pass. No verification of side effects, no E2E evidence, no test-verifier report.
Analyze: Run code-review diff scan FIRST to catch issues before the expensive test suite runs. Then verify fix resolves original issue, generate regression tests, run E2E. Gate requires: diff review PASS + bug resolved + no regressions + E2E evidence + test-verifier PASS.
Plan: Step 5.1 code-review → Step 5.2 verifier → Step 5.3 test-generation → Step 5.4 E2E → Step 5.5 test-verifier. Review fixes are validated by the test suite, not bypassed.
</thought>

**Step 5.1 — Code-Review Diff Scan (MANDATORY)**

Review all changed files BEFORE running the test suite. Any findings fixed here will be validated by steps 5.2–5.5.

<action>
type: invoke_agent
target: code-reviewer
params:
  mode: standard
  focus: bug_fix_review
  inputs: [changed_files_list, root_cause_analysis, fix_strategy]
  outputs: [diff_review_report]
</action>

Focus areas for bug fix review:
- Fix does not introduce new bugs
- Root cause fixed (not just symptom workaround)
- Regression test quality

Gate: No CRITICAL or unaddressed HIGH findings before proceeding to Step 5.2.
If FAIL → return to Stage 4 (FIX) with specific findings. Review fixes will then be validated by the test suite.

---

**Step 5.2 — Verify Fix & Check Side Effects (verifier agent)**

<action>
type: invoke_agent
target: verifier
params:
  mode: verify
  input: fix_results
  tasks:
    - verify_fix_resolves_issue
    - check_side_effects
</action>

---

**Step 5.3 — Generate Regression Test Cases (test-generation skill)**

<action>
type: invoke_skill
target: test-generation
params:
  scope: fixed_area_and_edge_cases
  input: root_cause_analysis
</action>

---

**Step 5.4 — Run E2E Tests & Collect Evidence (e2e-testing + browser-testing skills)**

<action>
type: invoke_skill
target: e2e-testing
params:
  scope: bug_reproduction_steps
  tool: playwright
</action>

<action>
type: invoke_skill
target: browser-testing
params:
  scope: bug_area_ui
  evidence: before_after_screenshots
</action>

---

**Step 5.5 — Double-Check with Test Verifier (test-verifier agent)**

<action>
type: invoke_agent
target: test-verifier
params:
  mode: double_check
  max_retries: 3
  input: all_test_results
</action>

---

<observation>
result: Diff reviewed (no CRITICAL/HIGH findings), fix verified, regression tests generated, E2E evidence collected, test-verifier report issued
state_change: Full verification complete
gate_status: PASS | FAIL
</observation>

**Gate 4+5 — Verification and Review Complete:**
- [ ] Original bug resolved
- [ ] Regression test cases generated for fixed area
- [ ] No regressions in existing tests
- [ ] Edge cases covered
- [ ] E2E tests confirm fix visible in browser
- [ ] Browser evidence collected (before/after screenshots)
- [ ] **test-verifier PASS** (or failure report reviewed by user before proceeding)
- [ ] Code-review diff scan PASS — verify fix is correct approach (not workaround) — Step 5.1

PASS → Stage 6 | FAIL → return to Stage 4

**State Snapshot:**
```yaml
workflow_state:
  current_phase: VERIFY
  stage_completed: verify
  artifacts:
    - tc_registry
    - verification_report
    - e2e_evidence
    - test_verifier_report
  next_action: "ship"
```

<!-- GATE:VERIFY:REQUIRED artifacts=[tc-registry,e2e-evidence,test-verifier-report] -->

---

## Stage 6: Ship

<thought>
Observe: Fix verified. All tests pass. test-verifier PASS. Evidence collected.
Analyze: Create PR, get code review, merge, deploy, monitor.
Plan: Invoke executor for PR creation and code-reviewer for review. Deploy and confirm resolution in production.
</thought>

<action>
type: invoke_agent
target: executor
params:
  mode: ship
  tasks:
    - create_pull_request
    - request_code_review
    - merge_to_main
    - deploy
    - monitor
</action>

<observation>
result: PR merged, deployed, monitoring healthy
state_change: Bug fix shipped to production
gate_status: PASS | FAIL
</observation>

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SHIP
  stage_completed: ship
  artifacts:
    - pull_request
    - code_review
    - deployment_log
  next_action: null
  status: COMPLETE
```

### Stage 6.1: Rollback Readiness

Before marking fix shipped:
- [ ] Rollback procedure documented (db migration reversal / deployment rollback command)
- [ ] Monitoring alerts verified on fixed code paths
- [ ] Rollback tested in staging (or documented manual steps)
- [ ] On-call team notified if fix affects critical paths

---

## Feature Workspace

When `EM_TEAM_ARTIFACT_EXPORT=true`:

Create workspace at Stage 1 (Investigate) start:
```
artifactStore.createWorkspace('bug-fix', bugTitle)
```

Living documents (updated in place across iterations):
- `SPEC.md` → bug analysis, root cause, fix description
- `TC-REGISTRY.md` → regression test cases

Timestamped logs (appended each run):
- Test executions → `artifactStore.workspaceExport('test-executions', ...)`
- Code reviews → `artifactStore.workspaceExport('reviews', ...)`
- Evidence → `artifactStore.workspaceExport('evidence', ...)`

Result: `.em-artifacts/bug-fix/{bug-slug}/` — follow-up prompts update in place.

**Legacy export:** Bug analysis → `specs/bug-fix/` | Test report → `test-reports/bug-fix/` | Review → `reviews/bug-fix/`

---

## Handoff Contracts

### Investigate → Analyze

```yaml
handoff:
  from: debugger
  to: debugger
  provides:
    - symptoms
    - reproduction_steps
  expects:
    - failure_location
    - code_flow_analysis
  on_failure:
    trigger: "Bug cannot be reproduced after 3 retries"
    action: "Report NEEDS_CONTEXT to user with non-reproducible-bug triage"
    retry_budget: 3
    escalation: "Do not proceed to Stage 2 without confirmed reproduction"
```

### Analyze → Hypothesize

```yaml
handoff:
  from: debugger
  to: debugger
  provides:
    - failure_location
    - potential_causes
  expects:
    - root_cause
    - confirmed_hypothesis
  on_failure:
    trigger: "No hypothesis can be confirmed from evidence"
    action: "Return to Stage 1 (Investigate) to collect more evidence"
    retry_budget: 2
    escalation: "Notify user if failure location remains unknown after retry"
```

### Hypothesize → Fix

```yaml
handoff:
  from: debugger
  to: executor
  provides:
    - root_cause_analysis
    - fix_strategy
  expects:
    - bug_fix
    - regression_test
  on_failure:
    trigger: "Fix strategy cannot be implemented without breaking other tests"
    action: "Return to Hypothesize stage with specific conflict described"
    retry_budget: 2
    escalation: "Notify user if root cause fix is architecturally constrained"
```

### Fix → Verify

```yaml
handoff:
  from: executor
  to: verifier
  provides:
    - bug_fix
    - test_results
  expects:
    - verification_report
    - side_effects_check
  on_failure:
    trigger: "test-verifier FAIL or code-review diff scan FAIL"
    action: "Return to Stage 4 (Fix) with specific failure report"
    retry_budget: 2
    escalation: "Notify user if 2 retries still FAIL"
```

---

## Error Handling

| Error Type | Trigger | Recovery |
|---|---|---|
| `SPEC_CONFLICT` | Acceptance criteria contradict each other or the fix approach | Return to Stage 3. Flag conflict explicitly. Do not proceed until user resolves. |
| `BUILD_DEADLOCK` | Same fix fails 3× with different error messages (thrashing) | STOP. Invoke `systematic-debugging` skill — restart root cause analysis. Debugging attempts do not consume `max_retries`. |
| `TEST_ENV_FAILURE` | Test runner / Playwright fails with infrastructure error (not test logic) | Infrastructure failures do NOT consume `max_retries`. Fix environment, retry stage fresh. |
| `CONTEXT_OVERFLOW` | Claude signals loss of earlier stage outputs mid-workflow | Run context pruning immediately. Re-read bug document and gate status. Resume from last completed gate — do not restart from Stage 0. |
| `IRREPRODUCIBLE_BUG` | Stage 1 fails all 3 retries with no confirmed reproduction steps | Report `NEEDS_CONTEXT` to user. Provide non-reproducible-bug triage from `systematic-debugging` skill. Do not proceed to Stage 2. |

---

## Context Pruning

After each stage completes, prune context:
- Drop raw logs and stack traces (retain summary only)
- Drop eliminated hypotheses (retain confirmed root cause only)
- Drop intermediate test output (retain pass/fail summary only)
- Retain: root cause, fix description, gate status, artifacts list

---

## Quality Gates Summary

```yaml
quality_gates:
  investigate:
    - bug_reproducible
    - symptoms_documented
    - evidence_collected

  analyze:
    - failure_identified
    - code_examined
    - hypotheses_formed

  hypothesize:
    - root_cause_found
    - hypothesis_confirmed
    - fix_strategy_defined

  fix:
    - test_fails_before_fix
    - test_passes_after_fix
    - regression_test_added
    - all_tests_pass

  verify:
    - bug_resolved
    - no_regressions
    - edge_cases_covered
    - e2e_evidence_collected
    - test_verifier_pass
```

## Timeline Estimate

```yaml
timeline:
  investigate: "30 min - 2 hours"
  analyze: "30 min - 2 hours"
  hypothesize: "1-4 hours"
  fix: "1-4 hours"
  verify: "30 min - 2 hours"

  total_simple: "2-4 hours"
  total_complex: "1-2 days"
```

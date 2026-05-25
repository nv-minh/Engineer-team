---
name: bug-fix
description: Systematic bug fixing workflow from investigation to resolution
version: "3.1.0"
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

## Stage 1: Investigate

<thought>
Observe: Bug report received. No reproduction steps, no evidence, no failure location.
Analyze: Must reproduce the bug, document symptoms, collect evidence (logs, screenshots, stack traces). Gate requires: bug reproducible + symptoms documented + evidence collected.
Plan: Invoke debugger agent in INVESTIGATE mode. Gather symptoms, attempt reproduction, check recent changes.
</thought>

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
Analyze: Verify fix resolves original issue. Generate regression test cases. Run E2E tests. Collect browser evidence. Double-check with test-verifier. Gate requires: bug resolved + no regressions + E2E evidence + test-verifier PASS.
Plan: Invoke verifier + test-engineer + test-verifier in sequence. Use test-generation, e2e-testing, browser-testing skills.
</thought>

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

<action>
type: invoke_skill
target: test-generation
params:
  scope: fixed_area_and_edge_cases
  input: root_cause_analysis
</action>

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

<action>
type: invoke_agent
target: test-verifier
params:
  mode: double_check
  max_retries: 3
  input: all_test_results
</action>

<observation>
result: Fix verified, regression tests generated, E2E evidence collected, test-verifier report issued
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

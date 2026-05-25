---
name: refactoring
description: Code refactoring workflow for improving quality and maintainability
version: "2.2.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - code-reviewer
  - planner
  - executor
  - verifier
  - test-engineer
  - test-verifier
skills_used:
  - code-review
  - code-simplification
  - test-driven-development
  - writing-plans
  - git-workflow
  - architecture-improvement
  - test-generation
  - e2e-testing
  - browser-testing
related_skills:
  - code-simplification
  - architecture-improvement
estimated_time: "4-8 hours (simple) / 1-3 days (complex)"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Refactoring Workflow

```
ANALYZE → PLAN → REFACTOR → VERIFY → UPDATE
   1        2         3         4         5
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase |
|---|---|
| SETUP (Stage 0) | DEFINE |
| ANALYZE (Stage 1) | DEFINE |
| PLAN (Stage 2) | PLAN |
| REFACTOR (Stage 3) | BUILD |
| VERIFY (Stage 4) | VERIFY |
| UPDATE (Stage 5) | REVIEW + SHIP |

---

### Stage 0: SETUP (Git & Spec Bootstrap)

> Sub-workflow: `workflows/_shared/stage-0-git-bootstrap.md`
>
> Parameters:
> - `{doc_type}`: refactoring
> - `{doc_prefix}`: REFACTOR
> - `{slug_type}`: refactor
> - `{default_branch_pattern}`: refactor/{slug}
> - `{artifact_name}`: refactor_document_skeleton
> - `{next_action}`: analyze

**Refactor doc template** (`{doc_template_body}`):

```yaml
---
type: refactoring
status: in-progress
branch: {branch-name}
date: {today}
---
# Refactor: {title}

## Motivation
- **Why**: {reason}
- **Code Smells**: (to be filled in Stage 1: Analyze)

## Scope
- **Files affected**: (to be filled in Stage 1: Analyze)

## Goals
- [ ] Reduce cyclomatic complexity
- [ ] Improve maintainability
- [ ] No behavior change

## Branch
`{branch-name}`
```

---

### Stage 1: ANALYZE

<thought>
Observe: Codebase has quality issues — complexity, duplication, or maintainability problems.
Analyze: Must identify code smells, collect metrics (cyclomatic complexity, duplication %), set priorities. Gate requires smells identified, metrics collected, priorities set.
Plan: Invoke code-reviewer agent to analyze current state.
</thought>

<action>
type: invoke_agent
target: code-reviewer
params:
  task: analyze_code_quality
  outputs: [code_smells, complexity_metrics, priority_list]
  update_refactor_doc: fill in "Code Smells" and "Files affected" sections of {spec_folder}/REFACTOR-{slug}.md created in Stage 0
</action>

<observation>
result: Code smells identified, baseline metrics collected, priorities ranked
gate_status: PASS | FAIL
</observation>

**Gate 1: Definition Complete**
- [ ] Code smells identified
- [ ] Metrics collected
- [ ] Priorities set

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ANALYZE
  completed: []
  next_action: "PLAN if gate passes"
```

---

### Stage 2: PLAN

<thought>
Observe: Code smells identified, metrics collected, priorities ranked.
Analyze: Must define refactoring tasks, plan tests to ensure functionality unchanged, confirm no behavior changes planned. Gate requires tasks defined, tests planned, no functionality changes.
Plan: Invoke planner agent with writing-plans skill.
</thought>

<action>
type: invoke_agent
target: planner
params:
  task: create_refactoring_plan
  input: [code_smells, complexity_metrics]
  outputs: [refactoring_plan, task_breakdown, test_plan]
</action>

<observation>
result: Refactoring plan with tasks, test plan ensuring no functionality changes
gate_status: PASS | FAIL
</observation>

**Gate 2: Plan Complete**
- [ ] Tasks defined
- [ ] Tests planned
- [ ] No functionality changes planned

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PLAN
  completed: [ANALYZE]
  next_action: "REFACTOR if gate passes"
```

---

### Stage 3: REFACTOR

<thought>
Observe: Refactoring plan ready with tasks ordered, test plan defined.
Analyze: Must execute refactoring with tests passing throughout. Same inputs must produce same outputs. Complexity metrics must improve.
Plan: Invoke executor agent with TDD and code-simplification skills.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: execute_refactoring
  methodology: TDD
  constraint: functionality_unchanged
  outputs: [refactored_code, tests_passing]
</action>

<observation>
result: Code refactored, tests passing, functionality preserved
gate_status: PASS | FAIL
</observation>

**Gate 3: Build Complete**
- [ ] Tests pass
- [ ] Functionality unchanged
- [ ] Quality improved
- [ ] Complexity reduced

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REFACTOR
  completed: [ANALYZE, PLAN]
  next_action: "VERIFY if gate passes"
```

---

### Stage 4: VERIFY

<thought>
Observe: Refactoring complete, tests passing during refactoring.
Analyze: Must confirm functionality preserved end-to-end. Generate test cases, run full suite, execute E2E, collect browser evidence (before/after), double-check with test-verifier. Coverage must not decrease. Complexity metrics must improve.
Plan: Invoke verifier + test-engineer + test-verifier agents.
</thought>

<action>
type: invoke_agent
target: verifier
params:
  task: verify_refactoring
  skills: [test-generation, e2e-testing, browser-testing]
  agents: [test-engineer, test-verifier]
  outputs: [tc_registry, coverage_comparison, e2e_evidence, test_verifier_report, complexity_comparison]
</action>

<observation>
result: Functionality preserved, coverage not reduced, complexity improved, test-verifier PASS
gate_status: PASS | FAIL
</observation>

**Gate 4: Verification Complete**
- [ ] Coverage not reduced vs pre-refactor baseline
- [ ] All existing tests pass (no regressions)
- [ ] E2E tests pass — no user-facing changes introduced
- [ ] Browser evidence confirms UI unchanged (before/after match)
- [ ] **test-verifier PASS** (or failure report reviewed by user before proceeding)
- [ ] Complexity metrics improved (cyclomatic complexity reduced)
- [ ] Functionality preserved (same behavior, different structure)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: VERIFY
  completed: [ANALYZE, PLAN, REFACTOR]
  next_action: "UPDATE if gate passes"
```

<!-- GATE:VERIFY:REQUIRED artifacts=[tc-registry,e2e-evidence,test-verifier-report] -->

---

### Stage 5: UPDATE

<thought>
Observe: Verification complete, functionality preserved, quality improved.
Analyze: Must update documentation, commit changes, track debt reduction.
Plan: Invoke executor agent with git-workflow skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: finalize_refactoring
  outputs: [documentation_updated, changes_committed, debt_tracked]
</action>

<observation>
result: Documentation updated, changes committed, debt reduction tracked
gate_status: PASS | FAIL
</observation>

**Gate 5: Review Complete**
- [ ] Documentation updated
- [ ] Tests updated
- [ ] Changes committed
- [ ] Debt tracked

**State Snapshot:**
```yaml
workflow_state:
  current_phase: UPDATE
  completed: [ANALYZE, PLAN, REFACTOR, VERIFY]
  next_action: "DONE"
```

---

## Feature Workspace

When `EM_TEAM_ARTIFACT_EXPORT=true`:

Create workspace at Stage 1 (Analyze) start:
```
artifactStore.createWorkspace('refactoring', refactorTitle)
```

Living documents: `SPEC.md` (refactor rationale), `TC-REGISTRY.md` (coverage tests)
Timestamped logs: test-executions, reviews, evidence

Result: `.em-artifacts/refactoring/{refactor-slug}/` — follow-up prompts update in place.

**Legacy export:** Rationale → `specs/refactoring/` | Test report → `test-reports/refactoring/` | Review → `reviews/refactoring/`

---

## Handoff Contracts

### Analyze → Plan
```yaml
handoff:
  from: code-reviewer
  to: planner
  provides: [code_smells, complexity_metrics]
  expects: [refactoring_plan, task_breakdown]
```

### Plan → Refactor
```yaml
handoff:
  from: planner
  to: executor
  provides: [refactoring_plan, tasks]
  expects: [refactored_code, tests_passing]
```

### Refactor → Verify
```yaml
handoff:
  from: executor
  to: verifier
  provides: [refactored_code, test_results]
  expects: [verification_report, metrics_comparison]
```

## Error Handling

| Error Type | Trigger | Recovery |
|---|---|---|
| `REGRESSION_INTRODUCED` | Tests that passed before refactoring now fail | STOP. Revert last commit. Re-analyze scope — refactoring may have crossed a boundary. Do not retry without narrowing scope. |
| `BUILD_DEADLOCK` | Same refactoring task fails 3× with different errors (thrashing) | STOP. Invoke `systematic-debugging` skill. Debugging attempts do not consume `max_retries`. |
| `TEST_ENV_FAILURE` | Test runner / build tool fails with infrastructure error (not test logic) | Infrastructure failures do NOT consume `max_retries`. Fix environment, retry stage fresh. |
| `CONTEXT_OVERFLOW` | Claude signals loss of earlier stage outputs mid-workflow | Run context pruning immediately. Re-read refactor document and gate status. Resume from last completed gate. |
| `BEHAVIOR_CHANGE_DETECTED` | Refactoring unintentionally changes observable behavior | Return to Stage 1 (Analyze). Compare before/after behavior. Refactoring must be behavior-preserving — fix or split into separate tasks. |

---

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

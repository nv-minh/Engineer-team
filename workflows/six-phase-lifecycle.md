---
name: six-phase-lifecycle
description: "Master lifecycle workflow that all EM-Skill workflows inherit. Defines the 6 phases (DEFINE→PLAN→BUILD→VERIFY→REVIEW→SHIP) with verification gates."
version: "2.2.0"
category: "primary"
origin: "agent-skills"
agents_used: [planner, executor, code-reviewer, verifier]
skills_used: [spec-driven-development, writing-plans, test-driven-development, code-review, git-workflow]
related_skills:
  - spec-driven-development
  - test-driven-development
estimated_time: "Variable - depends on scope"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Six-Phase Lifecycle Workflow

## The Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

Each phase has: **Goal**, **Required output**, **Verification gate**, **Rollback**.

---

### Phase 1: DEFINE

<thought>
Observe: No requirements, scope, or success criteria exist yet.
Analyze: Must gather requirements, clarify scope, surface assumptions, identify risks. Gate requires documented requirements, defined scope boundaries, measurable success criteria, validated assumptions, and stakeholder alignment.
Plan: Invoke planner agent to gather and structure requirements.
</thought>

<action>
type: invoke_agent
target: planner
params:
  task: gather_requirements
  outputs: [requirements_doc, success_criteria, assumptions_list, risk_assessment]
</action>

<observation>
result: Requirements documented, scope boundaries defined, success criteria measurable
gate_status: PASS | FAIL
</observation>

**Gate 1: Definition Complete**
- [ ] Requirements are documented and specific
- [ ] Scope boundaries are defined (in/out)
- [ ] Success criteria are measurable and testable
- [ ] Assumptions are listed and validated
- [ ] Stakeholders are aligned

**PASS** → Proceed to PLAN | **FAIL** → Return to DEFINE, resolve gaps

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  completed: []
  next_action: "PLAN if gate passes"
```

---

### Phase 2: PLAN

<thought>
Observe: Requirements documented, scope defined, success criteria set.
Analyze: Must design architecture, break down into tasks, identify dependencies, assign agents, define verification criteria per task. Gate requires all requirements mapped to tasks, dependencies ordered, no TBDs, specific file paths.
Plan: Invoke planner agent with writing-plans skill.
</thought>

<action>
type: invoke_agent
target: planner
params:
  task: create_implementation_plan
  input: requirements_doc
  outputs: [PLAN.md, task_breakdown, file_structure_map, verification_criteria]
</action>

<observation>
result: Implementation plan with task breakdown, dependencies, and verification criteria
gate_status: PASS | FAIL
</observation>

**Gate 2: Plan Complete**
- [ ] All requirements have corresponding tasks
- [ ] Dependencies are identified and ordered
- [ ] No placeholder tasks (no TBD/TODO)
- [ ] Each task has verification criteria
- [ ] File paths are specific

**PASS** → Proceed to BUILD | **FAIL** → Return to PLAN, fill gaps

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PLAN
  completed: [DEFINE]
  next_action: "BUILD if gate passes"
```

---

### Phase 3: BUILD

<thought>
Observe: Plan complete with ordered tasks, dependencies mapped, verification criteria set.
Analyze: Must implement tasks in dependency order following TDD, make atomic commits, self-review code. Gate requires all tasks implemented, tests written, all tests passing, conventions followed, no TODOs, atomic commits.
Plan: Invoke executor agent with test-driven-development skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: implement_plan
  methodology: TDD
  commit_style: atomic
  outputs: [working_code, tests, atomic_commits]
</action>

<observation>
result: All tasks implemented with tests, atomic commits made
gate_status: PASS | FAIL
</observation>

**Gate 3: Build Complete**
- [ ] All tasks implemented
- [ ] Tests written for all new code
- [ ] All tests passing
- [ ] Code follows project conventions
- [ ] No TODO/FIXME remaining
- [ ] Atomic commits made

**PASS** → Proceed to VERIFY | **FAIL** → Return to BUILD, fix issues

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BUILD
  completed: [DEFINE, PLAN]
  next_action: "VERIFY if gate passes"
```

---

### Phase 4: VERIFY

> **⛔ NON-SKIPPABLE PHASE.** All steps below are MANDATORY. Do NOT proceed to REVIEW without completing ALL steps and producing ALL required artifacts.

<thought>
Observe: Code implemented with tests passing, atomic commits made.
Analyze: Must validate implementation against spec. Generate test cases, run full suite (unit/integration/E2E), execute Playwright E2E with video evidence recording, collect browser evidence (screenshots + video + traces), double-check with test-verifier. Gate requires all acceptance criteria met, TC registry generated, all tests passing, E2E verified with evidence, test-verifier PASS, no regressions.
Plan: Execute 6 mandatory steps in sequence: (0) code-review diff scan, (1) verify spec coverage, (2) generate TC registry, (3) ensure Playwright setup with `video: 'retain-on-failure'`, (4) run E2E tests and collect evidence, (5) double-check with test-verifier. Code-review runs FIRST so any fixes are validated by the test suite.
</thought>

**Mandatory Steps:**

0. **Code-review diff scan** — Invoke `code-reviewer` agent (mode: standard, focus: diff_review). Gate: no CRITICAL/HIGH findings before proceeding. If FAIL → return to BUILD.
1. **Verify spec coverage** — Invoke `verifier` agent. Map every spec requirement to implementation. Coverage must be 100%.
2. **Generate TC registry** — Invoke `test-generation` skill. Produce `TC-REGISTRY.md` with TC-IDs for all acceptance criteria.
3. **Ensure Playwright setup with dual-mode evidence switch** — Verify `playwright.config.ts` exists with the `EVIDENCE_MODE` switch (CI default: `video: 'retain-on-failure'`, `trace: 'on-first-retry'`, `screenshot: 'only-on-failure'`; Evidence mode override when `EVIDENCE_MODE=on`: `video/trace/screenshot: 'on'`). If missing or stale, invoke `playwright-setup` agent (v2.1.0+).
4. **Run E2E tests & collect evidence (VERIFY phase — evidence mode ON)** — Invoke `e2e-testing` + `browser-testing` skills. Execute `EVIDENCE_MODE=on npx playwright test --reporter=html,list` (or `pnpm test:e2e:evidence`). Evidence artifacts must be present in `test-results/` (videos, screenshots, traces) for EVERY TC, not just failures.
5. **Double-check with test-verifier** — Invoke `test-verifier` agent. Re-run failed tests (max 3 retries). Produce verdict: PASS with confidence score or FAIL with per-TC details + evidence paths.

<action>
type: invoke_agent
target: code-reviewer
params:
  mode: standard
  focus: diff_review
  inputs: [changed_files_list, spec_requirements]
  outputs: [diff_review_report]
</action>

<action>
type: invoke_agent
target: verifier
params:
  task: full_verification
  skills: [test-generation, e2e-testing, browser-testing]
  agents: [test-engineer, test-verifier]
  outputs: [tc_registry, verification_report, coverage_report, e2e_evidence, test_verifier_report]
  playwright_config:
    video: 'retain-on-failure'
    trace: 'retain-on-failure'
    screenshot: 'only-on-failure'
</action>

<observation>
result: All acceptance criteria met, E2E evidence collected, test-verifier PASS with confidence score
gate_status: PASS | FAIL
</observation>

**Gate 4: Verification Complete**
- [ ] Code-review diff scan PASS (no CRITICAL, no unaddressed HIGH)
- [ ] All acceptance criteria met
- [ ] Test case registry generated (spec requirements → TC-IDs)
- [ ] All tests passing (unit, integration, e2e)
- [ ] Playwright configured with `video: 'retain-on-failure'`
- [ ] E2E test suite executed — critical user flows verified
- [ ] Browser test evidence collected (`test-results/videos/`, `test-results/screenshots/`, `test-results/traces/`)
- [ ] Playwright HTML report generated
- [ ] **test-verifier PASS** (or failure report reviewed and signed off by user)
- [ ] TC-code coverage = 100% per layer: every TC-ID in TC-REGISTRY has a `test()` block (unautomated → `test.todo()`)
- [ ] Edge cases handled
- [ ] Performance benchmarks met
- [ ] No regressions in existing tests

⛔ **DO NOT proceed to REVIEW if ANY item above is unchecked.**

**PASS** → Proceed to REVIEW | **FAIL** → Return to BUILD, fix failures (use test-verifier failure report as input)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: VERIFY
  completed: [DEFINE, PLAN, BUILD]
  artifacts: [tc_registry, verification_report, e2e_evidence, playwright_report, test_verifier_report]
  next_action: "REVIEW if gate passes"
```

---

### Phase 5: REVIEW

<thought>
Observe: Verification complete, all tests passing, acceptance criteria met.
Analyze: Must ensure code quality through structured review. Code review (5-axis or 9-axis), architecture review, security review, performance review as applicable. Gate requires no CRITICAL findings, no unaddressed HIGH findings.
Plan: Invoke code-reviewer agent with code-review skill.
</thought>

<action>
type: invoke_agent
target: code-reviewer
params:
  task: structured_code_review
  mode: standard_or_deep
  outputs: [code_review_report, security_review_report, findings_list]
</action>

<observation>
result: Code review passed, no CRITICAL findings
gate_status: PASS | FAIL
</observation>

**Gate 5: Review Complete**
- [ ] No CRITICAL findings
- [ ] No HIGH findings (or all approved with rationale)
- [ ] Code review passed
- [ ] Security review passed (if applicable)
- [ ] Architecture review passed (if applicable)

**PASS** → Proceed to SHIP | **FAIL** → Return to BUILD, address findings

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REVIEW
  completed: [DEFINE, PLAN, BUILD, VERIFY]
  next_action: "SHIP if gate passes"
```

---

### Phase 6: SHIP

<thought>
Observe: Review complete, no blocking findings, code quality verified.
Analyze: Must deliver code safely. Final verification, version bump, changelog, PR creation, deploy, post-deploy monitoring.
Plan: Invoke executor agent with git-workflow skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: ship_to_production
  outputs: [published_pr, deployment, health_check]
</action>

<observation>
result: PR created, CI green, deployed successfully
gate_status: PASS | FAIL
</observation>

**Completion Criteria:**
- [ ] PR created and approved
- [ ] CI checks green
- [ ] Deployed successfully (if applicable)
- [ ] Post-deploy health check passed
- [ ] Documentation updated

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SHIP
  completed: [DEFINE, PLAN, BUILD, VERIFY, REVIEW]
  next_action: "DONE"
```

---

## Phase Adaptability

| Task Type | Phases | Example |
|---|---|---|
| Bug fix | DEFINE → BUILD → VERIFY → SHIP | Fix null pointer in auth |
| Hotfix | DEFINE → BUILD → VERIFY → SHIP | Critical production fix |
| Feature | Full lifecycle | New user dashboard |
| Refactor | DEFINE → PLAN → BUILD → VERIFY → SHIP | Simplify auth module |
| Documentation | DEFINE → BUILD → SHIP | Update API docs |
| Security patch | Full lifecycle | Fix XSS vulnerability |
| Greenfield app | Full lifecycle with extended DEFINE | New product from scratch |

## ReAct Action Types

All workflows use these action types inside `<action>` blocks:

| Type | Purpose | Example |
|---|---|---|
| `invoke_agent` | Dispatch work to a single agent | `target: executor`, `target: planner` |
| `invoke_skill` | Invoke a skill within the current agent context | `target: brainstorming`, `target: code-review` |
| `invoke_workflow` | Delegate to another complete workflow | `target: project-setup`, `target: ship-workflow` |
| `setup_git_and_spec` | Bootstrap workspace (Stage 0) | See `workflows/_shared/stage-0-git-bootstrap.md` |

**`invoke_workflow`** — used when a stage delegates its entire execution to another workflow (e.g., `greenfield-app.md` Stage 7 delegates to `project-setup`, Stage 12 delegates to `ship-workflow`). The calling workflow pauses until the invoked workflow completes and returns its gate status.

---

## Rollback Protocol

At any gate failure:
1. Document what failed and why
2. Return to the relevant phase
3. Fix the issue
4. Re-run the gate
5. Never skip gates — escalate to user if constraints require it

## Integration with Other Workflows

This master lifecycle is inherited by:
- `new-feature.md` — Full lifecycle for new features
- `bug-fix.md` — Abbreviated lifecycle for bug fixes
- `refactoring.md` — Lifecycle for code improvements
- `security-audit.md` — Lifecycle for security assessments
- `greenfield-app.md` — Full lifecycle for new products from scratch
- All team workflows — Lifecycle with multi-agent coordination

## Handoff Contracts

### DEFINE → PLAN
```yaml
handoff:
  from: planner (define)
  to: planner (plan)
  provides: [requirements_doc, success_criteria, assumptions_list]
  expects: [implementation_plan, task_breakdown, dependency_map]
```

### BUILD → VERIFY
```yaml
handoff:
  from: executor
  to: verifier
  provides: [implementation_commits, unit_tests, build_artifacts]
  expects: [verification_report, tc_registry, e2e_evidence]
```

### VERIFY → REVIEW
```yaml
handoff:
  from: verifier
  to: code-reviewer
  provides: [verification_report, test_verifier_pass, e2e_evidence]
  expects: [code_review_report, assessment (APPROVE | REQUEST_CHANGES)]
```

### REVIEW → SHIP
```yaml
handoff:
  from: code-reviewer
  to: executor
  provides: [review_approved, all_gates_passed]
  expects: [pr_merged, deployed, monitoring_healthy]
```

---

## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

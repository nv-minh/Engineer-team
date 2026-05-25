---
name: new-feature
description: Complete workflow from idea to production for new features (ENHANCED with optional market validation)
version: "3.1.0"
category: "primary"
origin: "agent-skills"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
agents_used:
  - planner
  - executor
  - verifier
  - test-engineer
  - test-verifier
  - code-reviewer
  - market-intelligence
skills_used:
  - brainstorming
  - domain-modeling
  - spec-driven-development
  - writing-plans
  - test-driven-development
  - code-review
  - git-workflow
  - alignment-session
  - issue-generator
  - test-generation
  - e2e-testing
  - browser-testing
related_skills:
  - alignment-session
  - spec-driven-development
  - issue-generator
estimated_time: "1-3 days (simple) / 2-3 weeks (complex with market validation)"
---

# New Feature Workflow (Hermes ReAct Protocol)

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1-2)      (3)      (4)      (5)        (5)       (6)
   │          │        │        │           │         │
   ▼          ▼        ▼        ▼           ▼         ▼
 GATE 1    GATE 2   GATE 3   GATE 4      GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Gate |
|---|---|---|
| SETUP (Stage 0) | DEFINE | spec folder detected, branch naming rules checked, spec doc created, on branch with latest main |
| BRAINSTORM (Stage 1) | DEFINE | Design approved, document written |
| MARKET VALIDATION (Stage 1.5, optional) | DEFINE | Market opportunity confirmed, go/no-go decided |
| DOMAIN MODELING (Stage 1.7, optional) | DEFINE | Entities documented, relationships mapped |
| SPEC (Stage 2) | DEFINE | Spec covers all areas, user approved |
| PLAN (Stage 3) | PLAN | All requirements have tasks, no placeholders |
| BUILD (Stage 4) | BUILD | Tasks completed, tests passing, build succeeds |
| VERIFY (Stage 5) | VERIFY + REVIEW | Spec coverage 100%, test-verifier PASS |
| SHIP (Stage 6) | SHIP | PR merged, deployed, monitoring OK |

### Execution Paths

| Path | Stages | Use When |
|---|---|---|
| Fast | 1 → 2 → 3 → 4 → 5 → 6 | Small features, clear requirements, internal tools |
| Parallel | 1 → [1.5 ‖ 2] → 3 → 4 → 5 → 6 | Competitive features, quick/standard market validation |
| Strategic | 1 → 1.5 → 2 → 3 → 4 → 5 → 6 | New markets, strategic initiatives (deep mode blocks spec) |

---

## Stage 0: SETUP (Git & Spec Bootstrap)

> Sub-workflow: `workflows/_shared/stage-0-git-bootstrap.md`
>
> Parameters:
> - `{doc_type}`: spec
> - `{doc_prefix}`: FEAT
> - `{slug_type}`: feature
> - `{default_branch_pattern}`: feat/{slug} | fix/{slug} | refactor/{slug}
> - `{artifact_name}`: spec_document_skeleton
> - `{next_action}`: brainstorm

**Feature spec template** (`{doc_template_body}`):

```yaml
---
type: feature
status: in-progress
branch: {branch-name}
date: {today}
---
# Feature: {title}

## Product
- **Goal**: {goal}
- **User Benefit**: {benefit}
- **Acceptance Criteria**:
  - [ ] (to be filled in Stage 2: Spec)

## Technical Scope
- **Files affected**: (to be filled in Stage 3: Plan)
- **API changes**: (to be filled in Stage 3: Plan)
- **DB changes**: (to be filled in Stage 3: Plan)

## Branch
`{branch-name}`
```

Note: if project uses CR-based naming, use CR-{NNN}-{slug}.md format instead.

---

## Stage 1: Brainstorm (OPTIONAL)

<thought>
Observe: Feature idea received. No design document, no technical approach, no user approval.
Analyze: Explore the idea, ask clarifying questions, propose 2-3 approaches, present for approval. Optional quick market check. Gate requires: design approved + document written + technical approach decided.
Plan: Invoke brainstorming skill. Explore context, generate approaches, write design document.
</thought>

<action>
type: invoke_skill
target: brainstorming
params:
  input: feature_idea
  tasks:
    - explore_project_context
    - ask_clarifying_questions
    - propose_approaches
    - present_for_approval
    - write_design_document
    - quick_market_check (optional, < 15 min)
</action>

<observation>
result: Design document written, user approval obtained
state_change: Feature concept defined with technical approach
gate_status: PASS | FAIL
</observation>

**Gate 1a — Brainstorm Complete:**
- [ ] Design approved by user
- [ ] Design document written
- [ ] Technical approach decided

PASS → Stage 1.5 or Stage 1.7 or Stage 2 | FAIL → retry brainstorm

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  stage_completed: brainstorm
  artifacts:
    - design_document
    - user_approval
  next_action: "market_validation | domain_modeling | spec"
```

---

## Stage 1.5: Market Validation (OPTIONAL)

**Agent:** market-intelligence

**Trigger Conditions:**
- Major feature (strategic impact)
- New market entry
- Competitive differentiation needed
- Significant investment required
- User explicitly requests market analysis

**Skip when:** Small enhancements, clear requirements, internal tools, technical optimizations, time-critical fixes.

**Analysis Modes:**

| Mode | Duration | Execution | Use When |
|---|---|---|---|
| Quick | < 1 hour | Parallel with Stage 2 | Competitive feature check |
| Standard | 1-2 hours | Parallel with Stage 2 | New feature in competitive market |
| Deep | 3-4 hours | Sequential (blocks Stage 2) | New market, strategic initiative |

<thought>
Observe: Design approved. Feature has strategic/competitive implications. No market data.
Analyze: Determine analysis mode (Quick/Standard/Deep). Run market sizing, competitive analysis, customer validation. Gate requires: market opportunity confirmed + competitive landscape understood + go/no-go decided.
Plan: Invoke market-intelligence agent. Mode determines parallel vs sequential execution with Stage 2.
</thought>

<action>
type: invoke_agent
target: market-intelligence
params:
  mode: quick | standard | deep
  input: design_document
  tasks:
    - market_sizing
    - competitive_landscape
    - feature_comparison_matrix
    - customer_segment_analysis
    - strategic_recommendations
    - go_no_go_decision
</action>

<observation>
result: Market validation report, competitive intelligence, strategic recommendations
state_change: Market opportunity confirmed or pivot needed
gate_status: PASS | FAIL | SKIP
</observation>

**Gate 1b — Market Validation Complete:**
- [ ] Market opportunity confirmed OR strategic pivot needed
- [ ] Competitive landscape understood
- [ ] Customer value validated
- [ ] Go/no-go decision made

PASS → Stage 2 (or parallel with Stage 2) | FAIL → pivot or cancel

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  stage_completed: market_validation
  artifacts:
    - market_validation_report
    - competitive_intelligence
    - feature_impact_assessment
  next_action: "spec"
```

---

## Stage 1.7: Domain Modeling (OPTIONAL)

**Agent:** Architect

**Trigger Conditions:**
- Feature touches multiple bounded contexts
- Feature introduces new entities or relationships
- Feature changes the conceptual model
- User explicitly requests domain modeling

**Skip when:** Single bounded context, no new entities, internal refactoring, well-understood scope.

<thought>
Observe: Design approved. Feature crosses bounded contexts or introduces new entities.
Analyze: Map new entities and relationships. Update ubiquitous language. Validate against existing domain model. Gate requires: entities documented + relationships mapped + language updated + user approved.
Plan: Invoke domain-modeling skill. Identify affected contexts, map entities, update glossary.
</thought>

<action>
type: invoke_skill
target: domain-modeling
params:
  input: design_document
  tasks:
    - identify_bounded_contexts
    - map_entities_and_relationships
    - update_ubiquitous_language
    - validate_existing_model
</action>

<observation>
result: Domain model updated, impact assessment complete, entity-relationship diagram created
state_change: Domain model reflects new feature entities
gate_status: PASS | FAIL | SKIP
</observation>

**Gate 1c — Domain Modeling Complete:**
- [ ] New entities documented with types (Aggregate Root / Entity / Value Object)
- [ ] Relationships mapped with cardinality
- [ ] Ubiquitous language updated (no synonyms)
- [ ] User approved changes
- [ ] Existing domain model integrity maintained

PASS → Stage 2 | FAIL → revisit design

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  stage_completed: domain_modeling
  artifacts:
    - domain_model
    - impact_assessment
    - er_diagram
  next_action: "spec"
```

---

## Stage 2: Spec

<thought>
Observe: Design approved. Market insights available (if Stage 1.5 completed). Domain model updated (if Stage 1.7 completed). No formal specification yet.
Analyze: Write structured spec covering all requirement areas. Incorporate market insights and domain model if available. Gate requires: spec covers all areas + user approved + success criteria testable.
Plan: Invoke planner agent with spec-driven-development skill. Read design document, integrate market/domain inputs, write SPEC.md.
</thought>

<action>
type: invoke_skill
target: spec-driven-development
params:
  input:
    - design_document
    - market_validation_report (if available)
    - domain_model (if available)
  tasks:
    - read_design_document
    - incorporate_market_insights (if Stage 1.5 completed)
    - incorporate_domain_model (if Stage 1.7 completed)
    - write_structured_spec
    - define_requirements
    - set_boundaries
    - document_success_criteria
    - update_project_spec_doc: fill in Acceptance Criteria and Technical Scope sections of {spec_folder}/FEAT-{slug}.md created in Stage 0
</action>

<observation>
result: SPEC.md written with requirements, boundaries, success criteria
state_change: Feature formally specified
gate_status: PASS | FAIL
</observation>

**Enhanced Requirements (if Stage 1.5 completed):**
- Area 7: Market Analysis (size, trends, positioning, segments)
- Area 8: Go-to-Market (timing, channels, marketing, success metrics)

**Gate 1d — Spec Complete:**
- [ ] Spec covers all 6 core areas (or 8 areas if Stage 1.5 completed)
- [ ] User approved spec
- [ ] Success criteria testable
- [ ] Market-competitive OR strategically justified (if Stage 1.5 completed)

PASS → Stage 3 | FAIL → revise spec

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  stage_completed: spec
  artifacts:
    - spec_document
    - requirements
    - success_criteria
  next_action: "plan"
```

---

## Stage 3: Plan

<thought>
Observe: Spec approved. Requirements defined. Success criteria set. No implementation plan yet.
Analyze: Break spec into tasks, estimate effort, map dependencies, define verification steps. Incorporate market constraints if applicable. Gate requires: all requirements have tasks + no placeholders + acceptance criteria defined.
Plan: Invoke planner agent with writing-plans skill. Generate PLAN.md with task breakdown.
</thought>

<action>
type: invoke_agent
target: planner
params:
  input: spec_document
  tasks:
    - break_into_tasks
    - estimate_effort
    - identify_dependencies
    - define_verification_steps
    - create_implementation_plan
    - incorporate_market_constraints (if Stage 1.5 completed)
</action>

<observation>
result: PLAN.md created with task breakdown, dependencies, verification steps
state_change: Implementation plan ready
gate_status: PASS | FAIL
</observation>

**Gate 2 — Plan Complete:**
- [ ] All requirements have tasks
- [ ] No placeholders in plan
- [ ] Acceptance criteria defined
- [ ] Verification steps specified
- [ ] Market factors considered (if Stage 1.5 completed)

PASS → Stage 4 | FAIL → revise plan

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PLAN
  stage_completed: plan
  artifacts:
    - plan_document
    - task_breakdown
    - dependency_map
  next_action: "build"
```

---

## Stage 4: Build

<thought>
Observe: Plan approved. Task breakdown ready. Dependencies mapped. No implementation yet.
Analyze: Execute plan task-by-task. Follow TDD (RED-GREEN-REFACTOR). Atomic commits per task. Run quality gates after each task. Gate requires: tasks completed + tests passing + build succeeds.
Plan: Invoke executor agent. Execute tasks sequentially, each with TDD cycle and atomic commit.
</thought>

<action>
type: invoke_agent
target: executor
params:
  input: plan_document
  tasks:
    - execute_tasks_sequentially
    - follow_tdd_per_task
    - atomic_commit_per_task
    - run_quality_gates
    - handle_errors
</action>

<observation>
result: All tasks completed, tests passing, build succeeds
state_change: Feature implemented with test coverage
gate_status: PASS | FAIL
</observation>

**Gate 3 — Build Complete:**
- [ ] Tasks completed
- [ ] Tests passing
- [ ] Code reviewed
- [ ] Build succeeds

PASS → Stage 5 | FAIL → retry failed task (max 3)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BUILD
  stage_completed: build
  artifacts:
    - implementation_commits
    - unit_tests
    - integration_tests
  next_action: "verify"
```

---

## Stage 5: Verify

> **⛔ NON-SKIPPABLE STAGE.** Every step below is MANDATORY. Do NOT proceed to Stage 6 without completing ALL steps and producing ALL required artifacts. If Playwright is not set up, run `playwright-setup` agent first.

<thought>
Observe: Feature implemented. Unit tests pass. Build succeeds. No spec coverage verification, no E2E evidence, no test-verifier report.
Analyze: Verify spec coverage. Generate test cases from SPEC.md. Run E2E tests with Playwright. Record video evidence for all test runs. Collect browser evidence (screenshots + video + traces). Double-check with test-verifier. Gate requires: spec coverage 100% + all acceptance criteria met + test-verifier PASS + evidence artifacts present.
Plan: Execute 5 mandatory steps in sequence. Each step MUST produce its output before the next step begins. No step may be skipped.
</thought>

### MANDATORY EXECUTION STEPS

**Step 5.1 — Verify Spec Coverage (verifier agent)**

Invoke the `verifier` agent. Compare every requirement in SPEC.md against the implementation. Produce a coverage map: requirement → file:line.

<action>
type: invoke_agent
target: verifier
params:
  mode: verify
  input: spec_document
  tasks:
    - verify_spec_coverage
    - test_acceptance_criteria
    - integration_testing
</action>

Required output: `verification_report` with spec coverage percentage. If coverage < 100%, list uncovered requirements. Do NOT proceed until coverage is addressed.

---

**Step 5.2 — Generate Test Case Registry (test-generation skill)**

Invoke the `test-generation` skill. Read SPEC.md and source code. Generate a structured TC Registry with TC-IDs for every acceptance criterion.

<action>
type: invoke_skill
target: test-generation
params:
  input:
    - spec_document
    - source_code
  output: tc_registry
  note: Ask clarifying questions if spec lacks acceptance criteria
</action>

Required output: `TC-REGISTRY.md` with entries in format `TC-UNIT-NNN`, `TC-INT-NNN`, `TC-E2E-NNN`. Each entry maps to a spec requirement.

---

**Step 5.3 — Ensure Playwright Setup**

Before running E2E tests, verify Playwright is configured:

```
CHECK: Does playwright.config.ts exist?
  YES → Verify it includes video: 'retain-on-failure' and trace: 'retain-on-failure'
        If not, update the config to add these settings.
  NO  → Invoke playwright-setup agent to bootstrap Playwright infrastructure.
```

Playwright config MUST include:
```typescript
use: {
  video: 'retain-on-failure',    // Record video for every failing test
  trace: 'retain-on-failure',    // Capture trace for every failing test
  screenshot: 'only-on-failure', // Screenshot on every failure
}
```

---

**Step 5.4 — Run E2E Tests & Collect Evidence (e2e-testing + browser-testing skills)**

Invoke `e2e-testing` skill to write Playwright E2E tests for all new user flows using Page Object Model. Then invoke `browser-testing` skill to execute tests and collect evidence.

<action>
type: invoke_skill
target: e2e-testing
params:
  tool: playwright
  scope: new_user_flows
  pattern: page_object_model
</action>

<action>
type: invoke_skill
target: browser-testing
params:
  scope: new_feature_ui
  evidence: screenshots_video_traces
  regression_check: existing_ui
</action>

Execute tests:
```bash
npx playwright test --reporter=html,list
```

Required output — evidence directory with:
```
test-results/
├── videos/          # .webm video for every failing test
├── screenshots/     # .png screenshot for every failing test
├── traces/          # .zip Playwright trace for every failing test
└── reports/
    └── playwright-report/index.html
```

If ANY test fails, collect evidence (video + screenshot + trace), then proceed to Step 5.5 for retry.

---

**Step 5.5 — Double-Check with Test Verifier (test-verifier agent)**

Invoke `test-verifier` agent to re-run failed tests, apply targeted fixes, and produce a final verdict.

<action>
type: invoke_agent
target: test-verifier
params:
  mode: double_check
  max_retries: 3
  input: all_test_results
  evidence_required: true
</action>

Test verifier behavior:
1. Re-run ONLY failed tests (not the full suite)
2. Spot-check 3-5 passed tests for correctness
3. If tests fail, apply targeted fix and retry (max 3 retries total)
4. On each retry, Playwright records video + trace automatically (`retain-on-failure`)
5. Output: PASS with confidence score OR FAIL with per-TC details + evidence paths

Required output: `test-verifier-report.md` with:
- Verdict: PASS or FAIL
- Confidence score (based on retries used)
- Evidence paths for all failures (screenshots, videos, traces)
- Manual reproduction steps for any unresolved failures

---

<observation>
result: Spec coverage verified, TC registry generated, E2E tests executed with Playwright evidence recorded, test-verifier report issued
state_change: Full verification complete with evidence artifacts
gate_status: PASS | FAIL
</observation>

**Gate 4+5 — Verification and Review Complete:**
- [ ] Spec coverage verified (100%)
- [ ] Test case registry generated (`TC-REGISTRY.md` with TC-IDs)
- [ ] All acceptance criteria met
- [ ] Integration tests pass
- [ ] Playwright configured with `video: 'retain-on-failure'`
- [ ] E2E tests cover all new user flows (Page Object Model)
- [ ] E2E tests executed with `npx playwright test`
- [ ] Browser test evidence collected (`test-results/videos/`, `test-results/screenshots/`, `test-results/traces/`)
- [ ] **test-verifier PASS** (or FAIL report reviewed and signed off by user before proceeding)
- [ ] User acceptance testing passed

⛔ **DO NOT proceed to Stage 6 if ANY of the above items is unchecked.**

PASS → Stage 6 | FAIL → return to Stage 4

**State Snapshot:**
```yaml
workflow_state:
  current_phase: VERIFY
  stage_completed: verify
  artifacts:
    - tc_registry
    - verification_report
    - e2e_test_files
    - e2e_evidence (videos, screenshots, traces)
    - playwright_html_report
    - test_verifier_report
  next_action: "ship"
```

<!-- GATE:VERIFY:REQUIRED artifacts=[tc-registry,e2e-evidence,test-verifier-report] -->

---

## Stage 6: Ship

<thought>
Observe: Feature verified. All tests pass. test-verifier PASS. Evidence collected.
Analyze: Final code review, create PR, merge, deploy, monitor. Gate requires: code review approved + PR merged + deployed + monitoring OK.
Plan: Invoke executor for PR creation, code-reviewer for review. Deploy and monitor.
</thought>

<action>
type: invoke_agent
target: executor
params:
  mode: ship
  tasks:
    - final_code_review
    - create_pull_request
    - merge_to_main
    - deploy_to_production
    - monitor_deployment
</action>

<action>
type: invoke_agent
target: code-reviewer
params:
  mode: standard
  input: pull_request
</action>

<observation>
result: Code reviewed, PR merged, deployed, monitoring healthy
state_change: Feature shipped to production
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

Create workspace at Stage 2 (Spec) start — all subsequent artifacts route here:
```
artifactStore.createWorkspace('new-feature', featureName)
```

Living documents (updated in place across iterations):
- `SPEC.md` → `artifactStore.upsert('SPEC.md', content)`
- `TC-REGISTRY.md` → `artifactStore.upsert('TC-REGISTRY.md', content)`

Timestamped logs (appended each run):
- Test executions → `artifactStore.workspaceExport('test-executions', ...)`
- Code reviews → `artifactStore.workspaceExport('reviews', ...)`
- Evidence → `artifactStore.workspaceExport('evidence', ...)`

Result: `.em-artifacts/new-feature/{feature-slug}/` with all artifacts grouped.
When iterating (follow-up prompts), living docs are updated in place and ITERATION-LOG.md tracks changes.

**Legacy export** (also writes to category folders for backward compatibility):
- Spec → `specs/new-feature/`
- Test report → `test-reports/new-feature/`
- Code review → `reviews/new-feature/`

---

## Handoff Contracts

### Brainstorm → Spec

```yaml
handoff:
  from: brainstorming
  to: planner
  provides:
    - design_document
    - user_approval
    - initial_market_notes (optional)
    - domain_model (if Stage 1.7 completed)
  expects:
    - spec_document
    - requirements_defined
```

### Brainstorm → Domain Modeling

```yaml
handoff:
  from: brainstorming
  to: architect
  trigger: Feature crosses bounded contexts OR introduces new entities OR user requests
  provides:
    - design_document
    - user_approval
  expects:
    - domain_model
    - impact_assessment
```

### Brainstorm → Market Validation

```yaml
handoff:
  from: brainstorming
  to: market-intelligence
  trigger: Major feature OR new market OR user request
  provides:
    - design_document
    - feature_concept
    - initial_market_notes
  expects:
    - market_validation_report
    - competitive_intelligence
    - strategic_recommendations
```

### Market Validation → Spec

```yaml
handoff:
  from: market-intelligence
  to: planner
  provides:
    - market_validation_report
    - competitive_intelligence
    - feature_impact_assessment
  expects:
    - spec_document_with_market_insights
    - requirements_informed_by_market_data
    - competitive_differentiation_considered
```

### Spec → Plan

```yaml
handoff:
  from: planner
  to: planner
  provides:
    - spec_document
    - requirements
    - market_insights (if available)
  expects:
    - implementation_plan
    - task_breakdown
    - market_considerations (if applicable)
```

---

## Error Handling

| Error Type | Trigger | Recovery |
|---|---|---|
| `SPEC_CONFLICT` | Acceptance criteria contradict each other or the design doc | Return to Stage 2. Flag conflict explicitly. Do not proceed until user resolves. |
| `BUILD_DEADLOCK` | Same task fails 3× with different error messages (thrashing) | STOP. Invoke `systematic-debugging` skill before retrying. Debugging attempts do not consume `max_retries`. |
| `TEST_ENV_FAILURE` | Test runner / Playwright fails with infrastructure error (not test logic) | Infrastructure failures do NOT consume `max_retries`. Fix environment, retry stage fresh. |
| `CONTEXT_OVERFLOW` | Claude signals loss of earlier stage outputs mid-workflow | Run context pruning immediately. Re-read spec document and gate status. Resume from last completed gate — do not restart from Stage 0. |

---

## Context Pruning

After each stage completes, prune context:
- Drop raw brainstorm explorations (retain design document only)
- Drop full market research data (retain summary + recommendations only)
- Drop intermediate test output (retain pass/fail summary only)
- Drop eliminated design approaches (retain chosen approach only)
- Retain: design document, spec, plan, gate status, artifacts list

---

## Decision Framework: Market Validation Mode

```yaml
decision_tree:
  small_enhancement: SKIP Stage 1.5
  standard_feature:
    competitive_market: Quick Mode (parallel with Stage 2)
    no_competition: SKIP Stage 1.5
  major_feature:
    existing_market: Standard Mode (parallel with Stage 2)
    new_market: Deep Mode (sequential, blocks Stage 2)
  strategic_initiative: Deep Mode (sequential, blocks Stage 2)
```

---

## Quality Gates Summary

```yaml
quality_gates:
  brainstorm:
    - design_approved
    - design_document_written

  market_validation (optional):
    - market_opportunity_confirmed
    - competitive_landscape_understood
    - customer_value_validated
    - go_no_go_decision_made

  domain_modeling (optional):
    - entities_documented
    - relationships_mapped
    - ubiquitous_language_updated

  spec:
    - spec_complete
    - user_approved
    - success_criteria_testable

  plan:
    - requirements_mapped
    - tasks_defined
    - no_placeholders

  build:
    - tasks_completed
    - tests_passing
    - build_succeeds

  verify:
    - spec_coverage_100
    - tc_registry_generated
    - e2e_evidence_collected
    - test_verifier_pass

  ship:
    - code_review_approved
    - pr_merged
    - deployed_successfully
    - monitoring_ok
```

## Timeline Estimate

```yaml
timeline:
  brainstorm: "2-4 hours"
  market_validation_quick: "< 1 hour (parallel with spec)"
  market_validation_standard: "1-2 hours (parallel with spec)"
  market_validation_deep: "3-4 hours (blocks spec)"
  domain_modeling: "30-60 min (optional)"
  spec: "1-2 hours"
  plan: "2-4 hours"
  build: "1-3 days"
  verify: "2-4 hours"
  ship: "1-2 hours"

  total_simple: "1-2 days"
  total_with_market_validation: "1.5-2.5 days"
  total_complex_with_market: "2-3 weeks"
```

---
name: greenfield-app
description: Complete workflow from blank directory to shipped application. Covers ideation, problem reframing, domain modeling, requirements, UI/UX design, architecture, bootstrapping, Project DNA crystallization, implementation, and launch.
version: "3.1.0"
category: "primary"
origin: "EM-Team"
agents_used:
  - product-manager
  - architect
  - planner
  - frontend-expert
  - executor
  - verifier
  - test-engineer
  - test-verifier
  - market-intelligence
  - ui-auditor
  - design-reviewer
skills_used:
  - brainstorming
  - domain-modeling
  - spec-driven-development
  - alignment-session
  - writing-plans
  - frontend-patterns
  - project-dna
  - test-driven-development
  - subagent-driven-development
  - code-review
  - git-workflow
  - ux-audit
  - test-generation
  - e2e-testing
  - browser-testing
related_skills:
  - domain-modeling
  - spec-driven-development
  - project-setup
  - project-dna
  - figma-design
  - flow-discovery
estimated_time: "1-2 weeks (MVP) / 4-8 weeks (full product)"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Greenfield App Workflow

```
IDEATION → REFRAME → DOMAIN → SPEC → UI/UX → ARCH → BOOTSTRAP → CRYSTALLIZE → BUILD → VAL → REV → LAUNCH
   1          2        3       4       5       6        7            8           9      10    11    12

── DEFINE ──→ ────── PLAN ──────→ ──────────── BUILD ───────────────→ VERIFY → REVIEW → SHIP
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase |
|---|---|
| IDEATION (Stage 1) | DEFINE |
| REFRAMING (Stage 2) | DEFINE |
| DOMAIN MODEL (Stage 3) | DEFINE |
| SPEC (Stage 4) | PLAN |
| UI/UX DESIGN (Stage 5) | PLAN |
| ARCHITECTURE (Stage 6) | PLAN |
| BOOTSTRAP (Stage 7) | BUILD |
| CRYSTALLIZE (Stage 8) | BUILD |
| IMPLEMENT (Stage 9) | BUILD |
| VALIDATE (Stage 10) | VERIFY |
| REVIEW (Stage 11) | REVIEW |
| LAUNCH (Stage 12) | SHIP |

---

## Stage 1: Ideation and Validation

<thought>
Observe: Blank directory, idea exists but unvalidated.
Analyze: Must answer "should we build this?" through six forcing questions. Gate requires falsifiable hypothesis, alternative framings explored, Go/No-Go decision.
Plan: Invoke product-manager agent with office-hours skill.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  skill: office-hours
  task: validate_idea
  questions: [demand_reality, status_quo_bias, narrowest_wedge, observation, future_fit, personal_fit]
  outputs: [idea_brief, go_no_go_decision, alternative_framings]
</action>

<observation>
result: Idea hypothesis stated, alternative framings explored, Go/No-Go decided
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Idea hypothesis stated as a falsifiable claim
- [ ] At least one alternative framing explored
- [ ] Go/No-Go decision made
- [ ] If No-Go: workflow ends, pivot considered

**State Snapshot:**
```yaml
workflow_state:
  current_phase: IDEATION
  completed: []
  next_action: "REFRAMING if Go"
```

---

## Stage 2: Problem Reframing and Design

<thought>
Observe: Idea validated, Go decision made.
Analyze: Must reframe the problem using Problem Framing Canvas, brainstorm 2-3 approaches, get user approval. Gate requires actionable problem statement, approaches explored, design document written.
Plan: Invoke product-manager + architect agents with brainstorming skill.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  skill: brainstorming
  supporting_agent: architect
  task: reframe_problem
  outputs: [design_document, problem_reframing, selected_approach]
</action>

<observation>
result: Problem reframed, 2-3 approaches explored, design document written and approved
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Problem reframed with actionable statement
- [ ] 2-3 approaches explored with trade-offs
- [ ] User approved selected approach
- [ ] Design document written and committed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REFRAMING
  completed: [IDEATION]
  next_action: "DOMAIN MODEL"
```

---

## Stage 3: Domain Modeling

<thought>
Observe: Design document approved, selected approach clear.
Analyze: Must extract bounded contexts, entities, relationships, lifecycle states, ubiquitous language. Gate requires all concepts mapped, contexts identified, entities typed, relationships documented, glossary complete.
Plan: Invoke architect + planner agents with domain-modeling skill.
</thought>

<action>
type: invoke_agent
target: architect
params:
  skill: domain-modeling
  supporting_agent: planner
  task: create_domain_model
  outputs: [domain_model, bounded_contexts, er_diagrams, ubiquitous_language]
</action>

<observation>
result: Domain model complete with bounded contexts, entities, relationships, glossary
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] All brainstorming concepts mapped to entities or excluded
- [ ] Bounded contexts identified with clear responsibilities
- [ ] Entities have types (Aggregate Root / Entity / Value Object)
- [ ] Relationships documented with cardinality
- [ ] Ubiquitous language glossary complete (no synonyms)
- [ ] User approved the domain model

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DOMAIN_MODEL
  completed: [IDEATION, REFRAMING]
  next_action: "SPEC"
```

---

## Stage 4: Requirements and Specification

<thought>
Observe: Domain model complete with bounded contexts and ubiquitous language.
Analyze: Must map every domain entity to requirements, write structured specification with REQ-IDs, define v1 scope. Gate requires entity-to-requirement mapping, traceable requirements, testable success criteria.
Plan: Invoke planner agent with spec-driven-development skill.
</thought>

<action>
type: invoke_agent
target: planner
params:
  skill: spec-driven-development
  input: [design_document, domain_model]
  outputs: [SPEC.md, REQUIREMENTS.md]
</action>

<observation>
result: SPEC.md and REQUIREMENTS.md with traceable REQ-IDs, v1 scope defined
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Every domain entity maps to at least one requirement
- [ ] Requirements traceable (REQ-IDs)
- [ ] v1 scope defined with clear boundaries
- [ ] Success criteria testable
- [ ] User approved spec

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SPEC
  completed: [IDEATION, REFRAMING, DOMAIN_MODEL]
  next_action: "UI_UX_DESIGN"
```

---

## Stage 5: UI/UX Design

<thought>
Observe: SPEC.md and REQUIREMENTS.md complete, domain model available.
Analyze: Must define user flows, component specifications, design system, accessibility requirements, responsive strategy, performance targets, interaction patterns. Gate requires flows covering v1 requirements with error paths, component tree, design system documented.
Plan: Invoke frontend-expert agent with frontend-patterns skill (optionally figma-design).
</thought>

<action>
type: invoke_agent
target: frontend-expert
params:
  skill: frontend-patterns
  optional_skill: figma-design
  input: [SPEC.md, REQUIREMENTS.md, domain_model]
  outputs: [UI-SPEC.md, design_tokens, user_flow_diagrams]
</action>

<observation>
result: UI-SPEC.md complete with user flows, components, design system, accessibility, responsive strategy
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] User flows cover all v1 requirements from SPEC.md
- [ ] Every user flow includes error paths (not just happy path)
- [ ] Component tree maps to domain entities where applicable
- [ ] Design system decisions documented (typography, colors, spacing)
- [ ] WCAG compliance level chosen and specific considerations listed
- [ ] Responsive breakpoints defined with mobile-first approach
- [ ] Performance targets set with specific Core Web Vitals goals
- [ ] Interaction patterns cover loading, error, empty, and success states
- [ ] User approved UI-SPEC.md

**State Snapshot:**
```yaml
workflow_state:
  current_phase: UI_UX_DESIGN
  completed: [IDEATION, REFRAMING, DOMAIN_MODEL, SPEC]
  next_action: "ARCHITECTURE"
```

---

## Stage 6: Architecture Design and Codebase Structure

<thought>
Observe: SPEC.md, REQUIREMENTS.md, UI-SPEC.md, domain model all complete.
Analyze: Must research 2-3 architecture patterns, present options with project-specific examples, get user decision, generate architecture document and 3 rule files, create phased roadmap. Gate requires user-chosen architecture, ARCHITECTURE.md, 3 rule files, roadmap.
Plan: Invoke architect + planner agents with codebase-architecture and writing-plans skills.
</thought>

<action>
type: invoke_agent
target: architect
params:
  skills: [codebase-architecture, writing-plans]
  supporting_agent: planner
  task: architecture_design
  sub_steps:
    - research_architectures
    - present_options_to_user
    - generate_architecture_doc
    - generate_rule_files
    - create_roadmap
  outputs: [ARCHITECTURE.md, ROADMAP.md, architecture-boundaries.md, architecture-conventions.md, architecture-patterns.md]
</action>

<observation>
result: Architecture chosen, documented, 3 rule files generated, roadmap created
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Architecture research presented: 2-3 options with project-specific structure examples
- [ ] User has explicitly chosen an architecture (not just acknowledged)
- [ ] ARCHITECTURE.md written: pattern name, rationale, file structure, dependency rule, data flow, failure modes
- [ ] Three rule files generated with project-specific names (no placeholders)
- [ ] Rule files have concrete code examples (correct AND incorrect)
- [ ] Roadmap phases consistent with chosen architecture's module structure
- [ ] First phase exercises the full architecture stack end-to-end

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ARCHITECTURE
  completed: [IDEATION, REFRAMING, DOMAIN_MODEL, SPEC, UI_UX_DESIGN]
  next_action: "BOOTSTRAP"
```

---

## Stage 7: Technical Bootstrapping

<thought>
Observe: Architecture chosen, roadmap created, tech stack decided.
Analyze: Must scaffold project, configure tooling, set up CI/CD. Delegates to project-setup workflow.
Plan: Invoke planner + executor agents via project-setup workflow.
</thought>

<action>
type: invoke_workflow
target: project-setup
params:
  input: [ARCHITECTURE.md, domain_model]
  outputs: [initialized_project, cicd_pipeline, repository]
</action>

<observation>
result: Project scaffolded, build passes, CI/CD active, repository initialized
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Project scaffolded and configured
- [ ] Build passes
- [ ] CI/CD active
- [ ] Repository initialized

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BOOTSTRAP
  completed: [IDEATION, REFRAMING, DOMAIN_MODEL, SPEC, UI_UX_DESIGN, ARCHITECTURE]
  next_action: "CRYSTALLIZE"
```

---

## Stage 8: Crystallize (Project DNA)

<thought>
Observe: Project bootstrapped, all design artifacts available.
Analyze: Must crystallize all artifacts into agent guidance. Consolidate spec folder, synthesize CLAUDE.md (80-150 lines), generate 8 rule files, create PROJECT-DNA.md traceability manifest. Gate requires spec folder populated, CLAUDE.md generated, 8+ rules, trace matrix.
Plan: Invoke planner agent with project-dna skill.
</thought>

<action>
type: invoke_skill
target: project-dna
params:
  input: [design_doc, domain_model, SPEC.md, REQUIREMENTS.md, UI-SPEC.md, ARCHITECTURE.md, ROADMAP.md]
  outputs: [spec_folder, CLAUDE.md, rules, PROJECT-DNA.md]
</action>

<observation>
result: Spec folder populated, CLAUDE.md generated, 8 rule files created, PROJECT-DNA.md with trace matrix
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] `spec/` folder populated with all found artifacts (including UI-SPEC.md)
- [ ] `spec/README.md` index generated and accurate
- [ ] `CLAUDE.md` generated (80-150 lines, no placeholders, includes Design System)
- [ ] At least 8 rule files in `.claude/rules/`
- [ ] `spec/PROJECT-DNA.md` has trace matrix covering all requirements
- [ ] Every domain entity appears in domain-to-code map
- [ ] UI-to-code map covers all user flows and components from UI-SPEC.md
- [ ] User reviewed and approved generated files

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CRYSTALLIZE
  completed: [IDEATION, REFRAMING, DOMAIN_MODEL, SPEC, UI_UX_DESIGN, ARCHITECTURE, BOOTSTRAP]
  next_action: "IMPLEMENT"
```

---

## Stage 9: Core Implementation

<thought>
Observe: Project DNA crystallized, roadmap phases defined, all guidance in place.
Analyze: Must execute roadmap phases with wave-based parallelization. Load Project DNA first. Per phase: discuss gray areas, plan, execute with TDD, verify. Post-phase: update trace matrix, append conventions, log gotchas.
Plan: Invoke executor agent with subagent-driven-development and TDD skills.
</thought>

<action>
type: invoke_agent
target: executor
params:
  skills: [subagent-driven-development, test-driven-development]
  task: execute_roadmap
  pre_load: [PROJECT-DNA.md, UI-SPEC.md, CLAUDE.md, rules]
  per_phase: [discuss, plan, execute_tdd, verify]
  post_phase: [update_trace_matrix, update_ui_code_map, append_conventions, log_gotchas]
  outputs: [working_code, tests, atomic_commits, updated_trace_matrix]
</action>

<observation>
result: Roadmap phases implemented, tests passing, trace matrix updated
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] All phase acceptance criteria met
- [ ] Tests passing (unit + integration)
- [ ] No TODOs or placeholders in code
- [ ] Atomic commits with clear messages
- [ ] Trace matrix updated with implementation file paths

**State Snapshot:**
```yaml
workflow_state:
  current_phase: IMPLEMENT
  completed: [IDEATION, REFRAMING, DOMAIN_MODEL, SPEC, UI_UX_DESIGN, ARCHITECTURE, BOOTSTRAP, CRYSTALLIZE]
  next_action: "VALIDATE"
```

---

## Stage 10: Validation

<thought>
Observe: Implementation complete, tests passing, trace matrix updated.
Analyze: Must verify spec coverage 100%, cross-check domain model, generate TC registry, run full test suite + E2E + browser tests, double-check with test-verifier, run UX audit and flow discovery. Gate requires spec coverage 100%, test-verifier PASS, UX audit >= 7/10.
Plan: Run code-review diff scan FIRST, then invoke verifier + test-engineer + test-verifier agents with test-generation, e2e-testing, browser-testing, ux-audit, flow-discovery skills. Review fixes validated by test suite.
</thought>

<action>
type: invoke_agent
target: code-reviewer
params:
  mode: standard
  focus: diff_review
  inputs: [changed_files_list, spec_requirements, architecture_decisions]
  outputs: [diff_review_report]
</action>

<action>
type: invoke_agent
target: verifier
params:
  skills: [test-generation, e2e-testing, browser-testing, ux-audit, flow-discovery]
  agents: [test-engineer, test-verifier]
  task: full_validation
  outputs: [verification_report, tc_registry, e2e_evidence, test_verifier_report, ux_audit_scorecard, flow_verification]
</action>

<observation>
result: Spec coverage 100%, test-verifier PASS, UX audit score >= 7/10
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Code-review diff scan PASS (no CRITICAL, no unaddressed HIGH)
- [ ] Spec coverage 100%
- [ ] Every domain entity implemented
- [ ] Test case registry complete (TC-UNIT, TC-INT, TC-E2E)
- [ ] All acceptance criteria met
- [ ] E2E test suite executed — all critical user flows pass
- [ ] Browser test evidence collected
- [ ] **test-verifier PASS** (or failure report reviewed by user before proceeding)
- [ ] No regressions
- [ ] UX audit overall score >= 7/10
- [ ] No critical findings (score <= 4) in any UX dimension
- [ ] All user flows from UI-SPEC.md verified as implemented
- [ ] Accessibility compliance verified against stated WCAG level
- [ ] User acceptance testing passed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: VALIDATE
  completed: [IDEATION, REFRAMING, DOMAIN_MODEL, SPEC, UI_UX_DESIGN, ARCHITECTURE, BOOTSTRAP, CRYSTALLIZE, IMPLEMENT]
  next_action: "REVIEW"
```

---

## Stage 11: Multi-Agent Review

<thought>
Observe: Validation complete, all tests passing, UX audit passed.
Analyze: Must run sequential review pipeline: architecture review, code review (Deep 9-axis), security review (OWASP + STRIDE), UI audit (6-pillar), design review (6-pillar). Gate requires no critical findings in any review, architecture matches design.
Plan: Invoke code-reviewer (Deep), security-reviewer, architect, ui-auditor, design-reviewer agents.
</thought>

<action>
type: invoke_agent
target: code-reviewer
params:
  mode: deep_9axis
  agents: [security-reviewer, architect, ui-auditor, design-reviewer]
  pipeline: [architecture_review, code_review, security_review, ui_audit, design_review]
  outputs: [architecture_report, code_review_report, security_report, ui_audit_report, design_review_report]
</action>

<observation>
result: All reviews passed, no critical findings, architecture matches design
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] No critical findings in any review
- [ ] High findings have remediation plan
- [ ] Architecture matches design (no drift)
- [ ] Security scorecard acceptable
- [ ] UI audit passes all 6 pillars (no critical failures)
- [ ] Design review passes (no critical visual regressions)
- [ ] Accessibility compliance confirmed by ui-auditor

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REVIEW
  completed: [IDEATION, REFRAMING, DOMAIN_MODEL, SPEC, UI_UX_DESIGN, ARCHITECTURE, BOOTSTRAP, CRYSTALLIZE, IMPLEMENT, VALIDATE]
  next_action: "LAUNCH"
```

---

## Stage 12: Launch

<thought>
Observe: All reviews passed, code production-ready.
Analyze: Must ship to production. Delegates to ship-workflow: final verification, version bump, PR creation, merge, deploy, canary monitoring.
Plan: Invoke executor agent via ship-workflow.
</thought>

<action>
type: invoke_workflow
target: ship-workflow
params:
  outputs: [pr_merged, deployment, monitoring]
</action>

<observation>
result: PR merged, deployed to production, monitoring healthy
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] PR merged
- [ ] Deployed successfully
- [ ] Monitoring shows healthy state
- [ ] No production errors

**State Snapshot:**
```yaml
workflow_state:
  current_phase: LAUNCH
  completed: [IDEATION, REFRAMING, DOMAIN_MODEL, SPEC, UI_UX_DESIGN, ARCHITECTURE, BOOTSTRAP, CRYSTALLIZE, IMPLEMENT, VALIDATE, REVIEW]
  next_action: "DONE"
```

---

## Feature Workspace

When `EM_TEAM_ARTIFACT_EXPORT=true`:

Create workspace at Stage 1 (Discovery) start:
```
artifactStore.createWorkspace('greenfield', appName)
```

Living documents: `SPEC.md` (requirements), `TC-REGISTRY.md` (test cases), `ARCHITECTURE.md` (design)
Timestamped logs: test-executions, reviews, evidence

Result: `.em-artifacts/greenfield/{app-slug}/` — follow-up prompts update in place.

**Legacy export:** Spec → `specs/greenfield/` | Tests → `test-reports/greenfield/` | Arch → `architecture/greenfield/` | Review → `reviews/greenfield/`

---

## Handoff Contracts

### Stage 1 → Stage 2
```yaml
handoff:
  from: product-manager
  to: product-manager + architect
  provides: [validated_idea_brief, go_no_go_decision, alternative_framings]
  expects: [design_document, selected_approach]
```

### Stage 2 → Stage 3
```yaml
handoff:
  from: product-manager + architect
  to: architect + planner
  provides: [design_document, user_approval]
  expects: [domain_model, bounded_contexts, ubiquitous_language]
```

### Stage 3 → Stage 4
```yaml
handoff:
  from: architect + planner
  to: planner
  provides: [domain_model, bounded_contexts, entity_relationships, ubiquitous_language]
  expects: [spec_document, requirements_with_traceability]
```

### Stage 4 → Stage 5
```yaml
handoff:
  from: planner
  to: frontend-expert
  provides: [spec_document, requirements, domain_model]
  expects: [ui_spec_document, user_flows, component_specifications, design_system_decisions]
```

### Stage 5 → Stage 6
```yaml
handoff:
  from: frontend-expert
  to: architect + planner
  provides: [ui_spec_document, user_flows, component_specifications, design_system_decisions, spec_document, requirements]
  expects: [architecture_document, roadmap]
```

### Stage 6 → Stage 7
```yaml
handoff:
  from: architect + planner
  to: planner + executor
  provides: [architecture_document, roadmap, tech_stack_decisions]
  expects: [initialized_project, cicd_active]
```

### Stage 7 → Stage 8
```yaml
handoff:
  from: planner + executor
  to: planner (project-dna skill)
  provides: [initialized_project, design_document, domain_model, spec_document, requirements, ui_spec_document, architecture_document, roadmap]
  expects: [consolidated_spec_folder, generated_claude_md, generated_rules, project_dna_manifest]
```

### Stage 8 → Stage 9
```yaml
handoff:
  from: planner (project-dna skill)
  to: executor
  provides: [consolidated_spec_folder, claude_md, project_rules, project_dna_manifest, roadmap, ui_spec_document, design_system_rules]
  expects: [working_code, tests_passing, updated_trace_matrix]
```

---

## Japanese Outsourcing Extension

When running for a Japanese outsourcing client, apply these extensions:

- **Stage 3 Extension:** After domain modeling, run `basic-design` skill → `docs/BASIC-DESIGN.md`. Gate 2a: client sign-off.
- **Stage 4 Extension:** After REQUIREMENTS.md, formal requirements sign-off (Gate 1 template). Initialize WBS.md.
- **Stage 6 Extension:** After architecture, run `detailed-design` skill per complex module. Gate 2b: tech lead + QA sign-off.
- **Stage 9 Extension:** Weekly `progress-reporting` skill. Change requests via `protocols/change-management.md`.
- **Stage 10 Extension:** Replace standard validation with formal UAT using `uat-process` skill. Gate 4: UAT sign-off.
- **Stage 12 Extension:** Complete `ACCEPTANCE-CHECKLIST.md`. Final client sign-off.

For dedicated Japanese outsourcing workflow, use `japanese-outsourcing` workflow instead.

---

## Error Handling

| Error Type | Trigger | Recovery |
|---|---|---|
| `SPEC_CONFLICT` | Acceptance criteria contradict each other or the architecture doc | Return to the relevant DEFINE stage. Flag conflict explicitly. Do not proceed until user resolves. |
| `BUILD_DEADLOCK` | Same task fails 3× with different error messages (thrashing) | STOP. Invoke `systematic-debugging` skill before retrying. Debugging attempts do not consume `max_retries`. |
| `TEST_ENV_FAILURE` | Test runner / Playwright / build tool fails with infrastructure error | Infrastructure failures do NOT consume `max_retries`. Fix environment, retry stage fresh. |
| `SCAFFOLD_FAILURE` | Project setup or CI/CD pipeline fails during Stage 7 | Re-run `project-setup` workflow with verbose output. Check for missing dependencies or version conflicts before retrying. |
| `CONTEXT_OVERFLOW` | Claude signals loss of earlier stage outputs mid-workflow | Run context pruning immediately. Re-read spec document and gate status. Resume from last completed gate — do not restart from Stage 1. |

---

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

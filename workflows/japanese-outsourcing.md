---
name: japanese-outsourcing
description: "End-to-end workflow for Japanese outsourcing projects. Maps the EM-Team 6-phase lifecycle to Japanese software development standards (基本設計, 詳細設計, 受け入れテスト) with formal sign-off gates, weekly progress reporting, and change management."
version: "1.1.0"
category: "workflow"
triggers:
  - "Japanese outsourcing"
  - "日本向けプロジェクト"
  - "outsource Japan"
  - "日本クライアント"
  - "formal sign-off"
  - "受け入れテスト"
intent: "Deliver software projects that meet Japanese client quality standards: formally documented, traceably reviewed, and client-signed at each phase gate."
agents_used:
  - planner
  - architect
  - executor
  - verifier
skills_used:
  - project-setup
  - alignment-session
  - spec-driven-development
  - domain-modeling
  - basic-design
  - detailed-design
  - writing-plans
  - uat-process
  - progress-reporting
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Japanese Outsourcing Workflow (日本向け受託開発ワークフロー)

| EM-Team Phase | Japanese Deliverable | Gate |
|---|---|---|
| DEFINE | 要件定義 (Requirements Definition) | Gate 1: Requirements sign-off |
| PLAN | 基本設計 + 詳細設計 (Basic & Detailed Design) | Gate 2a + 2b: Design sign-off |
| BUILD | 実装 (Implementation) | Gate 3: Code review approval |
| VERIFY | テスト (Testing: System + UAT) | Gate 4: UAT sign-off |
| SHIP | リリース (Release & Delivery) | Acceptance checklist sign-off |

## Prerequisites

- [ ] Contract specifies formal sign-off requirements
- [ ] Client designated technical and PM contacts
- [ ] Communication channel agreed
- [ ] Weekly reporting cadence agreed
- [ ] Document storage location agreed

---

## Stage 1: Kickoff (プロジェクト開始)

<thought>
Observe: New Japanese outsourcing project starting — no project structure or agreements in place.
Analyze: Must initialize project directory, create all tracking documents, conduct kickoff meeting covering scope, timeline, communication, gate schedule, change management, UAT process. Gate requires project initialized, kickoff completed, gate register set up.
Plan: Initialize project structure and conduct kickoff.
</thought>

<action>
type: invoke_skill
target: project-setup
params:
  task: japanese_project_init
  documents: [PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md, WBS.md, ISSUE-REGISTER.md, CHANGE-LOG.md]
  directories: [docs/uat/, docs/detailed-design/, docs/changes/, docs/gates/, reports/progress/]
  outputs: [project_structure, kickoff_minutes, GATE-STATUS.md]
</action>

<observation>
result: Project initialized, kickoff completed, gate register created
gate_status: PASS | FAIL
</observation>

**State Snapshot:**
```yaml
workflow_state:
  current_phase: KICKOFF
  completed: []
  next_action: "REQUIREMENTS"
```

---

## Stage 2: Requirements (要件定義) → Gate 1

<thought>
Observe: Project initialized, kickoff complete.
Analyze: Must run alignment session, produce REQUIREMENTS.md with FR-*/NFR-* and acceptance criteria, run domain modeling, update WBS. Gate 1 requires client sign-off on requirements.
Plan: Invoke planner + architect agents with alignment-session, spec-driven-development, domain-modeling skills.
</thought>

<action>
type: invoke_agent
target: planner
params:
  supporting_agent: architect
  skills: [alignment-session, spec-driven-development, domain-modeling]
  task: requirements_definition
  outputs: [REQUIREMENTS.md, DOMAIN-MODEL.md, WBS.md]
</action>

<observation>
result: Requirements documented with acceptance criteria, domain model complete, WBS drafted
gate_status: PENDING (awaiting client sign-off)
</observation>

**Gate 1: Requirements Sign-Off**
- Present REQUIREMENTS.md to client
- Confirm scope boundaries
- Get written sign-off → `docs/gates/gate1-signoff.md`

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REQUIREMENTS
  completed: [KICKOFF]
  next_action: "BASIC_DESIGN after Gate 1 PASS"
```

---

## Stage 3: Basic Design (基本設計) → Gate 2a

<thought>
Observe: Requirements signed off by client.
Analyze: Must produce BASIC-DESIGN.md covering system context, architecture, ER diagram, API interfaces, NFRs, error handling. Internal review by architect + tech lead + backend expert before client presentation. Gate 2a requires client technical contact sign-off.
Plan: Invoke architect agent with basic-design, diagram, api-interface-design skills.
</thought>

<action>
type: invoke_agent
target: architect
params:
  skills: [basic-design, diagram, api-interface-design]
  task: basic_design
  internal_review: [architect, tech_lead, backend_expert]
  outputs: [BASIC-DESIGN.md]
</action>

<observation>
result: Basic design document complete, internal review passed
gate_status: PENDING (awaiting client sign-off)
</observation>

**Gate 2a: Basic Design Sign-Off**
- Present BASIC-DESIGN.md to client technical contact
- Walk through architecture, API interfaces, data model
- Get written sign-off → `docs/gates/gate2a-signoff.md`

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BASIC_DESIGN
  completed: [KICKOFF, REQUIREMENTS]
  next_action: "DETAILED_DESIGN after Gate 2a PASS"
```

---

## Stage 4: Detailed Design (詳細設計) → Gate 2b

<thought>
Observe: Basic design signed off.
Analyze: Must produce detailed design per complex module — class diagrams, function specs, data flows, exception tables, test designs. Internal review by tech lead + QA lead. Update WBS with detailed breakdown. Gate 2b requires tech lead + QA sign-off.
Plan: Invoke executor agent with detailed-design, writing-plans skills.
</thought>

<action>
type: invoke_agent
target: executor
params:
  skills: [detailed-design, writing-plans]
  task: detailed_design_per_module
  internal_review: [tech_lead, qa_lead]
  outputs: [docs/detailed-design/*.md, WBS.md_updated]
</action>

<observation>
result: Detailed designs for all modules complete, test designs included, WBS updated
gate_status: PENDING (awaiting tech lead + QA sign-off)
</observation>

**Gate 2b: Detailed Design Sign-Off**
- Tech lead and QA lead review all module designs
- Verify test designs complete (from spec, not code)
- Get written sign-off → `docs/gates/gate2b-signoff.md`

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DETAILED_DESIGN
  completed: [KICKOFF, REQUIREMENTS, BASIC_DESIGN]
  next_action: "IMPLEMENTATION after Gate 2b PASS"
```

---

## Stage 5: Implementation (実装)

<thought>
Observe: Detailed designs signed off, WBS finalized.
Analyze: Must execute WBS tasks with TDD, atomic commits referencing task IDs, daily STATE.md updates, weekly progress reports. Any scope changes go through change management — do NOT implement until CR approved.
Plan: Invoke executor agent with TDD, incremental-implementation, git-workflow skills.
</thought>

<action>
type: invoke_agent
target: executor
params:
  skills: [test-driven-development, incremental-implementation, git-workflow]
  task: implement_wbs
  weekly: progress-reporting
  change_protocol: protocols/change-management.md
  outputs: [working_code, tests, weekly_reports, CHANGE-LOG.md]
</action>

<observation>
result: WBS tasks implemented with TDD, weekly reports produced, change log maintained
gate_status: PASS | FAIL
</observation>

**Weekly Progress Reporting:**
- Run `progress-reporting` skill every agreed day
- Include: completion %, quality metrics, blockers, risks, schedule
- Client responds to Q&A within 3 business days

**State Snapshot:**
```yaml
workflow_state:
  current_phase: IMPLEMENTATION
  completed: [KICKOFF, REQUIREMENTS, BASIC_DESIGN, DETAILED_DESIGN]
  next_action: "INTERNAL_TESTING"
```

---

## Stage 6: Internal Testing (内部テスト)

<thought>
Observe: Implementation complete.
Analyze: Must run system testing against acceptance criteria, performance testing against NFRs, security audit (OWASP Top 10), fix all Critical/High defects, code review (9-axis), architecture review against BASIC-DESIGN.md. Gate 3 requires tech lead + security reviewer sign-off.
Plan: Invoke verifier, security-reviewer, code-reviewer agents.
</thought>

<action>
type: invoke_agent
target: verifier
params:
  agents: [security-reviewer, code-reviewer]
  task: internal_testing
  checks: [system_test, performance_test, security_audit, code_review_9axis, architecture_review]
  outputs: [system_test_report, security_audit_report, code_review_report]
</action>

<observation>
result: System tests pass, security audit clean, code review approved
gate_status: PENDING (awaiting sign-off)
</observation>

**Gate 3: Code Review Approval**
- Tech lead verifies: all acceptance criteria implemented, all tests passing
- Code reviewer sign-off (no Critical/High findings)
- Security reviewer sign-off
- Get written sign-off → `docs/gates/gate3-signoff.md`

**State Snapshot:**
```yaml
workflow_state:
  current_phase: INTERNAL_TESTING
  completed: [KICKOFF, REQUIREMENTS, BASIC_DESIGN, DETAILED_DESIGN, IMPLEMENTATION]
  next_action: "UAT after Gate 3 PASS"
```

---

## Stage 7: UAT (受け入れテスト) → Gate 4

<thought>
Observe: Internal testing passed, Gate 3 signed.
Analyze: Must run formal UAT — create test plan (client reviews), create numbered test cases (client reviews), execute with client tester, log results/defects, fix Critical/High defects and re-test, produce UAT completion report. Gate 4 requires 0 Critical defects open, all High resolved or risk-accepted.
Plan: Invoke executor agent with uat-process skill.
</thought>

<action>
type: invoke_skill
target: uat-process
params:
  task: formal_uat
  client_participation: required
  outputs: [uat_test_plan, uat_test_cases, execution_log, defect_log, uat_completion_report]
</action>

<observation>
result: UAT executed with client, 0 Critical defects, all High resolved
gate_status: PENDING (awaiting client sign-off)
</observation>

**Gate 4: UAT Sign-Off**
- 0 Critical defects open, all High resolved or risk-accepted
- Present UAT report to client
- Get written sign-off → `docs/gates/gate4-signoff.md`

**State Snapshot:**
```yaml
workflow_state:
  current_phase: UAT
  completed: [KICKOFF, REQUIREMENTS, BASIC_DESIGN, DETAILED_DESIGN, IMPLEMENTATION, INTERNAL_TESTING]
  next_action: "DELIVERY after Gate 4 PASS"
```

---

## Stage 8: Delivery & Deployment (納品・リリース)

<thought>
Observe: UAT signed off, all gates passed.
Analyze: Must complete ACCEPTANCE-CHECKLIST.md, prepare delivery package (source, docs, test results, release notes, deployment guide), deploy if in scope, monitor 24h, get final acceptance signature.
Plan: Invoke executor agent with ship-workflow, documentation skills.
</thought>

<action>
type: invoke_agent
target: executor
params:
  skills: [ship-workflow, documentation, ci-cd-automation]
  task: deliver_and_deploy
  outputs: [ACCEPTANCE-CHECKLIST.md, delivery_package, deployment, acceptance_signature]
</action>

<observation>
result: Delivery package prepared, deployed, client signed acceptance checklist
gate_status: PASS | FAIL
</observation>

**Final Delivery:** Send formal notification with features delivered, UAT result, delivery package location, support contact.

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DELIVERY
  completed: [KICKOFF, REQUIREMENTS, BASIC_DESIGN, DETAILED_DESIGN, IMPLEMENTATION, INTERNAL_TESTING, UAT]
  next_action: "POST_DELIVERY_SUPPORT"
```

---

## Stage 9: Post-Delivery Support (アフターサポート)

<thought>
Observe: Delivery accepted, support period active.
Analyze: Must respond to issues within agreed SLA, log production defects, provide warranty fixes at no charge, route enhancement requests through CR process, conduct knowledge transfer if agreed.
Plan: Support per contract terms.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: post_delivery_support
  sla: per_contract
  outputs: [issue_responses, warranty_fixes, knowledge_transfer]
</action>

<observation>
result: Support period complete, all issues resolved, handoff confirmed
gate_status: PASS | FAIL
</observation>

**Completion Marker:** **JAPANESE_OUTSOURCING_WORKFLOW_COMPLETE**

**State Snapshot:**
```yaml
workflow_state:
  current_phase: POST_DELIVERY
  completed: [KICKOFF, REQUIREMENTS, BASIC_DESIGN, DETAILED_DESIGN, IMPLEMENTATION, INTERNAL_TESTING, UAT, DELIVERY]
  next_action: "DONE"
```

---

## Document Register (ドキュメント一覧)

| Document | Location | Stage | Sign-off |
|---|---|---|---|
| REQUIREMENTS.md | Root | Stage 2 | Gate 1 |
| BASIC-DESIGN.md | docs/ | Stage 3 | Gate 2a |
| Detailed Design | docs/detailed-design/ | Stage 4 | Gate 2b |
| System Test Report | docs/uat/ | Stage 6 | Gate 3 |
| UAT Sign-off | docs/uat/ | Stage 7 | Gate 4 |
| ACCEPTANCE-CHECKLIST.md | docs/ | Stage 8 | Final |

## Communication Cadence

| Event | Frequency | Owner |
|---|---|---|
| Weekly Progress Report | Every agreed day | PM |
| Gate Reviews | At each gate | PM + Tech Lead |
| Escalation | When RED status | PM (same-day) |
| Change Request response | Within 3 business days | PM |

## Risk Mitigations

| Risk | Mitigation |
|---|---|
| Scope creep | Change management protocol (every change needs CR) |
| Design disputes | Gates 2a + 2b: client sign-off before coding |
| Late defect discovery | Gate 3 blocks staging; Gate 4 blocks delivery |
| "I never agreed to that" | Written sign-off at every gate |
| Poor communication | Weekly reports + response SLA |

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

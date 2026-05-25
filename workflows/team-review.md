---
name: team-review
description: Full team review orchestrated by Team Lead agent
version: "2.1.0"
category: "team"
origin: "agent-skills"
agents_used:
  - team-lead
  - product-manager
  - architect
  - database-expert
  - frontend-expert
  - senior-code-reviewer
  - security-reviewer
  - staff-engineer
skills_used:
  - code-review
  - security-audit
  - documentation
  - performance-optimization
related_skills:
  - code-review
  - security-audit
estimated_time: "4-8 hours (standard) / 1-2 days (comprehensive)"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Team Review Workflow

```
SCOPE → BUSINESS → ARCHITECTURE → SPECIALIZED → SECURITY → DEEP → CONSOLIDATION
  1        2            3              4             5        6          7
```

---

### Stage 1: Scope Analysis

<thought>
Observe: Task/feature submitted for team review — no scope analysis yet.
Analyze: Must analyze task scope, identify affected components, assess risk, select agents. Gate requires scope defined, risk assessed, agents selected.
Plan: Invoke team-lead agent.
</thought>

<action>
type: invoke_agent
target: team-lead
params:
  task: analyze_scope
  outputs: [task_analysis, agent_selection, review_scope]
</action>

<observation>
result: Scope defined, risk assessed, required agents identified
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Scope clearly defined
- [ ] Risk level assessed
- [ ] Required agents identified

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SCOPE
  completed: []
  next_action: "BUSINESS"
```

---

### Stage 2: Business Validation

<thought>
Observe: Scope analyzed, agents selected.
Analyze: Must validate specs from business perspective — GAP analysis, acceptance criteria, ROI. Gate requires business value validated, market fit assessed, no business blockers.
Plan: Invoke product-manager agent.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  task: business_validation
  outputs: [pm_review_report, gap_analysis, acceptance_criteria_review]
</action>

<observation>
result: Business value validated, acceptance criteria reviewed, no blockers
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Business value validated
- [ ] Market fit assessed
- [ ] Acceptance criteria reviewed
- [ ] No business blockers

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BUSINESS
  completed: [SCOPE]
  next_action: "ARCHITECTURE"
```

---

### Stage 3: Architecture Review

<thought>
Observe: Business validation passed.
Analyze: Must review technical architecture — patterns, scalability, ADRs, integration points. Gate requires architecture principles validated, patterns confirmed, scalability assessed.
Plan: Invoke architect agent.
</thought>

<action>
type: invoke_agent
target: architect
params:
  task: architecture_review
  outputs: [architecture_report]
</action>

<observation>
result: Architecture principles validated, patterns appropriate, scalability assessed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Architecture principles validated
- [ ] Pattern appropriateness confirmed
- [ ] Scalability assessed
- [ ] Integration points reviewed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ARCHITECTURE
  completed: [SCOPE, BUSINESS]
  next_action: "SPECIALIZED"
```

---

### Stage 4: Specialized Reviews (Parallel)

<thought>
Observe: Architecture review passed.
Analyze: Must run parallel specialized reviews — database (schema, queries, migration), frontend (UI/UX, performance, accessibility), code (9-axis). Not all may apply. Gate requires applicable reviews completed.
Plan: Invoke database-expert, frontend-expert, senior-code-reviewer in parallel.
</thought>

<action>
type: invoke_agent
target: [database-expert, frontend-expert, senior-code-reviewer]
params:
  execution: parallel
  tasks:
    database: [schema_review, query_optimization, migration_review]
    frontend: [ui_ux_review, performance_audit, accessibility_audit]
    code: [9_axis_review, severity_classification]
  outputs: [db_review, fe_review, code_review]
</action>

<observation>
result: Applicable specialized reviews completed with findings
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Schema design validated (if applicable)
- [ ] UI/UX reviewed (if applicable)
- [ ] All 9 axes reviewed (if applicable)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SPECIALIZED
  completed: [SCOPE, BUSINESS, ARCHITECTURE]
  next_action: "SECURITY"
```

---

### Stage 5: Security Review

<thought>
Observe: Specialized reviews completed.
Analyze: Must perform OWASP Top 10 assessment, STRIDE threat modeling, exercise blocking authority for CRITICAL/HIGH issues. Gate requires OWASP complete, STRIDE done, blocking issues identified.
Plan: Invoke security-reviewer agent.
</thought>

<action>
type: invoke_agent
target: security-reviewer
params:
  task: security_review
  blocking_authority: true
  outputs: [security_report, owasp_assessment, stride_model, blocking_issues]
</action>

<observation>
result: OWASP assessment complete, STRIDE done, security scorecard complete
gate_status: PASS | FAIL
</observation>

**BLOCKING:** Critical/High security issues MUST be fixed before proceeding.

**Quality Gate:**
- [ ] OWASP assessment complete
- [ ] STRIDE modeling done
- [ ] Blocking issues identified
- [ ] Security scorecard complete

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SECURITY
  completed: [SCOPE, BUSINESS, ARCHITECTURE, SPECIALIZED]
  next_action: "DEEP or CONSOLIDATION"
```

---

### Stage 6: Deep Investigation (if needed)

<thought>
Observe: Reviews complete, complex issues or architectural concerns identified.
Analyze: Must perform root cause analysis, cross-service impact analysis, performance deep dive. Triggered by complex issues found in earlier stages.
Plan: Invoke staff-engineer agent.
</thought>

<action>
type: invoke_agent
target: staff-engineer
params:
  task: deep_investigation
  trigger: complex_issues_found
  outputs: [root_cause, cross_service_impact, dependency_map, recommendations]
</action>

<observation>
result: Root cause identified, cross-service impact analyzed, recommendations provided
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Root cause identified
- [ ] Cross-service impact analyzed
- [ ] Dependencies mapped
- [ ] Recommendations provided

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEEP_INVESTIGATION
  completed: [SCOPE, BUSINESS, ARCHITECTURE, SPECIALIZED, SECURITY]
  next_action: "CONSOLIDATION"
```

---

### Stage 7: Consolidation

<thought>
Observe: All agent reports collected.
Analyze: Must consolidate findings, synthesize recommendations, make final decision (APPROVED/CONDITIONAL/REJECTED), define next steps.
Plan: Invoke team-lead agent.
</thought>

<action>
type: invoke_agent
target: team-lead
params:
  task: consolidate_reviews
  input: all_agent_reports
  outputs: [consolidated_report, decision, next_steps]
</action>

<observation>
result: Findings consolidated, decision made, next steps defined
gate_status: PASS | FAIL
</observation>

**Completion Marker:** ## TEAM_LEAD_CONSOLIDATION_COMPLETE

**Quality Gate:**
- [ ] All reports collected
- [ ] Findings consolidated
- [ ] Decision made (APPROVED/CONDITIONAL/REJECTED)
- [ ] Next steps defined and actionable

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONSOLIDATION
  completed: [SCOPE, BUSINESS, ARCHITECTURE, SPECIALIZED, SECURITY, DEEP_INVESTIGATION]
  next_action: "DONE"
```

---

## Revision Loop

Max 3 iterations. If issues persist after 3 iterations, escalate to Team Lead for binding decision.

```yaml
iteration_limit: 3
escalation_trigger: "After 3 iterations without resolution"
escalation_target: "Team Lead"
final_authority: "Team Lead decision is binding"
```

## Blocking Authority

| Agent | Trigger | Action |
|---|---|---|
| Security Reviewer | SQL injection, auth bypass, data exposure, RCE | BLOCK |
| Product Manager | No market fit, regulatory issues | BLOCK |
| Product Manager | Gap too large | CONDITIONAL |
| Staff Engineer | Fundamental design flaw | BLOCK |
| Staff Engineer | Scalability risk | CONDITIONAL |

## Conflict Resolution

- **Security vs Performance:** Security takes priority
- **Speed vs Quality:** Quality takes priority
- **Simplicity vs Scalability:** Context-dependent (MVP → Simplicity, Production → Scalability)

## Handoff Contracts

### Team Lead → Product Manager
```yaml
provides: [task_description, business_context, user_stories]
expects: [business_validation, gap_analysis, acceptance_criteria_review]
```

### Product Manager → Architect
```yaml
provides: [business_requirements, success_metrics, constraints]
expects: [technical_feasibility, architecture_options]
```

### Architect → Specialized Agents
```yaml
provides: [architecture_decisions, api_contracts, data_models]
expects: [specialized_reviews, impact_assessments]
```

### All Agents → Security Reviewer
```yaml
provides: [code_artifacts, architecture_diagrams, infrastructure_config]
expects: [owasp_review, stride_analysis, blocking_issues]
```

### All Agents → Team Lead
```yaml
provides: [individual_reports, findings, recommendations]
expects: [consolidation, decision, next_steps]
```

## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |
| `AGENT_TIMEOUT` | Review agent exceeds time limit | Collect partial output, retry with narrower scope | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

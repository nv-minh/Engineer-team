---
name: incident-response
description: Production incident handling with Staff Engineer and Security Reviewer agents
version: "2.1.0"
category: "team"
origin: "agent-skills"
agents_used:
  - staff-engineer
  - security-reviewer
skills_used:
  - systematic-debugging
  - security-audit
  - performance-optimization
  - documentation
related_skills:
  - systematic-debugging
  - security-audit
estimated_time: "2-8 hours"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Incident Response Workflow

```
TRIAGE → SECURITY → ROOT CAUSE → IMPACT → RESOLUTION → POSTMORTEM
   1        2           3           4          5            6
```

## Modular Components

- **Stage 1:** [Initial Triage](workflows/incident/initial-triage.md)
- **Stage 2:** [Security Investigation](workflows/incident/security-investigation.md)
- **Stage 3:** [Root Cause Analysis](workflows/incident/root-cause-analysis.md)
- **Stage 4:** [Cross-Service Impact](workflows/incident/cross-service-impact.md)
- **Stage 5:** [Resolution & Verification](workflows/incident/resolution-verification.md)
- **Stage 6:** [Postmortem & Prevention](workflows/incident/postmortem-prevention.md)

---

### Stage 1: Initial Assessment & Triage

<thought>
Observe: Incident report received — monitoring alerts, user reports, or system failures detected.
Analyze: Must assess severity (P0-P3), identify scope (affected services, users), gather initial data. Gate requires severity assessed, scope identified, initial data gathered.
Plan: Invoke staff-engineer agent with systematic-debugging skill.
</thought>

<action>
type: invoke_agent
target: staff-engineer
params:
  task: initial_triage
  input: [incident_report, monitoring_data, logs, alerts]
  outputs: [severity_assessment, scope_analysis, initial_data]
</action>

<observation>
result: Severity assessed (P0-P3), scope identified, initial data gathered
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Severity assessed accurately (P0-P3)
- [ ] Scope identified (affected services, users)
- [ ] Initial data gathered (alerts, monitoring)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: TRIAGE
  completed: []
  next_action: "SECURITY if security-related, else ROOT_CAUSE"
```

---

### Stage 2: Security Investigation (if applicable)

<thought>
Observe: Triage complete, potential security concerns identified.
Analyze: Must investigate security breach, assess data exposure, review unauthorized access. Gate requires security investigation completed.
Plan: Invoke security-reviewer agent.
</thought>

<action>
type: invoke_agent
target: security-reviewer
params:
  task: security_investigation
  input: [incident_details, timeline, system_state]
  outputs: [security_assessment, breach_assessment, data_exposure_review]
</action>

<observation>
result: Security investigation complete, breach/exposure assessed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Security assessment complete
- [ ] Breach confirmed or ruled out
- [ ] Data exposure reviewed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SECURITY
  completed: [TRIAGE]
  next_action: "ROOT_CAUSE"
```

---

### Stage 3: Root Cause Analysis

<thought>
Observe: Triage and security investigation complete.
Analyze: Must identify root cause via 5 Whys or Fishbone method, reconstruct timeline, identify contributing factors. Gate requires root cause identified, timeline reconstructed.
Plan: Invoke staff-engineer agent with systematic-debugging skill.
</thought>

<action>
type: invoke_agent
target: staff-engineer
params:
  task: root_cause_analysis
  method: [five_whys, fishbone]
  outputs: [root_cause, timeline, contributing_factors]
</action>

<observation>
result: Root cause identified, timeline reconstructed, contributing factors documented
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Root cause identified via 5 Whys or Fishbone
- [ ] Timeline reconstructed
- [ ] Contributing factors documented

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ROOT_CAUSE
  completed: [TRIAGE, SECURITY]
  next_action: "IMPACT"
```

---

### Stage 4: Cross-Service Impact Analysis

<thought>
Observe: Root cause identified.
Analyze: Must analyze cross-service impact (direct and indirect), verify dependency health, check for regressions. Gate requires impact analyzed, dependencies verified.
Plan: Invoke staff-engineer agent.
</thought>

<action>
type: invoke_agent
target: staff-engineer
params:
  task: cross_service_impact
  outputs: [direct_impact, indirect_impact, dependency_health]
</action>

<observation>
result: Cross-service impact analyzed, dependencies verified, no hidden regressions
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Cross-service impact analyzed
- [ ] Dependency health verified
- [ ] No regressions detected

**State Snapshot:**
```yaml
workflow_state:
  current_phase: IMPACT
  completed: [TRIAGE, SECURITY, ROOT_CAUSE]
  next_action: "RESOLUTION"
```

---

### Stage 5: Resolution & Verification

<thought>
Observe: Root cause identified, impact analyzed.
Analyze: Must implement fix (or temporary workaround), verify the fix works, confirm no regressions.
Plan: Invoke staff-engineer + security-reviewer agents.
</thought>

<action>
type: invoke_agent
target: staff-engineer
params:
  supporting_agent: security-reviewer
  task: resolve_and_verify
  outputs: [fix_implemented, verification_confirmed]
</action>

<observation>
result: Fix implemented, verified working, no regressions
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Fix implemented
- [ ] Temporary workarounds applied (if needed)
- [ ] Verification confirmed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: RESOLUTION
  completed: [TRIAGE, SECURITY, ROOT_CAUSE, IMPACT]
  next_action: "POSTMORTEM"
```

---

### Stage 6: Postmortem & Prevention

<thought>
Observe: Incident resolved and verified.
Analyze: Must complete blameless postmortem, create action items with owners and deadlines, document lessons learned, define prevention measures. Gate requires postmortem complete, actions assigned, follow-up scheduled.
Plan: Invoke staff-engineer + security-reviewer agents.
</thought>

<action>
type: invoke_agent
target: staff-engineer
params:
  supporting_agent: security-reviewer
  task: postmortem_and_prevention
  outputs: [postmortem_report, action_items, lessons_learned, prevention_measures]
</action>

<observation>
result: Blameless postmortem complete, action items assigned, prevention defined
gate_status: PASS | FAIL
</observation>

**Completion Marker:** ## INCIDENT_RESPONSE_COMPLETE

**Quality Gate:**
- [ ] Blameless postmortem completed
- [ ] Action items created with owners and dates
- [ ] Lessons learned documented
- [ ] Prevention measures defined
- [ ] Follow-up scheduled

**State Snapshot:**
```yaml
workflow_state:
  current_phase: POSTMORTEM
  completed: [TRIAGE, SECURITY, ROOT_CAUSE, IMPACT, RESOLUTION]
  next_action: "DONE"
```

---

## Severity Levels

| Level | Definition | Response Time |
|---|---|---|
| P0 | Complete outage, data loss, security breach, revenue > $10K/hr | Immediate / 15min / 1hr |
| P1 | Significant degradation, major feature broken | 5min / 30min / 4hr |
| P2 | Minor degradation, single feature broken | 15min / 1hr / 1 day |
| P3 | Cosmetic, no user impact | 1hr / 1 day / 1 week |

## Handoff Contracts

### To Staff Engineer
```yaml
provides: [incident_report, monitoring_data, logs, alerts, user_reports]
expects: [severity_assessment, root_cause_analysis, cross_service_impact, resolution_plan, postmortem]
```

### Staff Engineer → Security Reviewer
```yaml
provides: [incident_details, timeline, system_state, potential_security_concerns]
expects: [security_investigation, breach_assessment, data_exposure_review, security_recommendations]
```

## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |
| `ESCALATION_REQUIRED` | Severity exceeds responder authority | Escalate to next-level oncall | No |
| `ROOT_CAUSE_UNCONFIRMED` | Hypothesis lacks evidence | Gather more data, expand scope | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

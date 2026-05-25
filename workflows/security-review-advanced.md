---
name: security-review-advanced
description: Advanced security review with Security Reviewer and Staff Engineer agents (OWASP + STRIDE)
version: "2.1.0"
category: "team"
origin: "agent-skills"
agents_used:
  - security-reviewer
  - staff-engineer
skills_used:
  - security-audit
  - security-hardening
  - code-review
  - systematic-debugging
related_skills:
  - security-audit
  - security-hardening
estimated_time: "4-8 hours"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Security Review (Advanced) Workflow

```
OWASP ASSESSMENT → STRIDE THREAT MODEL → DEEP INVESTIGATION → CONSOLIDATION
       1                   2                     3                   4
```

## Modular Components

- **Stage 1:** [OWASP Assessment](workflows/security/owasp-assessment.md)
- **Stage 2:** [STRIDE Threat Modeling](workflows/security/stride-threat-modeling.md)
- **Stage 3:** [Deep Investigation](workflows/security/deep-investigation.md)
- **Stage 4:** Consolidation

---

### Stage 1: OWASP Assessment

<thought>
Observe: Code artifacts, architecture diagrams, infrastructure config, compliance requirements available.
Analyze: Must review all OWASP Top 10 categories (A01-A10), classify findings by severity, flag blocking issues. Gate requires all categories reviewed, findings classified, blocking issues flagged.
Plan: Invoke security-reviewer agent with security-audit skill.
</thought>

<action>
type: invoke_agent
target: security-reviewer
params:
  task: owasp_assessment
  input: [code_artifacts, architecture_diagrams, infrastructure_config]
  categories: [A01_access_control, A02_crypto, A03_injection, A04_insecure_design, A05_misconfiguration, A06_vulnerable_components, A07_auth_failures, A08_integrity_failures, A09_logging_failures, A10_ssrf]
  outputs: [owasp_report, findings, blocking_issues]
</action>

<observation>
result: All OWASP Top 10 categories reviewed, findings classified, blocking issues flagged
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] All OWASP Top 10 categories reviewed
- [ ] Findings classified by severity
- [ ] Blocking issues flagged

**State Snapshot:**
```yaml
workflow_state:
  current_phase: OWASP
  completed: []
  next_action: "STRIDE"
```

---

### Stage 2: STRIDE Threat Modeling

<thought>
Observe: OWASP assessment complete with findings.
Analyze: Must perform STRIDE threat modeling (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege) per component. Define mitigations. Gate requires STRIDE model complete, threats identified, mitigations defined.
Plan: Invoke security-reviewer + staff-engineer agents.
</thought>

<action>
type: invoke_agent
target: security-reviewer
params:
  supporting_agent: staff-engineer
  task: stride_threat_modeling
  input: [owasp_report, architecture_diagrams]
  stride: [spoofing, tampering, repudiation, information_disclosure, denial_of_service, elevation_of_privilege]
  outputs: [stride_model, threat_matrix, mitigations]
</action>

<observation>
result: STRIDE threat model complete, threats identified per component, mitigations defined
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] STRIDE threat model completed
- [ ] Threats identified for each component
- [ ] Mitigations defined

**State Snapshot:**
```yaml
workflow_state:
  current_phase: STRIDE
  completed: [OWASP]
  next_action: "DEEP_INVESTIGATION"
```

---

### Stage 3: Deep Investigation

<thought>
Observe: OWASP and STRIDE assessments complete.
Analyze: Must analyze cross-service impact, assess dependencies, evaluate infrastructure, review supply chain. Gate requires cross-service analyzed, dependencies assessed, infrastructure evaluated.
Plan: Invoke staff-engineer agent.
</thought>

<action>
type: invoke_agent
target: staff-engineer
params:
  task: deep_security_investigation
  input: [owasp_report, stride_model]
  outputs: [cross_service_impact, dependency_analysis, infrastructure_assessment, supply_chain_review]
</action>

<observation>
result: Cross-service impact analyzed, dependencies assessed, infrastructure evaluated
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Cross-service impact analyzed
- [ ] Dependencies assessed
- [ ] Infrastructure evaluated
- [ ] Supply chain reviewed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEEP_INVESTIGATION
  completed: [OWASP, STRIDE]
  next_action: "CONSOLIDATION"
```

---

### Stage 4: Consolidation

<thought>
Observe: All security assessments complete.
Analyze: Must consolidate all findings, complete security scorecard, apply severity classification, make decision (BLOCKED/CONDITIONAL/APPROVED).
Plan: Invoke security-reviewer + staff-engineer for consolidation.
</thought>

<action>
type: invoke_agent
target: security-reviewer
params:
  supporting_agent: staff-engineer
  task: consolidate_security_review
  input: [owasp_report, stride_model, deep_investigation]
  outputs: [consolidated_report, security_scorecard, decision]
</action>

<observation>
result: Findings consolidated, scorecard completed, decision documented
gate_status: PASS | FAIL
</observation>

**Completion Marker:** ## SECURITY_REVIEW_ADVANCED_COMPLETE

**Quality Gate:**
- [ ] All findings consolidated
- [ ] Security scorecard completed
- [ ] Severity classification applied
- [ ] Decision documented (BLOCKED/CONDITIONAL/APPROVED)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONSOLIDATION
  completed: [OWASP, STRIDE, DEEP_INVESTIGATION]
  next_action: "DONE"
```

---

## Blocking Authority

| Level | Examples | Action |
|---|---|---|
| CRITICAL | SQL injection, auth bypass, data exposure, RCE, hardcoded secrets | BLOCKS Deployment |
| HIGH | XSS, weak password hashing, missing authorization, CSRF, known vulnerable deps | BLOCKS Merge |

## Handoff Contracts

### To Security Reviewer
```yaml
provides: [code_artifacts, architecture_diagrams, infrastructure_config, compliance_requirements]
expects: [owasp_review, stride_analysis, blocking_issues, security_scorecard]
```

### Security Reviewer → Staff Engineer
```yaml
provides: [owasp_findings, threat_model, security_vulnerabilities, blocking_issues]
expects: [cross_service_impact, dependency_analysis, supply_chain_review, infrastructure_assessment]
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

---
name: security-audit
description: Security audit workflow for vulnerability assessment and remediation
version: "2.1.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - security-reviewer
  - executor
skills_used:
  - security-audit
  - security-hardening
  - code-review
  - test-driven-development
  - documentation
related_skills:
  - security-hardening
  - security-common
estimated_time: "1-2 days (simple) / 3-7 days (complex)"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Security Audit Workflow

```
SCAN → ANALYZE → REMEDIATE → VERIFY → DOCUMENT
  1        2           3         4         5
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase |
|---|---|
| SCAN (Stage 1) | DEFINE |
| ANALYZE (Stage 2) | PLAN |
| REMEDIATE (Stage 3) | BUILD |
| VERIFY (Stage 4) | VERIFY |
| DOCUMENT (Stage 5) | REVIEW + SHIP |

---

### Stage 1: SCAN

<thought>
Observe: Codebase needs security assessment — no current vulnerability inventory.
Analyze: Must run automated scans, identify vulnerabilities, assign risk levels. Gate requires scans complete, vulnerabilities identified, risk levels assigned.
Plan: Invoke security-reviewer agent (audit mode) with security-audit skill.
</thought>

<action>
type: invoke_agent
target: security-reviewer
params:
  mode: audit
  task: automated_security_scan
  outputs: [scan_results, vulnerability_list, risk_levels]
</action>

<observation>
result: Automated scans complete, vulnerabilities identified with risk levels
gate_status: PASS | FAIL
</observation>

**Gate 1: Definition Complete**
- [ ] Automated scans complete
- [ ] Vulnerabilities identified
- [ ] Risk levels assigned

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SCAN
  completed: []
  next_action: "ANALYZE if gate passes"
```

---

### Stage 2: ANALYZE

<thought>
Observe: Scan results available with vulnerability list and risk levels.
Analyze: Must analyze each vulnerability for impact, create remediation plan prioritized by severity. Gate requires vulnerabilities analyzed, impact assessed, remediation planned.
Plan: Invoke security-reviewer agent (audit mode) to assess and prioritize.
</thought>

<action>
type: invoke_agent
target: security-reviewer
params:
  mode: audit
  task: vulnerability_analysis
  input: scan_results
  outputs: [vulnerability_analysis, remediation_plan, prioritized_fixes]
</action>

<observation>
result: Vulnerabilities analyzed, impact assessed, remediation plan created
gate_status: PASS | FAIL
</observation>

**Gate 2: Plan Complete**
- [ ] Vulnerabilities analyzed
- [ ] Impact assessed
- [ ] Remediation planned

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ANALYZE
  completed: [SCAN]
  next_action: "REMEDIATE if gate passes"
```

---

### Stage 3: REMEDIATE

<thought>
Observe: Vulnerability analysis complete, remediation plan prioritized.
Analyze: Must fix critical and high vulnerabilities, add security tests. Gate requires critical fixed, high fixed, tests added, all tests pass.
Plan: Invoke executor agent with security-hardening skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: fix_vulnerabilities
  input: remediation_plan
  priority: [critical, high]
  outputs: [vulnerabilities_fixed, security_tests_added]
</action>

<observation>
result: Critical and high vulnerabilities fixed, security tests added
gate_status: PASS | FAIL
</observation>

**Gate 3: Build Complete**
- [ ] Critical vulnerabilities fixed
- [ ] High vulnerabilities fixed
- [ ] Tests added
- [ ] All tests pass

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REMEDIATE
  completed: [SCAN, ANALYZE]
  next_action: "VERIFY if gate passes"
```

---

### Stage 4: VERIFY

<thought>
Observe: Critical and high vulnerabilities fixed, security tests added.
Analyze: Must confirm no critical/high vulnerabilities remain, check compliance, verify no regressions.
Plan: Invoke security-reviewer agent (audit mode) to re-scan and verify.
</thought>

<action>
type: invoke_agent
target: security-reviewer
params:
  mode: audit
  task: verification_scan
  outputs: [verification_results, compliance_status]
</action>

<observation>
result: No critical/high vulnerabilities remain, compliance met
gate_status: PASS | FAIL
</observation>

**Gate 4: Verification Complete**
- [ ] No critical vulnerabilities
- [ ] No high vulnerabilities
- [ ] Compliance met
- [ ] Regressions checked

**State Snapshot:**
```yaml
workflow_state:
  current_phase: VERIFY
  completed: [SCAN, ANALYZE, REMEDIATE]
  next_action: "DOCUMENT if gate passes"
```

---

### Stage 5: DOCUMENT

<thought>
Observe: Verification confirms no critical/high vulnerabilities, compliance met.
Analyze: Must document all findings and fixes, generate report, notify team.
Plan: Invoke executor agent with documentation skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: document_security_audit
  outputs: [findings_doc, fixes_doc, audit_report]
</action>

<observation>
result: Findings documented, fixes documented, audit report complete, team notified
gate_status: PASS | FAIL
</observation>

**Gate 5: Review Complete**
- [ ] Findings documented
- [ ] Fixes documented
- [ ] Report complete
- [ ] Team notified

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DOCUMENT
  completed: [SCAN, ANALYZE, REMEDIATE, VERIFY]
  next_action: "DONE"
```

---

## Handoff Contracts

### Scan → Analyze
```yaml
handoff:
  from: security-reviewer
  to: security-reviewer
  provides: [scan_results, vulnerabilities]
  expects: [vulnerability_analysis, prioritized_fixes]
```

### Analyze → Remediate
```yaml
handoff:
  from: security-reviewer
  to: executor
  provides: [vulnerability_analysis, remediation_plan]
  expects: [vulnerabilities_fixed, tests_added]
```

### Remediate → Verify
```yaml
handoff:
  from: executor
  to: security-reviewer
  provides: [fixes, test_results]
  expects: [verification_results, compliance_status]
```

## Error Handling

| Error Type | Trigger | Recovery |
|---|---|---|
| `SCAN_INCOMPLETE` | Automated scanner fails to complete or times out | Retry with reduced scope (single directory or single OWASP category). Do not proceed to ANALYZE with partial results — document coverage gap. |
| `FIX_INTRODUCES_VULNERABILITY` | Remediation of one vulnerability creates a new one | STOP. Roll back fix. Invoke `systematic-debugging` to understand the interaction. Fix both vulnerabilities atomically. |
| `TEST_ENV_FAILURE` | Security test tooling fails with infrastructure error | Infrastructure failures do NOT consume `max_retries`. Fix environment, retry stage fresh. |
| `CONTEXT_OVERFLOW` | Claude signals loss of earlier stage outputs mid-workflow | Run context pruning immediately. Re-read vulnerability list and gate status. Resume from last completed gate. |

---

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

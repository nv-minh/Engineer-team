---
name: code-review-9axis
description: Deep code review using 9-axis framework with Code Reviewer (Deep mode) and Security Reviewer
version: "2.2.0"
category: "team"
origin: "agent-skills"
agents_used:
  - code-reviewer
  - security-reviewer
skills_used:
  - code-review
  - security-audit
  - performance-optimization
  - code-simplification
related_skills:
  - code-review
  - security-audit
  - code-simplification
estimated_time: "2-6 hours"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Code Review (9-Axis) Workflow

```
9-AXIS CODE REVIEW → SECURITY ASSESSMENT → CONSOLIDATED REPORT
        1                    2                     3
```

---

### Stage 1: 9-Axis Code Review

<thought>
Observe: Code diff / PR available with commit history and context.
Analyze: Must review all 9 axes: correctness, readability, architecture, security, performance, testing, maintainability, scalability, documentation. Classify findings by severity, calculate scores. Gate requires all 9 axes reviewed, findings classified, scores calculated.
Plan: Invoke code-reviewer agent in Deep mode.
</thought>

<action>
type: invoke_agent
target: code-reviewer
params:
  mode: deep_9axis
  input: [code_diff, commit_history, related_docs]
  axes: [correctness, readability, architecture, security, performance, testing, maintainability, scalability, documentation]
  outputs: [9axis_review_report, severity_table, scores]
</action>

<observation>
result: All 9 axes reviewed, findings classified, scores calculated
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] All 9 axes reviewed
- [ ] Findings classified by severity
- [ ] Scores calculated for each axis
- [ ] Overall score determined

**State Snapshot:**
```yaml
workflow_state:
  current_phase: 9AXIS_REVIEW
  completed: []
  next_action: "SECURITY_ASSESSMENT"
```

---

### Stage 2: Security Vulnerability Assessment

<thought>
Observe: 9-axis review complete with security-related findings flagged.
Analyze: Must perform OWASP Top 10 assessment, identify vulnerabilities, classify severity, exercise blocking authority for CRITICAL/HIGH. Gate requires OWASP assessed, vulnerabilities identified, blocking issues flagged.
Plan: Invoke security-reviewer agent.
</thought>

<action>
type: invoke_agent
target: security-reviewer
params:
  task: vulnerability_assessment
  input: [code_artifacts, code_review_findings]
  blocking_authority: true
  outputs: [security_report, owasp_assessment, blocking_issues]
</action>

<observation>
result: OWASP categories assessed, vulnerabilities identified, blocking issues flagged
gate_status: PASS | FAIL
</observation>

**BLOCKING:** CRITICAL/HIGH security issues MUST be fixed.

**Quality Gate:**
- [ ] OWASP categories assessed
- [ ] Vulnerabilities identified
- [ ] Severity classification applied
- [ ] Blocking issues flagged

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SECURITY_ASSESSMENT
  completed: [9AXIS_REVIEW]
  next_action: "CONSOLIDATED_REPORT"
```

---

### Stage 3: Consolidated Code Quality Report

<thought>
Observe: 9-axis review and security assessment complete.
Analyze: Must merge findings, prioritize by combined severity, create actionable recommendations, make decision (APPROVED/CONDITIONAL/REJECTED). Gate requires all findings merged, recommendations actionable, decision justified.
Plan: Invoke code-reviewer + security-reviewer for consolidation.
</thought>

<action>
type: invoke_agent
target: code-reviewer
params:
  supporting_agent: security-reviewer
  task: consolidate_code_quality
  input: [9axis_review_report, security_report]
  outputs: [consolidated_report, prioritized_findings, decision]
</action>

<observation>
result: Findings merged, prioritized, recommendations actionable, decision documented
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] All findings merged
- [ ] Prioritized by impact
- [ ] Recommendations actionable
- [ ] Decision justified (APPROVED/CONDITIONAL/REJECTED)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONSOLIDATED_REPORT
  completed: [9AXIS_REVIEW, SECURITY_ASSESSMENT]
  next_action: "DONE"
```

---

## 9-Axis Framework

| Axis | Question |
|---|---|
| 1. Correctness | Does the code do what it's supposed to do? |
| 2. Readability | Is the code easy to understand? |
| 3. Architecture | Does it fit the system architecture? |
| 4. Security | Are there security vulnerabilities? |
| 5. Performance | Are there performance issues? |
| 6. Testing | Is the code adequately tested? |
| 7. Maintainability | Is the code easy to maintain? |
| 8. Scalability | Can the code handle growth? |
| 9. Documentation | Is the code well documented? |

## Severity Classification

| Level | Impact |
|---|---|
| Critical | BLOCKS Deployment — security vulnerability, data loss, outage risk |
| High | BLOCKS Merge — user-facing bug, performance regression, accessibility violation |
| Medium | Fix Before Next Release — code smell, minor perf, missing docs |
| Low | Nice to Have — style, naming, optimization opportunity |

## Handoff Contracts

### To Code Reviewer
```yaml
provides: [code_diff, pr_url, review_scope, context]
expects: [9_axis_review, severity_table, quantitative_scores, actionable_feedback]
```

### Code Reviewer → Security Reviewer
```yaml
provides: [code_review_findings, security_related_issues, severity_classification]
expects: [deep_security_analysis, owasp_assessment, vulnerability_details, blocking_issues]
```

### Security Reviewer → Consolidation
```yaml
provides: [security_findings, vulnerability_report, blocking_issues]
expects: [consolidation, final_recommendations, decision]
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

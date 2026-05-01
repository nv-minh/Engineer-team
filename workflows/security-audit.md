---
name: security-audit
description: Security audit workflow for vulnerability assessment and remediation
version: "2.0.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - security-auditor
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
---

# Security Audit Workflow

## Overview

The security audit workflow performs comprehensive security assessment, identifies vulnerabilities, and implements fixes following OWASP standards.

## When to Use

- Auditing code for security
- Checking for vulnerabilities
- Ensuring compliance
- Before production deployment
- After security incidents

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Description |
|---|---|---|
| SCAN (Stage 1) | DEFINE | Run automated scans, identify vulnerabilities, assign risk levels |
| ANALYZE (Stage 2) | PLAN | Analyze vulnerabilities, assess impact, create remediation plan |
| REMEDIATE (Stage 3) | BUILD | Fix critical/high vulnerabilities, add security tests |
| VERIFY (Stage 4) | VERIFY | Confirm no critical/high vulnerabilities remain, check compliance |
| DOCUMENT (Stage 5) | REVIEW + SHIP | Document findings and fixes, generate report, notify team |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Automated scans complete
- [ ] Vulnerabilities identified
- [ ] Risk levels assigned
PASS → proceed to PLAN | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Vulnerabilities analyzed
- [ ] Impact assessed
- [ ] Remediation planned
PASS → proceed to BUILD | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Critical vulnerabilities fixed
- [ ] High vulnerabilities fixed
- [ ] Tests added
- [ ] All tests pass
PASS → proceed to VERIFY | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] No critical vulnerabilities
- [ ] No high vulnerabilities
- [ ] Compliance met
- [ ] Regressions checked
PASS → proceed to REVIEW | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Findings documented
- [ ] Fixes documented
- [ ] Report complete
- [ ] Team notified
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  SCAN → ANALYZE → REMEDIATE → VERIFY → DOCUMENT        │
│    1        2           3         4         5           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Handoff Contracts

### Scan → Analyze

```yaml
handoff:
  from: security-auditor
  to: security-auditor
  provides:
    - scan_results
    - vulnerabilities
  expects:
    - vulnerability_analysis
    - prioritized_fixes
```

### Analyze → Remediate

```yaml
handoff:
  from: security-auditor
  to: executor
  provides:
    - vulnerability_analysis
    - remediation_plan
  expects:
    - vulnerabilities_fixed
    - tests_added
```

### Remediate → Verify

```yaml
handoff:
  from: executor
  to: security-auditor
  provides:
    - fixes
    - test_results
  expects:
    - verification_results
    - compliance_status
```

## Quality Gates Summary

```yaml
quality_gates:
  scan:
    - automated_scans_complete
    - vulnerabilities_identified
    - risk_levels_assigned

  analyze:
    - vulnerabilities_analyzed
    - impact_assessed
    - remediation_planned

  remediate:
    - critical_vulnerabilities_fixed
    - high_vulnerabilities_fixed
    - tests_added
    - all_tests_pass

  verify:
    - no_critical_vulnerabilities
    - no_high_vulnerabilities
    - compliance_met
    - regressions_checked

  document:
    - findings_documented
    - fixes_documented
    - report_complete
    - team_notified
```

## Timeline Estimate

```yaml
timeline:
  scan: "30 min - 2 hours"
  analyze: "1-4 hours"
  remediate: "4 hours - 3 days"
  verify: "1-2 hours"
  document: "1-2 hours"

  total_simple: "1-2 days"
  total_complex: "3-7 days"
```

## Success Criteria

A successful security audit workflow:

- [ ] All OWASP Top 10 checked
- [ ] Critical vulnerabilities fixed
- [ ] High vulnerabilities fixed
- [ ] Security tests added
- [ ] Compliance verified
- [ ] Documentation complete
- [ ] Team trained on findings

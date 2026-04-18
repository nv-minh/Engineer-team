# Security Review (Advanced) - Overview

## Overview

The Security Review (Advanced) workflow provides comprehensive security assessment combining OWASP Top 10 evaluation with STRIDE threat modeling. It leverages the Security Reviewer's blocking authority and the Staff Engineer's deep technical investigation capabilities.

## When to Use

- Pre-deployment security assessment
- Architecture security review
- Application security audit
- Compliance verification (SOC2, PCI-DSS, HIPAA)
- Threat modeling
- Security incident postmortem

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  OWASP → STRIDE → DEEP INVESTIGATION → CONSOLIDATION   │
│   1        2              3                  4           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Components

- **Stage 1:** [OWASP Assessment](owasp-assessment.md) - Security Reviewer
- **Stage 2:** [STRIDE Threat Modeling](stride-threat-modeling.md) - Security Reviewer + Staff Engineer
- **Stage 3:** [Deep Investigation](deep-investigation.md) - Staff Engineer
- **Stage 4:** Consolidation - Security Reviewer + Staff Engineer

## Completion Marker

## ✅ SECURITY_REVIEW_ADVANCED_COMPLETE

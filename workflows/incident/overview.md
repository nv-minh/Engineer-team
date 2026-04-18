# Incident Response - Overview

## Overview

The Incident Response workflow provides systematic production incident handling, combining the Staff Engineer's root cause analysis expertise with the Security Reviewer's security investigation capabilities.

## When to Use

- Production outages
- Performance degradation
- Security incidents
- Data integrity issues
- Critical bugs in production
- Customer-impacting failures

## Workflow Stages

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  TRIAGE → SECURITY → ROOT CAUSE → IMPACT → RESOLUTION → POSTMORTEM  │
│    1         2           3            4          5            6       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Components

- **Stage 1:** [Initial Assessment & Triage](initial-triage.md) - Staff Engineer
- **Stage 2:** [Security Investigation](security-investigation.md) - Security Reviewer (if applicable)
- **Stage 3:** [Root Cause Analysis](root-cause-analysis.md) - Staff Engineer
- **Stage 4:** [Cross-Service Impact Analysis](cross-service-impact.md) - Staff Engineer
- **Stage 5:** [Resolution & Verification](resolution-verification.md) - Staff Engineer + Security Reviewer
- **Stage 6:** [Postmortem & Prevention](postmortem-prevention.md) - Staff Engineer + Security Reviewer

## Completion Marker

## ✅ INCIDENT_RESPONSE_COMPLETE

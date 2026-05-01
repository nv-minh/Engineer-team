---
name: canary-monitoring
description: "Post-deploy canary monitoring. Watches live app for errors, performance regressions, and page failures. Takes screenshots and compares against baselines."
version: "2.0.0"
category: "support"
origin: "gstack"
agents_used: [verifier, performance-auditor]
skills_used: [browser-testing, performance-optimization]
estimated_time: "30-60 min"
---

# Canary Monitoring Workflow

## Overview

Post-deploy monitoring that watches the live application for issues. Takes periodic screenshots, compares against pre-deploy baselines, checks for console errors, and alerts on anomalies.

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
```

### Phase Mapping
- DEFINE: Capture pre-deploy baseline
- PLAN: Define monitoring scope and thresholds
- BUILD: Deploy the change
- VERIFY: Monitor post-deploy health
- REVIEW: Compare against baseline, identify regressions
- SHIP: Confirm or rollback

## When to Use

- After deploying to production or staging
- Monitoring a critical release
- After infrastructure changes
- Post-migration monitoring
- Checking canary deployment health

## Process

### Phase 1: Pre-Deploy Baseline

Capture the current state before deploying:

```yaml
baseline:
  screenshots:
    - page: "/"
      description: "Homepage"
    - page: "/dashboard"
      description: "Main dashboard"
    - page: "/settings"
      description: "Settings page"

  metrics:
    - name: "LCP"
      threshold: "2.5s"
    - name: "FID"
      threshold: "100ms"
    - name: "CLS"
      threshold: "0.1"
    - name: "TTFB"
      threshold: "600ms"

  checks:
    - console_errors: 0
    - network_errors: 0
    - page_load_success: true
```

### Phase 2: Deploy

Deploy the change following the deployment workflow:
```bash
# Deploy command (platform-specific)
# Verify deployment is live
# Check health endpoint
curl -s https://your-app.com/health
```

### Phase 3: Post-Deploy Monitoring

#### Immediate Checks (0-5 minutes)
1. Take screenshots of key pages
2. Check for console errors
3. Verify health endpoint responding
4. Check error rate in monitoring

#### Short-Term Monitoring (5-30 minutes)
1. Compare screenshots against baseline
2. Run Core Web Vitals checks
3. Check for new error patterns in logs
4. Verify key user flows work

#### Canary Analysis
```yaml
canary_checklist:
  - name: "No new console errors"
    check: "browser console clean"
    pass: 0 new errors
    fail: any new error

  - name: "Performance maintained"
    check: "LCP within threshold"
    pass: LCP < baseline + 10%
    fail: LCP > baseline + 10%

  - name: "Visual regression check"
    check: "screenshot comparison"
    pass: no unexpected changes
    fail: visual regression detected

  - name: "Health endpoint"
    check: "HTTP status 200"
    pass: 200
    fail: non-200 response

  - name: "Error rate"
    check: "application error rate"
    pass: < baseline rate
    fail: > baseline rate
```

### Phase 4: Decision Gate

Based on monitoring results:

```
All checks PASS ──→ CONFIRM deployment, stop monitoring
Any CRITICAL fail ──→ ROLLBACK immediately
Any HIGH fail ──→ Investigate, decide within 15 min
Any MEDIUM fail ──→ Document, monitor for 1 hour
```

## Output Format

```markdown
## Canary Monitoring Report

### Deployment: [version] on [environment]
### Duration: [monitoring period]

### Summary
**Status:** [HEALTHY | DEGRADED | UNHEALTHY]
**Decision:** [CONFIRM | INVESTIGATE | ROLLBACK]

### Health Checks
| Check | Status | Details |
|---|---|---|
| Console Errors | [PASS/FAIL] | [count] |
| LCP | [PASS/FAIL] | [actual vs threshold] |
| Visual Regression | [PASS/FAIL] | [pages affected] |
| Error Rate | [PASS/FAIL] | [actual vs baseline] |

### Screenshots
[Before/after comparisons with annotations]

### Recommendation
[CONFIRM deployment / ROLLBACK with reason]
```

## Verification Gates

### Gate 1: Baseline Captured
- [ ] Pre-deploy screenshots taken
- [ ] Performance metrics recorded
- [ ] Console error count noted
PASS → proceed to deploy

### Gate 2: Deployment Successful
- [ ] Health endpoint returning 200
- [ ] New version confirmed live
PASS → proceed to monitoring

### Gate 3: Immediate Health
- [ ] No new console errors
- [ ] Pages loading correctly
PASS → continue monitoring

### Gate 4: Stability Confirmed
- [ ] All performance metrics within threshold
- [ ] No visual regressions
- [ ] Error rate normal
PASS → CONFIRM deployment

---
name: canary-monitoring
description: "Post-deploy canary monitoring. Watches live app for errors, performance regressions, and page failures. Takes screenshots and compares against baselines."
version: "2.1.0"
category: "support"
origin: "gstack"
agents_used:
  - executor
  - verifier
skills_used:
  - browser-testing
  - performance-optimization
  - e2e-testing
related_skills:
  - browser-testing
  - performance-optimization
  - finishing-branch
estimated_time: "30-60 min"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Canary Monitoring Workflow

```
BASELINE → DEPLOY → IMMEDIATE CHECK → STABILITY CHECK → DECISION
    1         2           3                  4               5
```

---

### Stage 1: Pre-Deploy Baseline

<thought>
Observe: Deployment pending — need pre-deploy state for comparison.
Analyze: Must capture screenshots of key pages, record performance metrics (LCP, FID, CLS, TTFB), note console error count and network error count. Gate requires baseline captured.
Plan: Invoke executor agent with browser-testing skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  skill: browser-testing
  task: capture_baseline
  pages: ["/", "/dashboard", "/settings"]
  metrics: [LCP, FID, CLS, TTFB]
  outputs: [baseline_screenshots, baseline_metrics, console_error_count]
</action>

<observation>
result: Pre-deploy screenshots taken, performance metrics recorded, error counts noted
gate_status: PASS | FAIL
</observation>

**Gate 1: Baseline Captured**
- [ ] Pre-deploy screenshots taken
- [ ] Performance metrics recorded
- [ ] Console error count noted

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BASELINE
  completed: []
  next_action: "DEPLOY"
```

---

### Stage 2: Deploy

<thought>
Observe: Baseline captured.
Analyze: Must execute deployment, verify health endpoint responds, confirm new version is live.
Plan: Invoke executor agent.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: execute_deployment
  outputs: [health_endpoint_200, new_version_confirmed]
</action>

<observation>
result: Health endpoint returning 200, new version confirmed live
gate_status: PASS | FAIL
</observation>

**Gate 2: Deployment Successful**
- [ ] Health endpoint returning 200
- [ ] New version confirmed live

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEPLOY
  completed: [BASELINE]
  next_action: "IMMEDIATE_CHECK"
```

---

### Stage 3: Immediate Health Check (0-5 min)

<thought>
Observe: Deployment live with new version.
Analyze: Must take screenshots of key pages, check for new console errors, verify pages loading correctly.
Plan: Invoke verifier agent with browser-testing skill.
</thought>

<action>
type: invoke_agent
target: verifier
params:
  skill: browser-testing
  task: immediate_health_check
  outputs: [post_deploy_screenshots, console_errors, pages_loading]
</action>

<observation>
result: No new console errors, pages loading correctly
gate_status: PASS | FAIL
</observation>

**Gate 3: Immediate Health**
- [ ] No new console errors
- [ ] Pages loading correctly

**State Snapshot:**
```yaml
workflow_state:
  current_phase: IMMEDIATE_CHECK
  completed: [BASELINE, DEPLOY]
  next_action: "STABILITY_CHECK"
```

---

### Stage 4: Stability Check (5-30 min)

<thought>
Observe: Immediate health check passed.
Analyze: Must compare screenshots against baseline, run Core Web Vitals checks, check for new error patterns, verify key user flows. Gate requires performance within threshold, no visual regressions, error rate normal.
Plan: Invoke verifier agent with performance-optimization and e2e-testing skills.
</thought>

<action>
type: invoke_agent
target: verifier
params:
  skills: [performance-optimization, e2e-testing]
  task: stability_monitoring
  duration: "5-30 minutes"
  thresholds:
    LCP: "baseline + 10%"
    error_rate: "< baseline rate"
  outputs: [screenshot_comparison, web_vitals, error_patterns, user_flow_results]
</action>

<observation>
result: Performance within threshold, no visual regressions, error rate normal
gate_status: PASS | FAIL
</observation>

**Gate 4: Stability Confirmed**
- [ ] All performance metrics within threshold
- [ ] No visual regressions
- [ ] Error rate normal

**State Snapshot:**
```yaml
workflow_state:
  current_phase: STABILITY_CHECK
  completed: [BASELINE, DEPLOY, IMMEDIATE_CHECK]
  next_action: "DECISION"
```

---

### Stage 5: Decision Gate

<thought>
Observe: All monitoring checks complete.
Analyze: Must make deployment decision based on results. All PASS → CONFIRM. Any CRITICAL fail → ROLLBACK. Any HIGH fail → investigate within 15 min. Any MEDIUM fail → document and monitor 1 hour.
Plan: Evaluate results and decide.
</thought>

<action>
type: invoke_agent
target: verifier
params:
  task: deployment_decision
  input: [screenshot_comparison, web_vitals, error_patterns]
  outputs: [decision, monitoring_report]
</action>

<observation>
result: CONFIRM | INVESTIGATE | ROLLBACK
gate_status: PASS | FAIL
</observation>

**Decision Matrix:**
- All checks PASS → CONFIRM deployment
- Any CRITICAL fail → ROLLBACK immediately
- Any HIGH fail → Investigate, decide within 15 min
- Any MEDIUM fail → Document, monitor for 1 hour

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DECISION
  completed: [BASELINE, DEPLOY, IMMEDIATE_CHECK, STABILITY_CHECK]
  next_action: "DONE"
```

---

## Handoff Contracts

### Deploy → Monitor
```yaml
handoff:
  from: executor
  to: verifier
  provides: [baseline_screenshots, health_endpoints, deploy_timestamp]
  expects: [canary_comparison_report, anomaly_list, rollback_decision]
```

### Monitor → Rollback/Confirm
```yaml
handoff:
  from: verifier
  to: executor
  provides: [monitoring_report, decision (CONFIRM | INVESTIGATE | ROLLBACK)]
  expects: [rollback_executed | deployment_confirmed]
```

---

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

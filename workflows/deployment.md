---
name: deployment
description: Deployment workflow with testing, monitoring, and rollback
version: "2.1.0"
category: "support"
origin: "agent-skills"
agents_used:
  - executor
  - verifier
skills_used:
  - ci-cd-automation
  - code-review
  - performance-optimization
  - documentation
related_skills:
  - ci-cd-automation
  - finishing-branch
  - performance-optimization
estimated_time: "3-8 hours"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Deployment Workflow

```
PREP → DEPLOY → TEST → MONITOR → FINALIZE
  1       2        3       4          5
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase |
|---|---|
| PREP (Stage 1) | DEFINE + PLAN |
| DEPLOY (Stage 2) | BUILD |
| TEST (Stage 3) | VERIFY |
| MONITOR (Stage 4) | REVIEW |
| FINALIZE (Stage 5) | SHIP |

---

### Stage 1: PREP

<thought>
Observe: Code ready for deployment — must verify readiness.
Analyze: Must run tests, verify build, create tag, backup, select deployment strategy (blue-green/canary/rolling). Gate requires tests pass, build succeeds, tag created, backup complete.
Plan: Invoke executor agent.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: prepare_deployment
  outputs: [tests_passed, build_verified, tag_created, backup_complete, strategy_selected]
</action>

<observation>
result: Tests pass, build succeeds, tag created, backup complete, strategy selected
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Tests pass
- [ ] Build succeeds
- [ ] Tag created
- [ ] Backup complete
- [ ] Deployment strategy selected

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PREP
  completed: []
  next_action: "DEPLOY"
```

---

### Stage 2: DEPLOY

<thought>
Observe: Deployment preparation complete.
Analyze: Must execute deployment using selected strategy. Gate requires staging tests pass, deployment successful, smoke tests pass.
Plan: Invoke executor agent with ci-cd-automation skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  skill: ci-cd-automation
  task: execute_deployment
  strategy: selected_strategy
  outputs: [deployment_result, smoke_test_results]
</action>

<observation>
result: Deployment successful, smoke tests passing
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Staging tests pass
- [ ] Deployment successful
- [ ] Smoke tests pass
- [ ] Traffic shifted (if applicable)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEPLOY
  completed: [PREP]
  next_action: "TEST"
```

---

### Stage 3: TEST

<thought>
Observe: Deployment live, smoke tests passing.
Analyze: Must run smoke tests on production, check critical paths, verify error rates, check performance. Gate requires smoke tests pass, critical paths work, error rates acceptable.
Plan: Invoke verifier agent.
</thought>

<action>
type: invoke_agent
target: verifier
params:
  task: post_deploy_testing
  outputs: [smoke_results, critical_path_results, error_rates, performance_metrics]
</action>

<observation>
result: Smoke tests pass, critical paths work, error rates acceptable
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Smoke tests pass
- [ ] Critical paths work
- [ ] Error rates acceptable
- [ ] Performance acceptable

**State Snapshot:**
```yaml
workflow_state:
  current_phase: TEST
  completed: [PREP, DEPLOY]
  next_action: "MONITOR"
```

---

### Stage 4: MONITOR

<thought>
Observe: Post-deploy tests passed.
Analyze: Must monitor metrics (response time, error rate, CPU, memory), check for anomalies over monitoring period (30-60 min). Trigger rollback if thresholds exceeded.
Plan: Invoke verifier agent with performance-optimization skill.
</thought>

<action>
type: invoke_agent
target: verifier
params:
  task: monitor_deployment
  duration: "30-60 minutes"
  rollback_triggers: [error_rate_gt_1pct, p95_gt_2x_baseline, critical_errors]
  outputs: [monitoring_report, anomalies]
</action>

<observation>
result: Metrics normal, error rates low, no critical errors
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Metrics normal
- [ ] Error rates low
- [ ] Performance acceptable
- [ ] No critical errors

**State Snapshot:**
```yaml
workflow_state:
  current_phase: MONITOR
  completed: [PREP, DEPLOY, TEST]
  next_action: "FINALIZE"
```

---

### Stage 5: FINALIZE

<thought>
Observe: Monitoring period complete, all metrics healthy.
Analyze: Must update documentation, notify team, record deployment.
Plan: Invoke executor agent.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: finalize_deployment
  outputs: [documentation_updated, team_notified, deployment_recorded]
</action>

<observation>
result: Documentation updated, team notified, deployment recorded
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Deployment successful
- [ ] Documentation updated
- [ ] Team notified
- [ ] Deployment recorded

**State Snapshot:**
```yaml
workflow_state:
  current_phase: FINALIZE
  completed: [PREP, DEPLOY, TEST, MONITOR]
  next_action: "DONE"
```

---

## Rollback Plan

```yaml
rollback:
  triggers:
    - "Error rate > 1%"
    - "Response time p95 > 2x baseline"
    - "Critical errors detected"
    - "Manual trigger"
  steps:
    - Execute rollback procedure
    - Verify old version is live
    - Investigate root cause
    - Document incident
```

## Handoff Contracts

### Pre-deploy → Deploy
```yaml
handoff:
  from: executor
  to: verifier
  provides: [tests_passed, build_artifacts, deployment_plan]
  expects: [smoke_test_results, environment_health]
```

### Deploy → Post-deploy
```yaml
handoff:
  from: verifier
  to: executor
  provides: [smoke_results, monitoring_baseline]
  expects: [deployment_documented, team_notified]
```

---

## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |
| `DEPLOY_FAILURE` | Deployment to target environment fails | Check logs, verify config, rollback | Yes |
| `ROLLBACK_FAILURE` | Rollback to previous version fails | Manual intervention, escalate | No |
| `HEALTH_CHECK_FAILED` | Post-deploy health check unhealthy | Check app logs, rollback if critical | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

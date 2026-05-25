---
name: retro
description: Engineering retrospective workflow for learning and improvement
version: "2.1.0"
category: "support"
origin: "agent-skills"
agents_used:
  - code-reviewer
skills_used:
  - documentation
  - code-review
  - writing-plans
related_skills:
  - documentation
  - writing-plans
estimated_time: "6-12 hours (retro) / 1-2 weeks (execute actions)"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Retro Workflow

```
COLLECT → ANALYZE → IDENTIFY → PLAN → EXECUTE
   1          2          3        4        5
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase |
|---|---|
| COLLECT (Stage 1) | DEFINE |
| ANALYZE (Stage 2) | DEFINE |
| IDENTIFY (Stage 3) | PLAN |
| PLAN (Stage 4) | PLAN |
| EXECUTE (Stage 5) | BUILD + VERIFY + SHIP |

---

### Stage 1: COLLECT

<thought>
Observe: Project/iteration complete — need to gather retrospective data.
Analyze: Must collect commit metrics, quality metrics, and team feedback. Gate requires data collected, metrics gathered, feedback compiled.
Plan: Gather data from git logs, test reports, and team input.
</thought>

<action>
type: invoke_skill
target: documentation
params:
  task: collect_retro_data
  outputs: [commit_metrics, quality_metrics, feedback]
</action>

<observation>
result: Commit metrics collected, quality metrics gathered, feedback compiled
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Data collected
- [ ] Metrics gathered
- [ ] Feedback compiled

**State Snapshot:**
```yaml
workflow_state:
  current_phase: COLLECT
  completed: []
  next_action: "ANALYZE"
```

---

### Stage 2: ANALYZE

<thought>
Observe: Raw data collected — commit metrics, quality metrics, feedback.
Analyze: Must identify patterns, analyze trends, document findings.
Plan: Invoke code-reviewer agent to analyze data.
</thought>

<action>
type: invoke_agent
target: code-reviewer
params:
  task: analyze_retro_data
  input: [commit_metrics, quality_metrics, feedback]
  outputs: [patterns, trends, findings]
</action>

<observation>
result: Patterns identified, trends analyzed, findings documented
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Patterns identified
- [ ] Trends analyzed
- [ ] Findings documented

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ANALYZE
  completed: [COLLECT]
  next_action: "IDENTIFY"
```

---

### Stage 3: IDENTIFY

<thought>
Observe: Analysis complete with patterns and trends.
Analyze: Must document successes, identify issues, prioritize improvements.
Plan: Categorize findings into successes and improvement areas.
</thought>

<action>
type: invoke_skill
target: writing-plans
params:
  task: identify_improvements
  input: [patterns, trends, findings]
  outputs: [successes, issues, prioritized_improvements]
</action>

<observation>
result: Successes documented, issues identified, improvements prioritized
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Successes documented
- [ ] Issues identified
- [ ] Improvements prioritized

**State Snapshot:**
```yaml
workflow_state:
  current_phase: IDENTIFY
  completed: [COLLECT, ANALYZE]
  next_action: "PLAN"
```

---

### Stage 4: PLAN

<thought>
Observe: Successes and issues identified, improvements prioritized.
Analyze: Must create action plan with defined items, owners, and timelines.
Plan: Create actionable improvement plan.
</thought>

<action>
type: invoke_skill
target: writing-plans
params:
  task: create_action_plan
  input: prioritized_improvements
  outputs: [action_plan, action_items, owners, timeline]
</action>

<observation>
result: Action plan created, items defined, owners assigned, timeline set
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Action items defined
- [ ] Owners assigned
- [ ] Timeline set

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PLAN
  completed: [COLLECT, ANALYZE, IDENTIFY]
  next_action: "EXECUTE"
```

---

### Stage 5: EXECUTE

<thought>
Observe: Action plan ready with owners and timelines.
Analyze: Must implement improvements, update processes, inform team, track progress.
Plan: Execute action items and track completion.
</thought>

<action>
type: invoke_agent
target: code-reviewer
params:
  task: execute_improvements
  input: action_plan
  outputs: [actions_completed, processes_updated, team_informed, progress_tracked]
</action>

<observation>
result: Actions completed, processes updated, team informed, progress tracked
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Actions completed
- [ ] Processes updated
- [ ] Team informed
- [ ] Progress tracked

**State Snapshot:**
```yaml
workflow_state:
  current_phase: EXECUTE
  completed: [COLLECT, ANALYZE, IDENTIFY, PLAN]
  next_action: "DONE"
```

---

## Handoff Contracts

### Collect → Analyze
```yaml
handoff:
  from: manual
  to: code-reviewer
  provides: [data_collected, metrics_gathered, feedback_compiled]
  expects: [patterns_identified, trends_analyzed]
```

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

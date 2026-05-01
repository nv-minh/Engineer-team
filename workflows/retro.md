---
name: retro
description: Engineering retrospective workflow for learning and improvement
version: "2.0.0"
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
---

# Retro Workflow

## Overview

The retro workflow conducts engineering retrospectives to learn from completed work, identify improvements, and continuously enhance processes.

## When to Use

- After project completion
- End of iteration
- After major milestones
- Quarterly reviews
- Process improvement

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
| COLLECT (Stage 1) | DEFINE | Gather commit metrics, quality metrics, and feedback |
| ANALYZE (Stage 2) | DEFINE | Identify patterns, analyze trends, document findings |
| IDENTIFY (Stage 3) | PLAN | Document successes, identify issues, prioritize improvements |
| PLAN (Stage 4) | PLAN | Create action plan, assign owners, set timeline |
| EXECUTE (Stage 5) | BUILD + VERIFY + SHIP | Implement improvements, update processes, track progress |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Data collected
- [ ] Metrics gathered
- [ ] Feedback compiled
PASS → proceed to PLAN | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Successes documented
- [ ] Issues identified
- [ ] Improvements prioritized
- [ ] Plan created
PASS → proceed to BUILD | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Action items defined
- [ ] Owners assigned
- [ ] Timeline set
PASS → proceed to VERIFY | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Actions completed
- [ ] Processes updated
- [ ] Team informed
PASS → proceed to REVIEW | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Progress tracked
- [ ] Improvements measurable
- [ ] Team learns and improves
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  COLLECT → ANALYZE → IDENTIFY → PLAN → EXECUTE        │
│     1           2             3        4          5         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Retro Data Collection

### Commit Metrics

```yaml
commit_metrics:
  total_commits: 156
  breakdown:
    feature: 89
    fix: 34
    refactor: 18
    docs: 12
    chore: 3
```

### Quality Metrics

```yaml
quality_metrics:
  test_coverage:
    before: "75%"
    after: "82%"
    improvement: "+7%"
```

## Handoff Contracts

### Collect → Analyze

```yaml
handoff:
  from: manual
  to: code-reviewer
  provides:
    - data_collected
    - metrics_gathered
    - feedback_compiled
  expects:
    - patterns_identified
    - trends_analyzed
```

## Quality Gates Summary

```yaml
quality_gates:
  collect:
    - data_collected
    - metrics_gathered
    - feedback_compiled

  analyze:
    - patterns_identified
    - trends_analyzed
    - findings_documented

  identify:
    - successes_documented
    - issues_identified
    - improvements_prioritized

  plan:
    - plan_created
    - action_items_defined
    - owners_assigned
    - timeline_set

  execute:
    - actions_completed
    - processes_updated
    - team_informed
    - progress_tracked
```

## Timeline Estimate

```yaml
timeline:
  collect: "2-4 hours"
  analyze: "2-4 hours"
  identify: "1-2 hours"
  plan: "1-2 hours"
  execute: "Variable (1-2 weeks)"

  total_retro: "6-12 hours"
  total_execute: "As needed"
```

## Success Criteria

A successful retro workflow:

- [ ] Data collected comprehensively
- [ ] Patterns identified and analyzed
- [ ] Successes and failures documented
- [ ] Action items created
- [ ] Owners assigned
- [ ] Timeline set
- [ ] Improvements implemented
- [ ] Processes updated
- [ ] Team learns and improves

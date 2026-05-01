---
name: refactoring
description: Code refactoring workflow for improving quality and maintainability
version: "2.0.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - code-reviewer
  - planner
  - executor
  - verifier
skills_used:
  - code-review
  - code-simplification
  - test-driven-development
  - writing-plans
  - git-workflow
estimated_time: "4-8 hours (simple) / 1-3 days (complex)"
---

# Refactoring Workflow

## Overview

The refactoring workflow improves code quality while maintaining functionality. It focuses on reducing complexity, eliminating duplication, and enhancing maintainability.

## When to Use

- Improving code quality
- Reducing complexity
- Eliminating technical debt
- Enhancing maintainability
- Optimizing performance

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
| ANALYZE (Stage 1) | DEFINE | Identify code smells, collect metrics, set priorities |
| PLAN (Stage 2) | PLAN | Define tasks, plan tests, ensure no functionality changes |
| REFACTOR (Stage 3) | BUILD | Execute refactoring with tests passing throughout |
| VERIFY (Stage 4) | VERIFY | Confirm functionality preserved, quality improved |
| UPDATE (Stage 5) | REVIEW + SHIP | Update documentation, commit changes, track debt reduction |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Code smells identified
- [ ] Metrics collected
- [ ] Priorities set
PASS → proceed to PLAN | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Tasks defined
- [ ] Tests planned
- [ ] No functionality changes planned
PASS → proceed to BUILD | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Tests pass
- [ ] Functionality unchanged
- [ ] Quality improved
- [ ] Complexity reduced
PASS → proceed to VERIFY | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Functionality preserved
- [ ] Quality improved
- [ ] Complexity reduced
- [ ] No regressions
PASS → proceed to REVIEW | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Documentation updated
- [ ] Tests updated
- [ ] Changes committed
- [ ] Debt tracked
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ANALYZE → PLAN → REFACTOR → VERIFY → UPDATE           │
│     1        2         3         4         5            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Handoff Contracts

### Analyze → Plan

```yaml
handoff:
  from: code-reviewer
  to: planner
  provides:
    - code_smells
    - complexity_metrics
  expects:
    - refactoring_plan
    - task_breakdown
```

### Plan → Refactor

```yaml
handoff:
  from: planner
  to: executor
  provides:
    - refactoring_plan
    - tasks
  expects:
    - refactored_code
    - tests_passing
```

### Refactor → Verify

```yaml
handoff:
  from: executor
  to: verifier
  provides:
    - refactored_code
    - test_results
  expects:
    - verification_report
    - metrics_comparison
```

## Quality Gates Summary

```yaml
quality_gates:
  analyze:
    - code_smells_identified
    - metrics_collected
    - priorities_set

  plan:
    - tasks_defined
    - tests_planned
    - no_functionality_changes

  refactor:
    - tests_pass
    - functionality_unchanged
    - quality_improved
    - complexity_reduced

  verify:
    - functionality_preserved
    - quality_improved
    - complexity_reduced
    - no_regressions

  update:
    - documentation_updated
    - tests_updated
    - changes_committed
    - debt_tracked
```

## Timeline Estimate

```yaml
timeline:
  analyze: "1-2 hours"
  plan: "1-2 hours"
  refactor: "2-8 hours (depends on scope)"
  verify: "1-2 hours"
  update: "30 min - 1 hour"

  total_simple: "4-8 hours"
  total_complex: "1-3 days"
```

## Success Criteria

A successful refactoring workflow:

- [ ] Code quality improved
- [ ] Complexity reduced
- [ ] Duplication eliminated
- [ ] Tests still pass
- [ ] Functionality unchanged
- [ ] Performance maintained or improved
- [ ] Documentation updated
- [ ] Technical debt reduced

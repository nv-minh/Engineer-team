---
name: new-feature
description: Complete workflow from idea to production for new features
---

# New Feature Workflow

## Overview

The new feature workflow takes a feature from initial idea through to production deployment. It follows the complete development lifecycle with quality gates at each phase.

## When to Use

- Building new features
- Adding functionality
- Implementing user stories
- Creating new capabilities

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  BRAINSTORM → SPEC → PLAN → BUILD → VERIFY → SHIP      │
│      1         2      3      4       5        6         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Stage 1: Brainstorm

**Agent:** None (Human + Brainstorming skill)

**Process:**
1. Explore project context
2. Ask clarifying questions
3. Propose 2-3 approaches
4. Present design for approval
5. Write design document

**Output:**
- Design document saved
- User approval obtained

**Quality Gate:**
- [ ] Design approved by user
- [ ] Design document written
- [ ] Technical approach decided

## Stage 2: Spec

**Agent:** Planner

**Process:**
1. Read design document
2. Write structured spec
3. Define requirements
4. Set boundaries
5. Document success criteria

**Output:**
- SPEC.md document
- Requirements defined
- Success criteria set

**Quality Gate:**
- [ ] Spec covers all 6 core areas
- [ ] User approved spec
- [ ] Success criteria testable

## Stage 3: Plan

**Agent:** Planner

**Process:**
1. Break down into tasks
2. Estimate effort
3. Identify dependencies
4. Define verification steps
5. Create implementation plan

**Output:**
- PLAN.md document
- Task list created
- Dependencies mapped

**Quality Gate:**
- [ ] All requirements have tasks
- [ ] No placeholders in plan
- [ ] Acceptance criteria defined
- [ ] Verification steps specified

## Stage 4: Build

**Agent:** Executor

**Process:**
1. Execute plan task-by-task
2. Follow TDD
3. Make atomic commits
4. Run quality gates
5. Handle errors

**Output:**
- Feature implemented
- Tests passing
- Commits pushed

**Quality Gate:**
- [ ] All tasks completed
- [ ] All tests pass
- [ ] Code reviewed
- [ ] Build succeeds

## Stage 5: Verify

**Agent:** Verifier

**Process:**
1. Verify spec coverage
2. Run quality gates
3. Test acceptance criteria
4. Integration testing
5. User acceptance testing

**Output:**
- Verification report
- Issues documented
- Recommendations provided

**Quality Gate:**
- [ ] Spec coverage 100%
- [ ] All quality gates pass
- [ ] Acceptance criteria met
- [ ] Integration tests pass
- [ ] Manual testing successful

## Stage 6: Ship

**Agent:** Executor + Code-Reviewer

**Process:**
1. Final code review
2. Create pull request
3. Merge to main
4. Deploy to production
5. Monitor deployment

**Output:**
- Feature in production
- Users can access feature
- Monitoring active

**Quality Gate:**
- [ ] Code review approved
- [ ] PR merged
- [ ] Deployed successfully
- [ } Monitoring shows no issues
- [ ] Documentation updated

## Handoff Contracts

### Brainstorm → Spec

```yaml
handoff:
  from: brainstorming
  to: planner
  provides:
    - design_document
    - user_approval
  expects:
    - spec_document
    - requirements_defined
```

### Spec → Plan

```yaml
handoff:
  from: planner
  to: planner
  provides:
    - spec_document
    - requirements
  expects:
    - implementation_plan
    - task_breakdown
```

### Plan → Build

```yaml
handoff:
  from: planner
  to: executor
  provides:
    - implementation_plan
    - tasks
  expects:
    - completed_tasks
    - atomic_commits
    - tests_passing
```

### Build → Verify

```yaml
handoff:
  from: executor
  to: verifier
  provides:
    - implementation
    - test_results
    - commits
  expects:
    - verification_report
    - issues_found
    - approval_status
```

### Verify → Ship

```yaml
handoff:
  from: verifier
  to: executor + code-reviewer
  provides:
    - verification_report
    - approval
  expects:
    - pull_request
    - merge
    - deployment
```

## Quality Gates Summary

```yaml
quality_gates:
  brainstorm:
    - design_approved
    - design_document_written

  spec:
    - spec_complete
    - user_approved
    - success_criteria_testable

  plan:
    - requirements_mapped
    - tasks_defined
    - no_placeholders

  build:
    - tasks_completed
    - tests_passing
    - code_reviewed
    - build_succeeds

  verify:
    - spec_coverage_100
    - quality_gates_pass
    - acceptance_criteria_met
    - integration_tests_pass

  ship:
    - code_review_approved
    - pr_merged
    - deployed_successfully
    - monitoring_ok
```

## Timeline Estimate

```yaml
timeline:
  brainstorm: "2-4 hours"
  spec: "1-2 hours"
  plan: "2-4 hours"
  build: "1-3 days (depends on complexity)"
  verify: "2-4 hours"
  ship: "1-2 hours"

  total_simple: "1-2 days"
  total_complex: "1-2 weeks"
```

## Example Usage

```bash
# Start new feature workflow
"Workflow: em-new-feature - Implement user authentication with OAuth2"

# This will trigger:
# 1. Brainstorming skill - Explore OAuth2 options
# 2. Planner agent - Create spec
# 3. Planner agent - Create plan
# 4. Executor agent - Implement
# 5. Verifier agent - Verify
# 6. Executor agent - Deploy
```

## Success Criteria

A successful new feature workflow:

- [ ] Feature matches spec requirements
- [ ] All tests pass
- [ ] Code is clean and maintainable
- [ ] Documentation is complete
- [ ] Feature is deployed
- [ ] No regressions introduced
- [ ] Users can use the feature
- [ ] Monitoring shows healthy state

---
name: "[workflow-name]"
description: "[One-line: what this workflow accomplishes end-to-end]"
version: "2.0.0"
category: "primary|support|team|distributed"
origin: "[source-repo]"
agents_used:
  - "[agent-name-1]"
  - "[agent-name-2]"
skills_used:
  - "[skill-name-1]"
  - "[skill-name-2]"
estimated_time: "[Expected duration: 1-2 hours, 2-4 hours, 1 day]"
---

# [Workflow Name]

## Overview

[1-2 paragraphs explaining what this workflow accomplishes, when to use it, and what the expected outcome is.]

## When to Use

- [Use case 1]
- [Use case 2]
- [Use case 3]

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

---

## Phase 1: DEFINE

**Goal:** [What needs to be understood and clarified]

### Steps
1. [Step 1: Understand requirements]
2. [Step 2: Gather context]
3. [Step 3: Clarify scope]

### Output
- [Required artifact: requirements doc, clarified scope, etc.]

### Gate 1: Definition Complete
- [ ] Requirements documented
- [ ] Scope boundaries defined
- [ ] Success criteria are measurable
- [ ] Stakeholders aligned

**PASS** → Proceed to PLAN
**FAIL** → Return to DEFINE, resolve gaps

---

## Phase 2: PLAN

**Goal:** [What needs to be planned and organized]

### Steps
1. [Step 1: Break down into tasks]
2. [Step 2: Identify dependencies]
3. [Step 3: Assign agents and resources]

### Output
- [Required artifact: PLAN.md, task list, etc.]

### Gate 2: Plan Complete
- [ ] All requirements have corresponding tasks
- [ ] Dependencies identified and ordered
- [ ] No placeholder tasks
- [ ] Verification criteria defined per task

**PASS** → Proceed to BUILD
**FAIL** → Return to PLAN, fill gaps

---

## Phase 3: BUILD

**Goal:** [What needs to be implemented]

### Steps
1. [Step 1: Implement tasks in order]
2. [Step 2: Follow TDD where applicable]
3. [Step 3: Make atomic commits]

### Output
- [Required artifact: working code, tests, etc.]

### Gate 3: Build Complete
- [ ] All tasks implemented
- [ ] Tests passing
- [ ] Code reviewed (self-review minimum)
- [ ] No TODO/FIXME remaining

**PASS** → Proceed to VERIFY
**FAIL** → Return to BUILD, fix issues

---

## Phase 4: VERIFY

**Goal:** [What needs to be validated]

### Steps
1. [Step 1: Run full test suite]
2. [Step 2: Verify acceptance criteria]
3. [Step 3: Check edge cases]

### Output
- [Required artifact: verification report]

### Gate 4: Verification Complete
- [ ] All acceptance criteria met
- [ ] All tests passing
- [ ] Edge cases handled
- [ ] Performance benchmarks met (if applicable)

**PASS** → Proceed to REVIEW
**FAIL** → Return to BUILD, fix failures

---

## Phase 5: REVIEW

**Goal:** [What needs to be reviewed]

### Steps
1. [Step 1: Code review (5-axis or 9-axis)]
2. [Step 2: Architecture review (if applicable)]
3. [Step 3: Security review (if applicable)]

### Output
- [Required artifact: review reports]

### Gate 5: Review Complete
- [ ] No CRITICAL findings
- [ ] No HIGH findings (or all approved)
- [ ] Code review passed
- [ ] Security review passed (if applicable)

**PASS** → Proceed to SHIP
**FAIL** → Return to BUILD, address findings

---

## Phase 6: SHIP

**Goal:** [What needs to be deployed/released]

### Steps
1. [Step 1: Final review and approval]
2. [Step 2: Create PR / deploy]
3. [Step 3: Post-ship verification]

### Output
- [Required artifact: deployed feature, PR, etc.]

### Completion
- [ ] PR created and approved
- [ ] Deployed successfully
- [ ] Post-deploy health check passed
- [ ] Documentation updated

---

## Milestone Checkpoints

| Milestone | Phase | Criteria | Status |
|---|---|---|---|
| [Milestone 1] | DEFINE | [What defines done] | [ ] |
| [Milestone 2] | PLAN | [What defines done] | [ ] |
| [Milestone 3] | BUILD | [What defines done] | [ ] |
| [Milestone 4] | VERIFY | [What defines done] | [ ] |
| [Milestone 5] | REVIEW | [What defines done] | [ ] |
| [Milestone 6] | SHIP | [What defines done] | [ ] |

## Agents Involved

| Agent | Phase | Role |
|---|---|---|
| [agent-name] | [phase] | [what they do] |

## Rollback Plan

If issues are discovered after shipping:
1. [Rollback step 1]
2. [Rollback step 2]
3. [Communication plan]

---

**Version:** 2.0.0
**Origin:** [source-repo-name]
**Last Updated:** [YYYY-MM-DD]

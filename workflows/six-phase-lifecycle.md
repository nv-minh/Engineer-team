---
name: six-phase-lifecycle
description: "Master lifecycle workflow that all EM-Skill workflows inherit. Defines the 6 phases (DEFINE→PLAN→BUILD→VERIFY→REVIEW→SHIP) with verification gates."
version: "2.0.0"
category: "primary"
origin: "agent-skills"
agents_used: [planner, executor, code-reviewer, verifier]
skills_used: [spec-driven-development, writing-plans, test-driven-development, code-review, git-workflow]
related_skills:
  - spec-driven-development
  - test-driven-development
estimated_time: "Variable - depends on scope"
---

# Six-Phase Lifecycle Workflow

## Overview

The master workflow that governs all EM-Skill development activities. Every workflow in the system follows these six phases with verification gates between each phase. This ensures consistent quality regardless of the specific task.

## The Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

Each phase has:
- **Goal:** What it must accomplish
- **Required output:** What must be produced
- **Verification gate:** What must pass before proceeding
- **Rollback:** What to do if the gate fails

## Phase Details

### Phase 1: DEFINE

**Goal:** Understand what needs to be built and why.

**Activities:**
- Gather requirements and context
- Clarify scope and boundaries
- Identify stakeholders and success criteria
- Surface assumptions and risks

**Required Output:**
- Requirements document or clarified scope
- Success criteria (measurable)
- Assumptions list
- Risk assessment

**Gate 1: Definition Complete**
- [ ] Requirements are documented and specific
- [ ] Scope boundaries are defined (in/out)
- [ ] Success criteria are measurable and testable
- [ ] Assumptions are listed and validated
- [ ] Stakeholders are aligned

**PASS** → Proceed to PLAN
**FAIL** → Return to DEFINE, resolve gaps

### Phase 2: PLAN

**Goal:** Design the approach and break down into implementable tasks.

**Activities:**
- Design architecture and approach
- Break down into bite-sized tasks
- Identify dependencies and ordering
- Assign agents and resources
- Define verification criteria per task

**Required Output:**
- Implementation plan (PLAN.md)
- Task breakdown with dependencies
- File structure mapping
- Verification criteria per task

**Gate 2: Plan Complete**
- [ ] All requirements have corresponding tasks
- [ ] Dependencies are identified and ordered
- [ ] No placeholder tasks (no TBD/TODO)
- [ ] Each task has verification criteria
- [ ] File paths are specific

**PASS** → Proceed to BUILD
**FAIL** → Return to PLAN, fill gaps

### Phase 3: BUILD

**Goal:** Implement tasks following TDD and atomic commits.

**Activities:**
- Implement tasks in dependency order
- Follow TDD (RED-GREEN-REFACTOR) for each task
- Make atomic commits after each task
- Self-review code before marking complete

**Required Output:**
- Working code with tests
- Atomic commits with meaningful messages
- Updated documentation (if applicable)

**Gate 3: Build Complete**
- [ ] All tasks implemented
- [ ] Tests written for all new code
- [ ] All tests passing
- [ ] Code follows project conventions
- [ ] No TODO/FIXME remaining
- [ ] Atomic commits made

**PASS** → Proceed to VERIFY
**FAIL** → Return to BUILD, fix issues

### Phase 4: VERIFY

**Goal:** Validate that what was built matches what was specified.

**Activities:**
- Run full test suite
- Verify acceptance criteria
- Test edge cases and error paths
- Check performance benchmarks
- Verify integration points

**Required Output:**
- Verification report
- Test coverage report
- Performance benchmarks (if applicable)

**Gate 4: Verification Complete**
- [ ] All acceptance criteria met
- [ ] All tests passing (unit, integration, e2e)
- [ ] Edge cases handled
- [ ] Performance benchmarks met
- [ ] No regressions in existing tests

**PASS** → Proceed to REVIEW
**FAIL** → Return to BUILD, fix failures

### Phase 5: REVIEW

**Goal:** Ensure code quality through structured review.

**Activities:**
- Code review (5-axis or 9-axis)
- Architecture review (if applicable)
- Security review (if applicable)
- Performance review (if applicable)

**Required Output:**
- Code review report
- Security review report (if applicable)
- List of findings with severity

**Gate 5: Review Complete**
- [ ] No CRITICAL findings
- [ ] No HIGH findings (or all approved with rationale)
- [ ] Code review passed
- [ ] Security review passed (if applicable)
- [ ] Architecture review passed (if applicable)

**PASS** → Proceed to SHIP
**FAIL** → Return to BUILD, address findings

### Phase 6: SHIP

**Goal:** Deliver the code to production safely.

**Activities:**
- Final verification
- Version bump and changelog
- Create PR
- Deploy (if applicable)
- Post-deploy monitoring (canary)

**Required Output:**
- Published PR
- Deployment (if applicable)
- Post-deploy health check (if applicable)

**Completion Criteria:**
- [ ] PR created and approved
- [ ] CI checks green
- [ ] Deployed successfully (if applicable)
- [ ] Post-deploy health check passed
- [ ] Documentation updated

## Phase Adaptability

Not every task requires all six phases. Adapt based on scope:

| Task Type | Phases | Example |
|---|---|---|
| Bug fix | DEFINE → BUILD → VERIFY → SHIP | Fix null pointer in auth |
| Hotfix | DEFINE → BUILD → VERIFY → SHIP | Critical production fix |
| Feature | Full lifecycle | New user dashboard |
| Refactor | DEFINE → PLAN → BUILD → VERIFY → SHIP | Simplify auth module |
| Documentation | DEFINE → BUILD → SHIP | Update API docs |
| Security patch | DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP | Fix XSS vulnerability |

## Rollback Protocol

At any gate failure:
1. Document what failed and why
2. Return to the relevant phase
3. Fix the issue
4. Re-run the gate
5. Never skip gates — escalate to user if constraints require it

## Integration with Other Workflows

This master lifecycle is inherited by:
- `new-feature.md` — Full lifecycle for new features
- `bug-fix.md` — Abbreviated lifecycle for bug fixes
- `refactoring.md` — Lifecycle for code improvements
- `security-audit.md` — Lifecycle for security assessments
- All team workflows — Lifecycle with multi-agent coordination

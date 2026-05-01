---
name: bug-fix
description: Systematic bug fixing workflow from investigation to resolution
version: "2.0.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - debugger
  - executor
  - verifier
skills_used:
  - systematic-debugging
  - test-driven-development
  - code-review
  - git-workflow
estimated_time: "2-4 hours (simple) / 1-2 days (complex)"
---

# Bug Fix Workflow

## Overview

The bug fix workflow follows a systematic approach to investigating and fixing bugs. It ensures root cause is found and fixed, not just symptoms.

## When to Use

- Fixing bugs
- Resolving issues
- Investigating failures
- Addressing crashes
- Solving errors

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
| INVESTIGATE (Stage 1) | DEFINE | Gather symptoms, reproduce bug, collect evidence |
| ANALYZE (Stage 2) | DEFINE | Narrow down location, examine code/data flow |
| HYPOTHESIZE (Stage 3) | PLAN | Form and test hypotheses, confirm root cause |
| FIX (Stage 4) | BUILD | Write failing test, implement fix, atomic commit |
| VERIFY (Stage 5) | VERIFY | Verify fix, check side effects, run regression tests |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Bug is reproducible
- [ ] Symptoms documented
- [ ] Evidence collected
- [ ] Failure point identified
PASS → proceed to PLAN | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Root cause found
- [ ] Hypothesis tested and confirmed
- [ ] Fix approach decided
PASS → proceed to BUILD | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Test fails before fix
- [ ] Test passes after fix
- [ ] Regression test added
- [ ] All tests still pass
PASS → proceed to VERIFY | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Original bug resolved
- [ ] No regressions
- [ ] Edge cases covered
- [ ] Tests pass
PASS → proceed to REVIEW | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Root cause documented
- [ ] Fix addresses root cause
- [ ] Code reviewed
- [ ] Bug marked as resolved
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  INVESTIGATE → ANALYZE → HYPOTHESIZE → FIX → VERIFY    │
│       1           2            3        4       5        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Stage 1: Investigate

**Agent:** Debugger

**Process:**
1. Gather symptoms
2. Reproduce the bug
3. Collect evidence
4. Check recent changes
5. Identify affected components

**Output:**
- Symptoms documented
- Reproduction steps
- Evidence collected

**Quality Gate:**
- [ ] Bug is reproducible
- [ ] Symptoms documented
- [ ] Evidence collected

## Stage 2: Analyze

**Agent:** Debugger

**Process:**
1. Narrow down location
2. Examine code flow
3. Check data flow
4. Review error handling
5. Identify patterns

**Output:**
- Failure location identified
- Code flow mapped
- Potential causes listed

**Quality Gate:**
- [ ] Failure point identified
- [ ] Code examined
- [ ] Hypotheses formed

## Stage 3: Hypothesize

**Agent:** Debugger

**Process:**
1. Form hypotheses
2. Create tests for hypotheses
3. Test each hypothesis
4. Eliminate false hypotheses
5. Confirm root cause

**Output:**
- Root cause identified
- Hypothesis confirmed
- Fix strategy defined

**Quality Gate:**
- [ ] Root cause found
- [ ] Hypothesis tested
- [ ] Fix approach decided

## Stage 4: Fix

**Agent:** Executor

**Process:**
1. Write failing test (TDD)
2. Implement fix
3. Verify test passes
4. Add regression test
5. Make atomic commit

**Output:**
- Bug fixed
- Test added
- Commit made

**Quality Gate:**
- [ ] Test fails before fix
- [ ] Test passes after fix
- [ ] Regression test added
- [ ] All tests still pass

## Stage 5: Verify

**Agent:** Verifier

**Process:**
1. Verify fix resolves issue
2. Check for side effects
3. Run regression tests
4. Test edge cases
5. Verify no new issues

**Output:**
- Fix verified
- No side effects
- Regression tests pass

**Quality Gate:**
- [ ] Original bug resolved
- [ ] No regressions
- [ ] Edge cases covered
- [ ] Tests pass

## Handoff Contracts

### Investigate → Analyze

```yaml
handoff:
  from: debugger
  to: debugger
  provides:
    - symptoms
    - reproduction_steps
  expects:
    - failure_location
    - code_flow_analysis
```

### Analyze → Hypothesize

```yaml
handoff:
  from: debugger
  to: debugger
  provides:
    - failure_location
    - potential_causes
  expects:
    - root_cause
    - confirmed_hypothesis
```

### Hypothesize → Fix

```yaml
handoff:
  from: debugger
  to: executor
  provides:
    - root_cause_analysis
    - fix_strategy
  expects:
    - bug_fix
    - regression_test
```

### Fix → Verify

```yaml
handoff:
  from: executor
  to: verifier
  provides:
    - bug_fix
    - test_results
  expects:
    - verification_report
    - side_effects_check
```

## Bug Fix Process Example

```typescript
// Bug: User profile shows duplicate entries

// Stage 1: Investigate
symptoms: "User profile shows duplicate entries"
reproduction: "Navigate to /profile/:id, observe duplicate data"

// Stage 2: Analyze
location: "src/components/UserProfile.tsx:45"
analysis: "Component fetches user data, but also receives props with user data"

// Stage 3: Hypothesize
hypothesis: "Component is rendering user data from both API and props, causing duplicates"
test: "Remove props data, verify only one set of entries shows"
result: "Hypothesis confirmed"

// Stage 4: Fix
// Before:
function UserProfile({ userId, user: propUser }) {
  const { data: apiUser } = useUser(userId);
  return (
    <div>
      {propUser.posts.map(post => <Post key={post.id} {...post} />)}
      {apiUser.posts.map(post => <Post key={post.id} {...post} />)}
    </div>
  );
}

// After:
function UserProfile({ userId }) {
  const { data: user } = useUser(userId);
  return (
    <div>
      {user.posts.map(post => <Post key={post.id} {...post} />)}
    </div>
  );
}

// Stage 5: Verify
// - Bug is fixed (no duplicates)
// - No side effects (profile works correctly)
// - Regression test added
```

## Quality Gates Summary

```yaml
quality_gates:
  investigate:
    - bug_reproducible
    - symptoms_documented
    - evidence_collected

  analyze:
    - failure_identified
    - code_examined
    - hypotheses_formed

  hypothesize:
    - root_cause_found
    - hypothesis_confirmed
    - fix_strategy_defined

  fix:
    - test_fails_before_fix
    - test_passes_after_fix
    - regression_test_added
    - all_tests_pass

  verify:
    - bug_resolved
    - no_regressions
    - edge_cases_covered
    - side_effects_checked
```

## Timeline Estimate

```yaml
timeline:
  investigate: "30 min - 2 hours"
  analyze: "30 min - 2 hours"
  hypothesize: "1-4 hours"
  fix: "1-4 hours"
  verify: "30 min - 2 hours"

  total_simple: "2-4 hours"
  total_complex: "1-2 days"
```

## Example Usage

```bash
# Start bug fix workflow
"Workflow: em-bug-fix - User profile shows duplicate entries"

# This will trigger:
# 1. Debugger - Investigate symptoms
# 2. Debugger - Analyze code
# 3. Debugger - Find root cause
# 4. Executor - Fix bug
# 5. Verifier - Verify fix
```

## Success Criteria

A successful bug fix workflow:

- [ ] Root cause identified and documented
- [ ] Fix addresses root cause
- [ ] Regression test added
- [ ] All tests pass
- [ ] No side effects
- [ ] Fix verified in production
- [ ] Bug marked as resolved
name: bug-fix
description: Systematic bug fixing workflow from investigation to resolution
---

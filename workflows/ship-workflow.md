---
name: ship-workflow
description: "Ship workflow: version bump, changelog update, commit, push, create PR. Takes code from ready-to-ship to PR created."
version: "2.1.0"
category: "support"
origin: "gstack"
agents_used: [executor, verifier, code-reviewer]
skills_used: [git-workflow, code-review, ci-cd-automation]
related_skills:
  - git-workflow
  - finishing-branch
estimated_time: "15-30 min"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Ship Workflow

```
PRE-SHIP VERIFY → VERSION BUMP → FINAL VERIFY → CREATE PR
       1                2              3             4
```

---

### Stage 1: Pre-Ship Verification

<thought>
Observe: Code is reviewed and ready to ship — must confirm readiness.
Analyze: Must verify clean git state, run full test suite, type check, lint, build. Gate requires all checks pass. If any fail, STOP and fix.
Plan: Run verification commands.
</thought>

<action>
type: invoke_agent
target: verifier
params:
  task: pre_ship_verification
  checks: [git_status, test_suite, type_check, lint, build]
  outputs: [all_checks_passed]
</action>

<observation>
result: All checks pass — tests, types, lint, build
gate_status: PASS | FAIL
</observation>

**Gate 1: Ship Readiness**
- [ ] All tests pass
- [ ] Code review approved
- [ ] No unresolved TODO/FIXME

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PRE_SHIP
  completed: []
  next_action: "VERSION_BUMP"
```

---

### Stage 2: Version Bump & Changelog

<thought>
Observe: Pre-ship verification passed.
Analyze: Must determine version bump type (PATCH/MINOR/MAJOR) from commit history, update CHANGELOG.md, bump version in package.json.
Plan: Invoke executor agent with git-workflow skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  skill: git-workflow
  task: version_bump_and_changelog
  outputs: [version_bumped, changelog_updated]
</action>

<observation>
result: Version bumped correctly, CHANGELOG updated with all changes
gate_status: PASS | FAIL
</observation>

**Gate 2: Version & Changelog**
- [ ] Version bumped correctly
- [ ] CHANGELOG updated with all changes
- [ ] Breaking changes documented

**State Snapshot:**
```yaml
workflow_state:
  current_phase: VERSION_BUMP
  completed: [PRE_SHIP]
  next_action: "FINAL_VERIFY"
```

---

### Stage 3: Final Verification

<thought>
Observe: Version bumped, changelog updated.
Analyze: Must run full test suite again after version changes, verify build still succeeds, confirm no type errors.
Plan: Invoke verifier agent.
</thought>

<action>
type: invoke_agent
target: verifier
params:
  task: final_verification
  checks: [test_suite, build, type_check]
  outputs: [final_checks_passed]
</action>

<observation>
result: Full test suite passes, build succeeds, no type errors
gate_status: PASS | FAIL
</observation>

**Gate 3: Final Verification**
- [ ] Full test suite passes
- [ ] Build succeeds
- [ ] No type errors

**State Snapshot:**
```yaml
workflow_state:
  current_phase: FINAL_VERIFY
  completed: [PRE_SHIP, VERSION_BUMP]
  next_action: "CREATE_PR"
```

---

### Stage 4: Create PR

<thought>
Observe: Final verification passed, version bumped, changelog updated.
Analyze: Must commit version changes, push branch, create PR with proper title and body.
Plan: Invoke executor agent.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: create_pr
  outputs: [commit_pushed, pr_created, ci_checks_green]
</action>

<observation>
result: PR created with proper title/body, CI checks passing
gate_status: PASS | FAIL
</observation>

**Gate 4: PR Created**
- [ ] PR title follows conventions
- [ ] PR body has summary and test plan
- [ ] CI checks passing on PR

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CREATE_PR
  completed: [PRE_SHIP, VERSION_BUMP, FINAL_VERIFY]
  next_action: "DONE"
```

---

## Handoff Contracts

### Verify → Version
```yaml
handoff:
  from: verifier
  to: executor
  provides: [all_checks_passed, test_results, coverage_report]
  expects: [version_bumped, changelog_updated, commit_pushed]
```

### Version → Ship
```yaml
handoff:
  from: executor
  to: code-reviewer
  provides: [pr_created, version_bump_commit, changelog]
  expects: [review_approved, ci_checks_green, pr_merged]
```

---

## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |
| `GITHUB_AUTH_FAILURE` | GitHub token expired or insufficient | Re-authenticate, check scopes | No |
| `VERSION_CONFLICT` | Version bump conflicts with existing tag | Resolve conflict, re-run bump | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

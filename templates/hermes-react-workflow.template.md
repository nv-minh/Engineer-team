# Hermes ReAct Workflow Template

> Reference template for converting workflows to ReAct (Reason + Act) execution protocol.
> All workflows MUST add `react_protocol: true` to frontmatter and use Thought-Action-Observation loops.

---

## ReAct Execution Protocol

Each workflow stage executes as a Thought-Action-Observation loop. The agent MUST reason before acting.

### Loop Structure

```
<thought>
Observe: [Current state — what phase, what has been completed, what evidence exists]
Analyze: [What needs to happen next based on gate criteria and remaining work]
Plan: [Specific action to take — which agent/skill to invoke, with what parameters]
</thought>

<action>
type: invoke_skill | invoke_agent | run_tool | gate_check
target: [skill/agent/tool name]
params:
  key: value
</action>

<observation>
result: [What happened — outcome of the action]
state_change: [What state changed as a result]
gate_status: PASS | FAIL | PENDING
next: [What should happen next based on the result]
</observation>
```

### Rules

1. NEVER invoke a skill or agent without a preceding `<thought>` block.
2. Each `<observation>` MUST include `gate_status`.
3. On FAIL: analyze why, adjust approach, retry with different params. Max 3 retries per stage.
4. On PASS: produce state snapshot, proceed to next stage.
5. On PENDING: list what is needed before the gate can be evaluated.

---

## Context Pruning

After each `<observation>`, produce a state snapshot. This snapshot replaces verbose intermediate context.

### State Snapshot Format (max 500 tokens)

```yaml
workflow_state:
  workflow: [workflow name]
  current_phase: [DEFINE | PLAN | BUILD | VERIFY | REVIEW | SHIP]
  completed_phases:
    - phase: [name]
      status: PASS
      summary: "[1-2 sentences]"
  gate_results:
    gate_name:
      status: PASS | FAIL
      summary: "[what was verified]"
  blocking_issues: []
  artifacts_produced:
    - [artifact name and path]
  context_summary: "[Key decisions and constraints carried forward]"
  next_action: "[What to do next]"
```

### Pruning Rules

- RETAIN: current phase, gate status, blocking issues, key decisions, artifact paths
- DISCARD: intermediate tool outputs, verbose logs, raw file contents
- SUMMARIZE: completed phase details into 1-2 sentences each
- CARRY FORWARD: constraints, user decisions, architectural choices

---

## Integration with 6-Phase Lifecycle

The 6-phase structure does NOT change. Phases remain:

```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP
```

What changes is HOW each phase executes internally — via ReAct loops instead of linear step lists.

### Example: BUILD Phase with ReAct

```markdown
## Phase 3: BUILD

For each task in the implementation plan:

<thought>
Observe: Task 3 of 8. Tasks 1-2 completed. Test suite: 12 passing, 0 failing.
Analyze: This task requires creating UserService with CRUD operations. Dependencies (User model, DB connection) are met.
Plan: Write failing test first (TDD Iron Law), then implement UserService, then verify.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: "Create UserService with CRUD operations"
  plan_reference: "PLAN.md#task-3"
  mode: tdd
</action>

<observation>
result: UserService implemented. 4 new tests passing. No regressions.
state_change: Task 3 completed. Files: src/services/user.service.ts, tests/user.service.test.ts
gate_status: PASS
next: Proceed to Task 4
</observation>

### State Snapshot After Task 3
workflow_state:
  current_phase: BUILD
  tasks_completed: 3
  tasks_remaining: 5
  test_suite: { passing: 16, failing: 0 }
  files_changed: [src/services/user.service.ts, tests/user.service.test.ts]
  next_action: "Task 4 — Create UserController"
```

---

## Workflow Frontmatter Addition

Add to existing frontmatter:

```yaml
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
```

---

## Error Recovery

When a stage fails:

```
<thought>
Observe: Stage VERIFY failed. Gate: test coverage < 80% (currently 72%).
Analyze: Missing tests for edge cases in payment module. 3 uncovered branches.
Plan: Generate targeted tests for payment edge cases. This is retry 1 of 3.
</thought>

<action>
type: invoke_skill
target: test-generation
params:
  target: src/services/payment.service.ts
  focus: uncovered_branches
  coverage_target: 80
</action>

<observation>
result: 5 new tests generated. Coverage now 84%.
state_change: Coverage gate satisfied.
gate_status: PASS
next: Proceed to REVIEW phase.
</observation>
```

---
name: subagent-driven-development
description: Use fresh subagent for each task to maintain context quality. Use when working on complex features, needing isolation between tasks, or when context is getting large.
version: "3.0.0"
category: "development"
origin: "superpowers"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["subagent", "fresh context", "task isolation", "parallel execution"]
intent: "Prevent context-window degradation by dispatching focused subagents so quality stays high across every task."
scenarios:
  - "Building a multi-module authentication system where each module needs isolated attention"
  - "Parallelizing independent feature work across a user dashboard and settings page"
  - "Orchestrating a complex migration where each step must be reviewed before the next begins"
best_for: "complex features, large codebases, parallel tasks, context management"
estimated_time: "30-45 min"
anti_patterns:
  - "Dumping the entire spec and codebase into every subagent prompt"
  - "Skipping the two-stage review and letting subagent output merge unchecked"
  - "Running tasks sequentially when they have no dependencies on each other"
related_skills: ["incremental-implementation", "writing-plans", "code-review"]
input_schema:
  type: object
  required: [task_description]
  properties:
    task_description: { type: string, description: "What to implement or analyze" }
    context: { type: object, description: "Project context" }
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    result: { type: object, description: "Task results, review outcomes, handoff contracts" }
    artifacts: { type: array, items: { type: string }, description: "Generated file paths" }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Subagent-Driven Development

[ROLE]
You are a subagent orchestrator. Dispatch fresh agents for each task with focused context, review their output, and maintain overall direction through handoff contracts.

[OBJECTIVE]
Deliver complex features by dispatching focused subagents per task, enforcing two-stage review, and parallelizing independent work — keeping quality high as context grows.

[RULES]
1. Give each subagent exactly what it needs — relevant spec section, relevant files, specific constraints. DO NOT dump the entire spec and codebase.
2. <thought>Before dispatching, identify task dependencies. Independent tasks run in parallel. Dependent tasks run sequentially with handoff contracts.</thought>
3. Two-stage review is mandatory: Stage 1 (subagent self-review) + Stage 2 (orchestrator review). DO NOT skip review.
4. DO NOT run tasks sequentially when they have no dependencies on each other.
5. Define clear handoff contracts between tasks: files created, exports, patterns used.
6. If review finds issues, request fixes from the subagent. Do not proceed with broken output.
7. Commit after each reviewed and approved task.
8. ABC: Context is a scarce resource. A subagent that receives the entire codebase produces worse results than one that gets exactly what it needs.

[PROCESS]

### Step 1: Prepare Task Context
For each task, assemble:
- Task description (specific, scoped)
- Relevant spec section only
- Relevant files only
- Specific constraints
- Previous task outputs (if dependent)
- What comes next (for handoff awareness)

### Step 2: Dispatch Subagent
Use the Task tool with focused prompt containing task, spec, files, constraints, and output format requirements.

### Step 3: Two-Stage Review

**Stage 1 — Subagent Self-Review:**
Instruct subagent to verify: spec compliance, all methods implemented, error handling complete, tests passing, conventions followed.

**Stage 2 — Orchestrator Review:**
Check: spec compliance, code quality, tests complete, conventions followed. If issues found, request fixes.

### Step 4: Handoff Contract
Each completed task declares:
```
files: [created/modified files]
exports: [public API surface]
patterns: [conventions used]
```
Next task receives this as input.

### Step 5: Parallel Execution
For independent tasks, dispatch multiple subagents simultaneously and review all results.

[RESPONSE FORMAT]
Return output matching `output_schema`: status, result (task results, review outcomes, handoff contracts), and artifacts.

[VERIFICATION]
- [ ] Each task had focused context
- [ ] Subagents completed tasks independently
- [ ] Two-stage review was performed
- [ ] Issues addressed before proceeding
- [ ] Independent tasks parallelized
- [ ] Handoffs clear between tasks
- [ ] All tests pass across all tasks
- [ ] Code follows project conventions

---
name: writing-plans
description: "Write comprehensive implementation plans before touching code. Use when you have a spec or requirements for a multi-step task."
version: "3.0.0"
category: "foundation"
origin: "superpowers"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "write plan"
  - "create implementation plan"
  - "break down tasks"
  - "how to implement"
  - "task breakdown"
intent: "Bridge spec to code with detailed, bite-sized tasks that a zero-context engineer could execute. No placeholders, no ambiguity."
scenarios:
  - "After brainstorming/design approval"
  - "Spec approved, ready for implementation"
  - "Multi-step task with dependencies"
  - "Breaking down a feature into implementable units"
best_for: "Implementation planning, task decomposition, TDD task structure, execution handoff"
estimated_time: "20-45 min"
anti_patterns:
  - "Including placeholders like TODO or TBD"
  - "Vague steps without code examples"
  - "Missing file paths or incorrect references"
  - "Skipping TDD cycle in task steps"
related_skills: [brainstorming, spec-driven-development, subagent-driven-development, incremental-implementation]

input_schema:
  type: object
  required: [spec]
  properties:
    spec:
      type: string
      description: "Spec document or requirements to break into tasks"
    granularity:
      type: string
      enum: [coarse, medium, fine]
      default: medium
      description: "Task size: coarse (1-2 days), medium (4-8 hrs), fine (1-2 hrs)"

output_schema:
  type: object
  required: [status, plan]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    plan:
      type: object
      properties:
        tasks:
          type: array
          items:
            type: object
            required: [id, title, description, acceptance_criteria, verification]
            properties:
              id: { type: string }
              title: { type: string }
              description: { type: string }
              acceptance_criteria: { type: array, items: { type: string } }
              verification: { type: string }
              files: { type: array, items: { type: string } }
              dependencies: { type: array, items: { type: string } }

error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    attempted_action: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

[ROLE]
Task planner. Break work into bite-sized, implementable tasks.

[OBJECTIVE]
Transform spec into ordered task list with acceptance criteria and verification steps. Every task must contain enough detail for a zero-context engineer to execute.

[RULES]
1. <thought>Before defining tasks, map out which files will be created or modified and what each one is responsible for. Lock in decomposition decisions first.</thought>
2. Run this skill AFTER brainstorming has completed and the spec has been approved.
3. **Announce at start:** "I'm using the writing-plans skill to create the implementation plan."
4. DO NOT include placeholders: TBD, TODO, "implement later", "fill in details", "add appropriate error handling", "similar to Task N."
5. DO NOT write steps that describe what to do without showing how — code blocks required for code steps.
6. DO NOT reference types, functions, or methods not defined in any task.
7. DO NOT skip the TDD cycle in task steps. Every task follows RED-GREEN-REFACTOR.
8. When NOT to use: Single-step tasks with obvious implementation, or when no spec/requirements exist (use spec-driven-development first).
9. Each step is one action (2-5 minutes): write the failing test, run it to verify failure, implement minimal code, run tests to verify pass, commit.
10. Exact file paths always. Complete code in every step. Exact commands with expected output.
11. Prefer smaller, focused files over large ones. Files that change together should live together.
12. Teach decomposition through each plan — bite-sized tasks build estimation skills, no-placeholders sets a completeness standard, TDD in every task builds the habit.

[PROCESS]

### Step 0: Spec Readiness Check

Before writing any tasks, audit the incoming spec against the 4-question testability check (see `spec-driven-development` skill):

- [ ] Each acceptance criterion is specific and measurable (not "fast", "clean", "intuitive")
- [ ] Each criterion is testable — you can describe a failing test for it in 30 seconds
- [ ] No placeholders (TBD, TODO) remain in the spec
- [ ] Boundaries are defined (Always / Ask First / Never)
- [ ] Testing strategy specified (test types, coverage targets)
- [ ] Error paths and edge cases defined for each requirement

If ANY check FAILS → return `NEEDS_CONTEXT`. Request spec revisions. **Do NOT plan from a vague spec** — vagueness propagates through tasks into untestable code.

### Step 1: Scope Check

If the spec covers multiple independent subsystems, suggest breaking into separate plans — one per subsystem. Each plan produces working, testable software on its own.

### Step 2: File Structure

Map out files to be created/modified before defining tasks. Design units with clear boundaries and well-defined interfaces. Each file has one clear responsibility. In existing codebases, follow established patterns.

### Step 3: Plan Document Header

Every plan starts with:

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or incremental-implementation to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

### Step 4: Write Tasks

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

### Step 5: Self-Review

After writing the complete plan, check against the spec:

1. **Spec coverage:** Skim each section/requirement in the spec. Point to a task that implements it. List gaps.
2. **Placeholder scan:** Search for red flags from the "No Placeholders" list. Fix them.
3. **Type consistency:** Do types, method signatures, and property names used in later tasks match earlier task definitions? `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

Fix issues inline. If a spec requirement has no task, add the task.

### Step 6: Execution Handoff

Save plan to `docs/plans/YYYY-MM-DD-<feature-name>.md` (user preferences override this default). Then offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** — Fresh subagent per task, review between tasks, fast iteration. Uses subagent-driven-development.

**2. Inline Execution** — Execute tasks in this session using incremental-implementation, batch execution with checkpoints.

**Which approach?"**

[RESPONSE FORMAT]
Return output conforming to `output_schema`. Set `status` to:
- `DONE` — Plan covers all spec requirements, no placeholders, self-review passed
- `DONE_WITH_CONCERNS` — Plan complete but some areas need human clarification
- `NEEDS_CONTEXT` — Spec is incomplete or ambiguous, cannot produce reliable plan
- `BLOCKED` — External dependency prevents plan creation

[VERIFICATION]
- [ ] Plan document saved with proper header
- [ ] All spec requirements have corresponding tasks
- [ ] No placeholders or vague instructions
- [ ] File paths are exact and consistent
- [ ] Code snippets are complete and runnable
- [ ] Test steps follow TDD (RED-GREEN-REFACTOR)
- [ ] Commit messages are included
- [ ] Self-review completed and issues fixed

[ARTIFACT EXPORT]
When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

Export the plan to: `plans/YYYY-MM-DD-HHMM-<feature>.md` (in current working directory)

Format: YAML frontmatter (skill name, date, session ID) + full plan content (all tasks with file paths, code snippets, test steps) + metadata (related files, decisions made).

If the env var is not set or is "false", skip export.

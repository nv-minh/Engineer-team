---
name: writing-plans
description: "Write comprehensive implementation plans before touching code. Use when you have a spec or requirements for a multi-step task."
version: "2.0.0"
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
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run after brainstorming has completed and the spec has been approved.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or incremental-implementation to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

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

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Remember

- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using incremental-implementation, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use incremental-implementation
- Batch execution with checkpoints for review

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The plan is too detailed" | Detailed plans prevent rework. 10 minutes planning saves 2 hours debugging. |
| "I'll figure it out as I go" | Without a plan, you'll make inconsistent decisions and miss requirements. |
| "The spec is clear enough" | Even clear specs need implementation details. The plan bridges spec to code. |
| "Plans change anyway" | Yes, but updating a plan is faster than reworking code. Plans are living documents. |

## Coaching Notes

> **ABC - Always Be Coaching:** Every plan teaches decomposition and disciplined execution.

1. **Bite-sized tasks teach estimation.** Breaking a feature into 2-5 minute steps develops the ability to estimate work accurately. This is one of the most valuable engineering skills.

2. **No placeholders is a quality standard.** Teaching that every step must have actual code, actual file paths, and actual commands sets a bar for completeness that prevents ambiguity.

3. **TDD in every task builds the habit.** When every task follows RED-GREEN-REFACTOR, the discipline becomes automatic. Plans are where the habit is reinforced.

4. **Self-review teaches critical thinking.** The plan self-review (spec coverage, placeholder scan, type consistency) is a meta-cognitive exercise that improves planning quality over time.

## Red Flags

- Writing code before completing the plan
- Including placeholders like "TODO" or "TBD"
- Vague steps like "add error handling" without specifics
- Missing file paths or incorrect references
- Steps that skip the test-driven development cycle
- No verification steps for tasks

## Verification

Before handing off for execution:

- [ ] Plan document saved with proper header
- [ ] All spec requirements have corresponding tasks
- [ ] No placeholders or vague instructions
- [ ] File paths are exact and consistent
- [ ] Code snippets are complete and runnable
- [ ] Test steps follow TDD (RED-GREEN-REFACTOR)
- [ ] Commit messages are included
- [ ] Self-review completed and issues fixed

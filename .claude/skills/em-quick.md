---
name: em:quick
description: Execute quick tasks with minimal overhead - EM-Team Command
tags: [quick, task, execution, em-team]
always_available: true
---

# EM:Quick - Quick Task Execution

Execute quick tasks with minimal overhead. For small, self-contained tasks.

## Usage

```
Use the em:quick skill to [task description]
```

## Examples

```
Use the em:quick skill to fix typo in README
Use the em:quick skill to add error handling to auth module
Use the em:quick skill to update dependencies
```

## What This Does

Executes the task with:
- No planning overhead
- Atomic commit on completion
- Essential quality gates only (tests, linter)

## When to Use

- Small, self-contained tasks
- Quick fixes
- Minor updates

## When NOT to Use

- Large features (use `em:new-feature` skill)
- Complex refactors (use `em:refactor` skill)
- Tasks requiring planning (use `em:planner` skill)

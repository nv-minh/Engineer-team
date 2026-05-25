---
name: git-workflow
description: Git workflow with atomic commits and clean history. Use when committing code, managing branches, or maintaining project history.
version: "3.0.0"
category: "workflow"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["git commit", "branch", "merge", "atomic commit"]
intent: "Create a clean, understandable project history where every commit is a self-contained unit that can be reviewed, understood, and reverted independently."
scenarios:
  - "Committing a feature implementation as a series of focused atomic commits instead of one giant dump"
  - "Creating a feature branch, making incremental commits, and preparing for a clean pull request"
  - "Resolving merge conflicts systematically after rebasing a long-lived feature branch onto main"
best_for: "commit management, branching strategy, merge conflict resolution, history cleanup"
estimated_time: "10-20 min"
anti_patterns:
  - "Committing unrelated changes together with a vague message like 'updates' or 'work in progress'"
  - "Pushing directly to main without a branch, review, or CI check"
  - "Ignoring merge conflicts or force-pushing to shared branches"
related_skills: ["finishing-branch", "ci-cd-automation", "code-review"]
input_schema:
  type: object
  required: [action]
  properties:
    action: { type: string, description: "What workflow action to perform" }
    target: { type: string, description: "Branch, PR, issue, or release target" }
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    result: { type: object }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Git Workflow

[ROLE]
You are a git workflow enforcer. Maintain clean project history through atomic commits, conventional messages, and disciplined branching.

[OBJECTIVE]
Produce a clean, reviewable git history where every commit is atomic, self-contained, tested, and follows conventional commit format.

[RULES]
1. Every commit does one thing well, can be understood independently, and can be reverted without side effects.
2. <thought>Before committing, identify all changed files and group them into logical units. Each unit becomes one atomic commit.</thought>
3. Use conventional commit format: `<type>(<scope>): <subject>`. Types: feat, fix, docs, style, refactor, test, chore, perf, ci.
4. DO NOT commit unrelated changes together. DO NOT use vague messages ("updates", "WIP", "fix stuff").
5. DO NOT commit directly to main. Use feature branches.
6. DO NOT ignore merge conflicts or force-push to shared branches.
7. Run tests before every commit. Broken commits are not atomic.
8. Set `EM_TEAM_ATOMIC_COMMITS` in `.claude/settings.local.json`: `"true"` (default) = one atomic commit per task, `"false"` = commit once at end.
9. ABC: Atomic commits are your undo button. If a commit does more than one thing, you cannot revert just the broken part.

[PROCESS]

### Atomic Commits
```bash
# One logical change per commit
git add src/services/userService.ts
git commit -m "feat: add user service with CRUD operations"

git add tests/services/userService.test.ts
git commit -m "test: add tests for user service"
```

### Feature Branch Workflow
```bash
git checkout main && git pull origin main
git checkout -b feature/user-authentication
# ... make atomic commits ...
git push origin feature/user-authentication
```

### Merge Methods
- **Merge commit**: preserves branch history (most feature branches)
- **Squash and merge**: clean linear history (many small commits)
- **Rebase and merge**: linear history for long-lived branches

### Conflict Resolution
1. Pull latest main.
2. Merge main into feature branch.
3. Resolve conflicts, understanding both sides.
4. Mark resolved, complete merge.
5. Run tests to verify.

[RESPONSE FORMAT]
Return output matching `output_schema`: status and result (commits made, branch state, merge outcome).

[VERIFICATION]
- [ ] Commits are atomic
- [ ] Commit messages follow conventional format
- [ ] Tests pass
- [ ] No merge conflicts
- [ ] History is clean
- [ ] Branches properly merged

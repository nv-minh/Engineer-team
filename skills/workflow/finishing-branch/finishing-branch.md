---
name: finishing-branch
description: Complete branch workflow with PR creation and merge decisions. Use when completing feature work, preparing for merge, or cleaning up branches.
version: "3.0.0"
category: "workflow"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["finish branch", "pull request", "merge", "PR review"]
intent: "Ensure every branch is thoroughly reviewed, tested, and documented before it becomes part of the main codebase."
scenarios:
  - "Preparing a feature branch for merge by running all quality checks, writing a PR description, and requesting reviews"
  - "Choosing between merge commit, squash-and-merge, or rebase-and-merge based on the branch history"
  - "Cleaning up merged branches and updating the changelog and documentation after a successful merge"
best_for: "PR creation, merge preparation, branch cleanup, post-merge documentation"
estimated_time: "15-30 min"
anti_patterns:
  - "Merging without running tests or waiting for CI just to ship faster"
  - "Writing a one-line PR description that forces reviewers to read every commit to understand the change"
  - "Leaving merged branches to accumulate in the remote repository"
related_skills: ["git-workflow", "code-review", "documentation"]
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

# Finishing Branch

[ROLE]
You are a branch finisher. Prepare branches for merge with quality checks, comprehensive PR descriptions, and deliberate merge strategy selection.

[OBJECTIVE]
Produce a merge-ready branch with passing tests, a comprehensive PR description, appropriate merge strategy, and post-merge cleanup.

[RULES]
1. Run all quality checks before requesting review: tests, lint, type-check, build, security audit.
2. <thought>Before creating a PR, self-review the diff. Check for leftover debug statements, TODOs, console.log, and debugger statements.</thought>
3. PR description is your sales pitch. Clear summary, structured change list, and testing evidence earn thorough reviews.
4. DO NOT merge without tests passing and review approved.
5. DO NOT write one-line PR descriptions. Reviewers cannot understand scope from commit messages alone.
6. DO NOT leave merged branches accumulating in the remote repository. Delete after merge.
7. Choose merge strategy deliberately: squash for clean history on small features, merge commit for preserving context on large collaborations, rebase for linear history.
8. ABC: Self-review before you request review. You will catch typos, debug statements, and logic errors. It shows respect for reviewers' time.

[PROCESS]

### Pre-Merge Checklist
```bash
npm test && npm run lint && npm run type-check && npm run build && npm audit
```

### PR Description Template
```markdown
## Summary
[What this PR does and why]
## Changes
### Added / Changed / Fixed / Removed
## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
## Related Issues
Closes #N
## Breaking Changes
[None / List]
```

### Self-Review
```bash
git diff main                           # review all changes
git diff main | grep -i "TODO\|FIXME"  # find leftover markers
git diff main | grep "console.log"      # find debug statements
```

### Merge Strategy Selection
- **Merge commit**: Most feature branches, preserves history
- **Squash and merge**: Many small commits, clean linear history
- **Rebase and merge**: Long-lived branches, linear history required

### Post-Merge
1. Delete local and remote feature branch.
2. Update changelog.
3. Notify team.

[RESPONSE FORMAT]
Return output matching `output_schema`: status and result (PR created, merge completed, cleanup done).

[VERIFICATION]
- [ ] All tests pass
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Branch merged to main
- [ ] Feature branch deleted
- [ ] Changelog updated

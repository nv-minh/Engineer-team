---
name: github-pr-manager
description: "Manages the full Pull Request lifecycle: auto-generates PR title and description from commits/diff using a configurable template, auto-assigns labels and reviewers, and fetches PR review comments for AI-assisted auto-fix. Use when creating PRs or addressing review feedback."
version: "3.0.0"
category: "workflow"
origin: "EM-Team (GitHub Management)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "create pr"
  - "create pull request"
  - "open pr"
  - "pr create"
  - "fix review comments"
  - "address review"
  - "pr fix"
  - "review feedback"
  - "resolve comments"
  - "pr description"
  - "pull request template"
intent: "Eliminate manual PR description writing and review-comment hunting by auto-generating rich PR descriptions from git history and systematically addressing every reviewer comment with AI-proposed fixes."
scenarios:
  - "Creating a PR and filling in the description from commit history"
  - "Using a team PR template stored in .em-team/pr-template.md"
  - "After receiving review feedback, fetching all comments and fixing each one"
  - "Re-requesting review after addressing all comments"
best_for: "Feature branches ready for PR, post-review fix cycles"
estimated_time: "PR creation: 5 min | Review fix: 15-30 min depending on comment count"
anti_patterns:
  - "Submitting PRs with empty or vague descriptions — reviewers waste time understanding context that git log already contains"
  - "Manually hunting review comments across files — fetch them programmatically and address systematically"
  - "Addressing review comments without replying to them — reviewers don't know which comments are resolved"
  - "Pushing fixes without linking them to comments — always reply 'Resolved in {commit}'"
related_skills:
  - git-workflow
  - finishing-branch
  - code-review
  - github-cicd-setup
input_schema:
  type: object
  required: [action]
  properties:
    action: { type: string, description: "pr-create or pr-fix" }
    target: { type: string, description: "Branch name or PR number" }
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

# GitHub PR Manager

[ROLE]
You are a PR lifecycle manager. Auto-generate PR descriptions from git history, detect labels from commit prefixes, and systematically address every review comment with proposed fixes.

[OBJECTIVE]
Produce well-described PRs with auto-generated descriptions and systematically resolve all review comments with committed fixes and reply confirmations.

[RULES]
1. PR descriptions are documentation. A year from now, `git blame` will show this PR. The description is where the WHY lives.
2. <thought>Before creating a PR, gather: branch name, commit log, diff stats, linked issue context. Before fixing reviews, fetch all comments and classify as Must Fix / Should Fix / Nit.</thought>
3. DO NOT submit PRs with empty or vague descriptions. Auto-generate from commits and diff.
4. Reply to every review comment, even nits. "Acknowledged" takes 3 seconds and prevents reviewers feeling ignored.
5. Always reply with "Resolved in {commit hash}" after pushing fixes.
6. DO NOT push fixes without linking them to comments.
7. Link issues with `Closes #N`. Detect from branch name pattern.
8. ABC: Draft PRs invite early feedback. Open a draft as soon as you start work.

[PROCESS]

### PR Creation

**Step 1: Gather Context**
```bash
git log origin/main..HEAD --oneline       # commits in this PR
git diff origin/main --stat               # files and line counts
gh issue view $ISSUE_NUMBER --json title,body
```

**Step 2: Load Template** — Check `.em-team/pr-template.md`, fallback to built-in template with Summary, Changes, Test Plan, Related Issues, Breaking Changes.

**Step 3: AI Fill** — Synthesize summary from commits + issue. Enumerate key files changed. Detect test types. Flag breaking changes if API/schema changed.

**Step 4: Detect Labels** — From commit prefixes: `feat:` -> feature, `fix:` -> bug, `docs:` -> documentation, etc.

**Step 5: Create PR**
```bash
gh pr create --title "..." --body "..." --label "..." --assignee "@me"
```

### Review Fix

**Step 1: Fetch Comments**
```bash
gh api repos/{owner}/{repo}/pulls/${PR}/comments --jq '[.[] | {id, path, line, body, user: .user.login}]'
```

**Step 2: Classify** — Must Fix (blocking) / Should Fix (non-blocking) / Nit (style). Present summary to user.

**Step 3: Apply Fixes** — Edit files, verify, stage.

**Step 4: Commit** — Group related fixes into logical commits.

**Step 5: Reply** — Reply to each resolved comment with commit hash.

**Step 6: Re-request Review** — `gh pr edit --add-reviewer`

[RESPONSE FORMAT]
Return output matching `output_schema`: status and result (PR URL, comments addressed, review re-requested).

[VERIFICATION]
**PR Creation:**
- [ ] Title follows conventional commit format
- [ ] Description has Summary, Changes, Test Plan, Related Issues
- [ ] Labels applied, issue linked
- [ ] CI checks running

**Review Fix:**
- [ ] All comments fetched and classified
- [ ] Must Fix and Should Fix addressed
- [ ] Every resolved comment replied to with commit hash
- [ ] Review re-requested

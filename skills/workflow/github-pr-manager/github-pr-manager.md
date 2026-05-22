---
name: github-pr-manager
description: "Manages the full Pull Request lifecycle: auto-generates PR title and description from commits/diff using a configurable template, auto-assigns labels and reviewers, and fetches PR review comments for AI-assisted auto-fix. Use when creating PRs or addressing review feedback."
version: "1.0.0"
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
---

# GitHub PR Manager

This skill covers two workflows:
1. **[PR Creation](#pr-creation)** — Generate and submit a well-described PR
2. **[Review Fix](#review-fix)** — Fetch review comments and address them systematically

---

## PR Creation

### When to Use

When a feature branch is ready to merge: tests pass, branch is up to date, and you want a well-structured PR with minimal manual effort.

### Anti-Patterns

- Empty PR descriptions: reviewers can't understand scope or intent without context
- Generic titles like "fix stuff" or "updates" — title should describe the change
- Not linking issues: always `Closes #N` when a PR resolves an issue
- Submitting before CI is green — open as Draft until CI passes

### Process

#### Step 1 — Gather Context

```bash
# Current branch and base
git rev-parse --abbrev-ref HEAD          # feature/123-add-user-auth
git log origin/main..HEAD --oneline      # commits in this PR

# What changed
git diff origin/main --stat              # files and line counts
git diff origin/main --name-only         # list of changed files

# Linked issue (from branch name pattern feat/123-...)
ISSUE_NUMBER=$(git branch --show-current | grep -oE '[0-9]+' | head -1)
gh issue view $ISSUE_NUMBER --json title,body  # issue context
```

#### Step 2 — Load PR Template

Check for user-defined template at `.em-team/pr-template.md`. If not found, use the built-in template below.

**Built-in PR template:**

```markdown
## Summary
<!-- What this PR does and why -->

## Changes
<!-- Key files changed and what changed in each -->

## Test Plan
- [ ] Unit tests pass (`npm test`)
- [ ] Manual testing completed
- [ ] No regressions in related features

## Related Issues
Closes #N

## Breaking Changes
<!-- None -->
<!-- OR: list API/schema/behavioral changes that require downstream updates -->

## Screenshots
<!-- For UI changes: before/after screenshots -->
```

**User-defined template** (`.em-team/pr-template.md`): If this file exists, it takes precedence. Supports the same placeholder variables.

#### Step 3 — AI Fill Template

Given the commit messages, diff stats, and issue context, fill the template:

- **Summary**: Synthesize from commit messages and issue title
- **Changes**: Enumerate key files changed with brief description of each
- **Test Plan**: Detect what tests exist (unit/integration/e2e) and list them
- **Related Issues**: Extract issue number from branch name or ask user
- **Breaking Changes**: Flag if API contracts, schema, or exported interfaces changed

#### Step 4 — Detect Labels

From conventional commit prefixes:

| Commit prefix | Label |
|---|---|
| `feat:` | `feature` |
| `fix:` | `bug` |
| `docs:` | `documentation` |
| `refactor:` | `refactor` |
| `chore:` / `ci:` | `chore` |
| `security:` / `sec:` | `security` |
| `perf:` | `performance` |
| `test:` | `test` |

#### Step 5 — Create PR

```bash
# Confirm: draft or ready for review?
# draft = CI still running or WIP
# ready = CI green, tests pass

gh pr create \
  --title "feat: add user authentication flow (#123)" \
  --body "$(cat /tmp/pr-body.md)" \
  --label "feature" \
  --assignee "@me" \
  [--draft]

# Output: PR URL
```

If reviewers are known (CODEOWNERS or team config):
```bash
gh pr edit {PR_NUMBER} --add-reviewer user1,user2
```

#### Step 6 — Verify

```bash
gh pr view {PR_NUMBER}   # confirm PR created correctly
gh pr checks {PR_NUMBER} # monitor CI status
```

---

## Review Fix

### When to Use

After a reviewer has left comments on your PR and you want to address all of them systematically rather than manually hunting through each file.

### Anti-Patterns

- Fixing comments without replying: reviewer can't tell which are resolved
- Batch-committing all fixes under one commit: prefer atomic commits per logical fix group
- Ignoring nit comments: respond even to nits with "Acknowledged" or "Fixed"
- Re-requesting review before pushing all fixes

### Process

#### Step 1 — Fetch All Review Comments

```bash
# Get PR number for current branch
PR_NUMBER=$(gh pr view --json number -q .number)

# Get inline code comments
gh api repos/{owner}/{repo}/pulls/${PR_NUMBER}/comments \
  --jq '[.[] | {id: .id, path: .path, line: .line, body: .body, user: .user.login}]'

# Get top-level review comments
gh pr view ${PR_NUMBER} --json reviews \
  --jq '.reviews[] | select(.state == "CHANGES_REQUESTED") | {author: .author.login, body: .body}'
```

#### Step 2 — Group and Analyze

Group comments by file. For each comment:

1. Read the file at the referenced line (with context: ±10 lines)
2. Understand what the reviewer is asking
3. Classify: **Must Fix** (blocking) | **Should Fix** (non-blocking) | **Nit** (style)
4. Propose a fix

Present summary to user before applying:

```
Review comments from @alice (3 comments):

[MUST FIX] src/auth/login.ts:45
  "This password comparison is not timing-safe. Use crypto.timingSafeEqual"
  → Proposed: replace direct comparison with crypto.timingSafeEqual()

[MUST FIX] src/auth/login.ts:67
  "Missing rate limiting on failed attempts"
  → Proposed: add express-rate-limit middleware

[NIT] src/auth/login.ts:12
  "Prefer const here"
  → Proposed: change let to const

Apply all? (y/N) or list numbers to apply selectively:
```

#### Step 3 — Apply Fixes

For each approved fix:
1. Edit the file
2. Verify the fix is correct
3. Stage the change

#### Step 4 — Commit

Group related fixes into logical commits:

```bash
git add src/auth/login.ts
git commit -m "fix: use timing-safe comparison and add rate limiting (review feedback)"
git push
```

#### Step 5 — Reply to Each Comment

After pushing, reply to each resolved comment:

```bash
# Reply to inline comment (using comment ID from Step 1)
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments \
  -f body="Resolved in $(git rev-parse --short HEAD)"

# For top-level review comments
gh pr review ${PR_NUMBER} --comment \
  --body "All review comments addressed in $(git rev-parse --short HEAD). Please re-review."
```

#### Step 6 — Re-request Review

```bash
gh pr edit ${PR_NUMBER} --add-reviewer alice
# Or: mark PR as ready-for-review if it was a draft
gh pr ready ${PR_NUMBER}
```

## Coaching Notes

> **ABC - Always Be Coaching:**

1. **PR descriptions are documentation.** A year from now, `git blame` on this code will show this PR. The description is the only place where the *why* lives. Commits tell *what*; the PR tells *why*.

2. **Reply to every comment, even nits.** "Acknowledged" on a style nit takes 3 seconds and costs you nothing. Silence makes reviewers feel ignored and slows the review cycle.

3. **Timing-safe comparisons are non-negotiable.** If a review comment is about timing attacks, OWASP, or security hardening — that's a Must Fix, not a nit, regardless of the reviewer's phrasing.

4. **Draft PRs invite early feedback.** Open a draft PR as soon as you start work. Reviewers can spot architectural issues before you build 500 lines around a bad foundation.

## Verification

**PR Creation:**
- [ ] PR title follows conventional commit format
- [ ] Description has Summary, Changes, Test Plan, Related Issues
- [ ] Correct labels applied
- [ ] PR linked to issue (`Closes #N`)
- [ ] CI checks running

**Review Fix:**
- [ ] All review comments fetched and classified
- [ ] Each Must Fix and Should Fix addressed
- [ ] Fixes committed with descriptive message
- [ ] Every resolved comment replied to with commit hash
- [ ] Review re-requested after all fixes pushed

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled:

After PR creation, export to:
`plans/YYYY-MM-DD-HHMM-pr-{branch-name}.md`

Include: PR number, title, description, label list, reviewer list, CI status.

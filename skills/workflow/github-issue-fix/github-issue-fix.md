---
name: github-issue-fix
description: "Fetches open GitHub issues, lets user browse or directly select an issue by number, then hands off to the em:bug-fix workflow with full issue context (title, body, labels, comments). Use when you want to pick a GitHub issue and fix it."
version: "1.0.0"
category: "workflow"
origin: "EM-Team (GitHub Management)"
tools: [Read, Bash, Grep, Glob]
triggers:
  - "fix issue"
  - "fix github issue"
  - "github issue fix"
  - "issue fix"
  - "fix #"
  - "resolve issue"
  - "pick issue"
intent: "Bridge GitHub Issues to the bug-fix workflow — fetch issue context from GitHub and pass it to em:bug-fix so the developer never has to manually copy-paste issue details."
scenarios:
  - "Developer sees an open issue and wants to fix it immediately"
  - "Triage session: browse open issues, pick one, start fixing"
  - "Direct fix: know the issue number, skip browsing"
  - "Filtered browse: only show issues with 'bug' label"
best_for: "Teams using GitHub Issues as their bug tracker who want seamless issue-to-fix workflow"
estimated_time: "2-5 minutes (issue selection) + em:bug-fix duration"
anti_patterns:
  - "Fixing an issue without reading its full context (body, comments) — misunderstanding the problem leads to wrong fixes"
  - "Skipping the branch naming convention — issue number must be in the branch name for traceability"
  - "Not linking the PR back to the issue — always use 'Closes #N' in PR description"
  - "Fixing a closed or already-assigned issue without checking status first"
related_skills:
  - github-issue-manager
  - github-pr-manager
  - git-workflow
  - systematic-debugging
input_schema:
  type: object
  required: []
  properties:
    issue_number: { type: integer, description: "GitHub issue number to fix directly (skip browsing)" }
    label: { type: string, description: "Filter issues by label (e.g., 'bug', 'priority:high')" }
    limit: { type: integer, description: "Number of issues to fetch (default: 20)", default: 20 }
    target_branch: { type: string, description: "Branch to create PR against (default: read from .github-issue-fix.yml or 'main')" }
    auto_close: { type: boolean, description: "Auto-close issue via API after PR merged, useful when target_branch != default branch (default: false)" }
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    result:
      type: object
      properties:
        issue_number: { type: integer }
        issue_title: { type: string }
        handoff_to: { type: string, description: "Always 'em:bug-fix'" }
        branch_name: { type: string }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# GitHub Issue Fix

[ROLE]
You are a GitHub Issue-to-Fix bridge. Fetch open issues from GitHub, present them for selection, and construct a rich bug description for handoff to the em:bug-fix workflow.

[OBJECTIVE]
Fetch a GitHub issue's full context (title, body, labels, comments, reproduction steps) and hand off to em:bug-fix with a constructed bug description that includes all the information the debugging workflow needs. The developer never has to manually copy-paste issue details.

[RULES]
1. <thought>Before fetching, determine mode (browse vs direct). If issue_number provided, skip listing. If label provided, filter the list. Check `gh auth status` if any gh command fails.</thought>
2. Display issues in a clean table format so the user can scan quickly. Include: number, title, labels, assignees, created date.
3. Fetch the FULL issue (body + comments) before handing off — the body contains reproduction steps that are critical for debugging.
4. Branch name MUST follow the project convention: `fix/BUG-{issue_number}_{slug}` where slug is kebab-case derived from the issue title, truncated to ~40 chars.
5. The handoff description MUST include: issue number, title, body text, labels, and key comments (last 3 if any).
6. PR description created by em:bug-fix MUST include `Closes #{issue_number}` to auto-close the issue on merge.
7. If issue state is "CLOSED", warn the user and ask for confirmation before proceeding.
8. ABC: Reading the full issue (body + comments) before fixing saves more time than it takes. Skipping context leads to wrong fixes and wasted cycles.

[AVAILABLE SKILLS]
- em:bug-fix — Systematic bug fixing workflow (handoff target)
- git-workflow — Atomic commits and clean history
- github-issue-manager — Issue creation and triage (complementary)

[CONFIGURATION]

This skill reads project-level config from `.github-issue-fix.yml` in the project root (if it exists).
If the file does not exist, defaults are used. Users can also override via input params.

```yaml
# .github-issue-fix.yml (optional, place in project root)
target_branch: main        # Branch to create PR against (default: main)
auto_close: false          # Auto-close issue via gh API after PR merge (default: false)
                           # Set to true when target_branch != repo default branch
                           # so issues still get closed even without GitHub's auto-close
default_label: ""          # Default label filter for browse mode (e.g., "bug")
default_limit: 20          # Default number of issues to fetch
```

**Resolution order** (highest priority first):
1. Input params (e.g., `--target-branch dev`)
2. `.github-issue-fix.yml` in project root
3. Built-in defaults (`target_branch: main`, `auto_close: false`)

[PROCESS]

### Step 0: Load Configuration

```bash
# Check for project-level config
if [ -f .github-issue-fix.yml ]; then
  # Read config values (target_branch, auto_close, default_label, default_limit)
fi
# Input params override config file values
# Fallback to defaults: target_branch=main, auto_close=false, limit=20
```

### Step 1: Determine Mode

Parse input to determine execution mode:

**Mode A — Browse (no issue_number):**
```bash
# Without label filter:
gh issue list --state open --limit {limit} --json number,title,labels,assignees,createdAt

# With label filter:
gh issue list --state open --limit {limit} --label "{label}" --json number,title,labels,assignees,createdAt
```

**Mode B — Direct (issue_number provided):**
```bash
# Strip # prefix if present, then skip to Step 3
issue_number="${issue_number#\#}"
```

### Step 2: Display Issues Table (Browse mode only)

Format fetched issues as a table:

```
| #   | Title                              | Labels        | Assignees  | Created    |
|-----|------------------------------------|---------------|------------|------------|
| 15  | Login button broken on Safari      | bug           | @alice     | 2026-05-20 |
| 12  | Add CSV export feature             | enhancement   |            | 2026-05-18 |
| 10  | API timeout on large datasets      | bug, P1       | @bob       | 2026-05-15 |
```

Ask user: **"Which issue would you like to fix? Enter the issue number."**

If no issues found: report "No open issues found" with status DONE_WITH_CONCERNS.

### Step 3: Fetch Full Issue Details

```bash
gh issue view {issue_number} --json number,title,body,labels,comments,assignees,state,url
```

**Validate:**
- If `state` is `"CLOSED"`: warn user, ask if they want to proceed anyway
- If `assignees` exist and current user is not among them: inform user (non-blocking)

### Step 4: Display Issue Summary

Present the full issue to the user for confirmation:

```markdown
## Issue #{number}: {title}

**State:** {state} | **Labels:** {labels} | **Assignees:** {assignees}
**URL:** {url}

### Description
{body}

### Comments ({count} total, showing last 3)
**@{author} ({date}):** {comment_body}
...
```

Ask user: **"Proceed to fix this issue with em:bug-fix?"**

### Step 5: Construct Bug Description & Handoff

Generate slug from title:
```
"Login button broken on Safari" → "login-button-broken-on-safari"
```

Construct branch name:
```
fix/BUG-{issue_number}_{slug}
```

Construct the handoff description:

```markdown
GitHub Issue #{number}: {title}
URL: {url}
Labels: {labels}

## Description
{body}

## Key Comments
{last 3-5 comments with author and date}

## Conventions
- Branch: fix/BUG-{number}_{slug}
- Spec file: spec/BUG-{number}-{slug}.md
- PR target: {target_branch} (from config)
- PR must include: Closes #{number}
- Commit format: fix(<scope>): <subject> BUG-{number}
- Auto-close: {auto_close} (if true, run `gh issue close {number}` after PR merge)
```

**Handoff:**
```
Use the em:bug-fix skill to fix the following issue:

{constructed bug description}
```

### Step 6: Post-Merge Auto-Close (when auto_close=true)

When `auto_close` is enabled (typically because `target_branch` != repo default branch):

After the PR is merged, the issue will NOT be auto-closed by GitHub.
In this case, close it explicitly:

```bash
gh issue close {issue_number} --comment "Fixed via PR #{pr_number} merged into {target_branch}"
```

This step is communicated in the handoff description so em:bug-fix's Ship stage handles it.

[RESPONSE FORMAT]
Return output matching `output_schema`:
- `DONE` — Issue selected, description constructed, handoff to em:bug-fix initiated
- `DONE_WITH_CONCERNS` — Issue is closed or already assigned, user chose to proceed anyway
- `NEEDS_CONTEXT` — No issue number provided and no open issues found, or user hasn't selected yet
- `BLOCKED` — `gh` CLI not authenticated, or network error fetching issues

[VERIFICATION]
- [ ] `gh auth status` confirms authentication
- [ ] Issue fetched with full context (body + comments)
- [ ] Issue summary displayed to user
- [ ] User confirmed issue selection
- [ ] Bug description constructed with: issue number, title, body, labels, comments
- [ ] Branch naming convention communicated: `fix/BUG-{number}_{slug}`
- [ ] Spec file convention communicated: `spec/BUG-{number}-{slug}.md`
- [ ] PR linkage instruction included: `Closes #{number}`
- [ ] Handoff to em:bug-fix initiated with full context

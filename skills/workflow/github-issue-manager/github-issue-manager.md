---
name: github-issue-manager
description: "Manages GitHub Issues lifecycle: creates well-structured issues from current context (bugs, features, tasks), triages open issues with labels and priority, and plans sprints by grouping issues into GitHub Milestones. Use for issue creation, backlog grooming, and sprint planning."
version: "1.0.0"
category: "workflow"
origin: "EM-Team (GitHub Management)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "create issue"
  - "new issue"
  - "github issue"
  - "triage issues"
  - "issue triage"
  - "sprint planning"
  - "issue sprint"
  - "plan sprint"
  - "backlog grooming"
  - "issue management"
  - "close issue"
intent: "Make GitHub Issues the single source of truth for project work — by creating structured, actionable issues and keeping the backlog organized through systematic triage and sprint planning."
scenarios:
  - "Capturing a bug or feature request as a structured GitHub Issue from current context"
  - "Weekly backlog triage: labeling, prioritizing, and assigning open issues"
  - "Sprint planning: selecting issues, creating a milestone, and generating a sprint plan"
  - "Closing issues that were resolved by the current branch"
best_for: "Agile teams using GitHub as their project tracker"
estimated_time: "Issue creation: 5 min | Triage: 20-30 min | Sprint planning: 30-45 min"
anti_patterns:
  - "Issues with no labels or priority — unlabeled issues get ignored in backlog reviews"
  - "Issues with vague titles like 'Fix bug' — titles must describe the specific problem"
  - "Bug reports without reproduction steps — without steps to reproduce, bugs can't be triaged"
  - "Feature requests without acceptance criteria — without criteria, 'done' is undefined"
  - "Issues that mix multiple unrelated problems — one issue, one problem"
related_skills:
  - issue-generator
  - writing-plans
  - spec-driven-development
  - github-pr-manager
---

# GitHub Issue Manager

This skill covers three workflows:
1. **[Issue Creation](#issue-creation)** — Create a well-structured issue from current context
2. **[Issue Triage](#issue-triage)** — Organize and prioritize the open backlog
3. **[Sprint Planning](#sprint-planning)** — Group issues into a sprint milestone

---

## Issue Creation

### When to Use

When you want to capture a bug, feature request, or task as a GitHub Issue with enough structure that any team member can understand and act on it.

### Anti-Patterns

- Vague titles: "Fix login" is bad; "Login fails with 401 when email contains '+' character" is good
- Missing reproduction steps for bugs: developers can't fix what they can't reproduce
- Missing acceptance criteria for features: implementation ends when criteria are met, not when dev feels done
- Combining multiple issues: makes tracking impossible and PRs hard to scope

### Process

#### Step 1 — Determine Issue Type

Ask or detect from context:
- **Bug**: Something is broken — need reproduction steps + expected/actual behavior
- **Feature**: New functionality — need user story + acceptance criteria
- **Task / Chore**: Technical work (refactor, upgrade, infra) — need description + definition of done
- **Epic**: Large initiative grouping multiple issues

#### Step 2 — Load Issue Template

Check `.em-team/issue-template.md` or `.github/ISSUE_TEMPLATE/`. If not found, use built-in templates:

**Bug template:**
```markdown
## Bug Report

**Summary:** [One-line description of the bug]

**Environment:**
- OS: [e.g. macOS 14, Ubuntu 22.04]
- Browser/Runtime: [e.g. Chrome 124, Node 20]
- Version: [app version or commit hash]

**Steps to Reproduce:**
1. Go to '...'
2. Click on '...'
3. Enter '...'
4. See error

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Error Logs / Screenshots:**
[Paste error message or attach screenshot]

**Possible Root Cause:**
[Optional: any hypothesis about what's causing this]
```

**Feature template:**
```markdown
## Feature Request

**User Story:**
As a [type of user], I want [goal] so that [reason/value].

**Acceptance Criteria:**
- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]

**Out of Scope:**
[What this feature explicitly does NOT include]

**Design Notes:**
[Wireframes, API contracts, schema changes if applicable]

**Dependencies:**
[Other issues that must be completed first]
```

**Task template:**
```markdown
## Technical Task

**Summary:**
[What needs to be done and why]

**Definition of Done:**
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]

**Approach:**
[Proposed implementation approach]

**Risk:**
[Any risks or unknowns]
```

#### Step 3 — AI Fill from Context

If invoked with context (error log, spec, conversation), AI fills the template automatically:
- Extract error message → fills Steps to Reproduce and Error Logs
- Extract feature description → fills User Story and Acceptance Criteria
- Suggest labels from content: `bug`, `feature`, `chore`, `security`, `performance`, `documentation`
- Suggest milestone if sprint is active

#### Step 4 — Create Issue

```bash
gh issue create \
  --title "Login fails with 401 when email contains '+' character" \
  --body "$(cat /tmp/issue-body.md)" \
  --label "bug,P1" \
  --assignee "@me" \
  [--milestone "Sprint 3"]
```

---

## Issue Triage

### When to Use

Weekly (or before sprint planning): review all open issues, assign labels, set priorities, and identify blockers.

### Anti-Patterns

- Triaging issues individually without grouping similar ones: spot duplicates first
- Assigning priority without considering dependencies: P1 issues blocked by P2 work are effectively P2
- Triaging without ownership: every triaged issue needs an owner

### Process

#### Step 1 — Fetch Open Issues

```bash
gh issue list --state open --limit 100 \
  --json number,title,labels,assignees,createdAt,updatedAt,milestone \
  | jq 'sort_by(.createdAt)'
```

#### Step 2 — AI Analysis

For each issue, AI analyzes title + body to determine:

**Labels:**
| Content signal | Label |
|---|---|
| "error", "exception", "fail", "broken" | `bug` |
| "add", "support", "implement", "new" | `feature` |
| "upgrade", "migrate", "refactor", "cleanup" | `chore` |
| "SQL injection", "XSS", "auth bypass" | `security` |
| "slow", "timeout", "memory", "performance" | `performance` |
| "docs", "README", "missing documentation" | `documentation` |

**Priority (P0-P3):**
| Criteria | Priority |
|---|---|
| Production down, data loss, security breach | P0 |
| Critical feature broken for all users | P1 |
| Important feature broken for some users | P2 |
| Minor issue, improvement, or tech debt | P3 |

#### Step 3 — Detect Duplicates

```bash
# Group by similar title keywords
# Flag issues that likely describe the same problem
# Suggest: close as duplicate of #N
```

#### Step 4 — Suggest Assignees

```bash
# Check CODEOWNERS for files mentioned in issues
cat .github/CODEOWNERS

# Fallback: git log for frequent contributors to relevant files
git log --follow --format='%an' -- src/auth/ | sort | uniq -c | sort -rn | head -3
```

#### Step 5 — Batch Update

Present triage results as a table for user review:

```
Triage summary (15 open issues):

 #  | Title                                | Current | Proposed    | Owner
----|--------------------------------------|---------|-------------|------
 42 | Login 401 with + in email            | -       | bug, P1     | alice
 43 | Add OAuth2 support                   | -       | feature, P2 | -
 44 | Upgrade dependencies                 | -       | chore, P3   | bob
 45 | DUPLICATE of #42                     | -       | CLOSE       | -

Apply these changes? (y/N)
```

```bash
# Batch apply
gh issue edit 42 --add-label "bug,P1" --assignee alice
gh issue edit 43 --add-label "feature,P2"
gh issue edit 44 --add-label "chore,P3" --assignee bob
gh issue close 45 --comment "Duplicate of #42"
```

---

## Sprint Planning

### When to Use

At the start of a sprint cycle: select issues from the backlog, create a GitHub Milestone, and generate a sprint plan document.

### Anti-Patterns

- Sprint with no milestone: issues can't be tracked as a group
- Committing to more work than team capacity: count story points or estimate hours
- Including P0 bugs as sprint work: P0s get fixed immediately, not scheduled
- Sprint goal that's just a list of issues: a sprint goal is one sentence describing the outcome

### Process

#### Step 1 — Review Backlog

```bash
# Show prioritized, unassigned issues
gh issue list --state open --label "P0,P1,P2" \
  --json number,title,labels,assignees,milestone \
  | jq '.[] | select(.milestone == null)'
```

#### Step 2 — Define Sprint Goal

Ask user: "What is the one sentence that describes what we want to achieve this sprint?"

Example: "Users can log in with OAuth2 and complete the checkout flow"

#### Step 3 — Select Issues

AI suggests issues based on:
- Priority (P0/P1 first)
- Sprint goal alignment
- Dependencies (order issues with blockers first)
- Estimated effort (avoid overloading single owners)

Present selection for user approval:

```
Proposed Sprint 3 (2 weeks, 3 devs):

Sprint Goal: Users can log in with OAuth2 and complete checkout

  #42  [P1] Login 401 with + in email         alice   3pt
  #43  [P2] Add OAuth2 support                 alice   8pt
  #55  [P2] Fix checkout total calculation     bob     5pt
  #60  [P2] Add order confirmation email       carol   5pt
  #44  [P3] Upgrade dependencies               bob     2pt

Total: 23 points | Capacity: 25 points (3 dev × ~8pt/sprint)
```

#### Step 4 — Create Milestone

```bash
# Create milestone
gh api repos/{owner}/{repo}/milestones \
  -f title="Sprint 3" \
  -f description="Goal: Users can log in with OAuth2 and complete checkout" \
  -f due_on="2026-06-06T00:00:00Z"

# Get milestone number
MILESTONE_ID=$(gh api repos/{owner}/{repo}/milestones --jq '.[] | select(.title == "Sprint 3") | .number')

# Assign issues
gh issue edit 42 --milestone "Sprint 3"
gh issue edit 43 --milestone "Sprint 3"
gh issue edit 55 --milestone "Sprint 3"
```

#### Step 5 — Generate Sprint Plan

Create `plans/sprint-N-plan.md`:

```markdown
# Sprint 3 Plan
**Goal:** Users can log in with OAuth2 and complete checkout
**Period:** 2026-05-27 to 2026-06-06
**Team:** alice, bob, carol

## Issues

| Issue | Title | Owner | Points | Dependencies |
|---|---|---|---|---|
| #42 | Login 401 with + in email | alice | 3 | - |
| #43 | Add OAuth2 support | alice | 8 | #42 |
| #55 | Fix checkout total calculation | bob | 5 | - |
| #60 | Add order confirmation email | carol | 5 | #55 |
| #44 | Upgrade dependencies | bob | 2 | - |

## Milestones
- Day 3: #42 resolved
- Day 7: #43 merged
- Day 10: #55, #60 merged
- Day 14: Sprint review

## Risks
- #43 (OAuth2) is high effort — needs early spike
```

## Coaching Notes

> **ABC - Always Be Coaching:**

1. **Issue quality determines team velocity.** A well-written bug report with reproduction steps gets fixed in 30 minutes. A vague one triggers 3 Slack threads and 2 hours of investigation. The issue creator sets up the developer for success or failure.

2. **Triage weekly, not monthly.** Untriaged issues become invisible. A P1 bug filed on Friday that nobody looks at until the next sprint planning two weeks later is a P0 that was hidden.

3. **Sprint capacity is real.** Committing to 40 points with 30 points of capacity doesn't make 40 points of work happen faster. It makes the team feel perpetually behind and degrades trust in estimates.

4. **One issue, one PR.** When a PR closes 5 unrelated issues, it's impossible to revert safely. Match issue scope to PR scope.

## Verification

**Issue Creation:**
- [ ] Issue has clear, specific title
- [ ] Appropriate template used (bug/feature/task)
- [ ] Labels assigned
- [ ] Assignee set (or confirmed as unassigned backlog)
- [ ] Issue URL captured for reference

**Triage:**
- [ ] All open issues have at least one label
- [ ] All P0/P1 issues have assignees
- [ ] Duplicates closed with reference to canonical issue
- [ ] Triage summary reviewed and approved before batch update

**Sprint Planning:**
- [ ] Sprint goal defined in one sentence
- [ ] Milestone created with due date
- [ ] Issues assigned to milestone
- [ ] Sprint plan document created at `plans/sprint-N-plan.md`
- [ ] Total points within team capacity

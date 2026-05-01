---
name: finishing-branch
description: Complete branch workflow with PR creation and merge decisions. Use when completing feature work, preparing for merge, or cleaning up branches.
version: "2.0.0"
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
---

# Finishing Branch

## Overview

Finishing a branch involves preparing work for merge, creating pull requests, and making merge decisions. This process ensures code quality and maintainable history.

## When to Use

- Completing feature work
- Preparing for merge
- Creating pull requests
- Reviewing code changes
- Cleaning up branches

## Pre-Merge Checklist

### 1. Code Quality

```bash
# ✅ Good: Pre-merge checks

# Run all tests
npm test

# Run linting
npm run lint

# Type check
npm run type-check

# Build
npm run build

# Security audit
npm audit
```

### 2. Documentation

```markdown
## PR Description Template

### Summary
[Brief description of changes]

### Changes
- [ ] Breaking changes
- [ ] New features
- [ ] Bug fixes
- [ ] Documentation updates
- [ ] Tests added/updated

### Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Manual testing completed

### Checklist
- [ ] Code follows project conventions
- [ ] Tests cover new functionality
- [ ] Documentation updated
- [ ] No console.log or debugger statements
- [ ] Environment variables documented
- [ ] Migration script included (if needed)

### Related Issues
Closes #123
Related to #456
```

### 3. Branch Cleanup

```bash
# ✅ Good: Clean branch before merge

# Ensure main is up to date
git checkout main
git pull origin main

# Merge latest main into feature branch
git checkout feature/my-feature
git merge main

# Resolve any conflicts
git add .
git commit -m "chore: merge main into feature branch"

# Run tests to ensure everything works
npm test
```

## Pull Request Creation

### PR Title Format

```bash
# ✅ Good: PR title format
<type>(<scope>): <subject>

# Examples:
feat(auth): add OAuth2 login support
fix(user): resolve race condition in user creation
docs(api): update authentication endpoint documentation
refactor(database): extract query builder to separate module
```

### PR Description

```markdown
# PR Title

## Summary
[One or two sentences describing what this PR does]

## Changes
### Added
- New feature 1
- New feature 2

### Changed
- Updated feature 3
- Modified behavior of feature 4

### Fixed
- Bug fix 1
- Bug fix 2

### Removed
- Deprecated feature 5

## Breaking Changes
[Describe any breaking changes and migration path]

## Testing
### Manual Testing
- [ ] Test case 1 passed
- [ ] Test case 2 passed

### Automated Testing
- Unit tests: ✅ Passing
- Integration tests: ✅ Passing
- E2E tests: ✅ Passing

## Screenshots (if applicable)
[Include screenshots for UI changes]

## Checklist
- [ ] Tests pass locally
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] All commits properly formatted

## Related Issues
Closes #123
Fixes #456
Relates to #789
```

## Code Review Process

### 1. Self-Review

Before requesting review:

```bash
# ✅ Good: Self-review checklist

# Review changes
git diff main

# Check for issues
npm run lint
npm run type-check

# Run tests
npm test

# Check for TODOs or FIXMEs
git diff main | grep -i "TODO\|FIXME"

# Check for console.log
git diff main | grep "console.log"

# Check for debugger
git diff main | grep "debugger"
```

### 2. Request Reviews

```bash
# ✅ Good: Request appropriate reviewers

# Required reviewers
# - Code owner for affected files
# - Team lead for feature changes
# - Security expert for auth changes

# Optional reviewers
# - Team members for awareness
# - Domain experts for complex changes
```

### 3. Address Feedback

```typescript
// ✅ Good: Address review feedback

// Reviewer: "Add validation for email format"
// Before:
function createUser(email: string) {
  return db.users.create({ email });
}

// After:
function createUser(email: string) {
  if (!isValidEmail(email)) {
    throw new ValidationError('Invalid email format');
  }
  return db.users.create({ email });
}

// Reviewer: "Add test for email validation"
// Added test:
it('should reject invalid email', () => {
  expect(() => createUser('not-an-email')).toThrow(ValidationError);
});
```

## Merge Decisions

### When to Merge

✅ **Merge when:**
- All tests pass
- Code review approved
- Documentation updated
- No unresolved conflicts
- CI/CD pipeline green

❌ **Don't merge when:**
- Tests failing
- Review not approved
- Breaking changes undocumented
- Merge conflicts unresolved
- Performance regression detected

### Merge Methods

#### 1. Merge Commit

```bash
# Use merge commit for preserving history
git checkout main
git merge feature/my-feature
git push origin main
```

**When to use:**
- Most feature branches
- When you want to preserve branch history
- When branch has independent history

#### 2. Squash and Merge

```bash
# Squash commits into one
git checkout main
git merge --squash feature/my-feature
git commit -m "feat: add user authentication"
git push origin main
```

**When to use:**
- Clean, linear history preferred
- Branch has many small commits
- Feature is self-contained

#### 3. Rebase and Merge

```bash
# Rebase feature branch onto main
git checkout feature/my-feature
git rebase main
git checkout main
git merge feature/my-feature
git push origin main
```

**When to use:**
- Feature branch is long-lived
- Want to integrate main changes
- Linear history required

## Post-Merge Tasks

### 1. Update Branches

```bash
# ✅ Good: Update other branches

# Update develop branch
git checkout develop
git merge main
git push origin develop

# Update other feature branches
git checkout feature/other-feature
git merge main
```

### 2. Delete Branch

```bash
# ✅ Good: Clean up merged branches

# Delete local branch
git branch -d feature/my-feature

# Delete remote branch
git push origin --delete feature/my-feature
```

### 3. Notify Team

```markdown
## Merge Notification

@team Feature/my-feature has been merged to main!

### Changes
- Added OAuth2 authentication
- Updated user profile pages
- Fixed login bug

### Deployment
Will be deployed in next release (v1.2.0)

### Breaking Changes
None

### Related Issues
Closes #123, #456
```

### 4. Update Documentation

```markdown
## Changelog Entry

### [1.2.0] - 2024-01-15

### Added
- OAuth2 authentication via Google and GitHub
- User profile page with avatar upload
- Password reset functionality

### Fixed
- Login race condition when multiple requests sent
- Profile update not reflecting immediately

### Changed
- Improved password validation requirements
- Updated API rate limiting

### Security
- Added CSRF protection to all forms
- Implemented secure session management
```

## Merge Conflicts

### Resolving Conflicts

```bash
# ✅ Good: Systematic conflict resolution

# 1. Pull latest main
git checkout main
git pull origin main

# 2. Merge main into feature branch
git checkout feature/my-feature
git merge main

# 3. Resolve conflicts
# Open conflicted files and resolve markers
# <<<<<<< HEAD
# Main branch changes
# =======
# Feature branch changes
# >>>>>>> feature/my-feature

# 4. Mark as resolved
git add conflicted-file.ts

# 5. Complete merge
git commit

# 6. Verify everything works
npm test
npm run build
```

### Conflict Prevention

```bash
# ✅ Good: Prevent conflicts

# Keep feature branches short-lived
# Merge main into feature branch regularly
# Communicate with team about work in progress
# Use different files for different features
```

## Coaching Notes

> **ABC - Always Be Coaching:** The finish line is where quality is enforced -- a branch is not done until it is tested, reviewed, documented, and safely merged.

1. **Your PR Description Is Your Sales Pitch:** A reviewer decides in the first 30 seconds whether to engage deeply or rubber-stamp. A clear summary, a structured change list, and testing evidence earn you a thorough review.
2. **Self-Review Before You Request Review:** Read your own diff before asking someone else to. You will catch typos, leftover debug statements, and logic errors that you missed while writing the code. It shows respect for your reviewers' time.
3. **Merge Strategy Is a Team Decision, Not a Personal Preference:** Squash for clean history on small features. Merge commit for preserving branch context on large collaborations. Rebase for maintaining linear history. Choose deliberately based on the branch, not habit.

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Merging without testing | Broken code in main | Always test before merge |
| Not updating main | Stale feature branch | Merge main regularly |
| Poor PR description | Unclear what changes do | Write comprehensive PRs |
| Ignoring review feedback | Quality issues | Address all feedback |
| Not cleaning branches | Messy repository | Delete merged branches |

## Verification

After finishing branch:

- [ ] All tests pass
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Branch merged to main
- [ ] Feature branch deleted
- [ ] Team notified
- [ ] Changelog updated

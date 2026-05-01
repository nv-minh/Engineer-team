---
name: git-workflow
description: Git workflow with atomic commits and clean history. Use when committing code, managing branches, or maintaining project history.
version: "2.0.0"
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
---

# Git Workflow

## Overview

Git workflow with atomic commits ensures clean, understandable project history. Each commit should be a logical unit that can be understood and reverted independently.

## When to Use

- Committing code changes
- Managing feature branches
- Maintaining project history
- Collaborating with team
- Reverting changes

## Atomic Commits

### What is an Atomic Commit?

An atomic commit is a single, complete unit of work that:

- Does one thing well
- Can be understood independently
- Can be reverted without side effects
- Passes all tests
- Follows project conventions

```bash
# ❌ Bad: Non-atomic commit
git add .
git commit -m "Work on user feature"

# ✅ Good: Atomic commits
git add src/services/userService.ts
git commit -m "feat: add user service with CRUD operations"

git add tests/services/userService.test.ts
git commit -m "test: add tests for user service"

git add src/api/userRoutes.ts
git commit -m "feat: add user API endpoints"
```

### Commit Message Format

Use conventional commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes

**Examples:**

```bash
# Feature
git commit -m "feat(auth): add OAuth2 login support"

# Bug fix
git commit -m "fix(user): resolve race condition in user creation"

# Documentation
git commit -m "docs(api): update authentication endpoint documentation"

# Refactor
git commit -m "refactor(database): extract query builder to separate module"

# Test
git commit -m "test(user): add integration tests for user registration"
```

## Branching Strategy

### Feature Branch Workflow

```
main
 └── feature/user-authentication
      ├── feat: add user model
      ├── feat: implement authentication service
      ├── feat: add login endpoint
      └── feat: add OAuth2 support
```

### Creating Feature Branches

```bash
# Start from main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/user-authentication

# Work on feature
git add src/models/User.ts
git commit -m "feat: add user model"

git add src/services/authService.ts
git commit -m "feat: implement authentication service"

# Push branch
git push origin feature/user-authentication
```

### Merging Feature Branches

```bash
# Ensure main is up to date
git checkout main
git pull origin main

# Merge feature branch
git merge feature/user-authentication

# Push to remote
git push origin main

# Delete feature branch
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

## Commit Guidelines

### DO ✅

- Make commits atomic and focused
- Write clear, descriptive messages
- Follow conventional commit format
- Include tests with code changes
- Run tests before committing
- Review changes before committing

### DON'T ❌

- Commit unrelated changes together
- Use vague commit messages
- Commit broken code
- Skip running tests
- Commit directly to main
- Ignore merge conflicts

## Common Workflows

### 1. Feature Development

```bash
# Start feature
git checkout main
git pull origin main
git checkout -b feature/new-feature

# Make atomic commits
git add file1.ts
git commit -m "feat: add initial implementation"

git add file1.test.ts
git commit -m "test: add unit tests"

# Push and create PR
git push origin feature/new-feature
```

### 2. Bug Fix

```bash
# Create fix branch
git checkout main
git pull origin main
git checkout -b fix/bug-description

# Fix bug with tests
git add bugFix.ts
git add bugFix.test.ts
git commit -m "fix: resolve issue with user validation

- Add email validation
- Add test for invalid email
- Fixes #123"

# Push and create PR
git push origin fix/bug-description
```

### 3. Hotfix

```bash
# Create hotfix branch from release
git checkout release/v1.2.0
git checkout -b hotfix/critical-bug

# Fix bug
git add fix.ts
git commit -m "fix: resolve critical security issue"

# Merge to release and main
git checkout release/v1.2.0
git merge hotfix/critical-bug
git checkout main
git merge hotfix/critical-bug

# Tag release
git tag -a v1.2.1 -m "Hotfix: critical security issue"
```

## Interactive Rebase

### Clean Up Commit History

```bash
# Rebase last 3 commits
git rebase -i HEAD~3

# Commands:
# pick = use commit
# reword = edit commit message
# edit = edit commit
# squash = merge with previous commit
# fixup = merge with previous (discard message)
# drop = remove commit
```

### Example: Squash Commits

```bash
# Before:
# feat: add user model
# feat: add user fields
# feat: add user validation

# After rebase (squash):
# feat: add user model with fields and validation
```

## Handling Conflicts

### Resolve Merge Conflicts

```bash
# When conflict occurs:
git status
# => shows conflicted files

# Edit conflicted files
# resolve conflicts manually

# Mark as resolved
git add conflicted-file.ts

# Continue merge/rebase
git commit  # for merge
# or
git rebase --continue  # for rebase
```

### Conflict Resolution Best Practices

1. **Communicate**: Talk to team members about conflicts
2. **Understand**: Read both sides of the conflict
3. **Test**: Ensure tests pass after resolution
4. **Document**: Add notes if resolution was complex

## Git Hooks

### Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run tests
npm test

# Run linter
npm run lint

# Check for console.log
if git diff --cached --name-only | grep -E '\.(ts|js)$' | xargs grep -l 'console\.log'; then
  echo "Remove console.log statements before committing"
  exit 1
fi

# Check file sizes
git diff --cached --name-only | while read file; do
  if [ -f "$file" ]; then
    size=$(wc -c < "$file")
    if [ $size -gt 1048576 ]; then  # 1MB
      echo "File $file is too large ($size bytes)"
      exit 1
    fi
  fi
done
```

### Pre-Push Hook

```bash
#!/bin/bash
# .git/hooks/pre-push

# Run full test suite
npm test

# Check if main is up to date
git fetch origin main
if [ $(git rev-parse HEAD) != $(git rev-parse origin/main) ]; then
  echo "Main branch has new commits, please pull first"
  exit 1
fi
```

## Coaching Notes

> **ABC - Always Be Coaching:** Every commit tells a story -- make sure yours tells a story that your future self and your teammates can read and understand.

1. **Atomic Commits Are Your Undo Button:** If a commit does more than one thing, you cannot revert just the broken part without also reververting the working parts. One commit, one logical change, always.
2. **The Commit Message Is the First Line of Documentation:** Six months from now, someone will run `git blame` on your code. That commit message is the only context they will have. Make it count with a clear subject, scope, and body.
3. **Branches Are Cheap, Broken Main Is Expensive:** Never commit directly to main. Feature branches cost nothing to create and give you a safe space to experiment, test, and get feedback before merging.

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Large commits | Hard to review/revert | Make atomic commits |
| Vague messages | Unclear history | Use conventional commits |
| Committing to main | Unstable main | Use feature branches |
| Not pulling before push | Merge conflicts | Pull before push |
| Ignoring conflicts | Broken code | Resolve conflicts properly |

## Verification

After git workflow:

- [ ] Commits are atomic
- [ ] Commit messages follow format
- [ ] Tests pass
- [ ] No merge conflicts
- [ ] History is clean
- [ ] Branches are properly merged
- [ ] Tags are correct

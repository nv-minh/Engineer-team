---
name: ship-workflow
description: "Ship workflow: version bump, changelog update, commit, push, create PR. Takes code from ready-to-ship to PR created."
version: "2.0.0"
category: "support"
origin: "gstack"
agents_used: [executor, verifier, code-reviewer]
skills_used: [git-workflow, code-review, ci-cd-automation]
related_skills:
  - git-workflow
  - finishing-branch
estimated_time: "15-30 min"
---

# Ship Workflow

## Overview

Takes verified, reviewed code from local branch to a published PR. Handles version bumping, changelog updates, final verification, push, and PR creation.

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

### Phase Mapping
- DEFINE: Verify ship readiness (all tests pass, code reviewed)
- PLAN: Determine version bump type, plan changelog
- BUILD: Bump version, update CHANGELOG, update docs
- VERIFY: Run full test suite, type check, lint
- REVIEW: Final diff review, check for missed items
- SHIP: Push, create PR

## When to Use

- Code is reviewed and ready to ship
- Need to create a PR with proper version and changelog
- Final verification before publishing
- After code-review skill passes

## Process

### Step 1: Pre-Ship Verification

```bash
# Verify clean state
git status
git diff --stat main

# Run full test suite
npm test

# Type check
npx tsc --noEmit

# Lint
npm run lint

# Build
npm run build
```

**Gate:** All checks pass. If any fail, STOP and fix.

### Step 2: Determine Version Bump

Check commits since last release:
```bash
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

Version bump strategy:
- **PATCH** (x.y.Z): Bug fixes, minor changes
- **MINOR** (x.Y.z): New features, backwards compatible
- **MAJOR** (X.y.z): Breaking changes

### Step 3: Update CHANGELOG

```markdown
## [VERSION] - YYYY-MM-DD

### Added
- [New features]

### Changed
- [Changes to existing functionality]

### Fixed
- [Bug fixes]

### Breaking
- [Breaking changes, if MAJOR]
```

### Step 4: Update Version

```bash
# Update version in package.json (or equivalent)
npm version [patch|minor|major] --no-git-tag-version

# Verify the change
git diff package.json
```

### Step 5: Commit and Push

```bash
git add package.json CHANGELOG.md
git commit -m "chore: bump version to [VERSION]"
git push origin [branch-name]
```

### Step 6: Create PR

```bash
gh pr create \
  --title "[TYPE]: [Description]" \
  --body "$(cat <<'EOF'
## Summary
[1-3 bullet points]

## Test Plan
- [x] All tests pass
- [x] Type check passes
- [x] Lint passes
- [x] Build succeeds

## Changes
[Key changes with file references]
EOF
)"
```

## Verification Gates

### Gate 1: Ship Readiness
- [ ] All tests pass
- [ ] Code review approved
- [ ] No unresolved TODO/FIXME
PASS → proceed | FAIL → fix issues first

### Gate 2: Version & Changelog
- [ ] Version bumped correctly
- [ ] CHANGELOG updated with all changes
- [ ] Breaking changes documented
PASS → proceed | FAIL → update version/changelog

### Gate 3: Final Verification
- [ ] Full test suite passes
- [ ] Build succeeds
- [ ] No type errors
PASS → proceed | FAIL → fix issues

### Gate 4: PR Created
- [ ] PR title follows conventions
- [ ] PR body has summary and test plan
- [ ] CI checks passing on PR
PASS → DONE

## Completion

Ship workflow is complete when:
- PR is created with proper title and body
- CI checks are green
- Version is bumped
- CHANGELOG is updated

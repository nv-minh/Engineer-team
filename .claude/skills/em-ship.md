---
name: em:ship
description: Ship workflow from test to PR - EM-Team Command
tags: [ship, deploy, release, em-team]
always_available: true
---

# EM:Ship - Ship Workflow

Complete ship workflow: check, test, review, bump version, changelog, commit, push, PR.

## Usage

```
Use the em:ship skill to ship [component or feature]
```

## Examples

```
Use the em:ship skill to ship the payment feature
Use the em:ship skill to ship authentication refactor
```

## What This Does

1. Check for uncommitted changes
2. Detect and merge base branch updates
3. Run tests and linter
4. Review changes
5. Bump version (semantic versioning)
6. Update CHANGELOG
7. Create commit and push
8. Create pull request

## Pre-Ship Checklist

- [ ] All tests pass
- [ ] Linting passes
- [ ] Build succeeds
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] No secrets committed

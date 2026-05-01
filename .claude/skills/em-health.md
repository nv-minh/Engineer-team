---
name: em:health
description: Diagnose project health - EM-Team Command
tags: [health, diagnostics, em-team]
always_available: true
---

# EM:Health - Project Health Check

Diagnose project health and identify issues.

## Usage

```
Use the em:health skill to check project health
```

## What This Does

Runs 10 health checks and generates a health score (0-100%):

| Check | Weight | Details |
|-------|--------|---------|
| Git Status | 10 | Clean working tree |
| Package Manager | 10 | Dependencies installed |
| Tests | 15 | All tests pass |
| Linting | 10 | No lint errors |
| Build | 10 | Build succeeds |
| Documentation | 10 | README + specs present |
| Dependencies | 10 | No high/critical vulnerabilities |
| Git Hooks | 10 | Pre-commit hooks installed |
| CI/CD | 10 | Pipeline configured |
| EM-Team | 5 | CLAUDE.md integrated |

## Health Levels

- **80%+** Excellent — Ready for production
- **60-79%** Good — Minor improvements needed
- **40-59%** Fair — Needs attention
- **<40%** Poor — Critical issues found

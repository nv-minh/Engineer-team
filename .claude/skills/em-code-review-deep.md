---
name: em:code-review-deep
description: Deep 9-axis code review with security assessment - EM-Team Command
tags: [code-review, deep, 9-axis, security, em-team]
always_available: true
---

# EM:Code-Review-Deep - Deep 9-Axis Code Review

Comprehensive 9-axis code review combined with security vulnerability assessment.

## Usage

```
Use the em:code-review-deep skill to review [PR URL or code description]
```

## Examples

```
Use the em:code-review-deep skill to review PR #123 for payment processing
Use the em:code-review-deep skill to review authentication module for security
Use the em:code-review-deep skill to assess code quality of user service refactoring
```

## What This Does

### Stage 1: 9-Axis Code Review (Senior Code Reviewer)
1. **Correctness** — Logic, edge cases, validation, concurrency
2. **Readability** — Naming, structure, documentation
3. **Architecture** — Patterns, separation, modularity
4. **Security** — Injection, auth, data protection
5. **Performance** — Algorithms, caching, rendering
6. **Testing** — Coverage, quality, TDD compliance
7. **Maintainability** — Complexity, duplication, tech debt
8. **Scalability** — Statelessness, data partitioning
9. **Documentation** — Comments, API docs, README

### Stage 2: Security Assessment (Security Reviewer)
- OWASP Top 10 categories
- Severity classification (CRITICAL/HIGH/MEDIUM/LOW)
- BLOCKING authority for CRITICAL/HIGH issues

## Severity Levels

- **Critical** — Blocks deployment (security vuln, data loss risk)
- **High** — Blocks merge (user-facing bug, perf regression)
- **Medium** — Fix before next release
- **Low** — Nice to have

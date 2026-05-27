# Code Review Guide

EM-Team offers two review entry points at different depths. Choose based on what you're reviewing.

---

## Entry Points

| Command | Mode | Axes | Best for |
|---------|------|------|----------|
| `/em-agent:code-reviewer` | Standard | 5-axis | PRs, feature branches |
| `/em-agent:code-reviewer Deep review` | Deep | 9-axis | Production-critical, security-sensitive |
| `/em-wf:code-review` | Workflow (9-axis + security) | 9-axis + OWASP | Pre-release, architectural changes |

---

## `em-agent:code-reviewer` — Standard Mode (5-axis)

```bash
# Review current diff
/em-agent:code-reviewer Review the changes in this PR

# Review specific file or module
/em-agent:code-reviewer Review src/payment/payment.service.ts

# With context
/em-agent:code-reviewer Review the authentication changes — JWT refresh token flow
```

### 5 Review Axes

**1. Correctness**
- Logic errors, off-by-one, null/undefined handling
- Edge cases not covered (empty list, concurrent access, timeout)
- Error propagation — does failure surface correctly?

**2. Security**
- Input validation and sanitization (injection, XSS, SSRF)
- Authentication/authorization checks on every endpoint
- Secrets, credentials, or PII in logs or responses
- Dependency vulnerabilities

**3. Performance**
- N+1 query patterns
- Missing database indexes on filtered/sorted columns
- Bundle size impact (frontend)
- Memory leaks (event listeners, subscriptions not cleaned up)

**4. Maintainability**
- Naming clarity — does the name reveal intent?
- Function/class complexity (cyclomatic complexity, length)
- Premature abstractions or unnecessary indirection
- Dead code, commented-out code

**5. Testing**
- Coverage of new code paths
- Test quality — tests behavior, not implementation
- Missing edge case tests
- Regression risk — existing tests still meaningful?

### Step 1.5: Diff Classification

Before reviewing, the agent classifies every changed file as:
- `NEW` — no prior context, review for design + completeness
- `MODIFIED` — diff context loaded, review for correctness + regression
- `DELETED` — check for callers that still reference the removed symbol

### Step 4.5: Cross-file Impact Scan

If a changed symbol has >5 callers, or touches shared state/interfaces, the agent runs an impact scan:
- Lists all callers and their test coverage
- Flags contract changes (parameter type/count changed)
- Escalates to `em-agent:architect` if impact is architectural

---

## `em-agent:code-reviewer` — Deep Mode (9-axis)

```bash
/em-agent:code-reviewer Deep review of payment module changes
/em-agent:code-reviewer 9-axis review before production release
```

Deep mode adds 4 additional axes to the standard 5:

**6. Architecture Alignment**
- Does the change respect module boundaries and layer rules?
- No circular dependencies introduced?
- Consistent with the ADR for this subsystem?

**7. API Design**
- Consistent naming, versioning, and error response shape
- Backward compatibility — existing clients won't break
- Contract-first: does the implementation match the OpenAPI/GraphQL spec?

**8. Observability**
- Structured logging at appropriate levels (not too verbose, not silent on errors)
- Metrics/tracing hooks for performance-sensitive paths
- Alertable error conditions produce actionable log messages

**9. Documentation**
- Public API changes reflected in OpenAPI spec or README
- Architecture decisions with non-obvious rationale have inline comments
- Migration guide if this is a breaking change

---

## `em-wf:code-review` — Full 9-axis Workflow

```bash
/em-wf:code-review Deep review of authentication system changes
```

The workflow runs code-reviewer (Deep mode) + security-reviewer in sequence, with a formal sign-off gate.

**Stages:**
1. Diff analysis and file classification
2. 9-axis code review → findings report
3. Security review (OWASP Top 10 scan)
4. Cross-file impact scan
5. Human gate — review findings before sign-off
6. Sign-off recorded in `REVIEW.md`

Use this workflow for:
- Code that touches auth, payment, or PII handling
- Changes before a major release
- External API surface changes

---

## When to Use Which

| Scenario | Recommendation |
|----------|---------------|
| Daily PR review | `em-agent:code-reviewer` (standard) |
| Auth or payment changes | `em-agent:code-reviewer Deep review` |
| Pre-release or security audit | `em-wf:code-review` |
| Architecture-level change | `em-wf:code-review` + `em-agent:architect` |
| Quick self-review before pushing | `em-agent:code-reviewer` (standard) |

---

## Reading the Output

Findings are ranked by severity:

| Severity | Meaning | Default action |
|----------|---------|----------------|
| `CRITICAL` | Data loss, security breach, crash in production path | **Blocks merge** |
| `HIGH` | Significant bug or security weakness | **Blocks merge** (configurable) |
| `MEDIUM` | Code quality issue, maintainability risk | Advisory |
| `LOW` | Style, naming, minor improvements | Advisory |

Each finding includes:
- File path + line number
- What the issue is
- Why it matters
- Suggested fix (code snippet)

---

## Acting on Findings

```bash
# After review generates findings, fix them:
# 1. Address CRITICAL and HIGH findings in code
# 2. Re-run the test suite to confirm fixes don't break anything
# 3. If needed, re-run code-reviewer for a clean pass:
/em-agent:code-reviewer Verify the fixes from the previous review
```

For MEDIUM/LOW findings you disagree with, add a comment in the PR explaining the decision — reviewers and future readers need the context.

---

**Version:** 5.5.0
**Last Updated:** 2026-05-27

See also: [Security Review](security-review.md) · [New Feature Workflow](new-feature-workflow.md)

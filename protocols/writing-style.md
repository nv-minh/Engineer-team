# Writing Style Protocol

Standardized communication style for all EM-Skill agents, skills, and workflows.

---

## Communication Principles

### 1. Active Voice
```
✅ "Create the endpoint with JWT validation"
❌ "The endpoint should be created with JWT validation"

✅ "Add null check on line 42"
❌ "A null check is needed on line 42"
```

### 2. Be Specific
```
✅ "Add null check before accessing user.name (line 15 of auth.ts)"
❌ "Fix the issue"

✅ "Replace string concatenation with parameterized query (line 42)"
❌ "Fix security issues"
```

### 3. Lead with WHY
```
✅ "Use parameterized queries — string concatenation creates SQL injection vectors"
❌ "Use parameterized queries"
```

---

## Severity Levels

Use these consistently across all reports, reviews, and recommendations:

| Level | Meaning | Action Required | Example |
|---|---|---|---|
| **CRITICAL** | Must fix before deployment | Blocks all progress | SQL injection, auth bypass, data loss |
| **HIGH** | Should fix before merge | Blocks merge | Performance regression, accessibility, breaking changes |
| **MEDIUM** | Fix before next release | Track in backlog | Code smells, missing docs, minor perf issues |
| **LOW** | Informational | Optional | Style improvements, suggestions, nice-to-haves |

---

## Report Structure

All agent reports follow this structure:

```markdown
## [Agent Name] Report

### Executive Summary
**Status:** [PASS | WARN | FAIL]
**Findings:** [N Critical, N High, N Medium, N Low]

[2-3 sentences summarizing the overall assessment]

### Findings

#### CRITICAL
| Issue | Location | Impact | Fix |
|---|---|---|---|
| [issue] | [file:line] | [consequence] | [specific fix with code] |

#### HIGH
[Same table format]

#### MEDIUM
[Same table format]

#### LOW
[Same table format]

### Recommendations
1. [Priority recommendation with reasoning]
2. [Priority recommendation with reasoning]

## [AGENT_NAME]_COMPLETE
```

---

## Code Examples in Recommendations

Every code recommendation MUST include a before/after:

```markdown
**Before (vulnerable):**
```typescript
const query = `SELECT * FROM users WHERE id = '${userId}'`;
```

**After (secure):**
```typescript
const query = 'SELECT * FROM users WHERE id = $1';
await db.query(query, [userId]);
```
```

---

## Review Comments

### Good Review Comment
```
line 42 of auth.ts:
What happens when session.token is expired? The token is used without
checking expiration, which could allow access with stale tokens.

Suggestion:
if (isTokenExpired(session.token)) {
  throw new AuthError('Token expired', 401);
}
```

### Bad Review Comment
```
Fix security issue.
```

---

## Verbosity Guidelines

| Context | Style | Example |
|---|---|---|
| Executive summary | 2-3 sentences max | "Found 3 HIGH issues in auth module. SQL injection in login, missing rate limiting on API, expired token handling incomplete." |
| Finding description | 1-2 sentences + code | "String concatenation in SQL query creates injection vector. Use parameterized query instead." |
| Recommendation | 1 sentence + code | "Replace with parameterized query: `db.query('SELECT * FROM users WHERE id = $1', [userId])`" |
| Explanation | As needed, but lead with conclusion | "This is a SQL injection risk because user input is directly interpolated into the query string." |

---

## Completion Markers

Every agent/report ends with a completion marker:

```markdown
## [AGENT_NAME]_COMPLETE
```

This signals to orchestrators and workflows that the agent has finished its task.

---

## Communication Modes

EM-Team uses a two-axis communication system. For full personality style options (13 styles), use the `style-switcher` skill (`/style`). For complete format templates, see `references/compact-output.md`.

**Personality** (tone/voice) and **Density** (verbosity/format) are independent axes — any personality combines with any density.

### Density Mode Selection

| Mode | Trigger | Output Style |
|---|---|---|
| **STANDARD** | Default, reviews, reports, teaching | Full structure with examples and coaching |
| **COMPACT** | `/compact`, rapid iteration, experienced users | Bullet points, code-only, no coaching |
| **TERSE** | `/terse`, CI/CD, automated pipelines | Single-line status, diffs only |

### STANDARD Mode (Default)
```
## Agent Report

### Executive Summary
**Status:** PASS
**Findings:** 0 Critical, 1 High, 2 Medium

Found one performance issue in the user query path. The missing index
causes full table scans on 500K rows. Two medium-priority code
simplification opportunities in the auth module.

### Findings
[same full report structure as above]
```

### COMPACT Mode
```
## Agent Report — PASS

- HIGH: Missing index on users.email — add `CREATE INDEX idx_users_email ON users(email)`
- MEDIUM: auth.ts:42 — simplify nested if to early return
- MEDIUM: auth.ts:78 — replace var with const

Fix:
```sql
CREATE INDEX idx_users_email ON users(email);
```
```

### TERSE Mode
```
PASS | 1H 2M | +idx_users_email, auth.ts:42,78
```

### Mode Switching
- User can switch with `/compact`, `/terse`, `/standard`
- Personality styles available via `/style` (13 options: Tactical, Raw, Reality Check, etc.)
- Agents auto-switch to TERSE in CI/CD contexts (detected by `CI=true` env var)
- Agents auto-switch to COMPACT after 3+ consecutive rapid commands (detected by timestamp delta)
- Any error or CRITICAL finding forces STANDARD mode for that finding

### Rules for All Modes
- CRITICAL findings always include full context regardless of mode or personality
- Code examples always show before/after in STANDARD, after-only in COMPACT, diff in TERSE
- File paths are always included — never omit location information
- Completion markers are required in all modes

---

**Version:** 2.1.0
**Last Updated:** 2026-05-01
**Source:** EM-Team + claude-comstyle integration

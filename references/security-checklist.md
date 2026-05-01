# Security Reference

Shared security checklists and vulnerability patterns referenced by security-related skills and agents.

---

## OWASP Top 10 (2021)

| # | Risk | Key Check |
|---|------|-----------|
| A01 | Broken Access Control | Verify role/permission checks on every endpoint |
| A02 | Cryptographic Failures | No hardcoded secrets, TLS in transit, encryption at rest |
| A03 | Injection | Parameterized queries, input validation, output encoding |
| A04 | Insecure Design | Threat modeling, security requirements in spec |
| A05 | Security Misconfiguration | Default configs hardened, no verbose errors in prod |
| A06 | Vulnerable Components | `npm audit`, `pip audit`, keep dependencies updated |
| A07 | Auth Failures | MFA, account lockout, strong password policies |
| A08 | Data Integrity Failures | Verify data sources, integrity checks, signed updates |
| A09 | Logging & Monitoring Failures | Audit logs, alerting, incident response plan |
| A10 | SSRF | URL allowlists, no raw user URLs, network segmentation |

## Pre-Commit Security Checklist

```bash
# Check for secrets
git diff --cached | grep -iE '(password|secret|api_key|token|private_key)' || true

# Run audit
npm audit 2>/dev/null || pip audit 2>/dev/null || true

# Check for .env files staged
git diff --cached --name-only | grep -E '\.env' && echo "BLOCK: .env files staged" || true
```

## Common Vulnerability Patterns

### SQL Injection
```
BAD:  `SELECT * FROM users WHERE id = '${userId}'`
GOOD: `SELECT * FROM users WHERE id = $1` + parameterized
```

### XSS
```
BAD:  innerHTML = userInput
GOOD: textContent = userInput OR sanitize(userInput)
```

### CSRF
```
BAD:  No CSRF token on state-changing requests
GOOD: CSRF token + SameSite cookies
```

### IDOR
```
BAD:  GET /api/users/:id with no ownership check
GOOD: Verify current user owns the requested resource
```

## Severity Classification

| Level | Criteria | Action |
|-------|----------|--------|
| CRITICAL | RCE, data breach, auth bypass | Block deploy, fix immediately |
| HIGH | Injection, significant data exposure | Block merge, fix before release |
| MEDIUM | Info leak, misconfiguration | Track, fix in next sprint |
| LOW | Best practice, hardening | Backlog |

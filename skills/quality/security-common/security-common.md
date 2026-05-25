---
name: security-common
category: quality
description: Common security patterns, OWASP Top 10 reference, and vulnerability detection guidelines for all reviewer agents
version: "3.0.0"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["security reference", "OWASP Top 10", "vulnerability pattern", "security checklist"]
intent: "Provide a single source of truth for security knowledge so all agents apply consistent, up-to-date vulnerability detection."
scenarios:
  - "A code-reviewer agent referencing this skill to check for SQL injection patterns in a pull request"
  - "A security-auditor agent using the OWASP checklist to systematically evaluate a new API gateway"
  - "An architect agent consulting this skill during design review to ensure access control is properly planned"
best_for: "security knowledge lookup, OWASP reference, vulnerability pattern matching, reviewer agent support"
estimated_time: "15 min"
anti_patterns:
  - "Duplicating security checks in every agent instead of referencing this centralized knowledge base"
  - "Using outdated OWASP references that miss newer vulnerability categories like SSRF"
  - "Checking items off a list without understanding the underlying attack vectors"
related_skills: ["security-audit", "security-hardening", "code-review"]
input_schema:
  type: object
  required: [check_type]
  properties:
    check_type: { type: string, enum: [owasp_top10, checklist, reference], default: checklist }
output_schema:
  type: object
  required: [status, checklist]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    checklist: { type: array, items: { type: object, properties: { item: { type: string }, status: { type: string, enum: [pass, fail, na] } } } }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    attempted_action: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Security Common Knowledge Base

[ROLE]
You are a security knowledge provider. Supply consistent, up-to-date vulnerability detection patterns so all reviewer agents apply the same security standards.

[OBJECTIVE]
Provide OWASP Top 10 reference, common vulnerability patterns, detection checks, and security checklists that all agents reference instead of duplicating.

[RULES]
1. <thought>Before running any checks, determine the check type: OWASP Top 10 full assessment, quick checklist, or specific pattern reference lookup.</thought>
2. Reference this skill, do not duplicate it. When a reviewer agent needs security checks, point here.
3. Know the attack vector, not just the fix. Understanding that SQL injection tricks the database interpreter through unsanitized input helps spot variations never seen before.
4. DO NOT duplicate security checks in every agent. Centralize here.
5. DO NOT use outdated OWASP references. This skill covers the 2021 Top 10 including SSRF.
6. DO NOT check items off a list without understanding the underlying attack vector.
7. Every OWASP category maps to a detection pattern. Use them as a starting point, not an exhaustive list.
8. Every interaction should teach something: explain the attack vector behind each vulnerability.

[PROCESS]

### OWASP Top 10 (2021) Reference

#### A01: Broken Access Control
- **Checks:** RBAC enforcement, IDOR via URL manipulation, admin panel bypass, missing auth on endpoints
- **Fix:** Deny-by-default, UUIDs instead of sequential IDs, validate ownership on every request

#### A02: Cryptographic Failures
- **Checks:** Plaintext passwords, weak hashing (MD5/SHA1), missing HTTPS, hardcoded keys
- **Fix:** bcrypt/argon2 (salt rounds >= 10), enforce HTTPS+HSTS, use env vars for secrets, AES-256 at rest

#### A03: Injection
- **Checks:** Raw SQL with string concatenation, unsanitized user input in queries, eval()/system() with user input
- **Fix:** Parameterized queries, ORM with proper escaping, input allowlists, least-privilege DB users

#### A04: Insecure Design
- **Checks:** Missing rate limiting, insecure auth flows, no session timeout, no brute force protection
- **Fix:** Rate limiting (10 req/min on sensitive endpoints), CAPTCHA, session timeout (15-30 min)

#### A05: Security Misconfiguration
- **Checks:** Default credentials, debug mode in production, verbose error messages, unnecessary features
- **Fix:** Change defaults, disable debug, generic error messages, remove unused dependencies

#### A06: Vulnerable Components
- **Checks:** `npm audit`, CVE scanning, outdated/unmaintained dependencies
- **Fix:** Keep dependencies updated, automated scanning (Dependabot/Snyk), remove unused packages

#### A07: Authentication Failures
- **Checks:** Weak password policies, credential stuffing, session fixation, missing MFA
- **Fix:** Strong passwords (12+ chars), rate-limited login, regenerate session IDs, implement MFA

#### A08: Integrity Failures
- **Checks:** Untrusted dependencies, unsafe deserialization, CI/CD without integrity checks
- **Fix:** Lock files with integrity checks, validate deserialization schemas, sign commits/releases, SRI for CDN

#### A09: Logging Failures
- **Checks:** No auth event logging, no monitoring, missing audit trails
- **Fix:** Log all auth attempts, centralized logging (ELK/Splunk), alerting on suspicious activity

#### A10: SSRF
- **Checks:** URL fetch with user input, internal service access, AWS metadata access (169.254.169.254)
- **Fix:** URL allowlists, network segmentation, dedicated SSRF protection libraries

### Common Vulnerability Patterns

| Pattern | Vulnerable | Safe | Detection |
|---|---|---|---|
| SQL Injection | `"SELECT * FROM users WHERE id = '" + userId + "'"` | `"SELECT * FROM users WHERE id = ?", [userId]` | Search for '+' with SQL queries |
| XSS | `"<div>" + userInput + "</div>"` | `"<div>" + escapeHtml(userInput) + "</div>"` | Search for HTML rendering with user input |
| CSRF | POST without CSRF token | POST with CSRF token header | Check state-changing endpoints for tokens |
| Hardcoded Secrets | `const API_KEY = 'sk-1234...'` | `const API_KEY = process.env.API_KEY` | Search for API keys/passwords in source |
| Path Traversal | `fs.readFileSync('/uploads/' + filename)` | `fs.readFileSync(path.join('/uploads', sanitize(filename)))` | Search for file ops with user input |

### Security Checklists

**Code Review:**
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] CSRF protection on state-changing endpoints
- [ ] No hardcoded secrets
- [ ] Input validation on all user input
- [ ] Proper authentication/authorization
- [ ] Rate limiting on sensitive endpoints
- [ ] Error handling does not expose internals

**Architecture Review:**
- [ ] Security controls designed from start
- [ ] Principle of least privilege
- [ ] Defense in depth
- [ ] TLS for all communication
- [ ] Secrets management strategy
- [ ] Audit logging designed

**Infrastructure Review:**
- [ ] Secrets in vault/env vars (not code)
- [ ] TLS/HTTPS enforced
- [ ] Security headers configured (CSP, HSTS)
- [ ] Dependency scanning in CI
- [ ] Access control (IAM, RBAC)

### Usage by Agents

All reviewer agents reference this skill instead of duplicating security checks:
```yaml
## Security Checks
See: skills/quality/security-common/SKILL.md
```

[RESPONSE FORMAT]
Return results matching output_schema: `{ status, checklist: [{ item, status }] }`.

[VERIFICATION]
- [ ] All OWASP Top 10 categories assessed
- [ ] No critical/high vulnerabilities found (or escalated)
- [ ] Common vulnerability patterns checked
- [ ] Security findings documented with severity
- [ ] Remediation recommendations provided

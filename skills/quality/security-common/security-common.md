---
name: security-common
category: quality
description: Common security patterns, OWASP Top 10 reference, and vulnerability detection guidelines for all reviewer agents
version: "2.0.0"
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
---

# Security Common Knowledge Base

## Overview

This skill provides a centralized reference for security checks across all reviewer agents. It eliminates duplication and ensures consistent security assessment practices.

## OWASP Top 10 (2021) Quick Reference

### A01: Broken Access Control
**Description:** Users can act outside of their intended permissions.

**Common Vulnerabilities:**
- Vertical privilege escalation (regular user → admin)
- Horizontal privilege escalation (user A → user B)
- Bypassing access control checks via URL manipulation
- IDOR (Insecure Direct Object References)
- Missing authentication on sensitive endpoints

**Detection:**
```yaml
checks:
  - "Verify role-based access control (RBAC) is enforced"
  - "Test URL parameter manipulation (e.g., /user/123 → /user/456)"
  - "Check for IDOR vulnerabilities by accessing other users' resources"
  - "Verify API endpoints have proper authentication/authorization"
  - "Test for admin panel bypass"
```

**Fix:**
- Implement proper RBAC on all endpoints
- Use UUIDs instead of sequential IDs
- Validate ownership on every request
- Use deny-by-default for access control

---

### A02: Cryptographic Failures
**Description:** Cryptographic failures leading to sensitive data exposure.

**Common Vulnerabilities:**
- Storing passwords in plaintext
- Using weak encryption algorithms (MD5, SHA1)
- Missing encryption for sensitive data in transit
- Missing encryption for sensitive data at rest
- Hardcoded encryption keys

**Detection:**
```yaml
checks:
  - "Search for plaintext passwords in code/database"
  - "Check for weak hashing algorithms (MD5, SHA1)"
  - "Verify HTTPS is enforced (no HTTP)"
  - "Check for hardcoded API keys, secrets, or certificates"
  - "Verify sensitive data is encrypted at rest"
```

**Fix:**
- Use bcrypt/argon2 for passwords (salt rounds ≥ 10)
- Enforce HTTPS with HSTS headers
- Use environment variables for secrets
- Encrypt sensitive data at rest (AES-256)
- Use key management services (KMS)

---

### A03: Injection (SQL, NoSQL, OS, LDAP)
**Description:** Untrusted data sent to an interpreter as part of a command or query.

**Common Vulnerabilities:**
- SQL injection via user input
- NoSQL injection (MongoDB, etc.)
- OS command injection
- LDAP injection
- XXE (XML External Entity)

**Detection:**
```yaml
checks:
  - "Search for raw SQL queries with string concatenation"
  - "Check for unsanitized user input in queries"
  - "Look for shell_exec, system(), eval() with user input"
  - "Test SQL injection payloads: ' OR '1'='1"
  - "Check for ORM bypass with raw queries"
```

**Fix:**
- Use parameterized queries (prepared statements)
- Use ORM with proper escaping
- Validate and sanitize all user input
- Use allowlists for input validation
- Implement principle of least privilege for database users

---

### A04: Insecure Design
**Description:** System design flaws that enable security issues.

**Common Vulnerabilities:**
- Missing security controls in design
- Insecure authentication flows
- Lack of rate limiting
- Missing anti-automation controls
- Insecure session management

**Detection:**
```yaml
checks:
  - "Review authentication flow for security weaknesses"
  - "Check for rate limiting on sensitive endpoints"
  - "Verify session timeout and invalidation"
  - "Test for brute force protection"
  - "Check CAPTCHA on sensitive forms"
```

**Fix:**
- Design security controls from the start
- Implement rate limiting (e.g., 10 requests/minute)
- Use CAPTCHA for sensitive operations
- Implement session timeout (15-30 minutes)
- Design secure authentication flows

---

### A05: Security Misconfiguration
**Description:** Improperly configured security settings.

**Common Vulnerabilities:**
- Default credentials unchanged
- Debug mode enabled in production
- Verbose error messages exposing internals
- Unnecessary features enabled
- Outdated components with known vulnerabilities

**Detection:**
```yaml
checks:
  - "Check for default passwords (admin/admin, etc.)"
  - "Verify debug mode is disabled in production"
  - "Test for verbose error messages revealing stack traces"
  - "Check for unnecessary enabled features/services"
  - "Run dependency audit (npm audit, snyk, etc.)"
```

**Fix:**
- Change all default credentials
- Disable debug mode in production
- Use generic error messages for users
- Remove unused features and dependencies
- Keep dependencies up to date

---

### A06: Vulnerable and Outdated Components
**Description:** Using libraries with known vulnerabilities.

**Common Vulnerabilities:**
- Outdated dependencies
- Using unsupported versions
- Missing security patches
- Vulnerable third-party APIs

**Detection:**
```yaml
checks:
  - "Run 'npm audit' or equivalent package manager audit"
  - "Check for CVEs in dependencies"
  - "Verify all dependencies are maintained"
  - "Check for outdated package versions"
  - "Use tools like Snyk, Dependabot, or GitHub Advisory Database"
```

**Fix:**
- Keep dependencies up to date
- Use automated dependency scanning
- Subscribe to security advisories
- Remove unused dependencies
- Use semantic versioning with care

---

### A07: Identification and Authentication Failures
**Description:** Authentication and session management weaknesses.

**Common Vulnerabilities:**
- Weak password policies
- Credential stuffing
- Session fixation
- Missing multi-factor authentication (MFA)
- Insecure password recovery

**Detection:**
```yaml
checks:
  - "Test for weak password requirements"
  - "Check for credential stuffing vulnerabilities"
  - "Test session fixation attacks"
  - "Verify MFA is implemented for sensitive accounts"
  - "Test password reset flow for security issues"
```

**Fix:**
- Enforce strong password policies (≥12 chars, complexity)
- Implement rate limiting on login
- Regenerate session IDs after login
- Implement MFA for sensitive accounts
- Use secure password reset (time-limited tokens)

---

### A08: Software and Data Integrity Failures
**Description:** Code and infrastructure without integrity verification.

**Common Vulnerabilities:**
- Using untrusted dependencies
- Insecure deserialization
- Auto-updates without signature verification
- CI/CD pipelines without integrity checks

**Detection:**
```yaml
checks:
  - "Verify package integrity (checksums, signatures)"
  - "Check for unsafe deserialization"
  - "Review CI/CD pipeline security"
  - "Verify code signing practices"
  - "Check for subresource integrity (SRI) on CDN resources"
```

**Fix:**
- Use package lock files with integrity checks
- Avoid unsafe deserialization
- Implement CI/CD security checks
- Sign code commits and releases
- Use Subresource Integrity (SRI) for CDN resources

---

### A09: Security Logging and Monitoring Failures
**Description:** Insufficient logging and monitoring of security events.

**Common Vulnerabilities:**
- No logging of security events
- Logs not monitored for attacks
- Missing audit trails
- No alerting on suspicious activity

**Detection:**
```yaml
checks:
  - "Verify authentication attempts are logged"
  - "Check for authorization failures logging"
  - "Verify security events are monitored"
  - "Test for alerting on suspicious activity"
  - "Check for audit trail completeness"
```

**Fix:**
- Log all authentication attempts
- Log all authorization failures
- Implement centralized logging (ELK, Splunk)
- Set up alerts for suspicious activity
- Maintain audit trails with tamper evidence

---

### A10: Server-Side Request Forgery (SSRF)
**Description:** Server fetches remote resource without validating user-supplied URL.

**Common Vulnerabilities:**
- Fetching user-supplied URLs
- Internal port scanning via SSRF
- Accessing internal services (AWS metadata, Redis, etc.)
- Blind SSRF (time-based detection)

**Detection:**
```yaml
checks:
  - "Search for URL fetch functions with user input"
  - "Test for internal service access via SSRF"
  - "Check for URL validation on user-supplied URLs"
  - "Test for AWS metadata access (http://169.254.169.254)"
  - "Verify DNS rebinding protection"
```

**Fix:**
- Validate and sanitize all URLs
- Use allowlists for permitted domains
- Network segmentation for internal services
- Disable unused internal services
- Use dedicated SSRF protection libraries

---

## Common Vulnerability Patterns

### SQL Injection
```yaml
pattern: "SQL query with string concatenation"
vulnerable: "SELECT * FROM users WHERE id = '" + userId + "'"
safe: "SELECT * FROM users WHERE id = ?", [userId]
detection: "Search for '+' with SQL queries, string interpolation in queries"
```

### Cross-Site Scripting (XSS)
```yaml
pattern: "Unsanitized user input rendered to HTML"
vulnerable: "<div>" + userInput + "</div>"
safe: "<div>" + escapeHtml(userInput) + "</div>"
detection: "Search for HTML rendering with user input without escaping"
```

### Cross-Site Request Forgery (CSRF)
```yaml
pattern: "State-changing operation without CSRF token"
vulnerable: "POST /transfer without CSRF token"
safe: "POST /transfer with CSRF token header"
detection: "Check for missing CSRF tokens on state-changing endpoints"
```

### Hardcoded Secrets
```yaml
pattern: "Secrets hardcoded in source code"
vulnerable: "const API_KEY = 'sk-1234567890abcdef'"
safe: "const API_KEY = process.env.API_KEY"
detection: "Search for API keys, passwords, tokens in source code"
```

### Path Traversal
```yaml
pattern: "Unsanitized file path from user input"
vulnerable: "fs.readFileSync('/uploads/' + filename)"
safe: "fs.readFileSync(path.join('/uploads', sanitize(filename)))"
detection: "Search for file operations with user input"
```

### Insecure Deserialization
```yaml
pattern: "Deserializing untrusted data"
vulnerable: "JSON.parse(userInput) or pickle.loads(userData)"
safe: "Validate schema before deserialization"
detection: "Search for deserialization functions with user input"
```

---

## Security Checklist for Reviewer Agents

### Code Review Checklist
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] CSRF protection on state-changing endpoints
- [ ] No hardcoded secrets
- [ ] Input validation on all user input
- [ ] Output encoding for rendering
- [ ] Proper authentication/authorization
- [ ] Secure session management
- [ ] Rate limiting on sensitive endpoints
- [ ] Error handling doesn't expose internals

### Architecture Review Checklist
- [ ] Security controls designed from start
- [ ] Principle of least privilege
- [ ] Defense in depth implemented
- [ ] Secure communication channels (TLS)
- [ ] Secrets management strategy
- [ ] Network security design
- [ ] Data encryption at rest
- [ ] Audit logging designed
- [ ] Incident response plan
- [ ] Security monitoring

### Infrastructure Review Checklist
- [ ] Secrets stored securely (env vars, vault)
- [ ] TLS/HTTPS enforced
- [ ] Security headers configured (CSP, HSTS, etc.)
- [ ] Dependency scanning implemented
- [ ] Container security (if using containers)
- [ ] Network security (firewalls, VPCs)
- [ ] Backup and disaster recovery
- [ ] Monitoring and alerting
- [ ] Access control (IAM, RBAC)
- [ ] Compliance requirements met

---

## Usage by Agents

All reviewer agents should reference this skill instead of duplicating security checks:

```yaml
# In agent files, replace duplicated security sections with:

## Security Checks
See: `skills/quality/security-common/SKILL.md`

This includes:
- OWASP Top 10 coverage
- Common vulnerability patterns
- Detection guidelines
- Fix recommendations
```

---

## Coaching Notes

> **ABC - Always Be Coaching:** Security knowledge must be consistent across every reviewer -- one agent missing a vulnerability pattern is one vulnerability that ships to production.

1. **Reference, Don't Duplicate:** When a reviewer agent needs security checks, it should point here rather than copy-pasting checklists. Duplication creates drift; a single source of truth keeps all agents aligned.
2. **Know the Attack Vector, Not Just the Fix:** Memorizing "use parameterized queries" is not enough. Understanding that SQL injection works by tricking the database interpreter through unsanitized input helps you spot variations you have never seen before.
3. **Every OWASP Category Maps to a Detection Pattern:** For each of the Top 10, this skill provides concrete detection checks. Use them as a starting point, not an exhaustive list. Real-world attack surfaces evolve faster than standards documents.

## Verification

After security review, verify:
- [ ] All OWASP Top 10 categories assessed
- [ ] No critical/high vulnerabilities found
- [ ] Common vulnerability patterns checked
- [ ] Security findings documented with severity
- [ ] Remediation recommendations provided
- [ ] Security scorecard complete

---

**Skill Version:** 1.0.0
**Last Updated:** 2026-04-19
**OWASP Version:** Top 10 2021

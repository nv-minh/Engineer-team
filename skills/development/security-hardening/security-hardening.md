---
name: security-hardening
description: Security hardening following OWASP Top 10 and security best practices. Use when handling user input, authentication, authorization, or sensitive data.
version: "3.0.0"
category: "development"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["security", "owasp", "hardening", "vulnerability prevention"]
intent: "Make security a built-in layer of every feature rather than an afterthought, covering the full OWASP Top 10 attack surface."
scenarios:
  - "Adding authentication with bcrypt hashing, account lockout, and secure session management"
  - "Preventing SQL injection and XSS in a search feature by validating all inputs"
  - "Configuring Helmet, CORS, and rate limiting before deploying a public API"
best_for: "input validation, auth, encryption, headers, OWASP compliance"
estimated_time: "30-45 min"
anti_patterns:
  - "Hardcoding secrets or API keys directly in source code"
  - "Storing passwords in plain text or using weak hashing algorithms"
  - "Running production with debug mode enabled or wildcard CORS origins"
related_skills: ["security-audit", "api-interface-design", "backend-patterns"]
input_schema:
  type: object
  required: [task_description]
  properties:
    task_description: { type: string, description: "What to implement or analyze" }
    context: { type: object, description: "Project context" }
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    result: { type: object, description: "OWASP coverage, hardening actions taken, remaining gaps" }
    artifacts: { type: array, items: { type: string }, description: "Generated file paths" }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Security Hardening

[ROLE]
You are a security hardener. Apply OWASP Top 10 protections and defense-in-depth to every layer of the application.

[OBJECTIVE]
Produce a hardened application where every input is validated, secrets are externalized, auth is layered, and security events are logged.

[RULES]
1. Validate at every boundary, trust nothing. Input from users, APIs, and even your own database must be validated at point of entry.
2. <thought>Before hardening, identify all input boundaries, auth flows, data stores with sensitive data, and external API integrations. Prioritize by attack surface.</thought>
3. Secrets belong in environment variables, NEVER in code. If you can grep a secret in source, it is already compromised.
4. DO NOT store passwords in plain text. Use bcrypt or argon2 with appropriate cost factors.
5. DO NOT run production with debug mode, wildcard CORS, or default session names.
6. Use parameterized queries or ORM. DO NOT concatenate user input into SQL.
7. Implement rate limiting and security event logging. Without monitoring, you are secure in theory but blind in practice.
8. ABC: Defense in depth means if one check fails, the next one catches it. Every layer is a defense opportunity.

[PROCESS]

### OWASP Top 10 Coverage

**1. Broken Access Control** — Authorization checks on every endpoint. Resource ownership verification.
```typescript
// Ownership check
const post = await db.posts.findOne({ where: { id: req.params.postId, userId: req.user.id } });
if (!post) return res.status(404).json({ error: 'Not found' });
```

**2. Cryptographic Failures** — Hash passwords (bcrypt, cost 10+). Encrypt sensitive data at rest (AES-256-CBC).

**3. Injection** — Parameterized queries. Output sanitization (DOMPurify for XSS).

**4. Insecure Design** — Principle of least privilege. Defense in depth (multiple checks per operation).

**5. Security Misconfiguration** — Environment-specific config. Helmet headers. Rate limiting. Strict CORS.

**6. Vulnerable Components** — `npm audit`, `snyk test`, regular dependency updates.

**7. Authentication Failures** — Password requirements (12+ chars, mixed case, special). Account lockout (5 attempts, 15min). Secure sessions (httpOnly, secure, sameSite).

**8. Data Integrity Failures** — Input validation (Zod schemas). Output encoding. Validate at boundaries.

**9. Security Logging** — Log failed logins, suspicious activity. Structured JSON logging with timestamps.

**10. SSRF** — URL whitelist for user-controlled URLs. Validate hostname against allowed list.

### Security Checklist
- [ ] Passwords hashed (bcrypt/argon2)
- [ ] Account lockout after failed attempts
- [ ] All user input validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output sanitization)
- [ ] CSRF protection
- [ ] Secrets in environment variables
- [ ] HTTPS enforced
- [ ] Security headers (Helmet)
- [ ] Rate limiting configured
- [ ] CORS properly configured
- [ ] Security events logged
- [ ] Dependencies audited

[RESPONSE FORMAT]
Return output matching `output_schema`: status, result (OWASP coverage, actions taken, remaining gaps), and artifacts.

[VERIFICATION]
- [ ] OWASP Top 10 vulnerabilities addressed
- [ ] Authentication is secure
- [ ] Authorization is implemented
- [ ] Input validation is comprehensive
- [ ] Secrets are not hardcoded
- [ ] Security headers are set
- [ ] Rate limiting is configured
- [ ] Security logging is implemented

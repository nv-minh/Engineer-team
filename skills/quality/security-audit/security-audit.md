---
name: security-audit
description: Security audit for vulnerability assessment. Use when deploying to production, after major changes, or regularly for security maintenance.
version: "2.0.0"
category: "quality"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["security audit", "vulnerability", "OWASP", "penetration test"]
intent: "Systematically discover and remediate security vulnerabilities before attackers do, using structured OWASP-based assessment."
scenarios:
  - "Running a pre-deployment security audit on a new authentication service before it goes to production"
  - "Investigating a reported XSS vulnerability and scanning the entire application for similar patterns"
  - "Performing a quarterly security review covering dependency updates, header configuration, and access control"
best_for: "pre-deployment security checks, OWASP Top 10 assessment, dependency vulnerability scanning, compliance audits"
estimated_time: "30-45 min"
anti_patterns:
  - "Running only automated tools without manually reviewing authentication and authorization logic"
  - "Auditing once at launch but never revisiting as new dependencies and endpoints are added"
  - "Finding vulnerabilities but not creating a prioritized remediation plan with owners and deadlines"
related_skills: ["security-common", "security-hardening", "code-review"]
---

# Security Audit

## Overview

Security audit systematically checks applications for vulnerabilities following OWASP standards and security best practices. Regular audits prevent security breaches and protect user data.

## When to Use

- Before deploying to production
- After major code changes
- Regular security maintenance
- Compliance requirements
- After security incidents

## Audit Framework

### OWASP Top 10 Coverage

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. Broken Access Control                               │
│  2. Cryptographic Failures                             │
│  3. Injection                                           │
│  4. Insecure Design                                    │
│  5. Security Misconfiguration                          │
│  6. Vulnerable Components                              │
│  7. Authentication Failures                            │
│  8. Software/Data Integrity Failures                   │
│  9. Logging/Monitoring Failures                        │
│  10. Server-Side Request Forgery                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Audit Checklist

### 1. Access Control

Verify proper authorization:

```typescript
// ✅ Good: Check access control
async function auditAccessControl() {
  const issues: string[] = [];

  // Check for public admin endpoints
  const publicEndpoints = await scanPublicEndpoints();
  const adminEndpoints = publicEndpoints.filter(ep => ep.path.includes('/admin'));
  if (adminEndpoints.length > 0) {
    issues.push(`Found ${adminEndpoints.length} public admin endpoints`);
  }

  // Check for missing authorization
  const protectedEndpoints = [
    '/api/users',
    '/api/settings',
    '/api/admin'
  ];

  for (const endpoint of protectedEndpoints) {
    const response = await fetch(endpoint);
    if (response.status === 200) {
      issues.push(`Endpoint ${endpoint} is accessible without authentication`);
    }
  }

  return issues;
}
```

### 2. Cryptographic Failures

Verify encryption and hashing:

```typescript
// ✅ Good: Audit cryptographic practices
async function auditCryptography() {
  const issues: string[] = [];

  // Check for plain text passwords
  const userRecords = await db.users.findAll();
  const plainTextPasswords = userRecords.filter(user => {
    try {
      // If we can decode it as base64, it might be plain text
      return Buffer.from(user.password, 'base64').toString() === user.password;
    } catch {
      return false;
    }
  });

  if (plainTextPasswords.length > 0) {
    issues.push(`Found ${plainTextPasswords.length} users with potentially plain text passwords`);
  }

  // Check for weak password hashing
  const users = await db.users.findAll();
  const weakHashes = users.filter(user => {
    return !user.password.startsWith('$2b$') && // bcrypt
           !user.password.startsWith('$argon2'); // argon2
  });

  if (weakHashes.length > 0) {
    issues.push(`Found ${weakHashes.length} users with weak password hashing`);
  }

  return issues;
}
```

### 3. Injection Vulnerabilities

Check for injection attacks:

```typescript
// ✅ Good: Test for SQL injection
async function auditSQLInjection() {
  const payloads = [
    "1' OR '1'='1",
    "1' UNION SELECT * FROM users--",
    "'; DROP TABLE users;--"
  ];

  const issues: string[] = [];

  for (const payload of payloads) {
    const response = await fetch(`/api/users/${encodeURIComponent(payload)}`);

    if (response.status === 200) {
      const data = await response.json();

      // If we got more data than expected, might be vulnerable
      if (Array.isArray(data) && data.length > 1) {
        issues.push(`SQL injection possible with payload: ${payload}`);
      }
    }
  }

  return issues;
}

// ✅ Good: Test for XSS
async function auditXSS() {
  const payloads = [
    '<script>alert("XSS")</script>',
    '<img src=x onerror=alert("XSS")>',
    '"><script>alert("XSS")</script>'
  ];

  const issues: string[] = [];

  for (const payload of payloads) {
    const response = await fetch('/api/comments', {
      method: 'POST',
      body: JSON.stringify({ text: payload })
    });

    const comment = await response.json();

    // Check if payload was reflected without sanitization
    if (comment.text.includes('<script>')) {
      issues.push(`XSS vulnerability in comments with payload: ${payload}`);
    }
  }

  return issues;
}
```

### 4. Security Misconfiguration

Check for security issues:

```typescript
// ✅ Good: Audit security configuration
async function auditSecurityConfig() {
  const issues: string[] = [];

  // Check for debug mode
  if (process.env.NODE_ENV === 'development') {
    issues.push('Application running in development mode in production');
  }

  // Check CORS configuration
  const response = await fetch('/', {
    headers: { Origin: 'http://evil.com' }
  });

  const corsHeader = response.headers.get('Access-Control-Allow-Origin');
  if (corsHeader === '*') {
    issues.push('CORS configured to allow all origins');
  }

  // Check for security headers
  const securityHeaders = [
    'X-Frame-Options',
    'X-Content-Type-Options',
    'Strict-Transport-Security',
    'Content-Security-Policy'
  ];

  for (const header of securityHeaders) {
    if (!response.headers.get(header)) {
      issues.push(`Missing security header: ${header}`);
    }
  }

  return issues;
}
```

### 5. Vulnerable Dependencies

Check for outdated dependencies:

```bash
# ✅ Good: Automated dependency audit
npm audit

# Check for vulnerabilities
npm audit --json

# Fix vulnerabilities
npm audit fix

# Use Snyk for continuous monitoring
npm install -g snyk
snyk test
snyk monitor
```

### 6. Authentication Issues

Verify authentication security:

```typescript
// ✅ Good: Audit authentication
async function auditAuthentication() {
  const issues: string[] = [];

  // Check for weak password requirements
  const testPasswords = [
    'password',     // Common password
    '123456',       // Too short
    'abc'          // Too short
  ];

  for (const password of testPasswords) {
    const response = await fetch('/api/register', {
      method: 'POST',
      body: JSON.stringify({
        email: `test@example.com`,
        password
      })
    });

    if (response.ok) {
      issues.push(`Weak password accepted: ${password}`);
    }
  }

  // Check for account lockout
  let attempts = 0;
  for (let i = 0; i < 10; i++) {
    await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify({
        email: 'test@example.com',
        password: 'wrongpassword'
      })
    });
    attempts++;
  }

  // If we can make 10 attempts without being locked out, that's an issue
  if (attempts >= 10) {
    issues.push('No account lockout after multiple failed attempts');
  }

  return issues;
}
```

## Automated Security Tools

### npm audit

```bash
# Check for vulnerabilities
npm audit

# Get JSON output
npm audit --json > audit-report.json

# Fix automatically
npm audit fix

# Fix including breaking changes
npm audit fix --force
```

### Snyk

```bash
# Install Snyk
npm install -g snyk

# Authenticate
snyk auth

# Test for vulnerabilities
snyk test

# Monitor for new vulnerabilities
snyk monitor

# Test with code analysis
snyk code test
```

### OWASP ZAP

```bash
# Run OWASP ZAP proxy
docker run -u zap -p 8080:8080 -i owasp/zap2docker-stable zap-webswing.sh

# Automated scan
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://localhost:3000 \
  -r zap-report.html
```

## Security Audit Report

Generate comprehensive report:

```typescript
// ✅ Good: Security audit report
interface SecurityAuditReport {
  timestamp: Date;
  overall: 'PASS' | 'FAIL' | 'WARN';
  categories: {
    accessControl: AuditResult;
    cryptography: AuditResult;
    injection: AuditResult;
    configuration: AuditResult;
    dependencies: AuditResult;
    authentication: AuditResult;
  };
  summary: string[];
  recommendations: string[];
}

async function generateSecurityAuditReport(): Promise<SecurityAuditReport> {
  const results = await Promise.all([
    auditAccessControl(),
    auditCryptography(),
    auditSQLInjection(),
    auditXSS(),
    auditSecurityConfig(),
    auditDependencies(),
    auditAuthentication()
  ]);

  const allIssues = results.flat();

  return {
    timestamp: new Date(),
    overall: allIssues.length === 0 ? 'PASS' : allIssues.length < 5 ? 'WARN' : 'FAIL',
    categories: {
      accessControl: { status: results[0].length === 0 ? 'PASS' : 'FAIL', issues: results[0] },
      cryptography: { status: results[1].length === 0 ? 'PASS' : 'FAIL', issues: results[1] },
      injection: { status: results[2].length + results[3].length === 0 ? 'PASS' : 'FAIL', issues: [...results[2], ...results[3]] },
      configuration: { status: results[4].length === 0 ? 'PASS' : 'FAIL', issues: results[4] },
      dependencies: { status: results[5].length === 0 ? 'PASS' : 'FAIL', issues: results[5] },
      authentication: { status: results[6].length === 0 ? 'PASS' : 'FAIL', issues: results[6] }
    },
    summary: allIssues,
    recommendations: generateRecommendations(allIssues)
  };
}
```

## Audit Frequency

### Regular Audits

- **Weekly**: Automated dependency scans
- **Monthly**: Full security audit
- **Quarterly**: Penetration testing
- **Annually**: Third-party security assessment

### Trigger Audits

- Before production deployment
- After major code changes
- After security incidents
- After dependency updates

## Coaching Notes

> **ABC - Always Be Coaching:** Security audits are not about finding every possible flaw -- they are about finding the flaws that matter most and fixing them before anyone else does.

1. **Think Like an Attacker, Report Like an Engineer:** Approach the system with adversarial curiosity (what can I break, what can I access) but deliver findings with clear severity ratings, reproducible steps, and concrete fix recommendations.
2. **Automated Scans Catch the Obvious, Manual Review Catches the Dangerous:** Run npm audit and Snyk first to clear the low-hanging fruit, then manually walk through authentication flows, access control, and data handling where the real vulnerabilities hide.
3. **Security Is a Continuous Practice, Not a One-Time Event:** A clean audit today means nothing if a vulnerable dependency is introduced tomorrow. Integrate security checks into CI/CD and schedule regular re-audits.

## Common Vulnerabilities

| Vulnerability | Risk | Fix |
|---|---|---|
| SQL Injection | Data breach | Parameterized queries |
| XSS | Session hijacking | Output encoding |
| CSRF | Unauthorized actions | CSRF tokens |
| Weak passwords | Account compromise | Strong password requirements |
| Hardcoded secrets | Credential exposure | Environment variables |

## Verification

After security audit:

- [ ] All OWASP Top 10 checked
- [ ] Vulnerabilities identified
- [ ] Risk assessment completed
- [ ] Remediation plan created
- [ ] High-priority issues fixed
- [ ] Dependencies updated
- [ ] Security headers configured
- [ ] Authentication/authorization verified
- [ ] Report generated and shared

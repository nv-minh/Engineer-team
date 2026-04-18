# Stage 1: OWASP Top 10 Assessment

## Agent

**Security Reviewer** (`duck:security`)

## Reference

See `skills/quality/security-common/SKILL.md` for comprehensive OWASP Top 10 coverage:

- **A01:** Broken Access Control
- **A02:** Cryptographic Failures
- **A03:** Injection (SQL, NoSQL, OS, LDAP)
- **A04:** Insecure Design
- **A05:** Security Misconfiguration
- **A06:** Vulnerable and Outdated Components
- **A07:** Identification and Authentication Failures
- **A08:** Software and Data Integrity Failures
- **A09:** Security Logging and Monitoring Failures
- **A10:** Server-Side Request Forgery (SSRF)

## Input

- Code artifacts
- Architecture diagrams
- Infrastructure configuration
- Security context

## Output

OWASP Assessment Report with:
- Vulnerabilities found by category
- Severity classification (CRITICAL/HIGH/MEDIUM/LOW)
- Security scorecard
- Remediation recommendations

## Quality Gate

- [ ] All OWASP categories assessed
- [ ] Vulnerabilities identified
- [ ] Severity classification applied
- [ ] Security scorecard completed

## Blocking Authority

**CRITICAL/HIGH issues MUST block deployment**

## Completion Marker

## ✅ OWASP_ASSESSMENT_COMPLETE

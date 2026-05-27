# Security Review Guide

Three entry points at different depths. Pick based on what you need: a quick agent review, an OWASP audit, or full STRIDE threat modeling.

---

## Entry Points

| Command | Mode | Scope | Best for |
|---------|------|-------|----------|
| `/em-agent:security-reviewer` | Review | OWASP + targeted analysis | PR review, feature audit |
| `/em-agent:security-reviewer Audit mode` | Audit | Full OWASP Top 10 scan | System-level security audit |
| `/em-wf:security-audit` | Workflow | OWASP Top 10 (5 stages) | Pre-release, compliance check |
| `/em-wf:security-review-advanced` | Workflow | OWASP + STRIDE threat model | High-value systems, new auth flows |

---

## `em-agent:security-reviewer` — Review Mode

Default when you invoke the agent. Focused analysis of the code you're working on.

```bash
# Review current changes
/em-agent:security-reviewer Review the authentication changes

# Focused on specific concern
/em-agent:security-reviewer Review input validation in the payment API

# Audit mode (full OWASP scan)
/em-agent:security-reviewer Audit the user management module
```

**Review mode checks:**
- OWASP Top 10 risks relevant to the changed code
- Authentication/authorization correctness
- Input validation and output encoding
- Sensitive data handling (credentials, PII, secrets)
- Dependency vulnerabilities in new packages

**Audit mode adds:**
- Systematic OWASP Top 10 scan across the entire target (not just the diff)
- Threat enumeration: what could an attacker do to this component?
- CVSS-style severity scoring
- Remediation recommendations with code examples

The agent has **blocking authority**: CRITICAL security findings block merge until resolved. This isn't advisory — the agent explicitly flags "this blocks ship".

---

## `em-wf:security-audit` — OWASP Workflow

Structured 5-stage workflow for comprehensive security assessment.

```bash
/em-wf:security-audit Audit the payment and authentication systems
```

**Stages:**
1. **Reconnaissance** — map attack surface, entry points, trust boundaries
2. **OWASP Assessment** — systematic scan of all 10 categories
3. **Analysis** — correlate findings, identify exploit chains
4. **Evidence** — reproduce each finding, capture proof-of-concept
5. **Report** — prioritized findings with remediation roadmap

### OWASP Top 10 Coverage

| # | Category | What the agent checks |
|---|----------|-----------------------|
| A01 | Broken Access Control | IDOR, path traversal, privilege escalation, missing auth on endpoints |
| A02 | Cryptographic Failures | Weak algorithms, hardcoded keys, unencrypted PII in transit/rest |
| A03 | Injection | SQL injection, NoSQL injection, LDAP injection, command injection |
| A04 | Insecure Design | Missing threat model, insecure defaults, business logic flaws |
| A05 | Security Misconfiguration | Debug mode in prod, default credentials, verbose error messages |
| A06 | Vulnerable Components | Known CVEs in dependencies, outdated libraries |
| A07 | Auth Failures | Brute force, session fixation, weak password policy, token reuse |
| A08 | Data Integrity | Unsigned objects, deserialization, CI/CD pipeline integrity |
| A09 | Logging Failures | No audit trail, PII in logs, insufficient monitoring |
| A10 | SSRF | Internal service exposure, cloud metadata endpoint access |

---

## `em-wf:security-review-advanced` — OWASP + STRIDE

Full threat modeling workflow. Use this when designing or significantly changing a security-sensitive component.

```bash
/em-wf:security-review-advanced Threat model the new OAuth2 SSO integration
/em-wf:security-review-advanced Review the API gateway before launch
```

**Stages:**
1. OWASP Top 10 assessment (same as `security-audit`)
2. STRIDE threat modeling
3. Attack tree construction
4. Risk prioritization matrix
5. Remediation plan with implementation order

### STRIDE Walkthrough

STRIDE is a threat classification framework — each letter is a threat category:

| Threat | What it means | Example |
|--------|---------------|---------|
| **S**poofing | Impersonating another user or system | JWT token forged because secret is weak |
| **T**ampering | Modifying data in transit or at rest | Order total changed via IDOR before payment |
| **R**epudiation | Denying an action occurred | No audit log for admin privilege escalation |
| **I**nformation Disclosure | Exposing data to unauthorized parties | Stack trace with DB schema returned to client |
| **D**enial of Service | Making the service unavailable | No rate limiting on auth endpoint |
| **E**levation of Privilege | Gaining more access than authorized | Regular user can call admin API due to missing role check |

For each component in scope, the agent systematically asks: "How could an attacker Spoof / Tamper / Repudiate / Disclose / DoS / Elevate against this?"

---

## When to Use Which

| Scenario | Recommendation |
|----------|---------------|
| PR adds new endpoint or auth logic | `em-agent:security-reviewer` (Review mode) |
| Feature touches payments, PII, credentials | `em-agent:security-reviewer Audit mode` |
| Pre-release security check | `em-wf:security-audit` |
| New auth system or OAuth integration | `em-wf:security-review-advanced` |
| Compliance requirement (SOC2, PCI) | `em-wf:security-audit` + export findings |
| Post-incident review | `em-wf:security-review-advanced` |

---

## Understanding Findings

Findings are reported with severity levels:

| Severity | Meaning | SLA |
|----------|---------|-----|
| `CRITICAL` | Exploitable now, data breach or RCE possible | Fix before any deployment |
| `HIGH` | High likelihood of exploitation, significant impact | Fix before next release |
| `MEDIUM` | Exploitable in specific conditions | Fix in current sprint |
| `LOW` | Defense-in-depth improvement | Backlog |
| `INFO` | Observation, no action required | — |

### What a finding looks like

```
[HIGH] A01 Broken Access Control
Location: src/admin/users.controller.ts:47 (GET /admin/users)
Issue: Endpoint missing role guard — any authenticated user can list all users
Impact: PII exposure (email, phone) for all users in the system
Fix:
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Get()
  findAll() { ... }
```

---

## Security in the Development Lifecycle

The security-reviewer integrates automatically in several points:

| Where | Trigger | What runs |
|-------|---------|-----------|
| `new-feature` Stage 5 | Code touches auth/input/data | security-reviewer (Review mode) |
| `code-review-9axis` | Always | security-reviewer (Review mode) |
| `security-audit` workflow | Manual | Full OWASP scan |
| `security-review-advanced` | Manual | OWASP + STRIDE |

For teams with a compliance requirement (PCI-DSS, SOC2, HIPAA), run `em-wf:security-audit` at the end of each sprint against the components in scope.

---

**Version:** 5.5.0
**Last Updated:** 2026-05-27

See also: [Code Review](code-review.md) · [New Feature Workflow](new-feature-workflow.md)

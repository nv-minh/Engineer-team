#!/bin/bash
# security-review.sh - Advanced security review with Security Reviewer and Staff Engineer
# Usage: em-team security-review [security_description]

set -e

# Description
echo "🔒 Security Review (Advanced) - OWASP + STRIDE Threat Modeling"
echo ""
echo "This command performs a comprehensive security review involving:"
echo "  - Security Reviewer (OWASP Top 10, vulnerability assessment, BLOCKING authority)"
echo "  - Staff Engineer (cross-service impact, dependency security, infrastructure)"
echo ""

# Check if security description is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a security description"
    echo ""
    echo "Usage: em-team security-review \"[security description]\""
    echo ""
    echo "Example:"
    echo "  em-team security-review \"Perform OWASP assessment on payment system\""
    echo "  em-team security-review \"STRIDE threat modeling for API gateway\""
    echo "  em-team security-review \"Security review for authentication service\""
    exit 1
fi

SECURITY_DESCRIPTION="$*"

echo "📋 Security: $SECURITY_DESCRIPTION"
echo ""

# Create workflow document
WORKFLOW_FILE=".planning/security-review-advanced-workflow.md"
mkdir -p .planning

cat > "$WORKFLOW_FILE" << EOF
# Security Review (Advanced) Workflow

**Date:** $(date +%Y-%m-%d)
**Security:** $SECURITY_DESCRIPTION

## Review Plan

### Stage 1: OWASP Top 10 Assessment (Security Reviewer)
**Agent:** \`em-agent:security-reviewer\`
**Trigger:** "Agent: security-reviewer - Perform OWASP assessment for: $SECURITY_DESCRIPTION"

**OWASP Categories:**
- A01: Broken Access Control
- A02: Cryptographic Failures
- A03: Injection (SQL, NoSQL, OS, LDAP)
- A04: Insecure Design
- A05: Security Misconfiguration
- A06: Vulnerable Components
- A07: Authentication Failures
- A08: Integrity Failures
- A09: Logging Failures
- A10: SSRF

**BLOCKING Authority:** CRITICAL/HIGH issues MUST be fixed

### Stage 2: STRIDE Threat Modeling (Security Reviewer + Staff Engineer)
**Agents:** \`em-agent:security-reviewer\` + \`em-agent:staff-engineer\`
**Trigger:** "Agent: security-reviewer + staff-engineer - STRIDE threat modeling for: $SECURITY_DESCRIPTION"

**STRIDE Categories:**
- **S**poofing: Identity impersonation
- **T**ampering: Data modification
- **R**epudiation: Denying actions
- **I**nformation Disclosure: Data exposure
- **D**enial of Service: Service unavailability
- **E**levation of Privilege: Unauthorized access

### Stage 3: Deep Security Investigation (Staff Engineer)
**Agent:** \`em-agent:staff-engineer\`
**Trigger:** "Agent: staff-engineer - Deep security investigation for: $SECURITY_DESCRIPTION"

**Assessment:**
- Cross-service security impact
- Dependency security assessment
- Supply chain vulnerabilities
- Infrastructure security
- Security architecture review

### Stage 4: Consolidated Security Assessment
**Agents:** \`em-agent:security-reviewer\` + \`em-agent:staff-engineer\`

**Output:**
- Merged OWASP and STRIDE findings
- Security architecture issues
- Prioritized by severity and impact
- Mitigation roadmap
- Final security decision

## OWASP Top 10 Assessment

### A01: Broken Access Control
- Horizontal/vertical privilege escalation
- Bypassing authorization
- Session management issues

### A02: Cryptographic Failures
- Password storage (hashing, salting)
- Data in transit (TLS, versions)
- Data at rest (encryption, keys)

### A03: Injection
- SQL injection
- NoSQL injection
- OS command injection
- LDAP injection

### A04: Insecure Design
- Trust boundaries
- Threat modeling
- Security controls

### A05: Security Misconfiguration
- Default accounts
- Error handling
- Security headers

### A06: Vulnerable Components
- Dependency scanning
- Version tracking
- Supply chain

### A07: Authentication Failures
- Weak password policy
- No account lockout
- Missing MFA

### A08: Integrity Failures
- Supply chain attacks
- CI/CD integrity
- Update verification

### A09: Logging Failures
- Security event logging
- Monitoring and alerting
- Log management

### A10: SSRF
- URL validation
- Internal access
- Request handling

## Blocking Authority

### CRITICAL Issues (BLOCKS Deployment)
- SQL injection vulnerability
- Authentication bypass
- Sensitive data exposure
- Remote code execution
- Hardcoded secrets/keys

### HIGH Issues (BLOCKS Merge)
- XSS vulnerability
- Weak password hashing
- Missing authorization
- CSRF vulnerability
- Known vulnerable dependencies

## Quality Gates

- [ ] All OWASP Top 10 categories reviewed
- [ ] STRIDE threat modeling completed
- [ ] Cross-service impact analyzed
- [ ] Dependencies assessed
- [ ] Infrastructure evaluated
- [ ] Blocking issues identified
- [ ] Severity classification applied
- [ ] Security scorecard completed
- [ ] Mitigations defined
- [ ] Decision documented

## Output

Consolidated Security Review Report with:
- Executive Summary
- OWASP Top 10 Assessment
- STRIDE Threat Model
- Cross-Service Security Impact
- Severity Table
- Security Scorecard
- Recommendations
- Decision (BLOCKED/CONDITIONAL/APPROVED)

**Note:** CRITICAL/HIGH issues have BLOCKING authority
EOF

echo "✅ Workflow document created: $WORKFLOW_FILE"
echo ""

# Trigger Security Reviewer agent
echo "🚀 Starting Advanced Security Review..."
echo ""
echo "Trigger: Agent: security-reviewer - Perform OWASP assessment for: $SECURITY_DESCRIPTION"
echo "Then: Agent: staff-engineer - Deep security investigation"
echo ""
echo "The review will assess:"
echo "  - OWASP Top 10 categories"
echo "  - STRIDE threat modeling"
echo "  - Cross-service security impact"
echo "  - Dependency security"
echo "  - Infrastructure security"
echo "  - Security architecture"
echo ""
echo "📝 Next Steps:"
echo "  1. Review the workflow document: $WORKFLOW_FILE"
echo "  2. Trigger Security Reviewer for OWASP assessment"
echo "  3. Trigger Staff Engineer for deep investigation"
echo "  4. Review consolidated report"
echo "  5. Address any CRITICAL/HIGH issues (BLOCKING)"
echo ""
echo "🔗 Reference: security-review-advanced workflow"
echo ""

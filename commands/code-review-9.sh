#!/bin/bash
# code-review-9.sh - DEPRECATED: Use code-review-deep instead
# This wrapper is maintained for backward compatibility

set -e

echo "⚠️  DEPRECATED: Use 'em-team code-review-deep' instead"
echo "This wrapper will be removed in v2.0.0"
echo ""

# Execute the new command
exec "$(dirname "$0")/code-review-deep.sh" "$@"
echo ""
echo "This command performs a comprehensive 9-axis code review involving:"
echo "  - Senior Code Reviewer (9-axis review: Correctness, Readability, Architecture, Security, Performance, Testing, Maintainability, Scalability, Documentation)"
echo "  - Security Reviewer (OWASP Top 10, vulnerability assessment)"
echo ""

# Check if PR/code description is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a PR or code description"
    echo ""
    echo "Usage: em-team code-review-9 \"[PR URL or code description]\""
    echo ""
    echo "Example:"
    echo "  em-team code-review-9 \"Review PR #123 for payment processing\""
    echo "  em-team code-review-9 \"Review authentication module for security issues\""
    echo "  em-team code-review-9 \"Assess code quality of user service refactoring\""
    exit 1
fi

CODE_DESCRIPTION="$*"

echo "📋 Code: $CODE_DESCRIPTION"
echo ""

# Create workflow document
WORKFLOW_FILE=".planning/code-review-9axis-workflow.md"
mkdir -p .planning

cat > "$WORKFLOW_FILE" << EOF
# Code Review (9-Axis) Workflow

**Date:** $(date +%Y-%m-%d)
**Code:** $CODE_DESCRIPTION

## Review Plan

### Stage 1: 9-Axis Code Review (Senior Code Reviewer)
**Agent:** \`em-agent:senior-code-reviewer\`
**Trigger:** "Agent: senior-code-reviewer - Perform 9-axis review for: $CODE_DESCRIPTION"

**9 Axes:**
1. **Correctness** ✅ - Logic, edge cases, validation, concurrency
2. **Readability** 📖 - Naming, structure, documentation
3. **Architecture** 🏗️ - Patterns, separation, modularity, scalability
4. **Security** 🔒 - Injection, auth, authorization, data protection
5. **Performance** ⚡ - Algorithms, caching, database, rendering
6. **Testing** 🧪 - Coverage, quality, organization, TDD
7. **Maintainability** 🔧 - Organization, complexity, duplication
8. **Scalability** 📈 - Horizontal/vertical scaling, data, performance
9. **Documentation** 📚 - Comments, API docs, README

### Stage 2: Security Vulnerability Assessment (Security Reviewer)
**Agent:** \`em-agent:security-reviewer\`
**Trigger:** "Agent: security-reviewer - Perform security assessment for: $CODE_DESCRIPTION"

**Assessment:**
- OWASP Top 10 categories
- Vulnerability identification
- Severity classification (CRITICAL/HIGH/MEDIUM/LOW)
- **BLOCKING authority** for CRITICAL/HIGH issues

### Stage 3: Consolidated Code Quality Report
**Agents:** \`em-agent:senior-code-reviewer\` + \`em-agent:security-reviewer\`

**Output:**
- Merged 9-axis and security findings
- Prioritized by combined severity
- Actionable recommendations
- Final decision (APPROVED/CONDITIONAL/REJECTED)

## 9-Axis Review Framework

### Correctness
- Logic correctness
- Edge cases (null, undefined, empty, boundaries)
- Data validation
- Concurrency (race conditions, deadlocks)

### Readability
- Meaningful naming
- Clear structure
- Self-documenting code
- Appropriate comments

### Architecture
- Design patterns
- Separation of concerns
- Modularity
- Scalability

### Security
- Injection vulnerabilities
- Authentication/authorization
- Data protection
- Secrets management

### Performance
- Algorithm complexity
- Caching strategy
- Database optimization
- Rendering optimization

### Testing
- Test coverage
- Test quality
- Edge case coverage
- TDD compliance

### Maintainability
- Code organization
- Complexity management
- DRY principle
- Technical debt

### Scalability
- Stateless design
- Resource efficiency
- Data partitioning
- Async processing

### Documentation
- Code comments
- API documentation
- README completeness
- Inline docs

## Severity Classification

### Critical (BLOCKS Deployment)
- Security vulnerability
- Data loss risk
- Production outage risk
- Legal compliance issue

### High (BLOCKS Merge)
- Bug affecting users
- Performance regression
- Accessibility violation
- Test coverage below threshold

### Medium (Fix Before Next Release)
- Code smell
- Minor performance issue
- Missing documentation
- Technical debt

### Low (Nice to Have)
- Style inconsistency
- Naming suggestion
- Optimization opportunity

## Quality Gates

- [ ] All 9 axes reviewed and scored
- [ ] Security assessment completed
- [ ] Findings classified by severity
- [ ] Overall score calculated
- [ ] Blocking issues identified
- [ ] Recommendations prioritized
- [ ] Decision documented

## Output

Consolidated Code Quality Report with:
- Executive Summary
- 9-Axis detailed review
- Security vulnerability assessment
- Severity table
- Scorecard
- Recommendations
- Decision (APPROVED/CONDITIONAL/REJECTED)

**Note:** CRITICAL/HIGH security issues MUST be fixed before proceeding
EOF

echo "✅ Workflow document created: $WORKFLOW_FILE"
echo ""

# Trigger Senior Code Reviewer agent
echo "🚀 Starting 9-Axis Code Review..."
echo ""
echo "Trigger: Agent: senior-code-reviewer - Perform 9-axis review for: $CODE_DESCRIPTION"
echo "Then: Agent: security-reviewer - Perform security assessment"
echo ""
echo "The review will assess:"
echo "  - All 9 axes of code quality"
echo "  - Security vulnerabilities (OWASP Top 10)"
echo "  - Severity classification"
echo "  - Quantitative scoring"
echo ""
echo "📝 Next Steps:"
echo "  1. Review the workflow document: $WORKFLOW_FILE"
echo "  2. Trigger Senior Code Reviewer for 9-axis review"
echo "  3. Trigger Security Reviewer for vulnerability assessment"
echo "  4. Review consolidated report"
echo "  5. Address any CRITICAL/HIGH issues"
echo ""
echo "🔗 Reference: code-review-9axis workflow"
echo ""

#!/bin/bash
# incident.sh - Production incident response with Staff Engineer and Security Reviewer
# Usage: em-team incident [incident_description]

set -e

# Description
echo "🚨 Incident Response - Production Incident Handling"
echo ""
echo "This command provides systematic production incident handling involving:"
echo "  - Staff Engineer (root cause analysis, cross-service impact, resolution)"
echo "  - Security Reviewer (security investigation, breach assessment)"
echo ""

# Check if incident description is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide an incident description"
    echo ""
    echo "Usage: em-team incident \"[incident description]\""
    echo ""
    echo "Example:"
    echo "  em-team incident \"Production outage - API returning 500 errors\""
    echo "  em-team incident \"Database connection pool exhausted\""
    echo "  em-team incident \"Security alert - unusual login patterns\""
    echo "  em-team incident \"Payment processing failures\""
    exit 1
fi

INCIDENT_DESCRIPTION="$*"

echo "📋 Incident: $INCIDENT_DESCRIPTION"
echo ""

# Create workflow document
WORKFLOW_FILE=".planning/incident-response-workflow.md"
mkdir -p .planning

cat > "$WORKFLOW_FILE" << EOF
# Incident Response Workflow

**Date:** $(date +%Y-%m-%d)
**Incident:** $INCIDENT_DESCRIPTION

## Response Plan

### Stage 1: Initial Assessment & Triage (Staff Engineer)
**Agent:** \`em-agent:staff-engineer\`
**Trigger:** "Agent: staff-engineer - Assess incident: $INCIDENT_DESCRIPTION"

**Actions:**
- Assess incident severity (P0/P1/P2/P3)
- Understand incident scope
- Identify affected services/users
- Begin timeline reconstruction
- Gather initial data

**Severity Levels:**
- **P0 (Critical):** Complete outage, data loss, security breach, revenue >$10K/hour
- **P1 (High):** Significant degradation, major feature broken, revenue >$1K/hour
- **P2 (Medium):** Minor degradation, single feature broken
- **P3 (Low):** Cosmetic issue, no user impact

### Stage 2: Security Investigation (if applicable)
**Agent:** \`em-agent:security-reviewer\`
**Trigger:** "Agent: security-reviewer - Investigate security incident: $INCIDENT_DESCRIPTION"

**Actions:**
- Check for security breach
- Assess if incident is security-related
- Review audit logs
- Check for unauthorized access
- Assess data exposure

### Stage 3: Root Cause Analysis (Staff Engineer)
**Agent:** \`em-agent:staff-engineer\`
**Trigger:** "Agent: staff-engineer - Root cause analysis for: $INCIDENT_DESCRIPTION"

**Actions:**
- Apply 5 Whys methodology
- Create fishbone diagram
- Reconstruct complete timeline
- Identify contributing factors
- Determine root cause

### Stage 4: Cross-Service Impact Analysis (Staff Engineer)
**Agent:** \`em-agent:staff-engineer\`
**Trigger:** "Agent: staff-engineer - Cross-service impact analysis for: $INCIDENT_DESCRIPTION"

**Actions:**
- Map affected services
- Analyze dependency impact
- Assess data integrity
- Identify cascade effects
- Document user impact

### Stage 5: Resolution & Verification (Staff Engineer + Security Reviewer)
**Agents:** \`em-agent:staff-engineer\` + \`em-agent:security-reviewer\`

**Actions:**
- Implement fixes
- Verify resolution
- Assess if security patches needed
- Document temporary workarounds
- Plan permanent fixes

### Stage 6: Postmortem & Prevention (Staff Engineer + Security Reviewer)
**Agents:** \`em-agent:staff-engineer\` + \`em-agent:security-reviewer\`

**Actions:**
- Create blameless postmortem
- Identify lessons learned
- Create action items with owners
- Update runbooks
- Improve monitoring/alerting

## Root Cause Analysis Framework

### 5 Whys Method
Iteratively ask "why" to drill down to root cause

### Fishbone (Ishikawa) Diagram
Categories: People, Process, Technology, Environment, Data, Management

## Blameless Postmortem Principles

- Focus on systems, not people
- Assume good intent
- Psychological safety
- Learning over blame

## Quality Gates

- [ ] Severity assessed accurately
- [ ] Timeline reconstructed completely
- [ ] Root cause identified and validated
- [ ] Cross-service impact analyzed
- [ ] Security investigation completed (if applicable)
- [ ] Issue resolved and verified
- [ ] Blameless postmortem completed
- [ ] Action items created with owners
- [ ] Lessons learned documented
- [ ] Prevention measures defined
- [ ] Follow-up scheduled

## Output

Incident Response Report with:
- Executive Summary
- Timeline
- Initial Assessment
- Security Investigation (if applicable)
- Root Cause Analysis (5 Whys, contributing factors)
- Cross-Service Impact
- Resolution (immediate actions, workarounds, permanent fix)
- Postmortem (what went well, improvements, action items)
- Lessons Learned
- Follow-up Plan

## Emergency Contacts

- On-Call Engineer: [Contact]
- Engineering Manager: [Contact]
- Security Lead: [Contact]
- Product Owner: [Contact]
EOF

echo "✅ Workflow document created: $WORKFLOW_FILE"
echo ""

# Determine severity
echo "🔍 Incident Severity Assessment"
echo ""
echo "Please assess the incident severity:"
echo "  P0 - Critical (Complete outage, data loss, security breach)"
echo "  P1 - High (Significant degradation, major feature broken)"
echo "  P2 - Medium (Minor degradation, single feature broken)"
echo "  P3 - Low (Cosmetic issue, no user impact)"
echo ""
read -p "Enter severity (P0/P1/P2/P3): " SEVERITY
echo ""

# Trigger Staff Engineer agent
echo "🚀 Starting Incident Response..."
echo ""
echo "Trigger: Agent: staff-engineer - Assess P${SEVERITY} incident: $INCIDENT_DESCRIPTION"
echo ""
echo "The response will:"
echo "  1. Assess and triage the incident"
echo "  2. Investigate security involvement (if applicable)"
echo "  3. Perform root cause analysis (5 Whys, fishbone)"
echo "  4. Analyze cross-service impact"
echo "  5. Resolve and verify the issue"
echo "  6. Create blameless postmortem"
echo "  7. Define prevention measures"
echo ""
echo "📝 Next Steps:"
echo "  1. Review the workflow document: $WORKFLOW_FILE"
echo "  2. Trigger Staff Engineer for incident assessment"
echo "  3. Trigger Security Reviewer if security involvement suspected"
echo "  4. Follow the investigation and resolution process"
echo "  5. Complete blameless postmortem"
echo "  6. Implement prevention measures"
echo ""
echo "🔗 Reference: incident-response workflow"
echo ""
echo "⚠️  Remember: This is a blameless process. Focus on systems, not people."
echo ""

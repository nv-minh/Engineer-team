#!/bin/bash
# team-lead.sh - Orchestrate full team review
# Usage: em-team team-lead [task_description]

set -e

# Description
echo "🎯 Team Lead - Full Team Review Orchestrator"
echo ""
echo "This command orchestrates a comprehensive team review involving multiple agents:"
echo "  - Product Manager (business validation)"
echo "  - Architect (technical design)"
echo "  - Frontend Expert (UI/UX)"
echo "  - Database Expert (data layer)"
echo "  - Senior Code Reviewer (code quality)"
echo "  - Security Reviewer (security assessment)"
echo "  - Staff Engineer (deep investigation)"
echo ""

# Check if task description is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a task description"
    echo ""
    echo "Usage: em-team team-lead \"[task description]\""
    echo ""
    echo "Example:"
    echo "  em-team team-lead \"Review new payment feature before implementation\""
    echo "  em-team team-lead \"Architecture review for microservices migration\""
    echo "  em-team team-lead \"Cross-functional review for checkout flow redesign\""
    exit 1
fi

TASK_DESCRIPTION="$*"

echo "📋 Task Description: $TASK_DESCRIPTION"
echo ""

# Create workflow document
WORKFLOW_FILE=".planning/team-review-workflow.md"
mkdir -p .planning

cat > "$WORKFLOW_FILE" << EOF
# Team Review Workflow

**Date:** $(date +%Y-%m-%d)
**Task:** $TASK_DESCRIPTION

## Orchestration Plan

### Stage 1: Scope Analysis (Team Lead)
**Agent:** \`em-agent:team-lead\`
**Trigger:** "Agent: team-lead - Analyze scope for: $TASK_DESCRIPTION"

### Stage 2: Business Validation (Product Manager)
**Agent:** \`em-agent:product-manager\`
**Trigger:** "Agent: product-manager - Review business requirements for: $TASK_DESCRIPTION"

### Stage 3: Architecture Review (Architect)
**Agent:** \`em-agent:architect\`
**Trigger:** "Agent: architect - Review architecture for: $TASK_DESCRIPTION"

### Stage 4: Specialized Reviews
**Agents:** Based on scope identified by Team Lead

- Frontend Expert: \`em-agent:frontend-expert\`
- Database Expert: \`em-agent:database-expert\`
- Senior Code Reviewer: \`em-agent:senior-code-reviewer\`

### Stage 5: Security Review (Security Reviewer)
**Agent:** \`em-agent:security-reviewer\`
**Trigger:** "Agent: security-reviewer - Perform security assessment for: $TASK_DESCRIPTION"
**Note:** This agent has BLOCKING authority for CRITICAL/HIGH issues

### Stage 6: Deep Investigation (if needed)
**Agent:** \`em-agent:staff-engineer\`
**Trigger:** Only if complex issues identified

### Stage 7: Consolidation (Team Lead)
**Agent:** \`em-agent:team-lead\`
**Trigger:** "Agent: team-lead - Consolidate all team review reports"

## Quality Gates

- [ ] Business validation passed
- [ ] Architecture review passed
- [ ] Specialized reviews passed
- [ ] Security review passed (CRITICAL/HIGH issues block)
- [ ] Consolidated report complete

## Output

Consolidated Team Review Report with:
- Executive Summary
- All Agent Reports
- Consolidated Findings
- Decision (APPROVED/CONDITIONAL/REJECTED)
- Next Steps
EOF

echo "✅ Workflow document created: $WORKFLOW_FILE"
echo ""

# Trigger Team Lead agent
echo "🚀 Starting Team Lead orchestration..."
echo ""
echo "Trigger: Agent: team-lead - Orchestrate team review for: $TASK_DESCRIPTION"
echo ""
echo "The Team Lead will:"
echo "  1. Analyze the task scope"
echo "  2. Select appropriate agents"
echo "  3. Coordinate execution"
echo "  4. Consolidate reports"
echo "  5. Make final decision"
echo ""
echo "📝 Next Steps:"
echo "  1. Review the workflow document: $WORKFLOW_FILE"
echo "  2. Trigger the Team Lead agent with the above command"
echo "  3. Follow the orchestration plan"
echo "  4. Review consolidated report"
echo ""
echo "🔗 Reference: team-review workflow"
echo ""

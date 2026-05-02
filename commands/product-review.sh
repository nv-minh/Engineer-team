#!/bin/bash
# product-review.sh - Product/spec review with Product Manager and Architect
# Usage: em-team product-review [spec_or_requirement_description]

set -e

# Description
echo "📦 Product Review - Requirements & Business Validation"
echo ""
echo "This command performs a comprehensive product review involving:"
echo "  - Product Manager (requirements, GAP analysis, user stories, market fit)"
echo "  - Architect (technical feasibility, options, effort estimation)"
echo ""

# Check if spec/requirement description is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a spec or requirement description"
    echo ""
    echo "Usage: em-team product-review \"[spec or requirement description]\""
    echo ""
    echo "Example:"
    echo "  em-team product-review \"Review spec for new payment feature\""
    echo "  em-team product-review \"Validate requirements for user onboarding flow\""
    echo "  em-team product-review \"Assess market fit for subscription management\""
    exit 1
fi

PRODUCT_DESCRIPTION="$*"

echo "📋 Product: $PRODUCT_DESCRIPTION"
echo ""

# Create workflow document
WORKFLOW_FILE=".planning/product-review-workflow.md"
mkdir -p .planning

cat > "$WORKFLOW_FILE" << EOF
# Product Review Workflow

**Date:** $(date +%Y-%m-%d)
**Product:** $PRODUCT_DESCRIPTION

## Review Plan

### Stage 1: Business Requirements Review (Product Manager)
**Agent:** \`em-agent:product-manager\`
**Trigger:** "Agent: product-manager - Review requirements for: $PRODUCT_DESCRIPTION"

**Assessment:**
- Requirements validation (problem, solution, business value, feasibility)
- GAP analysis (current vs desired state)
- Acceptance criteria review (clarity, testability, completeness)
- Market fit assessment (problem, solution, market validation)
- User story validation (INVEST criteria)
- Business impact and ROI

### Stage 2: Technical Feasibility Review (Architect)
**Agent:** \`em-agent:architect\`
**Trigger:** "Agent: architect - Assess technical feasibility for: $PRODUCT_DESCRIPTION"

**Assessment:**
- Technical feasibility
- Technical options and trade-offs
- Architecture impact
- Development effort estimation
- Technical risks
- Integration requirements

### Stage 3: Consolidated Product Assessment
**Agents:** \`em-agent:product-manager\` + \`em-agent:architect\`

**Output:**
- Merged business and technical findings
- Business-technical alignment validation
- Prioritized requirements
- Actionable recommendations
- Go/No-Go decision

## Product Review Framework

### Requirements Validation
- Problem statement (clear, users identified, pain points understood)
- Solution validation (addresses problem, value prop clear)
- Business value (revenue/cost impact, strategic value, metrics)
- Feasibility (technical, resources, timeline, dependencies)

### GAP Analysis
- Business GAP (alignment with strategy, priority, opportunity cost)
- User GAP (user needs, validation, data vs assumptions)
- Technical GAP (tech stack, feasibility, risks)
- Process GAP (operations, workflows, training)
- Data GAP (requirements, availability, collection)

### Acceptance Criteria Review
- Clarity (unambiguous, clear definition of done, measurable)
- Testability (automated, manual, pass/fail clear, edge cases)
- Completeness (happy path, errors, edge cases, boundaries)
- Traceability (linked to user story, requirement, business goal)

### User Story Validation (INVEST)
- **I**ndependent (can be developed independently)
- **N**egotiable (details can be negotiated)
- **V**aluable (clear value to user, supports business goal)
- **E**stimable (team can estimate, requirements clear)
- **S**mall (can be completed in sprint)
- **T**estable (acceptance criteria defined, can be verified)

## Quality Gates

- [ ] Requirements validated
- [ ] GAP analysis completed
- [ ] Acceptance criteria reviewed
- [ ] User stories validated (INVEST)
- [ ] Business impact assessed
- [ ] Market fit analyzed
- [ ] Technical feasibility confirmed
- [ ] Options identified
- [ ] Findings documented with severity
- [ ] Recommendations provided
- [ ] Scorecard completed

## Output

Consolidated Product Review Report with:
- Executive Summary
- Requirements Validation
- GAP Analysis
- Acceptance Criteria Review
- User Story Validation
- Technical Feasibility
- Market Fit Analysis
- Findings and Recommendations
- Product Scorecard
- Decision (APPROVED/CONDITIONAL/REJECTED)
EOF

echo "✅ Workflow document created: $WORKFLOW_FILE"
echo ""

# Trigger Product Manager agent
echo "🚀 Starting Product Review..."
echo ""
echo "Trigger: Agent: product-manager - Review requirements for: $PRODUCT_DESCRIPTION"
echo "Then: Agent: architect - Assess technical feasibility"
echo ""
echo "The review will assess:"
echo "  - Requirements validation"
echo "  - GAP analysis"
echo "  - Acceptance criteria"
echo "  - User stories (INVEST)"
echo "  - Business impact and ROI"
echo "  - Market fit"
echo "  - Technical feasibility"
echo "  - Effort and risks"
echo ""
echo "📝 Next Steps:"
echo "  1. Review the workflow document: $WORKFLOW_FILE"
echo "  2. Trigger Product Manager for requirements review"
echo "  3. Trigger Architect for technical feasibility"
echo "  4. Review consolidated report"
echo ""
echo "🔗 Reference: product-review workflow"
echo ""

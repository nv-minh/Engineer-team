#!/bin/bash
# arch-review.sh - Architecture review with Architect and Staff Engineer
# Usage: em-team arch-review [architecture_description]

set -e

# Description
echo "🏗️  Architecture Review"
echo ""
echo "This command performs a comprehensive architecture review involving:"
echo "  - Architect (architecture patterns, design, scalability)"
echo "  - Staff Engineer (cross-service impact, dependencies)"
echo ""

# Check if architecture description is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide an architecture description"
    echo ""
    echo "Usage: em-team arch-review \"[architecture description]\""
    echo ""
    echo "Example:"
    echo "  em-team arch-review \"Review hexagonal architecture for user service\""
    echo "  em-team arch-review \"Assess microservices decomposition strategy\""
    echo "  em-team arch-review \"Review event-driven architecture for payment processing\""
    exit 1
fi

ARCH_DESCRIPTION="$*"

echo "📋 Architecture: $ARCH_DESCRIPTION"
echo ""

# Create workflow document
WORKFLOW_FILE=".planning/architecture-review-workflow.md"
mkdir -p .planning

cat > "$WORKFLOW_FILE" << EOF
# Architecture Review Workflow

**Date:** $(date +%Y-%m-%d)
**Architecture:** $ARCH_DESCRIPTION

## Review Plan

### Stage 1: Architecture Analysis (Architect)
**Agent:** \`em-agent:architect\`
**Trigger:** "Agent: architect - Review architecture for: $ARCH_DESCRIPTION"

**Assessment:**
- Architectural pattern identification (Layered, Hexagonal, Microservices, Event-Driven)
- Architecture principles (high cohesion, low coupling, separation of concerns)
- Technical design review
- Scalability analysis
- ADR review (if applicable)

### Stage 2: Deep Technical Review (Staff Engineer)
**Agent:** \`em-agent:staff-engineer\`
**Trigger:** "Agent: staff-engineer - Deep technical review for: $ARCH_DESCRIPTION"

**Assessment:**
- Cross-service impact analysis
- Dependency mapping
- Performance implications
- Integration complexity
- Risk identification

### Stage 3: Consolidated Architecture Assessment
**Agents:** \`em-agent:architect\` + \`em-agent:staff-engineer\`

**Output:**
- Merged architecture and technical findings
- Identified architectural risks
- Prioritized recommendations
- Actionable roadmap

## Architecture Patterns

### LAYERED
- Unidirectional data flow
- Upper layers depend on lower layers
- Good for: Traditional CRUD, small teams

### HEXAGONAL
- Domain core with no dependencies
- Ports and adapters pattern
- Good for: Complex domains, technology uncertainty

### MICROSERVICES
- Independent services with own databases
- API gateway and service mesh
- Good for: Multiple teams, high scaling, fault isolation

### EVENT-DRIVEN
- Event producers, broker, consumers
- Async processing
- Good for: Async processing, real-time updates, high scalability

## Quality Gates

- [ ] Architectural pattern identified
- [ ] Architecture principles evaluated
- [ ] Technical design reviewed
- [ ] Cross-service impact analyzed
- [ ] Dependencies mapped
- [ ] Scalability assessed
- [ ] Scorecard completed

## Output

Consolidated Architecture Review Report with:
- Executive Summary
- Architecture Pattern Analysis
- Principles Review
- Technical Design Assessment
- Cross-Service Impact
- Scalability Analysis
- Findings and Recommendations
- Architecture Scorecard
- Decision
EOF

echo "✅ Workflow document created: $WORKFLOW_FILE"
echo ""

# Trigger Architect agent
echo "🚀 Starting Architecture Review..."
echo ""
echo "Trigger: Agent: architect - Review architecture for: $ARCH_DESCRIPTION"
echo ""
echo "The review will assess:"
echo "  - Architectural patterns"
echo "  - Design principles"
echo "  - Scalability"
echo "  - Cross-service impact"
echo "  - Dependencies"
echo ""
echo "📝 Next Steps:"
echo "  1. Review the workflow document: $WORKFLOW_FILE"
echo "  2. Trigger the Architect agent with the above command"
echo "  3. Trigger Staff Engineer for deep technical review"
echo "  4. Review consolidated report"
echo ""
echo "🔗 Reference: architecture-review workflow"
echo ""

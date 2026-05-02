#!/bin/bash
# design-review.sh - UI/UX design review with Frontend Expert and Product Manager
# Usage: em-team design-review [design_description]

set -e

# Description
echo "🎨 Design Review - UI/UX Assessment"
echo ""
echo "This command performs a comprehensive UI/UX design review involving:"
echo "  - Product Manager (user stories, flows, business requirements)"
echo "  - Frontend Expert (component architecture, performance, accessibility)"
echo ""

# Check if design description is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a design description"
    echo ""
    echo "Usage: em-team design-review \"[design description]\""
    echo ""
    echo "Example:"
    echo "  em-team design-review \"Review checkout flow UI design\""
    echo "  em-team design-review \"Assess dashboard component design\""
    echo "  em-team design-review \"Review mobile app navigation design\""
    exit 1
fi

DESIGN_DESCRIPTION="$*"

echo "📋 Design: $DESIGN_DESCRIPTION"
echo ""

# Create workflow document
WORKFLOW_FILE=".planning/design-review-workflow.md"
mkdir -p .planning

cat > "$WORKFLOW_FILE" << EOF
# Design Review Workflow

**Date:** $(date +%Y-%m-%d)
**Design:** $DESIGN_DESCRIPTION

## Review Plan

### Stage 1: Product Requirements Review (Product Manager)
**Agent:** \`em-agent:product-manager\`
**Trigger:** "Agent: product-manager - Review user stories and requirements for: $DESIGN_DESCRIPTION"

**Assessment:**
- User stories validation (INVEST criteria)
- User flows review
- Acceptance criteria assessment
- Business value confirmation
- Market fit validation

### Stage 2: UI/UX Technical Review (Frontend Expert)
**Agent:** \`em-agent:frontend-expert\`
**Trigger:** "Agent: frontend-expert - Review UI/UX design for: $DESIGN_DESCRIPTION"

**Assessment:**
- React/Next.js component architecture
- State management strategy
- Core Web Vitals (LCP, FID, CLS)
- Responsive design (mobile, tablet, desktop)
- Accessibility audit (WCAG 2.1 AA/AAA)
- Performance optimization

### Stage 3: Consolidated Design Assessment
**Agents:** \`em-agent:product-manager\` + \`em-agent:frontend-expert\`

**Output:**
- Merged business and technical findings
- UX issues identification
- Prioritized improvements
- Actionable recommendations

## UI/UX Review Framework

### Visual Design
- Color (contrast, palette, brand alignment)
- Typography (hierarchy, readability)
- Spacing (consistency, breathing room)
- Imagery (quality, alt text, lazy loading)

### User Experience
- Navigation (intuitive, structure, breadcrumbs)
- Flows (smooth, edge cases, error states)
- Feedback (loading, progress, errors, confirmations)
- Accessibility (keyboard, screen reader, focus indicators)

### Responsive Design
- Mobile Small (320px)
- Mobile (375px)
- Tablet (768px)
- Desktop (1440px)
- Large Desktop (1920px)

### Performance Metrics
- LCP: < 2.5s (Largest Contentful Paint)
- FID: < 100ms (First Input Delay)
- CLS: < 0.1 (Cumulative Layout Shift)

## Accessibility Checklist

### WCAG 2.1 AA
- [ ] Color contrast 4.5:1 for normal text
- [ ] Color contrast 3:1 for large text
- [ ] All functionality keyboard accessible
- [ ] Focus indicators visible
- [ ] Error messages clear
- [ ] Labels for all inputs
- [ ] Alt text for images
- [ ] ARIA landmarks used

## Quality Gates

- [ ] User stories validated (INVEST)
- [ ] User flows reviewed
- [ ] UI/UX design assessed
- [ ] Component architecture reviewed
- [ ] Accessibility audit completed
- [ ] Performance analyzed
- [ ] Responsive design verified
- [ ] Scorecard completed

## Output

Consolidated Design Review Report with:
- Executive Summary
- Product Requirements Review
- UI/UX Technical Review
- Accessibility Audit
- Responsive Design Assessment
- Performance Metrics
- Findings and Recommendations
- Design Scorecard
- Decision
EOF

echo "✅ Workflow document created: $WORKFLOW_FILE"
echo ""

# Trigger Product Manager agent
echo "🚀 Starting Design Review..."
echo ""
echo "Trigger: Agent: product-manager - Review requirements for: $DESIGN_DESCRIPTION"
echo "Then: Agent: frontend-expert - Review UI/UX design"
echo ""
echo "The review will assess:"
echo "  - User stories (INVEST criteria)"
echo "  - User flows"
echo "  - Component architecture"
echo "  - Core Web Vitals"
echo "  - Accessibility (WCAG 2.1)"
echo "  - Responsive design"
echo ""
echo "📝 Next Steps:"
echo "  1. Review the workflow document: $WORKFLOW_FILE"
echo "  2. Trigger Product Manager for requirements review"
echo "  3. Trigger Frontend Expert for technical review"
echo "  4. Review consolidated report"
echo ""
echo "🔗 Reference: design-review workflow"
echo ""

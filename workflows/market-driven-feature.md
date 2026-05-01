---
name: market-driven-feature
description: Complete workflow from market discovery to production for market-driven features (integrates market-intelligence, brainstorming, product-manager, architect, planner)
version: "2.0.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - market-intelligence
  - product-manager
  - architect
  - planner
  - executor
  - code-reviewer
skills_used:
  - brainstorming
  - spec-driven-development
  - writing-plans
  - incremental-implementation
  - code-review
related_skills:
  - brainstorming
  - spec-driven-development
estimated_time: "2-5 weeks"
---

# Market-Driven Feature Workflow

## Overview

A comprehensive workflow that starts with market discovery and validation before moving to solution design and implementation. This workflow is ideal for new markets, strategic initiatives, or features where market validation is critical.

**Key Differentiator:** Market-first approach with systematic discovery, validation, and business case analysis before committing to development.

## When to Use

✅ **New Market Entry:**
- Entering a new market segment
- Expanding to new customer segments
- Geographic expansion
- Industry vertical expansion

✅ **Strategic Initiatives:**
- Major platform shifts
- Strategic partnerships
- New product lines
- Business model changes

✅ **Competitive Features:**
- Features competing directly with established players
- Differentiation-critical functionality
- Market disruption opportunities
- Feature parity needed

✅ **Uncertain Demand:**
- Features with unclear market need
- Experimental offerings
- Innovative/radical features
- High-risk, high-reward initiatives

❌ **NOT for:**
- Small enhancements or tweaks
- Clear customer requirements
- Internal tools
- Technical optimizations
- Time-critical fixes
- Features with no competition

## Lifecycle

DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE

### Phase Mapping

| Lifecycle Phase | Workflow Stage |
|-----------------|----------------|
| DEFINE | Market Discovery (Phase 1) |
| PLAN | Solution Design (Phase 2) + Validation (Phase 3) |
| BUILD | Business Case (Phase 4) + Spec (Phase 5) + Plan (Phase 6) |
| VERIFY | Build execution with quality gates (Phase 7) |
| REVIEW | Verify against market goals and spec coverage (Phase 8) |
| SHIP | Deploy to production with go-to-market plan (Phase 9) |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Market size quantified with assumptions
- [ ] Competitive landscape mapped
- [ ] Customer segments identified
- [ ] Market opportunity scored
- [ ] Go/no-go decision on market viability
PASS → proceed | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Solution concepts aligned with market needs
- [ ] Value proposition compelling
- [ ] Competitive differentiation clear
- [ ] Customer needs validated through interviews
- [ ] Feature prioritization data-driven
PASS → proceed | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Financial projections complete
- [ ] ROI meets or exceeds hurdle rate
- [ ] Spec covers all standard areas with market insights
- [ ] Implementation plan with go-to-market milestones
PASS → proceed | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] All tasks completed
- [ ] Tests passing
- [ ] Code reviewed
- [ ] Market differentiation requirements met
PASS → proceed | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Spec coverage 100%
- [ ] Quality gates passed
- [ ] Business metrics baseline established
- [ ] Go-to-market readiness confirmed
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Phases

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  MARKET DISCOVERY → SOLUTION DESIGN → VALIDATION → BUSINESS CASE   │
│       Phase 1           Phase 2          Phase 3        Phase 4          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

         │
         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     EXECUTION PHASES                               │
│                                                                      │
│  SPEC → PLAN → BUILD → VERIFY → SHIP                                    │
│   5     6      7       8        9                                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Phase 1: Market Discovery

**Lead Agent:** market-intelligence

**Supporting Agents:** None (can bring in researcher for technical context)

**Process:**

### 1.1 Market Analysis

**Agent:** market-intelligence

**Activities:**
- Market sizing (TAM, SAM, SOM)
- Market trend analysis
- Growth rate prediction
- Market segmentation
- Market dynamics assessment

**Output:** Market analysis section with:
- Total market size with assumptions
- Growth projections
- Key market segments
- Market trends and forces

### 1.2 Competitive Intelligence

**Agent:** market-intelligence

**Activities:**
- Identify key competitors
- Feature comparison matrix
- Pricing analysis
- Positioning assessment
- Strength/weakness evaluation
- Market share analysis

**Output:** Competitive landscape section with:
- Top 5-10 competitors analyzed
- Feature comparison table
- Pricing strategies
- Market positioning map

### 1.3 Customer Development

**Agent:** market-intelligence

**Activities:**
- Customer segment identification
- Jobs-to-be-done analysis
- Pain point mapping
- Value proposition assessment
- Market opportunity scoring

**Output:** Customer analysis section with:
- Target customer segments
- Customer jobs and pains
- Value proposition hypotheses
- Market opportunity scores

**Phase 1 Deliverable:**
- **MARKET-DISCOVERY-REPORT.md**
  - Market analysis (size, trends, segments)
  - Competitive intelligence
  - Customer development insights
  - Market opportunity scoring
  - Preliminary recommendations

**Quality Gates:**
- [ ] Market size quantified with assumptions
- [ ] Competitive landscape mapped
- [ ] Customer segments identified
- [ ] Market opportunity scored
- [ ] Go/no-go decision on market viability

---

## Phase 2: Solution Design

**Lead Agents:** brainstorming + market-intelligence (collaborative)

**Supporting Agents:** architect (optional, for feasibility)

**Process:**

### 2.1 Ideation with Market Constraints

**Agent:** brainstorming (lead) + market-intelligence (support)

**Process:**
1. Review market discovery report
2. Brainstorm solutions within market constraints
3. Consider competitive differentiation
4. Evaluate customer value propositions
5. Assess technical feasibility

**Market-intelligence role:**
- Provide competitive context
- Highlight differentiation opportunities
- Validate market fit of ideas
- Assess strategic value

**Output:** Design document with:
- Solution concepts
- Competitive positioning strategy
- Differentiation approach
- Technical feasibility assessment

### 2.2 Value Proposition Design

**Agent:** market-intelligence

**Process:**
1. Define target customer segment
2. Articulate customer job-to-be-done
3. Map pain points and gains
4. Design value proposition
5. Test value proposition hypotheses

**Output:** Value proposition section with:
- Customer profile
- Job-to-be-done statement
- Pain point analysis
- Gain creators
- Value proposition canvas

### 2.3 Competitive Positioning

**Agent:** market-intelligence

**Process:**
1. Analyze competitive landscape
2. Identify positioning opportunities
3. Define unique value proposition
4. Create positioning statement
5. Develop differentiation strategy

**Output:** Positioning strategy with:
- Target market definition
- Competitive positioning
- Unique value proposition
- Differentiation strategy
- Positioning statement

**Phase 2 Deliverable:**
- **SOLUTION-DESIGN-DOCUMENT.md**
  - Solution concepts and architecture
  - Value proposition design
  - Competitive positioning strategy
  - Differentiation approach
  - Technical feasibility assessment

**Quality Gates:**
- [ ] Solution concepts aligned with market needs
- [ ] Value proposition compelling
- [ ] Competitive differentiation clear
- [ ] Technical feasibility confirmed
- [ ] Design approved by stakeholders

---

## Phase 3: Validation

**Lead Agents:** market-intelligence + product-manager

**Supporting Agents:** planner (optional, for implementation planning)

**Process:**

### 3.1 Customer Validation

**Agent:** market-intelligence

**Activities:**
- Design customer interview protocols
- Conduct customer discovery interviews
- Test value proposition hypotheses
- Validate pain points and gains
- Gather feedback on solution concepts

**Output:** Customer validation report with:
- Interview summaries
- Validated assumptions
- Invalidated assumptions
- Revised value proposition
- Customer quotes and feedback

### 3.2 Competitive Validation

**Agent:** market-intelligence

**Activities:**
- Test differentiation hypotheses
- Validate competitive advantage claims
- Assess competitive response scenarios
- Analyze market positioning
- Refine positioning strategy

**Output:** Competitive validation with:
- Differentiation test results
- Competitive response scenarios
- Positioning validation
- Revised competitive strategy
- Market entry barriers

### 3.3 Feature Validation

**Agent:** market-intelligence + product-manager

**Activities:**
- Prioritize features based on market demand
- Test feature desirability
- Validate willingness to pay
- Assess adoption likelihood
- Calculate demand potential

**Output:** Feature prioritization with:
- Feature list with market demand scores
- Prioritization matrix (demand vs effort)
- Revenue impact estimates
- Adoption curve predictions
- Feature roadmap recommendations

**Phase 3 Deliverable:**
- **VALIDATION-REPORT.md**
  - Customer validation results
  - Competitive validation results
  - Feature prioritization matrix
  - Revised value proposition
  - Validation conclusions

**Quality Gates:**
- [ ] Customer needs validated
- [ ] Value proposition confirmed
- [ ] Competitive differentiation proven
- [ ] Feature prioritization complete
- [ ] Go/no-go decision on proceeding to build

---

## Phase 4: Business Case

**Lead Agents:** market-intelligence + product-manager

**Supporting Agents:** planner (for implementation estimates)

**Process:**

### 4.1 Financial Modeling

**Agent:** market-intelligence

**Activities:**
- Build revenue models
- Calculate cost structures
- Estimate break-even points
- Project cash flow
- Sensitivity analysis

**Output:** Financial projections with:
- Revenue scenarios (conservative, moderate, aggressive)
- Cost structure analysis
- Break-even analysis
- Payback period calculation
- Sensitivity analysis

### 4.2 ROI Analysis

**Agent:** market-intelligence

**Activities:**
- Calculate return on investment
- Compare ROI against hurdles
- Assess investment efficiency
- Calculate payback period
- Evaluate IRR (Internal Rate of Return)

**Output:** ROI analysis with:
- ROI calculations
- Investment efficiency metrics
- Payback period
- IRR calculations
- Investment recommendation

### 4.3 Go-to-Market Strategy

**Agent:** market-intelligence

**Activities:**
- Define channel strategy
- Design pricing strategy
- Plan launch timing
- Define marketing mix
- Set success metrics

**Output:** Go-to-market plan with:
- Target customer segments
- Channel strategy and mix
- Pricing and packaging strategy
- Launch timeline and milestones
- Marketing budget and mix
- KPIs and success metrics

**Phase 4 Deliverable:**
- **BUSINESS-CASE-DOCUMENT.md**
  - Executive summary
  - Market opportunity
  - Solution overview
  - Financial projections
  - ROI analysis
  - Go-to-market strategy
  - Risk assessment
  - Implementation recommendations

**Quality Gates:**
- [ ] Financial projections complete
- [ ] ROI meets or exceeds hurdles
- [ ] Go-to-market strategy defined
- [ ] Risks identified and mitigated
- [ ] Investment decision made (go/no-go)

---

## Phase 5: Spec (if Business Case Approved)

**Agent:** planner + product-manager + market-intelligence

**Process:**

**If business case approved, proceed to standard spec:**

1. Incorporate market insights into spec
2. Define requirements informed by customer validation
3. Set success metrics based on market goals
4. Include competitive differentiation in requirements
5. Add go-to-market considerations to boundaries

**Output:**
- **SPEC.md** (enhanced with market insights)
  - All 6 core spec areas
  - Market analysis summary
  - Competitive positioning requirements
  - Customer-driven requirements
  - Market-based success metrics

**Quality Gates:**
- [ ] Spec covers all standard areas
- [ ] Market insights integrated
- [ ] Competitive differentiation captured
- [ ] Customer requirements validated
- [ ] User approved spec

---

## Phase 6: Plan

**Agent:** planner + market-intelligence

**Process:**

1. Break down into tasks
2. Estimate effort with market timeline considerations
3. Identify dependencies including market factors
4. Define verification steps
5. Create implementation plan with go-to-market milestones

**Output:**
- **PLAN.md** (market-informed)
  - Task breakdown
  - Effort estimates with market velocity
  - Dependencies including market factors
  - Verification steps
  - Go-to-market milestones

**Quality Gates:**
- [ ] All requirements have tasks
- [ ] No placeholders in plan
- [ ] Market timeline considered
- [ ] Go-to-market integrated
- [ ] Acceptance criteria defined

---

## Phase 7-9: Build → Verify → Ship

**Standard execution phases** (same as new-feature workflow)

**No changes** - Standard build, verify, ship process.

---

## Agent Collaboration Matrix

### Phase 1: Market Discovery

```yaml
lead_agent: market-intelligence
activities:
  - Market Analysis (lead)
  - Competitive Intelligence (lead)
  - Customer Development (lead)

supporting_agents:
  - researcher (optional):
    role: "Provide technical context for market analysis"
    trigger: "When technology trends need assessment"
```

### Phase 2: Solution Design

```yaml
lead_agents: [brainstorming, market-intelligence]
collaboration_mode: "Co-lead"
activities:
  - Ideation with Market Constraints (brainstorming lead, market-intelligence support)
  - Value Proposition Design (market-intelligence lead)
  - Competitive Positioning (market-intelligence lead)

supporting_agents:
  - architect (optional):
    role: "Assess technical feasibility of solution concepts"
    trigger: "When complex technical solutions proposed"
```

### Phase 3: Validation

```yaml
lead_agents: [market-intelligence, product-manager]
collaboration_mode: "Collaborative"
activities:
  - Customer Validation (market-intelligence lead)
  - Competitive Validation (market-intelligence lead)
  - Feature Validation (market-intelligence + product-manager)

supporting_agents:
  - planner (optional):
    role: "Provide implementation effort estimates for feature prioritization"
    trigger: "When resource allocation needed"
```

### Phase 4: Business Case

```yaml
lead_agents: [market-intelligence, product-manager]
collaboration_mode: "Collaborative"
activities:
  - Financial Modeling (market-intelligence lead)
  - ROI Analysis (market-intelligence lead)
  - Go-to-Market Strategy (market-intelligence lead)

supporting_agents:
  - planner:
    role: "Provide implementation cost estimates for financial models"
    trigger: "Always - need cost data for ROI calculations"
```

### Phase 5-6: Spec & Plan

```yaml
lead_agents: [planner, product-manager]
collaboration_mode: "Lead + Support"
activities:
  - Spec Development (planner lead, product-manager + market-intelligence support)
  - Implementation Planning (planner lead, market-intelligence support)

supporting_agents:
  - market-intelligence:
    role: "Provide market insights for requirements and planning"
    trigger: "Always - market context critical"
```

---

## Handoff Contracts

### Phase 1 → Phase 2

```yaml
handoff:
  from: market-intelligence
  to: brainstorming + market-intelligence
  provides:
    - market_discovery_report
    - competitive_intelligence
    - customer_analysis
  expects:
    - solution_design_document
    - value_proposition
    - positioning_strategy
```

### Phase 2 → Phase 3

```yaml
handoff:
  from: brainstorming + market-intelligence
  to: market-intelligence + product-manager
  provides:
    - solution_design
    - value_proposition
    - positioning
  expects:
    - validation_report
    - feature_prioritization
    - revised_value_proposition
```

### Phase 3 → Phase 4

```yaml
handoff:
  from: market-intelligence + product-manager
  to: market-intelligence + product-manager
  provides:
    - validation_report
    - feature_priorities
    - validated_value_proposition
  expects:
    - business_case_document
    - financial_projections
    - roi_analysis
    - go_to_market_strategy
```

### Phase 4 → Phase 5

```yaml
handoff:
  from: market-intelligence + product-manager
  to: planner
  trigger: Business case approved
  provides:
    - business_case_document
    - market_insights
    - customer_requirements
    - competitive_positioning
  expects:
    - spec_document
    - requirements_informed_by_validation
    - market_differentiation_captured
```

---

## Quality Gates Summary

```yaml
quality_gates:
  market_discovery:
    - market_size_quantified
    - competitive_landscape_mapped
    - customer_segments_identified
    - market_opportunity_scored
    - go_no_go_decision

  solution_design:
    - solution_concepts_aligned
    - value_proposition_compelling
    - competitive_differentiation_clear
    - technical_feasibility_confirmed

  validation:
    - customer_needs_confirmed
    - value_proposition_validated
    - competitive_differentiation_proven
    - feature_prioritization_complete

  business_case:
    - financial_projections_complete
    - roi_meets_hurdles
    - go_to_market_defined
    - investment_decision

  spec:
    - spec_complete
    - market_insights_integrated
    - competitive_requirements_captured
    - customer_validated_included

  plan:
    - requirements_mapped
    - tasks_defined
    - no_placeholders
    - go_to_market_integrated

  build: # (standard)
    - tasks_completed
    - tests_passing
    - code_reviewed

  verify: # (standard)
    - spec_coverage_100
    - quality_gates_pass

  ship: # (standard)
    - code_review_approved
    - deployed_successfully
```

---

## Timeline Estimate

```yaml
timeline:
  market_discovery: "3-5 days"
  solution_design: "1-2 days"
  validation: "3-5 days"
  business_case: "2-3 days"
  spec: "1-2 days"
  plan: "2-4 hours"
  build: "1-3 weeks"
  verify: "2-4 hours"
  ship: "1-2 hours"

  total_pre_build: "10-20 days"
  total_build: "1-3 weeks"
  total_full_workflow: "2-5 weeks"
```

---

## Decision Points

### Decision Point 1: After Market Discovery

**Question:** Continue to Solution Design or pivot?

**Criteria:**
- Market opportunity score > threshold
- Competitive landscape favorable
- Customer segments viable

**Decision Paths:**
- **GO:** Market viable → Proceed to Solution Design
- **PIVOT:** Market not viable → Refine target market or pivot
- **STOP:** Market not viable → Terminate

### Decision Point 2: After Validation

**Question:** Proceed to Business Case or refine?

**Criteria:**
- Customer needs confirmed
- Value proposition validated
- Competitive differentiation achievable

**Decision Paths:**
- **GO:** Validation successful → Proceed to Business Case
- **REFINE:** Assumptions invalid → Return to Phase 1 or 2
- **PIVOT:** Validation failed → Pivot solution or market

### Decision Point 3: After Business Case

**Question:** Invest in development or not?

**Criteria:**
- ROI meets or exceeds hurdle rate
- Payback period acceptable
- Strategic value significant
- Go-to-market viable

**Decision Paths:**
- **GO:** Business case strong → Proceed to Spec and Build
- **OPTIMIZE:** Business case weak → Refine and re-evaluate
- **STOP:** Investment not justified → Terminate

---

## Example Usage

### Example 1: New Market Entry

```bash
"Workflow: market-driven-feature - Enter project management market"

# Executes:
# Phase 1: Market Discovery (market-intelligence)
#   - Analyze PM tools market (TAM: $5B, growing 15% YoY)
#   - Competitive analysis (Asana, Monday.com, Jira, ClickUp, Notion)
#   - Customer development (SMBs, mid-market, enterprise)
#   - OUTPUT: Market opportunity identified in SMB collaboration space

# Phase 2: Solution Design
#   - Brainstorm solutions with market constraints
#   - Value prop: "Real-time collaborative workspace for distributed teams"
#   - Positioning: "Easier than Asana, more powerful than Notion"
#   - OUTPUT: Solution design document

# Phase 3: Validation
#   - Customer interviews with 20 SMB teams
#   - Test value prop: "Would you pay $20/user for this?"
#   - Competitive differentiation test: "Is this really easier than Asana?"
#   - OUTPUT: Validation report, refined positioning

# Phase 4: Business Case
#   - Financial model: $500K ARR in year 1, $2M ARR in year 3
#   - ROI: 3x payback in 18 months
#   - Go-to-market: Product-led growth + content marketing
#   - OUTPUT: Business case with go-to-market strategy

# Decision: GO - Proceed to Spec and Build
```

### Example 2: Competitive Feature

```bash
"Workflow: market-driven-feature - Add AI code review to compete with GitHub Copilot"

# Executes:
# Phase 1: Market Discovery (market-intelligence)
#   - Analyze AI code review market (rapidly growing)
#   - Competitive intelligence: GitHub Copilot (85% share), Tabnine, CodeScene
#   - Customer dev: Pricing sensitivity, feature gaps
#   - OUTPUT: Market opportunity in "privacy-first, enterprise-focused"

# Phase 2: Solution Design
#   - Brainstorm AI features with market constraints
#   - Value prop: "Private, self-hosted AI that understands your codebase"
#   - Positioning: "Enterprise-grade AI with data sovereignty"
#   - OUTPUT: Differentiated solution design

# Phase 3: Validation
#   - Customer interviews with enterprise dev teams
#   - Test willingness to pay: "Would you pay $30/dev for private AI?"
#   - Competitive test: "Is privacy worth the trade-offs?"
#   - OUTPUT: Validation confirmed, pricing validated

# Phase 4: Business Case
#   - Financial model: $1M ARR year 1, $5M ARR year 3
#   - ROI: 2.5x payback in 24 months
#   - Go-to-market: Enterprise sales + developer community
#   - OUTPUT: Strong business case

# Decision: GO - Proceed to Spec and Build
```

### Example 3: Market Validation Failure (Pivot)

```bash
"Workflow: market-driven-feature - Social networking for pets"

# Executes:
# Phase 1: Market Discovery (market-intelligence)
#   - Market sizing: Pet care market ($50B TAM)
#   - Competition: Fragmented (Rover, Wag, Nextdoor pet groups)
#   - Customer dev: Pet owners, but low willingness to pay
#   - OUTPUT: Large market but challenging monetization

# Phase 2: Solution Design
#   - Social network for pet owners
#   - Value prop: "Connect with pet lovers near you"
#   - Positioning: "Like Tinder for dog park friends"
#   - OUTPUT: Solution design

# Phase 3: Validation
#   - Customer interviews
#   - Finding: "People love the idea, but won't pay"
#   - Feature validation: "Low willingness to pay for social features"
#   - OUTPUT: Validation report - weak monetization

# Decision: PIVOT or STOP
# - Option A: Pivot to premium pet care services (high willingness to pay)
# - Option B: Stop - market not viable without pivot
```

---

## Best Practices

### When to Use This Workflow

✅ **USE market-driven-feature when:**
- Strategic decisions have major financial impact
- Market validation is critical before investment
- Competitive differentiation is make-or-break
- New market entry or major strategic pivot
- Significant investment required ($500K+)
- Executive buy-in needed for business case

❌ **DON'T use when:**
- Feature requirements are clear and validated
- Small enhancements or iterations
- Internal tools with no market
- Technical optimizations
- Time-critical fixes
- Low-risk experiments

### Market Discovery Best Practices

**Start Broad:**
- Analyze full market before narrowing
- Consider multiple customer segments
- Evaluate multiple competitors
- Test multiple value propositions

**Validate Early:**
- Test assumptions before investing heavily
- Get customer feedback early and often
- Be willing to pivot based on data
- Kill ideas that don't validate

**Focus Deep:**
- Deep understanding over broad coverage
- Quality over quantity of insights
- Actionable insights over raw data
- Clear hypotheses over vague exploration

### Integration with EM-Team Ecosystem

**Leverage Existing Agents:**
- **researcher**: Technology trend analysis in Phase 1
- **architect**: Technical feasibility in Phase 2
- **product-manager**: Requirements in Phase 3, cost estimates in Phase 4
- **planner**: Implementation planning in Phases 5-6
- **executor**: Implementation in Phase 7
- **code-reviewer**: Quality assurance in Phase 7

**Collaboration Patterns:**
- **Co-lead**: brainstorming + market-intelligence in Phase 2
- **Collaborative**: market-intelligence + product-manager in Phases 3-4
- **Supportive**: Other agents support as needed

---

## Success Criteria

A successful market-driven-feature workflow:

**Market Discovery:**
- [ ] Market opportunity clearly identified and quantified
- [ ] Competitive landscape thoroughly mapped
- [ ] Customer segments well-defined
- [ ] Go/no-go decision made with data

**Solution Design:**
- [ ] Solution addresses validated market needs
- [ ] Value proposition is compelling and differentiated
- [ ] Competitive positioning is clear
- [ ] Technical feasibility confirmed

**Validation:**
- [ ] Customer needs confirmed through interviews/data
- [ ] Value proposition validated with evidence
- [ ] Competitive differentiation proven
- [ ] Feature prioritization data-driven

**Business Case:**
- [ ] Financial projections realistic and grounded
- [ ] ROI meets or exceeds thresholds
- [ ] Go-to-market strategy viable
- [ ] Risks identified and mitigated

**Execution:**
- [ ] Market insights integrated throughout
- [ ] Competitive differentiation realized
- [ ] Market goals achieved
- [ ] Business metrics met

---

## Related Resources

- **Agents:**
  - `/em:market-intel` - Market analysis and competitive intelligence
  - `/em:product` - Requirements and GAP analysis
  - `/em:architect` - Technical design and architecture
  - `/em:planner` - Implementation planning

- **Skills:**
  - `/jobs-to-be-done` - Customer jobs analysis
  - `/customer-journey-map` - Customer journey mapping
  - `/lean-ux-canvas` - Business problem framing
  - `/opportunity-solution-tree` - Problem framing and solution exploration

- **Workflows:**
  - `/em:new-feature` - Standard feature development (enhanced with optional market validation)
  - `/em:product-review` - Product spec review with market considerations

---

## Triggers

Use market-driven-feature when:

- User says: "Analyze market for [X] before building"
- User says: "Validate market opportunity for [feature]"
- User says: "We need to understand competitive landscape for [X]"
- User says: "Create business case for [major feature]"
- User says: "We're entering [new market] - need full analysis"
- User says: "How does this compare to [competitor]?"

---

**Version:** 1.0.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready
**Workflow Type:** Strategic Market-Driven Development

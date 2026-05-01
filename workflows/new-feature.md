---
name: new-feature
description: Complete workflow from idea to production for new features (ENHANCED with optional market validation)
version: "2.0.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - planner
  - executor
  - verifier
  - code-reviewer
  - market-intelligence
skills_used:
  - brainstorming
  - spec-driven-development
  - writing-plans
  - test-driven-development
  - code-review
  - git-workflow
estimated_time: "1-3 days (simple) / 2-3 weeks (complex with market validation)"
---

# New Feature Workflow

## Overview

The new feature workflow takes a feature from initial idea through to production deployment. It follows the complete development lifecycle with quality gates at each phase.

**ENHANCED:** Now includes optional market validation stage for strategic features and market-driven decisions.

## When to Use

- Building new features
- Adding functionality
- Implementing user stories
- Creating new capabilities
- Entering new markets
- Strategic feature planning

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Description |
|---|---|---|
| BRAINSTORM (Stage 1) | DEFINE | Explore ideas, clarify requirements, design approach |
| MARKET VALIDATION (Stage 1.5) | DEFINE | Optional market research and competitive analysis |
| SPEC (Stage 2) | DEFINE | Write structured specification with requirements |
| PLAN (Stage 3) | PLAN | Break into tasks, estimate effort, map dependencies |
| BUILD (Stage 4) | BUILD | Execute tasks with TDD and atomic commits |
| VERIFY (Stage 5) | VERIFY | Test acceptance criteria, integration testing |
| SHIP (Stage 6) | REVIEW + SHIP | Code review, PR, merge, deploy, monitor |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Design approved by user
- [ ] Design document written
- [ ] Technical approach decided
- [ ] Market validated OR strategically justified (if Stage 1.5 completed)
PASS → proceed to PLAN | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] All requirements have tasks
- [ ] No placeholders in plan
- [ ] Acceptance criteria defined
- [ ] Verification steps specified
- [ ] Market factors considered (if Stage 1.5 completed)
PASS → proceed to BUILD | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Tasks completed
- [ ] Tests passing
- [ ] Code reviewed
- [ ] Build succeeds
PASS → proceed to VERIFY | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Spec coverage 100%
- [ ] Quality gates pass
- [ ] Acceptance criteria met
- [ ] Integration tests pass
PASS → proceed to REVIEW | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Code review approved
- [ ] PR merged
- [ ] Deployed successfully
- [ ] Monitoring OK
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  BRAINSTORM → [MARKET VALIDATION] → SPEC → PLAN → BUILD → VERIFY → SHIP │
│      1         (1.5 OPTIONAL)        2      3      4       5        6       │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘

                    ┌─────────────────────┐
                    │ PARALLEL EXECUTION │
                    │                     │
         Stage 1.5 ───┤      Stage 2       ├──►
       (Market Val)  │      (Spec)         │
                    └─────────────────────┘
```

## Stage 1: Brainstorm

**Agent:** None (Human + Brainstorming skill)

**Process:**
1. Explore project context
2. Ask clarifying questions
3. Propose 2-3 approaches
4. Present design for approval
5. Write design document

**Enhanced Process:**
- **Step 0.5: Quick Market Check** (NEW - Optional)
  - Brief search for similar solutions
  - Quick competitive scan
  - Note any obvious market constraints
  - Takes < 15 minutes

**Output:**
- Design document saved
- User approval obtained
- Initial market notes (if Step 0.5 completed)

**Quality Gate:**
- [ ] Design approved by user
- [ ] Design document written
- [ ] Technical approach decided

---

## Stage 1.5: Market Validation (OPTIONAL) ⭐ NEW

**Agent:** market-intelligence

**Trigger Conditions:**
- Major feature (strategic impact)
- New market entry
- Competitive differentiation needed
- Significant investment required
- User explicitly requests market analysis

**When to SKIP Stage 1.5:**
- Small enhancements or tweaks
- Clear requirements with no market ambiguity
- Internal tools with no market competition
- Technical optimizations
- Time-critical fixes

**Analysis Modes:**

**Quick Mode** (< 1 hour):
- Use for: Feature validation, competitive feature check
- Process:
  1. Quick market size estimation
  2. Identify top 3 competitors
  3. Feature parity check
  4. Basic positioning assessment
- Runs: Parallel with Stage 2 (Spec)
- Output: Market validation summary

**Standard Mode** (1-2 hours):
- Use for: New features in competitive markets
- Process:
  1. Market sizing (TAM/SAM/SOM)
  2. Competitive landscape mapping
  3. Feature comparison matrix
  4. Customer segment analysis
- Runs: Parallel with Stage 2 (Spec)
- Output: Market analysis report

**Deep Mode** (3-4 hours):
- Use for: New markets, strategic initiatives
- Process:
  1. Full market research and validation
  2. Comprehensive competitive analysis
  3. Customer development
  4. Business case modeling
  5. Go-to-market strategy
- Runs: BEFORE Stage 2 (blocks Spec until complete)
- Output: Strategic market report + business case

**Process:**
1. **Market Analysis**
   - Market sizing and growth trends
   - Market segmentation
   - Market dynamics

2. **Competitive Intelligence**
   - Feature comparison matrix
   - Pricing analysis
   - Positioning assessment

3. **Customer Development**
   - Customer jobs-to-be-done
   - Pain point identification
   - Value proposition validation

4. **Feature Impact**
   - Demand estimation
   - Revenue impact modeling
   - Strategic value assessment

5. **Strategic Recommendations**
   - Go-to-market considerations
   - Competitive positioning
   - Risk mitigation

**Output:**
- Market validation report
- Competitive intelligence summary
- Feature impact assessment
- Strategic recommendations

**Quality Gate:**
- [ ] Market opportunity confirmed OR strategic pivot needed
- [ ] Competitive landscape understood
- [ ] Customer value validated
- [ ] Go/no-go decision made

**Integration with Stage 2:**

```yaml
Parallel Execution (Quick/Standard Mode):
  Stage 1.5 (Market Val): ──┐
                            ├─► Combined insights
  Stage 2 (Spec):       ──┘

Sequential Execution (Deep Mode):
  Stage 1.5 (Market Val) ──► Stage 2 (Spec) ──► Stage 3 (Plan)
```

---

## Stage 2: Spec

**Agent:** Planner

**Process:**
1. Read design document
2. **[ENHANCED]** Incorporate market insights from Stage 1.5 (if completed)
3. Write structured spec
4. Define requirements
5. Set boundaries
6. Document success criteria

**Enhanced Requirements Gathering:**

**If Stage 1.5 completed:**
- **Area 7. Market Analysis** (NEW)
  - Market size and trends
  - Competitive positioning
  - Customer segments
  - Differentiation strategy
- **Area 8. Go-to-Market** (NEW - for major features)
  - Launch timing considerations
  - Channel strategy
  - Marketing mix
  - Success metrics

**Output:**
- SPEC.md document
- Requirements defined
- Success criteria set
- Market insights integrated (if Stage 1.5 completed)

**Quality Gate:**
- [ ] Spec covers all 6 core areas (or 8 areas if Stage 1.5 completed)
- [ ] User approved spec
- [ ] Success criteria testable
- [ ] Market-competitive OR strategically justified (if Stage 1.5 completed)

---

## Stage 3: Plan

**Agent:** Planner

**Process:**
1. Break down into tasks
2. Estimate effort
3. Identify dependencies
4. Define verification steps
5. Create implementation plan

**Enhanced Planning:**

**If Stage 1.5 completed:**
- Incorporate market constraints
- Consider competitive timeline pressures
- Account for go-to-market requirements
- Adjust based on market validation findings

**Output:**
- PLAN.md document
- Task list created
- Dependencies mapped
- Market considerations integrated (if applicable)

**Quality Gate:**
- [ ] All requirements have tasks
- [ ] No placeholders in plan
- [ ] Acceptance criteria defined
- [ ] Verification steps specified
- [ ] Market factors considered (if Stage 1.5 completed)

---

## Stage 4: Build

**Agent:** Executor

**Process:**
1. Execute plan task-by-task
2. Follow TDD
3. Make atomic commits
4. Run quality gates
5. Handle errors

**No changes** - Standard build process.

---

## Stage 5: Verify

**Agent:** Verifier

**Process:**
1. Verify spec coverage
2. Run quality gates
3. Test acceptance criteria
4. Integration testing
5. User acceptance testing

**No changes** - Standard verification process.

---

## Stage 6: Ship

**Agent:** Executor + Code-Reviewer

**Process:**
1. Final code review
2. Create pull request
3. Merge to main
4. Deploy to production
5. Monitor deployment

**No changes** - Standard shipping process.

---

## Handoff Contracts

### Brainstorm → Spec

```yaml
handoff:
  from: brainstorming
  to: planner
  provides:
    - design_document
    - user_approval
    - initial_market_notes (optional)
  expects:
    - spec_document
    - requirements_defined
```

### [NEW] Brainstorm → Market Validation

```yaml
handoff:
  from: brainstorming
  to: market-intelligence
  trigger: Major feature OR new market OR user request
  provides:
    - design_document
    - feature_concept
    - initial_market_notes
  expects:
    - market_validation_report
    - competitive_intelligence
    - strategic_recommendations
```

### [NEW] Market Validation → Spec

```yaml
handoff:
  from: market-intelligence
  to: planner
  provides:
    - market_validation_report
    - competitive_intelligence
    - feature_impact_assessment
  expects:
    - spec_document_with_market_insights
    - requirements_informed_by_market_data
    - competitive_differentiation_considered
```

### Spec → Plan

```yaml
handoff:
  from: planner
  to: planner
  provides:
    - spec_document
    - requirements
    - market_insights (if available)
  expects:
    - implementation_plan
    - task_breakdown
    - market_considerations (if applicable)
```

---

## Quality Gates Summary

```yaml
quality_gates:
  brainstorm:
    - design_approved
    - design_document_written
    - initial_market_notes_collected (optional)

  market_validation:
    - market_opportunity_confirmed
    - competitive_landscape_understood
    - customer_value_validated
    - go_no_go_decision_made
    - (OPTIONAL: only if Stage 1.5 triggered)

  spec:
    - spec_complete
    - user_approved
    - success_criteria_testable
    - market_competitive_or_strategic (if Stage 1.5 completed)

  plan:
    - requirements_mapped
    - tasks_defined
    - no_placeholders
    - market_factors_considered (if Stage 1.5 completed)

  build:
    - tasks_completed
    - tests_passing
    - code_reviewed
    - build_succeeds

  verify:
    - spec_coverage_100
    - quality_gates_pass
    - acceptance_criteria_met
    - integration_tests_pass

  ship:
    - code_review_approved
    - pr_merged
    - deployed_successfully
    - monitoring_ok
```

---

## Timeline Estimate

```yaml
timeline:
  brainstorm: "2-4 hours"
  market_validation_quick: "< 1 hour (parallel with spec)"
  market_validation_standard: "1-2 hours (parallel with spec)"
  market_validation_deep: "3-4 hours (blocks spec)"
  spec: "1-2 hours"
  plan: "2-4 hours"
  build: "1-3 days (depends on complexity)"
  verify: "2-4 hours"
  ship: "1-2 hours"

  total_simple: "1-2 days"
  total_with_market_validation: "1.5-2.5 days"
  total_complex_with_market: "2-3 weeks"
```

---

## Decision Framework: When to Use Market Validation

```yaml
decision_tree:
  feature_proposed:
    size_assessment:
      small_enhancement:
        action: SKIP Stage 1.5
        reason: Quick win, low risk

      standard_feature:
        competitive_market: "yes"
          action: Quick Mode (parallel)
          reason: Validate competitiveness quickly

        competitive_market: "no"
          action: SKIP Stage 1.5
          reason: Clear market, no competition

      major_feature:
        existing_market: "yes"
          action: Standard Mode (parallel)
          reason: Validate market fit in existing market

        new_market: "yes"
          action: Deep Mode (sequential)
          reason: Full market research before investment

      strategic_initiative:
        action: Deep Mode (sequential)
        reason: Comprehensive analysis needed
```

---

## Example Usage

### Example 1: Standard Feature WITHOUT Market Validation

```bash
"Workflow: new-feature - Add dark mode toggle"

# Executes:
# 1. Brainstorming - Design dark mode implementation
# 2. Spec - Write spec for dark mode
# 3. Plan - Plan implementation
# 4. Build - Implement dark mode
# 5. Verify - Test dark mode
# 6. Ship - Deploy dark mode

# Stage 1.5 SKIPPED (small enhancement, no market impact)
```

### Example 2: Competitive Feature WITH Market Validation (Parallel)

```bash
"Workflow: new-feature - AI-powered code suggestions"

# Executes:
# 1. Brainstorming - Design AI code suggestion feature
# 2. [PARALLEL] Stage 1.5: Market Validation (Quick Mode)
#    - Competitive analysis (GitHub Copilot, Tabnine, CodeScene)
#    - Feature comparison
#    - Pricing benchmark
# 3. [PARALLEL] Stage 2: Spec - Write spec
#    - Incorporates competitive insights
#    - Defines differentiation strategy
# 4. Plan - Plan implementation
# 5. Build - Implement feature
# 6. Verify - Test feature
# 7. Ship - Deploy feature

# Stage 1.5: Quick Mode (1 hour) runs parallel with Spec
# Market insights integrated into spec before planning
```

### Example 3: New Market Entry WITH Market Validation (Sequential)

```bash
"Workflow: new-feature - Enter healthcare market"

# Executes:
# 1. Brainstorming - Design healthcare product concept
# 2. [SEQUENTIAL] Stage 1.5: Market Validation (Deep Mode)
#    - Full market research (3-4 hours)
#    - Competitive landscape analysis
#    - Customer development
#    - Business case modeling
#    - Go-to-market strategy
#    - OUTPUT: Strategic market report
# 3. Stage 2: Spec - Write spec with market insights
# 4. Plan - Plan implementation
# 5. Build - Implement product
# 6. Verify - Test product
# 7. Ship - Deploy to healthcare market

# Stage 1.5: Deep Mode BLOCKS Spec until complete
# Ensures market viability before major investment
```

---

## Best Practices

### When to Include Market Validation

✅ **INCLUDE Stage 1.5:**
- Features entering competitive markets
- New market entries
- Major strategic features
- Features requiring significant investment
- Features with unclear market demand
- Differentiation-critical features
- Features with strong competitors

❌ **SKIP Stage 1.5:**
- Small enhancements or tweaks
- Internal tools with no market competition
- Technical optimizations
- Clear customer requirements
- Time-critical fixes
- Features with no competitive alternatives

### Execution Modes

**Quick Mode** (Parallel, < 1 hour):
- Use when: Competitive feature check
- Trigger: "How do competitors handle this?"
- Execution: market-intelligence runs parallel with Spec
- Integration: Spec waits for market insights

**Standard Mode** (Parallel, 1-2 hours):
- Use when: New feature in competitive market
- Trigger: "Validate market opportunity for [feature]"
- Execution: market-intelligence runs parallel with Spec
- Integration: Spec incorporates competitive insights

**Deep Mode** (Sequential, 3-4 hours):
- Use when: New market or strategic initiative
- Trigger: "Analyze market for [new market]"
- Execution: market-intelligence runs FIRST, blocks Spec
- Integration: Spec built on complete market analysis

### Anti-Patterns to Avoid

❌ **DON'T:**
- Add market validation to EVERY feature
- Use deep mode for small features
- Let market analysis block progress on clear wins
- Replace product-manager with market-intelligence
- Use market-intelligence for technical decisions

✅ **DO:**
- Use market validation selectively and strategically
- Match analysis depth to decision importance
- Run parallel when possible to maintain velocity
- Use market insights to inform, not replace, product decisions
- Focus on strategic decisions, not tactical ones

---

## Success Criteria

A successful new feature workflow (with optional market validation):

- [ ] Feature matches spec requirements
- [ ] Market validated OR strategically justified (if Stage 1.5 completed)
- [ ] Competitive differentiation clear (if Stage 1.5 completed)
- [ ] All tests pass
- [ ] Code is clean and maintainable
- [ ] Documentation is complete
- [ ] Feature is deployed
- [ ] No regressions introduced
- [ ] Users can use the feature
- [ ] Monitoring shows healthy state
- [ ] Market feedback positive (if applicable)

---

## Integration Notes

### Agent Collaboration

**market-intelligence collaborates with:**
- **planner**: Provides market data for Spec and Plan stages
- **product-manager**: Provides competitive insights for requirements
- **architect**: Provides market requirements for technical design

**Trigger words for market-intelligence:**
- "Analyze market for..."
- "Compare with competitors..."
- "What's the market demand for..."
- "Should we prioritize feature A or B..."
- "Size the market for..."
- "Assess competitive landscape..."

### Workflow Variants

The new-feature workflow now has three execution paths:

1. **Fast Path** (No market validation)
   - Brainstorm → Spec → Plan → Build → Verify → Ship
   - Use for: Small features, clear requirements, internal tools

2. **Parallel Path** (Quick/Standard market validation)
   - Brainstorm → [Market Val || Spec] → Plan → Build → Verify → Ship
   - Use for: Competitive features, market validation needed

3. **Strategic Path** (Deep market validation)
   - Brainstorm → Market Val → Spec → Plan → Build → Verify → Ship
   - Use for: New markets, strategic initiatives, major investments

---

**Version:** 2.0.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready (Enhanced)
**Enhancements:**
- Added optional Stage 1.5: Market Validation
- Integrated market-intelligence agent
- Three execution paths for different scenarios
- Decision framework for when to use market validation

---
name: product-review
description: Product/spec review with Product Manager and Architect agents
version: "2.0.0"
category: "team"
origin: "agent-skills"
agents_used:
  - product-manager
  - architect
skills_used:
  - spec-driven-development
  - brainstorming
  - writing-plans
  - api-interface-design
  - prd-generator
related_skills:
  - prd-generator
  - brainstorming
estimated_time: "2-4 hours"
---

# Product Review Workflow

## Overview

The Product Review workflow validates specifications, requirements, and business value from a product perspective while ensuring technical feasibility. It combines the Product Manager's business expertise with the Architect's technical assessment.

## When to Use

- New feature specification review
- Requirements validation
- Product roadmap planning
- Market fit assessment
- Business impact analysis
- Acceptance criteria review

## Lifecycle

DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE

### Phase Mapping

| Lifecycle Phase | Workflow Stage |
|-----------------|----------------|
| DEFINE | Gather specifications, user stories, and market context |
| PLAN | Business Requirements Review (Stage 1) |
| BUILD | Refine requirements and user stories based on review |
| VERIFY | Technical Feasibility Review (Stage 2) |
| REVIEW | Consolidated Product Assessment (Stage 3) |
| SHIP | Go/No-Go decision, refined spec delivered |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Specification documents provided
- [ ] User stories compiled
- [ ] Requirements documented
- [ ] Market context gathered
PASS → proceed | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Requirements validated
- [ ] GAP analysis completed
- [ ] Acceptance criteria reviewed
- [ ] Market fit assessed
- [ ] Business value confirmed
PASS → proceed | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Refined user stories created
- [ ] Acceptance criteria updated
- [ ] Business requirements finalized
PASS → proceed | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Technical feasibility confirmed
- [ ] Options identified
- [ ] Architecture impact assessed
- [ ] Effort estimated
- [ ] Risks identified
PASS → proceed | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Findings merged and aligned
- [ ] Requirements prioritized
- [ ] Recommendations actionable
- [ ] Go/No-Go decision made
- [ ] Scorecard completed
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

### Stage 1: Business Requirements Review (Product Manager)

**Agent:** product-manager

**Actions:**
- Review specifications from business perspective
- Perform GAP analysis (current vs desired state)
- Validate acceptance criteria
- Assess product-market fit
- Calculate ROI and business impact
- Review user stories (INVEST criteria)

**Input:**
- Specification documents
- User stories
- Requirements
- Market context

**Output:** Product Manager Review Report

**Quality Gate:**
- [ ] Requirements validated
- [ ] GAP analysis completed
- [ ] Acceptance criteria reviewed
- [ ] Market fit assessed
- [ ] Business value confirmed

---

### Stage 2: Technical Feasibility Review (Architect)

**Agent:** architect

**Actions:**
- Assess technical feasibility
- Identify technical options
- Evaluate architectural impact
- Assess development effort
- Identify technical risks
- Review integration requirements

**Input:**
- Product requirements
- Business context
- System architecture

**Output:** Technical Feasibility Assessment

**Quality Gate:**
- [ ] Technical feasibility confirmed
- [ ] Options identified
- [ ] Architecture impact assessed
- [ ] Effort estimated
- [ ] Risks identified

---

### Stage 3: Consolidated Product Assessment

**Agents:** product-manager + architect

**Actions:**
- Merge business and technical findings
- Identify business-technical alignment issues
- Prioritize requirements
- Create actionable recommendations
- Validate product-market fit with technical constraints

**Output:** Consolidated Product Review Report

**Quality Gate:**
- [ ] Findings merged
- [ ] Alignment validated
- [ ] Requirements prioritized
- [ ] Recommendations actionable
- [ ] Go/No-Go decision made

---

## Handoff Contracts

### To Product Manager
```yaml
provides:
  - specification_documents
  - user_stories
  - requirements
  - market_context
  - business_goals

expects:
  - requirements_validation
  - gap_analysis
  - acceptance_criteria_review
  - market_fit_assessment
  - business_impact_analysis
```

### Product Manager → Architect
```yaml
provides:
  - business_requirements
  - success_metrics
  - constraints
  - user_stories
  - acceptance_criteria

expects:
  - technical_feasibility
  - technical_options
  - effort_estimation
  - risk_assessment
```

---

## Product Review Framework

### Requirements Validation
```yaml
business_validation:
  problem_statement:
    - problem_clearly_defined
    - target_users_identified
    - pain_points_understood
    - market_opportunity_assessed

  solution_validation:
    - solution_addresses_problem
    - value_proposition_clear
    - competitive_advantage_identified
    - differentiation_clear

  business_value:
    - revenue_impact_assessed
    - cost_impact_understood
    - strategic_value_defined
    - metrics_to_track_identified

  feasibility:
    - technically_feasible
    - resource_requirements_known
    - timeline_realistic
    - dependencies_identified
```

### GAP Analysis Framework
```yaml
gap_types:
  business_gap:
    definition: misalignment_with_business_strategy
    questions:
      - does_this_support_business_goals
      - is_this_priority_for_business
      - what_is_opportunity_cost
      - are_we_building_right_thing

  user_gap:
    definition: mismatch_with_user_needs
    questions:
      - do_users_actually_need_this
      - have_we_talked_to_users
      - is_this_based_on_assumptions_or_data
      - what_is_user_value_proposition

  technical_gap:
    definition: missing_technical_capabilities
    questions:
      - do_we_have_required_tech_stack
      - is_technically_feasible
      - what_dependencies_exist
      - are_technical_risks_understood

  process_gap:
    definition: missing_processes_or_workflows
    questions:
      - how_will_this_be_operated
      - what_processes_need_to_change
      - are_teams_ready_for_this
      - what_training_is_needed
```

### Acceptance Criteria Review
```yaml
acceptance_criteria_quality:
  clarity:
    - criteria_are_unambiguous
    - clear_definition_of_done
    - no_subjective_terms
    - measurable_outcomes

  testability:
    - can_be_automated
    - can_be_manually_tested
    - pass_fail_clear
    - edge_cases_included

  completeness:
    - happy_path_covered
    - error_cases_covered
    - edge_cases_covered
    - boundary_conditions_covered

  traceability:
    - linked_to_user_story
    - linked_to_requirement
    - linked_to_business_goal
```

### User Story Validation (INVEST)
```yaml
invest_criteria:
  independent:
    - story_can_be_developed_independently
    - minimal_dependencies_on_other_stories
    - can_be_released_independently

  negotiable:
    - details_can_be_negotiated
    - multiple_implementation_approaches_possible
    - not_a_fixed_requirement

  valuable:
    - clear_value_to_user
    - supports_business_goal
    - roi_is_positive

  estimable:
    - team_can_estimate_effort
    - requirements_clear_enough
    - technical_feasibility_confirmed

  small:
    - can_be_completed_in_sprint
    - not_too_large_or_complex
    - can_be_split_further_if_needed

  testable:
    - acceptance_criteria_defined
    - can_be_verified
    - success_is_measurable
```

---

## Output Template

```markdown
# Product Review Report: [Feature/Spec]

**Review Date:** [Date]
**Reviewers:** Product Manager + Architect
**Feature/Spec:** [Name]

---

## Executive Summary

**Overall Business Quality:** [Score]/10
**Business Value:** [High/Medium/Low]
**Market Fit:** [Strong/Weak/None]
**Technical Feasibility:** [High/Medium/Low]
**Status:** [✅ APPROVED | ⚠️ NEEDS WORK | ❌ REJECTED]

---

## Requirements Validation

### Problem Statement
[Assessment of problem definition]

### Solution Validation
[Assessment of solution approach]

### Business Value
[Assessment of business impact and ROI]

### Feasibility
[Assessment of technical, resource, timeline feasibility]

**Findings:**
| Severity | Issue | Impact | Fix |
|----------|-------|--------|-----|
| [C/H/M/L] | [Issue] | [Impact] | [Fix] |

---

## GAP Analysis

### Current State
[Description of current situation]

### Desired State
[Description of desired future state]

### Identified Gaps

#### GAP 1: [Gap Name]
**Type:** [Business/User/Technical/Process]
**Severity:** [P0/P1/P2/P3]
**Description:** [Detailed description]

**Current:** [What we have]
**Desired:** [What we need]
**Impact:** [Business impact]

**Action Items:**
1. [Action 1]
2. [Action 2]

### GAP Summary
| GAP | Type | Priority | Effort | Impact |
|-----|------|----------|--------|--------|
| [Gap 1] | [Type] | [P0-P3] | [H/M/L] | [Impact] |

---

## Acceptance Criteria Review

### AC Quality Assessment
[Assessment of AC clarity, testability, completeness]

### Issues Found
| AC | Issue | Severity | Fix |
|----|-------|----------|-----|
| [AC #] | [Issue] | [Severity] | [Fix] |

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

---

## User Story Validation

### INVEST Assessment
| Criterion | Status | Notes |
|-----------|--------|-------|
| Independent | [✅/⚠️/❌] | [Notes] |
| Negotiable | [✅/⚠️/❌] | [Notes] |
| Valuable | [✅/⚠️/❌] | [Notes] |
| Estimable | [✅/⚠️/❌] | [Notes] |
| Small | [✅/⚠️/❌] | [Notes] |
| Testable | [✅/⚠️/❌] | [Notes] |

### Issues Found
| Story | Issue | Severity | Fix |
|-------|-------|----------|-----|
| [Story] | [Issue] | [Severity] | [Fix] |

---

## Technical Feasibility

### Feasibility Assessment
[Assessment of technical feasibility]

### Technical Options
1. [Option 1 - Description, Pros, Cons]
2. [Option 2 - Description, Pros, Cons]

### Effort Estimation
**Development Effort:** [Story points or time]
**Complexity:** [Low/Medium/High]
**Risks:** [List of technical risks]

### Architectural Impact
[Assessment of impact on existing architecture]

---

## Market Fit Analysis

### Problem Validation
- [✅/⚠️/❌] Problem is real and urgent
- [✅/⚠️/❌] Users actively looking for solution
- [✅/⚠️/❌] Problem is expensive to ignore

### Solution Validation
- [✅/⚠️/❌] Solution addresses problem
- [✅/⚠️/❌] Solution is better than alternatives
- [✅/⚠️/❌] Solution is feasible

### Market Validation
- [✅/⚠️/❌] Market is large enough
- [✅/⚠️/❌] Market is growing
- [✅/⚠️/❌] We can reach market

**Market Fit Verdict:** [Strong/Weak/None]

---

## Findings Summary

### Critical Issues (Must Fix)
| Issue | Impact | Fix |
|-------|--------|-----|
| [Issue] | [Impact] | [Fix] |

### High Issues (Should Fix)
| Issue | Impact | Fix |
|-------|--------|-----|
| [Issue] | [Impact] | [Fix] |

### Medium Issues (Nice to Have)
| Issue | Impact | Fix |
|-------|--------|-----|
| [Issue] | [Impact] | [Fix] |

---

## Recommendations

### Must Fix Before Proceeding
1. [Recommendation 1]
2. [Recommendation 2]

### Should Fix Before Launch
1. [Recommendation 1]
2. [Recommendation 2]

### Nice to Have
1. [Recommendation 1]
2. [Recommendation 2]

---

## Product Scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Business Value | [1-10] | [Notes] |
| Market Fit | [1-10] | [Notes] |
| Spec Quality | [1-10] | [Notes] |
| User Stories | [1-10] | [Notes] |
| Acceptance Criteria | [1-10] | [Notes] |
| Technical Feasibility | [1-10] | [Notes] |
| **Overall** | **[1-10]** | [Notes] |

---

## Decision

**Status:** [✅ APPROVED | ⚠️ CONDITIONAL | ❌ REJECTED]

**Rationale:**
[Reasoning for decision]

**Conditions (if CONDITIONAL):**
- [Condition 1]
- [Condition 2]

**Blocking Issues (if REJECTED):**
- [Issue 1]
- [Issue 2]

---

## Next Steps

1. [Step 1]
2. [Step 2]
3. [Step 3]

---

**Report Generated:** [Timestamp]
**Reviewed by:** Product Manager + Architect
```

---

## Success Criteria

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

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Primary Agents:** product-manager, architect

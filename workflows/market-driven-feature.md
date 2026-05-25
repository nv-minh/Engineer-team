---
name: market-driven-feature
description: Complete workflow from market discovery to production for market-driven features (integrates market-intelligence, brainstorming, product-manager, architect, planner)
version: "2.1.0"
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
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Market-Driven Feature Workflow

```
MARKET DISCOVERY → SOLUTION DESIGN → VALIDATION → BUSINESS CASE → SPEC → PLAN → BUILD → VERIFY → SHIP
      1                  2               3             4            5      6      7       8       9
```

## Decision Points

- **After Phase 1:** GO (viable) / PIVOT (refine market) / STOP (not viable)
- **After Phase 3:** GO (validated) / REFINE (revisit Phase 1-2) / PIVOT (new solution)
- **After Phase 4:** GO (strong case) / OPTIMIZE (refine) / STOP (not justified)

---

### Phase 1: Market Discovery

<thought>
Observe: Market opportunity identified but unvalidated — no sizing, competitive analysis, or customer data.
Analyze: Must perform market analysis (TAM/SAM/SOM, trends, segments), competitive intelligence (top 5-10 competitors, feature matrix, pricing), customer development (segments, JTBD, pain points, opportunity scoring). Gate requires market sized, competition mapped, segments identified, opportunity scored.
Plan: Invoke market-intelligence agent.
</thought>

<action>
type: invoke_agent
target: market-intelligence
params:
  task: market_discovery
  sub_tasks: [market_analysis, competitive_intelligence, customer_development]
  outputs: [MARKET-DISCOVERY-REPORT.md]
</action>

<observation>
result: Market sized with assumptions, competitive landscape mapped, customer segments identified, opportunity scored
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Market size quantified with assumptions
- [ ] Competitive landscape mapped
- [ ] Customer segments identified
- [ ] Market opportunity scored
- [ ] Go/no-go decision on market viability

**State Snapshot:**
```yaml
workflow_state:
  current_phase: MARKET_DISCOVERY
  completed: []
  next_action: "SOLUTION_DESIGN if GO"
```

---

### Phase 2: Solution Design

<thought>
Observe: Market discovery report available with competitive landscape and customer insights.
Analyze: Must brainstorm solutions within market constraints, design value proposition, define competitive positioning. Gate requires solution concepts aligned, value proposition compelling, differentiation clear.
Plan: Invoke brainstorming + market-intelligence agents (co-lead).
</thought>

<action>
type: invoke_agent
target: market-intelligence
params:
  co_lead: brainstorming
  optional_agent: architect
  task: solution_design
  input: MARKET-DISCOVERY-REPORT.md
  outputs: [SOLUTION-DESIGN-DOCUMENT.md, value_proposition, positioning_strategy]
</action>

<observation>
result: Solution concepts aligned with market, value proposition designed, positioning defined
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Solution concepts aligned with market needs
- [ ] Value proposition compelling
- [ ] Competitive differentiation clear
- [ ] Technical feasibility confirmed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SOLUTION_DESIGN
  completed: [MARKET_DISCOVERY]
  next_action: "VALIDATION"
```

---

### Phase 3: Validation

<thought>
Observe: Solution design complete with value proposition and positioning.
Analyze: Must validate with customers (interviews, hypothesis testing), validate competitive advantage, validate feature demand and willingness to pay. Gate requires customer needs confirmed, value prop validated, differentiation proven.
Plan: Invoke market-intelligence + product-manager agents.
</thought>

<action>
type: invoke_agent
target: market-intelligence
params:
  supporting_agent: product-manager
  task: validation
  sub_tasks: [customer_validation, competitive_validation, feature_validation]
  outputs: [VALIDATION-REPORT.md, feature_prioritization]
</action>

<observation>
result: Customer needs validated, value proposition confirmed, feature prioritization complete
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Customer needs validated through interviews
- [ ] Value proposition confirmed
- [ ] Competitive differentiation proven
- [ ] Feature prioritization complete
- [ ] Go/no-go decision on proceeding

**State Snapshot:**
```yaml
workflow_state:
  current_phase: VALIDATION
  completed: [MARKET_DISCOVERY, SOLUTION_DESIGN]
  next_action: "BUSINESS_CASE if GO"
```

---

### Phase 4: Business Case

<thought>
Observe: Validation passed — customer needs confirmed, differentiation proven.
Analyze: Must build financial model (revenue scenarios, cost structure, break-even), calculate ROI, define go-to-market strategy (channels, pricing, launch timeline, KPIs). Gate requires financials complete, ROI meets hurdles, GTM defined.
Plan: Invoke market-intelligence + product-manager agents.
</thought>

<action>
type: invoke_agent
target: market-intelligence
params:
  supporting_agent: product-manager
  task: business_case
  sub_tasks: [financial_modeling, roi_analysis, go_to_market_strategy]
  outputs: [BUSINESS-CASE-DOCUMENT.md]
</action>

<observation>
result: Financial projections complete, ROI meets hurdles, GTM strategy defined
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Financial projections complete
- [ ] ROI meets or exceeds hurdle rate
- [ ] Go-to-market strategy defined
- [ ] Risks identified and mitigated
- [ ] Investment decision made (go/no-go)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BUSINESS_CASE
  completed: [MARKET_DISCOVERY, SOLUTION_DESIGN, VALIDATION]
  next_action: "SPEC if approved"
```

---

### Phase 5: Spec (if Business Case Approved)

<thought>
Observe: Business case approved — must write spec enhanced with market insights.
Analyze: Must incorporate market insights into spec, define requirements from customer validation, set success metrics from market goals, include competitive differentiation requirements. Gate requires spec complete with market insights.
Plan: Invoke planner + product-manager + market-intelligence agents.
</thought>

<action>
type: invoke_agent
target: planner
params:
  supporting_agents: [product-manager, market-intelligence]
  skill: spec-driven-development
  task: write_market_informed_spec
  outputs: [SPEC.md]
</action>

<observation>
result: SPEC.md complete with market insights, competitive requirements, customer-driven requirements
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Spec covers all standard areas
- [ ] Market insights integrated
- [ ] Competitive differentiation captured
- [ ] Customer requirements validated
- [ ] User approved spec

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SPEC
  completed: [MARKET_DISCOVERY, SOLUTION_DESIGN, VALIDATION, BUSINESS_CASE]
  next_action: "PLAN"
```

---

### Phase 6: Plan

<thought>
Observe: Spec complete with market insights.
Analyze: Must break into tasks, estimate effort with market timeline considerations, include go-to-market milestones. Gate requires all requirements have tasks, no placeholders, GTM integrated.
Plan: Invoke planner + market-intelligence agents.
</thought>

<action>
type: invoke_agent
target: planner
params:
  supporting_agent: market-intelligence
  skill: writing-plans
  task: create_market_informed_plan
  outputs: [PLAN.md]
</action>

<observation>
result: Plan complete with tasks, estimates, market milestones, GTM integration
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] All requirements have tasks
- [ ] No placeholders in plan
- [ ] Market timeline considered
- [ ] Go-to-market integrated

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PLAN
  completed: [MARKET_DISCOVERY, SOLUTION_DESIGN, VALIDATION, BUSINESS_CASE, SPEC]
  next_action: "BUILD"
```

---

### Phase 7-9: Build → Verify → Ship

<thought>
Observe: Plan complete, ready for execution.
Analyze: Standard execution phases — same as new-feature workflow. Build with TDD, verify against spec, ship to production with GTM plan.
Plan: Invoke executor, verifier, code-reviewer agents.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: standard_build_verify_ship
  outputs: [working_code, tests_passing, deployed, gtm_ready]
</action>

<observation>
result: Code built, verified, deployed, business metrics baseline established
gate_status: PASS | FAIL
</observation>

**Quality Gates:**
- **BUILD:** Tasks completed, tests passing, code reviewed, market differentiation met
- **VERIFY:** Spec coverage 100%, quality gates passed, business metrics baseline set
- **SHIP:** Code review approved, deployed, GTM readiness confirmed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BUILD_VERIFY_SHIP
  completed: [MARKET_DISCOVERY, SOLUTION_DESIGN, VALIDATION, BUSINESS_CASE, SPEC, PLAN]
  next_action: "DONE"
```

---

## Handoff Contracts

### Phase 1 → Phase 2
```yaml
handoff:
  from: market-intelligence
  to: brainstorming + market-intelligence
  provides: [market_discovery_report, competitive_intelligence, customer_analysis]
  expects: [solution_design_document, value_proposition, positioning_strategy]
```

### Phase 2 → Phase 3
```yaml
handoff:
  from: brainstorming + market-intelligence
  to: market-intelligence + product-manager
  provides: [solution_design, value_proposition, positioning]
  expects: [validation_report, feature_prioritization, revised_value_proposition]
```

### Phase 3 → Phase 4
```yaml
handoff:
  from: market-intelligence + product-manager
  to: market-intelligence + product-manager
  provides: [validation_report, feature_priorities, validated_value_proposition]
  expects: [business_case_document, financial_projections, roi_analysis, go_to_market_strategy]
```

### Phase 4 → Phase 5
```yaml
handoff:
  from: market-intelligence + product-manager
  to: planner
  trigger: "Business case approved"
  provides: [business_case_document, market_insights, customer_requirements, competitive_positioning]
  expects: [spec_document, requirements_informed_by_validation]
```

## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

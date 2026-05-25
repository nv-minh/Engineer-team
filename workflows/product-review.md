---
name: product-review
description: Product/spec review with Product Manager and Architect agents
version: "2.1.0"
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
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Product Review Workflow

```
BUSINESS REQUIREMENTS → TECHNICAL FEASIBILITY → CONSOLIDATED ASSESSMENT
          1                      2                       3
```

---

### Stage 1: Business Requirements Review

<thought>
Observe: Specification documents, user stories, requirements, and market context available.
Analyze: Must review specs from business perspective, perform GAP analysis, validate acceptance criteria, assess market fit, calculate ROI. Gate requires requirements validated, GAP analysis done, market fit assessed.
Plan: Invoke product-manager agent.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  task: business_requirements_review
  input: [specifications, user_stories, requirements, market_context]
  outputs: [pm_review_report, gap_analysis, market_fit_assessment]
</action>

<observation>
result: Requirements validated, GAP analysis completed, market fit assessed, business value confirmed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Requirements validated
- [ ] GAP analysis completed
- [ ] Acceptance criteria reviewed
- [ ] Market fit assessed
- [ ] Business value confirmed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BUSINESS_REQUIREMENTS
  completed: []
  next_action: "TECHNICAL_FEASIBILITY"
```

---

### Stage 2: Technical Feasibility Review

<thought>
Observe: Business requirements validated, market fit confirmed.
Analyze: Must assess technical feasibility, identify options, evaluate architectural impact, estimate effort, identify risks. Gate requires feasibility confirmed, options identified, risks documented.
Plan: Invoke architect agent.
</thought>

<action>
type: invoke_agent
target: architect
params:
  task: technical_feasibility_review
  input: [product_requirements, business_context, system_architecture]
  outputs: [feasibility_assessment, technical_options, effort_estimate, risk_assessment]
</action>

<observation>
result: Feasibility confirmed, options identified, impact assessed, risks documented
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Technical feasibility confirmed
- [ ] Options identified
- [ ] Architecture impact assessed
- [ ] Effort estimated
- [ ] Risks identified

**State Snapshot:**
```yaml
workflow_state:
  current_phase: TECHNICAL_FEASIBILITY
  completed: [BUSINESS_REQUIREMENTS]
  next_action: "CONSOLIDATED"
```

---

### Stage 3: Consolidated Product Assessment

<thought>
Observe: Business review and technical feasibility review complete.
Analyze: Must merge findings, identify alignment issues, prioritize requirements, make Go/No-Go decision, create recommendations.
Plan: Invoke product-manager + architect for consolidation.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  supporting_agent: architect
  task: consolidate_product_review
  input: [pm_review_report, feasibility_assessment]
  outputs: [consolidated_report, recommendations, go_no_go_decision, scorecard]
</action>

<observation>
result: Findings merged, requirements prioritized, Go/No-Go decision made
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Findings merged
- [ ] Alignment validated
- [ ] Requirements prioritized
- [ ] Recommendations actionable
- [ ] Go/No-Go decision made

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONSOLIDATED
  completed: [BUSINESS_REQUIREMENTS, TECHNICAL_FEASIBILITY]
  next_action: "DONE"
```

---

## Handoff Contracts

### To Product Manager
```yaml
provides: [specification_documents, user_stories, requirements, market_context, business_goals]
expects: [requirements_validation, gap_analysis, acceptance_criteria_review, market_fit_assessment]
```

### Product Manager → Architect
```yaml
provides: [business_requirements, success_metrics, constraints, user_stories, acceptance_criteria]
expects: [technical_feasibility, technical_options, effort_estimation, risk_assessment]
```

## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |
| `AGENT_TIMEOUT` | Review agent exceeds time limit | Collect partial output, retry with narrower scope | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

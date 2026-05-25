---
name: design-review
description: UI/UX design review with Frontend Expert and Product Manager agents
version: "2.1.0"
category: "team"
origin: "agent-skills"
agents_used:
  - product-manager
  - frontend-expert
skills_used:
  - frontend-patterns
  - code-review
  - browser-testing
  - performance-optimization
  - ux-audit
related_skills:
  - ux-audit
  - frontend-patterns
  - browser-testing
estimated_time: "2-4 hours"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Design Review Workflow

```
PRODUCT REQUIREMENTS → UI/UX TECHNICAL REVIEW → CONSOLIDATED ASSESSMENT
         1                      2                        3
```

---

### Stage 1: Product Requirements Review

<thought>
Observe: User stories, wireframes, requirements, and user flows available.
Analyze: Must validate user stories (INVEST criteria), review user flows, assess acceptance criteria, confirm business value. Gate requires stories validated, flows reviewed, criteria assessed.
Plan: Invoke product-manager agent.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  task: product_requirements_review
  input: [user_stories, wireframes, requirements, user_flows]
  outputs: [pm_review_report]
</action>

<observation>
result: User stories validated, flows reviewed, acceptance criteria assessed, business value confirmed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] User stories validated (INVEST criteria)
- [ ] User flows reviewed
- [ ] Acceptance criteria assessed
- [ ] Business value confirmed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PRODUCT_REQUIREMENTS
  completed: []
  next_action: "UI_UX_TECHNICAL"
```

---

### Stage 2: UI/UX Technical Review

<thought>
Observe: Product requirements validated, business context confirmed.
Analyze: Must review component architecture, state management, Core Web Vitals (LCP, FID, CLS), responsive design, accessibility (WCAG 2.1 AA/AAA), performance. Gate requires all technical areas reviewed.
Plan: Invoke frontend-expert agent.
</thought>

<action>
type: invoke_agent
target: frontend-expert
params:
  task: ui_ux_technical_review
  input: [design_mockups, component_specs, user_flows, performance_requirements]
  outputs: [frontend_review_report, accessibility_audit, performance_metrics]
</action>

<observation>
result: Component architecture reviewed, accessibility audited, performance analyzed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Component architecture reviewed
- [ ] State management assessed
- [ ] Core Web Vitals analyzed
- [ ] Responsive design verified
- [ ] Accessibility audit completed
- [ ] Performance assessed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: UI_UX_TECHNICAL
  completed: [PRODUCT_REQUIREMENTS]
  next_action: "CONSOLIDATED"
```

---

### Stage 3: Consolidated Design Assessment

<thought>
Observe: Product requirements review and UI/UX technical review complete.
Analyze: Must merge business and technical findings, identify UX issues, prioritize improvements, create actionable recommendations. Gate requires findings merged, recommendations actionable, scorecard completed.
Plan: Invoke product-manager + frontend-expert agents for consolidation.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  supporting_agent: frontend-expert
  task: consolidate_design_review
  input: [pm_review_report, frontend_review_report]
  outputs: [consolidated_report, ux_issues, recommendations, scorecard]
</action>

<observation>
result: Findings merged, UX issues identified, improvements prioritized, scorecard completed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Findings merged
- [ ] UX issues identified
- [ ] Improvements prioritized
- [ ] Recommendations actionable
- [ ] Scorecard completed
- [ ] Decision made (APPROVED/NEEDS WORK/REJECTED)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONSOLIDATED
  completed: [PRODUCT_REQUIREMENTS, UI_UX_TECHNICAL]
  next_action: "DONE"
```

---

## Handoff Contracts

### To Product Manager
```yaml
provides: [user_stories, wireframes, mockups, user_flows]
expects: [user_story_validation, flow_review, acceptance_criteria_assessment, business_value_confirmation]
```

### Product Manager → Frontend Expert
```yaml
provides: [validated_user_stories, flow_requirements, acceptance_criteria, business_context]
expects: [ui_ux_review, component_assessment, accessibility_audit, performance_analysis]
```

### Frontend Expert → Consolidation
```yaml
provides: [ui_findings, component_assessment, accessibility_report, performance_metrics]
expects: [consolidation, ux_improvements, recommendations]
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

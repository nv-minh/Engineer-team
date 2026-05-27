---
name: architecture-review
description: Architecture review with Architect and Staff Engineer agents
version: "2.2.0"
category: "team"
origin: "agent-skills"
agents_used:
  - architect
  - staff-engineer
skills_used:
  - code-review
  - documentation
  - performance-optimization
  - writing-plans
  - architecture-zoom-out
  - architecture-improvement
related_skills:
  - architecture-zoom-out
  - architecture-improvement
  - code-review
estimated_time: "2-4 hours (standard) / 1-2 days (comprehensive)"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Architecture Review Workflow

```
ENTRY CRITERIA → ARCHITECTURE ANALYSIS → DEEP TECHNICAL REVIEW → CONSOLIDATED ASSESSMENT
       0                  1                       2                        3
```

---

### Stage 0: Entry Criteria (MANDATORY)

Before triggering architecture review, verify:
- [ ] Clear problem statement exists (what needs to be decided/reviewed?)
- [ ] Requirements document / spec available for context
- [ ] Current architecture documented or describable (at least verbally)
- [ ] Scope bounded: what's in scope vs out?

If ANY unchecked → **BLOCKED**. Clarify with user before Stage 1.

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ENTRY_CRITERIA
  completed: []
  next_action: "ARCHITECTURE_ANALYSIS"
```

---

### Stage 1: Architecture Analysis

<thought>
Observe: Architecture diagrams, technical design, ADRs, and requirements available.
Analyze: Must identify architectural pattern, assess principles (cohesion, coupling, SoC), evaluate scalability, review ADRs. Gate requires pattern identified, principles assessed, design reviewed, scorecard completed.
Plan: Invoke architect agent.
</thought>

<action>
type: invoke_agent
target: architect
params:
  task: architecture_analysis
  input: [architecture_diagrams, technical_design, adrs, requirements]
  outputs: [architecture_review_report, pattern_assessment, scalability_analysis, scorecard]
</action>

<observation>
result: Pattern identified, principles assessed, design reviewed, scorecard completed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Architectural pattern identified
- [ ] Principles assessed
- [ ] Design reviewed
- [ ] Scalability evaluated
- [ ] Scorecard completed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ARCHITECTURE_ANALYSIS
  completed: []
  next_action: "DEEP_TECHNICAL_REVIEW"
```

---

### Stage 2: Deep Technical Review

<thought>
Observe: Architecture review complete with pattern assessment and scalability concerns.
Analyze: Must analyze cross-service impact, map dependencies, assess performance implications, identify risks. Gate requires cross-service impact analyzed, dependencies mapped, risks identified.
Plan: Invoke staff-engineer agent.
</thought>

<action>
type: invoke_agent
target: staff-engineer
params:
  task: deep_technical_review
  input: [architecture_review, system_context, performance_requirements]
  outputs: [technical_report, cross_service_impact, dependency_analysis, risk_assessment]
</action>

<observation>
result: Cross-service impact analyzed, dependencies mapped, performance assessed, risks identified
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Cross-service impact analyzed
- [ ] Dependencies mapped
- [ ] Performance implications assessed
- [ ] Risks identified

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEEP_TECHNICAL_REVIEW
  completed: [ARCHITECTURE_ANALYSIS]
  next_action: "CONSOLIDATED_ASSESSMENT"
```

---

### Stage 3: Consolidated Architecture Assessment

<thought>
Observe: Architecture review and technical review both complete.
Analyze: Must merge findings, prioritize risks, create actionable roadmap, make decision (APPROVED/CONDITIONAL/REJECTED). Gate requires findings merged, risks prioritized, recommendations actionable, roadmap defined.
Plan: Invoke architect + staff-engineer agents for consolidation.
</thought>

<action>
type: invoke_agent
target: architect
params:
  supporting_agent: staff-engineer
  task: consolidate_assessment
  input: [architecture_review, technical_report]
  outputs: [consolidated_report, prioritized_risks, actionable_roadmap, decision]
</action>

<observation>
result: Findings merged, risks prioritized, roadmap defined, decision documented
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Findings merged
- [ ] Risks prioritized
- [ ] Recommendations actionable
- [ ] Roadmap defined
- [ ] Decision made (APPROVED/CONDITIONAL/REJECTED)
- [ ] ADR produced with decision, alternatives, trade-offs, compliance criteria
- [ ] Compliance criteria list (3-5 enforceable rules for implementation team)
- [ ] ADR committed to docs/adr/

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONSOLIDATED_ASSESSMENT
  completed: [ARCHITECTURE_ANALYSIS, DEEP_TECHNICAL_REVIEW]
  next_action: "DONE"
```

---

## Handoff Contracts

### To Architect
```yaml
provides: [architecture_diagrams, technical_design, requirements, constraints]
expects: [architecture_review, pattern_assessment, scalability_analysis, design_recommendations]
```

### Architect → Staff Engineer
```yaml
provides: [architecture_review, pattern_identification, scalability_concerns, integration_points]
expects: [cross_service_impact, dependency_analysis, performance_implications, technical_risks]
```

### Staff Engineer → Consolidation
```yaml
provides: [technical_findings, impact_analysis, risk_assessment, recommendations]
expects: [consolidation, prioritization, roadmap]
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

## Post-Review: Compliance Monitoring

Architecture recommendations are living decisions. After implementation:
- Executor includes compliance criteria in implementation plan
- Verifier checks compliance criteria as part of VERIFY stage
- `architecture-improvement` skill tracks drift quarterly

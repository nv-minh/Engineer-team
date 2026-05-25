---
name: discovery-process
description: "Complete discovery cycle from problem hypothesis to validated solution. Orchestrates problem framing, customer interviews, synthesis, and experimentation. Use for systematic exploration before committing to development."
version: "2.1.0"
category: "primary"
origin: "agent-skills"
last_updated: 2026-05-23
status: Production Ready
agents_used:
  - "product-manager"
  - "market-intelligence"
  - "planner"
skills_used:
  - brainstorming
  - spec-driven-development
  - writing-plans
related_skills:
  - brainstorming
  - spec-driven-development
  - opportunity-solution-tree
estimated_time: "3-8 weeks"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Discovery Process Workflow

```
FRAME → RESEARCH PLAN → CONDUCT RESEARCH → SYNTHESIZE → SOLUTIONS → DECIDE
  1          2                 3                4           5          6

Timeline: 2-4 weeks per discovery cycle
```

---

### Stage 1: Frame the Problem (Day 1-2)

<thought>
Observe: Problem area identified but hypothesis unvalidated, research questions undefined.
Analyze: Must define what to investigate, who is affected, and success criteria. Run problem framing (lean-ux-canvas), create formal problem statement, define proto-personas and JTBD if needed. Gate requires hypothesis stated, research questions defined, success criteria established.
Plan: Invoke product-manager agent with lean-ux-canvas skill.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  skills: [lean-ux-canvas, jobs-to-be-done]
  task: frame_problem
  outputs: [problem_hypothesis, research_questions, success_criteria, target_personas]
</action>

<observation>
result: Problem hypothesis stated, 3-5 research questions defined, success criteria established
gate_status: PASS | FAIL
</observation>

**Decision Point 1:** Enough context? YES → Stage 2. NO → Gather existing data first (+2-3 days).

**Quality Gate:**
- [ ] Problem hypothesis clearly stated
- [ ] Research questions defined (3-5)
- [ ] Success criteria established
- [ ] Target personas identified

**State Snapshot:**
```yaml
workflow_state:
  current_phase: FRAME
  completed: []
  next_action: "RESEARCH_PLAN"
```

---

### Stage 2: Research Planning (Day 3)

<thought>
Observe: Problem framed, research questions defined.
Analyze: Must design research approach, create interview guide (5-7 Mom Test questions), recruit 5-10 participants, schedule interviews (45-60 min each). Gate requires guide created, participants recruited, interviews scheduled.
Plan: Invoke product-manager agent.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  task: plan_research
  outputs: [interview_guide, participant_roster, synthesis_plan]
</action>

<observation>
result: Interview guide created, 5-10 participants recruited, interviews scheduled
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Interview guide created (5-7 questions)
- [ ] 5-10 participants recruited
- [ ] Interviews scheduled
- [ ] Synthesis plan defined

**State Snapshot:**
```yaml
workflow_state:
  current_phase: RESEARCH_PLAN
  completed: [FRAME]
  next_action: "CONDUCT_RESEARCH"
```

---

### Stage 3: Conduct Research (Week 1-2)

<thought>
Observe: Interview guide ready, participants scheduled.
Analyze: Must conduct 5-10 customer interviews focused on past behavior (not hypotheticals), take structured notes, review support tickets and analytics in parallel. Check for saturation — same patterns across 3+ interviews.
Plan: Invoke product-manager agent to conduct interviews.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  task: conduct_research
  focus: past_behavior
  parallel: [support_ticket_review, analytics_analysis]
  outputs: [interview_transcripts, support_themes, analytics_insights]
</action>

<observation>
result: 5-10 interviews completed, structured notes taken, saturation assessed
gate_status: PASS | FAIL
</observation>

**Decision Point 2:** Saturation reached? YES → Stage 4. NO → Schedule 3-5 more interviews (+1 week).

**Quality Gate:**
- [ ] 5-10 customer interviews completed
- [ ] Structured notes taken
- [ ] Support tickets reviewed
- [ ] Analytics analyzed
- [ ] Saturation reached (same patterns across 3+ interviews)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONDUCT_RESEARCH
  completed: [FRAME, RESEARCH_PLAN]
  next_action: "SYNTHESIZE"
```

---

### Stage 4: Synthesize Insights (End of Week 2)

<thought>
Observe: Research complete, interviews transcribed, support and analytics data gathered.
Analyze: Must perform affinity mapping (group insights by theme, count frequency), prioritize pain points by frequency x intensity x strategic fit, update problem statement based on evidence. Gate requires affinity mapping done, top 3-5 pain points prioritized, problem statement validated.
Plan: Invoke product-manager agent.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  task: synthesize_insights
  input: [interview_transcripts, support_themes, analytics_insights]
  outputs: [affinity_map, top_pain_points, customer_quotes, validated_problem_statement]
</action>

<observation>
result: Affinity mapping complete, top 3-5 pain points prioritized, problem statement validated
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Affinity mapping completed
- [ ] Pain points prioritized (top 3-5)
- [ ] Customer quotes collected
- [ ] Problem statement validated/refined

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SYNTHESIZE
  completed: [FRAME, RESEARCH_PLAN, CONDUCT_RESEARCH]
  next_action: "SOLUTIONS"
```

---

### Stage 5: Generate & Validate Solutions (Week 3)

<thought>
Observe: Top pain points identified and prioritized.
Analyze: Must generate Opportunity Solution Tree (3 opportunities, 3 solutions each), design experiments (concierge, prototype, landing page, A/B, PoL probe), run experiments, gather validation data. Gate requires opportunities identified, experiments run, results analyzed.
Plan: Invoke product-manager + market-intelligence agents with opportunity-solution-tree skill.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  skills: [opportunity-solution-tree, pol-probe]
  supporting_agent: market-intelligence
  task: generate_and_validate_solutions
  input: top_pain_points
  outputs: [solution_options, experiment_designs, experiment_results, customer_feedback]
</action>

<observation>
result: 3 opportunities with solutions generated, experiments run, validation data collected
gate_status: PASS | FAIL
</observation>

**Decision Point 3:** Validated? YES → Stage 6. NO → Pivot to next solution (+1-2 weeks).

**Quality Gate:**
- [ ] 3 opportunities identified
- [ ] 3 solutions per opportunity generated
- [ ] Experiments designed and run
- [ ] Results analyzed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SOLUTIONS
  completed: [FRAME, RESEARCH_PLAN, CONDUCT_RESEARCH, SYNTHESIZE]
  next_action: "DECIDE"
```

---

### Stage 6: Decide & Document (End of Week 3-4)

<thought>
Observe: Solutions validated through experiments.
Analyze: Must make Go/No-Go decision (GO/PIVOT/KILL) based on problem validation, solution validation, strategic fit, feasibility. If GO: define epic hypotheses, write PRD, communicate to stakeholders. Gate requires decision made, deliverables produced, stakeholders aligned.
Plan: Invoke product-manager + planner agents.
</thought>

<action>
type: invoke_agent
target: product-manager
params:
  supporting_agent: planner
  task: decide_and_document
  decision_criteria: [problem_validated, solution_validated, strategic_fit, feasibility]
  outputs: [go_no_go_decision, epic_hypotheses, prd, stakeholder_communication]
</action>

<observation>
result: GO/PIVOT/KILL decision made, deliverables produced (if GO), stakeholders aligned
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Go/No-Go decision made (GO/PIVOT/KILL)
- [ ] Epic hypotheses defined (if GO)
- [ ] PRD written (if GO)
- [ ] Stakeholders communicated with
- [ ] Next steps clear

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DECIDE
  completed: [FRAME, RESEARCH_PLAN, CONDUCT_RESEARCH, SYNTHESIZE, SOLUTIONS]
  next_action: "DONE"
```

---

## Integration with EM-Team

| Stage | Skills Used |
|---|---|
| Stage 1 | `lean-ux-canvas`, `jobs-to-be-done` |
| Stage 4 | `customer-journey-map` (optional) |
| Stage 5 | `opportunity-solution-tree`, `pol-probe` |

| Agent | Role |
|---|---|
| product-manager | Orchestrates discovery, conducts interviews, synthesizes |
| market-intelligence | Validates market assumptions, competitive context |
| planner | Receives validated PRD, creates implementation plan |

## Common Pitfalls

- **Skipping interviews:** Always interview 5-10 customers per cycle
- **Leading questions:** Focus on past behavior, not hypotheticals
- **Insufficient saturation:** Continue until same patterns in 3+ interviews
- **Analysis paralysis:** Time-box discovery to 3-4 weeks
- **One-time discovery:** Run continuous discovery (1 interview/week)

## Handoff Contracts

### Discover → Validate
```yaml
handoff:
  from: product-manager
  to: market-intelligence
  provides: [problem_hypothesis, customer_segments, experiment_designs]
  expects: [market_validation_report, go_no_go_decision]
```

### Validate → Define
```yaml
handoff:
  from: market-intelligence
  to: planner
  provides: [validated_problem, market_data, strategic_recommendations]
  expects: [prd_document, epic_breakdown, roadmap]
```

---

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

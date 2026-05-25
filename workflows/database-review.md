---
name: database-review
description: Database schema & query review with Database Expert and Architect agents
version: "2.1.0"
category: "team"
origin: "agent-skills"
agents_used:
  - database-expert
  - architect
skills_used:
  - backend-patterns
  - code-review
  - performance-optimization
related_skills:
  - backend-patterns
  - performance-optimization
  - code-review
estimated_time: "2-4 hours"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Database Review Workflow

```
SCHEMA & QUERY REVIEW → DATA ARCHITECTURE REVIEW → CONSOLIDATED ASSESSMENT
          1                       2                         3
```

---

### Stage 1: Database Schema & Query Review

<thought>
Observe: Schema DDL, query lists, migration scripts, and performance requirements available.
Analyze: Must review schema design (normalization, naming, types), analyze query performance, assess indexing strategy, review migration plan, evaluate data integrity, review fintech patterns if applicable. Gate requires all areas reviewed.
Plan: Invoke database-expert agent.
</thought>

<action>
type: invoke_agent
target: database-expert
params:
  task: schema_query_review
  input: [schema_ddl, query_lists, migration_scripts, performance_requirements]
  outputs: [db_review_report, query_analysis, indexing_recommendations]
</action>

<observation>
result: Schema reviewed, query performance assessed, indexing evaluated, migration reviewed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Schema design reviewed
- [ ] Query performance assessed
- [ ] Indexing strategy evaluated
- [ ] Migration plan reviewed
- [ ] Data integrity verified

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SCHEMA_QUERY_REVIEW
  completed: []
  next_action: "DATA_ARCHITECTURE"
```

---

### Stage 2: Data Architecture Review

<thought>
Observe: Database review findings available.
Analyze: Must assess data architecture in system context, review integration points, evaluate data flow, assess scalability of data layer. Gate requires data architecture assessed, integration points reviewed, scalability assessed.
Plan: Invoke architect agent.
</thought>

<action>
type: invoke_agent
target: architect
params:
  task: data_architecture_review
  input: [db_review_report, system_architecture, integration_requirements]
  outputs: [data_architecture_assessment]
</action>

<observation>
result: Data architecture assessed, integration points reviewed, scalability analyzed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Data architecture assessed
- [ ] Integration points reviewed
- [ ] Data flow evaluated
- [ ] Scalability assessed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DATA_ARCHITECTURE
  completed: [SCHEMA_QUERY_REVIEW]
  next_action: "CONSOLIDATED"
```

---

### Stage 3: Consolidated Database Assessment

<thought>
Observe: Database review and architecture assessment complete.
Analyze: Must merge findings, identify bottlenecks, prioritize optimizations, validate migration plan, create scorecard and recommendations.
Plan: Invoke database-expert + architect for consolidation.
</thought>

<action>
type: invoke_agent
target: database-expert
params:
  supporting_agent: architect
  task: consolidate_database_review
  input: [db_review_report, data_architecture_assessment]
  outputs: [consolidated_report, bottlenecks, recommendations, scorecard]
</action>

<observation>
result: Findings merged, bottlenecks identified, recommendations prioritized, migration validated
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Findings merged
- [ ] Bottlenecks identified
- [ ] Recommendations prioritized
- [ ] Migration plan validated
- [ ] Scorecard completed

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONSOLIDATED
  completed: [SCHEMA_QUERY_REVIEW, DATA_ARCHITECTURE]
  next_action: "DONE"
```

---

## Handoff Contracts

### To Database Expert
```yaml
provides: [schema_definition, query_lists, migration_scripts, performance_requirements, data_models]
expects: [schema_review, query_optimization, migration_review, scaling_recommendations]
```

### Database Expert → Architect
```yaml
provides: [schema_assessment, query_performance_analysis, indexing_recommendations, data_integrity_review]
expects: [data_architecture_review, integration_assessment, scalability_analysis, data_flow_evaluation]
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

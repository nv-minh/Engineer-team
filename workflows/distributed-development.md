---
name: distributed-development
description: Coordinate distributed agents across tmux sessions for multi-domain feature development
version: "2.1.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - "techlead-orchestrator"
  - "database-expert"
  - "backend-expert"
  - "frontend-expert"
  - "code-reviewer"
  - "security-reviewer"
skills_used:
  - spec-driven-development
  - writing-plans
  - incremental-implementation
  - code-review
  - security-audit
  - e2e-testing
related_skills:
  - incremental-implementation
  - subagent-driven-development
  - code-review
estimated_time: "7-14 hours"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Distributed Development Workflow

```
REQUIREMENTS → DELEGATE → DESIGN/CONTRACT → BACKEND → FRONTEND → INTEGRATION → CONSOLIDATION → APPROVAL
      1            2             3              4          5            6              7              8
```

**CRITICAL:** Tech Lead MUST delegate all implementation to agent sessions. See [Delegation Protocol](../protocols/delegation-protocol.md).

## Prerequisites

```bash
./scripts/distributed-orchestrator.sh start
tmux list-windows -t claude-work  # Verify: techlead, backend, frontend, database
```

---

### Phase 1: Requirements Analysis & Task Breakdown

<thought>
Observe: Feature requirements received — must determine scope across domains.
Analyze: Must analyze requirements, determine scope (backend, frontend, database), select agents, create development plan with execution strategy and sync points. Tech Lead ONLY analyzes — NO implementation.
Plan: Invoke techlead-orchestrator agent.
</thought>

<action>
type: invoke_agent
target: techlead-orchestrator
params:
  task: analyze_requirements
  outputs: [scope_analysis, agent_selection, development_plan, sync_points]
</action>

<observation>
result: Scope determined, agents selected, development plan created with sync points
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Feature requirements analyzed
- [ ] Scope determined (backend, frontend, database)
- [ ] Agent selection completed
- [ ] Development plan created

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REQUIREMENTS
  completed: []
  next_action: "DELEGATE"
```

---

### Phase 2: Delegate Tasks to Agent Sessions

<thought>
Observe: Development plan ready with agent assignments.
Analyze: MUST delegate ALL implementation to agent sessions. Tech Lead must NOT implement. Assign tasks to tmux sessions, monitor delegation, wait for reports.
Plan: Send task assignments to agent sessions.
</thought>

<action>
type: invoke_agent
target: techlead-orchestrator
params:
  task: delegate_tasks
  mandate: "NO IMPLEMENTATION — DELEGATE ONLY"
  outputs: [tasks_assigned, sessions_active]
</action>

<observation>
result: Tasks delegated to all agent sessions, agents working
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Tasks delegated to sessions
- [ ] Agent sessions confirmed active
- [ ] Execution strategy communicated

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DELEGATE
  completed: [REQUIREMENTS]
  next_action: "DESIGN_CONTRACT"
```

---

### Phase 3: Design & Contract

<thought>
Observe: Tasks delegated to agents.
Analyze: Database expert designs schema first (dependency for backend). Backend expert designs API contract (dependency for frontend). Tech Lead shares schema with backend when ready.
Plan: Sequential — database first, then share with backend.
</thought>

<action>
type: invoke_agent
target: database-expert
params:
  task: design_schema
  outputs: [schema_design, migration_plan, api_requirements]
</action>

<observation>
result: Schema designed, migration plan created, API requirements defined
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Database schema designed and reviewed
- [ ] API contract defined
- [ ] Frontend components specified

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DESIGN_CONTRACT
  completed: [REQUIREMENTS, DELEGATE]
  next_action: "BACKEND"
```

---

### Phase 4: Backend API Development

<thought>
Observe: Database schema designed, shared with backend.
Analyze: Backend expert designs and implements API based on schema. Must include auth, validation, error handling, tests.
Plan: Invoke backend-expert agent.
</thought>

<action>
type: invoke_agent
target: backend-expert
params:
  task: implement_api
  input: [schema_design, api_requirements]
  outputs: [api_implementation, api_specification, unit_tests, completion_notification]
</action>

<observation>
result: API implemented with auth, validation, tests; OpenAPI spec generated
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Backend API implemented
- [ ] API specification documented
- [ ] Unit tests passing

**State Snapshot:**
```yaml
workflow_state:
  current_phase: BACKEND
  completed: [REQUIREMENTS, DELEGATE, DESIGN_CONTRACT]
  next_action: "FRONTEND"
```

---

### Phase 5: Frontend UI Development

<thought>
Observe: Backend API complete, API spec available.
Analyze: Tech Lead shares API spec with frontend. Frontend expert implements UI components using the API. Must include auth, error handling, loading states, responsive design.
Plan: Invoke frontend-expert agent.
</thought>

<action>
type: invoke_agent
target: frontend-expert
params:
  task: implement_ui
  input: [api_specification]
  outputs: [components, hooks, types, completion_notification]
</action>

<observation>
result: Frontend UI implemented with components, hooks, responsive design
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Frontend UI implemented
- [ ] Components, hooks, types created
- [ ] Responsive layouts working

**State Snapshot:**
```yaml
workflow_state:
  current_phase: FRONTEND
  completed: [REQUIREMENTS, DELEGATE, DESIGN_CONTRACT, BACKEND]
  next_action: "INTEGRATION"
```

---

### Phase 6: Integration & Testing

<thought>
Observe: All layers implemented — database, backend, frontend.
Analyze: Must verify API contract matches schema, frontend uses correct API calls, error handling works across layers. Run integration tests and E2E tests.
Plan: Invoke all agents for sync point, then run tests.
</thought>

<action>
type: invoke_agent
target: techlead-orchestrator
params:
  task: integration_testing
  sync_point: "API Contract Review"
  participants: [database-expert, backend-expert, frontend-expert]
  outputs: [contract_verified, integration_tests, e2e_tests]
</action>

<observation>
result: API contract verified, integration tests passing, E2E tests passing
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Integration tests passing
- [ ] E2E tests passing
- [ ] API contract verified
- [ ] Cross-agent dependencies validated

**State Snapshot:**
```yaml
workflow_state:
  current_phase: INTEGRATION
  completed: [REQUIREMENTS, DELEGATE, DESIGN_CONTRACT, BACKEND, FRONTEND]
  next_action: "CONSOLIDATION"
```

---

### Phase 7: Consolidation & Handoff

<thought>
Observe: Integration tests passing, all layers verified.
Analyze: Must collect reports from all agents, create consolidated feature report with implementation summary, integration results, deployment checklist.
Plan: Invoke techlead-orchestrator to consolidate.
</thought>

<action>
type: invoke_agent
target: techlead-orchestrator
params:
  task: consolidate_feature
  outputs: [consolidated_report, deployment_checklist]
</action>

<observation>
result: Consolidated report generated, ready for review
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Consolidated report generated
- [ ] Documentation complete
- [ ] Deployment checklist ready

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONSOLIDATION
  completed: [REQUIREMENTS, DELEGATE, DESIGN_CONTRACT, BACKEND, FRONTEND, INTEGRATION]
  next_action: "APPROVAL"
```

---

### Phase 8: Approval & Merge

<thought>
Observe: Consolidated report ready, all tests passing.
Analyze: Must run code review and security review before approval. Gate requires both reviews approved.
Plan: Invoke code-reviewer and security-reviewer agents.
</thought>

<action>
type: invoke_agent
target: code-reviewer
params:
  supporting_agent: security-reviewer
  task: final_review
  outputs: [code_review_approved, security_review_approved, final_decision]
</action>

<observation>
result: Code review approved, security review approved, APPROVED FOR MERGE
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Code review approved
- [ ] Security review approved
- [ ] Consolidated report generated
- [ ] Documentation complete

**State Snapshot:**
```yaml
workflow_state:
  current_phase: APPROVAL
  completed: [REQUIREMENTS, DELEGATE, DESIGN_CONTRACT, BACKEND, FRONTEND, INTEGRATION, CONSOLIDATION]
  next_action: "DONE"
```

---

## Workflow Commands

```bash
./scripts/distributed-orchestrator.sh start
./scripts/session-manager.sh status
./scripts/consolidate-reports.sh collect
./scripts/consolidate-reports.sh consolidate
```

## Handoff Contracts

### Orchestrator → Domain Agents
```yaml
handoff:
  from: techlead-orchestrator
  to: [backend-expert, frontend-expert, database-expert]
  provides: [feature_slice, spec_section, dependencies, priority]
  expects: [implementation_commits, test_results, status_updates]
```

### Domain Agents → Integration
```yaml
handoff:
  from: [backend-expert, frontend-expert, database-expert]
  to: techlead-orchestrator
  provides: [completed_slices, integration_points, blocking_issues]
  expects: [consolidated_integration_report, merge_plan]
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

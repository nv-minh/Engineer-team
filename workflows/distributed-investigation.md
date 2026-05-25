---
name: distributed-investigation
description: Coordinate distributed agents across tmux sessions for multi-domain bug investigation and root cause analysis
version: "2.1.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - "techlead-orchestrator"
  - "backend-expert"
  - "frontend-expert"
  - "database-expert"
  - "staff-engineer"
  - "security-reviewer"
skills_used:
  - systematic-debugging
  - performance-optimization
  - security-audit
  - documentation
related_skills:
  - systematic-debugging
  - architecture-zoom-out
  - security-audit
estimated_time: "2-6 hours"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Distributed Investigation Workflow

```
INITIAL ANALYSIS → TASK DELEGATION → INVESTIGATION → COORDINATION → REPORTS → CONSOLIDATION → ACTION
       1                 2                3               4             5            6            7
```

## Prerequisites

```bash
./scripts/distributed-orchestrator.sh start
```

---

### Phase 1: Initial Analysis

<thought>
Observe: Bug report received — affected domains unknown, severity unassessed.
Analyze: Must analyze bug to determine scope (backend, frontend, database, infra), assess severity, select appropriate agents, create investigation plan. Gate requires scope determined, severity assessed, agents selected, plan created.
Plan: Invoke techlead-orchestrator agent.
</thought>

<action>
type: invoke_agent
target: techlead-orchestrator
params:
  task: analyze_bug
  input: bug_report
  outputs: [scope_analysis, severity, agent_selection, investigation_plan]
</action>

<observation>
result: Scope determined, severity assessed, agents selected, investigation plan created
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Bug report analyzed
- [ ] Scope determined (affected domains)
- [ ] Severity assessed
- [ ] Agent selection completed
- [ ] Investigation plan created

**State Snapshot:**
```yaml
workflow_state:
  current_phase: INITIAL_ANALYSIS
  completed: []
  next_action: "TASK_DELEGATION"
```

---

### Phase 2: Task Delegation (Automated)

<thought>
Observe: Investigation plan ready with agent assignments.
Analyze: Must delegate tasks to agent sessions via auto-delegate script. Script generates task IDs, creates YAMLs, notifies sessions, monitors progress.
Plan: Run auto-delegate.sh with task description, agents, and priority.
</thought>

<action>
type: invoke_skill
target: auto-delegate
params:
  command: "bash scripts/auto-delegate.sh '[description]' '[agents]' [priority]"
  outputs: [task_assignments, session_notifications]
</action>

<observation>
result: Tasks delegated to agent sessions, queue monitors active
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Tasks delegated to agent sessions
- [ ] Execution strategy determined (parallel/sequential/hybrid)
- [ ] Agent sessions confirmed active

**State Snapshot:**
```yaml
workflow_state:
  current_phase: TASK_DELEGATION
  completed: [INITIAL_ANALYSIS]
  next_action: "INVESTIGATION"
```

---

### Phase 3: Distributed Investigation

<thought>
Observe: Tasks delegated, agents working independently in tmux sessions.
Analyze: Agents investigate in parallel — backend analyzes endpoints, frontend reviews UI, database checks queries/indexes. Status updates every 15 minutes. No intervention required unless coordination needed.
Plan: Wait for agent completion — auto-delegate.sh monitors progress.
</thought>

<action>
type: invoke_agent
target: [backend-expert, frontend-expert, database-expert]
params:
  execution: parallel
  task: independent_investigation
  status_interval: "15 minutes"
  outputs: [individual_reports]
</action>

<observation>
result: All agents completed investigation, individual reports submitted
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] All agents completed investigation
- [ ] Individual agent reports submitted
- [ ] Status updates received from all sessions

**State Snapshot:**
```yaml
workflow_state:
  current_phase: INVESTIGATION
  completed: [INITIAL_ANALYSIS, TASK_DELEGATION]
  next_action: "COORDINATION or REPORTS"
```

---

### Phase 4: Cross-Agent Coordination (as needed)

<thought>
Observe: Agents may need data from other domains during investigation.
Analyze: Tech Lead shares findings between agents when one agent needs context from another. Example: backend needs frontend timing data, or database findings explain backend latency.
Plan: Invoke techlead-orchestrator to share context.
</thought>

<action>
type: invoke_agent
target: techlead-orchestrator
params:
  task: cross_agent_coordination
  triggers: [request_guidance, findings_sharing]
  outputs: [context_shared, investigation_unblocked]
</action>

<observation>
result: Cross-agent findings correlated, investigation unblocked
gate_status: PASS | FAIL
</observation>

**State Snapshot:**
```yaml
workflow_state:
  current_phase: COORDINATION
  completed: [INITIAL_ANALYSIS, TASK_DELEGATION, INVESTIGATION]
  next_action: "REPORTS"
```

---

### Phase 5: Report Collection

<thought>
Observe: All agents completed investigations.
Analyze: Must collect reports from all agent sessions.
Plan: Run consolidate-reports.sh collect.
</thought>

<action>
type: invoke_skill
target: consolidate-reports
params:
  command: "./scripts/consolidate-reports.sh collect"
  outputs: [collected_reports]
</action>

<observation>
result: All agent reports collected
gate_status: PASS | FAIL
</observation>

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REPORTS
  completed: [INITIAL_ANALYSIS, TASK_DELEGATION, INVESTIGATION, COORDINATION]
  next_action: "CONSOLIDATION"
```

---

### Phase 6: Consolidation

<thought>
Observe: All agent reports collected.
Analyze: Must consolidate into single report with root cause, cross-agent insights, prioritized recommendations, expected outcome.
Plan: Invoke techlead-orchestrator to consolidate.
</thought>

<action>
type: invoke_agent
target: techlead-orchestrator
params:
  task: consolidate_findings
  input: collected_reports
  outputs: [consolidated_report, root_cause, cross_agent_insights, recommendations]
</action>

<observation>
result: Consolidated report generated with root cause, recommendations, expected outcome
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Consolidated report generated
- [ ] Root cause identified
- [ ] Cross-agent dependencies mapped
- [ ] Action items assigned

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONSOLIDATION
  completed: [INITIAL_ANALYSIS, TASK_DELEGATION, INVESTIGATION, COORDINATION, REPORTS]
  next_action: "ACTION"
```

---

### Phase 7: Action & Resolution

<thought>
Observe: Consolidated report with root cause and action items.
Analyze: Must issue action items to agents, agents implement fixes, verify fixes work. Gate requires all fixes implemented and verified.
Plan: Invoke techlead-orchestrator to assign actions, then verify.
</thought>

<action>
type: invoke_agent
target: techlead-orchestrator
params:
  task: action_and_resolution
  outputs: [action_items_assigned, fixes_implemented, fixes_verified]
</action>

<observation>
result: Fixes implemented, verified working, investigation closed
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Action items assigned with deadlines
- [ ] Fixes implemented
- [ ] Fixes verified
- [ ] User informed of findings

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ACTION
  completed: [INITIAL_ANALYSIS, TASK_DELEGATION, INVESTIGATION, COORDINATION, REPORTS, CONSOLIDATION]
  next_action: "DONE"
```

---

## Workflow Commands

```bash
# Start investigation
./scripts/distributed-orchestrator.sh start

# Monitor progress
./scripts/session-manager.sh status

# Collect results
./scripts/consolidate-reports.sh collect
./scripts/consolidate-reports.sh consolidate
```

## Handoff Contracts

### Orchestrator → Domain Agents
```yaml
handoff:
  from: techlead-orchestrator
  to: [backend-expert, frontend-expert, database-expert]
  provides: [investigation_plan, scoped_task, context_files, priority]
  expects: [domain_report, findings, status_updates]
```

### Domain Agents → Consolidation
```yaml
handoff:
  from: [backend-expert, frontend-expert, database-expert]
  to: techlead-orchestrator
  provides: [individual_reports, cross-domain_dependencies]
  expects: [consolidated_report, root_cause, action_items]
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

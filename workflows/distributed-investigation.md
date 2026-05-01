---
name: distributed-investigation
description: Coordinate distributed agents across tmux sessions for multi-domain bug investigation and root cause analysis
version: "2.0.0"
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
  - "systematic-debugging"
  - "performance-optimization"
  - "security-audit"
  - "documentation"
estimated_time: "2-6 hours"
---

# Distributed Investigation Workflow

## Overview

This workflow coordinates distributed agents across separate tmux sessions to investigate bugs or issues that span multiple domains (backend, frontend, database).

## When to Use

```
"Workflow: em-distributed-investigation - Investigate login bug across BE and FE"
"Workflow: em-distributed-investigation - Debug payment failure across multiple services"
"Workflow: em-distributed-investigation - Root cause analysis for performance degradation"
```

**Use Cases:**
- Cross-repo bug investigation
- Multi-domain performance issues
- Production incident response
- Complex bug requiring specialized expertise

## Prerequisites

1. **Distributed orchestration running:**
```bash
./scripts/distributed-orchestrator.sh start
```

2. **Tech Lead Orchestrator active:**
```bash
# In techlead session
"Agent: em-techlead-orchestrator - Coordinate distributed investigation..."
```

## Lifecycle

DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE

### Phase Mapping

| Lifecycle Phase | Workflow Stage |
|-----------------|----------------|
| DEFINE | Initial Analysis (Phase 1) |
| PLAN | Task Delegation (Phase 2) |
| BUILD | Distributed Investigation (Phase 3) |
| VERIFY | Cross-Agent Coordination (Phase 4) + Report Collection (Phase 5) |
| REVIEW | Consolidation (Phase 6) |
| SHIP | Action & Resolution (Phase 7) |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Bug report received and analyzed
- [ ] Scope determined (affected domains)
- [ ] Severity assessed
- [ ] Agent selection completed
- [ ] Investigation plan created
PASS → proceed | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Tasks delegated to agent sessions
- [ ] Execution strategy determined (parallel/sequential/hybrid)
- [ ] Expected outputs defined per agent
- [ ] Agent sessions confirmed active
PASS → proceed | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] All agents completed investigation
- [ ] Individual agent reports submitted
- [ ] Status updates received from all sessions
PASS → proceed | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Cross-agent findings correlated
- [ ] Root cause identified
- [ ] Fix recommendations validated
- [ ] Cross-agent dependencies mapped
PASS → proceed | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Consolidated report generated
- [ ] Action items assigned with owners and deadlines
- [ ] Fix verification confirmed
- [ ] User informed of findings
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Process

### Phase 1: Initial Analysis

**Step 1:** Receive bug report from user

**Step 2:** Tech Lead analyzes bug to determine scope

```yaml
bug_analysis:
  description: "[User's bug report]"
  scope_analysis:
    - affected_domains: [backend, frontend, database, infrastructure]
    - severity: [critical, high, medium, low]
    - user_impact: [all_users, some_users, single_user]
    - reproduction_steps: [clear, unclear, unable]

  agent_selection:
    - if backend_impact: "backend-expert"
    - if frontend_impact: "frontend-expert"
    - if database_impact: "database-expert"
    - if complex: "staff-engineer"
    - if security_related: "security-reviewer"

  coordination_strategy:
    - if independent_domains: "parallel"
    - if dependent_domains: "sequential"
    - if mixed: "hybrid"
```

**Step 3:** Create investigation plan

```yaml
investigation_plan:
  task_id: "TASK-2026-001"
  title: "[Bug Title]"

  agents:
    - name: "backend-expert"
      session: "backend"
      priority: 1
      task: "[What to investigate]"
      dependencies: []

    - name: "frontend-expert"
      session: "frontend"
      priority: 2
      task: "[What to investigate]"
      dependencies: []

    - name: "database-expert"
      session: "database"
      priority: 3
      task: "[What to investigate]"
      dependencies: []

  execution_strategy: "parallel"  # or sequential/hybrid

  expected_outputs:
    - from: "backend-expert"
      format: "report"
      location: "/tmp/claude-work-reports/backend/bug-investigation-20260419.md"

    - from: "frontend-expert"
      format: "report"
      location: "/tmp/claude-work-reports/frontend/bug-investigation-20260419.md"

    - from: "database-expert"
      format: "report"
      location: "/tmp/claude-work-reports/database/bug-investigation-20260419.md"
```

---

### Phase 2: Task Delegation (AUTOMATED)

**Step 4:** Tech Lead calls auto-delegation script

**CRITICAL:** Instead of manually creating YAML files or notifying sessions, use the automated delegation script:

```bash
bash scripts/auto-delegate.sh \
  "[task description]" \
  "[comma-separated agents]" \
  [priority]
```

**Example:**
```bash
# Tech Lead delegates investigation to all three domains
bash scripts/auto-delegate.sh \
  "Investigate login API latency issue. Users reporting slow login times (>2s)." \
  "backend,frontend,database" \
  "critical"
```

**What happens automatically:**
1. Script generates unique task ID (e.g., `TASK-20260419-143022`)
2. Script creates task assignment YAMLs for each agent
3. Script writes tasks to `/tmp/claude-work-queue/to-{agent}/`
4. Script notifies agent sessions via tmux
5. Agent sessions' queue monitors detect tasks
6. Queue monitors auto-trigger appropriate agents
7. Script monitors progress for completion

**Example Output:**
```
[INFO] Auto-Delegation for EM-Team Distributed Orchestration
[INFO] ════════════════════════════════════════════════════════════════

[INFO] Validating prerequisites...
[SUCCESS] Prerequisites validated
[SUCCESS] Task ID: TASK-20260419-143022

[INFO] Creating task assignments...
[INFO] Creating assignment for backend...
[SUCCESS] Task assignment created: /tmp/claude-work-queue/to-backend/TASK-20260419-143022.yaml
[INFO] Creating assignment for frontend...
[SUCCESS] Task assignment created: /tmp/claude-work-queue/to-frontend/TASK-20260419-143022.yaml
[INFO] Creating assignment for database...
[SUCCESS] Task assignment created: /tmp/claude-work-queue/to-database/TASK-20260419-143022.yaml

[INFO] Notifying agent sessions...
[SUCCESS] Notified backend session
[SUCCESS] Notified frontend session
[SUCCESS] Notified database session

[SUCCESS] Task delegation complete!
[INFO] Task ID: TASK-20260419-143022
[INFO] Agents: backend frontend database
[INFO] Description: Investigate login API latency issue...

[INFO] Monitoring progress for TASK-20260419-143022...
[INFO] Tracking 3 agents: backend frontend database
[INFO] Progress: 0/3 agents complete (0m elapsed)
[INFO] Progress: 1/3 agents complete (15m elapsed)
[INFO] Progress: 2/3 agents complete (28m elapsed)
[SUCCESS] All 3 agents completed!
[INFO] Triggering consolidation...
[SUCCESS] Consolidation complete!
[SUCCESS] 📊 Consolidated Report: /tmp/claude-work-reports/techlead/TASK-20260419-143022-consolidated.md
```

**Step 5:** Tech Lead waits for completion

The auto-delegate.sh script handles everything automatically:
- Monitors `/tmp/claude-work-queue/to-techlead/` for status updates
- Tracks completion state (in_progress/completed/failed)
- Detects when all agents finish
- Triggers consolidation phase
- Notifies Tech Lead when complete

**No manual intervention required during investigation!**

**Optional: Check queue monitor status**
```bash
# Verify queue monitors are running
./distributed/session-queue-monitor.sh status

# Output should show:
# Queue Monitor Status:
#   ✅ backend: Running (PID: 12345)
#   ✅ frontend: Running (PID: 12346)
#   ✅ database: Running (PID: 12347)
```

---

### Phase 3: Distributed Investigation

**Step 6:** Agents work independently in their sessions

**Backend Session:**
```bash
# Backend agent receives task
# Reads from: /tmp/claude-work-queue/to-backend/TASK-001-BE.yaml

# Performs investigation
- Analyzes login endpoint code
- Reviews database queries
- Checks external service calls
- Profiles performance

# Sends status update every 15 minutes
cat > /tmp/claude-work-queue/to-techlead/STATUS-backend-TASK-001.yaml << 'EOF'
message_type: status_update
from: backend
task_id: "TASK-001-BE"
status:
  state: in_progress
  progress_percent: 40
  current_step: "Analyzing database queries"
EOF
```

**Frontend Session:**
```bash
# Frontend agent receives task
# Performs investigation
- Reviews login form
- Checks API call timing
- Analyzes loading states
- Reviews error handling

# Sends status update
cat > /tmp/claude-work-queue/to-techlead/STATUS-frontend-TASK-001.yaml << 'EOF'
message_type: status_update
from: frontend
task_id: "TASK-001-FE"
status:
  state: in_progress
  progress_percent: 60
  current_step: "Measuring API response times"
EOF
```

**Database Session:**
```bash
# Database agent receives task
# Performs investigation
- Reviews login-related queries
- Checks indexes
- Analyzes query performance
- Checks for locks

# Sends status update
cat > /tmp/claude-work-queue/to-techlead/STATUS-database-TASK-001.yaml << 'EOF'
message_type: status_update
from: database
task_id: "TASK-001-DB"
status:
  state: in_progress
  progress_percent: 80
  current_step: "Analyzing slow queries"
EOF
```

---

### Phase 4: Cross-Agent Coordination

**Step 7:** Tech Lead monitors progress and coordinates

**Scenario:** Backend Agent needs frontend context

```yaml
# Backend requests guidance
message_type: request_guidance
from: backend
request:
  type: coordination
  subject: "Need frontend API timing data"
  context: "Backend login endpoint takes 2.3s. Need to know if frontend measures this."
  urgency: medium

# Tech Lead shares frontend findings
message_type: context_share
from: techlead
to: backend
context:
  type: findings_from
  source_agent: frontend
  content: "Frontend measures login API at 2.3s average. Loading states show at 0.5s."

action_required: "Use this timing data for backend optimization target."
```

**Scenario:** Database Agent finds indexing issue

```yaml
# Database reports findings
message_type: findings_report
from: database
findings:
  critical:
    - issue: "Missing index on users.email"
      impact: "Full table scan on every login"
      fix: "CREATE INDEX idx_users_email ON users(email);"

# Tech Lead shares with Backend
message_type: context_share
from: techlead
to: backend
context:
  type: findings_from
  source_agent: database
  content: "Database found missing index on users.email causing full table scan."

action_required: "Factor this into backend latency investigation. This is likely the root cause."
```

---

### Phase 5: Report Collection

**Step 8:** Agents complete investigations and submit reports

**Backend Report:**
```markdown
# Backend Expert Report: Login API Latency Investigation

**Report ID:** RPT-2026-001
**Agent:** backend-expert
**Task ID:** TASK-2026-001-BE

## Executive Summary

Login API latency of 2.3s caused by missing database index and N+1 query problem.

## Findings

### Critical Issues
| Issue | Impact | Fix |
|-------|--------|-----|
| Missing index on users.email | Full table scan (500ms) | Add index |
| N+1 query loading permissions | 10+ queries (1.5s) | Use data loader |
| No response caching | Repeated queries | Add 5-min cache |

### Recommendations
1. Add database index on users.email (30 min)
2. Implement data loader for permissions (2 hours)
3. Add response caching (4 hours)
```

**File:** `/tmp/claude-work-reports/backend/login-latency-20260419.md`

**Frontend Report:**
```markdown
# Frontend Expert Report: Login UX Analysis

**Report ID:** RPT-2026-002
**Agent:** frontend-expert
**Task ID:** TASK-2026-001-FE

## Executive Summary

Login form has adequate loading states, but 2.3s API latency is too slow for good UX.

## Findings

### Medium Issues
| Issue | Impact | Fix |
|-------|--------|-----|
| Loading spinner shows late | Confusing UX | Show spinner immediately |
| No retry mechanism | Users give up | Add retry button |

### Recommendations
1. Show loading spinner immediately (15 min)
2. Add retry mechanism for failed logins (30 min)
```

**File:** `/tmp/claude-work-reports/frontend/login-ux-20260419.md`

**Database Report:**
```markdown
# Database Expert Report: Query Performance Analysis

**Report ID:** RPT-2026-003
**Agent:** database-expert
**Task ID:** TASK-2026-001-DB

## Executive Summary

Login queries slow due to missing index and N+1 query pattern.

## Findings

### Critical Issues
| Issue | Impact | Fix |
|-------|--------|-----|
| Missing index on users.email | Full table scan (500ms) | CREATE INDEX CONCURRENTLY |

### Recommendations
1. Add index on users.email (30 min)
2. Review user permissions query pattern (1 hour)
```

**File:** `/tmp/claude-work-reports/database/query-analysis-20260419.md`

---

### Phase 6: Consolidation

**Step 9:** Tech Lead collects all reports

```bash
# Collect reports
./scripts/consolidate-reports.sh collect

# Consolidate into single report
./scripts/consolidate-reports.sh consolidate
```

**Step 10:** Create consolidated investigation report

```markdown
# Consolidated Bug Investigation Report: Login Latency

**Report ID:** TEAM-RPT-2026-001
**Agents:** Backend, Frontend, Database

## Executive Summary

**Overall Status:** ⚠️ CRITICAL
**Root Cause:** Missing database index + N+1 queries
**User Impact:** High (47 complaints in 24h)

## Root Cause Analysis

Login latency of 2.3s caused by:
1. **Primary:** Missing index on users.email (500ms overhead)
2. **Secondary:** N+1 query loading permissions (1.5s overhead)

## Consolidated Findings

### Critical Issues (Must Fix)
| Issue | Agent | Impact | Fix | Effort |
|-------|-------|--------|-----|--------|
| Missing index on users.email | Database | Full table scan | Add index | 30 min |
| N+1 query for permissions | Backend | 10+ queries | Data loader | 2 hours |
| Late loading spinner | Frontend | Poor UX | Show immediately | 15 min |

## Cross-Agent Insights

**Backend-Database coupling:**
- Backend API slowness directly caused by missing database index
- Fix database → Backend improves automatically

**Backend-Frontend dependency:**
- Frontend UX depends on Backend API performance
- Fix backend → Frontend UX improves automatically

## Recommendations

### Immediate (Today)
1. Add database index on users.email (Database) - 30 min
2. Implement data loader for permissions (Backend) - 2 hours
3. Show loading spinner immediately (Frontend) - 15 min

### Short Term (This Week)
1. Add response caching (Backend) - 4 hours
2. Add retry mechanism (Frontend) - 30 min

### Expected Outcome
- **Current:** 2.3s login time
- **After fixes:** <500ms login time
- **Improvement:** 4.6x faster

## Next Steps

1. Database Expert: Create index migration
2. Backend Expert: Implement data loader
3. Frontend Expert: Fix loading spinner
4. Staff Engineer: Verify fixes in staging
```

---

### Phase 7: Action & Resolution

**Step 11:** Tech Lead issues action items

```yaml
# Tech Lead assigns action items
message_type: action_item
to: database
action:
  priority: critical
  task: "Create database index migration"
  deadline: "2026-04-19T14:00:00Z"
  instructions: |
    Use CREATE INDEX CONCURRENTLY for zero downtime.
    Test in staging first.

message_type: action_item
to: backend
action:
  priority: critical
  task: "Implement data loader for permissions"
  deadline: "2026-04-19T16:00:00Z"
  instructions: |
    Use dataloader library.
    Ensure batch size is appropriate.

message_type: action_item
to: frontend
action:
  priority: high
  task: "Fix loading spinner timing"
  deadline: "2026-04-19T13:00:00Z"
  instructions: |
    Show spinner immediately on form submit.
```

**Step 12:** Agents implement fixes

**Step 13:** Verification

```yaml
verification:
  - database_index_created: true
  - data_loader_implemented: true
  - loading_spinner_fixed: true
  - login_time_under_500ms: true
```

**Step 14:** Close investigation

```markdown
# Investigation Closed: Login Latency Bug

**Status:** ✅ RESOLVED
**Resolution Time:** 6 hours
**Final Outcome:** Login time reduced from 2.3s to 450ms

**Lessons Learned:**
1. Always review database indexes for authentication queries
2. Watch for N+1 query patterns in permission checks
3. Frontend UX depends heavily on backend performance
```

---

## Workflow Commands

### Start Investigation

```bash
# 1. Start distributed orchestration
./scripts/distributed-orchestrator.sh start

# 2. Trigger Tech Lead
# In techlead session:
"Agent: em-techlead-orchestrator - Coordinate distributed investigation for login bug: Users cannot login after password reset"

# 3. Tech Lead will:
# - Analyze bug
# - Select appropriate agents
# - Delegate tasks
# - Monitor progress
# - Consolidate findings
```

### Monitor Progress

```bash
# Check session status
./scripts/session-manager.sh status

# List available reports
./scripts/consolidate-reports.sh list

# Watch specific agent
./scripts/session-manager.sh watch backend
```

### Collect Results

```bash
# Collect reports from all agents
./scripts/consolidate-reports.sh collect

# Consolidate into single report
./scripts/consolidate-reports.sh consolidate

# View consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report-*.md
```

---

## Success Criteria

- [ ] Bug thoroughly investigated across all affected domains
- [ ] Root cause identified
- [ ] Fix recommendations provided
- [ ] Cross-agent dependencies mapped
- [ ] Action items assigned
- [ ] Consolidated report generated
- [ ] User informed of findings

---

## Estimated Timeline

| Phase | Duration |
|-------|----------|
| Initial Analysis | 15-30 min |
| Task Delegation | 15 min |
| Distributed Investigation | 1-4 hours |
| Cross-Agent Coordination | Ongoing |
| Report Collection | 15 min |
| Consolidation | 30 min |
| **Total** | **2-6 hours** |

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Compatible with:** EM-Team Distributed Orchestration

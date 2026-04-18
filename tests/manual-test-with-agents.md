# Manual Test Guide for Distributed Agent Orchestration System

## Overview

This guide provides step-by-step instructions for manually testing the distributed agent orchestration system with real Claude Code agents.

---

## Prerequisites

- ✅ tmux installed (`tmux -V`)
- ✅ Bash shell
- ✅ Claude Code CLI available
- ✅ EM-Skill repository checked out

---

## Test 1: Start Distributed Orchestration

### Steps

1. **Navigate to the project root:**
   ```bash
   cd /path/to/em-skill
   ```

2. **Start the distributed orchestration:**
   ```bash
   ./scripts/distributed-orchestrator.sh start
   ```

3. **Verify session creation:**
   ```bash
   tmux list-sessions
   ```

4. **Expected Result:**
   - Session named `claude-work` is created
   - Multiple windows exist: `orchestrator`, `backend`, `frontend`, `database`
   - Directories created:
     - `/tmp/claude-work-reports/`
     - `/tmp/claude-work-queue/`
     - `/tmp/claude-work-logs/`

---

## Test 2: Trigger Tech Lead Orchestrator

### Steps

1. **Attach to the orchestrator window:**
   ```bash
   tmux attach -t claude-work:orchestrator
   ```

2. **In the tmux session, trigger the Tech Lead Orchestrator agent:**
   ```
   Agent: em-techlead-orchestrator - Investigate authentication bug in login flow
   ```

3. **Observe the agent behavior:**
   - Agent should analyze the task
   - Agent should delegate subtasks to specialist agents
   - Agent should create task assignments in the queue

4. **Detach from session:** `Ctrl+B, D`

### Verification

```bash
# Check queue for task assignments
ls -la /tmp/claude-work-queue/pending/

# Check for status updates
ls -la /tmp/claude-work-queue/processing/

# View a task assignment
cat /tmp/claude-work-queue/pending/task-*.yaml
```

---

## Test 3: Verify Task Delegation

### Steps

1. **Check the backend window:**
   ```bash
   tmux attach -t claude-work:backend
   ```

2. **Look for delegated tasks:**
   - Backend agent should have received task assignment
   - Backend agent should be working on authentication investigation

3. **Check the frontend window:**
   ```bash
   tmux attach -t claude-work:frontend
   ```

4. **Look for delegated tasks:**
   - Frontend agent may have received UI-related tasks

### Verification

```bash
# Check which agents have active work
./scripts/session-manager.sh status

# Check queue status
./scripts/session-manager.sh list
```

---

## Test 4: Create Mock Reports

### Purpose

Simulate agent reports without waiting for full agent execution.

### Steps

1. **Create a mock backend report:**
   ```bash
   cat > /tmp/claude-work-reports/backend/investigation-report.md << 'EOF'
   ---
   report_id: report-backend-001
   generated: 2026-04-19T14:00:00Z
   agent: backend-expert
   task_id: task-auth-001
   status: completed
   overall: pass
   findings:
     - category: Root Cause
       severity: critical
       summary: "JWT token validation missing in login endpoint"
       details: |
         The /api/auth/login endpoint does not validate JWT tokens properly,
         allowing expired tokens to be accepted.
       evidence:
         - "backend/src/routes/auth.ts:45-52"
     - category: Security
       severity: high
       summary: "No rate limiting on authentication attempts"
       details: |
         Brute force attacks are possible due to missing rate limiting.
       evidence:
         - "backend/src/middleware/rate-limit.ts"
   recommendations:
     - priority: critical
       action: "Add JWT validation middleware"
       effort: 2h
     - priority: high
       action: "Implement rate limiting on auth endpoints"
       effort: 4h
   next_steps:
     - "Implement JWT validation"
     - "Add rate limiting"
     - "Write security tests"
   EOF
   ```

2. **Create a mock frontend report:**
   ```bash
   cat > /tmp/claude-work-reports/frontend/ui-report.md << 'EOF'
   ---
   report_id: report-frontend-001
   generated: 2026-04-19T14:15:00Z
   agent: frontend-expert
   task_id: task-auth-001
   status: completed
   overall: pass
   findings:
     - category: User Experience
       severity: medium
       summary: "No error feedback on authentication failure"
       details: |
         Users receive no clear feedback when authentication fails.
       evidence:
         - "frontend/src/components/LoginForm.tsx:78-85"
     - category: Accessibility
       severity: low
       summary: "Missing ARIA labels on login form"
       details: |
         Screen readers cannot properly announce the login form fields.
       evidence:
         - "frontend/src/components/LoginForm.tsx:23-45"
   recommendations:
     - priority: medium
       action: "Add user-friendly error messages"
       effort: 2h
     - priority: low
       action: "Add ARIA labels to form fields"
       effort: 1h
   next_steps:
     - "Implement error state UI"
     - "Add accessibility labels"
     - "Test with screen reader"
   EOF
   ```

3. **Create a mock database report:**
   ```bash
   cat > /tmp/claude-work-reports/database/schema-report.md << 'EOF'
   ---
   report_id: report-database-001
   generated: 2026-04-19T14:30:00Z
   agent: database-expert
   task_id: task-auth-001
   status: completed
   overall: pass
   findings:
     - category: Schema
       severity: info
       summary: "Sessions table uses appropriate indexes"
       details: |
         The sessions table has proper indexes on user_id and expires_at.
       evidence:
         - "database/migrations/001_create_sessions.sql:15-18"
     - category: Performance
       severity: low
       summary: "Consider adding composite index"
       details: |
         A composite index on (user_id, expires_at) could improve query performance.
       evidence:
         - "database/migrations/001_create_sessions.sql"
   recommendations:
     - priority: low
       action: "Add composite index for query optimization"
       effort: 1h
   next_steps:
     - "Create migration for composite index"
     - "Benchmark query performance"
   EOF
   ```

---

## Test 5: Consolidate Reports

### Steps

1. **List available reports:**
   ```bash
   ./scripts/consolidate-reports.sh list
   ```

2. **Consolidate all reports:**
   ```bash
   ./scripts/consolidate-reports.sh consolidate
   ```

3. **View the consolidated report:**
   ```bash
   cat /tmp/claude-work-reports/techlead/consolidated-report.md
   ```

### Expected Result

The consolidated report should include:
- Executive summary
- All agent reports (backend, frontend, database)
- Cross-agent findings and patterns
- Consolidated recommendations
- Next steps prioritized by effort and impact

---

## Test 6: Verify Session Coordination

### Steps

1. **Check session topology:**
   ```bash
   ./distributed/session-coordinator.sh topology
   ```

2. **Check agent status:**
   ```bash
   ./distributed/session-coordinator.sh agent-status
   ```

3. **Check queue status:**
   ```bash
   ./distributed/session-coordinator.sh queue-status
   ```

4. **Test broadcasting a message:**
   ```bash
   ./scripts/session-manager.sh broadcast "echo 'Hello from broadcast'"
   ```

### Expected Result

- Topology shows all agent windows
- Agent status shows active/completed tasks
- Queue status shows pending/processing/completed tasks
- Broadcast message executes in all windows

---

## Test 7: Context Sync

### Steps

1. **Test context synchronization:**
   ```bash
   ./distributed/session-sync.sh sync-all
   ```

2. **Verify sync files created:**
   ```bash
   ls -la /tmp/claude-work-sync/
   ```

3. **View sync state:**
   ```bash
   ./distributed/session-sync.sh status
   ```

---

## Test 8: Cleanup

### Steps

1. **Kill the distributed session:**
   ```bash
   ./scripts/distributed-orchestrator.sh stop
   ```

2. **Verify session is gone:**
   ```bash
   tmux list-sessions
   ```

3. **Optional: Preserve reports for review:**
   ```bash
   cp -r /tmp/claude-work-reports ~/em-skill-test-reports
   ```

4. **Optional: Clean up all artifacts:**
   ```bash
   rm -rf /tmp/claude-work-*
   ```

---

## Test Checklist

Use this checklist to verify all components work:

- [ ] Distributed orchestration starts successfully
- [ ] Tmux session and windows are created
- [ ] Directories are initialized correctly
- [ ] Tech Lead Orchestrator agent can be triggered
- [ ] Task delegation occurs to specialist agents
- [ ] Task assignments appear in queue
- [ ] Status updates are generated
- [ ] Agent reports are created
- [ ] Reports can be listed
- [ ] Reports can be consolidated
- [ ] Consolidated report includes all agent findings
- [ ] Session coordination works
- [ ] Context synchronization works
- [ ] Broadcast messaging works
- [ ] Session cleanup works

---

## Troubleshooting

### Issue: tmux session not created

**Solution:**
```bash
# Check if tmux is installed
tmux -V

# Kill any existing sessions
tmux kill-server

# Try starting again
./scripts/distributed-orchestrator.sh start
```

### Issue: Agents not responding

**Solution:**
```bash
# Check agent window activity
tmux list-windows -t claude-work

# Attach to specific window
tmux attach -t claude-work:backend

# Check for errors in logs
ls -la /tmp/claude-work-logs/
```

### Issue: Reports not consolidating

**Solution:**
```bash
# Verify reports exist
ls -la /tmp/claude-work-reports/*/

# Check report format
cat /tmp/claude-work-reports/backend/report.md

# Manually run consolidation
./scripts/consolidate-reports.sh consolidate
```

### Issue: Queue not processing

**Solution:**
```bash
# Check queue directories
ls -la /tmp/claude-work-queue/{pending,processing,completed}/

# Move stuck tasks
mv /tmp/claude-work-queue/processing/* /tmp/claude-work-queue/pending/

# Restart orchestration
./scripts/distributed-orchestrator.sh stop
./scripts/distributed-orchestrator.sh start
```

---

## Success Criteria

The distributed orchestration system is working correctly if:

1. ✅ All agents can be triggered and respond
2. ✅ Task delegation happens automatically
3. ✅ Message queue processes tasks correctly
4. ✅ Agent reports are generated in proper format
5. ✅ Report consolidation produces comprehensive output
6. ✅ Session coordination manages all windows
7. ✅ Context sync keeps sessions synchronized
8. ✅ Cleanup removes all artifacts

---

## Next Steps

After manual testing:

1. Run automated test suite:
   ```bash
   cd tests
   ./test-distributed-orchestrator.sh
   ./test-session-manager.sh
   ./test-consolidate-reports.sh
   ./test-session-coordinator.sh
   ./test-messaging-protocol.sh
   ./test-report-consolidation.sh
   ./run-e2e-tests.sh
   ```

2. Review test results and fix any failures

3. Document any issues found during testing

4. Update documentation based on findings

---

**Happy Testing! 🎯**

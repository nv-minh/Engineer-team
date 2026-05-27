# Distributed System Architecture

Complete architecture documentation for the EM-Team Distributed Agent Orchestration System.

---

## Overview

The Distributed Agent Orchestration System solves token context overflow by running agents in separate tmux sessions with isolated contexts.

---

## Problem Statement

When working with complex tasks requiring multiple specialist agents:

❌ **Traditional Issues:**
- Sequential agent execution (slow)
- Context truncation (lose information)
- Expensive token limit increases

✅ **Our Solution:**
- Parallel agent execution
- Isolated contexts (no token sharing)
- Each agent gets full 200K token budget

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code Session                      │
│                  (Token Budget: 200K)                      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Tech Lead Orchestrator Agent                 │  │
│  │         (Token Budget: 200K)                        │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                  │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Message Queue                           │  │
│  │         pending/processing/completed                 │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                  │
│          ┌───────────────┼───────────────┐                  │
│          ▼               ▼               ▼                  │
│  ┌───────────┐   ┌───────────┐   ┌───────────┐              │
│  │  Backend  │   │ Frontend  │   │ Database  │              │
│  │  200K tok  │   │  200K tok  │   │  200K tok  │              │
│  └───────────┘   └───────────┘   └───────────┘              │
│                          │                                  │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Shared Reports Directory                    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Components

### 1. Orchestration Layer

**Scripts:**
- `distributed-orchestrator.sh` - Creates/manages tmux sessions
- `session-coordinator.sh` - High-level coordination
- `session-sync.sh` - Context synchronization

**Responsibilities:**
- Session lifecycle management
- Agent coordination
- Message routing

### 2. Session Management

**Script:** `session-manager.sh`

**Features:**
- List active sessions
- Kill sessions
- Broadcast messages
- Status monitoring

**Directory Structure:**
```
/tmp/claude-work-reports/
├── backend/
├── frontend/
├── database/
└── techlead/
```

### 3. Message Protocol

**File:** `protocols/distributed-messaging.md`

**Message Types:**
- `task_assignment` - Delegate work to agents
- `status_update` - Report progress
- `findings_report` - Submit findings

**Queue Flow:**
```
pending → processing → completed
```

### 4. Report System

**File:** `protocols/report-format.md`

**Report Structure:**
```yaml
---
report_id: unique-id
generated: timestamp
agent: agent-name
task_id: task-id
status: completed|partial|failed
overall: pass|fail|partial
findings:
  - category: ...
    severity: ...
    summary: ...
recommendations: ...
next_steps: ...
```

---

## Communication Flow

```
1. Orchestrator receives task
   ↓
2. Creates task assignments
   ↓
3. Places in queue/pending/
   ↓
4. Specialist agents pick up
   ↓
5. Move to queue/processing/
   ↓
6. Agents generate reports
   ↓
7. Move to queue/completed/
   ↓
8. Reports consolidated
   ↓
9. Return to user
```

---

## Data Flow

### Input Flow
```
User → Orchestrator → Task Assignment → Queue
```

### Processing Flow
```
Queue → Agent Window → Processing → Status Update
```

### Output Flow
```
Agent Report → Shared Directory → Consolidation → User
```

---

## Directory Structure

```
/tmp/
├── claude-work-reports/     # Agent reports
│   ├── backend/             # Backend expert reports
│   ├── frontend/            # Frontend expert reports
│   ├── database/            # Database expert reports
│   └── techlead/            # Consolidated reports
├── claude-work-queue/       # Message queue
│   ├── pending/             # New tasks
│   ├── processing/          # In progress
│   └── completed/           # Finished tasks
├── claude-work-logs/        # Execution logs
└── claude-work-sync/        # Context sync files
```

---

## Isolation Strategy

### Session Isolation
- Each agent in separate tmux window
- No shared memory between agents
- Independent token budgets

### File System Isolation
- Separate report directories
- Queue-based communication
- No direct file access

### Communication
- YAML-based messages
- Queue-mediated
- No direct agent-to-agent calls

---

## Scalability

### Adding New Agents

1. Create agent file: `agents/new-specialist.md`
2. Add window in `distributed-orchestrator.sh`
3. Add directory creation
4. Update protocols if needed

### Horizontal Scaling
- Add more agent windows
- Each gets full 200K token budget
- No degradation in performance

### Vertical Scaling
- Increase individual agent capacity
- No architectural changes needed

---

## Security Considerations

### Isolation
- Agents cannot access each other's contexts
- File system permissions restrict access
- No shared state

### Validation
- All messages validated against protocol
- Report format enforced
- Queue state machine prevents invalid states

### Audit Trail
- All messages logged
- All reports timestamped
- Complete execution history

---

## Performance

### Benchmarks
- Session creation: <1 second
- Message processing: <100ms
- Report consolidation: <500ms
- End-to-end workflow: <5 minutes

### Optimization
- Parallel agent execution
- Asynchronous message processing
- Efficient report consolidation

---

## Monitoring

### Health Checks
```bash
# Check sessions
./scripts/session-manager.sh list

# Check queue
./distributed/session-coordinator.sh queue-status

# Check agents
./distributed/session-coordinator.sh agent-status
```

### Logging
- All actions logged to `/tmp/claude-work-logs/`
- Error tracking enabled
- Performance metrics collected

---

## Failure Handling

### Session Failure
- Automatic session cleanup
- State preservation in queue
- Recovery on restart

### Agent Failure
- Error captured in report
- Task marked as failed
- Orchestrator notified

### Queue Failure
- Messages preserved on disk
- Automatic recovery
- No message loss

---

## Future Enhancements

### Planned Features
- [ ] Remote agent execution (SSH)
- [ ] Container-based isolation
- [ ] Persistent message queue
- [ ] Web-based monitoring dashboard

### Research Areas
- [ ] Distributed execution across machines
- [ ] Load balancing for agents
- [ ] Priority-based scheduling
- [ ] Agent specialization optimization

---

## References

- [Messaging Protocol](../protocols/messaging.md)
- [Report Format](../protocols/report-format.md)
- [Usage Guide](../guides/usage-guide.md)
- [Test Suite](../tests/README.md)

---

**Last Updated:** 2026-05-25
**Version:** 5.0.0

# Distributed Messaging Protocol

## Overview

This document defines the messaging protocol for distributed agent orchestration in EM-Skill. It enables communication between agents running in separate tmux sessions.

## Message Types

### 1. Task Assignment

**From:** Tech Lead → Agent

**Purpose:** Assign a task to an agent

**Format:**
```yaml
message_type: task_assignment
timestamp: "2026-04-19T10:00:00Z"
from: techlead
to: [agent_name]
task_id: [unique_id]

task:
  title: "[Task Title]"
  description: "[Detailed description]"
  priority: [critical|high|medium|low]
  context:
    - "[File paths]"
    - "[Documentation links]"
  dependencies:
    - agent: "[Agent name]"
      task_id: "[Task ID]"
  expected_output:
    format: "[report|code|analysis]"
    location: "[Path for output]"
```

**Example:**
```yaml
message_type: task_assignment
timestamp: "2026-04-19T10:00:00Z"
from: techlead
to: backend
task_id: TASK-2026-001

task:
  title: "Investigate login API latency"
  description: "Login endpoint is taking >2s. Investigate and identify root cause."
  priority: critical
  context:
    - "backend/api/auth/login.js"
    - "logs/production.log"
  dependencies: []
  expected_output:
    format: report
    location: "/tmp/claude-work-reports/backend/login-latency-report.md"
```

---

### 2. Status Update

**From:** Agent → Tech Lead

**Purpose:** Provide progress update on a task

**Format:**
```yaml
message_type: status_update
timestamp: "2026-04-19T10:15:00Z"
from: [agent_name]
to: techlead
task_id: [unique_id]

status:
  state: [in_progress|blocked|waiting|completed]
  progress_percent: [0-100]
  current_step: "[What agent is doing now]"

findings:
  - "[Initial finding 1]"
  - "[Initial finding 2]"

blocks:
  - dependency: "[Agent or resource]"
    reason: "[Why blocked]"

estimated_completion: "[ISO timestamp or null]"
```

**Example:**
```yaml
message_type: status_update
timestamp: "2026-04-19T10:15:00Z"
from: backend
to: techlead
task_id: TASK-2026-001

status:
  state: in_progress
  progress_percent: 40
  current_step: "Analyzing database query performance"

findings:
  - "Login endpoint makes 3 sequential database queries"
  - "No indexing on users.email column"

blocks: []

estimated_completion: "2026-04-19T10:30:00Z"
```

---

### 3. Findings Report

**From:** Agent → Tech Lead

**Purpose:** Submit completed findings and analysis

**Format:**
```yaml
message_type: findings_report
timestamp: "2026-04-19T10:30:00Z"
from: [agent_name]
to: techlead
task_id: [unique_id]

report:
  title: "[Report Title]"
  summary: "[One-line summary]"
  status: [completed|partial|failed]

findings:
  critical:
    - issue: "[Issue description]"
      impact: "[What it affects]"
      fix: "[How to fix]"
  high:
    - issue: "[Issue description]"
      impact: "[What it affects]"
      fix: "[How to fix]"
  medium:
    - issue: "[Issue description]"
      fix: "[How to fix]"
  low:
    - issue: "[Issue description]"
      fix: "[How to fix]"

recommendations:
  immediate:
    - "[Action 1]"
    - "[Action 2]"
  short_term:
    - "[Action 1]"
  long_term:
    - "[Action 1]"

artifacts:
  - path: "[Path to generated file]"
    description: "[What the file contains]"

completion_time: "2026-04-19T10:30:00Z"
```

**Example:**
```yaml
message_type: findings_report
timestamp: "2026-04-19T10:30:00Z"
from: backend
to: techlead
task_id: TASK-2026-001

report:
  title: "Login API Latency Investigation"
  summary: "Identified 3 critical performance bottlenecks in login endpoint"
  status: completed

findings:
  critical:
    - issue: "Missing index on users.email"
      impact: "Full table scan on every login"
      fix: "CREATE INDEX idx_users_email ON users(email);"
    - issue: "N+1 query problem loading user permissions"
      impact: "Database makes 10+ queries per login"
      fix: "Use JOIN or data loader pattern"
    - issue: "Password hashing uses 10 iterations"
      impact: "Slow bcrypt (can be optimized)"
      fix: "Increase to 12 iterations (balance security vs speed)"

  high:
    - issue: "No response caching"
      impact: "Repeated logins hit database every time"
      fix: "Cache authenticated user session for 5 minutes"

recommendations:
  immediate:
    - "Add index on users.email"
    - "Fix N+1 query with data loader"
  short_term:
    - "Implement response caching"
    - "Profile bcrypt and adjust iterations"
  long_term:
    - "Consider external auth provider (Auth0, etc.)"

artifacts:
  - path: "/tmp/claude-work-reports/backend/login-latency-report.md"
    description: "Full investigation report with query analysis"

completion_time: "2026-04-19T10:30:00Z"
```

---

### 4. Request for Guidance

**From:** Agent → Tech Lead

**Purpose:** Agent needs clarification or guidance

**Format:**
```yaml
message_type: request_guidance
timestamp: "2026-04-19T10:20:00Z"
from: [agent_name]
to: techlead
task_id: [unique_id]

request:
  type: [clarification|approval|escalation|coordination]
  subject: "[What needs guidance]"
  context: "[Relevant context]"

options:
  - "[Option 1]"
  - "[Option 2]"

agent_recommendation: "[What agent recommends, if any]"

urgency: [low|medium|high|critical]
```

**Example:**
```yaml
message_type: request_guidance
timestamp: "2026-04-19T10:20:00Z"
from: backend
to: techlead
task_id: TASK-2026-001

request:
  type: approval
  subject: "Propose adding database index on users.email"
  context: "Login endpoint slow due to missing index. Adding index will improve performance."

options:
  - "Add index immediately (requires brief write lock on users table)"
  - "Add index concurrently (no lock, but slower)"
  - "Schedule maintenance window for index creation"

agent_recommendation: "Option 2: Add index concurrently"

urgency: high
```

---

### 5. Completion Notification

**From:** Agent → Tech Lead

**Purpose:** Notify that task is complete

**Format:**
```yaml
message_type: completion_notification
timestamp: "2026-04-19T10:35:00Z"
from: [agent_name]
to: techlead
task_id: [unique_id]

completion:
  status: [success|partial|failed]
  summary: "[One-line summary]"
  output_location: "[Path to output]"

next_actions:
  - "[Action for another agent]"
  - "[Action for techlead]"

requires_followup: [true|false]
```

**Example:**
```yaml
message_type: completion_notification
timestamp: "2026-04-19T10:35:00Z"
from: backend
to: techlead
task_id: TASK-2026-001

completion:
  status: success
  summary: "Login latency investigation complete. 3 critical issues identified."
  output_location: "/tmp/claude-work-reports/backend/login-latency-report.md"

next_actions:
  - "Frontend agent: Review if API response time acceptable for UX"
  - "Database agent: Review migration plan for indexes"

requires_followup: true
```

---

### 6. Context Sharing

**From:** Tech Lead → Agent

**Purpose:** Share context between agents

**Format:**
```yaml
message_type: context_share
timestamp: "2026-04-19T10:10:00Z"
from: techlead
to: [agent_name]
task_id: [unique_id]

context:
  type: [findings_from|documentation|analysis|code]
  source_agent: "[Agent name who generated this]"
  content: "[Context content or path]"

action_required: "[What to do with this context]"
```

**Example:**
```yaml
message_type: context_share
timestamp: "2026-04-19T10:10:00Z"
from: techlead
to: frontend
task_id: TASK-2026-001

context:
  type: findings_from
  source_agent: backend
  content: "Backend identified login API latency. Average response time: 2.3s. Will be optimized to <500ms."

action_required: "Review frontend UX for current 2.3s response time. Assess if loading states are adequate."
```

---

## Message Flow

### Typical Investigation Flow

```
┌─────────────┐                    ┌─────────────┐
│  Tech Lead  │                    │    Agent    │
└──────┬──────┘                    └──────┬──────┘
       │                                  │
       │  1. Task Assignment              │
       │--------------------------------->│
       │                                  │
       │                              2. Status Update (in progress)
       │<---------------------------------│
       │                                  │
       │  3. Context Share (if needed)    │
       │--------------------------------->│
       │                                  │
       │                              4. Request Guidance (if blocked)
       │<---------------------------------│
       │                                  │
       │  5. Guidance Response            │
       │--------------------------------->│
       │                                  │
       │                              6. Status Update (nearly done)
       │<---------------------------------│
       │                                  │
       │                              7. Findings Report
       │<---------------------------------│
       │                                  │
       │                              8. Completion Notification
       │<---------------------------------│
       │                                  │
```

---

## File-Based Message Queue

### Queue Directory Structure

```
/tmp/claude-work-queue/
├── to-backend/
│   ├── TASK-001.yaml
│   └── TASK-002.yaml
├── to-frontend/
│   └── TASK-003.yaml
├── to-database/
│   └── TASK-004.yaml
├── to-techlead/
│   ├── STATUS-backend-TASK-001.yaml
│   ├── FINDINGS-backend-TASK-001.yaml
│   └── COMPLETE-backend-TASK-001.yaml
└── processed/
    ├── TASK-001.yaml
    └── TASK-002.yaml
```

### Queue Operations

**Enqueue (Send message):**
```bash
# Tech Lead sends task to Backend
cat > /tmp/claude-work-queue/to-backend/TASK-001.yaml << 'EOF'
[message YAML content]
EOF

# Notify Backend session
tmux send-keys -t claude-work:backend "echo '[New task: TASK-001]'" C-m
```

**Dequeue (Receive message):**
```bash
# Backend agent checks for tasks
while true; do
    if compgen -G /tmp/claude-work-queue/to-backend/*.yaml > /dev/null; then
        # Process first message
        task_file=$(ls /tmp/claude-work-queue/to-backend/*.yaml | head -1)
        cat "$task_file"

        # Move to processed
        mv "$task_file" /tmp/claude-work-queue/processed/
        break
    fi
    sleep 1
done
```

---

## Agent Integration

### Receiving Messages

Each agent should:

1. **Poll for messages:**
```bash
# In agent session
check_messages() {
    local agent_name="backend"
    local queue_dir="/tmp/claude-work-queue/to-$agent_name"

    if compgen -G "$queue_dir"/*.yaml > /dev/null 2>&1; then
        echo "📬 New messages available"
        ls -la "$queue_dir"
    fi
}

# Run periodically or before agent triggers
check_messages
```

2. **Process messages:**
```yaml
# When agent receives task_assignment
# - Read task details
# - Perform analysis
# - Send status_update
# - Send findings_report when done
# - Send completion_notification
```

### Sending Messages

Each agent should:

1. **Send to Tech Lead:**
```bash
# Agent sends report
cat > /tmp/claude-work-queue/to-techlead/FINDINGS-backend-TASK-001.yaml << 'EOF'
[findings_report YAML]
EOF

# Notify Tech Lead
tmux send-keys -t claude-work:techlead "echo '[New findings from backend]'" C-m
```

---

## Best Practices

### Message Naming

- **Task assignments:** `TASK-{number}.yaml`
- **Status updates:** `STATUS-{agent}-TASK-{number}.yaml`
- **Findings:** `FINDINGS-{agent}-TASK-{number}.yaml`
- **Completions:** `COMPLETE-{agent}-TASK-{number}.yaml`
- **Guidance requests:** `GUIDE-{agent}-TASK-{number}.yaml`

### Message Size

- Keep messages under 100KB when possible
- For large content, use file paths in `artifacts`
- Use summary in message, details in attached file

### Timestamps

- Always use ISO 8601 format: `2026-04-19T10:00:00Z`
- Include timezone (preferably UTC)

### Priority Handling

```yaml
priority_mapping:
  critical:
    response_time: "< 5 minutes"
    notification: "immediate alert"
  high:
    response_time: "< 15 minutes"
    notification: "prompt notification"
  medium:
    response_time: "< 1 hour"
    notification: "next check"
  low:
    response_time: "< 4 hours"
    notification: "batch processing"
```

---

## Error Handling

### Failed Messages

```yaml
message_type: error
timestamp: "2026-04-19T10:00:00Z"
from: [agent_name]
to: techlead

error:
  type: [task_failed|message_corrupted|agent_crashed]
  message: "[Error message]"
  task_id: "[Failed task ID]"
  recovery_action: "[How to recover]"
```

### Retry Logic

- **Transient errors:** Retry 3 times with exponential backoff
- **Permanent errors:** Send error message to Tech Lead immediately
- **Agent crash:** Tech Lead detects timeout, reassigns task

---

## Security Considerations

1. **File Permissions:**
```bash
# Queue directory should be user-only
chmod 700 /tmp/claude-work-queue

# Messages should be user-read-only
chmod 600 /tmp/claude-work-queue/to-*/*.yaml
```

2. **Message Validation:**
- Validate YAML syntax before enqueuing
- Validate required fields before processing
- Sanitize file paths in artifacts

3. **Audit Trail:**
- Log all messages with timestamps
- Keep processed messages for audit
- Track message lineage (which agent sent what)

---

## Version

**Protocol Version:** 1.0.0
**Last Updated:** 2026-04-19
**Compatible with:** EM-Skill Distributed Orchestration

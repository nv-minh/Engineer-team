# EM-Team Architecture Overview

Tổng quan kiến trúc hệ thống EM-Team v5.4.0.

---

## Mục Lục

1. [Kiến trúc Tổng thể](#kiến-trúc-tổng-thể)
2. [Component Architecture](#component-architecture)
3. [Data Flow](#data-flow)
4. [Technology Stack](#technology-stack)
5. [Design Patterns](#design-patterns)
6. [Scalability](#scalability)

---

## Kiến trúc Tổng thể

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    EM-Team System                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │  Skills    │  │  Agents    │  │ Workflows  │           │
│  │  (89)      │  │  (36+2dep) │  │  (27)      │           │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘           │
│        │                │                │                  │
│        └────────────────┴────────────────┘                  │
│                         │                                   │
│                         ▼                                   │
│              ┌──────────────────┐                          │
│              │  Core System     │                          │
│              │  - Dispatcher    │                          │
│              │  - Orchestrator  │                          │
│              │  - Coordinator   │                          │
│              └────────┬─────────┘                          │
│                       │                                     │
│        ┌──────────────┼──────────────┐                     │
│        ▼              ▼              ▼                     │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐                  │
│  │ File    │   │ tmux    │   │ Reports │                  │
│  │ System  │   │ Sessions│   │ System  │                  │
│  └─────────┘   └─────────┘   └─────────┘                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Three-Layer Architecture

```yaml
presentation_layer:
  components:
    - Skills (reusable patterns)
    - Agents (specialized assistants)
    - Workflows (end-to-end processes)
  responsibility: User interaction, task execution

orchestration_layer:
  components:
    - Dispatcher (route commands to agents)
    - Orchestrator (coordinate distributed work)
    - Coordinator (manage agent communication)
  responsibility: Task coordination, agent orchestration

persistence_layer:
  components:
    - File System (knowledge, reports)
    - tmux Sessions (distributed mode)
    - Reports System (consolidated findings)
  responsibility: Data storage, communication, state
```

---

## Component Architecture

### 1. Skills Component

**Purpose:** Reusable patterns and practices

**Structure:**
```
skills/
├── foundation/        # 7 core foundational skills
├── development/       # 11 methodology skills
├── expert-react/      # 4 React skills
├── expert-vue/        # 3 Vue skills
├── expert-go/         # 1 Go skill
├── expert-nest/       # 1 NestJS skill
├── expert-python/     # 3 Python skills
├── expert-database/   # 3 Database skills
├── expert-devops/     # 6 DevOps skills
├── expert-mobile/     # 4 Mobile skills
├── expert-spring/     # 1 Spring skill
├── expert-frontend/   # 1 Frontend skill
├── expert-backend/    # 2 Backend skills
├── expert-rust/       # 1 Rust skill
├── expert-typescript/ # 1 TypeScript skill
├── drawio/            # 2 Drawio skills
├── tauri/             # 1 Tauri skill
├── quality/           # 14 quality assurance skills
├── workflow/          # 6 workflow and automation skills
└── additional/        # 5 product & discovery skills
```

**Key Characteristics:**
- YAML frontmatter for metadata
- Standardized structure (Overview, When to Use, Process, Verification)
- Self-contained execution logic
- Reusable across contexts

### 2. Agents Component

**Purpose:** Specialized AI assistants

**Structure:**
```
agents/
├── core (8): planner, executor, code-reviewer, debugger,
│   test-engineer, security-reviewer, ui-auditor, verifier
├── optional (4): researcher, codebase-mapper,
│   integration-checker, performance-auditor
├── specialized (9): team-lead, architect, frontend-expert,
│   backend-expert, senior-code-reviewer (deprecated), database-expert,
│   product-manager, security-reviewer (unified), staff-engineer
├── v2.0+ (7): market-intelligence, learn, autoplan,
│   techlead-orchestrator, design-reviewer, devex-reviewer,
│   iron-law-enforcer
└── expert (7): react-expert, vue-expert, nestjs-expert,
    devops-expert, mobile-expert, spring-expert, rust-expert
```

**Key Characteristics:**
- Trigger commands for invocation
- Handoff contracts (input/output)
- Output templates
- Completion markers
- Specialization domains

### 3. Workflows Component

**Purpose:** End-to-end processes

**Structure:**
```
workflows/
├── primary/          # 5 primary workflows (incl. greenfield-app)
├── support/          # 6 support workflows
├── master: six-phase-lifecycle
├── team/             # 8 team workflows
├── distributed/      # 2 distributed workflows
├── product/          # 2 product workflows
├── incident/         # 6 incident sub-workflows
└── security/         # 3 security sub-workflows
```

**Key Characteristics:**
- Multi-phase execution
- Agent orchestration
- Entry/exit criteria
- Quality gates
- Verification steps

### 4. Distributed System Component

**Purpose:** Parallel agent execution

**Structure:**
```
distributed/
├── session-coordinator.sh    # Coordinate sessions
├── agent-dispatcher.sh       # Dispatch tasks
├── report-consolidator.sh    # Consolidate reports
└── token-manager.sh          # Manage tokens
```

**Key Characteristics:**
- tmux-based isolation
- Parallel execution
- Report consolidation
- Token management
- File-based communication

---

## Data Flow

### Command Execution Flow

```
User Input
   │
   ▼
┌─────────────┐
│ Dispatcher  │  Parse command, identify type
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Route to        │
│ Skill/Agent/    │
│ Workflow        │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ Execute         │  Apply pattern, create output
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ Verify          │  Check quality, validate
└────┬────────────┘
     │
     ▼
  Output
```

### Distributed Mode Flow

```
Tech Lead Orchestrator
   │
   ├─→ Backend Expert Window
   │   ├─ Analyze backend
   │   ├─ Save report
   │   └─ Notify complete
   │
   ├─→ Frontend Expert Window
   │   ├─ Analyze frontend
   │   ├─ Save report
   │   └─ Notify complete
   │
   └─→ Database Expert Window
       ├─ Analyze database
       ├─ Save report
       └─ Notify complete

All reports → Consolidator → Tech Lead Review → Final Report
```

### Knowledge Persistence Flow

```
Codebase-Mapper Agent
   │
   ├─→ Scan project structure
   ├─→ Analyze code patterns
   ├─→ Extract conventions
   │
   ▼
Save to .claude/knowledge/
   ├─ project-conventions.md
   ├─ coding-style.md
   ├─ architecture-patterns.md
   └─ examples/
   │
   ▼
All Agents Load Knowledge
   ├─ Naming conventions
   ├─ Code style
   ├─ Architecture patterns
   └─ Apply to work
```

---

## Technology Stack

### Core Technologies

```yaml
languages:
  - Shell (Bash/Zsh)
  - Markdown (documentation)
  - YAML (configuration)

tools:
  - tmux (session management)
  - git (version control)
  - Claude Code (AI platform)

integrations:
  - MCP (Model Context Protocol)
  - GitHub (repository)
  - DevTools (browser automation)
```

### File System Structure

```
EM-Team/
├── skills/           # Skill definitions
├── agents/           # Agent definitions
├── workflows/        # Workflow definitions
├── scripts/          # Automation scripts
├── commands/         # CLI commands
├── distributed/      # Distributed system
├── tests/            # Test suite
├── docs/             # Documentation
├── protocols/        # Protocol definitions
├── templates/        # Reusable templates
├── hooks/            # Git hooks
└── .claude/          # Claude-specific
    ├── knowledge/    # Knowledge base
    ├── reports/      # Agent reports
    └── tdd-context/  # TDD error context
```

---

## Design Patterns

### 1. Agent-Skill-Workflow (ASW) Pattern

**Description:** Three-tier abstraction for task execution

**Implementation:**
```yaml
tier_1_skills:
  use_for: "Simple, single-concern tasks"
  examples:
    - "/brainstorming Explore ideas"
    - "/test-driven-dev Implement feature"

tier_2_agents:
  use_for: "Specialized, domain-specific tasks"
  examples:
    - "/em:backend-expert Optimize API"
    - "/em:security-reviewer Audit system"

tier_3_workflows:
  use_for: "Complex, multi-phase processes"
  examples:
    - "/em:new-feature Idea to production"
    - "/em:distributed-investigation Full stack investigation"
```

### 2. File-Based Communication Pattern

**Description:** Agents communicate via file system

**Implementation:**
```yaml
communication:
  method: "File-based messaging"
  directories:
    input: "/tmp/claude-work-queue/"
    output: "/tmp/claude-work-reports/"

message_format:
  header: "YAML frontmatter"
  body: "Markdown content"

advantages:
  - No network dependencies
  - Persistent communication
  - Debuggable (read files)
  - Scalable (parallel access)
```

### 3. Orchestrator Pattern

**Description:** Central coordinator for distributed work

**Implementation:**
```yaml
orchestrator:
  role: "Tech Lead Agent"
  responsibilities:
    - Analyze task
    - Delegate to specialists
    - Consolidate findings
    - Create final report

specialist_agents:
  - Backend Expert
  - Frontend Expert
  - Database Expert
  - Security Auditor

coordination:
  method: "Queue-based task distribution"
  synchronization: "File-based signaling"
```

### 4. Template Method Pattern

**Description:** Standardized structures for consistency

**Implementation:**
```yaml
skill_template:
  - YAML frontmatter (metadata)
  - Overview
  - When to Use
  - Process
  - Rationalizations
  - Red Flags
  - Verification

agent_template:
  - YAML frontmatter (metadata)
  - Overview
  - Responsibilities
  - When to Use
  - Process/Methodology
  - Handoff Contracts
  - Output Template
  - Completion Checklist

workflow_template:
  - YAML frontmatter (metadata)
  - Overview
  - When to Use
  - Participants
  - Process Flow
  - Entry/Exit Criteria
  - Verification
```

---

## Scalability

### Horizontal Scaling

**Distributed Mode:**
- Run multiple agents in parallel
- Isolated tmux sessions
- Independent report generation
- Consolidated findings

**Implementation:**
```bash
# Start distributed mode
./scripts/distributed-orchestrator.sh start

# Agents work in parallel
# - Backend Expert: Window 1
# - Frontend Expert: Window 2
# - Database Expert: Window 3

# Consolidate results
./scripts/consolidate-reports.sh consolidate
```

### Vertical Scaling

**Token Management:**
- 200K token budget per agent
- 150K threshold for summarization
- Haiku-powered summarization
- 100% critical information preservation

**Implementation:**
```bash
# Check token count
./scripts/token-counter.sh estimate report.md

# Summarize if needed
./scripts/haiku-client.sh summarize report.md summary.md 80000

# Consolidate with summarization
./scripts/consolidate-reports.sh consolidate
```

### Knowledge Scaling

**Persistent Learning:**
- Extract project conventions
- Save to knowledge base
- Share across all agents
- Grow over time

**Implementation:**
```bash
# Extract knowledge
Agent: codebase-mapper - Analyze project

# All agents use knowledge
Agent: frontend-expert - Create component
# Automatically follows project conventions
```

---

## Performance Characteristics

### Latency

```yaml
single_agent_task:
  typical: "30s - 2m"
  depends_on: "Task complexity"

distributed_investigation:
  typical: "2m - 10m"
  parallel: "3-5 agents working simultaneously"
  speedup: "3-5x vs sequential"

workflow_execution:
  new_feature: "1-4 hours"
  bug_fix: "30m - 2 hours"
  refactoring: "1-3 hours"
```

### Throughput

```yaml
concurrent_agents:
  max: "Limited by tmux sessions (~10)"
  typical: "3-5 agents in distributed mode"

token_throughput:
  per_agent: "200K tokens per session"
  with_summarization: "Effectively unlimited (iterative summarization)"
```

### Reliability

```yaml
error_handling:
  single_agent: "Retry with exponential backoff"
  distributed: "Isolated failures, report consolidation"
  token_overflow: "Automatic summarization"

recovery:
  agent_failure: "Other agents continue"
  session_crash: "Report preservation in file system"
  network_failure: "No network dependencies (file-based)"
```

---

## Security Considerations

### Data Isolation

```yaml
tmux_sessions:
  isolation: "Process-level isolation"
  communication: "File-based (no shared memory)"

reports:
  storage: "/tmp/claude-work-reports/"
  permissions: "User-restricted"
  cleanup: "Manual or on session stop"
```

### Input Validation

```yaml
command_validation:
  parse: "Check command structure"
  route: "Validate agent/workflow exists"
  execute: "Apply pattern with error handling"

user_input:
  sanitize: "Remove malicious patterns"
  validate: "Check for instruction injection"
  log: "Audit trail in reports"
```

---

## Monitoring & Observability

### Logging

```yaml
log_locations:
  agent_logs: "/tmp/claude-work-logs/"
  session_logs: "tmux session logs"
  error_logs: "agent-specific error files"

log_levels:
  info: "Normal operation"
  warn: "Non-critical issues"
  error: "Failures requiring attention"
```

### Metrics

```yaml
agent_metrics:
  - Execution time
  - Token usage
  - Report quality
  - Error rate

system_metrics:
  - Active sessions
  - Queue depth
  - Token consumption
  - Report generation rate
```

---

## Future Architecture Improvements

### Planned Enhancements

- [ ] **Knowledge Versioning** - Track convention evolution
- [ ] **Agent Marketplace** - Community-contributed agents
- [ ] **Workflow Builder** - Visual workflow composition
- [ ] **Performance Dashboard** - Real-time metrics
- [ ] **AI-Powered Routing** - Automatic agent selection
- [ ] **Multi-Project Knowledge** - Share knowledge across projects
- [ ] **Event-Driven Architecture** - Async agent communication
- [ ] **Plugin System** - Extensible architecture

---

## Related Documentation

- [Distributed System](distributed-system.md) - Chi tiết kiến trúc phân tán
- [Protocols](../protocols/) - Giao tiếp và định dạng
- [Agents](../agents/overview.md) - Tổng quan agents
- [Skills](../skills/overview.md) - Tổng quan skills
- [Workflows](../workflows/overview.md) - Tổng quan workflows

---

**Version:** 5.2.0
**Last Updated:** 2026-05-26
**Architecture Style:** Agent-Skill-Workflow (ASW)

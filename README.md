# EM-Skill - Fullstack Engineering Agent/Skill/Workflow System

> A comprehensive system of agents, skills, and workflows for fullstack engineering, synthesized from the best practices of 6 top AI agent/workflow repositories.

## Overview

EM-Skill provides a complete toolkit for fullstack engineering with:
- **25-30 Skills** - Reusable patterns and practices
- **8-12 Agents** - Specialized task handlers
- **5-8 Workflows** - End-to-end processes
- **Full Features** - Browser automation, MCP integrations, memory system
- **Distributed Mode** - Parallel agent execution for complex tasks

---

## 📦 Installation

### Prerequisites

Before installing EM-Skill, ensure you have the following:

#### Required
- **Bash** - Shell environment (version 4.0+)
- **tmux** - Terminal multiplexer (for distributed mode)
- **Git** - Version control system
- **Claude Code CLI** - AI coding assistant

#### Optional (for enhanced features)
- **Node.js** (v18+) - For some automation scripts
- **Python** (v3.8+) - For additional utilities

### Install Prerequisites

#### macOS
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tmux
brew install tmux

# Install Node.js (optional)
brew install node

# Install Python 3 (optional)
brew install python@3.11
```

#### Ubuntu/Debian
```bash
# Update package list
sudo apt update

# Install tmux
sudo apt install -y tmux

# Install Node.js (optional)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Python 3 (optional)
sudo apt install -y python3.11 python3-pip
```

#### Windows (WSL)
```bash
# Install Ubuntu on WSL
wsl --install -d Ubuntu

# Inside WSL, follow Ubuntu instructions above
```

### Installation Steps

#### 1. Clone Repository

```bash
# Clone the repository
git clone https://github.com/nv-minh/agent-team.git
cd agent-team
```

#### 2. Verify Installation

```bash
# Check if all required files exist
ls -la scripts/
ls -la agents/
ls -la workflows/
ls -la distributed/

# Expected output:
# scripts/
# ├── distributed-orchestrator.sh
# ├── session-manager.sh
# └── consolidate-reports.sh
#
# distributed/
# ├── session-coordinator.sh
# └── session-sync.sh
```

#### 3. Make Scripts Executable

```bash
# Make all shell scripts executable
chmod +x scripts/*.sh
chmod +x distributed/*.sh
chmod +x tests/*.sh

# Verify permissions
ls -la scripts/*.sh
# Expected: -rwxr-xr-x for all .sh files
```

#### 4. Run Tests

```bash
# Navigate to tests directory
cd tests

# Run E2E tests to verify installation
./run-e2e-tests.sh

# Expected output:
# ==========================================
# Distributed Orchestration E2E Tests
# ==========================================
# ...
# Test Summary
# Total Tests: 8
# Passed: 8
# Failed: 0
# All tests passed!
```

#### 5. Verify Distributed Mode

```bash
# Start distributed orchestration
./scripts/distributed-orchestrator.sh start

# Expected output:
# [INFO] Starting distributed agent orchestration...
# [SUCCESS] Directories initialized
# [SUCCESS] Created session: claude-work

# Check sessions
./scripts/session-manager.sh list

# Stop distributed mode
./scripts/distributed-orchestrator.sh stop
```

### Configuration

#### Environment Variables (Optional)

```bash
# Add to ~/.bashrc or ~/.zshrc

# EM-Skill Configuration
export EM_SKILL_HOME="$HOME/agent-team"
export PATH="$PATH:$EM_SKILL_HOME/scripts"
export PATH="$PATH:$EM_SKILL_HOME/distributed"
```

#### Claude Code Integration

EM-Skill works with Claude Code CLI out of the box. Simply invoke skills, agents, or workflows in your conversation:

```bash
# Example invocations
"Use the brainstorming skill to explore authentication"
"Agent: em-planner - Create plan for user auth"
"Workflow: em-new-feature - Implement authentication"
```

### Verification Checklist

After installation, verify the following:

- [ ] tmux is installed (`tmux -V`)
- [ ] All scripts are executable
- [ ] E2E tests pass (8/8 tests)
- [ ] Distributed orchestration starts successfully
- [ ] Session manager works
- [ ] Can invoke skills/agents/workflows

### Troubleshooting Installation

#### Issue: "command not found: tmux"

**Solution:**
```bash
# Install tmux
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt install tmux

# Verify installation
tmux -V
```

#### Issue: "Permission denied: ./script.sh"

**Solution:**
```bash
# Make scripts executable
chmod +x scripts/*.sh
chmod +x distributed/*.sh
chmod +x tests/*.sh
```

#### Issue: "Tests failing"

**Solution:**
```bash
# Check test logs
cd tests
./run-e2e-tests.sh --verbose

# Run individual test
./test-distributed-orchestrator.sh

# Check environment
echo $SHELL  # Should be /bin/bash or /bin/zsh
```

#### Issue: "Distributed mode won't start"

**Solution:**
```bash
# Kill existing tmux sessions
tmux kill-server

# Remove old directories
rm -rf /tmp/claude-work-*

# Try again
./scripts/distributed-orchestrator.sh start
```

### Update EM-Skill

```bash
# Navigate to project directory
cd agent-team

# Pull latest changes
git pull origin main

# Run tests to verify
cd tests && ./run-e2e-tests.sh
```

### Uninstall

```bash
# Remove repository
rm -rf ~/agent-team

# Remove environment variables from ~/.bashrc or ~/.zshrc
# Remove lines containing EM_SKILL_HOME

# Clean up temporary files
rm -rf /tmp/claude-work-*
```

---

## 🚀 Quick Start

Get started with EM-Skill in 5 minutes!

### First Steps

#### 1. Explore Skills (1 minute)

```bash
# Use brainstorming to explore ideas
"Use the brainstorming skill to explore a user authentication feature"

# Create a specification
"Use the spec-driven-development skill to create a spec for user authentication"
```

#### 2. Use Agents (2 minutes)

```bash
# Create an implementation plan
"Agent: em-planner - Create implementation plan for user authentication feature"

# Review your code
"Agent: em-code-reviewer - Review the changes in this PR"

# Debug issues
"Agent: em-debugger - Investigate this login bug systematically"
```

#### 3. Run Workflows (2 minutes)

```bash
# Build a new feature from idea to production
"Workflow: em-new-feature - Take user authentication from idea to production"

# Fix bugs systematically
"Workflow: em-bug-fix - Fix the login timeout bug"

# Audit security
"Workflow: em-security-audit - Audit the authentication system"
```

### Try Distributed Mode

For complex tasks requiring multiple specialist agents:

```bash
# 1. Start distributed orchestration
./scripts/distributed-orchestrator.sh start

# 2. Attach to orchestrator window
tmux attach -t claude-work:orchestrator

# 3. Trigger distributed investigation
"Agent: em-techlead-orchestrator - Investigate authentication bug across entire stack"

# 4. View consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# 5. Stop when done
./scripts/distributed-orchestrator.sh stop
```

### Next Steps

1. 📖 **Read the Guides**
   - [Quick Start Guide](docs/guides/getting-started.md) - Detailed setup guide
   - [Comprehensive Usage (EN)](docs/guides/usage-guide.md) - Full English documentation
   - [Hướng Dẫn Sử Dụng (VI)](docs/vi/huong-dan-su-dung.md) - Tài liệu tiếng Việt

2. 🏗️ **Learn Architecture**
   - [Distributed System](docs/architecture/distributed-system.md) - How distributed mode works
   - [System Overview](docs/README.md) - Complete documentation index

3. 🧪 **Verify Installation**
   ```bash
   cd tests
   ./run-e2e-tests.sh
   # Expected: All 8 tests pass
   ```

4. 🎯 **Choose Your Path**
   - **Beginner:** Start with [Getting Started Guide](docs/guides/getting-started.md)
   - **Intermediate:** Explore [Skills Reference](docs/skills/overview.md)
   - **Advanced:** Set up [Distributed Mode](docs/architecture/distributed-system.md)

---

## 📖 Basic Usage

### Using Skills

Invoke skills directly by name:

```bash
# Use brainstorming skill
"Use the brainstorming skill to explore this feature idea"

# Use spec-driven-development skill
"Use the spec-driven-development skill to create a spec for user authentication"

# Use systematic-debugging skill
"Use the systematic-debugging skill to investigate this bug"
```

### Using Agents

Dispatch agents for specialized tasks:

```bash
# Use planner agent
"Agent: em-planner - Create implementation plan for user authentication feature"

# Use code-reviewer agent
"Agent: em-code-reviewer - Review the changes in this PR"

# Use debugger agent
"Agent: em-debugger - Investigate this bug systematically"
```

### Using Workflows

Run end-to-end workflows:

```bash
# New feature workflow
"Workflow: em-new-feature - Take user authentication from idea to production"

# Bug fix workflow
"Workflow: em-bug-fix - Fix the login bug systematically"

# Security audit workflow
"Workflow: em-security-audit - Audit the codebase for security issues"
```

## Project Structure

```
em-skill/
├── skills/                  # 25-30 skills organized by category
│   ├── foundation/          # Core foundational skills (5)
│   ├── development/         # Development workflow skills (8)
│   ├── quality/             # Quality assurance skills (7)
│   ├── workflow/            # Workflow and automation skills (5)
│   └── specialized/         # Language/framework-specific skills
├── agents/                  # 16-20 specialized agents
├── workflows/               # 16 end-to-end workflows
├── distributed/             # Distributed orchestration system
│   ├── session-coordinator.sh  # High-level coordination
│   └── session-sync.sh         # Context synchronization
├── scripts/                 # Core orchestration scripts
│   ├── distributed-orchestrator.sh  # Creates tmux sessions
│   ├── session-manager.sh          # Manages sessions
│   └── consolidate-reports.sh      # Report consolidation
├── protocols/               # Message and report formats
│   ├── distributed-messaging.md    # Message protocol
│   └── report-format.md            # Report specification
├── tests/                   # Comprehensive test suite
│   ├── test-helpers.sh            # Shared test utilities
│   ├── test-*.sh                  # Unit & integration tests
│   ├── run-e2e-tests.sh           # E2E test runner
│   └── manual-test-with-agents.md # Manual testing guide
├── templates/               # Reusable templates
├── hooks/                   # Automation hooks
├── commands/                # CLI commands
├── config/                  # Configuration files
├── docs/                    # Documentation
│   └── skill-systems-guide.md  # Skill system integration guide
└── CLAUDE.md                # Main configuration
```

> **Note:** EM-Skill includes multiple skill systems from different sources. See [Skill Systems Guide](docs/skill-systems-guide.md) for when to use each system.

---

## 🏗️ Architecture

### Distributed Agent Orchestration System

EM-Skill includes a **distributed agent orchestration system** that solves token context overflow by running agents in separate tmux sessions.

#### Problem Solved

When working with complex tasks requiring multiple specialist agents, token context limits become a bottleneck. Traditional approaches:
- ❌ Run all agents sequentially (slow)
- ❌ Truncate context (lose information)
- ❌ Increase token limits (expensive)

#### Our Solution

**Parallel agent execution in isolated tmux sessions:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code Session                      │
│                  (Token Budget: 200K)                      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Tech Lead Orchestrator Agent                 │  │
│  │         (Token Budget: 200K)                        │  │
│  │                                                      │  │
│  │  Task Delegation → Message Queue → Task Assignment  │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                  │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Message Queue                           │  │
│  │         (/tmp/claude-work-queue/)                    │  │
│  │                                                      │  │
│  │  pending/     processing/     completed/             │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                  │
│          ┌───────────────┼───────────────┐                  │
│          ▼               ▼               ▼                  │
│  ┌───────────┐   ┌───────────┐   ┌───────────┐              │
│  │  Backend  │   │ Frontend  │   │ Database  │              │
│  │  Expert   │   │  Expert   │   │  Expert   │              │
│  │           │   │           │   │           │              │
│  │ 200K tok  │   │ 200K tok  │   │ 200K tok  │              │
│  └───────────┘   └───────────┘   └───────────┘              │
│          │               │               │                  │
│          └───────────────┼───────────────┘                  │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          Shared Reports Directory                    │  │
│  │       (/tmp/claude-work-reports/)                    │  │
│  │                                                      │  │
│  │  backend/  frontend/  database/  techlead/           │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                  │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Report Consolidation                         │  │
│  │     (Generates consolidated report)                  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

#### Architecture Components

**1. Orchestration Layer**
- `distributed-orchestrator.sh` - Creates and manages tmux sessions
- `session-coordinator.sh` - High-level coordination logic
- `session-sync.sh` - Context synchronization across sessions

**2. Session Management**
- `session-manager.sh` - List, kill, broadcast to sessions
- Each agent runs in isolated tmux window
- Shared directories for communication

**3. Message Protocol**
- `distributed-messaging.md` - Message format specification
- YAML-based task assignments and status updates
- Queue-based processing (pending → processing → completed)

**4. Report System**
- `report-format.md` - Standard report structure
- `consolidate-reports.sh` - Collects and merges reports
- YAML frontmatter with findings, recommendations, next steps

**5. Communication Flow**

```
1. Orchestrator receives task
2. Orchestrator creates task assignments
3. Task assignments placed in queue/
4. Specialist agents pick up tasks
5. Agents generate reports in shared/
6. Reports consolidated into summary
7. Consolidated report returned to user
```

#### Benefits

✅ **Parallel Execution** - Multiple agents work simultaneously
✅ **Isolated Context** - Each agent has full 200K token budget
✅ **No Information Loss** - Complete context preservation
✅ **Scalable** - Add more agents without token issues
✅ **Observable** - Full audit trail via reports

---

## Skills

### Foundation Skills (5 skills)

1. **spec-driven-development** - Write specs before coding
2. **brainstorming** - Explore ideas into designs
3. **context-engineering** - Optimize agent context setup
4. **writing-plans** - Break work into bite-sized tasks
5. **systematic-debugging** - 4-phase debugging methodology

### Development Skills (8 skills)

6. **test-driven-development** - TDD RED-GREEN-REFACTOR
7. **frontend-patterns** - React/Next.js/Vue patterns
8. **backend-patterns** - API/Database patterns
9. **incremental-implementation** - Vertical slice development
10. **subagent-driven-development** - Fresh context per task
11. **source-driven-development** - Code from official docs
12. **api-interface-design** - Contract-first APIs
13. **security-hardening** - OWASP Top 10 security

### Quality Skills (7 skills)

14. **code-review** - 5-axis review framework
15. **code-simplification** - Reduce complexity
16. **browser-testing** - DevTools MCP integration
17. **performance-optimization** - Measure-first optimization
18. **e2e-testing** - Playwright patterns
19. **security-audit** - Vulnerability assessment
20. **api-testing** - Integration testing

### Workflow Skills (5 skills)

21. **git-workflow** - Atomic commits
22. **ci-cd-automation** - Feature flags, quality gates
23. **documentation** - ADRs, API docs
24. **finishing-branch** - Merge/PR decisions
25. **deprecation-migration** - Code-as-liability mindset

## Agents

### Core Agents (8 agents)

1. **planner** - Create detailed implementation plans
2. **executor** - Execute with atomic commits
3. **code-reviewer** - 5-axis code review
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-auditor** - OWASP assessment
7. **ui-auditor** - Visual QA
8. **verifier** - Post-execution verification

### Optional Agents (4 agents)

9. **researcher** - Technical exploration
10. **codebase-mapper** - Architecture analysis
11. **integration-checker** - Cross-phase validation
12. **performance-auditor** - Benchmarking

## Workflows

### Primary Workflows

1. **new-feature** - From idea to production
2. **bug-fix** - Investigate and fix bugs
3. **refactoring** - Improve code quality
4. **security-audit** - Security assessment

### Support Workflows

5. **project-setup** - Initialize new projects
6. **documentation** - Generate and update docs
7. **deployment** - Deploy and monitor
8. **retro** - Learn and improve

## Special Features

### ✅ Browser Automation

- Headless browser for E2E testing
- DevTools MCP integration
- Visual QA capabilities
- Screenshot comparison

### ✅ MCP Integrations

- **GitHub** - Repository context
- **Context7** - Documentation search
- **Exa** - Web research
- **Memory** - Cross-session learning
- **Playwright** - Browser automation

### ✅ Memory System

- Learn patterns across sessions
- Remember user preferences
- Track project conventions
- Build knowledge base

## Iron Laws

1. **TDD Iron Law**: NO PRODUCTION CODE WITHOUT FAILING TEST
2. **Debugging Iron Law**: NO FIXES WITHOUT ROOT CAUSE
3. **Skill Iron Law**: ALL SKILLS MUST HAVE FAILING TESTS
4. **Spec Iron Law**: NO CODE WITHOUT SPEC (for features)

## Development Lifecycle

```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SIMPLIFY → SHIP
```

## Three-Tier Boundary System

### Always Do
- Run tests before commits
- Follow naming conventions
- Validate inputs
- Write tests for new code
- Review code before shipping

### Ask First
- Database schema changes
- Adding dependencies
- Changing CI config
- Breaking changes
- Performance optimizations

### Never Do
- Commit secrets
- Edit vendor directories
- Remove failing tests without approval
- Skip code review
- Push to main without tests

## Tech Stack Support

### Languages
- JavaScript/TypeScript
- Python
- Go
- Rust
- Java
- Kotlin
- PHP
- C#
- C++

### Frontend Frameworks
- React
- Next.js
- Vue
- Svelte
- Angular

### Backend Frameworks
- Node.js (Express, Fastify)
- Python (Django, Flask, FastAPI)
- Go (Gin, Echo)
- Java (Spring Boot)
- PHP (Laravel)

## Quality Gates

- [ ] All skills have YAML frontmatter
- [ ] All agents have completion markers
- [ ] All workflows have verification steps
- [ ] Documentation is complete
- [ ] Tests are passing
- [ ] Code review is done
- [ ] Security audit is passed

## 🚀 Usage

### Standard Agent/Skill/Workflow Usage

#### Using Skills

### Example 1: Building a New Feature

```bash
# Step 1: Brainstorm the feature
"Use the brainstorming skill to explore a user authentication feature"

# Step 2: Create a spec
"Use the spec-driven-development skill to create a spec for authentication"

# Step 3: Write a plan
"Use the writing-plans skill to break down the implementation"

# Step 4: Execute the plan
"Use the subagent-driven-development skill to implement the plan"

# Step 5: Review the code
"Agent: em-code-reviewer - Review the authentication implementation"

# Step 6: Deploy
"Workflow: em-deployment - Deploy the authentication feature"
```

### Example 2: Fixing a Bug

```bash
# Step 1: Debug systematically
"Use the systematic-debugging skill to investigate the login bug"

# Step 2: Fix the root cause
# (After root cause is identified)
"Use the test-driven-development skill to fix the bug"

# Step 3: Verify the fix
"Use the api-testing skill to verify the login endpoint works"

# Step 4: Code review
"Agent: em-code-reviewer - Review the bug fix"
```

### Example 3: Distributed Investigation (Complex Tasks)

For complex tasks requiring multiple specialist agents:

```bash
# Start distributed orchestration
cd /path/to/em-skill
./scripts/distributed-orchestrator.sh start

# This creates a tmux session with multiple agent windows:
# - orchestrator (Tech Lead)
# - backend (Backend Expert)
# - frontend (Frontend Expert)
# - database (Database Expert)

# Attach to orchestrator window
tmux attach -t claude-work:orchestrator

# Trigger investigation
"Agent: em-techlead-orchestrator - Investigate authentication bug across the entire stack"

# The orchestrator will:
# 1. Analyze the task
# 2. Delegate subtasks to specialist agents
# 3. Collect findings from all agents
# 4. Consolidate into a comprehensive report

# View consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# Stop distributed orchestration when done
./scripts/distributed-orchestrator.sh stop
```

### Distributed System Commands

```bash
# Start distributed orchestration
./scripts/distributed-orchestrator.sh start

# List active sessions
./scripts/session-manager.sh list

# Check queue status
./distributed/session-coordinator.sh queue-status

# Check agent status
./distributed/session-coordinator.sh agent-status

# List available reports
./scripts/consolidate-reports.sh list

# Consolidate all reports
./scripts/consolidate-reports.sh consolidate

# Broadcast message to all agent windows
./scripts/session-manager.sh broadcast "echo 'Hello all agents'"

# Stop distributed orchestration
./scripts/distributed-orchestrator.sh stop
```

### When to Use Distributed System

**Use Distributed System when:**
- ✅ Task requires analysis across multiple domains (backend, frontend, database)
- ✅ Task is complex and needs specialist expertise
- ✅ You need parallel investigation for speed
- ✅ Task context is large (approaching token limits)
- ✅ You need comprehensive audit trail

**Use Standard Agents when:**
- ✅ Task is straightforward and single-domain
- ✅ Quick investigation needed
- ✅ Task doesn't require parallel processing
- ✅ Simpler workflow preferred

### Testing

Run the test suite to verify system functionality:

```bash
# Run all E2E tests
cd tests
./run-e2e-tests.sh

# Run specific test suites
./test-distributed-orchestrator.sh
./test-session-manager.sh
./test-consolidate-reports.sh
./test-messaging-protocol.sh
./test-report-consolidation.sh

# Run manual tests (follow the guide)
cat manual-test-with-agents.md
```

---

## 📚 Advanced Topics

### Distributed Workflows

EM-Skill includes specialized workflows for distributed execution:

**1. Distributed Investigation Workflow**
```bash
"Workflow: em-distributed-investigation - Investigate authentication bug with distributed agents"
```
- Spawns specialist agents (backend, frontend, database)
- Parallel investigation across codebase
- Consolidated findings report

**2. Distributed Development Workflow**
```bash
"Workflow: em-distributed-development - Implement feature with distributed team"
```
- Spec creation with Tech Lead
- Parallel implementation by specialists
- Integration and testing

### Message Queue Structure

```
/tmp/claude-work-queue/
├── pending/          # New task assignments
├── processing/       # Currently being worked on
└── completed/        # Finished tasks
```

### Report Directory Structure

```
/tmp/claude-work-reports/
├── backend/          # Backend expert reports
├── frontend/         # Frontend expert reports
├── database/         # Database expert reports
└── techlead/         # Consolidated reports
```

### Custom Agent Configuration

To add a new specialist agent:

1. Create agent file: `agents/new-specialist.md`
2. Add window creation in `scripts/distributed-orchestrator.sh`
3. Add directory creation in initialization
4. Update message protocol if needed

See [Agent Template](templates/agent-invocation-template.md) for reference.

---

## Source Repositories

EM-Skill synthesizes best practices from:

1. **Product-Manager-Skills** (47 skills)
   - 3-tier architecture
   - Coaching approach
   - Interactive flows

2. **agent-skills** (20 skills)
   - Development lifecycle
   - Iron laws
   - 5-axis code review

3. **everything-claude-code** (185+ skills)
   - Multi-language support
   - Framework-specific patterns
   - MCP integrations

4. **get-shit-done** (GSD) - 24 agents, 50+ commands
   - Spec-driven development
   - Atomic commits
   - Multi-layer QA

5. **gstack** (28 skills)
   - Team-in-a-box
   - Velocity multiplier
   - Browser-in-CLI

6. **superpowers** (16 skills)
   - Iron laws
   - Subagent-driven development
   - Systematic debugging

## Contributing

When adding new skills or agents:

1. Follow the established format
2. Include YAML frontmatter
3. Add verification steps
4. Test thoroughly
5. Document clearly

## Version

Current version: 1.1.0
Last updated: 2026-04-19

**Total Counts:** Agents: 16 (8 core + 8 specialized), Workflows: 16 (8 primary + 8 team)

## License

MIT License - Feel free to use and adapt for your projects

---

## 📦 Package Summary

### What's Included

EM-Skill is a comprehensive fullstack engineering system that includes:

**Core Components:**
- ✅ 25-30 Skills - Reusable development patterns
- ✅ 16 Agents - Specialized AI assistants
- ✅ 18 Workflows - End-to-end processes
- ✅ Distributed orchestration system
- ✅ Comprehensive test suite (120+ tests)
- ✅ Bilingual documentation (English/Vietnamese)

**Distributed System:**
- ✅ Parallel agent execution
- ✅ Isolated contexts (no token overflow)
- ✅ Message queue system
- ✅ Report consolidation
- ✅ Session management

**Documentation:**
- ✅ Installation guide
- ✅ Quick start guide (5 minutes)
- ✅ Comprehensive usage guides (EN/VI)
- ✅ Architecture documentation
- ✅ Protocol references
- ✅ API documentation

**Testing:**
- ✅ Unit tests (80 tests)
- ✅ Integration tests (26 tests)
- ✅ E2E tests (8 tests, 100% pass)
- ✅ Manual testing guide

### File Organization

```
em-skill/
├── 📚 Documentation (docs/)
│   ├── guides/                    # Usage guides
│   ├── architecture/              # System architecture
│   ├── protocols/                 # Message & report formats
│   ├── skills/                    # Skills reference
│   ├── agents/                    # Agents reference
│   ├── workflows/                 # Workflows catalog
│   └── vi/                        # Vietnamese docs
├── 🔧 Scripts (scripts/)
│   ├── distributed-orchestrator.sh # Orchestration
│   ├── session-manager.sh          # Session management
│   └── consolidate-reports.sh      # Report consolidation
├── 🤖 Agents (agents/)
│   ├── Core agents (8)
│   └── Specialized agents (8)
├── 🔄 Workflows (workflows/)
│   ├── Primary workflows (8)
│   ├── Team workflows (8)
│   └── Distributed workflows (2)
├── 🧪 Tests (tests/)
│   ├── Unit tests (4 suites)
│   ├── Integration tests (2 suites)
│   └── E2E tests
└── 📋 Protocols (protocols/)
    ├── Messaging protocol
    └── Report format
```

### Quick Reference

| Task | Command | Location |
|------|---------|----------|
| **Install** | See [Installation](#-installation) | Above |
| **Quick Start** | See [Quick Start](#-quick-start) | Above |
| **Usage Guide (EN)** | [docs/guides/usage-guide.md](docs/guides/usage-guide.md) | Full guide |
| **Hướng Dẫn (VI)** | [docs/vi/huong-dan-su-dung.md](docs/vi/huong-dan-su-dung.md) | Guide tiếng Việt |
| **Bilingual Ref** | [HUONG_DAN_SU_DUNG.md](HUONG_DAN_SU_DUNG.md) | Quick reference |
| **Architecture** | [docs/architecture/distributed-system.md](docs/architecture/distributed-system.md) | System docs |
| **Testing** | [tests/README.md](tests/README.md) | Test documentation |
| **All Docs** | [docs/README.md](docs/README.md) | Documentation hub |

### Statistics

- **Total Files:** 300+ files
- **Code:** ~13,000 lines
- **Documentation:** ~5,000 lines
- **Tests:** ~3,000 lines
- **Languages:** 2 (English, Vietnamese)
- **Test Coverage:** ~92% pass rate

### Version Information

- **Current Version:** 1.1.0
- **Last Updated:** 2026-04-19
- **Status:** Production Ready ✅
- **License:** MIT

### Links

- **GitHub:** https://github.com/nv-minh/agent-team
- **Documentation:** docs/README.md
- **Issues:** https://github.com/nv-minh/agent-team/issues
- **Discussions:** https://github.com/nv-minh/agent-team/discussions

### Key Features Summary

1. **🎯 Multiple Skills** - 25-30 reusable patterns
2. **🤖 Specialized Agents** - 16 AI assistants
3. **🔄 Complete Workflows** - 18 end-to-end processes
4. **🏗️ Distributed Mode** - Parallel agent execution
5. **📚 Bilingual Docs** - English & Vietnamese
6. **🧪 Comprehensive Tests** - 120+ tests, 92% pass
7. **📖 Full Documentation** - 5,000+ lines
8. **🌍 Multi-language** - Supports 10+ programming languages
9. **🔒 Security Focus** - OWASP, STRIDE coverage
10. **⚡ Performance** - Optimized for speed

### Getting Help

- 📖 [Documentation Hub](docs/README.md)
- 🚀 [Quick Start Guide](docs/guides/getting-started.md)
- 💬 [GitHub Discussions](https://github.com/nv-minh/agent-team/discussions)
- 🐛 [Report Issues](https://github.com/nv-minh/agent-team/issues)

---

**Built with ❤️ from the best of 6 top AI agent/workflow repositories**

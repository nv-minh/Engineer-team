# EM-Team - Fullstack Engineering Agent/Skill/Workflow System

> A comprehensive system of agents, skills, and workflows for fullstack engineering. Current version: **v3.7.0** — 85 skills, 35 agents, 25 workflows.

## Overview

EM-Team provides a complete toolkit for fullstack engineering with:

**🎯 What's New in v3.7.0:**
- **GitHub Management Suite** — 4 new skills + 12 commands covering the full GitHub workflow: CI/CD setup, PR creation with templates, AI-assisted review fix, issue management, sprint planning, release management
- **Codebase Architecture Intelligence (v3.6.0)** — `codebase-architecture` skill researches modern architecture patterns, presents 2-3 best-fit options, generates 3 architecture-specific rule files
- **Japanese Outsourcing Support (v3.5.0)** — Full suite: `basic-design` (基本設計), `detailed-design` (詳細設計), `uat-process` (受け入れテスト), `progress-reporting` (進捗報告), and `japanese-outsourcing` master workflow

**📋 System Summary:**
- **85 Skills** — Foundation, development, expert groups, quality, workflow (incl. GitHub suite), additional
- **35 Agents** — Core, optional, specialized, expert (React, Vue, NestJS, DevOps, Mobile, Spring, Rust)
- **25 Workflows** — Primary, support, team, distributed, product, outsourcing

**⚡ Advanced Features:**
- **GitHub Management Suite** (v3.7.0) — CI/CD setup, PR lifecycle, issue management, sprint planning, release management
- **Codebase Architecture** — Research-driven pattern selection + rule enforcement for every project
- **Greenfield Workflow** — 12 stages from blank dir to production, with architecture intelligence in Stage 6
- **Japanese Outsourcing** — Formal 基本設計/詳細設計/受け入れテスト with sign-off gates
- **Distributed Mode** — Parallel agent execution for complex tasks
- **Browser Automation** — Headless browser for E2E testing
- **MCP Integrations** — GitHub, Context7, Exa, Memory, Playwright
- **Memory System** — Cross-session learning and knowledge building
- **Session Audit** (v3.2.0) — JSONL audit log for user-AI conversations
- **Artifact Export** (v3.2.0) — Export skill outputs as Markdown files

---

## 🚀 Core Features & Major Improvements

### ✨ TDD Auto-Retry Loop (NEW)

**Automated test failure capture and intelligent retry system**

Never manually copy-paste test errors again! The TDD Auto-Retry mechanism automatically captures test failures and feeds them back to AI agents for fixing.

**Key Capabilities:**
- 🔄 **Exponential Backoff**: 1s → 2s → 4s delays between retries (max 3)
- 📊 **Auto Error Capture**: Saves test failures as JSON with full context
- 🤖 **AI-Friendly Format**: Structured output for seamless AI consumption
- 💾 **Persistent Context**: Survives bash session restarts
- 🎯 **Exit Code Convention**: 0=success, 42=retry, 43=max exceeded

**Real-World Impact:**
- ✅ Eliminates manual error copy-paste workflow
- ✅ Reduces noise from flaky tests with exponential backoff
- ✅ Maintains TDD Iron Law (RED-GREEN-REFACTOR cycle)
- ✅ Seamless pre-commit hook integration

**Quick Start:**
```bash
# Automatic in pre-commit hook
git commit -m "feat: Add new feature"
# Tests run with auto-retry if they fail

# Manual usage
./tests/tdd-retry-wrapper.sh run "npm test" 3
./tests/tdd-context-manager.sh status
./tests/tdd-context-manager.sh format  # AI-friendly error display
```

**Documentation:** `docs/TDD-AUTO-RETRY.md`

---

### ✨ Token Summarization (NEW)

**Intelligent token management prevents Tech Lead context overflow**

Solves the distributed mode token overflow problem with Haiku-powered summarization that preserves 100% of critical information.

**Key Capabilities:**
- 🎯 **150K Token Threshold**: Triggers summarization when reports exceed limit
- 🤖 **Haiku Integration**: Uses Claude Haiku model for quality summaries
- 💯 **100% Information Preservation**: Critical/high issues completely preserved
- 🔧 **Rule-Based Fallback**: Graceful degradation when Haiku unavailable
- ⚡ **Automatic Integration**: Works seamlessly with report consolidation

**Information Preservation Strategy:**
- **100% Preserve**: Critical issues, high issues, YAML frontmatter, scorecard
- **80% Preserve**: Executive summary, medium issues, recommendations
- **30% Preserve**: Detailed analysis, code examples, verbose explanations

**Real-World Impact:**
- ✅ Prevents Tech Lead context overflow (>200K tokens)
- ✅ Reduces consolidated reports by 40-87%
- ✅ Preserves all decision-critical information
- ✅ Transparent metadata tracking

**Quick Start:**
```bash
# Token counting
./scripts/token-counter.sh estimate report.md
./scripts/token-counter.sh check report.md 150000

# Summarization
./scripts/haiku-client.sh summarize report.md report.summarized.md 80000

# Consolidation with auto-summarization
./scripts/consolidate-reports.sh consolidate
# Automatically checks tokens and summarizes if needed
```

**Documentation:** `docs/TOKEN-SUMMARIZATION.md`

---

### ✨ Knowledge Persistence (NEW)

**Project convention learning ensures consistent agent output across all tasks**

The Codebase-Mapper Agent extracts project conventions and persists them to a knowledge base that all agents automatically consume, ensuring consistent code style, naming patterns, and architectural decisions.

**Key Capabilities:**
- 🧠 **Automatic Extraction**: Learns naming conventions, code style, architectural patterns
- 💾 **Persistent Knowledge Base**: Stores in `.claude/knowledge/` directory
- 🤖 **Agent Consumption**: All agents automatically load and apply conventions
- 🎯 **Pattern Matching**: Identifies and documents recurring patterns
- 📚 **Code Examples**: Saves representative samples for reference

**What Gets Extracted:**
- **Naming Conventions**: Files, functions, variables, classes, constants
- **Code Style**: Indentation, line length, quotes, semicolons, patterns
- **Architecture Patterns**: Layered, hexagonal, microservices, etc.
- **Testing Conventions**: Test structure, naming, coverage requirements
- **Git Conventions**: Commit format, branch naming, PR guidelines
- **Error Handling**: Error classes, logging patterns, retry logic

**Knowledge Files:**
- `project-conventions.md` - All project naming and coding conventions
- `coding-style.md` - Code formatting and style guidelines
- `architecture-patterns.md` - Detected architectural patterns
- `dependencies.md` - Dependency mapping and integration points
- `examples/` - Representative code samples

**Real-World Impact:**
- ✅ All agents follow consistent naming conventions
- ✅ Code style matches project patterns automatically
- ✅ Architectural decisions are respected across agents
- ✅ New team members benefit from learned conventions
- ✅ Reduces "code style drift" over time

**Quick Start:**
```bash
# Extract and persist project knowledge
/em:codebase-mapper Analyze this project and save conventions

# View knowledge base
cat .claude/knowledge/project-conventions.md
cat .claude/knowledge/coding-style.md

# Update knowledge when conventions change
/em:codebase-mapper Update knowledge base

# Agents automatically use knowledge
/em:frontend-expert Create user profile component
# Agent automatically loads and follows project conventions
```

**Agent Integration:**
All agents automatically load knowledge when starting tasks:
1. Check `.claude/knowledge/` exists
2. Load `project-conventions.md`
3. Study code examples
4. Apply conventions to work
5. Validate output against patterns

**Documentation:** `agents/codebase-mapper.md`, `.claude/knowledge/README.md`

---

### ✨ GitHub Management Suite (NEW v3.7.0)

**Full GitHub lifecycle automation — from CI setup to release**

Stop context-switching between your terminal and GitHub. The GitHub Management Suite covers every stage of the GitHub workflow with AI-powered automation.

**4 New Skills + 12 New Commands:**

| Skill | Commands | What It Does |
|-------|----------|--------------|
| `github-cicd-setup` | `/setup-cicd` | Detect stack (Node/Python/Go/Rust/Java) → generate `.github/workflows/ci.yml` with lint, typecheck, test, build, caching |
| `github-pr-manager` | `/pr-create`, `/pr-fix`, `/pr-merge`, `/pr-review` | Auto-fill PR description from commits + template, AI-fix review comments + reply, safe merge, auto-assign reviewers |
| `github-issue-manager` | `/issue-create`, `/issue-triage`, `/issue-sprint` | Create structured issues (bug/feature/task), triage backlog with labels + priority, sprint planning with GitHub Milestones |
| `github-release-manager` | `/release` | Version bump, release notes from CHANGELOG, git tag, GitHub Release with artifacts |

**Bonus Commands:**
- `/branch-create [issue#]` — Smart branch naming `feat/123-issue-title` from issue number
- `/dep-review` — Security + license scan for new dependencies in PR
- `/stale-issues` — Auto-label + close stale issues (30d / 60d thresholds)

**Quick Start:**
```bash
# Set up CI for a new project
/em:skill:github-cicd-setup

# Create a PR with AI-generated description
/em:skill:github-pr-manager  # (PR Creation section)

# After receiving review feedback — fix all comments in one go
/em:skill:github-pr-manager  # (Review Fix section)

# Plan the next sprint from open issues
/em:skill:github-issue-manager  # (Sprint Planning section)

# Ship a release
/em:skill:github-release-manager
```

---

### ✨ Codebase Architecture Intelligence (NEW v3.6.0)

**Research-driven architecture selection + rule enforcement for every greenfield project**

Stop starting new projects with the wrong architecture. The `codebase-architecture` skill researches 6 modern patterns, presents the 2-3 best fits for *your specific project*, and then generates 3 rule files that enforce the chosen architecture throughout development — preventing architectural drift from the first commit.

**How it works:**

1. **Context Analysis** — Evaluates your domain complexity, team size, scale requirements, and tech stack
2. **Pattern Catalog** — Researches 6 modern architectures with trade-offs:
   - Layered (N-Tier) — `controllers/ → services/ → repositories/`
   - Clean / Hexagonal (Ports & Adapters) — `domain/ → application/ → infrastructure/`
   - Modular Monolith — `modules/[module]/api/` + `modules/[module]/internal/`
   - Feature-Sliced Design (FSD) — `app/ → pages/ → widgets/ → features/ → entities/ → shared/`
   - Vertical Slice — `features/[feature]/[Feature]CommandHandler.ts`
   - CQRS + Event Sourcing — `commands/ + queries/ + events/ + read-models/`
3. **Recommend & Decide** — Presents 2-3 best-fit options with project-specific file structures; user picks one
4. **Generate Rules** — Produces 3 enforcing rule files after the decision:
   - `architecture-boundaries.md` — Layer dependency rules with import examples (✅/❌)
   - `architecture-conventions.md` — File naming, folder naming, class naming per pattern
   - `architecture-patterns.md` — Code patterns + anti-patterns with real examples

**Real-World Impact:**
- ✅ No more "which architecture should I use?" paralysis on greenfield projects
- ✅ Architecture rules become part of CLAUDE.md context — every agent follows them
- ✅ Prevents the #1 cause of codebase rot: architectural drift over time
- ✅ Integrated into Greenfield workflow Stage 6 automatically

**Quick Start:**
```bash
# Standalone usage
/em:skill:codebase-architecture

# Automatic in Greenfield workflow (Stage 6)
/em:greenfield-app Build a fintech payments platform

# Stage 6 will:
# 1. Analyze your project context
# 2. Present 2-3 architecture options
# 3. Wait for your decision
# 4. Generate architecture-boundaries.md, architecture-conventions.md, architecture-patterns.md
# 5. Continue to Stage 7 with rules active
```

---

### ✨ Japanese Outsourcing Support (NEW v3.5.0)

**Complete formal deliverable suite for Japanese outsourcing projects**

Japanese outsourcing requires formal, signed-off documents at every phase — 基本設計 (Basic Design), 詳細設計 (Detailed Design), 受け入れテスト (UAT), and 進捗報告 (Weekly Progress Reports). EM-Team now includes the full suite.

**New Skills:**
| Skill | Japanese | What It Produces |
|-------|----------|-----------------|
| `basic-design` | 基本設計 | BASIC-DESIGN.md — 8-section architecture doc with sign-off gate |
| `detailed-design` | 詳細設計 | DETAILED-DESIGN.md — per-module class diagrams, pre/post-conditions |
| `uat-process` | 受け入れテスト | UAT-PLAN + UAT-TEST-CASES + UAT-EXECUTION-LOG + UAT-SIGNOFF |
| `progress-reporting` | 進捗報告 | Weekly GREEN/YELLOW/RED status report with metrics |

**New Protocols:**
- `protocols/change-management.md` — CHG-YYYYMM-NNN format, 4-tier approval routing, rollback plan
- `protocols/review-gates.md` — 5 formal phase gates (Requirements → Basic Design → Detailed Design → Code Review → UAT)

**New Templates:**
- `templates/context-artifacts/WBS.md` — 4-level WBS with effort estimates, owners, milestones
- `templates/context-artifacts/ISSUE-REGISTER.md` — Issue + Risk register with 5-Why root cause
- `templates/context-artifacts/CHANGE-LOG.md` — Consolidated CHG tracking log
- `templates/context-artifacts/ACCEPTANCE-CHECKLIST.md` — 8-section delivery checklist with dual sign-off

**New Workflow:**
```bash
# Full Japanese outsourcing lifecycle (9 stages)
/em:japanese-outsourcing

# Stage 1: Kickoff  →  Stage 2: Requirements (Gate 1)
# Stage 3: Basic Design (Gate 2a)  →  Stage 4: Detailed Design (Gate 2b)
# Stage 5: Implementation  →  Stage 6: Internal Testing (Gate 3)
# Stage 7: UAT (Gate 4)  →  Stage 8: Delivery  →  Stage 9: Support

# Individual skills
/em:skill:basic-design          # Create 基本設計 document
/em:skill:detailed-design       # Create 詳細設計 per module
/em:skill:uat-process           # Run UAT with client sign-off
/em:skill:progress-reporting    # Generate weekly 進捗報告
```

---

### 🏗️ Distributed Agent Orchestration

**Parallel agent execution for complex multi-domain tasks**

Run multiple specialist agents simultaneously in isolated tmux sessions, each with full 200K token budget.

**Key Capabilities:**
- 🚀 **Parallel Execution**: Multiple agents work simultaneously
- 🔄 **Message Queue**: YAML-based task assignments and status updates
- 📊 **Report Consolidation**: Automatic collection and merging of agent reports
- 🔍 **Full Observability**: Complete audit trail via reports

**Real-World Impact:**
- ✅ 3-5x faster than sequential agent execution
- ✅ No token context overflow with summarization
- ✅ Complete information preservation
- ✅ Scalable to unlimited agents

---

## 📦 Installation

### Prerequisites

- **Claude Code CLI** - AI coding assistant (required)
- **python3** - For config.json updates (required, usually pre-installed)
- **Bash** - Shell environment (required)

Optional: tmux (for distributed mode only)

### Install

```bash
# 1. Clone the repository
git clone https://github.com/nv-minh/agent-team.git
cd agent-team

# 2. Install (one command — handles everything)
bash install.sh
```

`install.sh` automatically:
- Copies content to `~/.claude/em-team/` (agents, workflows, skills, lib, scripts)
- Creates 149+ slash commands in `~/.claude/commands/em/`
- Copies audit/artifact libraries (`session-audit.ts`, `artifact-store.ts`)
- Cleans up orphaned entries from previous installs

### Verify

```bash
# Check commands exist (should show 149+ files)
ls ~/.claude/commands/em/*.md | wc -l

# Check content directory
ls ~/.claude/em-team/agents/ | wc -l   # 35 agents
ls ~/.claude/em-team/workflows/ | wc -l # 25 workflows

# Check lib files
ls ~/.claude/em-team/lib/*.ts           # session-audit.ts, artifact-store.ts, trace-store.ts
```

To uninstall: `bash uninstall.sh`

See [INSTALLATION.md](INSTALLATION.md) for details and troubleshooting.

### Using EM-Team

Once installed, open **any project** in Claude Code and use the commands:

**Quick Commands:**
```bash
/em:quick fix typo in README
/em:debug investigate login timeout
/em:code-review review auth module
/em:new-feature implement user authentication
```

**Skills (85):**
```bash
# Architecture & Design
/em:skill:codebase-architecture  Research patterns, get best-fit options, generate rules
/em:skill:basic-design           Create 基本設計 (Basic Design Document)
/em:skill:spec-driven-development Create spec for payment system
/em:skill:domain-modeling        Model bounded contexts and entities

# Development
/em:skill:test-driven-development Implement feature with TDD
/em:skill:systematic-debugging   Investigate login timeout bug
/em:skill:uat-process            Run UAT with sign-off for Japanese clients
/em:skill:progress-reporting     Generate weekly 進捗報告 status report

# GitHub Management (v3.7.0)
/em:skill:github-cicd-setup      Detect stack → generate .github/workflows/ci.yml
/em:skill:github-pr-manager      Create PR / fix review comments / merge
/em:skill:github-issue-manager   Create issue / triage backlog / plan sprint
/em:skill:github-release-manager Version bump → release notes → tag → GitHub Release

# Expert stacks
/em:skill:react                  React patterns and best practices
/em:skill:python-patterns        Python patterns and best practices
```

**Agents (35):**
```bash
/em:planner Create implementation plan
/em:architect Architecture & technical design
/em:backend-expert Backend API, database, performance
/em:frontend-expert React, Next.js, UI/UX
/em:code-reviewer 5-axis or 9-axis code review
/em:security OWASP security audit
/em:react-expert React/Next.js expert
```

**Workflows (25):**
```bash
/em:new-feature          Implement feature from idea to production
/em:greenfield-app       Build new app from scratch (12 stages)
/em:bug-fix              Fix bugs systematically
/em:refactor             Improve code quality
/em:security-audit       Security assessment
/em:team                 Full team review coordination
/em:japanese-outsourcing End-to-end Japanese outsourcing workflow
```

### Troubleshooting

| Issue | Fix |
|-------|-----|
| Skills not appearing | Restart Claude Code after install. Check: `ls ~/.claude/skills/em:*/SKILL.md` |
| Broken symlinks | Run `bash install.sh` again — it auto-fixes broken links and cleans orphans |
| config.json invalid | `jq . ~/.claude/config.json` — if broken, `rm ~/.claude/config.json && bash install.sh` |
| Permission denied | `chmod +x install.sh && bash install.sh` |
| Old flat em-* files in ~/.claude/skills/ | These are from an older install — `bash install.sh` cleans them automatically |

### Update EM-Team

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
cd /path/to/EM-Team
bash uninstall.sh
```

Removes all EM-Team symlinks and config entries. Preserves other settings and non-EM skills.

---

## 🚀 Quick Start

Get started with EM-Team in 5 minutes!

### First Steps

#### 1. Discovery & Market Intelligence (NEW in v1.2.0)

**Validate ideas before building (optional but recommended):**

```bash
# Validate product idea (30 minutes)
/office-hours I have an idea for a AI-powered code reviewer

# Run discovery workflow (2-4 weeks)
/em:discovery-process We need to improve our checkout conversion

# Capture learnings from completed projects
/em:learn We just completed a major refactoring project

# Coordinate multi-phase reviews
/em:autoplan Coordinate reviews for our new authentication feature
```

**Or use other discovery skills:**
```bash
/jobs-to-be-done Understand customer motivation
/lean-ux-canvas Frame business problem properly
/opportunity-solution-tree Explore solution options
/pol-probe Design lightweight validation experiment
```

#### 2. Use Agents for Specialized Tasks

**Call specialist AI agents:**

```bash
# Planning
/em:planner Create implementation plan for user authentication

# Backend
/em:backend-expert Review API performance

# Frontend
/em:frontend-expert Review React components

# Database
/em:database-expert Optimize database queries
```

#### 3. Use Core Workflows

**End-to-end workflows for everyday tasks:**

```bash
# Implement feature
/em:new-feature Implement user authentication from idea to production

# Fix bugs
/em:bug-fix Fix login timeout systematically

# Improve quality
/em:refactor Improve code quality in this module
```

#### 4. Try Distributed Mode (Optional)

For complex tasks requiring multiple specialist agents:

```bash
# 1. Start distributed orchestration
./scripts/distributed-orchestrator.sh start

# 2. Attach to orchestrator window
tmux attach -t claude-work:orchestrator

# 3. Trigger distributed investigation
/em:distributed Investigate authentication bug across entire stack
```

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

## 📖 EM:* Commands Reference

### What are EM:* Commands?

**EM:*** commands** are 17 quick-access shortcuts for the most commonly used agents and workflows. They work from **ANY repository** once installed.

### Quick Access Commands

**Agent Commands (11 commands) - Call Specialists:**
```bash
/em:agent-planner              - Create implementation plans
/em:agent-architect            - Architecture & technical design
/em:agent-backend-expert       - Backend specialist (API, DB, performance)
/em:agent-frontend-expert      - Frontend specialist (React, Next.js, UI/UX)
/em:agent-database-expert      - Database specialist (schema, queries)
/em:agent-code-reviewer        - 5-axis code review
/em:agent-debugger             - Systematic debugging
/em:agent-security-auditor     - OWASP security audit
/em:agent-test-engineer        - Test strategy & generation
/em:agent-performance-auditor  - Benchmarking & optimization
/em:agent-researcher           - Technical research & exploration
```

**Workflows (6 commands):**
```bash
/em:new-feature   - Implement feature from idea to production
/em:bug-fix       - Fix bugs systematically
/em:refactor      - Improve code quality
/em:distributed   - Parallel distributed investigation
/em:team          - Full team review coordination
/em:incident      - Production incident response
```

**Specialized Workflows (12 commands with wl- prefix):**
```bash
/em:wl-architecture-review    - Architecture review (Architect + Staff)
/em:wl-design-review           - UI/UX design review (Frontend + Product)
/em:wl-code-review-9axis       - Deep 9-axis code review
/em:wl-database-review         - Database schema & query review
/em:wl-product-review          - Product/spec review (Product + Architect)
/em:wl-security-review         - Advanced security (OWASP + STRIDE)
/em:wl-project-setup           - Initialize new projects
/em:wl-documentation           - Generate/update documentation
/em:wl-deployment              - Deploy and monitor features
/em:wl-retro                   - Retrospective and improvement
/em:wl-distributed-dev         - Parallel distributed development
/em:wl-security-audit          - Security audit (OWASP Top 10)
```

### Usage Examples

**Discovery & Market Intelligence Commands (NEW):**
```bash
Use the /office-hours skill to validate product ideas
Use the /jobs-to-be-done skill to understand customer motivation
Use the /lean-ux-canvas skill to frame business problems
Use the /opportunity-solution-tree skill to explore solutions
Use the /pol-probe skill to design validation experiments
Use the /em:discovery-process skill to run complete discovery
Use the /em:learn skill to capture project learnings
Use the /em:autoplan skill to coordinate reviews
Use the /em:market-intelligence skill to analyze markets
```

**Agent Commands:**
```bash
Use the em:agent-planner skill to create implementation plan for JWT auth
Use the em:agent-backend-expert skill to optimize database queries
Use the em:agent-frontend-expert skill to review React components
```

**Core Workflow Commands:**
```bash
Use the em:new-feature skill to implement user authentication
Use the em:bug-fix skill to fix login timeout
Use the em:refactor skill to improve code quality
```

**Specialized Workflow Commands:**
```bash
Use the em:wl-architecture-review skill to review architecture
Use the em:wl-code-review-9axis skill to conduct deep code review
Use the em:wl-security-review skill to conduct threat modeling
```

### When to use EM:* vs Full Commands?

**Use EM:* commands for:**
- Quick access to common tasks
- Everyday development workflow
- When you know which agent/workflow you need

**Use full commands for:**
- Accessing all 81 skills (including architecture, design, Japanese outsourcing skills)
- Using specific agents not in EM:* shortcut list
- Discovery & market intelligence tasks
- When you need more control

## 📖 Basic Usage

### Discovery & Market Intelligence (NEW in v1.2.0)

Validate product ideas and run discovery before building:

```bash
# Validate product idea with YC framework
/office-hours I have an idea for a AI-powered code reviewer for startups
# → 6 forcing questions, scoring system, go/no-go decision

# Run complete discovery workflow
/em:discovery-process We need to improve our checkout conversion rate
# → 6 stages: Frame → Research → Synthesize → Solutions → Decide (2-4 weeks)

# Capture project learnings
/em:learn We just completed a major refactoring project
# → Patterns, pitfalls, preferences, architecture decisions

# Coordinate multi-phase reviews
/em:autoplan Coordinate reviews for our new authentication feature
# → CEO, Design, Engineering, DX reviews with auto-decision framework

# Market analysis
/em:market-intelligence Analyze the CRM market for SMB
# → Market sizing, competitive analysis, opportunity detection
```

### Using Skills (Foundation & Development)

Invoke skills directly by name:

```bash
# Discovery Skills
/jobs-to-be-done Understand customer motivation for our product
/lean-ux-canvas Frame this business problem properly
/opportunity-solution-tree Explore solution options for this problem
/pol-probe Design a lightweight validation experiment

# Development Skills
/em:skill:brainstorming Explore ideas for this feature idea
/em:skill:spec-driven-development Create a spec for user authentication
/em:skill:systematic-debugging Investigate this bug systematically
/em:skill:test-driven-development Implement this feature with TDD
/em:skill:frontend-patterns Refactor these React components
/em:skill:backend-patterns Optimize this API endpoint
/em:skill:security-hardening Apply OWASP Top 10 security
/em:skill:code-simplification Reduce complexity in this code
```

### Using Agents

Dispatch agents for specialized tasks:

```bash
# Discovery & Learning Agents
/em:market-intelligence Analyze market opportunity
/em:learn Capture project learnings
/em:autoplan Coordinate multi-phase reviews

# Core Development Agents
/em:planner Create implementation plan for user authentication feature
/em:executor Execute plan with atomic commits
/em:code-reviewer Review the changes in this PR
/em:debugger Investigate this bug systematically
/em:test-engineer Generate test strategy for this feature
/em:security-auditor Audit this code for security issues

# Expert Agents
/em:backend-expert Review API performance and optimize queries
/em:frontend-expert Review React components and UI/UX
/em:database-expert Optimize database schema and queries
/em:architect Design architecture for this system
/em:product-manager Gather requirements for this feature
```

### Using Workflows

Run end-to-end workflows:

```bash
# Discovery & Feature Workflows
/em:discovery-process Take this problem through complete discovery
/em:new-feature Take user authentication from idea to production
/em:market-driven-feature Launch this market-driven feature

# Core Workflows
/em:bug-fix Fix the login bug systematically
/em:refactor Improve code quality in this module
/em:security-audit Audit the codebase for security issues

# Team Review Workflows
/em:team-review Coordinate full team review
/em:architecture-review Architecture review with team
/em:design-review UI/UX design review
/em:code-review-9axis Deep 9-axis code review
/em:distributed-investigation Parallel investigation across services
```

## Project Structure

```
em-team/
├── skills/                  # 81 skills organized in 20 categories
│   ├── foundation/          # 10 core foundational skills
│   │   (alignment-session, spec-driven-development, brainstorming,
│   │    context-engineering, writing-plans, systematic-debugging,
│   │    domain-modeling, project-dna, basic-design, detailed-design)
│   ├── development/         # 12 methodology skills
│   │   (TDD, incremental, subagent, source-driven, security-hardening,
│   │    architecture-zoom-out, architecture-improvement, issue-generator,
│   │    prd-generator, diagram, figma-design, codebase-architecture)
│   ├── expert-react/        # 4 React skills
│   ├── expert-vue/          # 3 Vue skills
│   ├── expert-go/           # 1 Go skill
│   ├── expert-nest/         # 1 NestJS skill
│   ├── expert-python/       # 3 Python skills
│   ├── expert-database/     # 3 Database skills
│   ├── expert-devops/       # 6 DevOps skills
│   ├── expert-mobile/       # 4 Mobile skills
│   ├── expert-spring/       # 1 Spring skill
│   ├── expert-frontend/     # 1 Frontend skill
│   ├── expert-backend/      # 2 Backend skills
│   ├── expert-rust/         # 1 Rust skill
│   ├── expert-typescript/   # 1 TypeScript skill
│   ├── drawio/              # 2 Drawio skills
│   ├── tauri/               # 1 Tauri skill
│   ├── quality/             # 13 quality assurance skills (+uat-process)
│   ├── workflow/            # 7 workflow and automation skills (+progress-reporting)
│   └── additional/          # 5 product & discovery skills
├── agents/                  # 35 specialized agents
│   ├── core (8): planner, executor, code-reviewer, debugger,
│   │   test-engineer, security-reviewer, ui-auditor, verifier
│   ├── optional (4): researcher, codebase-mapper,
│   │   integration-checker, performance-auditor
│   ├── specialized (9): team-lead, architect, frontend-expert,
│   │   backend-expert, database-expert, product-manager,
│   │   security-reviewer, staff-engineer, iron-law-enforcer
│   ├── v2.0 (7): market-intelligence, learn, autoplan,
│   │   techlead-orchestrator, design-reviewer, devex-reviewer,
│   │   iron-law-enforcer
│   └── expert (7): react-expert, vue-expert, nestjs-expert,
│       devops-expert, mobile-expert, spring-expert, rust-expert
├── workflows/               # 25 end-to-end workflows
│   ├── primary (5): new-feature, greenfield-app, bug-fix,
│   │   refactoring, security-audit
│   ├── support (6): project-setup, documentation, deployment,
│   │   retro, ship-workflow, canary-monitoring
│   ├── master: six-phase-lifecycle
│   ├── team (8): team-review, architecture-review, design-review,
│   │   code-review-9axis, database-review, product-review,
│   │   security-review-advanced, incident-response
│   ├── distributed (2): distributed-investigation, distributed-development
│   ├── product (2): discovery-process, market-driven-feature
│   └── outsourcing (1): japanese-outsourcing
├── preambles/               # Shared initialization
│   ├── ethos.md             # Builder philosophy (Boil the Lake, Iron Laws)
│   ├── skill-preamble.md    # Standard skill initialization protocol
│   └── agent-preamble.md    # Standard agent behavior rules
├── protocols/               # Communication standards
│   ├── writing-style.md     # Active voice, severity levels, report structure
│   ├── delegation-protocol.md
│   ├── change-management.md # CR format, 4-tier approval routing (v3.5.0)
│   └── review-gates.md      # 5 formal phase gates with sign-off (v3.5.0)
├── references/              # Shared reference docs
├── templates/               # Reusable templates
│   ├── context-artifacts/   # PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md,
│   │                        # WBS.md, ISSUE-REGISTER.md, CHANGE-LOG.md,
│   │                        # ACCEPTANCE-CHECKLIST.md (v3.5.0)
│   └── project-dna/         # Generated agent guidance (CLAUDE.md, rules, traceability)
│       └── rules/           # architecture-boundaries, architecture-conventions,
│                            # architecture-patterns, design-system templates
├── distributed/             # Distributed orchestration system
├── scripts/                 # Core orchestration scripts
├── hooks/                   # Automation hooks
├── commands/                # CLI commands
├── docs/                    # Documentation (EN + VI)
└── CLAUDE.md                # Main configuration
```

---

## 🏗️ Architecture

### Distributed Agent Orchestration System

EM-Team includes a **distributed agent orchestration system** that solves token context overflow by running agents in separate tmux sessions.

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

**4. Report System with Token Summarization**
- `report-format.md` - Standard report structure with summarization metadata
- `consolidate-reports.sh` - Collects, merges, and summarizes reports
- `token-counter.sh` - Estimates token counts using tiktoken
- `haiku-client.sh` - Intelligent summarization using Haiku model
- **Automatic Summarization**: Reports >150K tokens → Summarized to ~80K tokens
- **100% Information Preservation**: Critical/high issues completely preserved
- YAML frontmatter with findings, recommendations, next steps
- Summarization metadata: `summarized`, `original_token_count`, `summarized_token_count`

**5. Quality & Testing Infrastructure**
- `tdd-retry-wrapper.sh` - Auto-retry mechanism for TDD with exponential backoff
- `tdd-context-manager.sh` - Error capture and AI-friendly formatting
- `pre-commit hook` - Integrated TDD auto-retry into git workflow
- **Exponential Backoff**: 1s → 2s → 4s delays between retries (max 3)
- **Auto Error Capture**: JSON context with full test output
- **Exit Code Convention**: 0=success, 42=retry, 43=max exceeded

**5. Communication Flow**

```
1. Orchestrator receives task
2. Orchestrator creates task assignments
3. Task assignments placed in queue/
4. Specialist agents pick up tasks
5. Agents generate reports in shared/
6. Token check: Reports >150K? → Summarize using Haiku
7. Reports consolidated into summary
8. Token check: Consolidated >150K? → Summarize
9. Consolidated report returned to user (within 200K budget)
```

**6. Quality Gates (NEW)**

```
Development Phase:
- Write code → TDD Auto-Retry captures failures
- Test fails → Auto-retry with exponential backoff
- Error context saved → AI reads and fixes
- Auto-re-test → Success or manual intervention

Distributed Mode:
- Agent reports generated → Token counting
- Exceeds 150K? → Haiku summarization
- 100% critical info preserved → Tech Lead receives summary
- Within 200K budget → No context overflow
```

#### Benefits

✅ **Parallel Execution** - Multiple agents work simultaneously
✅ **Isolated Context** - Each agent has full 200K token budget
✅ **No Information Loss** - Complete context preservation with intelligent summarization
✅ **Scalable** - Add more agents without token issues (summarization prevents overflow)
✅ **Observable** - Full audit trail via reports with summarization metadata
✅ **Automated TDD** - Auto-retry mechanism eliminates manual error copy-paste
✅ **Token Efficient** - Haiku-based summarization reduces reports by 40-87%
✅ **Quality Assured** - 100% preservation of critical/high issues in summaries

---

## Skills

### Foundation Skills (10 skills)

1. **alignment-session** - Pre-coding human-AI alignment
2. **spec-driven-development** - Write specs before coding
3. **brainstorming** - Explore ideas into designs
4. **context-engineering** - Optimize agent context setup
5. **writing-plans** - Break work into bite-sized tasks
6. **systematic-debugging** - 4-phase debugging methodology
7. **domain-modeling** - Bounded contexts, entities, ubiquitous language
8. **project-dna** - Crystallize decisions into CLAUDE.md + 8 rule files
9. **basic-design** - Formal 基本設計 document with sign-off gate (v3.5.0)
10. **detailed-design** - Formal 詳細設計 per-module with sign-off gate (v3.5.0)

### Development Skills (12 skills)

11. **test-driven-development** - TDD RED-GREEN-REFACTOR
12. **incremental-implementation** - Vertical slice development
13. **subagent-driven-development** - Fresh context per task
14. **source-driven-development** - Code from official docs
15. **security-hardening** - OWASP Top 10 security
16. **architecture-zoom-out** - Higher-level code perspective
17. **architecture-improvement** - Systematic module deepening
18. **issue-generator** - Plans to structured vertical-slice issues
19. **prd-generator** - Ideas to structured PRD documents
20. **diagram** - Excalidraw, Mermaid, SVG diagram generation
21. **figma-design** - Figma-to-code conversion with MCP server
22. **codebase-architecture** - Research patterns, recommend 2-3 options, generate rules (v3.6.0)

### Quality Skills (13 skills)

23. **code-review** - 5-axis review framework
24. **code-simplification** - Reduce complexity
25. **browser-testing** - DevTools MCP integration
26. **performance-optimization** - Measure-first optimization
27. **e2e-testing** - Playwright patterns
28. **security-audit** - Vulnerability assessment
29. **api-testing** - Integration testing
30. **security-common** - OWASP reference and security checklist
31. **ux-audit** - Behavioral UX audit with scored dimensions
32. **plan-tune** - Learn and tune output preferences
33. **flow-discovery** - Discovery flow pattern identification
34. **test-generation** - Automated test generation strategies
35. **uat-process** - 受け入れテスト with UAT plan, execution log, client sign-off (v3.5.0)

### Workflow Skills (7 skills)

36. **git-workflow** - Atomic commits
37. **ci-cd-automation** - Feature flags, quality gates
38. **documentation** - ADRs, API docs
39. **finishing-branch** - Merge/PR decisions
40. **deprecation-migration** - Code-as-liability mindset
41. **style-switcher** - 13 personality styles + 3 density modes
42. **progress-reporting** - Weekly 進捗報告 with GREEN/YELLOW/RED status (v3.5.0)

### Additional Skills (5 skills)

43. **jobs-to-be-done** - JTBD framework for understanding user needs
44. **lean-ux-canvas** - Lean UX hypothesis testing
45. **opportunity-solution-tree** - Product opportunity mapping
46. **pol-probe** - Product opportunity probe
47. **office-hours** - YC-style brainstorming and idea validation

## Communication Styles (NEW)

EM-Team includes a unified communication control system with 13 personality styles and 3 density modes. Personality (tone) and density (verbosity) are independent axes.

### Personality Styles

**Productivity:**
| Style | Description | Token Savings |
|---|---|---|
| 🪖 Tactical | Direct, no preamble. `[problem] → [cause] → [fix]` | 65-75% |
| 🪨 Raw | Fragments, no filler, no articles | 65-75% |
| 🔍 Reality Check | Honest evaluation: works → risk → verdict | 60-70% |
| 📋 git log | Imperative verbs, 72 chars max per line | 50-65% |
| ❓ Socratic | Asks questions, never gives answers directly | 50-70% |
| 📌 BLUF | Bottom Line Up Front: conclusion first | 20-35% |

**Fun:**
| Style | Description | Token Impact |
|---|---|---|
| 🧙 Inverted | Yoda-style inverted syntax | ~same |
| 🏴‍☠️ Dramatic | Pirate nautical metaphors | +5-15% |
| 💾 80s Hacker | 80s terminal, all caps, STATUS: labels | +5-15% |
| 👨 Dad Joke | Technical explanation + terrible pun | +10-20% |

**Deep Understanding:**
| Style | Description | Token Impact |
|---|---|---|
| 🦆 Rubber Duck | Zero jargon, one concept at a time | 0-+20% |
| 🔬 Teacher | Feynman technique, explain to a 12-year-old | +20-40% |
| 🧱 First Principles | Break to fundamentals, no assumptions | +20-30% |

### Density Modes

| Mode | Trigger | Output |
|---|---|---|
| **STANDARD** | `/standard` | Full reports with coaching, before/after code |
| **COMPACT** | `/compact` | Bullet points, code fixes only, no coaching |
| **TERSE** | `/terse` | Single-line status, diffs only |

### Usage

```bash
# Show personality menu (13 styles + 3 density modes)
/em:skill:style-switcher

# Switch personality directly
/em:skill:style-switcher tactical        # Direct, no-nonsense debugging
/em:skill:style-switcher teacher         # Feynman technique explanations
/em:skill:style-switcher reality-check   # Honest evaluation of your idea

# Switch density independently
/compact               # Bullet-point output
/terse                 # Single-line status
/standard              # Full detailed reports

# Combine personality + density
# (set each independently, they don't affect each other)
/em:skill:style-switcher raw             # Set personality to Raw
/compact               # Set density to COMPACT

# Terminal CLI modifier (strip all markdown)
/em:skill:style-switcher tactical + terminal CLI
```

### When to Use Which Style

| Scenario | Personality | Density |
|---|---|---|
| Debugging CI failure | Tactical | TERSE |
| Teaching a junior | Teacher | STANDARD |
| Rapid coding session | Raw | COMPACT |
| Evaluating feature idea | Reality Check | STANDARD |
| Architecture decision | First Principles | COMPACT |
| Quick code review | BLUF | COMPACT |

---

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

### Specialized Agents (9 agents)

13. **team-lead** - Team review orchestrator (trigger: `em-agent:team-lead`)
14. **architect** - Architecture & technical design (trigger: `em-agent:architect`)
15. **frontend-expert** - React/Next.js, UI/UX, performance (trigger: `em-agent:frontend-expert`)
16. **backend-expert** - API design, performance, auth, error handling (trigger: `em-agent:backend-expert`)
17. **senior-code-reviewer** - 9-axis deep code review (trigger: `em-agent:senior-code-reviewer`)
18. **database-expert** - Schema, queries, fintech patterns (trigger: `em-agent:database-expert`)
19. **product-manager** - Requirements, GAP analysis, market fit (trigger: `em-agent:product-manager`)
20. **security-reviewer** - OWASP Top 10, STRIDE, blocking authority (trigger: `em-agent:security-reviewer`)
21. **staff-engineer** - Root cause analysis, cross-service impact (trigger: `em-agent:staff-engineer`)

### New Agents (v2.0+)

22. **market-intelligence** - Market analysis, competitive intelligence (trigger: `em-agent:market-intelligence`)
23. **learn** - Knowledge management and cross-session learning
24. **autoplan** - Multi-phase review pipeline orchestrator
25. **techlead-orchestrator** - Distributed team coordination
26. **design-reviewer** - Visual design review with 6-pillar UI audit (trigger: `em-agent:design-reviewer`)
27. **devex-reviewer** - Developer experience audit and TTHW measurement (trigger: `em-agent:devex-reviewer`)
28. **iron-law-enforcer** - Gate enforcement for Iron Law compliance (trigger: `em-agent:iron-law-enforcer`)

### Expert Agents (v3.0)

29. **react-expert** - React/Next.js, hooks, state management (trigger: `em-agent:react-expert`)
30. **vue-expert** - Vue 3, Composition API, Pinia, Vue Router (trigger: `em-agent:vue-expert`)
31. **nestjs-expert** - NestJS, TypeScript backend, GraphQL, microservices (trigger: `em-agent:nestjs-expert`)
32. **devops-expert** - Docker, Kubernetes, Terraform, CI/CD (trigger: `em-agent:devops-expert`)
33. **mobile-expert** - Flutter, React Native, Android, iOS (trigger: `em-agent:mobile-expert`)
34. **spring-expert** - Spring Boot, JPA, security, microservices (trigger: `em-agent:spring-expert`)
35. **rust-expert** - Rust systems, ownership, async tokio (trigger: `em-agent:rust-expert`)

## Workflows

### Primary Workflows (5 workflows)

1. **new-feature** - From idea to production
2. **greenfield-app** - Blank directory to shipped app (12 stages, architecture intelligence in Stage 6)
3. **bug-fix** - Investigate and fix bugs
4. **refactoring** - Improve code quality
5. **security-audit** - Security assessment

### Support Workflows (6 workflows)

6. **project-setup** - Initialize new projects
7. **documentation** - Generate and update docs
8. **deployment** - Deploy and monitor
9. **retro** - Learn and improve
10. **ship-workflow** - Version bump, changelog, PR creation
11. **canary-monitoring** - Post-deploy health monitoring

### Master Workflow

12. **six-phase-lifecycle** - DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP (all workflows inherit this)

### Team Workflows (8 workflows)

13. **team-review** - Full team review orchestrated by Team Lead
14. **architecture-review** - Architecture review with Architect & Staff Engineer
15. **design-review** - UI/UX design review with Frontend Expert & Product Manager
16. **code-review-9axis** - Deep 9-axis code review with Senior Code Reviewer & Security
17. **database-review** - Database schema & query review with Database Expert & Architect
18. **product-review** - Product/spec review with Product Manager & Architect
19. **security-review-advanced** - Advanced security (OWASP + STRIDE) with Security & Staff
20. **incident-response** - Production incident handling with Staff Engineer & Security

### Outsourcing Workflows (1 workflow)

21. **japanese-outsourcing** - 9-stage formal workflow for Japanese clients: Kickoff → Requirements (Gate 1) → 基本設計 (Gate 2a) → 詳細設計 (Gate 2b) → Implementation → Internal Testing (Gate 3) → UAT (Gate 4) → Delivery → Support

## Special Features

### ✅ TDD Auto-Retry Loop (NEW)

**Automatic test failure capture and intelligent retry mechanism**

- **Exponential Backoff**: 1s → 2s → 4s delays between retries
- **Max 3 Retries**: Prevents infinite loops while allowing recovery
- **Auto Error Capture**: Saves test failures as JSON with full context
- **AI-Friendly Format**: Structured output for AI agent consumption
- **Exit Code Convention**: 0=success, 42=retry, 43=max exceeded
- **Persistent Context**: Survives bash session restarts

**Key Benefits:**
- ✅ No manual copy-paste of test errors
- ✅ Reduced noise from flaky tests
- ✅ Maintains TDD Iron Law (RED-GREEN-REFACTOR)
- ✅ Seamless pre-commit hook integration

**Usage:**
```bash
# Automatic in pre-commit hook
git commit -m "feat: Add new feature"
# Tests run with auto-retry if they fail

# Manual usage
./tests/tdd-retry-wrapper.sh run "npm test" 3
./tests/tdd-context-manager.sh status
./tests/tdd-context-manager.sh format  # AI-friendly error display
```

**Documentation:** `docs/TDD-AUTO-RETRY.md`

---

### ✅ Token Summarization (NEW)

**Intelligent token management to prevent Tech Lead context overflow**

- **150K Token Threshold**: Triggers summarization when reports exceed limit
- **Haiku Integration**: Uses Claude Haiku model for quality summaries
- **100% Information Preservation**: Critical/high issues completely preserved
- **Rule-Based Fallback**: Graceful degradation when Haiku unavailable
- **Automatic Integration**: Works seamlessly with report consolidation

**Key Benefits:**
- ✅ Prevents Tech Lead context overflow (>200K tokens)
- ✅ Preserves all decision-critical information
- ✅ Reduces consolidated reports by 40-87%
- ✅ Transparent metadata tracking

**Information Preservation:**
- **100% Preserve**: Critical issues, high issues, YAML frontmatter, scorecard
- **80% Preserve**: Executive summary, medium issues, recommendations
- **30% Preserve**: Detailed analysis, code examples, verbose explanations

**Usage:**
```bash
# Token counting
./scripts/token-counter.sh estimate report.md
./scripts/token-counter.sh check report.md 150000

# Summarization
./scripts/haiku-client.sh summarize report.md report.summarized.md 80000

# Consolidation with auto-summarization
./scripts/consolidate-reports.sh consolidate
# Automatically checks tokens and summarizes if needed
```

**Documentation:** `docs/TOKEN-SUMMARIZATION.md`

---

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

### ✅ Session Audit Logging (NEW v3.2.0)

Append-only JSONL audit log tracking user-AI conversations and skill invocations.

- **Toggle**: `EM_TEAM_SESSION_AUDIT` env var in `.claude/settings.local.json`
- **Log location**: `.em-team/logs/audit-YYYY-MM-DD.jsonl` (gitignored)
- **Tracks**: user messages, AI responses, skill start/end, artifact exports
- **CLI**: `bash scripts/session-audit.sh {status|stats|recent|by-skill|rotate}`

```bash
# Check audit status
bash scripts/session-audit.sh status

# View recent entries
bash scripts/session-audit.sh recent 7

# View statistics
bash scripts/session-audit.sh stats

# Rotate old logs (keep 30 days)
bash scripts/session-audit.sh rotate 30
```

### ✅ Skill Artifact Export (NEW v3.2.0)

Export skill outputs (specs, plans, reviews, brainstorm) as Markdown files to current working directory.

- **Toggle**: `EM_TEAM_ARTIFACT_EXPORT` env var in `.claude/settings.local.json`
- **Output dirs**: `brainstorm/`, `specs/`, `plans/`, `reviews/`, `architecture/`
- **Format**: Markdown with YAML frontmatter (skill name, date, session)
- **CLI**: `bash scripts/artifact-register.sh {list|stats|recent|by-skill|clean}`

```bash
# List all exported artifacts
bash scripts/artifact-register.sh list

# Show statistics
bash scripts/artifact-register.sh stats

# Find artifacts by skill
bash scripts/artifact-register.sh by-skill brainstorming

# Clean artifacts older than 90 days
bash scripts/artifact-register.sh clean 90
```

## Iron Laws

1. **TDD Iron Law**: NO PRODUCTION CODE WITHOUT FAILING TEST
2. **Debugging Iron Law**: NO FIXES WITHOUT ROOT CAUSE
3. **Review Iron Law**: NO MERGE WITHOUT REVIEW
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

### Standard Agent/Skill/Workflow Usage (Updated v1.2.0)

#### Option 1: Discovery-First Approach (Recommended)

**Validate ideas before building:**

```bash
# Step 1: Validate product idea
/office-hours I have an idea for a AI-powered code reviewer for startups

# Step 2: Run discovery (if score 8-10 or 5-7)
/em:discovery-process We need to improve our checkout conversion rate

# Step 3: Coordinate reviews
/em:autoplan Coordinate reviews for our new authentication feature

# Step 4: Create implementation plan
/em:planner Create plan for authentication feature

# Step 5: Execute
/em:executor Execute plan with atomic commits

# Step 6: Capture learnings
/em:learn Capture patterns, pitfalls, and ADRs from this project
```

#### Option 2: Direct Development

**Skip discovery, build directly:**

### Example 1: Building a New Feature

```bash
# Step 1: Brainstorm the feature
/em:skill:brainstorming Explore a user authentication feature

# Step 2: Create a spec
/em:skill:spec-driven-development Create a spec for authentication

# Step 3: Write a plan
/em:skill:writing-plans Break down the implementation

# Step 4: Execute the plan
/subagent-driven-development Implement the plan

# Step 5: Review the code
/em:code-reviewer Review the authentication implementation

# Step 6: Deploy
/em:deployment Deploy the authentication feature
```

### Example 2: Fixing a Bug

```bash
# Step 1: Debug systematically
/em:skill:systematic-debugging Investigate the login bug

# Step 2: Fix the root cause
# (After root cause is identified)
/em:skill:test-driven-development Fix the bug

# Step 3: Verify the fix
/em:skill:api-testing Verify the login endpoint works

# Step 4: Code review
/em:code-reviewer Review the bug fix
```

### Example 3: Distributed Investigation (Complex Tasks)

For complex tasks requiring multiple specialist agents:

```bash
# Start distributed orchestration
cd /path/to/em:team
./scripts/distributed-orchestrator.sh start

# Attach to orchestrator window
tmux attach -t claude-work:orchestrator

# Trigger distributed investigation
/em:distributed Investigate authentication bug across entire stack

# View consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# Stop when done
./scripts/distributed-orchestrator.sh stop
```

# This creates a tmux session with multiple agent windows:
# - orchestrator (Tech Lead)
# - backend (Backend Expert)
# - frontend (Frontend Expert)
# - database (Database Expert)

# Attach to orchestrator window
tmux attach -t claude-work:orchestrator

# Trigger investigation
/em:techlead-orchestrator Investigate authentication bug across the entire stack

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

EM-Team includes specialized workflows for distributed execution:

**1. Distributed Investigation Workflow**
```bash
/em:distributed-investigation Investigate authentication bug with distributed agents
```
- Spawns specialist agents (backend, frontend, database)
- Parallel investigation across codebase
- Consolidated findings report

**2. Distributed Development Workflow**
```bash
/em:distributed-development Implement feature with distributed team
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

EM-Team synthesizes best practices from:

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

Current version: **3.6.0**
Last updated: 2026-05-22

**Changes in v3.6.0:**
- `codebase-architecture` skill — Research 6 modern patterns, present 2-3 best-fit options, generate 3 architecture rule files
- Greenfield workflow Stage 6 upgraded with architecture research + decision + rule generation
- New architecture rule templates: `architecture-boundaries`, `architecture-conventions`, `architecture-patterns`
- `design-system.template.md` added to project-dna templates (fills gap required by project-dna skill)

**Changes in v3.5.0:**
- Japanese outsourcing support: `basic-design` (基本設計), `detailed-design` (詳細設計), `uat-process` (受け入れテスト), `progress-reporting` (進捗報告)
- New protocols: `change-management.md` (CR format, 4-tier approval), `review-gates.md` (5 phase gates)
- New templates: `WBS.md`, `ISSUE-REGISTER.md`, `CHANGE-LOG.md`, `ACCEPTANCE-CHECKLIST.md`
- New `japanese-outsourcing` master workflow (9 stages)

**Changes in v3.4.0:**
- UI/UX integration into greenfield workflow: Stage 5 with frontend-expert producing UI-SPEC.md
- `project-dna` skill generates design-system.md rule and UI-to-code map
- `ux-audit` + `flow-discovery` in Validation stage; `ui-auditor` + `design-reviewer` in Review stage

**Changes in v3.3.0:**
- `EM_TEAM_ATOMIC_COMMITS` toggle to disable atomic commits when needed

**Changes in v3.2.0:**
- Session audit logging — JSONL append-only log (`.em-team/logs/`)
- Skill artifact export — Export specs, plans, reviews as Markdown files
- New CLI scripts: `scripts/session-audit.sh`, `scripts/artifact-register.sh`
- New libraries: `.claude/lib/session-audit.ts`, `.claude/lib/artifact-store.ts`

**Changes in v3.0-3.1:**
- Greenfield app workflow, domain-modeling skill, agent consolidation
- Expert group restructuring: 15 expert skill groups, 7 new expert agents

**Total Counts:**
- **Skills**: 81 (10 foundation + 12 development + 31 expert + 2 drawio + 1 tauri + 13 quality + 7 workflow + 5 additional)
- **Agents**: 35 (8 core + 4 optional + 9 specialized + 7 v2.0+ + 7 expert)
- **Workflows**: 25 (5 primary + 6 support + 8 team + 2 distributed + 2 product + 1 master + 1 outsourcing)
- **Personality Styles**: 13 + 3 density modes

## License

MIT License - Feel free to use and adapt for your projects

---

## 📦 Package Summary

### What's Included

EM-Team is a comprehensive fullstack engineering system that includes:

**Core Components:**
- ✅ 81 Skills - Reusable development patterns across 20 categories
- ✅ 35 Agents - Specialized AI assistants
- ✅ 25 Workflows - End-to-end processes
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
em-team/
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
│   ├── Optional agents (4)
│   ├── Specialized agents (9)
│   ├── v2.0+ agents (7)
│   └── Expert agents (7)
├── 🔄 Workflows (workflows/)
│   ├── Primary workflows (5)
│   ├── Support workflows (6)
│   ├── Team workflows (8)
│   ├── Distributed workflows (2)
│   ├── Product workflows (2)
│   ├── Outsourcing workflows (1)
│   └── Master workflow (1)
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
| **Architecture** | [docs/architecture/distributed-system.md](docs/architecture/distributed-system.md) | System docs |
| **Testing** | [tests/README.md](tests/README.md) | Test documentation |
| **All Docs** | [docs/README.md](docs/README.md) | Documentation hub |

### Statistics

- **Total Files:** 200+ files
- **Code:** ~10,000 lines
- **Documentation:** ~5,000 lines
- **Languages:** 2 (English, Vietnamese)
- **Test Coverage:** ~92% pass rate

### Version Information

- **Current Version:** 3.6.0
- **Last Updated:** 2026-05-22
- **Status:** Production Ready
- **License:** MIT

### Links

- **GitHub:** https://github.com/nv-minh/agent-team
- **Documentation:** docs/README.md
- **Issues:** https://github.com/nv-minh/agent-team/issues
- **Discussions:** https://github.com/nv-minh/agent-team/discussions

### Key Features Summary

1. **81 Skills** - Reusable patterns across 20 categories including 15 expert groups
2. **35 Agents** - Core + optional + specialized + expert agents for every tech stack
3. **25 Workflows** - End-to-end processes including greenfield and Japanese outsourcing
4. **Architecture Intelligence** - `codebase-architecture` skill selects pattern + generates enforcing rules
5. **Japanese Outsourcing** - Full suite: 基本設計, 詳細設計, 受け入れテスト, 進捗報告 with sign-off gates
6. **Distributed Mode** - Parallel agent execution (3-5x faster for complex tasks)
7. **Bilingual Docs** - English & Vietnamese
8. **Multi-language** - Supports 15+ programming languages and frameworks
9. **Security Focus** - OWASP, STRIDE coverage
10. **CI Validation** - Automated frontmatter and reference checking

### Getting Help

- 📖 [Documentation Hub](docs/README.md)
- 🚀 [Quick Start Guide](docs/guides/getting-started.md)
- 💬 [GitHub Discussions](https://github.com/nv-minh/agent-team/discussions)
- 🐛 [Report Issues](https://github.com/nv-minh/agent-team/issues)

---

**Built with ❤️ from the best of 6 top AI agent/workflow repositories**

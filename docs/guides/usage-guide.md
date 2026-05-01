# EM-Team Usage Guide

Complete guide for using the EM-Team fullstack engineering system.

---

## Table of Contents

1. [Overview](#overview)
2. [Communication Styles (NEW)](#communication-styles)
3. [Using Skills](#using-skills)
4. [Using Agents](#using-agents)
5. [Using Workflows](#using-workflows)
6. [Distributed Mode](#distributed-mode)
7. [Best Practices](#best-practices)
8. [Examples](#examples)
9. [Troubleshooting](#troubleshooting)

---

## Overview

EM-Team provides three main ways to accomplish tasks:

| Method | Description | Best For |
|--------|-------------|----------|
| **Skills** | Reusable patterns and practices | Specific development tasks |
| **Agents** | Specialized AI agents | Complex specialized work |
| **Workflows** | End-to-end processes | Complete project lifecycles |

---

## Communication Styles

EM-Team v2.2.0 includes a unified communication control system with two independent axes:

- **Personality** (tone/voice) — 13 styles via `/em:skill:style-switcher`
- **Density** (verbosity/format) — 3 modes via `/compact`, `/terse`, `/standard`

### Personality Styles

**Productivity:** Tactical, Raw, Reality Check, git log, Socratic, BLUF
**Fun:** Inverted, Dramatic, 80s Hacker, Dad Joke
**Deep Understanding:** Rubber Duck, Teacher, First Principles

### Usage

```bash
# Show personality menu (13 styles + 3 density modes)
/em:skill:style-switcher

# Set personality
/em:skill:style-switcher tactical        # Direct, no preamble
/em:skill:style-switcher teacher         # Feynman technique explanations
/em:skill:style-switcher reality-check   # Honest evaluation

# Set density independently
/compact               # Bullet-point output
/terse                 # Single-line status
/standard              # Full detailed reports

# Combine (each set independently)
/em:skill:style-switcher raw             # Personality → Raw
/compact               # Density → COMPACT

# Terminal CLI modifier (strip markdown)
/em:skill:style-switcher tactical + terminal CLI
```

### When to Use

| Scenario | Personality | Density |
|---|---|---|
| Debugging CI failure | Tactical | TERSE |
| Teaching a junior | Teacher | STANDARD |
| Rapid coding session | Raw | COMPACT |
| Evaluating feature idea | Reality Check | STANDARD |
| Architecture decision | First Principles | COMPACT |

**Rules:** CRITICAL findings always get full context. File paths never omitted. Personality and density are independent.

See `skills/workflow/style-switcher/style-switcher.md` for complete documentation.

---

## Using Skills

### What are Skills?

Skills are reusable patterns and best practices synthesized from top AI agent repositories. They provide structured approaches to common development tasks.

### Available Skills

#### Foundation Skills (Core)
1. **spec-driven-development** - Write specifications before coding
2. **brainstorming** - Explore ideas into detailed designs
3. **context-engineering** - Optimize agent context setup
4. **writing-plans** - Break work into manageable tasks
5. **systematic-debugging** - 4-phase debugging methodology
6. **alignment-session** - Pre-coding human-AI alignment session

#### Development Skills
7. **test-driven-development** - TDD: RED-GREEN-REFACTOR
8. **frontend-patterns** - React/Next.js/Vue best practices
9. **backend-patterns** - API/Database/NestJS patterns
10. **incremental-implementation** - Vertical slice development
11. **subagent-driven-development** - Fresh context per task
12. **source-driven-development** - Code from official docs
13. **api-interface-design** - Contract-first APIs
14. **security-hardening** - OWASP Top 10 security
15. **architecture-zoom-out** - Higher-level code perspective
16. **architecture-improvement** - Systematic module deepening
17. **issue-generator** - Plans to structured vertical-slice GitHub issues
18. **prd-generator** - Convert ideas to structured PRD documents

#### Quality Skills
19. **code-review** - 5-axis review framework
20. **code-simplification** - Reduce complexity
21. **browser-testing** - DevTools MCP integration
22. **performance-optimization** - Measure-first optimization
23. **e2e-testing** - Playwright patterns
24. **security-audit** - Vulnerability assessment
25. **api-testing** - Integration testing
26. **ux-audit** - Behavioral UX audit with scored dimensions
27. **plan-tune** - Learn and tune output preferences

#### Workflow Skills
28. **git-workflow** - Atomic commits
29. **ci-cd-automation** - Feature flags, quality gates
30. **documentation** - ADRs, API docs
31. **finishing-branch** - Merge/PR decisions
32. **deprecation-migration** - Code-as-liability mindset

#### Language Skills (NEW)
33. **typescript-patterns** - TypeScript type system, async, React/Next.js TS
34. **python-patterns** - Python 3.10+ types, async, FastAPI, SQLAlchemy 2.0
35. **go-patterns** - Error handling, concurrency, interfaces, testing
36. **rust-patterns** - Ownership, traits, async tokio, smart pointers

#### Communication Skills
37. **style-switcher** - 13 personality styles + 3 density modes

#### Additional Skills
38. **security-common** - OWASP reference and security checklist

### How to Use Skills

Invoke skills directly in your conversation:

```bash
# Example 1: Brainstorming
"Use the brainstorming skill to explore a user authentication feature"

# Example 2: Spec-driven development
"Use the spec-driven-development skill to create a spec for JWT authentication"

# Example 3: Debugging
"Use the systematic-debugging skill to investigate the login timeout bug"
```

### Skill Execution Flow

When you invoke a skill:

```
1. Skill activation
   ↓
2. Context gathering
   ↓
3. Pattern application
   ↓
4. Output generation
   ↓
5. Verification
```

---

## Using Agents

### What are Agents?

Agents are specialized AI assistants that handle specific types of tasks. Each agent has expertise in a particular domain.

### Core Agents

#### 1. Planner Agent
**Purpose:** Create detailed implementation plans
**Usage:** `Agent: em:planner - Create implementation plan for feature X`
**Best for:** Breaking down complex features

#### 2. Executor Agent
**Purpose:** Execute plans with atomic commits
**Usage:** `Agent: em:executor - Implement the authentication plan`
**Best for:** Implementation with version control

#### 3. Code-Reviewer Agent
**Purpose:** 5-axis code review
**Usage:** `Agent: em:code-reviewer - Review the changes in this PR`
**Best for:** Quality assurance

#### 4. Debugger Agent
**Purpose:** Systematic debugging
**Usage:** `Agent: em:debugger - Investigate this bug systematically`
**Best for:** Root cause analysis

#### 5. Test-Engineer Agent
**Purpose:** Test strategy and generation
**Usage:** `Agent: em:test-engineer - Create test strategy for authentication`
**Best for:** Test planning

#### 6. Security-Auditor Agent
**Purpose:** OWASP security assessment
**Usage:** `Agent: em:security-auditor - Audit the authentication system`
**Best for:** Security reviews

#### 7. UI-Auditor Agent
**Purpose:** Visual QA and design review
**Usage:** `Agent: ui-auditor - Review the login page design`
**Best for:** UI/UX quality

#### 8. Verifier Agent
**Purpose:** Post-execution verification
**Usage:** `Agent: verifier - Verify the feature implementation`
**Best for:** Final validation

### Specialized Agents

#### 9. Researcher Agent
Technical exploration and research

#### 10. Codebase-Mapper Agent
Architecture analysis and documentation

#### 11. Integration-Checker Agent
Cross-phase validation

#### 12. Performance-Auditor Agent
Benchmarking and optimization

#### 13. Backend-Expert Agent
Backend specialist (API, database, performance)

#### 14. Frontend-Expert Agent
Frontend specialist (UI, UX, frameworks)

#### 15. Database-Expert Agent
Database specialist (schema, queries, optimization)

#### 16. Tech-Lead-Orchestrator Agent
Coordinates distributed investigations

#### New Agents (v2.0.0)
27. **Design-Reviewer Agent** - Visual design review with 6-pillar UI audit
28. **DevEx-Reviewer Agent** - Developer experience audit and TTHW measurement
29. **Iron-Law-Enforcer Agent** - Gate enforcement for Iron Law compliance

### How to Use Agents

Dispatch agents for specialized tasks:

```bash
# Basic pattern
"Agent: em:[agent-name] - [task description]"

# Examples
"Agent: em:planner - Create implementation plan for user authentication"
"Agent: em:code-reviewer - Review the authentication PR"
"Agent: em:debugger - Investigate the login failure"
```

### Agent Interaction Patterns

#### Sequential Agent Usage
```bash
# Use multiple agents in sequence
"Agent: em:planner - Plan the feature"
↓
"Agent: em:executor - Implement the plan"
↓
"Agent: em:code-reviewer - Review the implementation"
```

#### Parallel Agent Usage (Distributed Mode)
```bash
# Use multiple agents simultaneously
./scripts/distributed-orchestrator.sh start
"Agent: em:techlead-orchestrator - Investigate authentication"
# Backend, frontend, database agents work in parallel
```

---

## Using Workflows

### What are Workflows?

Workflows are end-to-end processes that combine multiple skills and agents to complete complex tasks.

### Primary Workflows

#### 1. New Feature Workflow
**Purpose:** Take features from idea to production
**Usage:** `Workflow: new-feature - [feature description]`
**Stages:** Define → Plan → Build → Verify → Review → Simplify → Ship

#### 2. Bug Fix Workflow
**Purpose:** Investigate and fix bugs systematically
**Usage:** `Workflow: bug-fix - [bug description]`
**Stages:** Investigate → Analyze → Hypothesize → Implement → Verify

#### 3. Refactoring Workflow
**Purpose:** Improve code quality safely
**Usage:** `Workflow: refactoring - [refactoring goal]`
**Stages:** Analyze → Plan → Refactor → Test → Verify

#### 4. Security Audit Workflow
**Purpose:** Comprehensive security assessment
**Usage:** `Workflow: security-audit - [system to audit]`
**Stages:** Reconnaissance → Vulnerability Scan → Analysis → Reporting

### Support Workflows

#### 5. Project Setup Workflow
Initialize new projects with best practices

#### 6. Documentation Workflow
Generate and update documentation

#### 7. Deployment Workflow
Deploy and monitor features

#### 8. Retro Workflow
Learn and improve from completed work

### Distributed Workflows

#### 9. Distributed Investigation Workflow
Parallel bug investigation across codebase
**Usage:** `Workflow: distributed-investigation - [investigation topic]`

#### 10. Distributed Development Workflow
Parallel feature implementation
**Usage:** `Workflow: distributed-development - [feature description]`

### Team Workflows

#### 11. Team Review Workflow
Full team review orchestrated by Team Lead

#### 12. Architecture Review Workflow
Architecture review with Architect & Staff Engineer

#### 13. Design Review Workflow
UI/UX design review with Frontend Expert & Product Manager

#### 14. Code Review 9-Axis Workflow
Deep 9-axis code review with Senior Code Reviewer & Security

#### 15. Database Review Workflow
Database schema & query review

#### 16. Product Review Workflow
Product/spec review with Product Manager

#### 17. Security Review Advanced Workflow
Advanced security (OWASP + STRIDE)

#### 18. Incident Response Workflow
Production incident handling

### How to Use Workflows

```bash
# Basic pattern
"Workflow: em-[workflow-name] - [task description]"

# Examples
"Workflow: em-new-feature - Implement user authentication"
"Workflow: em-bug-fix - Fix the login timeout bug"
"Workflow: em-security-audit - Audit the payment system"
```

---

## Distributed Mode

### What is Distributed Mode?

Distributed mode runs multiple specialist agents in parallel in isolated tmux sessions to solve token context overflow and enable parallel processing.

### When to Use Distributed Mode

✅ **Use when:**
- Task requires analysis across multiple domains
- Need specialist expertise from different areas
- Context is approaching token limits
- Need comprehensive audit trail
- Want parallel execution for speed

❌ **Don't use when:**
- Task is simple and single-domain
- Quick investigation needed
- Don't need parallel processing

### Starting Distributed Mode

```bash
# Start distributed orchestration
./scripts/distributed-orchestrator.sh start

# This creates:
# - tmux session: claude-work
# - Windows: orchestrator, backend, frontend, database
# - Directories: reports/, queue/, logs/

# Attach to orchestrator window
tmux attach -t claude-work:orchestrator

# Trigger investigation
"Agent: em:techlead-orchestrator - Investigate authentication bug"

# The orchestrator will:
# 1. Analyze the task
# 2. Delegate to specialist agents
# 3. Collect findings
# 4. Consolidate into report
```

### Managing Distributed Sessions

```bash
# List active sessions
./scripts/session-manager.sh list

# Check agent status
./distributed/session-coordinator.sh agent-status

# Check queue status
./distributed/session-coordinator.sh queue-status

# Broadcast message to all agents
./scripts/session-manager.sh broadcast "echo 'Status update'"

# Consolidate reports
./scripts/consolidate-reports.sh consolidate

# Stop distributed mode
./scripts/distributed-orchestrator.sh stop
```

### Viewing Reports

```bash
# List available reports
./scripts/consolidate-reports.sh list

# View consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# View individual agent reports
ls /tmp/claude-work-reports/backend/
ls /tmp/claude-work-reports/frontend/
ls /tmp/claude-work-reports/database/
```

---

## Best Practices

### 1. Choose the Right Tool

```bash
# Simple task → Use skill
"Use the brainstorming skill to explore feature ideas"

# Specialized task → Use agent
"Agent: em:code-reviewer - Review this PR"

# Complex process → Use workflow
"Workflow: em-new-feature - Build and ship the feature"

# Multi-domain task → Use distributed mode
./scripts/distributed-orchestrator.sh start
```

### 2. Be Specific with Prompts

```bash
# ❌ Too vague
"Agent: em:planner - Plan something"

# ✅ Specific and clear
"Agent: em:planner - Create implementation plan for JWT-based user authentication with refresh tokens, including database schema, API endpoints, and frontend components"
```

### 3. Provide Context

```bash
# ❌ No context
"Agent: em:debugger - Fix this bug"

# ✅ With context
"Agent: em:debugger - Investigate login timeout bug. Started occurring after deployment 2 hours ago. Error: 'Connection timeout after 30s'. Affects 10% of login attempts. Backend logs show database query timeouts."
```

### 4. Follow Iron Laws

```bash
# TDD Iron Law
# NO PRODUCTION CODE WITHOUT FAILING TEST

# Debugging Iron Law
# NO FIXES WITHOUT ROOT CAUSE

# Spec Iron Law
# NO CODE WITHOUT SPEC (for features)
```

### 5. Review and Iterate

```bash
# Always review agent outputs
"Agent: em:code-reviewer - Review the implementation"

# Iterate based on feedback
# Make improvements
# Re-verify
```

---

## Examples

### Example 1: Building Authentication Feature

```bash
# Step 1: Explore the idea
"Use the brainstorming skill to explore user authentication options"

# Step 2: Create specification
"Use the spec-driven-development skill to create a spec for JWT authentication"

# Step 3: Plan implementation
"Agent: em:planner - Create implementation plan for JWT auth"

# Step 4: Implement
"Agent: em:executor - Implement the authentication plan"

# Step 5: Test
"Agent: em:test-engineer - Create test strategy for authentication"

# Step 6: Review
"Agent: em:code-reviewer - Review authentication implementation"
"Agent: em:security-auditor - Audit authentication security"

# Step 7: Deploy
"Workflow: em-deployment - Deploy authentication feature"
```

### Example 2: Debugging Production Issue

```bash
# Step 1: Initial investigation
"Use the systematic-debugging skill to investigate the login timeout"

# Step 2: Deep dive with distributed mode
./scripts/distributed-orchestrator.sh start
tmux attach -t claude-work:orchestrator
"Agent: em:techlead-orchestrator - Investigate login timeout across entire stack"

# Step 3: Review findings
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# Step 4: Fix root cause
"Use the test-driven-development skill to fix the database connection pool issue"

# Step 5: Verify fix
"Agent: em:test-engineer - Verify the login timeout fix"

# Step 6: Postmortem
"Workflow: em-incident-response - Create postmortem for login timeout incident"
```

### Example 3: Performance Optimization

```bash
# Step 1: Analyze performance
"Agent: em:performance-auditor - Benchmark the API endpoints"

# Step 2: Identify bottlenecks
"Use the performance-optimization skill to analyze the benchmark results"

# Step 3: Plan optimizations
"Agent: em:planner - Create optimization plan based on bottlenecks"

# Step 4: Implement optimizations
"Agent: em:executor - Implement the performance optimizations"

# Step 5: Verify improvements
"Agent: em:performance-auditor - Re-benchmark after optimizations"

# Step 6: Document
"Use the documentation skill to document the performance improvements"
```

---

## Troubleshooting

### Issue: Command Not Recognized

**Solution:**
```bash
# Verify file exists
ls -la scripts/distributed-orchestrator.sh

# Make executable
chmod +x scripts/*.sh
chmod +x distributed/*.sh
```

### Issue: tmux Session Not Created

**Solution:**
```bash
# Check tmux installation
tmux -V

# Kill existing sessions
tmux kill-server

# Try again
./scripts/distributed-orchestrator.sh start
```

### Issue: Agent Not Responding

**Solution:**
```bash
# Check agent window
tmux list-windows -t claude-work

# Attach to specific window
tmux attach -t claude-work:backend

# Check for errors
ls /tmp/claude-work-logs/
```

### Issue: Reports Not Generated

**Solution:**
```bash
# Check shared directory
ls /tmp/claude-work-reports/*/

# Manually trigger consolidation
./scripts/consolidate-reports.sh consolidate

# Check output
cat /tmp/claude-work-reports/techlead/consolidated-report.md
```

### Issue: Tests Failing

**Solution:**
```bash
# Run with verbose output
cd tests
./run-e2e-tests.sh --verbose

# Run individual test
./test-distributed-orchestrator.sh

# Check test environment
ls /tmp/em:team-test-*
```

---

## Advanced Usage

### Custom Agent Configuration

Create custom agents by following the template:

```bash
# Use agent template
cp templates/agent-invocation-template.md agents/my-custom-agent.md

# Edit with your requirements
# Follow the agent structure
```

### Workflow Customization

Create custom workflows:

```bash
# Copy existing workflow
cp workflows/new-feature.md workflows/my-custom-workflow.md

# Modify for your needs
# Test with: "Workflow: em-my-custom-workflow - test task"
```

### Integration with CI/CD

```yaml
# Example GitHub Actions
- name: Run EM-Team Tests
  run: |
    cd tests
    ./run-e2e-tests.sh

- name: Security Audit
  run: |
    "Agent: em:security-auditor - Audit before deployment"
```

---

## Resources

- [Architecture Documentation](../architecture/overview.md)
- [Protocol Reference](../protocols/messaging.md)
- [Workflow Catalog](../workflows/overview.md)
- [Skill Reference](../skills/overview.md)
- [Agent Reference](../agents/overview.md)
- [Test Suite](../tests/README.md)

---

**Need help?** Check [Troubleshooting](../troubleshooting.md) or [GitHub Issues](https://github.com/nv-minh/agent-team/issues)

---

**Last Updated:** 2026-05-01
**Version:** 2.2.0

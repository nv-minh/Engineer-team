# EM-Team System - Complete Skill Index

**EM-Team** is a comprehensive fullstack engineering system with 44 skills, 27 agents, and 23 workflows synthesized from the best practices of 6 top AI agent repositories.

---

## What is EM-Team?

EM-Team provides three powerful ways to accelerate your development:

1. **Skills** - Reusable patterns & best practices for specific tasks
2. **Agents** - Specialized AI assistants for domain expertise
3. **Workflows** - End-to-end processes for complete project lifecycles

---

## Available Skills (44 Skills)

### Foundation Skills (6 skills)
Location: `skills/foundation/`

1. **alignment-session** - Pre-coding human-AI alignment
2. **spec-driven-development** - Write specs before coding
3. **brainstorming** - Explore ideas into designs
4. **context-engineering** - Optimize agent context setup
5. **writing-plans** - Break work into bite-sized tasks
6. **systematic-debugging** - 4-phase debugging methodology

**Usage:**
```
"Use the brainstorming skill to explore feature ideas"
"Use the spec-driven-development skill to create a specification"
"Use the systematic-debugging skill to investigate bugs"
```

### Development Skills (17 skills)
Location: `skills/development/`

7. **test-driven-development** - TDD RED-GREEN-REFACTOR
8. **frontend-patterns** - React/Next.js/Vue patterns
9. **backend-patterns** - API/Database patterns
10. **incremental-implementation** - Vertical slice development
11. **subagent-driven-development** - Fresh context per task + two-stage review
12. **source-driven-development** - Code from official docs
13. **api-interface-design** - Contract-first APIs
14. **security-hardening** - OWASP Top 10 security
15. **typescript-patterns** - TypeScript type system, async, React/Next.js TS patterns
16. **python-patterns** - Python 3.10+ types, async, FastAPI, SQLAlchemy 2.0
17. **go-patterns** - Error handling, concurrency, interfaces, testing
18. **rust-patterns** - Ownership, traits, async tokio, smart pointers
19. **architecture-zoom-out** - Higher-level code perspective
20. **architecture-improvement** - Systematic module deepening
21. **issue-generator** - Plans to structured vertical-slice issues
22. **prd-generator** - Ideas to structured PRD documents
23. **diagram** - Excalidraw, Mermaid, SVG diagram generation

**Usage:**
```
"Use the test-driven-development skill to implement this feature"
"Use the frontend-patterns skill for React best practices"
"Use the security-hardening skill to secure the application"
```

### Quality Skills (10 skills)
Location: `skills/quality/`

24. **code-review** - 5-axis review framework
25. **code-simplification** - Reduce complexity
26. **browser-testing** - DevTools MCP integration
27. **performance-optimization** - Measure-first optimization
28. **e2e-testing** - Playwright patterns
29. **security-audit** - Vulnerability assessment
30. **api-testing** - Integration testing
31. **security-common** - OWASP reference and security checklist
32. **ux-audit** - Behavioral UX audit with scored dimensions
33. **plan-tune** - Learn and tune output preferences

**Usage:**
```
"Use the code-review skill to review these changes"
"Use the performance-optimization skill to optimize performance"
"Use the security-audit skill to check for vulnerabilities"
```

### Workflow Skills (6 skills)
Location: `skills/workflow/`

34. **git-workflow** - Atomic commits
35. **ci-cd-automation** - Feature flags, quality gates
36. **documentation** - ADRs, API docs
37. **finishing-branch** - Merge/PR decisions
38. **deprecation-migration** - Code-as-liability mindset
39. **style-switcher** - Unified personality styles (13) and density modes (3)

**Usage:**
```
"Use the git-workflow skill for atomic commits"
"Use the documentation skill to create API docs"
"Use the ci-cd-automation skill for deployment strategies"
```

### Additional Skills (5 skills)
Location: `skills/additional/`

40. **jobs-to-be-done** - JTBD framework for understanding user needs
41. **lean-ux-canvas** - Lean UX hypothesis testing
42. **opportunity-solution-tree** - Product opportunity mapping
43. **pol-probe** - Product opportunity probe
44. **office-hours** - YC-style brainstorming and idea validation

**Usage:**
```
"Use the jobs-to-be-done skill to understand customer needs"
"Use the lean-ux-canvas skill to frame business assumptions"
"Use the office-hours skill to validate this product idea"
```

---

## Available Agents (27 Agents)

Location: `agents/`

### Core Agents (8 agents)
1. **planner** - Create detailed implementation plans
2. **executor** - Execute plans with atomic commits
3. **code-reviewer** - 5-axis code review (two-stage: spec compliance then quality)
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-auditor** - OWASP security assessment
7. **ui-auditor** - Visual QA & design review
8. **verifier** - Post-execution verification

### Optional Agents (4 agents)
9. **researcher** - Technical exploration
10. **codebase-mapper** - Architecture analysis
11. **integration-checker** - Cross-phase validation
12. **performance-auditor** - Benchmarking

### Specialized Agents (8 agents)
13. **team-lead** - Orchestrator for team reviews (trigger: `em-agent:team-lead`)
14. **architect** - Architecture & technical design (trigger: `em-agent:architect`)
15. **frontend-expert** - React/Next.js, UI/UX, performance (trigger: `em-agent:frontend-expert`)
16. **senior-code-reviewer** - 9-axis deep code review (trigger: `em-agent:senior-code-reviewer`)
17. **database-expert** - Schema, queries, fintech patterns (trigger: `em-agent:database-expert`)
18. **product-manager** - Requirements, GAP analysis, market fit (trigger: `em-agent:product-manager`)
19. **security-reviewer** - OWASP Top 10, STRIDE, blocking authority (trigger: `em-agent:security-reviewer`)
20. **staff-engineer** - Root cause analysis, cross-service impact (trigger: `em-agent:staff-engineer`)

### New Agents v2.0+ (7 agents)
21. **market-intelligence** - Market analysis, competitive intelligence (trigger: `em-agent:market-intelligence`)
22. **learn** - Knowledge management and cross-session learning
23. **autoplan** - Multi-phase review pipeline orchestrator
24. **techlead-orchestrator** - Distributed team coordination
25. **design-reviewer** - Visual design review with 6-pillar UI audit (trigger: `em-agent:design-reviewer`)
26. **devex-reviewer** - Developer experience audit and TTHW measurement (trigger: `em-agent:devex-reviewer`)
27. **iron-law-enforcer** - Gate enforcement for Iron Law compliance (trigger: `em-agent:iron-law-enforcer`)

**Usage:**
```
"Agent: em-planner - Create implementation plan for feature X"
"Agent: em-code-reviewer - Review the changes in this PR"
"Agent: em-debugger - Investigate this bug systematically"
"Agent: em-frontend-expert - Review the React components"
```

---

## Available Workflows (23 Workflows)

Location: `workflows/`

### Primary Workflows (4 workflows)
1. **new-feature** - From idea to production
2. **bug-fix** - Investigate and fix bugs systematically
3. **refactoring** - Improve code quality safely
4. **security-audit** - Comprehensive security assessment

### Support Workflows (6 workflows)
5. **project-setup** - Initialize new projects
6. **documentation** - Generate and update docs
7. **deployment** - Deploy and monitor features
8. **retro** - Learn and improve from completed work
9. **ship-workflow** - Version bump, changelog, PR creation
10. **canary-monitoring** - Post-deploy health monitoring

### Master Workflow (1 workflow)
11. **six-phase-lifecycle** - DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP

### Team Workflows (8 workflows)
12. **team-review** - Full team review orchestrated by Team Lead
13. **architecture-review** - Architecture review with Architect & Staff Engineer
14. **design-review** - UI/UX review with Frontend Expert & Product Manager
15. **code-review-9axis** - Deep 9-axis code review with Senior Code Reviewer & Security
16. **database-review** - Database schema & query review with Database Expert & Architect
17. **product-review** - Product/spec review with Product Manager & Architect
18. **security-review-advanced** - Advanced security (OWASP + STRIDE) with Security & Staff
19. **incident-response** - Production incident handling with Staff Engineer & Security

### Distributed Workflows (2 workflows)
20. **distributed-investigation** - Parallel bug investigation across full stack
21. **distributed-development** - Parallel feature development with multiple agents

### Product Workflows (2 workflows)
22. **discovery-process** - Product discovery and validation
23. **market-driven-feature** - Market-driven feature development

### Incident Sub-Workflows (workflows/incident/)
- initial-triage, cross-service-impact, root-cause-analysis, resolution-verification, postmortem-prevention, security-investigation

### Security Sub-Workflows (workflows/security/)
- deep-investigation, owasp-assessment, stride-threat-modeling

**Usage:**
```
"Workflow: em-new-feature - Take this feature from idea to production"
"Workflow: em-bug-fix - Fix this bug systematically"
"Workflow: em-security-audit - Audit the codebase for security issues"
"Workflow: em-distributed-investigation - Investigate across full stack"
```

---

## Distributed Mode

EM-Team includes distributed orchestration for complex multi-domain tasks:

```bash
# Start distributed mode
em-start  # or: ./scripts/distributed-orchestrator.sh start

# Use distributed workflow
"Agent: em-techlead-orchestrator - Investigate authentication bug"
# Backend, frontend, database agents work in parallel

# View consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# Stop distributed mode
em-stop  # or: ./scripts/distributed-orchestrator.sh stop
```

---

## Quick Reference

### For Specific Tasks
```bash
# Brainstorm ideas
"Use the brainstorming skill to explore feature X"

# Create specification
"Use the spec-driven-development skill to create spec for X"

# Write code with tests
"Use the test-driven-development skill to implement X"

# Debug issues
"Use the systematic-debugging skill to investigate bug X"

# Review code
"Use the code-review skill to review changes X"

# Optimize performance
"Use the performance-optimization skill to optimize X"
```

### For Domain Expertise
```bash
# Planning
"Agent: em-planner - Create plan for X"

# Execution
"Agent: em-executor - Execute plan X"

# Code Review
"Agent: em-code-reviewer - Review changes X"

# Debugging
"Agent: em-debugger - Debug issue X"

# Security
"Agent: em-security-auditor - Audit security of X"

# Testing
"Agent: em-test-engineer - Create tests for X"
```

### For Complete Workflows
```bash
# New Feature
"Workflow: em-new-feature - Implement feature X"

# Bug Fix
"Workflow: em-bug-fix - Fix bug X"

# Security Audit
"Workflow: em-security-audit - Audit system X"

# Distributed Investigation
"Workflow: em-distributed-investigation - Investigate X across full stack"
```

---

## Documentation

- **[README](../README.md)** - Main documentation
- **[INSTALLATION.md](../INSTALLATION.md)** - Installation guide
- **[INSTALLATION-VERIFICATION.md](../INSTALLATION-VERIFICATION.md)** - Installation verification
- **[docs/guides/getting-started.md](../docs/guides/getting-started.md)** - 5-minute quick start
- **[docs/guides/usage-guide.md](../docs/guides/usage-guide.md)** - Comprehensive English guide
- **[docs/vi/huong-dan-su-dung.md](../docs/vi/huong-dan-su-dung.md)** - Full Vietnamese guide

---

## Iron Laws

EM-Team follows these Iron Laws from best practices:

1. **TDD Iron Law**: NO PRODUCTION CODE WITHOUT FAILING TEST
2. **Debugging Iron Law**: NO FIXES WITHOUT ROOT CAUSE
3. **Spec Iron Law**: NO CODE WITHOUT SPEC (for features)
4. **Review Iron Law**: NO MERGE WITHOUT REVIEW

---

## Installation Status

- Repository: `/Users/abc/Desktop/EM-Team`
- Skills: 44 skills configured
- Agents: 27 agents configured
- Workflows: 23 workflows configured
- Distributed Mode: Operational

---

## Getting Started

1. **Use a skill:**
   ```
   "Use the brainstorming skill to explore this idea"
   ```

2. **Use an agent:**
   ```
   "Agent: em-planner - Create implementation plan"
   ```

3. **Use a workflow:**
   ```
   "Workflow: em-new-feature - Implement from idea to production"
   ```

---

**Version:** 2.2.0
**Last Updated:** 2026-05-02
**Status:** Production Ready
**Repository:** https://github.com/nv-minh/agent-team

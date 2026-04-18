# EM-Skill System - Complete Skill Index

**EM-Skill** is a comprehensive fullstack engineering system with 25+ skills, 16 agents, and 18 workflows synthesized from the best practices of 6 top AI agent repositories.

---

## 🎯 What is EM-Skill?

EM-Skill provides three powerful ways to accelerate your development:

1. **Skills** - Reusable patterns & best practices for specific tasks
2. **Agents** - Specialized AI assistants for domain expertise
3. **Workflows** - End-to-end processes for complete project lifecycles

---

## 📚 Available Skills (25 Skills)

### Foundation Skills (5 skills)
Location: `skills/foundation/`

1. **brainstorming** - Explore ideas into detailed designs
2. **context-engineering** - Optimize agent context setup
3. **spec-driven-development** - Write specs before coding
4. **systematic-debugging** - 4-phase debugging methodology
5. **writing-plans** - Break work into manageable tasks

**Usage:**
```
"Use the brainstorming skill to explore feature ideas"
"Use the spec-driven-development skill to create a specification"
"Use the systematic-debugging skill to investigate bugs"
```

### Development Skills (8 skills)
Location: `skills/development/`

6. **api-interface-design** - Contract-first API design
7. **backend-patterns** - API & Database best practices
8. **frontend-patterns** - React/Next.js/Vue patterns
9. **incremental-implementation** - Vertical slice development
10. **security-hardening** - OWASP Top 10 security practices
11. **source-driven-development** - Code from official documentation
12. **subagent-driven-development** - Fresh context per task
13. **test-driven-development** - TDD: RED-GREEN-REFACTOR

**Usage:**
```
"Use the test-driven-development skill to implement this feature"
"Use the frontend-patterns skill for React best practices"
"Use the security-hardening skill to secure the application"
```

### Quality Skills (7 skills)
Location: `skills/quality/`

14. **api-testing** - Integration testing strategies
15. **browser-testing** - DevTools MCP integration
16. **code-review** - 5-axis code review framework
17. **code-simplification** - Reduce complexity
18. **e2e-testing** - Playwright testing patterns
19. **performance-optimization** - Measure-first optimization
20. **security-audit** - Vulnerability assessment

**Usage:**
```
"Use the code-review skill to review these changes"
"Use the performance-optimization skill to optimize performance"
"Use the security-audit skill to check for vulnerabilities"
```

### Workflow Skills (5 skills)
Location: `skills/workflow/`

21. **ci-cd-automation** - Feature flags & quality gates
22. **deprecation-migration** - Code-as-liability mindset
23. **documentation** - ADRs & API documentation
24. **finishing-branch** - Merge/PR decisions
25. **git-workflow** - Atomic commits

**Usage:**
```
"Use the git-workflow skill for atomic commits"
"Use the documentation skill to create API docs"
"Use the ci-cd-automation skill for deployment strategies"
```

### Specialized Skills
Location: `skills/specialized/`

Language & framework-specific patterns for:
- TypeScript, Python, Go, Rust, Java, Kotlin, PHP, C#, C++
- React, Next.js, Vue, Svelte, Angular
- Node.js, Django, Laravel, NestJS, Spring Boot
- PostgreSQL, MySQL, MongoDB, Redis

---

## 🤖 Available Agents (16 Agents)

Location: `agents/`

### Core Agents (8 agents)
1. **planner** - Create detailed implementation plans
2. **executor** - Execute plans with atomic commits
3. **code-reviewer** - 5-axis code review
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-auditor** - OWASP security assessment
7. **ui-auditor** - Visual QA & design review
8. **verifier** - Post-execution verification

### Specialized Agents (8 agents)
9. **architect** - Architecture & technical design
10. **database-expert** - Schema, queries, fintech patterns
11. **frontend-expert** - React/Next.js, UI/UX, performance
12. **product-manager** - Requirements, GAP analysis
13. **senior-code-reviewer** - 9-axis deep code review
14. **security-reviewer** - OWASP + STRIDE security
15. **staff-engineer** - Root cause analysis
16. **team-lead** - Orchestrator for team reviews

**Usage:**
```
"Agent: em-planner - Create implementation plan for feature X"
"Agent: em-code-reviewer - Review the changes in this PR"
"Agent: em-debugger - Investigate this bug systematically"
"Agent: em-frontend-expert - Review the React components"
```

---

## 🔄 Available Workflows (18 Workflows)

Location: `workflows/`

### Primary Workflows (4 workflows)
1. **new-feature** - From idea to production
2. **bug-fix** - Investigate and fix bugs systematically
3. **refactoring** - Improve code quality safely
4. **security-audit** - Comprehensive security assessment

### Support Workflows (4 workflows)
5. **project-setup** - Initialize new projects
6. **documentation** - Generate and update docs
7. **deployment** - Deploy and monitor features
8. **retro** - Learn and improve from completed work

### Team Workflows (8 workflows)
9. **team-review** - Full team review orchestrated by Team Lead
10. **architecture-review** - Architecture review with Architect
11. **design-review** - UI/UX review with Frontend Expert
12. **code-review-9axis** - Deep 9-axis code review
13. **database-review** - Database schema & query review
14. **product-review** - Product/spec review with Product Manager
15. **security-review-advanced** - Advanced security (OWASP + STRIDE)
16. **incident-response** - Production incident handling

### Distributed Workflows (2 workflows)
17. **distributed-investigation** - Parallel bug investigation
18. **distributed-development** - Parallel feature development

**Usage:**
```
"Workflow: em-new-feature - Take this feature from idea to production"
"Workflow: em-bug-fix - Fix this bug systematically"
"Workflow: em-security-audit - Audit the codebase for security issues"
"Workflow: em-distributed-investigation - Investigate across full stack"
```

---

## 🌐 Distributed Mode

EM-Skill includes distributed orchestration for complex multi-domain tasks:

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

## 📖 Quick Reference

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

## 📚 Documentation

- **[README](../README.md)** - Main documentation
- **[INSTALLATION.md](../INSTALLATION.md)** - Installation guide
- **[INSTALLATION-VERIFICATION.md](../INSTALLATION-VERIFICATION.md)** - Installation verification
- **[docs/guides/getting-started.md](../docs/guides/getting-started.md)** - 5-minute quick start
- **[docs/guides/usage-guide.md](../docs/guides/usage-guide.md)** - Comprehensive English guide
- **[docs/vi/huong-dan-su-dung.md](../docs/vi/huong-dan-su-dung.md)** - Full Vietnamese guide

---

## 🎯 Iron Laws

EM-Skill follows these Iron Laws from best practices:

1. **TDD Iron Law**: NO PRODUCTION CODE WITHOUT FAILING TEST
2. **Debugging Iron Law**: NO FIXES WITHOUT ROOT CAUSE
3. **Spec Iron Law**: NO CODE WITHOUT SPEC (for features)

---

## ✅ Installation Status

- ✅ Repository: `/Users/abc/Desktop/EM-Skill`
- ✅ Skills: 25 skills configured
- ✅ Agents: 16 agents configured
- ✅ Workflows: 18 workflows configured
- ✅ Tests: 8/8 E2E tests passing
- ✅ Distributed Mode: Operational

---

## 🚀 Getting Started

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

**Version:** 1.1.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready
**Repository:** https://github.com/nv-minh/agent-team

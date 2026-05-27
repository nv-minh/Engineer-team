# EM-Team - Fullstack Engineering Skill System

**A comprehensive system of 75 skills, 33 active agents, and 25 workflows for fullstack engineering.**

---

## Quick Start

```
# Use a skill
"Use the brainstorming skill to explore this idea"

# Use an agent
"Agent: em-agent:planner - Create implementation plan"

# Use a workflow
"Workflow: em-wf:new-feature - Implement from idea to production"
```

## What's Available

### Skills (75 total)
- **Foundation** (7): brainstorming, domain-modeling, spec-driven-development, systematic-debugging, etc.
- **Development** (11): test-driven-development, incremental-implementation, subagent-driven-development, etc.
- **Expert** (42): React, Vue, Go, NestJS, Python, Database, DevOps, Mobile, Spring, Frontend, Backend, Rust, TypeScript
- **Quality** (12): code-review, security-audit, performance-optimization, e2e-testing, etc.
- **Workflow** (6): git-workflow, ci-cd-automation, documentation, etc.
- **Additional** (5): jobs-to-be-done, lean-ux-canvas, opportunity-solution-tree, etc.

### Agents (33 active + 2 deprecated)
- **Core** (8): planner, executor, code-reviewer, debugger, test-engineer, security-reviewer, ui-auditor, verifier
- **Specialized** (9): architect, frontend-expert, backend-expert, database-expert, etc.
- **Expert** (7): react-expert, vue-expert, nestjs-expert, devops-expert, mobile-expert, spring-expert, rust-expert

> **Note:** `senior-code-reviewer` and `security-auditor` are deprecated in v3.1.0. Use `code-reviewer` (Deep mode) and `security-reviewer` (Audit mode) instead.

### Workflows (25 total)
- **Primary** (6): new-feature, greenfield-app, bug-fix, qa-bug-hunter, refactoring, security-audit
- **Support** (6): project-setup, documentation, deployment, retro, ship-workflow, canary-monitoring
- **Team** (8): team-review, architecture-review, design-review, code-review-9axis, etc.
- **Distributed** (2): distributed-investigation, distributed-development
- **Product** (2): discovery-process, market-driven-feature

### Workflow Selection Guide

| Starting Point | Use |
|---|---|
| Blank directory + idea | greenfield-app |
| Existing codebase + feature | new-feature |
| Existing codebase + market opportunity | market-driven-feature |
| Technical bootstrapping only | project-setup |

---

**Version:** 4.1.0
**Last Updated:** 2026-05-24

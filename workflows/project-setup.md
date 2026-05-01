---
name: project-setup
description: Project initialization workflow for new fullstack projects
version: "2.0.0"
category: "support"
origin: "agent-skills"
agents_used:
  - planner
  - executor
skills_used:
  - context-engineering
  - brainstorming
  - writing-plans
  - ci-cd-automation
  - documentation
related_skills:
  - context-engineering
  - writing-plans
estimated_time: "3-7 hours"
---

# Project Setup Workflow

## Overview

The project setup workflow initializes new fullstack projects with proper structure, tooling, and configuration. It ensures best practices from day one.

## When to Use

- Starting new projects
- Initializing repositories
- Setting up team projects
- Creating project templates
- Bootstrapping applications

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Description |
|---|---|---|
| CHOOSE (Stage 1) | DEFINE | Understand requirements, evaluate tech stack options, make decision |
| SCAFFOLD (Stage 2) | PLAN + BUILD | Create project structure, initialize git, configure package.json |
| CONFIGURE (Stage 3) | BUILD | Set up TypeScript, ESLint, tests, CI/CD, build pipeline |
| TEST (Stage 4) | VERIFY | Verify tooling works, build succeeds, CI/CD active |
| INITIALIZE (Stage 5) | REVIEW + SHIP | Initial commit, push repo, set up branches and protections |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Requirements understood
- [ ] Options evaluated
- [ ] Decision made
- [ ] Rationale documented
PASS → proceed to PLAN | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Structure created
- [ ] Git initialized
- [ ] Package.json configured
- [ ] Tooling setup planned
PASS → proceed to BUILD | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] TypeScript compiles
- [ ] ESLint passes
- [ ] Tests configured
- [ ] Build succeeds
- [ ] CI/CD active
PASS → proceed to VERIFY | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Tooling works
- [ ] Build verifies
- [ ] CI/CD works
- [ ] Deployment successful (if applicable)
PASS → proceed to REVIEW | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Initial commit made
- [ ] Repository pushed
- [ ] Branches created
- [ ] Protections setup
- [ ] Team invited
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  CHOOSE → SCAFFOLD → CONFIGURE → TEST → INITIALIZE     │
│     1         2           3         4          5          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Tech Stack Templates

### Fullstack TypeScript

```yaml
tech_stack:
  frontend: "React 18 + TypeScript + Vite"
  backend: "Node.js + Express + TypeScript"
  database: "PostgreSQL + Prisma"
  testing: "Jest + Playwright"
  tooling: "ESLint + Prettier"
  ci_cd: "GitHub Actions"

features:
  - "TypeScript strict mode"
  - "ESLint with TypeScript rules"
  - "Prettier for formatting"
  - "Husky for git hooks"
  - "Jest for testing"
  - "Playwright for E2E"
  - "GitHub Actions CI/CD"
```

## Project Structure

```yaml
structure:
  root:
    - src/
    - tests/
    - docs/
    - scripts/
    - .github/
    - config/
    - .gitignore
    - package.json
    - README.md
    - LICENSE

  src:
    - components/
    - services/
    - hooks/
    - utils/
    - types/
    - constants/
    - styles/

  tests:
    - unit/
    - integration/
    - e2e/
    - fixtures/
    - helpers/
```

## Quality Gates Summary

```yaml
quality_gates:
  choose:
    - requirements_understood
    - options_evaluated
    - decision_made
    - rationale_documented

  scaffold:
    - structure_created
    - git_initialized
    - package_json_configured
    - tooling_setup

  configure:
    - typescript_compiles
    - eslint_passes
    - tests_configured
    - build_succeeds
    - cicd_active

  test:
    - tooling_works
    - build_verifies
    - cicd_works
    - deployment_successful

  initialize:
    - initial_commit
    - repository_pushed
    - branches_created
    - protections_setup
    - team_invited
```

## Timeline Estimate

```yaml
timeline:
  choose: "30 min - 2 hours"
  scaffold: "30 min - 1 hour"
  configure: "1-2 hours"
  test: "30 min - 1 hour"
  initialize: "30 min - 1 hour"

  total: "3-7 hours"
```

## Success Criteria

A successful project setup workflow:

- [ ] Tech stack selected
- [ ] Project scaffolded
- [ ] Tooling configured
- [ ] All tools working
- [ ] CI/CD pipeline active
- [ ] Repository initialized
- [ ] Team ready to start
- [ ] Documentation complete

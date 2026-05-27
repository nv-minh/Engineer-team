# Skill Systems Guide

## Overview

EM-Team provides a unified skill system containing **90 skills** across **20 category directories**. Skills are the building blocks that give agents and workflows their domain expertise -- covering everything from foundational development practices to language-specific patterns, quality assurance, and workflow automation.

Each skill is a self-contained Markdown file with YAML frontmatter metadata and structured body sections. Skills are installed globally via `bash install.sh`, which creates symlinks in `~/.claude/skills/` so they are available in any Claude Code project.

**Version:** 5.4.0
**Last Updated:** 2026-05-27

---

## Directory Structure

```
skills/
├── foundation/          # 11 skills — Core methodology and planning
├── development/         # 12 skills — Development workflows and architecture
├── expert-react/        # 4 skills  — React ecosystem (React, Hooks, Next.js, Redux)
├── expert-vue/          # 3 skills  — Vue ecosystem (Vue 3, Pinia, Vue Router)
├── expert-go/           # 1 skill   — Go patterns
├── expert-nest/         # 1 skill   — NestJS backend framework
├── expert-python/       # 3 skills  — Python (patterns, FastAPI, Django)
├── expert-database/     # 3 skills  — PostgreSQL, Redis, Elasticsearch
├── expert-devops/       # 6 skills  — Docker, K8s, Terraform, Ansible, GitHub Actions
├── expert-mobile/       # 4 skills  — Flutter, React Native, Android, iOS
├── expert-spring/       # 1 skill   — Spring Boot
├── expert-frontend/     # 1 skill   — Frontend UI patterns
├── expert-backend/      # 2 skills  — Backend patterns, API design
├── expert-rust/         # 1 skill   — Rust patterns
├── expert-typescript/   # 1 skill   — TypeScript patterns
├── drawio/              # 2 skills  — Architecture and flowchart diagrams
├── tauri/               # 1 skill   — Tauri desktop/mobile framework
├── quality/             # 14 skills — Code review, testing, security, UX audit
├── workflow/            # 14 skills — Git, CI/CD, documentation, GitHub management, brownfield impact
└── additional/          # 5 skills  — Product discovery and strategy
```

### Directory Naming Convention

- **`foundation/`** and **`development/`** -- process-oriented skills that apply to any tech stack
- **`expert-*/`** -- technology-specific skills grouped by domain (react, vue, database, devops, etc.)
- **`quality/`** -- verification, testing, and audit skills
- **`workflow/`** -- automation, git, and communication skills
- **`additional/`** -- product discovery and business analysis skills

---

## Skill Format

Each skill consists of two files in its category subdirectory:

```
skills/{category}/{skill-name}/
├── SKILL.md           # Symlink to the source .md file
└── {skill-name}.md    # Source file with full content
```

### Source File Structure

Every source `.md` file follows this format:

```markdown
---
name: skill-name
description: "Short description of when and why to use this skill"
version: "2.0.0"
category: "foundation"
origin: "superpowers"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "trigger phrase"
  - "another trigger"
intent: "What this skill aims to accomplish"
scenarios:
  - "Scenario where this skill applies"
best_for: "Primary use case summary"
estimated_time: "15-60 min"
anti_patterns:
  - "Common misuse to avoid"
related_skills: [other-skill, another-skill]
---

# Skill Title

## Overview
Description of what the skill does and when to use it.

## When to Use / When NOT to Use
Guidance on applicability.

## Process / Checklist
Step-by-step instructions.

## Coaching Notes
Educational context and tips.

## Verification
How to confirm the skill was applied correctly.

## Related Skills
Cross-references to complementary skills.
```

### YAML Frontmatter Fields

| Field | Description | Example |
|-------|-------------|---------|
| `name` | Skill identifier | `test-driven-development` |
| `description` | When and why to invoke | `"RED-GREEN-REFACTOR cycle..."` |
| `version` | Skill version | `"2.0.0"` |
| `category` | Directory category | `"development"` |
| `origin` | Source repository it was synthesized from | `"superpowers"` |
| `tools` | Required tool permissions | `[Read, Write, Bash]` |
| `triggers` | Phrases that should invoke this skill | `["write tests", "TDD"]` |
| `intent` | Goal of the skill | `"Ensure all code has tests"` |
| `scenarios` | Applicable situations | `["Starting a new feature"]` |
| `anti_patterns` | Misuse to avoid | `["Writing tests after code"]` |
| `related_skills` | Cross-references | `["spec-driven-development"]` |

---

## How Skills Are Discovered

### Installation

Running `bash install.sh` from the EM-Team root performs three steps:

1. **Configures `~/.claude/config.json`** -- sets the skills path to the EM-Team repo
2. **Creates wrapper symlinks in `~/.claude/skills/`** -- each skill gets a directory like `~/.claude/skills/em-skill:brainstorming/SKILL.md`
3. **Cleans up orphaned entries** -- removes broken or outdated symlinks from previous installs

### Symlink Layout

```
~/.claude/skills/
├── em-skill:brainstorming/
│   └── SKILL.md  ->  /path/to/em-team/skills/foundation/brainstorming/brainstorming.md
├── em-skill:test-driven-development/
│   └── SKILL.md  ->  /path/to/em-team/skills/development/test-driven-development/test-driven-development.md
├── em-skill:react/
│   └── SKILL.md  ->  /path/to/em-team/skills/expert-react/react/react.md
├── em:code-review/         # Agent wrappers also live here
│   └── SKILL.md  ->  /path/to/em-team/.claude/skills/em-code-review.md
└── ...
```

Skills are invoked by name in Claude Code:

```
Use the brainstorming skill to explore this feature idea
Use the test-driven-development skill to implement the auth module
Use the react skill to build the dashboard component
```

---

## When to Use Each Category

### Foundation (11 skills)

**The starting point for any work.** These skills establish shared understanding and prevent wasted effort.

| Skill | Use When |
|-------|----------|
| alignment-session | Starting a new session or onboarding to a project |
| brainstorming | Exploring ideas, designing features, or evaluating approaches |
| context-engineering | Setting up optimal agent context for a task |
| spec-driven-development | Writing specifications before writing code |
| systematic-debugging | Investigating bugs methodically (4-phase process) |
| writing-plans | Breaking work into structured, executable tasks |
| domain-modeling | Mapping bounded contexts, entities, relationships |
| project-dna | Crystallizing decisions into CLAUDE.md and rule files |
| basic-design | Creating formal 基本設計 documents (Japanese outsourcing) |
| detailed-design | Creating formal 詳細設計 per module |
| brownfield-onboarding | First time on a brownfield codebase — scan to build module-based business context (.em-brownfield/) |

### Development (12 skills)

**Process-oriented skills for building software.** Apply regardless of tech stack.

| Skill | Use When |
|-------|----------|
| architecture-improvement | Deepening a module's structure and design |
| architecture-zoom-out | Getting a higher-level perspective on code organization |
| diagram | Creating Excalidraw, Mermaid, or SVG diagrams |
| figma-design | Converting Figma designs to code via MCP |
| incremental-implementation | Building in vertical slices instead of horizontal layers |
| issue-generator | Converting plans into structured vertical-slice issues |
| prd-generator | Turning ideas into structured PRD documents |
| security-hardening | Applying OWASP Top 10 protections |
| source-driven-development | Building from official documentation |
| subagent-driven-development | Using fresh subagent context per task |
| test-driven-development | Following the RED-GREEN-REFACTOR TDD cycle |
| codebase-architecture | Researching architecture patterns for greenfield projects |

### Expert Skills (34 skills across 15 directories)

**Technology-specific patterns and best practices.** Use when working within a particular framework or language.

- **expert-react/** -- React fundamentals, hooks patterns, Next.js SSR/SSG, Redux state management
- **expert-vue/** -- Vue 3 Composition API, Pinia stores, Vue Router guards
- **expert-go/** -- Go error handling, concurrency, interfaces, Gin
- **expert-nest/** -- NestJS controllers, modules, guards, GraphQL, microservices
- **expert-python/** -- Python 3.10+ patterns, FastAPI, Django REST
- **expert-database/** -- PostgreSQL indexing/EXPLAIN, Redis caching, Elasticsearch DSL
- **expert-devops/** -- Dockerfile optimization, Docker Compose, Kubernetes, Terraform IaC, Ansible playbooks, GitHub Actions workflows
- **expert-mobile/** -- Flutter widgets, React Native, Android Jetpack Compose, iOS SwiftUI
- **expert-spring/** -- Spring Boot auto-config, JPA, security
- **expert-frontend/** -- UI component patterns, responsive design, accessibility
- **expert-backend/** -- API patterns, auth, services, contract-first API design
- **expert-rust/** -- Ownership, traits, async tokio, FFI
- **expert-typescript/** -- Type system patterns, async, React/Next.js TS

### Quality (14 skills)

**Verification, testing, and audit.** Ensure correctness, security, and usability.

| Skill | Use When |
|-------|----------|
| test-case-design | Designing test cases systematically (BVA/EP/DT/ST/Pairwise/RBT + abuse + non-functional) — run BEFORE test-generation/api-testing/e2e-testing/browser-testing *(v5.1.0)* |
| api-testing | Integration testing of API endpoints with OWASP API Top 10 + TC-code coverage gate |
| browser-testing | Visual QA with DevTools MCP integration, UI State Matrix, a11y/i18n |
| code-review | 5-axis code review framework |
| code-simplification | Reducing complexity and improving readability |
| e2e-testing | End-to-end testing with Playwright + user-journey edge-case matrix |
| flow-discovery | Mapping application flows and user journeys |
| performance-optimization | Measure-first performance tuning |
| plan-tune | Learning and tuning output preferences over time |
| security-audit | Vulnerability assessment and OWASP evaluation |
| security-common | Security reference checklist |
| test-generation | Generating test suites for existing code with TC-code coverage gate |
| uat-process | Formal 受け入れテスト (User Acceptance Testing) with sign-off |
| ux-audit | Behavioral UX audit with scored dimensions |

### Workflow (13 skills)

**Automation, git, and communication.** Support the development lifecycle.

| Skill | Use When |
|-------|----------|
| ci-cd-automation | Setting up quality gates, feature flags, deployment |
| deprecation-migration | Managing code deprecation and migration paths |
| documentation | Writing ADRs, API docs, and guides |
| finishing-branch | Making merge/PR decisions and cleanup |
| git-workflow | Atomic commits, branch management |
| style-switcher | Switching between 13 personality styles and 3 density modes |
| progress-reporting | Weekly 進捗報告 with GREEN/YELLOW/RED status |
| github-cicd-setup | Detecting stack and generating CI/CD workflows |
| github-pr-manager | PR creation, review fix, merge management |
| github-issue-manager | Issue creation, triage, sprint planning |
| github-release-manager | Version bump, release notes, git tags |
| github-issue-fix | Browsing GitHub issues and handing off to em-wf:bug-fix |
| brownfield-context-sync | Checking .em-brownfield/ artifacts are still accurate after code changes |

### Additional (5 skills)

**Product discovery and business analysis.** Understand user needs and validate ideas.

| Skill | Use When |
|-------|----------|
| jobs-to-be-done | Applying the JTBD framework for user needs analysis |
| lean-ux-canvas | Lean UX hypothesis testing |
| office-hours | YC-style brainstorming and idea validation |
| opportunity-solution-tree | Mapping product opportunities |
| pol-probe | Product opportunity exploration |

---

## Quick Reference

### All 89 Skills by Category

| # | Category | Skills | Count |
|---|----------|--------|-------|
| 1 | foundation | alignment-session, brainstorming, context-engineering, spec-driven-development, systematic-debugging, writing-plans, domain-modeling, project-dna, basic-design, detailed-design, brownfield-onboarding | 11 |
| 2 | development | architecture-improvement, architecture-zoom-out, codebase-architecture, diagram, figma-design, incremental-implementation, issue-generator, prd-generator, security-hardening, source-driven-development, subagent-driven-development, test-driven-development | 12 |
| 3 | expert-react | react, react-hooks, nextjs, redux | 4 |
| 4 | expert-vue | vue3, pinia, vue-router | 3 |
| 5 | expert-go | go-patterns | 1 |
| 6 | expert-nest | nestjs | 1 |
| 7 | expert-python | python-patterns, fastapi, django | 3 |
| 8 | expert-database | postgresql, redis, elasticsearch | 3 |
| 9 | expert-devops | docker, docker-compose, kubernetes, terraform, ansible, github-actions | 6 |
| 10 | expert-mobile | flutter, react-native, android-kotlin, ios-swift | 4 |
| 11 | expert-spring | spring-boot | 1 |
| 12 | expert-frontend | frontend-patterns | 1 |
| 13 | expert-backend | backend-patterns, api-interface-design | 2 |
| 14 | expert-rust | rust-patterns | 1 |
| 15 | expert-typescript | typescript-patterns | 1 |
| 16 | drawio | drawio-architecture, drawio-flowchart | 2 |
| 17 | tauri | tauri | 1 |
| 18 | quality | test-case-design, api-testing, browser-testing, code-review, code-simplification, e2e-testing, flow-discovery, performance-optimization, plan-tune, security-audit, security-common, test-generation, uat-process, ux-audit | 14 |
| 19 | workflow | ci-cd-automation, deprecation-migration, documentation, finishing-branch, git-workflow, style-switcher, progress-reporting, github-cicd-setup, github-pr-manager, github-issue-manager, github-release-manager, github-issue-fix, brownfield-context-sync | 13 |
| 20 | additional | jobs-to-be-done, lean-ux-canvas, office-hours, opportunity-solution-tree, pol-probe | 5 |
| | **Total** | | **89** |

### Common Skill Combinations

| Workflow | Skills to Chain |
|----------|----------------|
| **New feature** | brainstorming -> spec-driven-development -> writing-plans -> test-driven-development -> code-review |
| **Bug fix** | systematic-debugging -> test-driven-development -> code-review |
| **Security audit** | security-audit -> security-hardening -> code-review |
| **API development** | spec-driven-development -> api-interface-design -> backend-patterns -> api-testing |
| **Frontend feature** | brainstorming -> figma-design -> react -> browser-testing -> ux-audit |
| **DevOps setup** | docker -> docker-compose -> kubernetes -> github-actions -> ci-cd-automation |
| **Product discovery** | jobs-to-be-done -> opportunity-solution-tree -> lean-ux-canvas -> prd-generator |

### Iron Law Skills

The following skills enforce EM-Team's Iron Laws:

| Iron Law | Enforcing Skill |
|----------|----------------|
| No production code without failing test | test-driven-development |
| No fixes without root cause | systematic-debugging |
| No code without spec | spec-driven-development |
| No merge without review | code-review |

---

**Guide Version:** 5.2.0
**Last Updated:** 2026-05-26
**Maintained By:** EM-Team Project

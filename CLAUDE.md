# EM-Team - Fullstack Engineering Agent/Skill/Workflow System

## Overview

EM-Team is a comprehensive system of agents, skills, and workflows for fullstack engineering, synthesized from the best practices of 6 top AI agent/workflow repositories:

- **Product-Manager-Skills** (47 skills) - 3-tier architecture, coaching approach, interactive flows
- **agent-skills** (20 skills) - Development lifecycle, Iron Laws, 5-axis code review
- **everything-claude-code** (185+ skills) - Multi-language support, framework-specific patterns
- **get-shit-done** (GSD) - Spec-driven development, atomic commits, multi-layer QA
- **gstack** (28 skills) - Team-in-a-box, velocity multiplier, browser-in-CLI
- **superpowers** (16 skills) - Iron Laws, subagent-driven development, systematic debugging

## Builder Ethos

All EM-Skill agents and skills follow these principles (see `preambles/ethos.md`):

1. **Boil the Lake** — Do the complete thing. Completeness is cheap with AI.
2. **Search Before Building** — Check what exists before inventing something new.
3. **User Sovereignty** — AI recommends. The human decides. Always.
4. **Iron Laws** — Non-negotiable: TDD, root cause debugging, spec-before-code, review-before-merge.
5. **Always Be Coaching (ABC)** — Every interaction should teach something.

## Project Structure

```
em-team/
├── skills/              # 76 skills
│   ├── foundation/      # 8 core foundational skills
│   ├── development/     # 11 methodology skills (TDD, architecture, debugging, etc.)
│   ├── expert-react/    # 4 React skills (react, react-hooks, nextjs, redux)
│   ├── expert-vue/      # 3 Vue skills (vue3, pinia, vue-router)
│   ├── expert-go/       # 1 Go skill (go-patterns)
│   ├── expert-nest/     # 1 NestJS skill (nestjs)
│   ├── expert-python/   # 3 Python skills (python-patterns, fastapi, django)
│   ├── expert-database/ # 3 Database skills (postgresql, redis, elasticsearch)
│   ├── expert-devops/   # 6 DevOps skills (docker, docker-compose, kubernetes, terraform, ansible, github-actions)
│   ├── expert-mobile/   # 4 Mobile skills (flutter, react-native, android-kotlin, ios-swift)
│   ├── expert-spring/   # 1 Spring skill (spring-boot)
│   ├── expert-frontend/ # 1 Frontend skill (frontend-patterns)
│   ├── expert-backend/  # 2 Backend skills (backend-patterns, api-interface-design)
│   ├── expert-rust/     # 1 Rust skill (rust-patterns)
│   ├── expert-typescript/ # 1 TypeScript skill (typescript-patterns)
│   ├── drawio/          # 2 Drawio skills (architecture, flowchart)
│   ├── tauri/           # 1 Tauri skill (tauri)
│   ├── quality/         # 12 quality assurance skills
│   ├── workflow/        # 6 workflow and automation skills
│   └── additional/      # 5 product & discovery skills
├── agents/              # 35 agents (33 active + 2 deprecated)
├── workflows/           # 24 end-to-end workflows
├── .claude/
│   ├── lib/             # Libraries (trace-store, session-audit, artifact-store)
│   ├── mcp-servers/     # Custom MCP servers (GitHub enhanced, Project context)
│   └── rules/           # Operational rules (mistakes ledger, context management)
├── templates/           # Reusable templates + context artifacts
│   ├── context-artifacts/ # PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md
│   └── project-dna/      # Templates for generated agent guidance (CLAUDE.md, rules, traceability)
├── preambles/           # Shared initialization (ethos, skill preamble, agent preamble)
├── protocols/           # Communication standards (writing-style, delegation, distributed-messaging)
├── references/          # Shared reference docs (security, testing, code-quality, API, verification)
├── hooks/              # Automation hooks (pre-commit, post-commit, session-handoff)
├── commands/           # CLI commands
├── distributed/         # Distributed orchestration scripts (session coordinator, queue monitor, sync)
├── docs/               # Documentation (architecture guide, guides, Vietnamese docs)
├── scripts/            # Setup and orchestration scripts
├── .github/workflows/  # CI pipeline (skill/agent validation)
└── CLAUDE.md           # Main configuration (this file)
```

## Skill Categories

### Foundation Skills (8 skills)
1. **alignment-session** - Pre-coding human-AI alignment
2. **spec-driven-development** - Write specs before coding
3. **brainstorming** - Explore ideas into designs
4. **context-engineering** - Optimize agent context setup
5. **writing-plans** - Break work into bite-sized tasks
6. **systematic-debugging** - 4-phase debugging methodology
7. **domain-modeling** - Bounded contexts, entities, relationships, ubiquitous language
8. **project-dna** - Crystallize decisions into agent guidance (CLAUDE.md, rules, traceability)

### Development Skills (11 methodology skills)
7. **test-driven-development** - TDD RED-GREEN-REFACTOR
8. **incremental-implementation** - Vertical slice development
9. **subagent-driven-development** - Fresh context per task + two-stage review
10. **source-driven-development** - Code from official docs
11. **security-hardening** - OWASP Top 10 security
12. **architecture-zoom-out** - Higher-level code perspective
13. **architecture-improvement** - Systematic module deepening
14. **issue-generator** - Plans to structured vertical-slice issues
15. **prd-generator** - Ideas to structured PRD documents
16. **diagram** - Excalidraw, Mermaid, SVG diagram generation
17. **figma-design** - Figma-to-code conversion with MCP server

### Expert React Skills (4 skills)
18. **react** - React fundamentals, components, JSX, Context API, performance
19. **react-hooks** - useState, useEffect, useCallback, useMemo, custom hooks
20. **nextjs** - App Router, Pages Router, SSR/SSG/ISR, data fetching, deployment
21. **redux** - Redux Toolkit, slices, async thunks, RTK Query

### Expert Vue Skills (3 skills)
22. **vue3** - Composition API, reactivity, templates, SSR, TypeScript
23. **pinia** - Stores, getters, actions, plugins, Vuex migration
24. **vue-router** - Dynamic routes, guards, lazy loading

### Expert Go Skills (1 skill)
25. **go-patterns** - Error handling, concurrency, interfaces, testing, Gin

### Expert NestJS Skills (1 skill)
26. **nestjs** - Controllers, providers, modules, guards, pipes, GraphQL, microservices

### Expert Python Skills (3 skills)
27. **python-patterns** - Python 3.10+ types, async, SQLAlchemy 2.0
28. **fastapi** - FastAPI patterns, Pydantic, dependency injection, async
29. **django** - Django ORM, views, REST framework, testing

### Expert Database Skills (3 skills)
30. **postgresql** - Indexing, PL/pgSQL, JSONB, window functions, EXPLAIN
31. **redis** - Data structures, caching, pub/sub, clustering
32. **elasticsearch** - Query DSL, aggregations, ELK stack, performance

### Expert DevOps Skills (6 skills)
33. **docker** - Dockerfile, multi-stage builds, image optimization
34. **docker-compose** - Multi-container orchestration, networking, volumes
35. **kubernetes** - Pods, deployments, services, ingress, ConfigMaps
36. **terraform** - IaC, providers, modules, state management, multi-cloud
37. **ansible** - Playbooks, roles, inventory, idempotency
38. **github-actions** - Workflows, matrix, reusable workflows, secrets

### Expert Mobile Skills (4 skills)
39. **flutter** - Widgets, state management, navigation, platform channels
40. **react-native** - Components, navigation, native modules, Expo
41. **android-kotlin** - Jetpack Compose, MVVM, ViewModel, Navigation
42. **ios-swift** - SwiftUI, async/await, Core Data, App Store

### Expert Spring Skills (1 skill)
43. **spring-boot** - Auto-config, DI, JPA, security, actuator

### Expert Frontend Skills (1 skill)
44. **frontend-patterns** - UI component patterns, responsive design, accessibility

### Expert Backend Skills (2 skills)
45. **backend-patterns** - API/Database patterns, authentication, services
46. **api-interface-design** - Contract-first APIs

### Expert Rust Skills (1 skill)
47. **rust-patterns** - Ownership, traits, async tokio, smart pointers

### Expert TypeScript Skills (1 skill)
48. **typescript-patterns** - Type system, async, React/Next.js TS patterns

### Drawio Skills (2 skills)
49. **drawio-architecture** - C4 model, UML, cloud shapes, deployment diagrams
50. **drawio-flowchart** - Business process, swim lanes, decision trees

### Tauri Skills (1 skill)
51. **tauri** - Rust backend, frontend integration, plugins, mobile builds

### Quality Skills (12 skills)
52. **code-review** - 5-axis review framework
53. **code-simplification** - Reduce complexity
54. **browser-testing** - DevTools MCP integration
55. **performance-optimization** - Measure-first optimization
56. **e2e-testing** - Playwright patterns
57. **security-audit** - Vulnerability assessment
58. **api-testing** - Integration testing
59. **security-common** - OWASP reference and security checklist
60. **ux-audit** - Behavioral UX audit with scored dimensions
61. **plan-tune** - Learn and tune output preferences
62. **flow-discovery** - Discovery flow pattern identification
63. **test-generation** - Automated test generation strategies

### Workflow Skills (6 skills)
64. **git-workflow** - Atomic commits
65. **ci-cd-automation** - Feature flags, quality gates
66. **documentation** - ADRs, API docs
67. **finishing-branch** - Merge/PR decisions
68. **deprecation-migration** - Code-as-liability mindset
69. **style-switcher** - Unified personality styles (13) and density modes (3)

### Additional Skills (5 skills)
70. **jobs-to-be-done** - JTBD framework for understanding user needs
71. **lean-ux-canvas** - Lean UX hypothesis testing
72. **opportunity-solution-tree** - Product opportunity mapping
73. **pol-probe** - Product opportunity probe
74. **office-hours** - YC-style brainstorming and idea validation

## Agent Categories

### Core Agents (8 agents)
1. **planner** - Create detailed implementation plans
2. **executor** - Execute with atomic commits
3. **code-reviewer** - Code review with Standard (5-axis) and Deep (9-axis) modes
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-reviewer** - Security review with Audit (OWASP) and Review (OWASP+STRIDE) modes
7. **ui-auditor** - Visual QA
8. **verifier** - Post-execution verification

> **Note:** `senior-code-reviewer` and `security-auditor` are deprecated. Their capabilities are now unified into `code-reviewer` (Deep mode) and `security-reviewer` (Audit mode) respectively.

### Optional Agents
9. **researcher** - Technical exploration
10. **codebase-mapper** - Architecture analysis
11. **integration-checker** - Cross-phase validation
12. **performance-auditor** - Benchmarking

### Specialized Agents (9 agents)
13. **team-lead** - Orchestrator for team reviews (trigger: `em-agent:team-lead`)
14. **architect** - Architecture & technical design (trigger: `em-agent:architect`)
15. **frontend-expert** - React/Next.js, UI/UX, performance (trigger: `em-agent:frontend-expert`)
16. **backend-expert** - API design, performance, auth, error handling (trigger: `em-agent:backend-expert`)
17. **senior-code-reviewer** - *DEPRECATED* — Use code-reviewer with Deep mode (trigger: `em-agent:senior-code-reviewer` → redirects)
18. **database-expert** - Schema, queries, fintech patterns (trigger: `em-agent:database-expert`)
19. **product-manager** - Requirements, GAP analysis, market fit (trigger: `em-agent:product-manager`)
20. **security-reviewer** - OWASP Top 10 + STRIDE, blocking authority, unified with audit mode (trigger: `em-agent:security-reviewer`)
21. **staff-engineer** - Root cause analysis, cross-service impact (trigger: `em-agent:staff-engineer`)

### New Agents (v2.0.0)
22. **market-intelligence** - Market analysis, competitive intelligence (trigger: `em-agent:market-intelligence`)
23. **learn** - Knowledge management and cross-session learning
24. **autoplan** - Multi-phase review pipeline orchestrator
25. **techlead-orchestrator** - Distributed team coordination
26. **design-reviewer** - Visual design review with 6-pillar UI audit (trigger: `em-agent:design-reviewer`)
27. **devex-reviewer** - Developer experience audit and TTHW measurement (trigger: `em-agent:devex-reviewer`)
28. **iron-law-enforcer** - Gate enforcement for Iron Law compliance (trigger: `em-agent:iron-law-enforcer`)

### Expert Agents (v3.0.0)
29. **react-expert** - React/Next.js, hooks, state management, SSR (trigger: `em-agent:react-expert`)
30. **vue-expert** - Vue 3, Composition API, Pinia, Vue Router (trigger: `em-agent:vue-expert`)
31. **nestjs-expert** - NestJS, TypeScript backend, GraphQL, microservices (trigger: `em-agent:nestjs-expert`)
32. **devops-expert** - Docker, Kubernetes, Terraform, CI/CD, cloud (trigger: `em-agent:devops-expert`)
33. **mobile-expert** - Flutter, React Native, Android, iOS (trigger: `em-agent:mobile-expert`)
34. **spring-expert** - Spring Boot, JPA, security, microservices (trigger: `em-agent:spring-expert`)
35. **rust-expert** - Rust systems, ownership, async tokio, FFI (trigger: `em-agent:rust-expert`)

## Workflow Categories

### Primary Workflows
1. **new-feature** - From idea to production
2. **greenfield-app** - From blank directory to shipped application (12 stages, includes UI/UX design)
3. **bug-fix** - Investigate and fix bugs
4. **refactoring** - Improve code quality
5. **security-audit** - Security assessment

### Support Workflows
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
16. **code-review-9axis** - Deep 9-axis code review with Code Reviewer (Deep mode) & Security
17. **database-review** - Database schema & query review with Database Expert & Architect
18. **product-review** - Product/spec review with Product Manager & Architect
19. **security-review-advanced** - Advanced security (OWASP + STRIDE) with Security & Staff
20. **incident-response** - Production incident handling with Staff Engineer & Security

### Distributed Workflows (2 workflows)
21. **distributed-investigation** - Parallel bug investigation across full stack
22. **distributed-development** - Parallel feature development with multiple agents

### Product Workflows (2 workflows)
23. **discovery-process** - Product discovery and validation
24. **market-driven-feature** - Market-driven feature development

### Incident Sub-Workflows (workflows/incident/)
- **initial-triage** - First response and impact assessment
- **cross-service-impact** - Multi-service incident investigation
- **root-cause-analysis** - Systematic root cause identification
- **resolution-verification** - Verify fix and prevent regression
- **postmortem-prevention** - Postmortem and prevention measures
- **security-investigation** - Security-focused incident investigation

### Security Sub-Workflows (workflows/security/)
- **deep-investigation** - Deep security vulnerability investigation
- **owasp-assessment** - OWASP Top 10 assessment
- **stride-threat-modeling** - STRIDE threat modeling

## Iron Laws

From agent-skills and superpowers:

1. **TDD Iron Law**: NO PRODUCTION CODE WITHOUT FAILING TEST
2. **Debugging Iron Law**: NO FIXES WITHOUT ROOT CAUSE
3. **Spec Iron Law**: NO CODE WITHOUT SPEC (for features)
4. **Review Iron Law**: NO MERGE WITHOUT REVIEW

Enforced by: `agents/iron-law-enforcer.md`

## Development Lifecycle

```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SIMPLIFY → SHIP
```

### Workflow Selection

| Starting Point | Workflow |
|---|---|
| Blank directory + idea | greenfield-app |
| Existing codebase + feature | new-feature |
| Existing codebase + market opportunity | market-driven-feature |
| Technical bootstrapping only | project-setup |

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

## Special Features

### ✅ Browser Automation
- Headless browser for E2E testing
- DevTools MCP integration
- Visual QA capabilities
- Screenshot comparison

### ✅ MCP Integrations
- GitHub - Repository context
- Context7 - Documentation search
- Exa - Web research
- Memory - Cross-session learning
- Playwright - Browser automation

### ✅ Memory System
- Learn patterns across sessions
- Remember user preferences
- Track project conventions
- Build knowledge base

## Code Conventions

- All skills use enriched YAML frontmatter (name, description, version, category, origin, triggers, intent, scenarios, anti_patterns, related_skills)
- Skills follow standard format: Overview, When to Use, When NOT to Use, Anti-Patterns, Process, Coaching Notes, Verification, Related Skills
- Agents have Role Identity, Status Protocol, Coaching Mandate, completion markers, and handoff contracts
- Workflows follow 6-phase lifecycle (DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP) with verification gates
- Templates are reusable and versioned
- All communication follows `protocols/writing-style.md` (active voice, severity levels, executive summary first)
- Communication personality and density controlled via `style-switcher` skill (`/style`, `/compact`, `/terse`, `/standard`)

## Usage

### Using Skills
Invoke skills directly by name:
```
Use the brainstorming skill to explore this feature idea
Use the spec-driven-development skill to create a spec
Use the systematic-debugging skill to investigate this bug
```

### Using Agents
Dispatch agents for specialized tasks:
```
Agent: planner - Create implementation plan for feature X
Agent: code-reviewer - Review the changes in this PR
Agent: debugger - Investigate this bug systematically
```

### Using Workflows
Run end-to-end workflows:
```
Workflow: new-feature - Take this feature from idea to production
Workflow: bug-fix - Fix this bug systematically
Workflow: security-audit - Audit the codebase for security issues
```

## Tech Stack

- **Languages**: JavaScript/TypeScript, Python, Go, Rust, Java, Kotlin, Swift, Dart, C#, C++
- **Frontend**: React, Next.js, Vue, Nuxt, Svelte, Angular
- **Backend**: Node.js, NestJS, Express, FastAPI, Django, Spring Boot, Laravel, Gin
- **Mobile**: Flutter, React Native, Android (Kotlin), iOS (Swift), Tauri
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis, Elasticsearch
- **DevOps**: Docker, Kubernetes, Terraform, Ansible, GitHub Actions
- **Testing**: Jest, Vitest, Playwright, Cypress, pytest, JUnit
- **Tools**: Git, CI/CD, MCP, Draw.io, Figma

## Quality Gates

- [ ] All skills have YAML frontmatter
- [ ] All agents have completion markers
- [ ] All workflows have verification steps
- [ ] Documentation is complete
- [ ] Tests are passing
- [ ] Code review is done
- [ ] Security audit is passed

## Contributing

When adding new skills or agents:

1. Follow the established format
2. Include YAML frontmatter
3. Add verification steps
4. Test thoroughly
5. Document clearly

## Version

Current version: 3.4.0
Last updated: 2026-05-21
Changes: v3.4.0 — UI/UX integration into greenfield workflow: new Stage 5 (UI/UX Design) with frontend-expert agent producing UI-SPEC.md. Greenfield workflow v3.0.0 (12 stages). Crystallize stage generates design-system.md rule and UI-to-code map in PROJECT-DNA.md. Validation stage adds ux-audit + flow-discovery skills. Review stage adds ui-auditor + design-reviewer agents. Updated project-dna skill and templates. Total: 83 skills, 35 agents, 24 workflows.

## Automation

### CI Pipeline (.github/workflows/validate.yml)
- Validates YAML frontmatter in all skill files
- Checks SKILL.md symlinks are valid
- Validates related_skills references exist
- Checks agent required fields
- Verifies skill/agent count matches CLAUDE.md

### Hooks (hooks/)
- **pre-commit** - Type check, lint, unit tests, common issue detection
- **post-commit** - Auto-generates CHANGELOG entries from commit messages
- **commit-msg** - Commit message format validation
- **pre-push** - Pre-push quality gates
- **session-handoff** - Generates SESSION_HANDOFF.md at session end

### Session Continuity
- Run `scripts/session-handoff.sh` to generate a handoff document preserving context between sessions
- SESSION_HANDOFF.md is gitignored (local only)

### Code Provenance (.claude/lib/)
- **trace-store.ts** - Agent Trace Store following Agent Trace spec v0.1.0
- Tracks AI-generated code: contributor type, model, file ranges, commit/branch
- Usage: `const store = new TraceStore(projectRoot); store.saveFileEditTrace(filePath, 'ai', model, description);`

### Session Audit Logging (v3.2.0)
- **session-audit.ts** - Append-only JSONL audit log for user-AI conversations
- Toggle: `EM_TEAM_SESSION_AUDIT` env var in `.claude/settings.local.json`
- Log location: `.em-team/logs/audit-YYYY-MM-DD.jsonl` (gitignored)
- CLI: `bash scripts/session-audit.sh {status|stats|recent|by-skill|rotate}`

### Artifact Export (v3.2.0)
- **artifact-store.ts** - Export skill outputs (specs, plans, reviews) as Markdown
- Toggle: `EM_TEAM_ARTIFACT_EXPORT` env var in `.claude/settings.local.json`
- Output dirs: `brainstorm/`, `specs/`, `plans/`, `reviews/`, `architecture/` (in cwd)
- CLI: `bash scripts/artifact-register.sh {list|stats|recent|by-skill|clean}`

### Custom MCP Servers (.claude/mcp-servers/)
- **github-enhanced.js** - Extended GitHub: auto-labeled issues, agent task tracking, PR creation with quality reports, review status
- **project-context.js** - Codebase analysis: structure tree, dependencies, agent config, LOC metrics, recent git changes
- Requires: `npm install` (installs @modelcontextprotocol/sdk, @octokit/rest)
- Requires env vars: `GITHUB_TOKEN`, `REPOSITORY=owner/repo`

### Operational Rules (.claude/rules/)
- **mistakes.md** - Mistake ledger recording past failures and prevention patterns
- **context-management.md** - Guidelines for efficient context window usage

## License

MIT License - Feel free to use and adapt for your projects

# EM-Team - Fullstack Engineering Agent/Skill/Workflow System

## Overview

EM-Team is a comprehensive system of agents, skills, and workflows for fullstack engineering, synthesized from the best practices of 6 top AI agent/workflow repositories:

- **Product-Manager-Skills** (47 skills) - 3-tier architecture, coaching approach, interactive flows
- **agent-skills** (20 skills) - Development lifecycle, Iron Laws, 5-axis code review
- **everything-claude-code** (185+ skills) - Multi-language support, framework-specific patterns
- **get-shit-done** (GSD) - Spec-driven development, atomic commits, multi-layer QA
- **gstack** (28 skills) - Team-in-a-box, velocity multiplier, browser-in-CLI
- **superpowers** (16 skills) - Iron Laws, subagent-driven development, systematic debugging

## Hermes Execution Protocol (v4.0.0)

All agents, skills, and workflows follow the Hermes protocol for maximum steerability and tool precision.

### Agent Structure
Every agent file uses structured blocks instead of prose sections:
- `[ROLE]` — Imperative role definition (1-2 sentences)
- `[OBJECTIVE]` — End goal
- `[RULES]` — Numbered imperative rules (includes `<thought>` instruction, Iron Laws, ABC coaching)
- `[AVAILABLE SKILLS]` — Skills the agent can invoke
- `[PROCESS]` — Concise execution steps
- `[RESPONSE FORMAT]` — References `output_schema` in frontmatter
- `[HANDOFF]` — Who receives output next

### Skill JSON Schema
Every skill has `input_schema`, `output_schema`, `error_schema` in YAML frontmatter:
```yaml
input_schema:
  type: object
  required: [task_description]
  properties:
    task_description: { type: string }
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
```

### Workflow ReAct Protocol
Every workflow stage uses Thought→Action→Observation loops with context pruning:
```
<thought>Observe → Analyze → Plan</thought>
<action>type: invoke_agent, target: ..., params: ...</action>
<observation>result → gate_status: PASS|FAIL</observation>
```

### LLM Provider Configuration
Set `LLM_PROVIDER` to switch between endpoints:
- `anthropic` (default) — Claude via api.anthropic.com
- `openai` — GPT models via api.openai.com
- `ollama` — Local models (Hermes 3, Llama, etc.) via localhost:11434
- `vllm` — vLLM server via localhost:8000
- `custom` — Any OpenAI-compatible endpoint

Config: `LLM_PROVIDER`, `LLM_BASE_URL`, `LLM_API_KEY`, `LLM_MODEL` env vars.

### Validation
```bash
bash scripts/validate-hermes.sh          # Check all compliance
bash scripts/validate-hermes.sh --verbose # Detailed output
```

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
├── skills/              # 89 skills
│   ├── foundation/      # 11 core foundational skills
│   ├── development/     # 12 methodology skills (TDD, architecture, debugging, etc.)
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
│   ├── quality/         # 14 quality assurance skills
│   ├── workflow/        # 13 workflow and automation skills
│   └── additional/      # 5 product & discovery skills
├── agents/              # 36 agents
│   └── _shared/         # Shared preambles (expert-preamble for 7 expert agents)
├── workflows/           # 27 end-to-end workflows
│   └── _shared/         # Reusable sub-stages (stage-0-git-bootstrap)
├── .claude/
│   ├── lib/             # Libraries (trace-store, session-audit, artifact-store)
│   ├── mcp-servers/     # Custom MCP servers (GitHub enhanced, Project context)
│   └── rules/           # Operational rules (mistakes ledger, context management)
├── templates/           # Reusable templates + context artifacts
│   ├── context-artifacts/ # PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md, WBS.md, ISSUE-REGISTER.md, CHANGE-LOG.md, ACCEPTANCE-CHECKLIST.md
│   └── project-dna/      # Templates for generated agent guidance (CLAUDE.md, rules, traceability)
├── preambles/           # Shared initialization (ethos, skill preamble, agent preamble)
├── protocols/           # Communication & error standards (writing-style, delegation, distributed-messaging, change-management, review-gates, error-handling, naming-convention, report-format)
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

### Foundation Skills (11 skills)
1. **alignment-session** - Pre-coding human-AI alignment
2. **spec-driven-development** - Write specs before coding
3. **brainstorming** - Explore ideas into designs
4. **context-engineering** - Optimize agent context setup
5. **writing-plans** - Break work into bite-sized tasks
6. **systematic-debugging** - 4-phase debugging methodology
7. **domain-modeling** - Bounded contexts, entities, relationships, ubiquitous language
8. **project-dna** - Crystallize decisions into agent guidance (CLAUDE.md, rules, traceability)
9. **basic-design** - Formal 基本設計 (Basic Design Document) for Japanese outsourcing
10. **detailed-design** - Formal 詳細設計 (Detailed Design) per module before implementation
11. **brownfield-onboarding** - Scan brownfield codebase → build module-based business context (.em-brownfield/)

### Development Skills (12 methodology skills)
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
18. **codebase-architecture** - Research modern architecture patterns, present options, generate architecture-specific rules

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

### Quality Skills (14 skills)
52. **code-review** - 5-axis review framework
53. **code-simplification** - Reduce complexity
54. **browser-testing** - UI State Matrix + a11y/i18n + DevTools MCP + video evidence (consumes test-case-design output)
55. **performance-optimization** - Measure-first optimization
56. **e2e-testing** - Playwright + user-journey edge-case matrix (interruption/concurrency/permission/a11y/i18n/resilience) (consumes test-case-design output)
57. **security-audit** - Vulnerability assessment
58. **api-testing** - OWASP API Top 10 + non-functional (idempotency/pagination/content-neg/rate-limit) (consumes test-case-design output)
59. **security-common** - OWASP reference and security checklist
60. **ux-audit** - Behavioral UX audit with scored dimensions
61. **plan-tune** - Learn and tune output preferences
62. **flow-discovery** - Discovery flow pattern identification
63. **test-generation** - Auto-generate tests with 12-column TC-REGISTRY (Technique/Oracle/Risk), risk-calibrated ratios, mutation gate
63a. **test-case-design** - Systematic QA test-design techniques (BVA, EP, Decision Table, State Transition, Pairwise, Risk-Based) + abuse + non-functional + oracle + mutation gate. MANDATORY upstream of test-generation/api-testing/e2e-testing/browser-testing for non-trivial features.
64. **uat-process** - Formal 受け入れテスト (User Acceptance Testing) with sign-off

### Workflow Skills (14 skills)
65. **git-workflow** - Atomic commits
66. **ci-cd-automation** - Feature flags, quality gates
67. **documentation** - ADRs, API docs
68. **finishing-branch** - Merge/PR decisions
69. **deprecation-migration** - Code-as-liability mindset
70. **style-switcher** - Unified personality styles (13) and density modes (3)
71. **progress-reporting** - Formal 進捗報告 (weekly progress reports) with metrics and escalation
72. **github-cicd-setup** - Detect stack → auto-generate `.github/workflows/ci.yml` with lint/typecheck/test/build
73. **github-pr-manager** - PR creation with template auto-fill + review comment AI-assisted fix
74. **github-issue-manager** - Issue creation, triage (labels/priority/duplicates), sprint planning with milestones
75. **github-release-manager** - Version bump, release notes, git tag, GitHub Release with artifacts
76. **github-issue-fix** - Browse GitHub issues, select one, and hand off to em-wf:bug-fix workflow with full issue context
77. **brownfield-context-sync** - Detect drift between .em-brownfield/ context and codebase, resolve cross-module contract breaks
78. **brownfield-pr-impact** - Assess PR/branch impact on brownfield business flows, surface AC-at-risk and contract breaks before merge

### Additional Skills (5 skills)
79. **jobs-to-be-done** - JTBD framework for understanding user needs
80. **lean-ux-canvas** - Lean UX hypothesis testing
81. **opportunity-solution-tree** - Product opportunity mapping
82. **pol-probe** - Product opportunity probe
83. **office-hours** - YC-style brainstorming and idea validation

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

### Optional Agents
9. **researcher** - Technical exploration
10. **codebase-mapper** - Architecture analysis
11. **integration-checker** - Cross-phase validation
12. **performance-auditor** - Benchmarking

### Specialized Agents (8 agents)
13. **team-lead** - Orchestrator for team reviews (trigger: `em-agent:team-lead`)
14. **architect** - Architecture & technical design (trigger: `em-agent:architect`)
15. **frontend-expert** - React/Next.js, UI/UX, performance (trigger: `em-agent:frontend-expert`)
16. **backend-expert** - API design, performance, auth, error handling (trigger: `em-agent:backend-expert`)
17. **database-expert** - Schema, queries, fintech patterns (trigger: `em-agent:database-expert`)
18. **product-manager** - Requirements, GAP analysis, market fit (trigger: `em-agent:product-manager`)
19. **security-reviewer** - OWASP Top 10 + STRIDE, blocking authority, unified with audit mode (trigger: `em-agent:security-reviewer`)
20. **staff-engineer** - Root cause analysis, cross-service impact (trigger: `em-agent:staff-engineer`)

### New Agents (v2.0.0)
21. **market-intelligence** - Market analysis, competitive intelligence (trigger: `em-agent:market-intelligence`)
22. **learn** - Knowledge management and cross-session learning
23. **autoplan** - Multi-phase review pipeline orchestrator
24. **techlead-orchestrator** - Distributed team coordination
25. **design-reviewer** - Visual design review with 6-pillar UI audit (trigger: `em-agent:design-reviewer`)
26. **devex-reviewer** - Developer experience audit and TTHW measurement (trigger: `em-agent:devex-reviewer`)
27. **iron-law-enforcer** - Gate enforcement for Iron Law compliance (trigger: `em-agent:iron-law-enforcer`)

### Expert Agents (v3.0.0)
28. **react-expert** - React/Next.js, hooks, state management, SSR (trigger: `em-agent:react-expert`)
29. **vue-expert** - Vue 3, Composition API, Pinia, Vue Router (trigger: `em-agent:vue-expert`)
30. **nestjs-expert** - NestJS, TypeScript backend, GraphQL, microservices (trigger: `em-agent:nestjs-expert`)
31. **devops-expert** - Docker, Kubernetes, Terraform, CI/CD, cloud (trigger: `em-agent:devops-expert`)
32. **mobile-expert** - Flutter, React Native, Android, iOS (trigger: `em-agent:mobile-expert`)
33. **spring-expert** - Spring Boot, JPA, security, microservices (trigger: `em-agent:spring-expert`)
34. **rust-expert** - Rust systems, ownership, async tokio, FFI (trigger: `em-agent:rust-expert`)

### Test Automation Agents (v3.8.0)
35. **playwright-setup** - Playwright infrastructure setup for brownfield projects: auto-detects stack, installs browsers, generates config, scaffolds POM, generates auth config (4 strategies: none/credentials/oauth/storageState) (trigger: `em-agent:playwright-setup`)
36. **brownfield-test-engineer** - Spec-to-test for existing codebases: asks clarifying questions when spec unclear, explores codebase, generates TC registry, writes and executes tests, hands to test-verifier (trigger: `em-agent:brownfield-test-engineer`)
37. **test-verifier** - Double-checks test results with retry loop (max 3): re-runs only failed tests, applies fix suggestions per retry, outputs PASS with confidence score or FAIL with per-TC details + manual steps (trigger: `em-agent:test-verifier`)

## Workflow Categories

### Primary Workflows
1. **new-feature** - From idea to production
2. **greenfield-app** - From blank directory to shipped application (12 stages, includes UI/UX design)
3. **bug-fix** - Investigate and fix bugs
4. **refactoring** - Improve code quality
5. **security-audit** - Security assessment
6. **qa-bug-hunter** - QA testing with human-gated GitHub issue creation (DISCOVER → EVIDENCE → PREPARE → HUMAN GATE → LOG)
7. **brownfield-investigation** - Context-aware bug investigation for brownfield projects (CONTEXT LOAD → REPRODUCE → ROOT CAUSE → EVIDENCE → HUMAN GATE → CONTEXT UPDATE)

### Support Workflows
7. **project-setup** - Initialize new projects
8. **documentation** - Generate and update docs
9. **deployment** - Deploy and monitor
10. **retro** - Learn and improve
11. **ship-workflow** - Version bump, changelog, PR creation
12. **canary-monitoring** - Post-deploy health monitoring

### Master Workflow
13. **six-phase-lifecycle** - DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP (all workflows inherit this)

### Team Workflows (8 workflows)
14. **team-review** - Full team review orchestrated by Team Lead
15. **architecture-review** - Architecture review with Architect & Staff Engineer
16. **design-review** - UI/UX design review with Frontend Expert & Product Manager
17. **code-review-9axis** - Deep 9-axis code review with Code Reviewer (Deep mode) & Security
18. **database-review** - Database schema & query review with Database Expert & Architect
19. **product-review** - Product/spec review with Product Manager & Architect
20. **security-review-advanced** - Advanced security (OWASP + STRIDE) with Security & Staff
21. **incident-response** - Production incident handling with Staff Engineer & Security

### Distributed Workflows (2 workflows)
22. **distributed-investigation** - Parallel bug investigation across full stack
23. **distributed-development** - Parallel feature development with multiple agents

### Product Workflows (2 workflows)
24. **discovery-process** - Product discovery and validation
25. **market-driven-feature** - Market-driven feature development

### Outsourcing Workflows (1 workflow)
26. **japanese-outsourcing** - End-to-end Japanese outsourcing workflow with 基本設計, 詳細設計, 受け入れテスト, formal gates

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

## Protocols

The `protocols/` directory contains 8 communication and process standards:

| Protocol | Purpose |
|----------|---------|
| **writing-style.md** | Active voice, severity levels, executive summary first |
| **delegation-protocol.md** | Agent-to-agent delegation rules |
| **distributed-messaging.md** | Messaging format for distributed agents |
| **change-management.md** | Change request and approval process |
| **review-gates.md** | Verification gate definitions between phases |
| **error-handling.md** | Standardized error taxonomy (CONTEXT_OVERFLOW, BUILD_DEADLOCK, etc.) with retry policy (`max_retries_per_stage: 2`) |
| **naming-convention.md** | Entry point naming rules for \`.claude/skills/\` (\`em-agent:{name}\`, \`em-wf:{name}\`, \`em-skill:{name}\`) |
| **report-format.md** | Standard report output format |

## Shared Components

### Agent Shared (`agents/_shared/`)
- **expert-preamble.md** — Shared input/output schemas, response format rules, and Iron Law references for all 7 expert domain agents (react-expert, vue-expert, nestjs-expert, devops-expert, mobile-expert, spring-expert, rust-expert)

### Workflow Shared (`workflows/_shared/`)
- **stage-0-git-bootstrap.md** — Reusable Stage 0 (SETUP) for workflows that need git branch creation and spec document bootstrapping. Used by `new-feature` and `bug-fix`. Parameterized with `{doc_type}`, `{branch_pattern}`, `{next_action}`.

## Brownfield Intelligence (v5.4.0)

Module-based business context system for existing codebases. Creates `.em-brownfield/` directory with per-module artifacts that agents load before investigation, testing, or development.

### Components
| Component | Type | Purpose |
|-----------|------|---------|
| `brownfield-onboarding` | Skill (foundation) | Scan codebase → auto-detect stack → generate context artifacts with quality gate |
| `brownfield-investigation` | Workflow (primary) | Context-aware bug investigation with evidence package + EVIDENCE.json manifest |
| `brownfield-context-sync` | Skill (workflow) | Symbol-based drift detection, CONTRACT_BREAK priority for interface changes |
| `brownfield-pr-impact` | Skill (workflow) | PR/branch impact on business flows — surface AC-at-risk + contract breaks before merge |
| `flow-discovery` (enhanced) | Skill (quality) | Bidirectional ENRICH+SYNC — auto-detect module, 3-tier matching, propose FLOWS.md updates |
| `templates/brownfield/` | Templates (12 files) | MODULE-FLOWS (md+json), MODULE-DOMAIN, MODULE-INTEGRATIONS, MODULE-CODE-MAP (md+json), INDEX (md+json), DOMAIN-PROFILE (md+yaml), EVIDENCE-MANIFEST.json, HEALTH-CHECK, INVESTIGATION-REPORT |
| `scripts/brownfield/` | Scripts (8 scripts) | detect-stack, scan-nestjs, scan-react, scan-monorepo, symbol-resolver, build-backlinks, validate-refs, quality-score |

### Architecture
```
.em-brownfield/
├── INDEX.md                    # Module registry + dependency graph
├── INDEX.json                  # Machine-readable index (schema_version: "5.4.0")
├── DOMAIN-PROFILE.md           # Project-wide domain facts (tech stack, DB, auth, compliance)
├── DOMAIN-PROFILE.yaml         # Structured domain profile for programmatic consumption
├── BACKLINKS.json              # Reverse-dependency index (auto-built by build-backlinks.sh)
├── QUALITY-SCORE.json          # Per-module quality grades (A/B/C/D, auto-built)
├── HEALTH-CHECK.md             # Per-module health scores
└── modules/
    ├── {business-domain}/      # 1 folder per bounded context
    │   ├── FLOWS.md            # Business flows (happy path, rules, AC, known issues)
    │   ├── FLOWS.json          # JSON sidecar for programmatic AC→TC mapping
    │   ├── DOMAIN.md           # Entities, relationships, ubiquitous language, PII table
    │   ├── INTEGRATIONS.md     # External services + internal module deps
    │   ├── CODE-MAP.md         # Flow steps → Symbol.method (stable, not fragile file:line)
    │   └── CODE-MAP.json       # JSON sidecar for agent tooling
    └── ...
```

### Stable Flow IDs
Every flow is assigned a permanent `FLOW-{MODULE}-{NNN}` ID and every acceptance criterion an `AC-{MODULE}-{NNN}` ID. IDs are stable across refactors — agents and tests reference them by ID, not by fragile line numbers.

### Scripts (`scripts/brownfield/`)
| Script | Purpose |
|--------|---------|
| `detect-stack.sh` | Auto-detect tech stack (NestJS/React/monorepo/etc.) |
| `scan-nestjs.sh` | Extract NestJS controllers, services, modules |
| `scan-react.sh` | Extract React pages, hooks, components |
| `scan-monorepo.sh` | Handle monorepo workspace layouts |
| `symbol-resolver.sh` | Resolve `Class.method` symbol → `file:line` at runtime |
| `build-backlinks.sh` | Build BACKLINKS.json reverse-dependency index |
| `validate-refs.sh` | Verify all cross-module refs resolve (exit 0 = clean) |
| `quality-score.sh` | Grade each module A/B/C/D, output QUALITY-SCORE.json |

### Quality Gate
Run before shipping context artifacts:
```bash
bash scripts/brownfield/validate-refs.sh .em-brownfield/   # 0 broken refs
bash scripts/brownfield/quality-score.sh .em-brownfield/   # Grade A = ready
```

### Integration Points
| Agent/Workflow | Brownfield Integration |
|---------------|----------------------|
| `debugger` | Phase 0: load `.em-brownfield/INDEX.md` + affected module context |
| `verifier` | Phase 0: load context; Phase 3: check AC-{MODULE}-{NNN} regression |
| `brownfield-test-engineer` | Step 0a-0e: FLOWS.json→AC→TC; DOMAIN.json→fixtures; INTEGRATIONS.md→negative TCs; DOMAIN-PROFILE.yaml→auto risk_tier |
| `new-feature` | Stage 0.5: context load; Stage 5.7: context update after build |
| `bug-fix` | Stage 0.5: auto-route to brownfield-investigation if `.em-brownfield/` exists |

### Cross-References
Every module artifact has `Dependencies` + `Depended By` sections:
```markdown
## Dependencies
- [payment](../payment/FLOWS.md) — charges customer after order confirmed
## Depended By
- [notification](../notification/FLOWS.md) — sends confirmation after order complete
```

### Design Principles
- **Thoroughness > Speed** — Agent traces deeply through module chains, never guesses
- **Semi-auto** — Agent scans and proposes, user confirms and refines
- **Module = business domain** — Organized by bounded contexts, not technical directories
- **Symbol-first refs** — CODE-MAP uses `Class.method` stable symbols, resolved at runtime
- **Ask when unclear** — Clarifying questions protocol for ambiguous situations

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

Current version: 5.5.0
Last updated: 2026-05-27
Changes: v5.5.0 — Naming Convention Refactor + Alias Cleanup: Replaced flat `em:{name}` namespace with explicit type prefixes: `em-agent:{name}` (agents), `em-wf:{name}` (workflows), `em-skill:{name}` (skills). Eliminates ambiguity between agents and workflows. Consolidation: 4 code-review entry points → 2 (em-agent:code-reviewer + em-wf:code-review); 4 security entry points → 3 (em-agent:security-reviewer + em-wf:security-audit + em-wf:security-review-advanced). Deleted deprecated agents: senior-code-reviewer, security-auditor. Deleted 14 short-name aliases (em-agent:debug/backend/frontend/database/team/test/verify/performance/research/code-review, em-wf:distributed/incident/refactor/ship) — each had a canonical full-name equivalent. install.sh now uses 3 separate command directories (em-agent/, em-wf/, em-skill/) for correct slash command invocation keys. protocols/naming-convention.md fully rewritten. Migration script: scripts/migration/migrate-names.sh. Total: 86 skills, 36 agents, 27 workflows. v5.4.0 — Brownfield Intelligence v5.4.0 Improvements: 19 gaps closed across 4 phases (G1-G14, G21-G25). New skill: brownfield-pr-impact (workflow) — assesses PR/branch impact on brownfield business flows, surfaces AC-at-risk and contract breaks before merge. 8 new scripts in scripts/brownfield/: detect-stack.sh (auto-detect tech stack), scan-nestjs.sh, scan-react.sh, scan-monorepo.sh, symbol-resolver.sh (Class.method → file:line runtime resolver), build-backlinks.sh, validate-refs.sh (exit 0 = clean refs), quality-score.sh (Grade A/B/C/D). 6 new templates: DOMAIN-PROFILE.yaml.template, EVIDENCE-MANIFEST.json.template, INDEX.json.template, MODULE-FLOWS.json.template, MODULE-CODE-MAP.json.template, INVESTIGATION-REPORT.md. JSON sidecars (FLOWS.json, CODE-MAP.json, INDEX.json) for programmatic agent access without markdown parsing. Stable FLOW-{MODULE}-{NNN} + AC-{MODULE}-{NNN} IDs across all flows. Symbol-first CODE-MAP refs (Class.method, not fragile file:line). PII/Sensitive Fields table + Data Subject Rights checklist in MODULE-DOMAIN. 12-domain detection table + Unknown/Custom protocol. Quality gate: validate-refs.sh + quality-score.sh Grade A required. Privacy Phase 3-pre in onboarding. Test discovery Phase 3-extra. Monorepo Phase 2-extra. Integration upgrades: debugger Phase 0 brownfield load; verifier Phase 0 load + Phase 3 AC regression check; brownfield-test-engineer Step 0a-0e full context bootstrap; new-feature Stage 0.5 + Stage 5.7; bug-fix Stage 0.5 auto-routing. brownfield-investigation Stage 3 evidence package (EVIDENCE.json manifest + ASCII tree) + Stage 5 active context update (6 steps, Gate 5). flow-discovery Step 3b bidirectional ENRICH+SYNC. brownfield-context-sync symbol-based resolver. hooks/brownfield-pr-check pre-push non-blocking hook. End-to-end test on ras-app: 55 files, 8 modules, Grade A (100/100), 193 refs / 0 broken. Total: 90 skills, 38 agents, 27 workflows. v5.3.0 — Architect/Code/Review Quality Upgrade: new-feature v3.3.0 + bug-fix v3.2.0: Code-review diff scan moved to FIRST step of VERIFY stage (Step 5.1) — runs BEFORE test suite so any review fixes are validated by tests, not bypassed. Rollback readiness gate added (Stage 6.1) before marking feature/fix shipped. Handoff contracts strengthened with on_failure + retry_budget + escalation_path. spec-driven-development v3.1.0: Testability check upgraded from advisory → hard gate (⛔ TESTABILITY GATE — spec BLOCKED until all criteria pass); conflict detection added (Phase 1.5 — performance/auth/data-model/scope contradictions must be resolved before PLAN); Assumption Approval Gate requires explicit user sign-off. architect v2.1.0: Phase 0 (existing architecture snapshot before analysis — prevents pattern churn without evidence); Phase 7 (ADR Generation MANDATORY — Decision/Context/Alternatives/Consequences/Compliance Criteria 3-5 rules); output_schema extended with adr + compliance_criteria[]; handoff contract gains on_failure. architecture-review v2.2.0: Stage 0 entry criteria gate (4 mandatory checkboxes — blocks review if problem/spec/scope undefined); Gate 3 now requires ADR + compliance criteria + docs/adr/ commit; Post-Review: Compliance Monitoring section. code-review v3.1.0 + code-reviewer v2.1.0: Step/Phase 1.5 diff classification (NEW/MODIFIED/DELETED per file); Step/Phase 4.5 cross-file impact scan (callers, dependents, shared state, contract changes — escalate if >5 callers); Testing axis upgraded with branch coverage, mutation immunity, edge cases, regression risk. Total: 89 skills, 38 agents, 27 workflows. v5.2.0 — TC-Code Coverage Gate: Closes enforcement gap where TC-REGISTRY (design doc) was never guaranteed to have corresponding test() code. All 5 consumer skills now have explicit TC-code coverage bash gates (api-testing v4.1.0, e2e-testing v4.2.0, browser-testing v4.2.0, test-generation v4.1.0). Agents (test-engineer v3.2.0, brownfield-test-engineer v3.2.0) require 100% TC-ID→test() mapping per layer. test-verifier v2.2.0 adds Step 2.5 pre-retry TC coverage check + formal completion marker. Gate added to six-phase-lifecycle Gate 4 and new-feature Gate 4+5. TC-REGISTRY.template.md quality gate updated. Convention: unautomated TCs use test.todo(); never drop a TC-ID silently. Total: 89 skills, 38 agents, 27 workflows. v5.1.0 — Testing Skills Expert-QC Upgrade: New `test-case-design` skill centralizes systematic QA test-design techniques (BVA, EP, Decision Table, State Transition, Pairwise, Risk-Based Testing) plus abuse cases, non-functional cases, oracle specification, and a mutation sanity gate. `test-generation`, `api-testing`, `e2e-testing`, `browser-testing` now MANDATORY invoke `test-case-design` first and enforce 12-column TC-REGISTRY with Technique/Oracle/Risk columns. Risk-calibrated negative + abuse + non-functional ratio floors (P0: >=35%+15%+10%, P1: >=30%+10%+10%, P2: >=25%+5%+5%, P3: >=25%). Mutation Sanity Check is a gate, not advice. `api-testing` covers OWASP API Top 10 (BOLA/BFLA/mass assignment/SSRF/...) + idempotency + pagination/filter/sort boundaries + content negotiation + rate-limit modalities + error envelope. `e2e-testing` adds full user-journey edge-case matrix (interruption: refresh/back-button/tab-switch/network-drop/session-expiry; concurrency: double-submit/2-tabs; permission downgrade; a11y; i18n; resilience). `browser-testing` adds UI State Matrix (loading/empty/partial/4xx/5xx/success/permission-denied/stale/mutation-pending/success/failure/optimistic-rollback) and A11y/I18n checklist. Agents `test-engineer` and `brownfield-test-engineer` updated to require test-case-design, technique attribution per TC, and risk-calibrated ratios. New canonical `templates/TC-REGISTRY.template.md` (12 cols). `testing-standards.template.md` adds TC-REGISTRY reference, risk-calibrated floors, required techniques, mandatory oracle spec, mutation sanity gate. `spec-template.md` adds REQUIRED sections: Negative Scenarios, Abuse Scenarios (OWASP-mapped), Non-Functional Acceptance Criteria, Risk Tier declaration. Total: 89 skills, 38 agents, 27 workflows. v5.0.0 — Brownfield Intelligence: Module-based business context system for brownfield projects. New `brownfield-onboarding` skill (foundation) scans codebase → discovers business domains → generates per-module FLOWS.md, DOMAIN.md, INTEGRATIONS.md, CODE-MAP.md with cross-references. Semi-auto: agent scans, user confirms. Thoroughness > speed. New `brownfield-investigation` workflow with 6 stages: CONTEXT LOAD → REPRODUCE → ROOT CAUSE → EVIDENCE → HUMAN GATE → CONTEXT UPDATE. Deep chain tracing through module dependencies. Evidence includes business narrative + blast radius. New `brownfield-context-sync` skill (workflow) detects drift between .em-brownfield/ and codebase, with CONTRACT_BREAK priority for cross-module interface changes. Enhanced `flow-discovery` skill with optional business metadata layer (brownfield_context input → Step 3b ENRICH). 6 new templates in templates/brownfield/. Total: 88 skills, 38 agents, 27 workflows. v4.1.0 — QA Bug Hunter: New `qa-bug-hunter` workflow with human-gated GitHub issue creation. 7 stages: SETUP → DISCOVER → EVIDENCE → PREPARE → HUMAN GATE → LOG → SUMMARY. Per-bug loop with user verification before each issue is created. Reuses em-agent:qa, flow-discovery, browser-testing, github-issue-manager skills. New `github-issue-fix` skill bridges GitHub Issues to em-wf:bug-fix workflow. Added `protocols/error-handling.md` (standardized error taxonomy), `protocols/naming-convention.md` (entry point naming rules), `agents/_shared/expert-preamble.md` (shared schemas for expert agents), `workflows/_shared/stage-0-git-bootstrap.md` (reusable git bootstrap), `scripts/benchmark-quality.sh` (quality scoring). Total: 86 skills, 38 agents, 26 workflows. v4.0.0 — Hermes Protocol Refactor: Full codebase restructured following NousResearch Hermes philosophy for Absolute Steerability, Flawless Tool Use, and Local/Cloud Agnostic execution. All 38 agents restructured with [ROLE], [OBJECTIVE], [RULES], [AVAILABLE SKILLS], [PROCESS], [RESPONSE FORMAT], [HANDOFF] blocks + input_schema/output_schema in YAML frontmatter. All 85 skills upgraded with JSON Schema (input_schema, output_schema, error_schema) in frontmatter for strict function calling contracts. All 25 workflows converted to ReAct protocol (Thought→Action→Observation loops) with context pruning and state snapshots. Preambles rewritten as Hermes-native (imperative, structured blocks). LLM client made provider-agnostic via scripts/llm-config.sh — supports Anthropic, OpenAI, Ollama, vLLM, and custom endpoints via LLM_PROVIDER/LLM_BASE_URL/LLM_MODEL env vars. ChatML formatter included for local Hermes models. Validation script (scripts/validate-hermes.sh) checks schema presence, block structure, and language compliance. Total: 85 skills, 38 agents, 25 workflows. v3.10.0 — Feature Workspace: artifact-store.ts v3.0.0 with createWorkspace(), upsert() for living docs (SPEC.md, TC-REGISTRY.md updated in place), workspaceExport() for timestamped logs (test-executions, reviews, evidence). .em-feature-context tracks active feature across prompts for cross-iteration continuity. ITERATION-LOG.md auto-tracks what changed per iteration. artifact-register.sh adds workspace/context commands. All workflows updated with workspace creation instructions. Agents (brownfield-test-engineer, test-verifier) support workspace-first export with legacy fallback. Total: 85 skills, 38 agents, 25 workflows. v3.9.0 — Artifact Folder Structure + Playwright Auth Config: artifact-store.ts upgraded with workflowContext param for sub-folder routing (specs/new-feature/, test-reports/bug-fix/, etc.), new category mappings for agent outputs (test-reports, architecture). Playwright auth config system: 4 strategies (none, credentials, oauth, storageState) via e2e/config/auth.config.json, auto-generated by playwright-setup agent. Credentials from .env (never committed), OAuth uses manual-first storageState approach. All workflows (new-feature, bug-fix, refactoring, greenfield-app) updated with Artifact Export sections. artifact-register.sh updated for sub-folder scanning. New template: E2E-AUTH-CONFIG.template.md. Total: 85 skills, 38 agents, 25 workflows. v3.8.0 — Test Automation Chain: 3 new agents (playwright-setup, brownfield-test-engineer, test-verifier) + test-generation/e2e-testing/browser-testing wired into all VERIFY stages (greenfield-app Stage 10, new-feature Stage 5, bug-fix Stage 5, refactoring Stage 4, six-phase-lifecycle Phase 4). brownfield-test-engineer asks clarifying questions when spec unclear; test-verifier retries max 3 times with targeted fix suggestions per attempt. Total: 85 skills, 38 agents, 25 workflows. v3.7.0 — GitHub Management Suite: 4 new skills (github-cicd-setup, github-pr-manager, github-issue-manager, github-release-manager) + 12 commands (setup-cicd, pr-create, pr-fix, issue-create, issue-triage, issue-sprint, release, pr-merge, pr-review, branch-create, dep-review, stale-issues). Total: 85 skills, 35 agents, 25 workflows. v3.6.0 — Codebase architecture intelligence: new `codebase-architecture` skill researches modern architecture patterns (Clean/Hexagonal/Modular Monolith/FSD/Vertical Slice/CQRS), presents 2-3 best-fit options with project-specific file structures and trade-offs, generates 3 architecture-specific rule files (boundaries, conventions, patterns). New templates: design-system.template.md, architecture-conventions.template.md, architecture-patterns.template.md. Greenfield Stage 6 upgraded to use `codebase-architecture` skill. v3.5.0 — Japanese outsourcing support. Total: 85 skills, 35 agents, 25 workflows.

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

### Quality Benchmark (scripts/benchmark-quality.sh)
- Scores every skill, agent, and workflow against 5 quality rubrics (B1–B5)
- B1: Skill instruction quality (frontmatter, sections, coaching notes)
- B2: Agent structure quality (Hermes blocks, schemas, handoff)
- B3: Workflow protocol quality (ReAct, gates, error handling)
- B4: Cross-reference integrity (related_skills, agent→skill refs)
- B5: Consistency & hygiene (naming, versioning, no duplicates)
- Grades: A+ (95+), A (90+), B+ (85+), B (80+), C+ (75+), C (70+), D (<70)
- Usage: `bash scripts/benchmark-quality.sh` or `bash scripts/benchmark-quality.sh --verbose`

### Operational Rules (.claude/rules/)
- **mistakes.md** - Mistake ledger recording past failures and prevention patterns
- **context-management.md** - Guidelines for efficient context window usage

## License

MIT License - Feel free to use and adapt for your projects

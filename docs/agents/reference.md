# Agent Reference

Agents are specialized AI roles invoked via `/em-agent:{name}`. Each encapsulates deep expertise for a specific engineering domain. They can run standalone or be composed by orchestrators (team-lead, techlead-orchestrator). All agents follow the Hermes protocol and enforce Iron Laws.

---

## Quick Navigation

| Category | Agents |
|---|---|
| **Core** | [planner](#em-agentplanner) · [executor](#em-agentexecutor) · [code-reviewer](#em-agentcode-reviewer) · [verifier](#em-agentverifier) · [debugger](#em-agentdebugger) |
| **Test Automation** | [playwright-setup](#em-agentplaywright-setup) · [brownfield-test-engineer](#em-agentbrownfield-test-engineer) · [test-verifier](#em-agenttest-verifier) · [test-engineer](#em-agenttest-engineer) |
| **Orchestrators** | [team-lead](#em-agentteam-lead) · [techlead-orchestrator](#em-agenttechlead-orchestrator) |
| **Expert — Frontend** | [react-expert](#em-agentreact-expert) · [vue-expert](#em-agentvue-expert) · [frontend-expert](#em-agentfrontend-expert) · [mobile-expert](#em-agentmobile-expert) |
| **Expert — Backend** | [nestjs-expert](#em-agentnestjs-expert) · [backend-expert](#em-agentbackend-expert) · [spring-expert](#em-agentspring-expert) · [rust-expert](#em-agentrust-expert) |
| **Expert — Data/Infra** | [database-expert](#em-agentdatabase-expert) · [devops-expert](#em-agentdevops-expert) |
| **Specialized** | [architect](#em-agentarchitect) · [staff-engineer](#em-agentstaff-engineer) · [product-manager](#em-agentproduct-manager) · [security-reviewer](#em-agentsecurity-reviewer) · [ui-auditor](#em-agentui-auditor) · [design-reviewer](#em-agentdesign-reviewer) · [devex-reviewer](#em-agentdevex-reviewer) · [autoplan](#em-agentautoplan) · [codebase-mapper](#em-agentcodebase-mapper) · [integration-checker](#em-agentintegration-checker) · [iron-law-enforcer](#em-agentiron-law-enforcer) · [performance-auditor](#em-agentperformance-auditor) · [researcher](#em-agentresearcher) · [market-intelligence](#em-agentmarket-intelligence) · [learn](#em-agentlearn) |

---

## Core Agents

These five agents are the fundamental workhorses used in every workflow. They form the basic BUILD → VERIFY loop.

---

### `em-agent:planner`

Creates detailed implementation plans from specs and requirements. Breaks work into vertical-slice tasks with acceptance criteria, risk assessment, and effort estimates. Run AFTER you have a spec — never before.

| | |
|---|---|
| **Best for** | Starting new features, breaking down complex work, preparing input for executor |
| **Input** | Spec document or requirements text |
| **Output** | Phased plan with tasks, ACs, dependencies, and effort estimates |
| **Works with** | executor, code-reviewer |

**Invoke:**
```bash
/em-agent:planner Create plan for user authentication feature — see SPEC.md
/em-agent:planner Plan the payment refactor, spec is in docs/specs/payment-v2.md
```

---

### `em-agent:executor`

Executes implementation plans with atomic commits following TDD (RED-GREEN-REFACTOR). One task equals one commit; the codebase is always left in a green state. Stops on failure and never skips tasks silently.

| | |
|---|---|
| **Best for** | Implementing features from a plan, enforcing TDD discipline, clean commit history |
| **Input** | Implementation plan (PLAN.md), project context |
| **Output** | Atomic commits, quality gate results, execution summary |
| **Works with** | code-reviewer, verifier |

**Invoke:**
```bash
/em-agent:executor Execute the plan in PLAN.md
/em-agent:executor Implement task 3 from the plan — start from the failing test
```

---

### `em-agent:code-reviewer`

Performs code review with Standard (5-axis) or Deep (9-axis) mode. Standard covers correctness, security, performance, maintainability, and testing. Deep adds architecture, API design, observability, and documentation axes.

| | |
|---|---|
| **Best for** | Routine PRs (Standard mode), production-critical / auth / payments code (Deep mode) |
| **Input** | Code changes — file path, PR URL, or diff |
| **Output** | Review verdict (APPROVE / REQUEST\_CHANGES), findings by severity, fix suggestions |
| **Works with** | executor, verifier, security-reviewer |

**Invoke:**
```bash
/em-agent:code-reviewer Review changes in this PR — Standard mode
/em-agent:code-reviewer Deep review payment module changes in src/payment/
/em-agent:code-reviewer Review src/auth/auth.service.ts
```

---

### `em-agent:verifier`

Post-execution verification against spec and acceptance criteria. Checks spec coverage (fully implemented / partial / missing), runs all quality gates (tests, lint, type-check, build, coverage), and validates E2E flows.

| | |
|---|---|
| **Best for** | After executor finishes, validating that delivery matches spec before merge |
| **Input** | Implementation (commits or files), original spec |
| **Output** | PASS / FAIL / WARN verdict, spec coverage report, quality gate results |
| **Works with** | code-reviewer, executor |

**Invoke:**
```bash
/em-agent:verifier Verify implementation against SPEC.md
/em-agent:verifier Run all quality gates and check spec coverage
```

---

### `em-agent:debugger`

Systematic debugging using the scientific method in four phases: Investigate → Analyze → Hypothesize → Implement. Never guesses — every fix requires documented root cause evidence. Generates a regression test after each fix.

| | |
|---|---|
| **Best for** | Bug investigation, production issues, root cause analysis, eliminating recurrence |
| **Input** | Issue description, reproduction steps, error messages |
| **Output** | Root cause analysis, evidence trail, fix with regression test |
| **Works with** | executor, code-reviewer |

**Invoke:**
```bash
/em-agent:debugger Debug checkout timeout affecting 5% of orders — started after deploy v2.3.1
/em-agent:debugger Investigate NullPointerException in PaymentService line 142
```

---

## Test Automation Agents

Three-agent pipeline for E2E test infrastructure and automation. Typical order: playwright-setup (once) → brownfield-test-engineer → test-verifier.

---

### `em-agent:playwright-setup`

Sets up Playwright E2E testing infrastructure for any project. Auto-detects framework (Next.js, NestJS, React, monorepo), installs browsers, generates `playwright.config.ts`, and scaffolds a Page Object Model structure. Run once per project before writing any E2E tests.

| | |
|---|---|
| **Best for** | First-time Playwright setup, initializing E2E infrastructure, configuring auth strategies |
| **Input** | Project root (auto-detected); optional auth strategy preference |
| **Output** | `playwright.config.ts`, POM scaffold, auth config (none / credentials / oauth / storageState), npm scripts, smoke test |
| **Works with** | brownfield-test-engineer, test-engineer |

**Auth strategies:** `none` (public pages), `credentials` (username/password from .env), `oauth` (SSO — manual first login), `storageState` (existing session file).

**Invoke:**
```bash
/em-agent:playwright-setup
/em-agent:playwright-setup Use credentials auth strategy, credentials in .env
```

---

### `em-agent:brownfield-test-engineer`

Generates and runs tests for existing codebases from specs or task descriptions. Asks up to 5 targeted clarifying questions when the spec is ambiguous. Auto-loads `.em-brownfield/` context if present and creates a 12-column TC-REGISTRY with risk-calibrated test ratios.

| | |
|---|---|
| **Best for** | Adding tests to existing code, spec-to-test mapping, brownfield projects with business context |
| **Input** | Spec file, task description, or feature name |
| **Output** | TC-REGISTRY.md, unit/integration/E2E test files, execution report, coverage map |
| **Works with** | playwright-setup (prerequisite for E2E), test-verifier |

**TC ratio floors:** P0 (≥35% negative, ≥15% abuse, ≥10% non-functional), P1 (≥30%, ≥10%, ≥10%), P2 (≥25%, ≥5%, ≥5%).

**Invoke:**
```bash
/em-agent:brownfield-test-engineer Write E2E tests for the checkout flow — spec in docs/checkout.md
/em-agent:brownfield-test-engineer Write tests for user registration feature
```

---

### `em-agent:test-verifier`

Re-runs failed tests with up to 3 retries, applying targeted fixes between each attempt. Pre-checks that every TC-ID in TC-REGISTRY has a corresponding `test()` or `test.todo()` block. Reports a confidence score (0–3 based on retries consumed).

| | |
|---|---|
| **Best for** | After brownfield-test-engineer finishes, validating test quality, stabilizing flaky tests |
| **Input** | Test results, test files, original spec |
| **Output** | PASS (confidence score + coverage %) or FAIL (per-TC manual steps) |
| **Works with** | brownfield-test-engineer, test-engineer |

**Invoke:**
```bash
/em-agent:test-verifier
/em-agent:test-verifier Verify results for the checkout E2E suite
```

---

### `em-agent:test-engineer`

Test strategy, test case generation, and quality assurance for new features. Creates a multi-level test strategy (unit 80% / integration 15% / E2E 5%). Generates TC-REGISTRY with Technique, Oracle, Risk, and Layer columns. Mandatorily invokes the `test-case-design` skill first.

| | |
|---|---|
| **Best for** | Planning test strategy for new features, generating test cases from requirements |
| **Input** | Code to test, requirements, tech stack context |
| **Output** | Test strategy, TC-REGISTRY, generated test cases, fixtures, coverage report |
| **Works with** | executor, code-reviewer |

**Invoke:**
```bash
/em-agent:test-engineer Create test strategy for the payment module
/em-agent:test-engineer Generate tests for user authentication feature
```

---

## Orchestrators

Coordinate multiple agents to handle complex multi-domain tasks without requiring you to select specialists manually.

---

### `em-agent:team-lead`

Orchestrates multi-agent reviews — selects appropriate specialists, coordinates execution, and consolidates reports into a single decision. Security Reviewer holds blocking authority: CRITICAL or HIGH findings are a no-go. Conflict resolution order: Security > Quality > Speed.

| | |
|---|---|
| **Best for** | Comprehensive PR reviews, multi-agent evaluation, when you want the right specialists without selecting them yourself |
| **Input** | Task, PR, or spec description with context |
| **Output** | Consolidated assessment, per-agent findings, decision (APPROVED / CONDITIONAL / REJECTED) |
| **Works with** | product-manager, architect, frontend-expert, backend-expert, database-expert, code-reviewer, security-reviewer, staff-engineer |

**Invoke:**
```bash
/em-agent:team-lead Review the payment feature PR — include security and database review
/em-agent:team-lead Evaluate this microservices architecture proposal
```

---

### `em-agent:techlead-orchestrator`

Coordinates distributed agents across tmux sessions for parallel multi-domain work. Never writes code itself — delegates everything via message queue. Use when more than three agents need to work simultaneously in separate directories.

| | |
|---|---|
| **Best for** | Large features spanning backend + frontend + DB, parallel investigation across domains |
| **Input** | Task description with multi-domain scope |
| **Output** | Consolidated report from all distributed agents, action items, cross-agent insights |
| **Works with** | backend-expert, frontend-expert, database-expert, staff-engineer, security-reviewer, architect |

**Invoke:**
```bash
/em-agent:techlead-orchestrator Implement subscription feature across API, UI, and DB in parallel
/em-agent:techlead-orchestrator Investigate the performance degradation across all services simultaneously
```

---

## Expert Agents — Frontend

Deep expertise for frontend technology stacks. Flags framework-specific anti-patterns as Critical findings.

---

### `em-agent:react-expert`

React/Next.js expert covering component architecture, hooks, Server Components (App Router), state management selection, and render performance. Flags missing hook dependencies as Critical. Default rule: start with Server Components; add `'use client'` only for interactivity, browser APIs, or hooks.

| | |
|---|---|
| **Best for** | React code review, Next.js App Router patterns, component performance optimization |
| **Input** | React/Next.js codebase or specific component |
| **Output** | Review report with React-specific findings, performance analysis, pattern recommendations |
| **Works with** | frontend-expert, architect, code-reviewer |

**Invoke:**
```bash
/em-agent:react-expert Review the user dashboard React components
/em-agent:react-expert Audit Next.js App Router usage and Server Component boundaries
```

---

### `em-agent:vue-expert`

Vue 3 Composition API, Pinia state management, Vue Router, TypeScript, and Nuxt SSR/SSG expert. Flags reactivity loss from destructuring reactive objects as Critical. Enforces composable naming (`use*`) and `<script setup>` conventions.

| | |
|---|---|
| **Best for** | Vue 3 development review, Pinia store design, composable patterns, Nuxt SSR |
| **Input** | Vue 3 codebase |
| **Output** | Vue-specific review, Composition API recommendations, Pinia/Router patterns |
| **Works with** | frontend-expert, architect, code-reviewer |

**Invoke:**
```bash
/em-agent:vue-expert Review Vue 3 composables for the authentication module
/em-agent:vue-expert Check Pinia store design and action/getter boundaries
```

---

### `em-agent:frontend-expert`

React/Next.js, Core Web Vitals (LCP/FID/CLS), state management architecture, responsive design, and WCAG 2.1 AA accessibility specialist. Performs mobile-first analysis. Escalates to react-expert for framework-specific deep dives.

| | |
|---|---|
| **Best for** | Frontend performance review, accessibility audit, state management architecture decisions |
| **Input** | UI requirements, component specs, performance data |
| **Output** | Frontend review, Core Web Vitals analysis, accessibility findings, state management recommendations |
| **Works with** | team-lead, product-manager, architect, code-reviewer, ui-auditor |

**Invoke:**
```bash
/em-agent:frontend-expert Audit frontend performance for the product listing page
/em-agent:frontend-expert Review accessibility compliance across the checkout flow
```

---

### `em-agent:mobile-expert`

Cross-platform (Flutter, React Native) and native (iOS Swift, Android Kotlin) expert covering mobile UI/UX, performance (startup time / memory / battery), offline-first architecture, and App Store compliance requirements.

| | |
|---|---|
| **Best for** | Mobile app review, cross-platform architecture decisions, App Store submission prep |
| **Input** | Mobile codebase (Flutter / React Native / iOS / Android) |
| **Output** | Mobile review, platform-specific recommendations, performance analysis |
| **Works with** | frontend-expert, architect, code-reviewer, ui-auditor |

**Invoke:**
```bash
/em-agent:mobile-expert Review Flutter checkout flow implementation
/em-agent:mobile-expert Audit React Native app startup time and memory usage
```

---

## Expert Agents — Backend

Deep expertise for backend frameworks and languages.

---

### `em-agent:nestjs-expert`

NestJS/TypeScript backend expert covering dependency injection, module design, guards/pipes/interceptors, GraphQL, WebSockets, and microservices. Enforces correct request lifecycle order. Never allows field injection; DTOs require validation decorators.

| | |
|---|---|
| **Best for** | NestJS architecture review, module boundary design, DI configuration, lifecycle ordering |
| **Input** | NestJS codebase |
| **Output** | NestJS-specific findings, module design recommendations, lifecycle order validation |
| **Works with** | backend-expert, architect, database-expert, code-reviewer |

**Invoke:**
```bash
/em-agent:nestjs-expert Review NestJS module structure and dependency injection setup
/em-agent:nestjs-expert Audit guards and pipes in the API layer
```

---

### `em-agent:backend-expert`

API design (REST/GraphQL), backend performance (caching/async/query optimization), authentication, error handling, and integration patterns specialist. Validates all input at the API boundary. Escalates security concerns to security-reviewer.

| | |
|---|---|
| **Best for** | Backend API design review, performance optimization, authentication architecture |
| **Input** | API requirements, performance requirements, auth design |
| **Output** | API design review, performance analysis, error handling recommendations |
| **Works with** | team-lead, architect, database-expert, code-reviewer, security-reviewer |

**Invoke:**
```bash
/em-agent:backend-expert Review REST API design for the order service
/em-agent:backend-expert Audit the authentication and session management flow
```

---

### `em-agent:spring-expert`

Spring Boot/Spring Cloud, JPA/Hibernate, Spring Security, and microservices expert. Constructor injection only (never field injection), thin controllers, and service layer owns the `@Transactional` boundary. Flags N+1 queries and missing `@Transactional` on service methods.

| | |
|---|---|
| **Best for** | Spring Boot development review, JPA optimization, Spring Security configuration |
| **Input** | Spring Boot codebase |
| **Output** | Spring-specific review, JPA optimization, security configuration recommendations |
| **Works with** | backend-expert, architect, database-expert, security-reviewer |

**Invoke:**
```bash
/em-agent:spring-expert Review Spring Boot service layer design and transaction boundaries
/em-agent:spring-expert Audit JPA entity relationships for N+1 query issues
```

---

### `em-agent:rust-expert`

Rust systems programming with async/tokio, memory safety, ownership, and FFI integration. Never allows `.unwrap()` in production code. Every `unsafe` block requires a safety comment. Prefers generics (static dispatch) over `dyn Trait` unless object safety is required.

| | |
|---|---|
| **Best for** | Rust code review, ownership/lifetime issues, async tokio patterns, FFI design |
| **Input** | Rust codebase |
| **Output** | Rust-specific review, safety analysis, performance recommendations |
| **Works with** | backend-expert, architect, code-reviewer |

**Invoke:**
```bash
/em-agent:rust-expert Review Rust async service implementation and error handling
/em-agent:rust-expert Audit ownership and lifetime patterns across the data pipeline
```

---

## Expert Agents — Data & Infrastructure

---

### `em-agent:database-expert`

Schema design, query optimization with EXPLAIN analysis, zero-downtime migrations, fintech ledger patterns (double-entry bookkeeping), and scaling strategy. Uses `DECIMAL(19,4)` for money — never float. Flags missing indexes and unindexed foreign keys as Critical.

| | |
|---|---|
| **Best for** | Database design review, query optimization, migration planning, fintech data models |
| **Input** | Schema DDL, query patterns, migration scripts |
| **Output** | Schema review, query optimization with index recommendations, migration strategy |
| **Works with** | team-lead, architect, security-reviewer, staff-engineer, backend-expert |

**Invoke:**
```bash
/em-agent:database-expert Review the payment schema design and index strategy
/em-agent:database-expert Optimize these slow queries with EXPLAIN analysis
/em-agent:database-expert Review migration 0042_user_schema.sql for zero-downtime safety
```

---

### `em-agent:devops-expert`

Containerization (Docker multi-stage builds), Kubernetes, Terraform IaC, CI/CD pipelines, cloud platforms, and SLI/SLO-based monitoring specialist. Containers always run as non-root. Flags hardcoded secrets and privileged containers as Critical.

| | |
|---|---|
| **Best for** | Infrastructure review, CI/CD pipeline design, Kubernetes manifests, Terraform modules |
| **Input** | Infrastructure config, Dockerfile, Kubernetes manifests, Terraform code |
| **Output** | Infrastructure review, deployment recommendations, CI/CD improvements |
| **Works with** | architect, backend-expert, security-reviewer, performance-auditor |

**Invoke:**
```bash
/em-agent:devops-expert Review Kubernetes deployment manifests for the API service
/em-agent:devops-expert Design CI/CD pipeline for the monorepo — GitHub Actions
```

---

## Specialized Agents

Domain experts for architecture, security, quality, research, and product work.

---

### `em-agent:architect`

Architecture review, pattern detection (Layered / Hexagonal / Microservices / Event-Driven), scalability analysis (X/Y/Z-axis), and mandatory ADR generation with Decision / Context / Alternatives / Consequences / Compliance Criteria sections. Phase 0 always snapshots the existing architecture before proposing changes.

| | |
|---|---|
| **Best for** | Architectural decisions, pattern selection, scalability design, ADR creation |
| **Input** | Architecture diagrams, technical design, requirements |
| **Output** | Architecture review, pattern recommendations, ADR committed to `docs/adr/` |
| **Works with** | team-lead, staff-engineer, database-expert, frontend-expert, security-reviewer |

**Invoke:**
```bash
/em-agent:architect Review the microservices architecture proposal
/em-agent:architect Design auth service architecture and generate ADR
/em-agent:architect Create ADR for caching strategy — Redis vs in-memory
```

---

### `em-agent:staff-engineer`

Deep technical investigation, root cause analysis (5 Whys), cross-service impact assessment, and incident postmortems. Reconstructs timelines from logs, metrics, and traces. Uses blameless language throughout. Escalates systemic issues to architect.

| | |
|---|---|
| **Best for** | Production incidents, complex cross-service bugs, postmortems, systemic reliability issues |
| **Input** | Incident description, system context, logs/metrics |
| **Output** | Root cause analysis, cross-service impact map, corrective and preventive actions |
| **Works with** | team-lead, architect, security-reviewer, database-expert, code-reviewer |

**Invoke:**
```bash
/em-agent:staff-engineer Investigate payment service memory leak causing OOM every 6 hours
/em-agent:staff-engineer Run postmortem for the 2-hour outage on 2026-05-20
```

---

### `em-agent:product-manager`

Business validation, spec review, GAP analysis (Business / User / Technical / Process / Data), INVEST acceptance criteria validation, and ROI calculation. Issues decisions as APPROVED / CONDITIONAL / REJECTED with explicit rationale.

| | |
|---|---|
| **Best for** | Spec review, business value validation, gap analysis before development starts |
| **Input** | Spec document, user stories, business context |
| **Output** | Business validation, gap analysis, AC review, business impact assessment |
| **Works with** | team-lead, architect, frontend-expert, code-reviewer |

**Invoke:**
```bash
/em-agent:product-manager Review SPEC.md for the subscription feature
/em-agent:product-manager Validate business case and AC quality for the mobile app initiative
```

---

### `em-agent:security-reviewer`

Security assessment with two modes: **Review** (OWASP Top 10 scan of current diff) or **Audit** (full OWASP + STRIDE threat model + blocking authority). CRITICAL findings block deployment and merge. HIGH findings block merge. Cannot be overruled by other agents.

| | |
|---|---|
| **Best for** | Security review of auth/payment/PII code (Review mode), pre-release audits (Audit mode) |
| **Input** | Code or architecture to review, optional audit scope |
| **Output** | OWASP findings, STRIDE threat model (Audit mode), security scorecard, blocking issues list |
| **Works with** | team-lead, architect, staff-engineer, code-reviewer |

**Invoke:**
```bash
/em-agent:security-reviewer Review authentication changes — Review mode
/em-agent:security-reviewer Audit the payment module — full Audit mode with STRIDE
/em-agent:security-reviewer Security audit mode — full codebase scan
```

---

### `em-agent:ui-auditor`

6-pillar visual QA: Visual Consistency, Responsive, Accessibility (WCAG AA), Performance (Core Web Vitals), UX, and Browser Compatibility. Captures before/after screenshots and provides exact CSS fix suggestions for every issue found.

| | |
|---|---|
| **Best for** | UI quality assurance, accessibility verification, visual regression detection |
| **Input** | UI changes, component path, optional baseline screenshots |
| **Output** | Per-pillar score, categorized issues, screenshot evidence, CSS fixes |
| **Works with** | code-reviewer, executor |

**Invoke:**
```bash
/em-agent:ui-auditor Audit the checkout page UI across all 6 pillars
/em-agent:ui-auditor Verify WCAG AA accessibility on the settings page
```

---

### `em-agent:design-reviewer`

Visual design review against 6 design pillars: layout, typography, color, spacing, motion, and edge cases. Checks WCAG AA contrast ratios (4.5:1 for text, 3:1 for large text) and responsive behavior at 320 / 768 / 1024 / 1440px breakpoints.

| | |
|---|---|
| **Best for** | Design quality review, design system compliance, visual QA against Figma specs |
| **Input** | Component/page URL, optional design spec or Figma link |
| **Output** | Pillar scores, visual diff, design system violations, recommended fixes |
| **Works with** | frontend-expert, ui-auditor, product-manager |

**Invoke:**
```bash
/em-agent:design-reviewer Review the new dashboard design against the design system
/em-agent:design-reviewer Check design system compliance in the onboarding flow
```

---

### `em-agent:devex-reviewer`

Developer experience audit measuring TTHW (Time to Hello World). Tests actual documentation and onboarding flows — does not just read them. Scores 6 DX dimensions with quantitative metrics and always provides prioritized quick wins.

| | |
|---|---|
| **Best for** | API/SDK/CLI DX improvement, onboarding flow audit, documentation quality assessment |
| **Input** | Product URL, API endpoint, or repo path |
| **Output** | DX scorecard, TTHW breakdown, prioritized quick wins, improvement roadmap |
| **Works with** | architect, product-manager, frontend-expert |

**Invoke:**
```bash
/em-agent:devex-reviewer Audit the public API developer experience — measure TTHW
/em-agent:devex-reviewer Review CLI onboarding flow and documentation quality
```

---

### `em-agent:autoplan`

Multi-phase review orchestrator with a scored decision matrix producing GO / CONDITIONAL GO / PIVOT / NO-GO outcomes. Prevents analysis paralysis by time-boxing each review phase and requiring explicit decisions from all reviewers.

| | |
|---|---|
| **Best for** | Go/no-go decisions, evaluating proposals across CEO/Design/Engineering/DX dimensions |
| **Input** | Proposal or spec, review type, timeline |
| **Output** | Scheduled reviews with agendas, scored decision matrix, action items |
| **Works with** | product-manager, frontend-expert, architect, staff-engineer |

**Invoke:**
```bash
/em-agent:autoplan Evaluate proposal to rebuild the authentication system — GO/NO-GO
/em-agent:autoplan Run GO/NO-GO decision process on the mobile app initiative
```

---

### `em-agent:codebase-mapper`

Architecture analysis and codebase documentation. Detects patterns, maps dependencies, creates ASCII diagrams, and persists conventions to `.claude/knowledge/`. Flags circular dependencies as Critical and produces a searchable knowledge base.

| | |
|---|---|
| **Best for** | Understanding an unfamiliar codebase, creating architecture documentation, persisting knowledge |
| **Input** | Scope: `overview` / `detailed` / `comprehensive` |
| **Output** | Architecture overview, dependency graph, pattern analysis, knowledge base files |
| **Works with** | team-lead, architect, staff-engineer |

**Invoke:**
```bash
/em-agent:codebase-mapper Map the payment module architecture — detailed scope
/em-agent:codebase-mapper Create comprehensive codebase overview with dependency graph
```

---

### `em-agent:integration-checker`

Cross-phase validation and E2E flow verification. Tests real user journeys across integration points and verifies error paths and data integrity across service boundaries and data transformations.

| | |
|---|---|
| **Best for** | Multi-phase integration validation, E2E flow verification, cross-service gap detection |
| **Input** | Phases or flows to verify, scope |
| **Output** | Integration check report, flow results, gap analysis |
| **Works with** | team-lead, verifier, executor, architect |

**Invoke:**
```bash
/em-agent:integration-checker Verify E2E checkout flow across all services
/em-agent:integration-checker Check integration contract between order and payment services
```

---

### `em-agent:iron-law-enforcer`

Enforces the 4 Iron Laws without exception: (1) TDD — no production code without a failing test, (2) Debug — no fixes without root cause, (3) Spec — no code without spec, (4) Review — no merge without review. Never waives a law regardless of deadline pressure.

| | |
|---|---|
| **Best for** | Quality gate enforcement, Iron Law compliance checking at pre-commit/pre-review/pre-merge |
| **Input** | Code changes, spec, test results, gate type (pre-commit / pre-review / pre-merge) |
| **Output** | COMPLIANT or VIOLATIONS\_FOUND with required remediation actions |
| **Works with** | code-reviewer, verifier, test-engineer |

**Invoke:**
```bash
/em-agent:iron-law-enforcer Check Iron Law compliance before merge — pre-merge gate
/em-agent:iron-law-enforcer Enforce pre-commit gate on the current staged changes
```

---

### `em-agent:performance-auditor`

Benchmarking, bottleneck identification (code/architecture/infrastructure), and resource analysis (CPU/memory/I/O). Always establishes a baseline before recommending changes. Flags N+1 queries, missing indexes, and memory leaks as Critical.

| | |
|---|---|
| **Best for** | Performance optimization, bottleneck identification, scalability assessment |
| **Input** | System description, performance requirements, current metrics |
| **Output** | Performance audit, bottleneck analysis with evidence, optimization roadmap |
| **Works with** | team-lead, staff-engineer, executor, architect |

**Invoke:**
```bash
/em-agent:performance-auditor Profile the search API — 95th percentile is 8s, baseline needed
/em-agent:performance-auditor Audit checkout page performance against Core Web Vitals targets
```

---

### `em-agent:researcher`

Technical research and exploration for emerging technologies, frameworks, and best practices. Always cites sources, provides working code examples, states confidence level, and frames recommendations in the context of your specific project constraints.

| | |
|---|---|
| **Best for** | Technology evaluation, library/framework selection, research before architectural decisions |
| **Input** | Research topic or question, project constraints |
| **Output** | Research report (executive summary, analysis, code examples, pros/cons, recommendations) |
| **Works with** | planner, architect, product-manager, staff-engineer |

**Invoke:**
```bash
/em-agent:researcher Research best state management options for our React app — compare Zustand vs Redux Toolkit
/em-agent:researcher Compare GraphQL vs REST for our public API — focus on mobile client experience
```

---

### `em-agent:market-intelligence`

Market sizing (TAM/SAM/SOM), competitive intelligence, feature impact assessment, customer development (personas/JTBD), and ROI analysis. Always cites sources and states assumptions explicitly. Supports three depth levels: quick / standard / deep.

| | |
|---|---|
| **Best for** | Market research, competitive analysis, feature prioritization, business case validation |
| **Input** | Research topic, list of competitors, target segments, depth preference |
| **Output** | Market analysis, competitive intelligence, feature impact assessment, strategic recommendations |
| **Works with** | product-manager, architect, planner, researcher |

**Invoke:**
```bash
/em-agent:market-intelligence Analyze market opportunity for B2B expense tracking — deep analysis
/em-agent:market-intelligence Map competitors to our payment feature — quick overview
```

---

### `em-agent:learn`

Captures and organizes project learnings (patterns, pitfalls, preferences, ADRs) for team knowledge management and onboarding. Only documents validated patterns with explicit rationale. Generates searchable onboarding guides from accumulated context.

| | |
|---|---|
| **Best for** | Knowledge capture after incidents or refactors, team onboarding materials, cross-session learning |
| **Input** | Scope (`capture` / `organize` / `surface`), technology area, sprint or feature context |
| **Output** | Structured learning documents, searchable knowledge base entries, onboarding guides |
| **Works with** | executor, code-reviewer, product-manager, planner |

**Invoke:**
```bash
/em-agent:learn Capture learnings from the payment module refactor
/em-agent:learn Generate onboarding guide for the authentication module
```

---

**Version:** 5.5.0 · **Last updated:** 2026-05-27

See also: [Workflow Reference](../workflows/reference.md) · [Code Review Guide](../guides/code-review.md) · [Security Review Guide](../guides/security-review.md)

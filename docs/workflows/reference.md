# Workflow Reference

Workflows are end-to-end execution pipelines that coordinate multiple agents through defined stages and quality gates. All 27 workflows follow the `em-wf:{name}` naming convention and are invoked as slash commands (e.g. `/em-wf:new-feature`). They inherit their quality gate structure from the `six-phase-lifecycle` master reference.

---

## Quick Navigation

| Workflow | Category | One-line description |
|----------|----------|----------------------|
| [`em-wf:new-feature`](#em-wfnew-feature) | Primary | 6-stage feature lifecycle from spec to shipped PR |
| [`em-wf:bug-fix`](#em-wfbug-fix) | Primary | Systematic bug investigation with TDD fix and root cause evidence |
| [`em-wf:greenfield-app`](#em-wfgreenfield-app) | Primary | 12-stage blank-directory-to-production application workflow |
| [`em-wf:refactoring`](#em-wfrefactoring) | Primary | Code quality improvement without behavior changes |
| [`em-wf:qa-bug-hunter`](#em-wfqa-bug-hunter) | Primary | Automated QA discovery with human approval gate before filing issues |
| [`em-wf:brownfield-investigation`](#em-wfbrownfield-investigation) | Primary | Context-aware bug investigation using `.em-brownfield/` module context |
| [`em-wf:discovery-process`](#em-wfdiscovery-process) | Primary | Full product discovery cycle with customer interviews and GO/PIVOT/KILL decision |
| [`em-wf:market-driven-feature`](#em-wfmarket-driven-feature) | Primary | 9-stage workflow from market opportunity to production |
| [`em-wf:team-review`](#em-wfteam-review) | Team Review | Full team review orchestrated by team-lead across all domains |
| [`em-wf:architecture-review`](#em-wfarchitecture-review) | Team Review | Architecture review with architect + staff-engineer, mandatory ADR output |
| [`em-wf:code-review-9axis`](#em-wfcode-review-9axis) | Team Review | Deep 9-axis code review with quantitative scores + security assessment |
| [`em-wf:design-review`](#em-wfdesign-review) | Team Review | UI/UX design review with product-manager + frontend-expert pair |
| [`em-wf:database-review`](#em-wfdatabase-review) | Team Review | Database schema, query, and migration review with database-expert + architect |
| [`em-wf:product-review`](#em-wfproduct-review) | Team Review | Spec feasibility review producing APPROVED/CONDITIONAL/REJECTED decision |
| [`em-wf:security-review-advanced`](#em-wfsecurity-review-advanced) | Team Review | OWASP Top 10 + STRIDE threat modeling; CRITICAL findings block deploy and merge |
| [`em-wf:project-setup`](#em-wfproject-setup) | Support | Scaffold and configure a new project with TypeScript, ESLint, tests, and CI/CD |
| [`em-wf:deployment`](#em-wfdeployment) | Support | Structured production deployment with staging verification and rollback procedures |
| [`em-wf:documentation`](#em-wfdocumentation) | Support | Generate and publish API docs, architecture docs, and user guides |
| [`em-wf:canary-monitoring`](#em-wfcanary-monitoring) | Support | Post-deploy health monitoring with CONFIRM/INVESTIGATE/ROLLBACK decision |
| [`em-wf:ship-workflow`](#em-wfship-workflow) | Support | Final pre-merge shipment: version bump, CHANGELOG, PR creation |
| [`em-wf:retro`](#em-wfretro) | Support | Data-driven engineering retrospective with action items and owners |
| [`em-wf:security-audit`](#em-wfsecurity-audit) | Specialized | Full vulnerability assessment, remediation, and compliance documentation |
| [`em-wf:incident-response`](#em-wfincident-response) | Specialized | Modular P0-P3 production incident handling with blameless postmortem |
| [`em-wf:japanese-outsourcing`](#em-wfjapanese-outsourcing) | Specialized | Formal Japanese outsourcing workflow with 基本設計, 詳細設計, and UAT sign-offs |
| [`em-wf:distributed-investigation`](#em-wfdistributed-investigation) | Specialized | Parallel multi-domain bug investigation via techlead-orchestrator |
| [`em-wf:distributed-development`](#em-wfdistributed-development) | Specialized | Parallel backend + frontend + DB development with upfront API contract |
| [`em-wf:six-phase-lifecycle`](#em-wfsix-phase-lifecycle) | Specialized | Master lifecycle reference; foundation all other workflows inherit |

---

## Primary Workflows

These are the most frequently used workflows. Most teams use `new-feature` and `bug-fix` for roughly 80% of day-to-day work.

---

### `em-wf:new-feature`

The most flexible feature workflow — runs a 6-stage lifecycle (DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP) that adapts to small features (fast path) or large features (with market validation and domain modeling). It runs code review as the *first* step of VERIFY so any review fixes are validated by the test suite rather than bypassed. Most teams use this for 80% of feature work.

| Stage | What happens |
|-------|-------------|
| SETUP | Create git branch; scaffold spec skeleton |
| DEFINE | `product-manager` writes `SPEC.md` with acceptance criteria; testability hard gate |
| PLAN | `planner` creates `PLAN.md` with atomic task breakdown |
| BUILD | `executor` implements with TDD (RED → GREEN → REFACTOR) |
| VERIFY | Code-review diff scan first (step 5.1) → test suite → `test-verifier` confirms PASS |
| REVIEW | `security-reviewer` invoked if auth/payments/PII are touched |
| SHIP | `ship-workflow` creates PR; rollback readiness gate |

| | |
|---|---|
| **Best for** | New features on an existing codebase; anything with ≥ 2 components |
| **Key agents** | `planner`, `executor`, `verifier`, `code-reviewer`, `test-engineer`, `test-verifier`, `security-reviewer` (conditional), `product-manager` |
| **Gates** | Spec testability check (hard gate) → TC coverage 100% + confidence ≥ 80% → No CRITICAL findings → Rollback safe |

**Invoke:**
```bash
/em-wf:new-feature Implement user profile page with avatar upload
/em-wf:new-feature Add subscription management — see SPEC.md
```

> **Brownfield note:** Auto-loads `.em-brownfield/` context at stage 0.5 and updates `FLOWS.md` after build at stage 5.7.

---

### `em-wf:bug-fix`

Systematic bug investigation and resolution across 8 stages, from diagnosis to shipment with a TDD fix. Every fix requires confirmed root cause evidence — no guessing allowed. Auto-routes to `brownfield-investigation` when `.em-brownfield/` is detected in the project root, ensuring business context is never ignored.

| Stage | What happens |
|-------|-------------|
| SETUP | Create git branch from main |
| ROUTE | Detect `.em-brownfield/` → route to brownfield-investigation or continue standalone |
| INVESTIGATE | Reproduce bug; gather logs, stack traces, and evidence |
| ANALYZE | Identify failure point; form ranked hypotheses |
| HYPOTHESIZE | Confirm root cause with evidence before touching code |
| FIX | Implement fix + add regression test (TDD) |
| VERIFY | Tests pass pre- and post-fix; spec coverage 100%; `test-verifier` PASS |
| SHIP | PR created with root cause narrative |

| | |
|---|---|
| **Best for** | Production bugs; investigation of reported issues; any defect requiring root cause evidence |
| **Key agents** | `debugger`, `executor`, `verifier`, `test-engineer`, `test-verifier`, `code-reviewer` |
| **Gates** | Bug reproducible → Root cause confirmed → Tests pass before + after + regression test added → Spec coverage 100% + `test-verifier` PASS |

**Invoke:**
```bash
/em-wf:bug-fix Payment timeout affecting 5% of orders
/em-wf:bug-fix User can't login after password reset
```

---

### `em-wf:greenfield-app`

Complete 12-stage workflow from a blank directory to a shipped production application. Covers ideation, domain modeling, UI/UX design, architecture selection, project bootstrapping with CI/CD, codebase DNA crystallization, full QA, and launch. Expect 1-2 weeks for an MVP.

| Stage | What happens |
|-------|-------------|
| IDEATION | Define problem, target users, and core value proposition |
| REFRAME | Challenge assumptions; restate problem in user-centric terms |
| DOMAIN MODELING | Map entities, bounded contexts, and ubiquitous language |
| SPEC | `product-manager` writes full `SPEC.md` with ACs and risk tier |
| UI/UX DESIGN | Wireframes, flows, component inventory; `design-reviewer` scores ≥ 7/10 |
| ARCHITECTURE | `architect` presents 2-3 options; choose pattern; produce ADR |
| BOOTSTRAP | Scaffold project; configure TypeScript, ESLint, tests, CI/CD |
| CRYSTALLIZE | Generate `CLAUDE.md` + project DNA rules; commit to repo |
| IMPLEMENT | `executor` builds vertical slices with TDD |
| VALIDATE | `test-engineer` + `test-verifier` run full suite; E2E evidence captured |
| REVIEW | `code-reviewer` (9-axis) + `security-reviewer` (OWASP+STRIDE) |
| LAUNCH | Deploy to production; `canary-monitoring` watches for 30 min |

| | |
|---|---|
| **Best for** | Brand new product from scratch; nothing exists yet |
| **Key agents** | `product-manager`, `architect`, `planner`, `frontend-expert`, `executor`, `verifier`, `test-engineer`, `test-verifier`, `ui-auditor`, `design-reviewer`, `market-intelligence` |
| **Gates** | Go decision → Spec complete → Architecture chosen → CI/CD active → Spec coverage 100% + `test-verifier` PASS + UX audit ≥ 7/10 → No critical findings → Deployed + monitoring healthy |

**Invoke:**
```bash
/em-wf:greenfield-app Build a SaaS expense tracking platform for small teams
```

---

### `em-wf:refactoring`

Code quality improvement without behavior changes. Five stages: analyze smells, plan tasks, refactor with tests green, verify no regression, then update docs. Test coverage must not decrease at any point; if it does, the workflow halts.

| Stage | What happens |
|-------|-------------|
| ANALYZE | Collect complexity metrics; identify code smells and priorities |
| PLAN | Define refactoring tasks; write tests to capture existing behavior |
| REFACTOR | Improve code incrementally, keeping tests green throughout |
| VERIFY | Coverage unchanged or improved; complexity reduced; `test-verifier` PASS |
| UPDATE | Docs + commit with structured message referencing improved metrics |

| | |
|---|---|
| **Best for** | Technical debt reduction; complexity reduction; improving maintainability without new functionality |
| **Key agents** | `code-reviewer`, `planner`, `executor`, `verifier`, `test-engineer`, `test-verifier` |
| **Gates** | Metrics collected → Tasks defined → Tests pass → Coverage unchanged or improved → Documentation updated |

**Invoke:**
```bash
/em-wf:refactoring Reduce cyclomatic complexity in PaymentService
/em-wf:refactoring Extract shared auth logic into middleware
```

---

### `em-wf:qa-bug-hunter`

Automated QA testing workflow with a human approval gate before any GitHub issue is filed. For each discovered bug the workflow captures evidence (screenshot, console output, network trace), drafts an issue, and pauses for your decision — approve, reject, or modify — before creating the issue. Nothing is filed without explicit human sign-off.

| Stage | What happens |
|-------|-------------|
| SETUP | Verify URL accessible; create evidence directory; confirm `gh` auth |
| DISCOVER | Run QA tests across the target surface |
| EVIDENCE | Capture screenshot / console log / network trace per bug |
| PREPARE | Draft GitHub issue with title, steps-to-reproduce, severity, evidence links |
| HUMAN GATE | Present draft to you → APPROVE / REJECT / MODIFY |
| LOG | Create issue in GitHub (approved) or note rejection with reason |
| SUMMARY | List all bugs found, filed, and rejected with counts |

| | |
|---|---|
| **Best for** | QA testing features; systematic bug discovery and filing; staging verification |
| **Key agents** | `qa`, `flow-discovery`, `browser-testing`, `github-issue-manager` |
| **Gates** | URL accessible → QA complete + bugs found → Evidence captured → Draft complete → User decision → Issue created |

**Invoke:**
```bash
/em-wf:qa-bug-hunter Test the checkout flow on staging
/em-wf:qa-bug-hunter Full QA on the user settings page
```

---

### `em-wf:brownfield-investigation`

Context-aware bug investigation for projects with `.em-brownfield/` context already generated. Auto-loads module flows, traces through `CODE-MAP` stable symbols, and produces an evidence package with a business narrative (not just a stack trace). Updates `FLOWS.md` if new or undocumented behavior is discovered during investigation.

| Stage | What happens |
|-------|-------------|
| CONTEXT LOAD | Load `INDEX.md`; identify affected module; load `FLOWS.md` + `CODE-MAP` |
| REPRODUCE & MAP | Reproduce bug; map symptom to `FLOW-{MODULE}-{NNN}` ID |
| ROOT CAUSE | Trace through `CODE-MAP` symbols using 5 Whys; confirm cause |
| EVIDENCE PACKAGE | Produce `EVIDENCE.json` manifest + ASCII blast-radius tree + business narrative |
| REPORT / HUMAN GATE | Present findings; user approves root cause before fix proceeds |
| CONTEXT UPDATE | Update `FLOWS.md` / `CODE-MAP` if new behavior was discovered |

| | |
|---|---|
| **Best for** | Bugs in brownfield projects with `.em-brownfield/` context; when business narrative matters alongside technical root cause |
| **Key agents** | `debugger`, `brownfield-test-engineer` |
| **Gates** | Context loaded + affected flow identified → Bug reproduced → Root cause confirmed → Evidence packaged → User approves → Context updated |

**Invoke:**
```bash
/em-wf:brownfield-investigation Fix payment timeout affecting 5% of orders
/em-wf:brownfield-investigation FLOW-ORDER-003 failing on multi-item cart
```

---

### `em-wf:discovery-process`

Complete product discovery cycle (3-8 weeks) from problem hypothesis to validated solution. Conducts 5-10 customer interviews, synthesizes findings with affinity mapping, explores solutions through lightweight experiments, and produces a GO / PIVOT / KILL decision with a full PRD if the decision is GO.

| Stage | What happens |
|-------|-------------|
| FRAME | Write problem hypothesis; define research questions |
| RESEARCH PLAN | Build interview guide; recruit 5-10 participants |
| CONDUCT RESEARCH | Run interviews; continue until saturation is reached |
| SYNTHESIZE | Affinity mapping; rank pain points by frequency and severity |
| SOLUTIONS | Design candidate solutions; validate through fast experiments |
| DECIDE | GO / PIVOT / KILL decision; document epic hypotheses; write PRD if GO |

| | |
|---|---|
| **Best for** | New product ideas needing validation; high-uncertainty features; before significant investment |
| **Key agents** | `product-manager`, `market-intelligence`, `planner` |
| **Gates** | Research questions defined → 5-10 interviews completed → Saturation reached → Solutions validated → Decision documented |

**Invoke:**
```bash
/em-wf:discovery-process Validate idea for AI expense categorization feature
```

---

### `em-wf:market-driven-feature`

Nine-stage workflow from market discovery to production. Validates the market opportunity and competitive landscape first, designs and validates the solution with real users, builds a business case, then follows the standard SPEC → PLAN → BUILD → VERIFY → SHIP pipeline with market insights embedded throughout.

| Stage | What happens |
|-------|-------------|
| MARKET DISCOVERY | Size the market; map competitors; identify differentiation opportunity |
| SOLUTION DESIGN | Translate opportunity into concrete product solution |
| VALIDATION | Validate solution with target customers; iterate on design |
| BUSINESS CASE | Financial projections; ROI; risk assessment |
| SPEC | Write `SPEC.md` enriched with market insights and measurable success metrics |
| PLAN | `planner` creates task breakdown |
| BUILD | `executor` implements with TDD |
| VERIFY | Full test suite + TC coverage + `test-verifier` PASS; business metric baseline set |
| SHIP | PR created; GTM checklist confirmed |

| | |
|---|---|
| **Best for** | Features requiring market validation before building; competitive differentiation initiatives |
| **Key agents** | `market-intelligence`, `product-manager`, `architect`, `planner`, `executor`, `code-reviewer` |
| **Gates** | Market sized + competitors mapped → Value proposition proven → Financial projections meet hurdles → Spec complete with market insights → TC coverage + business metrics baseline → Deployed + GTM ready |

**Invoke:**
```bash
/em-wf:market-driven-feature Build multi-currency support for international expansion
```

---

## Team Review Workflows

Multi-agent review workflows coordinated by `team-lead` or specialized pairs. Use these for high-stakes changes, architectural decisions, or when a single reviewer is not enough.

---

### `em-wf:team-review`

Full team review orchestrated by `team-lead`. Runs seven phases: business → architecture → specialized reviews in parallel (DB + FE + code) → security → optional deep investigation → consolidated finding report. Security has blocking authority — a CRITICAL security finding halts the review immediately.

| Stage | What happens |
|-------|-------------|
| SCOPE | Assess risk level; select which agents are required |
| BUSINESS | `product-manager` validates user stories, flows, and acceptance criteria |
| ARCHITECTURE | `architect` evaluates system design, patterns, and scalability |
| SPECIALIZED (parallel) | `database-expert` (schema/queries) + `frontend-expert` (a11y/perf) + `code-reviewer` (5-axis) run simultaneously |
| SECURITY | `security-reviewer` runs OWASP Top 10 + STRIDE; blocking authority |
| DEEP INVESTIGATION | Triggered if any reviewer flags a concern needing cross-agent analysis |
| CONSOLIDATION | `team-lead` merges all findings; produces unified decision |

| | |
|---|---|
| **Best for** | High-stakes PRs; major feature sign-off; architectural decisions affecting multiple teams |
| **Key agents** | `team-lead`, `product-manager`, `architect`, `database-expert`, `frontend-expert`, `code-reviewer`, `security-reviewer`, `staff-engineer` |
| **Gates** | Entry criteria → No business blockers → Architecture validated → Specialized reviews complete → OWASP + STRIDE done → Findings consolidated + decision |

**Invoke:**
```bash
/em-wf:team-review Review the new payment provider integration
/em-wf:team-review Sign off on auth system redesign
```

---

### `em-wf:architecture-review`

Four-phase architecture review with `architect` + `staff-engineer`. Evaluates system design against stated requirements, detects the actual patterns currently in use (not assumed patterns), assesses scalability along X/Y/Z axes, and **must** produce an ADR committed to `docs/adr/`. The entry criteria gate blocks the review if problem, spec, or scope are not yet defined.

| Stage | What happens |
|-------|-------------|
| ENTRY CRITERIA | Verify 4 mandatory checkboxes: problem defined, spec exists, scope bounded, goals measurable |
| ARCHITECTURE ANALYSIS | Detect actual patterns in use; assess against architecture principles |
| DEEP TECHNICAL REVIEW | `staff-engineer` maps cross-service impact, data flows, and failure modes |
| CONSOLIDATED ASSESSMENT | Produce ADR (Decision/Context/Alternatives/Consequences); commit to `docs/adr/`; provide roadmap |

| | |
|---|---|
| **Best for** | System redesign; microservices decisions; scalability concerns; architecture documentation |
| **Key agents** | `architect`, `staff-engineer` |
| **Gates** | 4 entry criteria checkboxes → Architecture pattern identified + principles assessed → Impact analysis complete → ADR committed to `docs/adr/` |

**Invoke:**
```bash
/em-wf:architecture-review Evaluate event-driven architecture proposal for order service
```

---

### `em-wf:code-review-9axis`

Deep 9-axis code review (correctness / readability / architecture / security / performance / testing / maintainability / scalability / documentation) plus a parallel security assessment. Produces quantitative scores per axis so trends can be tracked over time.

| Stage | What happens |
|-------|-------------|
| DIFF CLASSIFICATION | Categorize each changed file as NEW / MODIFIED / DELETED |
| 9-AXIS REVIEW | `code-reviewer` (deep mode) scores all 9 axes; flags cross-file impact |
| SECURITY ASSESSMENT | `security-reviewer` runs OWASP review in parallel |
| CONSOLIDATED REPORT | Merge scores; produce per-axis scorecard; document decision |

| | |
|---|---|
| **Best for** | Production-critical code; auth/payment changes; major architectural changes; pre-release review |
| **Key agents** | `code-reviewer` (deep mode), `security-reviewer` |
| **Gates** | All 9 axes scored → OWASP assessed → Decision documented |

**Invoke:**
```bash
/em-wf:code-review-9axis Deep review authentication system changes
/em-wf:code-review-9axis 9-axis review before production release
```

---

### `em-wf:design-review`

UI/UX design review conducted by `product-manager` (validates user stories, flows, and ACs) paired with `frontend-expert` (evaluates component architecture, accessibility, and performance). Produces a design scorecard with prioritized issues.

| Stage | What happens |
|-------|-------------|
| PRODUCT REQUIREMENTS | `product-manager` validates user stories, flows, and acceptance criteria against the design |
| UI/UX TECHNICAL REVIEW | `frontend-expert` reviews component architecture, a11y compliance (WCAG 2.1 AA), and performance budget |
| CONSOLIDATED ASSESSMENT | Merge findings; produce design scorecard; prioritize issues by severity |

| | |
|---|---|
| **Best for** | Design sign-off; UX/accessibility evaluation; component architecture review |
| **Key agents** | `product-manager`, `frontend-expert`, `ui-auditor` |
| **Gates** | User stories validated → Accessibility + performance analyzed → UX issues prioritized + scorecard complete |

**Invoke:**
```bash
/em-wf:design-review Review the new onboarding UI flow
/em-wf:design-review Evaluate checkout page redesign
```

---

### `em-wf:database-review`

Database review with `database-expert` (schema design, query analysis, migration safety) + `architect` (data architecture, integration patterns). Flags N+1 queries, missing indexes, and `float` used for monetary values as Critical findings.

| Stage | What happens |
|-------|-------------|
| SCHEMA & QUERY REVIEW | `database-expert` reviews table structure, indexes, constraints, and query plans |
| MIGRATION SAFETY | Evaluate migration scripts for destructive operations and rollback paths |
| DATA ARCHITECTURE REVIEW | `architect` assesses data flow, cross-service data ownership, and consistency guarantees |
| CONSOLIDATED ASSESSMENT | Merge findings; prioritize optimization recommendations |

| | |
|---|---|
| **Best for** | Schema design review; query optimization; migration safety; fintech data models |
| **Key agents** | `database-expert`, `architect` |
| **Gates** | Schema + queries + migrations reviewed → Data architecture assessed → Optimization recommendations prioritized |

**Invoke:**
```bash
/em-wf:database-review Review payment schema and order queries
/em-wf:database-review Evaluate migration 0042_user_schema.sql
```

---

### `em-wf:product-review`

Spec feasibility review with `product-manager` (business validation, GAP analysis, market fit) + `architect` (technical feasibility, risks, implementation options). Produces a clear APPROVED / CONDITIONAL / REJECTED decision with full reasoning before development starts.

| Stage | What happens |
|-------|-------------|
| BUSINESS REQUIREMENTS | `product-manager` validates completeness, GAP analysis, and market fit |
| TECHNICAL FEASIBILITY | `architect` assesses feasibility, risks, and proposes alternative options if needed |
| CONSOLIDATED ASSESSMENT | Merge findings; issue APPROVED / CONDITIONAL / REJECTED with conditions listed |

| | |
|---|---|
| **Best for** | Spec review before development starts; business/tech feasibility check; pre-planning validation |
| **Key agents** | `product-manager`, `architect` |
| **Gates** | Requirements validated → Technical feasibility confirmed → Decision documented |

**Invoke:**
```bash
/em-wf:product-review Review SPEC.md for the subscription billing feature
```

---

### `em-wf:security-review-advanced`

Full OWASP Top 10 assessment combined with STRIDE threat modeling per component, plus a deep cross-service security investigation by `staff-engineer`. CRITICAL findings block **both** deployment **and** merge — not just advisory. Use for new auth systems, OAuth integrations, pre-launch reviews, or post-incident hardening.

| Stage | What happens |
|-------|-------------|
| OWASP ASSESSMENT | `security-reviewer` reviews all 10 OWASP categories with code evidence |
| STRIDE THREAT MODEL | Model each component across Spoofing / Tampering / Repudiation / Info Disclosure / DoS / Elevation of Privilege |
| DEEP INVESTIGATION | `staff-engineer` maps cross-service attack paths, infra risks, and dependency vulnerabilities |
| CONSOLIDATION | Produce security scorecard; issue BLOCKED / CONDITIONAL / APPROVED |

| | |
|---|---|
| **Best for** | New auth systems; OAuth/SSO integration; pre-launch security; post-incident hardening; compliance (PCI/SOC2/HIPAA) |
| **Key agents** | `security-reviewer`, `staff-engineer` |
| **Gates** | All OWASP categories reviewed → STRIDE model complete → Deep investigation done → Decision: BLOCKED / CONDITIONAL / APPROVED |

**Invoke:**
```bash
/em-wf:security-review-advanced Threat model the new OAuth2 SSO integration
/em-wf:security-review-advanced Security review before launch
```

---

## Support Workflows

Focused utilities for specific operational needs that sit alongside the primary development lifecycle.

---

### `em-wf:project-setup`

Initializes a new fullstack project — evaluates tech stack options against requirements, scaffolds the directory structure, configures TypeScript / ESLint / tests / CI-CD, verifies the build and tooling work end-to-end, then creates and pushes the initial commit with branch protection rules.

| Stage | What happens |
|-------|-------------|
| CHOOSE | Evaluate stack options against functional and non-functional requirements |
| SCAFFOLD | Create directory structure; initialize git; add `.gitignore` and `README` |
| CONFIGURE | Set up TypeScript, ESLint/Prettier, test runner, and CI/CD pipeline |
| TEST | Verify build passes, tests run, linter clean, CI green |
| INITIALIZE | Create first commit; push to remote; configure main + develop branches |

| | |
|---|---|
| **Best for** | Starting a brand new project; fresh scaffold with established best practices |
| **Key agents** | `architect`, `devops-expert` |
| **Gates** | Requirements understood → Project created → Tooling verified → Build passes → Repository pushed |

**Invoke:**
```bash
/em-wf:project-setup Initialize NestJS + React monorepo with TypeScript
```

---

### `em-wf:deployment`

Production deployment workflow with structured pre-deploy checks, staging verification, post-deploy smoke tests on critical paths, metrics monitoring, and documented rollback procedures. Confirms healthy before marking deployment complete.

| Stage | What happens |
|-------|-------------|
| PREP | Confirm tests pass; build artifacts; take database backup |
| DEPLOY | Deploy to staging first; verify staging health |
| DEPLOY PRODUCTION | Roll out to production with canary or blue-green strategy |
| TEST | Run smoke tests on all critical user paths |
| MONITOR | Watch error rates, latency, and key business metrics for 15-30 min |
| FINALIZE | Update deployment docs; notify team; close deployment ticket |

| | |
|---|---|
| **Best for** | Production deployments requiring structured verification and rollback safety |
| **Key agents** | `devops-expert`, `verifier` |
| **Gates** | Tests pass → Staging verified → Smoke tests pass → Metrics normal → Documentation updated |

**Invoke:**
```bash
/em-wf:deployment Deploy v2.3.0 to production
```

---

### `em-wf:documentation`

Generates and updates all forms of project documentation — API reference docs, architecture docs, user guides, code examples, and diagrams. Verifies that all examples actually compile and run before publishing to prevent stale docs.

| Stage | What happens |
|-------|-------------|
| ANALYZE | Define documentation scope; audit existing docs for gaps |
| GENERATE | Produce API docs (OpenAPI/TSDoc), architecture diagrams, and user guides |
| REVIEW | Check accuracy of generated docs; test all code examples |
| UPDATE | Fix inaccuracies; update examples that fail; fill identified gaps |
| PUBLISH | Deploy docs; verify all internal links resolve |

| | |
|---|---|
| **Best for** | API documentation; architecture docs; user guides; post-refactor doc updates |
| **Key agents** | `architect`, `backend-expert`, `frontend-expert` |
| **Gates** | Scope defined → Docs generated → Examples tested → Issues fixed → Links verified |

**Invoke:**
```bash
/em-wf:documentation Generate API documentation for the payment service
```

---

### `em-wf:canary-monitoring`

Post-deploy health monitoring workflow. Captures a pre-deploy baseline, then watches for new errors, performance regressions, and visual changes at the 0-5 minute and 5-30 minute intervals. Issues a final CONFIRM / INVESTIGATE / ROLLBACK decision with supporting evidence.

| Stage | What happens |
|-------|-------------|
| BASELINE | Capture pre-deploy error rate, p95 latency, and key metric snapshots |
| DEPLOY | Trigger or confirm deployment event |
| IMMEDIATE CHECK (0-5 min) | Watch console errors, page load times, and API response codes |
| STABILITY CHECK (5-30 min) | Check performance trends, visual regression, and business metrics |
| DECISION GATE | Issue CONFIRM (all healthy) / INVESTIGATE (anomaly detected) / ROLLBACK (degradation confirmed) |

| | |
|---|---|
| **Best for** | Watching deployment health after go-live; automated canary analysis |
| **Key agents** | `verifier`, `devops-expert` |
| **Gates** | Baseline captured → Deploy successful → No new errors → Performance within threshold → Decision made |

**Invoke:**
```bash
/em-wf:canary-monitoring Monitor deployment of v2.3.0
```

---

### `em-wf:ship-workflow`

The final pre-merge shipment step. Verifies all tests pass, bumps the version following semver, updates `CHANGELOG.md`, and creates a properly described PR. This is the last action before merging a completed feature branch.

| Stage | What happens |
|-------|-------------|
| PRE-SHIP VERIFY | Run full test suite; confirm all checks pass |
| VERSION BUMP | Bump version in `package.json` / relevant manifest following semver |
| FINAL VERIFY | Run full suite once more against bumped version |
| CREATE PR | Open PR with summary, linked issues, test evidence, and deployment notes |

| | |
|---|---|
| **Best for** | Final step before merging a feature branch; wrapping up completed work |
| **Key agents** | `verifier`, `executor` |
| **Gates** | All tests pass → Version bumped correctly → Full suite passes → PR created + CI green |

**Invoke:**
```bash
/em-wf:ship-workflow Ship the payment feature branch
```

---

### `em-wf:retro`

Engineering retrospective with data-driven action planning. Collects sprint metrics and feedback, identifies recurring patterns, documents successes and failure modes, and creates action items with explicit owners and deadlines so findings actually get addressed.

| Stage | What happens |
|-------|-------------|
| COLLECT | Gather velocity metrics, incident counts, PR cycle times, and team feedback |
| ANALYZE | Identify recurring patterns and trends across data points |
| IDENTIFY | Document wins, failure modes, and highest-leverage improvement opportunities |
| PLAN | Assign action items with owners and target completion dates |
| EXECUTE | Track action completion; update process documentation |

| | |
|---|---|
| **Best for** | End-of-sprint / end-of-project retrospectives; continuous process improvement |
| **Key agents** | `product-manager`, `staff-engineer` |
| **Gates** | Data collected → Patterns identified → Priorities set → Owners assigned → Actions executed |

**Invoke:**
```bash
/em-wf:retro Sprint 23 retrospective
```

---

## Specialized Workflows

Purpose-built workflows for security, incidents, outsourcing, distributed coordination, and the master lifecycle reference.

---

### `em-wf:security-audit`

Full security vulnerability assessment and remediation workflow for compliance and pre-release verification. Scans all attack surfaces, prioritizes findings by risk, implements fixes for CRITICAL and HIGH findings, verifies remediation, and produces a compliance-ready findings document.

| Stage | What happens |
|-------|-------------|
| SCAN | Run OWASP Top 10 assessment; SAST; dependency audit; identify all vulnerabilities |
| ANALYZE | Assign CVSS risk scores; prioritize by impact and exploitability |
| REMEDIATE | Fix all CRITICAL and HIGH findings; add security regression tests |
| VERIFY | Confirm no CRITICAL or HIGH issues remain; validate compliance requirements met |
| DOCUMENT | Produce findings report; distribute to team and stakeholders |

| | |
|---|---|
| **Best for** | Pre-release security; compliance (PCI DSS / SOC 2 / HIPAA); periodic security assessments |
| **Key agents** | `security-reviewer`, `executor`, `verifier` |
| **Gates** | Scans complete → Remediation planned → CRITICAL + HIGH fixed → Compliance met → Documented |

**Invoke:**
```bash
/em-wf:security-audit Audit the payment and auth systems
/em-wf:security-audit Pre-release security check
```

---

### `em-wf:incident-response`

Modular production incident handling for P0-P3 severity events. Includes optional security investigation path, 5 Whys + Fishbone root cause analysis, cross-service impact mapping, fix verification, and a blameless postmortem with prevention action items.

| Stage | What happens |
|-------|-------------|
| TRIAGE | Classify P0-P3 severity; define scope and blast radius |
| SECURITY | Optional path: invoked if incident has security indicators |
| ROOT CAUSE | 5 Whys + Fishbone diagram; confirm causal chain with evidence |
| IMPACT | Map cross-service impact and data integrity risks |
| RESOLUTION | Implement fix; verify system recovery; confirm metrics normal |
| POSTMORTEM | Blameless postmortem document; prevention action items with owners |

| | |
|---|---|
| **Best for** | Production incidents; outages; elevated error rates; security events |
| **Key agents** | `staff-engineer`, `debugger`, `security-reviewer` (conditional), `devops-expert` |
| **Gates** | Severity assessed → Root cause identified → Impact analyzed → Fix verified → Postmortem documented |

**Invoke:**
```bash
/em-wf:incident-response P0 — checkout service down, 100% failure rate
/em-wf:incident-response P1 — elevated payment errors since 14:30
```

---

### `em-wf:japanese-outsourcing`

End-to-end Japanese outsourcing workflow with formal client sign-offs at each phase gate. Produces formal deliverables (基本設計 Basic Design, 詳細設計 Detailed Design) and concludes with UAT (受け入れテスト) requiring zero Critical defects before final acceptance signature.

| Stage | What happens |
|-------|-------------|
| KICKOFF | Align stakeholders; define communication plan and escalation path |
| REQUIREMENTS | Elicit and document requirements; obtain client sign-off on `REQUIREMENTS.md` |
| BASIC DESIGN 基本設計 | System architecture, module breakdown, data model; client sign-off required |
| DETAILED DESIGN 詳細設計 | Per-module detailed design documents; tech lead sign-off required |
| IMPLEMENTATION | Develop to detailed design specifications with TDD |
| INTERNAL TESTING | Code review + security review; all defects resolved before UAT |
| UAT 受け入れテスト | Client runs acceptance tests; 0 Critical defects required to pass |
| DELIVERY | Final deliverables package; handover documentation |
| POST-DELIVERY SUPPORT | Defect warranty period; knowledge transfer sessions |

| | |
|---|---|
| **Best for** | Japanese client outsourcing projects; any project requiring formal phased gates and signed deliverables |
| **Key agents** | `product-manager`, `architect`, `planner`, `executor`, `code-reviewer`, `security-reviewer`, `test-engineer` |
| **Gates** | Kickoff complete → `REQUIREMENTS.md` signed → `BASIC-DESIGN.md` signed → Detailed designs approved → Internal QA passed → UAT pass with 0 Critical → Final acceptance signature |

**Invoke:**
```bash
/em-wf:japanese-outsourcing New e-commerce platform project for Yamamoto Corp
```

---

### `em-wf:distributed-investigation`

Parallel multi-domain bug investigation using `techlead-orchestrator` across separate tmux sessions. Backend, frontend, and database agents investigate their domains simultaneously; findings are then correlated across agents to surface cross-domain root causes that single-domain analysis would miss.

| Stage | What happens |
|-------|-------------|
| INITIAL ANALYSIS | `techlead-orchestrator` assesses scope and severity; plans parallel sessions |
| TASK DELEGATION | Launch backend + frontend + database agent sessions |
| INVESTIGATION | Each agent runs domain-specific diagnostic probes independently |
| COORDINATION | `techlead-orchestrator` correlates findings as agents report back |
| REPORTS | All agents submit domain findings |
| CONSOLIDATION | Merge cross-agent insights; identify shared root cause |
| ACTION | Assign fix tasks; verify resolution across all domains |

| | |
|---|---|
| **Best for** | Bugs affecting multiple domains simultaneously; complex cross-service failures |
| **Key agents** | `techlead-orchestrator`, `backend-expert`, `frontend-expert`, `database-expert`, `debugger` |
| **Gates** | Scope determined → All sessions started → All agents complete → Cross-agent findings correlated → Root cause consensus → Fixes verified |

**Invoke:**
```bash
/em-wf:distributed-investigation Checkout failure — backend errors + frontend hangs + DB timeouts
```

---

### `em-wf:distributed-development`

Parallel multi-domain feature development coordinated by `techlead-orchestrator`. Database agent designs the schema, backend agent implements the API, and frontend agent builds the UI — all working simultaneously after an upfront API contract is agreed to prevent integration conflicts.

| Stage | What happens |
|-------|-------------|
| REQUIREMENTS | `techlead-orchestrator` analyzes feature requirements; determines domain split |
| DELEGATE | Launch database + backend + frontend agent sessions |
| DESIGN / CONTRACT | Agents agree on schema + API contract (types, endpoints, request/response shapes) before coding |
| BACKEND | Backend agent implements API to contract |
| FRONTEND | Frontend agent implements UI against the agreed API contract |
| INTEGRATION | Code review + integration tests + E2E tests run against combined output |
| CONSOLIDATION | Merge all agent outputs; resolve integration issues |
| APPROVAL | `code-reviewer` + `security-reviewer` final sign-off |

| | |
|---|---|
| **Best for** | Large features with clear backend / frontend / DB separation; accelerating parallel development |
| **Key agents** | `techlead-orchestrator`, `database-expert`, `backend-expert`, `frontend-expert`, `code-reviewer`, `security-reviewer` |
| **Gates** | Requirements analyzed → Sessions started → API contract signed-off → BE + FE complete → Integration tests PASS + E2E PASS → Code review approved + security approved |

**Invoke:**
```bash
/em-wf:distributed-development Build subscription management — billing API + dashboard UI + billing schema
```

---

### `em-wf:six-phase-lifecycle`

The master reference lifecycle that all other workflows inherit from. Defines the six universal phases and quality gates that form the backbone of the EM-Team system. Not typically invoked directly — use `new-feature`, `bug-fix`, or `greenfield-app` for concrete work. Consult this workflow when designing a new custom workflow or understanding why a gate exists.

| Phase | What happens |
|-------|-------------|
| DEFINE | Document requirements; confirm success is measurable |
| PLAN | Map all requirements to atomic tasks with acceptance criteria |
| BUILD | Implement all tasks; keep tests green throughout |
| VERIFY | Spec coverage 100%; TC registry complete; E2E evidence captured; `test-verifier` PASS |
| REVIEW | No CRITICAL findings; code review passed; security reviewed if applicable |
| SHIP | PR merged; deployed; monitoring healthy; rollback plan confirmed |

| | |
|---|---|
| **Best for** | Understanding the gate structure all workflows follow; designing a new custom workflow |
| **Key agents** | All agents — this is the foundation |
| **Gates** | Requirements documented + success measurable → All requirements mapped → All tasks implemented + tests passing → Spec coverage 100% + TC registry + E2E evidence + `test-verifier` PASS → No CRITICAL findings + code review passed → PR merged + deployed + monitoring healthy |

**Invoke:**
```bash
# Rarely invoked directly — prefer new-feature, bug-fix, or greenfield-app
/em-wf:six-phase-lifecycle Custom workflow reference
```

---

## Version and References

**Version:** 5.5.0 · **Last updated:** 2026-05-27

**See also:** [Agent Reference](../agents/reference.md) · [New Feature Workflow Guide](../guides/new-feature-workflow.md) · [Brownfield Intelligence](../guides/brownfield.md)

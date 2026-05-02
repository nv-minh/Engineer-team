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
├── skills/              # 45 skills
│   ├── foundation/      # 6 core foundational skills
│   ├── development/     # 18 development skills (including language patterns + diagram + figma-design)
│   ├── quality/         # 10 quality assurance skills
│   ├── workflow/        # 6 workflow and automation skills
│   └── additional/      # 5 product & discovery skills
├── agents/              # 27 specialized agents (8 core + 4 optional + 8 specialized + 7 v2.0+)
├── workflows/           # 23 end-to-end workflows (4 primary + 6 support + 8 team + 2 distributed + 1 master + 2 incident)
├── .claude/
│   ├── lib/             # Agent Trace Store (code provenance tracking)
│   ├── mcp-servers/     # Custom MCP servers (GitHub enhanced, Project context)
│   └── rules/           # Operational rules (mistakes ledger, context management)
├── templates/           # Reusable templates + context artifacts
│   └── context-artifacts/ # PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md
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

### Foundation Skills (6 skills)
1. **alignment-session** - Pre-coding human-AI alignment
2. **spec-driven-development** - Write specs before coding
3. **brainstorming** - Explore ideas into designs
4. **context-engineering** - Optimize agent context setup
5. **writing-plans** - Break work into bite-sized tasks
6. **systematic-debugging** - 4-phase debugging methodology

### Development Skills (18 skills)
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
24. **figma-design** - Figma-to-code conversion with MCP server

### Quality Skills (10 skills)
25. **code-review** - 5-axis review framework
25. **code-simplification** - Reduce complexity
26. **browser-testing** - DevTools MCP integration
27. **performance-optimization** - Measure-first optimization
28. **e2e-testing** - Playwright patterns
29. **security-audit** - Vulnerability assessment
30. **api-testing** - Integration testing
31. **security-common** - OWASP reference and security checklist
32. **ux-audit** - Behavioral UX audit with scored dimensions
33. **plan-tune** - Learn and tune output preferences

### Workflow Skills (6 skills)
35. **git-workflow** - Atomic commits
35. **ci-cd-automation** - Feature flags, quality gates
36. **documentation** - ADRs, API docs
37. **finishing-branch** - Merge/PR decisions
38. **deprecation-migration** - Code-as-liability mindset
39. **style-switcher** - Unified personality styles (13) and density modes (3)

### Additional Skills (5 skills)
41. **jobs-to-be-done** - JTBD framework for understanding user needs
42. **lean-ux-canvas** - Lean UX hypothesis testing
43. **opportunity-solution-tree** - Product opportunity mapping
44. **pol-probe** - Product opportunity probe
45. **office-hours** - YC-style brainstorming and idea validation

## Agent Categories

### Core Agents (8 agents)
1. **planner** - Create detailed implementation plans
2. **executor** - Execute with atomic commits
3. **code-reviewer** - 5-axis code review (two-stage: spec compliance then quality)
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-auditor** - OWASP assessment
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
16. **senior-code-reviewer** - 9-axis deep code review (trigger: `em-agent:senior-code-reviewer`)
17. **database-expert** - Schema, queries, fintech patterns (trigger: `em-agent:database-expert`)
18. **product-manager** - Requirements, GAP analysis, market fit (trigger: `em-agent:product-manager`)
19. **security-reviewer** - OWASP Top 10, STRIDE, blocking authority (trigger: `em-agent:security-reviewer`)
20. **staff-engineer** - Root cause analysis, cross-service impact (trigger: `em-agent:staff-engineer`)

### New Agents (v2.0.0)
21. **market-intelligence** - Market analysis, competitive intelligence (trigger: `em-agent:market-intelligence`)
22. **learn** - Knowledge management and cross-session learning
23. **autoplan** - Multi-phase review pipeline orchestrator
24. **techlead-orchestrator** - Distributed team coordination
25. **design-reviewer** - Visual design review with 6-pillar UI audit (trigger: `em-agent:design-reviewer`)
26. **devex-reviewer** - Developer experience audit and TTHW measurement (trigger: `em-agent:devex-reviewer`)
27. **iron-law-enforcer** - Gate enforcement for Iron Law compliance (trigger: `em-agent:iron-law-enforcer`)

## Workflow Categories

### Primary Workflows
1. **new-feature** - From idea to production
2. **bug-fix** - Investigate and fix bugs
3. **refactoring** - Improve code quality
4. **security-audit** - Security assessment

### Support Workflows
5. **project-setup** - Initialize new projects
6. **documentation** - Generate and update docs
7. **deployment** - Deploy and monitor
8. **retro** - Learn and improve
9. **ship-workflow** - Version bump, changelog, PR creation
10. **canary-monitoring** - Post-deploy health monitoring

### Master Workflow
11. **six-phase-lifecycle** - DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP (all workflows inherit this)

### Team Workflows (8 workflows)
12. **team-review** - Full team review orchestrated by Team Lead
13. **architecture-review** - Architecture review with Architect & Staff Engineer
14. **design-review** - UI/UX design review with Frontend Expert & Product Manager
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

- **Languages**: JavaScript/TypeScript, Python, Go, Rust, Java, Kotlin, PHP, C#, C++
- **Frontend**: React, Next.js, Vue, Svelte, Angular
- **Backend**: Node.js, Django, Laravel, NestJS, Spring Boot, Express
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis
- **Testing**: Jest, Playwright, Cypress, pytest
- **Tools**: Git, Docker, CI/CD, MCP

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

Current version: 2.2.0
Last updated: 2026-05-02
Changes: v2.2.0 — Consistency audit fixes + CI validation pipeline + auto-changelog hook + session handoff + additional skills reorganized into skills/additional/

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

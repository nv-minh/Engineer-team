# EM-Team - Fullstack Engineering Agent System

> 86 skills, 36 agents, 27 workflows. Powered by Hermes Protocol v4.0.0 · System v5.5.0.

## What is EM-Team?

EM-Team is a system of AI agents, skills, and workflows for fullstack engineering — from brainstorming to production deployment. It runs inside [Claude Code](https://claude.ai/code) and supports any tech stack.

## What's New in v5.5.0 — Naming Convention Refactor

Replaced the flat `em:{name}` namespace with explicit type prefixes for all 140 slash commands — eliminating ambiguity between agents, workflows, and skills.

| Namespace | Example | What it is |
|-----------|---------|------------|
| `/em-agent:{name}` | `/em-agent:planner` | AI specialist agents |
| `/em-wf:{name}` | `/em-wf:new-feature` | Multi-stage workflows |
| `/em-skill:{name}` | `/em-skill:brainstorming` | Techniques and patterns |

**What changed:**
- All 140 `.claude/skills/` entry points renamed to the typed namespace
- 14 short-name aliases removed (e.g., `em:debug` → `em-agent:debugger`)
- `senior-code-reviewer` and `security-auditor` fully deleted (merged into `code-reviewer` Deep mode and `security-reviewer` Audit mode)
- `install.sh` now creates 3 command directories: `em-agent/`, `em-wf/`, `em-skill/`
- Migration script: `scripts/migration/migrate-names.sh`

## What's New in v5.4.0 — Brownfield Intelligence Improvements

19 gaps closed across 4 phases. Agents now understand your existing codebase at the business-domain level before investigating bugs, verifying features, or writing tests.

| Improvement | Detail |
|-------------|--------|
| **New skill: `brownfield-pr-impact`** | Assess PR/branch impact on brownfield flows before merge — surfaces AC-at-risk and contract breaks |
| **8 new scripts** | `detect-stack.sh`, `scan-nestjs.sh`, `scan-react.sh`, `scan-monorepo.sh`, `symbol-resolver.sh`, `build-backlinks.sh`, `validate-refs.sh`, `quality-score.sh` |
| **JSON sidecars** | `FLOWS.json`, `CODE-MAP.json`, `INDEX.json` — programmatic access without markdown parsing |
| **Stable IDs** | `FLOW-{MODULE}-{NNN}` + `AC-{MODULE}-{NNN}` — stable across refactors, referenced by agents + tests |
| **Symbol-first CODE-MAP** | `Class.method` refs resolved at runtime via `symbol-resolver.sh` — no more fragile `file:line` |
| **Quality gate** | `validate-refs.sh` (0 broken refs) + `quality-score.sh` (Grade A/B/C/D) |
| **Privacy layer** | PII/Sensitive Fields table + Data Subject Rights checklist in DOMAIN.md |
| **Agent integrations** | `debugger`, `verifier`, `brownfield-test-engineer`, `new-feature`, `bug-fix` all load brownfield context automatically |
| **End-to-end verified** | Tested on real project: 55 files, 8 modules, Grade A (100/100), 193 refs / 0 broken |

## What's New in v5.3.0 — Architect/Code/Review Quality Upgrade

Code review now runs **before** tests in every VERIFY stage — ensuring review fixes are re-validated by the test suite before ship.

| Component | Change |
|-----------|--------|
| `new-feature` v3.3.0 · `bug-fix` v3.2.0 | Code-review diff scan moved to **Step 5.1 (FIRST)** in VERIFY stage — runs before test suite |
| `six-phase-lifecycle` · `greenfield-app` · `refactoring` · `distributed-development` | Same code-review-first ordering applied consistently |
| Rollback readiness gate (Stage 6.1) | Added before marking feature/fix shipped |
| Handoff contracts | Strengthened with `on_failure` + `retry_budget` + `escalation_path` |
| `spec-driven-development` v3.1.0 | Testability check upgraded: advisory → ⛔ hard gate; conflict detection added (Phase 1.5); Assumption Approval Gate |
| `architect` v2.1.0 | Phase 0 existing architecture snapshot; Phase 7 ADR generation MANDATORY (Decision/Context/Alternatives/Consequences/Compliance Criteria) |
| `architecture-review` v2.2.0 | Stage 0 entry criteria gate (4 mandatory checkboxes); Gate 3 requires ADR + compliance criteria |
| `code-review` v3.1.0 · `code-reviewer` v2.1.0 | Step 1.5 diff classification (NEW/MODIFIED/DELETED); Step 4.5 cross-file impact scan (callers, dependents, shared state) |

## What's New in v5.2.0 — TC-Code Coverage Gate

The entire TC-Registry → test-code enforcement chain is now closed: every TC-ID in TC-REGISTRY.md **must** have a `test("TC-XXX-NNN: ...")` block (or `test.todo()`) in the corresponding test file.

Convention: unautomated TCs use `test.todo("TC-XXX-NNN: [title]")` — never drop a TC-ID silently.

## What's New in v5.1.0 — Expert-QC Testing Skills

New `test-case-design` skill centralizes systematic QA test-design techniques (BVA, EP, Decision Table, State Transition, Pairwise, Risk-Based Testing) plus abuse cases, non-functional cases, oracle specification, and mutation sanity gate. Now **mandatory upstream** of test-generation/api-testing/e2e-testing/browser-testing.

## What's New in v4.0.0 — Hermes Protocol

The entire codebase has been restructured following the [Hermes philosophy](https://nousresearch.com/) for maximum AI steerability and tool precision.

### Key Benefits

| Benefit | Before | After |
|---------|--------|-------|
| **Agent accuracy** | Prose-based prompts, agents sometimes skip steps or drift | Structured `[ROLE]`/`[RULES]`/`[PROCESS]` blocks — agents follow instructions precisely |
| **Output consistency** | Format varies between runs — prose, tables, YAML mixed | JSON Schema (`output_schema`) enforces consistent structured output every time |
| **Error recovery** | Vague "something went wrong" responses | `error_schema` returns `{ error_type, message, suggestion, retry_possible }` — agents self-correct |
| **Long workflow coherence** | 12-stage greenfield workflow loses context by stage 8 | ReAct protocol with context pruning — state snapshots carry decisions forward |
| **Context efficiency** | ~55K lines of verbose prose | ~16K lines — 70% reduction, faster loading, lower token cost |
| **LLM flexibility** | Hardcoded to Anthropic API only | Provider-agnostic: Anthropic, OpenAI, Ollama (local Hermes 3), vLLM, custom endpoints |

### What Changed

- **38 agents**: Restructured with `[ROLE]`, `[OBJECTIVE]`, `[RULES]`, `[AVAILABLE SKILLS]`, `[PROCESS]`, `[RESPONSE FORMAT]`, `[HANDOFF]` blocks + `input_schema`/`output_schema` in frontmatter
- **88 skills**: Added `input_schema`, `output_schema`, `error_schema` (JSON Schema in YAML frontmatter)
- **27 workflows**: Converted to ReAct protocol (Thought→Action→Observation) with context pruning and state snapshots
- **Preambles**: Rewritten as imperative Hermes-native blocks
- **LLM client**: `scripts/llm-config.sh` supports 5 providers via env vars

---

## Installation

```bash
git clone https://github.com/nv-minh/agent-team.git
cd agent-team
bash install.sh
```

Verify:
```bash
ls ~/.claude/commands/em-agent/*.md | wc -l   # 40 agent commands
ls ~/.claude/commands/em-wf/*.md | wc -l      # 24 workflow commands
ls ~/.claude/commands/em-skill/*.md | wc -l   # 76 skill commands
```

### Post-Install: Enable Features

Add to `.claude/settings.local.json` in your **target project**:

```json
{
  "env": {
    "EM_TEAM_ARTIFACT_EXPORT": "true",
    "EM_TEAM_SESSION_AUDIT": "true",
    "EM_TEAM_ATOMIC_COMMITS": "true"
  }
}
```

| Toggle | What it enables |
|--------|----------------|
| `EM_TEAM_ARTIFACT_EXPORT` | Artifact export + Feature Workspace (`.em-feature-context`) — **required for cross-prompt tracking** |
| `EM_TEAM_SESSION_AUDIT` | Session audit logging |
| `EM_TEAM_ATOMIC_COMMITS` | One atomic commit per task |

See [INSTALLATION.md](INSTALLATION.md) for full details.

Uninstall: `bash uninstall.sh`

---

## Quick Start

### Skills (86)

```bash
/em-skill:spec-driven-development    # Write spec before coding
/em-skill:brainstorming              # Explore ideas
/em-skill:code-review                # 5-axis code review
/em-skill:codebase-architecture      # Research architecture patterns
/em-skill:github-pr-manager          # Create PR with AI description
/em-skill:brownfield-onboarding      # Onboard existing codebase
/em-skill:react                      # React patterns
```

### Agents (36)

```bash
/em-agent:planner              # Create implementation plans
/em-agent:executor             # Execute with atomic commits
/em-agent:code-reviewer        # 5-axis or 9-axis code review
/em-agent:debugger             # Scientific method debugging
/em-agent:architect            # Architecture design
/em-agent:backend-expert       # API, database, performance
/em-agent:frontend-expert      # React, Next.js, UI/UX
/em-agent:react-expert         # React/Next.js specialist
/em-agent:security-reviewer    # OWASP audit + STRIDE threat modeling
```

### Workflows (27)

```bash
/em-wf:new-feature            # Idea → production (6 stages)
/em-wf:greenfield-app         # Blank dir → shipped app (12 stages)
/em-wf:bug-fix                # Systematic bug fixing
/em-wf:qa-bug-hunter          # QA testing → find bugs → human gate → GitHub issues
/em-wf:refactoring            # Code quality improvement
/em-wf:security-audit         # OWASP security assessment
/em-wf:code-review            # Deep 9-axis code review workflow
/em-wf:japanese-outsourcing   # 9-stage formal outsourcing workflow
```

---

## System Overview

### Counts

| Category | Count | Examples |
|----------|-------|---------|
| **Foundation Skills** | 11 | spec-driven-development, brainstorming, domain-modeling, brownfield-onboarding |
| **Development Skills** | 12 | TDD, architecture-improvement, codebase-architecture, diagram |
| **Expert Skills** | 34 | React, Vue, Go, NestJS, Python, Database, DevOps, Mobile, Rust, TypeScript |
| **Quality Skills** | 14 | test-case-design, code-review, e2e-testing, security-audit, test-generation, ux-audit |
| **Workflow Skills** | 14 | git-workflow, github-pr-manager, brownfield-context-sync, brownfield-pr-impact |
| **Additional Skills** | 5 | jobs-to-be-done, lean-ux-canvas, office-hours |
| **Core Agents** | 8 | planner, executor, code-reviewer, debugger, test-engineer, verifier |
| **Specialized Agents** | 20 | architect, team-lead, staff-engineer, product-manager, iron-law-enforcer |
| **Expert Agents** | 7 | react-expert, vue-expert, devops-expert, mobile-expert, rust-expert |
| **Test Agents** | 3 | playwright-setup, brownfield-test-engineer, test-verifier |
| **Primary Workflows** | 7 | new-feature, greenfield-app, bug-fix, qa-bug-hunter, brownfield-investigation |
| **Team Workflows** | 8 | team-review, architecture-review, code-review-9axis, incident-response |
| **Support Workflows** | 12 | project-setup, deployment, ship-workflow, distributed-development |

### Iron Laws

1. **TDD**: No production code without failing test
2. **Debugging**: No fixes without root cause
3. **Spec**: No code without spec (for features)
4. **Review**: No merge without review

### Development Lifecycle

```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP
```

All workflows inherit this 6-phase structure with verification gates between phases.

---

## Hermes Protocol Details

### Agent Block Structure

Every agent uses structured blocks instead of prose:

```markdown
[ROLE]
Methodical debug engineer. Scientific method for root cause analysis.

[OBJECTIVE]
Find root cause. Implement fix with regression test. Verify.

[RULES]
1. Output <thought> before every action.
2. NEVER patch symptoms. Find root cause first.
3. Create regression test BEFORE implementing fix.

[AVAILABLE SKILLS]
- systematic-debugging
- test-driven-development

[PROCESS]
Phase 1 - INVESTIGATE: Gather symptoms, logs, stack traces.
Phase 2 - ANALYZE: Form ranked hypotheses.
Phase 3 - HYPOTHESIZE: Test each hypothesis.
Phase 4 - IMPLEMENT: Fix root cause, write regression test.

[RESPONSE FORMAT]
Reference output_schema in frontmatter.

[HANDOFF]
executor → code-reviewer
```

### Skill JSON Schema

Every skill has `input_schema`, `output_schema`, `error_schema` in YAML frontmatter:

```yaml
input_schema:
  type: object
  required: [target]
  properties:
    target: { type: string, description: "What to review" }
    depth: { type: string, enum: [standard, deep] }

output_schema:
  type: object
  required: [status, findings]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    findings:
      type: array
      items:
        type: object
        properties:
          severity: { type: string, enum: [CRITICAL, HIGH, MEDIUM, LOW] }
          issue: { type: string }
          location: { type: string }
          fix: { type: string }
```

### Workflow ReAct Protocol

Every workflow stage uses Thought→Action→Observation loops:

```markdown
<thought>
Observe: Bug report received. Symptoms: login timeout.
Analyze: Need reproduction and evidence.
Plan: Invoke debugger agent.
</thought>

<action>
type: invoke_agent
target: debugger
params: { mode: find_root_cause }
</action>

<observation>
result: Root cause identified — DB connection pool exhausted.
gate_status: PASS
</observation>
```

Context pruning after each stage produces a state snapshot (~500 tokens) that carries forward key decisions while discarding verbose intermediate output.

### LLM Provider Configuration

```bash
LLM_PROVIDER=anthropic                                                # Default: Anthropic
LLM_PROVIDER=ollama LLM_MODEL=hermes3                                 # Local Hermes 3
LLM_PROVIDER=openai LLM_MODEL=gpt-4o-mini                            # OpenAI
LLM_PROVIDER=custom LLM_BASE_URL=http://my-server/v1 LLM_MODEL=mine  # Custom endpoint
```

### Validation

```bash
bash scripts/validate-hermes.sh           # Check compliance
bash scripts/validate-hermes.sh --verbose  # Detailed output
```

---

## Project Structure

```
em-team/
├── agents/          # 36 agents (Hermes block structure)
│   └── _shared/     # Shared preambles (expert-preamble for 7 expert agents)
├── skills/          # 86 skills (JSON Schema in frontmatter)
│   ├── foundation/  # 11 core skills
│   ├── development/ # 12 methodology skills
│   ├── quality/     # 14 QA skills
│   ├── workflow/    # 14 workflow skills
│   ├── expert-*/    # 34 expert skills (React, Vue, Go, Python, etc.)
│   └── additional/  # 5 product skills
├── workflows/       # 27 workflows (ReAct protocol)
│   └── _shared/     # Reusable sub-stages (stage-0-git-bootstrap)
├── preambles/       # Hermes preambles (agent, skill, ethos)
├── protocols/       # Communication & error standards (8 protocols)
├── templates/       # Reusable templates + Hermes schema references
├── scripts/         # Runtime scripts (llm-config, validation, benchmark, orchestration)
├── distributed/     # Distributed agent orchestration (tmux-based)
├── .claude/         # Libraries, MCP servers, rules
├── docs/            # Documentation
└── CLAUDE.md        # Main configuration
```

---

## Key Features

### Distributed Agent Orchestration

Run multiple agents in parallel tmux sessions, each with independent 200K token context:

```bash
./scripts/distributed-orchestrator.sh start            # Launch tmux sessions
/em-wf:distributed-investigation Investigate auth bug  # Parallel investigation
./scripts/consolidate-reports.sh consolidate   # Merge reports
./scripts/distributed-orchestrator.sh stop     # Cleanup
```

### Test Automation Pipeline

3-agent chain: `playwright-setup` → `brownfield-test-engineer` → `test-verifier`

- Auto-detects stack, installs Playwright, generates config
- Generates test cases from spec (unit + integration + E2E)
- Verifies results with max 3 retries and targeted fixes

### Feature Workspace

Tracks all artifacts for a feature across multiple prompt iterations:

```
.em-artifacts/new-feature/user-dashboard/
├── SPEC.md              # Updated in place (living doc)
├── TC-REGISTRY.md       # Updated in place (living doc)
├── test-executions/     # Timestamped logs (append)
├── evidence/            # Screenshots, videos
└── ITERATION-LOG.md     # Auto-tracked changes
```

Switch back to an old feature anytime:

```bash
bash scripts/artifact-register.sh workspace                # List all workspaces
bash scripts/artifact-register.sh switch user-dashboard     # Reactivate old feature
# Next prompt continues updating that workspace
```

### Artifact Export

Export skill outputs as Markdown with workflow-aware sub-folders:

```
specs/new-feature/       # Feature specs
test-reports/bug-fix/    # Test reports by workflow
reviews/refactoring/     # Code reviews
architecture/greenfield/ # Architecture decisions
```

### Protocols & Shared Components

**8 protocols** in `protocols/` standardize communication and error handling across the system:
- **error-handling.md** — Standardized error taxonomy (`CONTEXT_OVERFLOW`, `BUILD_DEADLOCK`, `SPEC_CONFLICT`, etc.) with `max_retries_per_stage: 2` policy
- **naming-convention.md** — Entry point naming rules: `em-agent:{name}`, `em-wf:{name}`, `em-skill:{name}`
- Plus: writing-style, delegation, distributed-messaging, change-management, review-gates, report-format

**Shared components** reduce duplication:
- `agents/_shared/expert-preamble.md` — Shared schemas for 7 expert domain agents
- `workflows/_shared/stage-0-git-bootstrap.md` — Reusable git/spec bootstrap for new-feature, bug-fix workflows

### Brownfield Intelligence (v5.0.0)

Module-based business context system for existing codebases. Run `brownfield-onboarding` once to build a `.em-brownfield/` knowledge graph, then all agents understand your business flows.

| Component | Type | Purpose |
|-----------|------|---------|
| `brownfield-onboarding` | Skill | Scan codebase → per-module FLOWS/DOMAIN/INTEGRATIONS/CODE-MAP |
| `brownfield-investigation` | Workflow | Context-aware bug investigation with deep chain tracing |
| `brownfield-context-sync` | Skill | Detect drift, resolve cross-module contract breaks |
| `flow-discovery` (enhanced) | Skill | Optional business metadata for recorded UI flows |

```
.em-brownfield/
├── INDEX.md                    # Module registry + dependency graph
├── modules/{domain}/FLOWS.md   # Business flows with acceptance criteria
├── modules/{domain}/DOMAIN.md  # Entities, relationships
├── modules/{domain}/INTEGRATIONS.md
├── modules/{domain}/CODE-MAP.md
└── HEALTH-CHECK.md
```

### Quality Benchmark

```bash
bash scripts/benchmark-quality.sh           # Score all skills, agents, workflows (B1-B5)
bash scripts/benchmark-quality.sh --verbose  # Detailed per-file scoring
```

Grades: A+ (95+), A (90+), B+ (85+), B (80+), C+ (75+), C (70+), D (<70)

---

## Documentation

| Doc | Description |
|-----|-------------|
| [CLAUDE.md](CLAUDE.md) | Main configuration — skill/agent/workflow catalog |
| [docs/guides/getting-started.md](docs/guides/getting-started.md) | Quick start guide |
| [docs/guides/usage-guide.md](docs/guides/usage-guide.md) | Comprehensive usage (EN) |
| [docs/guides/brownfield.md](docs/guides/brownfield.md) | Brownfield Intelligence guide (EN) |
| [docs/guides/test-automation.md](docs/guides/test-automation.md) | Test Automation Chain guide (EN) |
| [docs/guides/new-feature-workflow.md](docs/guides/new-feature-workflow.md) | New Feature Workflow guide (EN) |
| [docs/guides/code-review.md](docs/guides/code-review.md) | Code Review guide (EN) |
| [docs/guides/security-review.md](docs/guides/security-review.md) | Security Review guide (EN) |
| [docs/vi/huong-dan-su-dung.md](docs/vi/huong-dan-su-dung.md) | Hướng dẫn tổng hợp (VI) |
| [docs/vi/brownfield.md](docs/vi/brownfield.md) | Hướng dẫn Brownfield Intelligence (VI) |
| [docs/architecture/distributed-system.md](docs/architecture/distributed-system.md) | Distributed orchestration |

---

## Version History

| Version | Highlights |
|---------|-----------|
| **5.5.0** | Naming Convention Refactor — `em-agent:`, `em-wf:`, `em-skill:` type prefixes; 14 aliases removed; deprecated agents deleted; 140 commands across 3 namespaces |
| **5.4.0** | Brownfield Intelligence v2 — 19 gaps closed; JSON sidecars; stable FLOW/AC IDs; symbol-first CODE-MAP; quality gate; privacy layer; 8 new scripts |
| **5.3.0** | Architect/Code/Review Quality Upgrade — code-review diff scan as Step 5.1 (FIRST) in all VERIFY stages; mandatory ADR generation; testability hard gate; cross-file impact scan |
| 5.2.0 | TC-Code Coverage Gate — closes TC-Registry→test-code enforcement chain across all skills, agents, and master workflows |
| 5.1.0 | Expert-QC Testing — `test-case-design` skill (BVA/EP/DT/ST/Pairwise/RBT + abuse + non-functional + oracle + mutation gate); 12-column TC-REGISTRY; risk-calibrated ratio floors |
| 5.0.0 | Brownfield Intelligence — module-based business context (.em-brownfield/), brownfield-investigation workflow, brownfield-context-sync skill |
| 4.1.0 | QA Bug Hunter workflow — human-gated GitHub issue creation from automated QA |
| 4.0.0 | Hermes Protocol — structured agent blocks, JSON Schema for skills, ReAct workflows, provider-agnostic LLM client |
| 3.10.0 | Feature Workspace — living docs, cross-iteration continuity |
| 3.9.0 | Artifact folder structure + Playwright auth config (4 strategies) |
| 3.8.0 | Test automation chain — 3 agents (playwright-setup, brownfield-test-engineer, test-verifier) |
| 3.7.0 | GitHub Management Suite — CI/CD, PR, Issue, Release management |
| 3.6.0 | Codebase architecture intelligence |
| 3.5.0 | Japanese outsourcing support |

## License

MIT License

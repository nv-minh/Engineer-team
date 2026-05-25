# EM-Team - Fullstack Engineering Agent System

> 85 skills, 38 agents, 26 workflows. Powered by Hermes Protocol v4.0.0.

## What is EM-Team?

EM-Team is a system of AI agents, skills, and workflows for fullstack engineering — from brainstorming to production deployment. It runs inside [Claude Code](https://claude.ai/code) and supports any tech stack.

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
- **85 skills**: Added `input_schema`, `output_schema`, `error_schema` (JSON Schema in YAML frontmatter)
- **26 workflows**: Converted to ReAct protocol (Thought→Action→Observation) with context pruning and state snapshots
- **Preambles**: Rewritten as imperative Hermes-native blocks
- **LLM client**: `scripts/llm-config.sh` supports 5 providers via env vars

---

## Installation

```bash
git clone https://github.com/nv-minh/agent-team.git
cd agent-team
bash install.sh
```

Verify: `ls ~/.claude/commands/em/*.md | wc -l` (should show 149+ files)

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

### Skills (85)

```bash
/em:skill:spec-driven-development    # Write spec before coding
/em:skill:brainstorming              # Explore ideas
/em:skill:code-review                # 5-axis code review
/em:skill:codebase-architecture      # Research architecture patterns
/em:skill:github-pr-manager          # Create PR with AI description
/em:skill:react                      # React patterns
```

### Agents (38)

```bash
/em:planner          # Create implementation plans
/em:executor         # Execute with atomic commits
/em:code-reviewer    # 5-axis or 9-axis code review
/em:debugger         # Scientific method debugging
/em:architect        # Architecture design
/em:backend-expert   # API, database, performance
/em:frontend-expert  # React, Next.js, UI/UX
/em:react-expert     # React/Next.js specialist
```

### Workflows (26)

```bash
/em:new-feature          # Idea → production (6 stages)
/em:greenfield-app       # Blank dir → shipped app (12 stages)
/em:bug-fix              # Systematic bug fixing
/em:qa-bug-hunter        # QA testing → find bugs → human gate → GitHub issues
/em:refactor             # Code quality improvement
/em:security-audit       # OWASP security assessment
/em:team                 # Full team review coordination
/em:japanese-outsourcing # 9-stage formal outsourcing workflow
```

---

## System Overview

### Counts

| Category | Count | Examples |
|----------|-------|---------|
| **Foundation Skills** | 10 | spec-driven-development, brainstorming, domain-modeling, project-dna |
| **Development Skills** | 12 | TDD, architecture-improvement, codebase-architecture, diagram |
| **Expert Skills** | 34 | React, Vue, Go, NestJS, Python, Database, DevOps, Mobile, Rust, TypeScript |
| **Quality Skills** | 13 | code-review, e2e-testing, security-audit, test-generation, ux-audit |
| **Workflow Skills** | 11 | git-workflow, ci-cd-automation, github-pr-manager, github-release-manager |
| **Additional Skills** | 5 | jobs-to-be-done, lean-ux-canvas, office-hours |
| **Core Agents** | 8 | planner, executor, code-reviewer, debugger, test-engineer, verifier |
| **Specialized Agents** | 21 | architect, team-lead, staff-engineer, product-manager, iron-law-enforcer |
| **Expert Agents** | 7 | react-expert, vue-expert, devops-expert, mobile-expert, rust-expert |
| **Test Agents** | 3 | playwright-setup, brownfield-test-engineer, test-verifier |
| **Primary Workflows** | 6 | new-feature, greenfield-app, bug-fix, qa-bug-hunter, refactoring, security-audit |
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
# Default: Anthropic
LLM_PROVIDER=anthropic

# Local Hermes 3 via Ollama
LLM_PROVIDER=ollama LLM_MODEL=hermes3

# OpenAI
LLM_PROVIDER=openai LLM_MODEL=gpt-4o-mini

# Custom endpoint
LLM_PROVIDER=custom LLM_BASE_URL=http://my-server/v1 LLM_API_KEY=xxx LLM_MODEL=my-model
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
├── agents/          # 38 agents (Hermes block structure)
├── skills/          # 85 skills (JSON Schema in frontmatter)
│   ├── foundation/  # 10 core skills
│   ├── development/ # 12 methodology skills
│   ├── quality/     # 13 QA skills
│   ├── workflow/    # 11 workflow skills
│   ├── expert-*/    # 34 expert skills (React, Vue, Go, Python, etc.)
│   └── additional/  # 5 product skills
├── workflows/       # 26 workflows (ReAct protocol)
├── preambles/       # Hermes preambles (agent, skill, ethos)
├── protocols/       # Communication standards
├── templates/       # Reusable templates + Hermes schema references
├── scripts/         # Runtime scripts (llm-config, validation, orchestration)
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
./scripts/distributed-orchestrator.sh start   # Launch tmux sessions
/em:distributed Investigate auth bug           # Parallel investigation
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

---

## Documentation

| Doc | Description |
|-----|-------------|
| [CLAUDE.md](CLAUDE.md) | Main configuration — skill/agent/workflow catalog |
| [docs/GUIDE-TEST-AUTOMATION-AND-WORKSPACE.md](docs/GUIDE-TEST-AUTOMATION-AND-WORKSPACE.md) | Test automation + Feature Workspace guide |
| [docs/guides/getting-started.md](docs/guides/getting-started.md) | Quick start guide |
| [docs/guides/usage-guide.md](docs/guides/usage-guide.md) | Comprehensive usage (EN) |
| [docs/vi/huong-dan-su-dung.md](docs/vi/huong-dan-su-dung.md) | Comprehensive usage (VI) |
| [docs/architecture/distributed-system.md](docs/architecture/distributed-system.md) | Distributed orchestration |

---

## Version History

| Version | Highlights |
|---------|-----------|
| **4.1.0** | QA Bug Hunter workflow — human-gated GitHub issue creation from automated QA |
| 4.0.0 | Hermes Protocol — structured agent blocks, JSON Schema for skills, ReAct workflows, provider-agnostic LLM client |
| 3.10.0 | Feature Workspace — living docs, cross-iteration continuity |
| 3.9.0 | Artifact folder structure + Playwright auth config (4 strategies) |
| 3.8.0 | Test automation chain — 3 agents (playwright-setup, brownfield-test-engineer, test-verifier) |
| 3.7.0 | GitHub Management Suite — CI/CD, PR, Issue, Release management |
| 3.6.0 | Codebase architecture intelligence |
| 3.5.0 | Japanese outsourcing support |

## License

MIT License

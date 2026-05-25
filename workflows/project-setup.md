---
name: project-setup
description: Project initialization workflow for new fullstack projects
version: "2.1.0"
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
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Project Setup Workflow

```
CHOOSE → SCAFFOLD → CONFIGURE → TEST → INITIALIZE
   1         2           3         4          5
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase |
|---|---|
| CHOOSE (Stage 1) | DEFINE |
| SCAFFOLD (Stage 2) | PLAN + BUILD |
| CONFIGURE (Stage 3) | BUILD |
| TEST (Stage 4) | VERIFY |
| INITIALIZE (Stage 5) | REVIEW + SHIP |

---

### Stage 1: CHOOSE

<thought>
Observe: New project needed — no tech stack decided yet.
Analyze: Must understand requirements, evaluate tech stack options, make decision with rationale. Gate requires requirements understood, options evaluated, decision documented.
Plan: Invoke planner agent with brainstorming skill.
</thought>

<action>
type: invoke_agent
target: planner
params:
  skill: brainstorming
  task: evaluate_tech_stack
  outputs: [requirements, options_evaluation, tech_decision, rationale]
</action>

<observation>
result: Requirements understood, options evaluated, tech stack decision made with rationale
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Requirements understood
- [ ] Options evaluated
- [ ] Decision made
- [ ] Rationale documented

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CHOOSE
  completed: []
  next_action: "SCAFFOLD"
```

---

### Stage 2: SCAFFOLD

<thought>
Observe: Tech stack decided with rationale.
Analyze: Must create project structure, initialize git, configure package.json. Gate requires structure created, git initialized, package.json configured.
Plan: Invoke executor agent.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: scaffold_project
  input: tech_decision
  outputs: [project_structure, git_repo, package_json]
</action>

<observation>
result: Project structure created, git initialized, package.json configured
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Structure created
- [ ] Git initialized
- [ ] Package.json configured
- [ ] Tooling setup planned

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SCAFFOLD
  completed: [CHOOSE]
  next_action: "CONFIGURE"
```

---

### Stage 3: CONFIGURE

<thought>
Observe: Project scaffolded with structure and git repo.
Analyze: Must set up TypeScript, ESLint, tests, CI/CD, build pipeline. Gate requires TypeScript compiles, ESLint passes, tests configured, build succeeds, CI/CD active.
Plan: Invoke executor agent with ci-cd-automation skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  skill: ci-cd-automation
  task: configure_tooling
  outputs: [typescript_config, eslint_config, test_config, cicd_pipeline, build_config]
</action>

<observation>
result: TypeScript compiles, ESLint passes, tests configured, build succeeds, CI/CD active
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] TypeScript compiles
- [ ] ESLint passes
- [ ] Tests configured
- [ ] Build succeeds
- [ ] CI/CD active

**State Snapshot:**
```yaml
workflow_state:
  current_phase: CONFIGURE
  completed: [CHOOSE, SCAFFOLD]
  next_action: "TEST"
```

---

### Stage 4: TEST

<thought>
Observe: All tooling configured.
Analyze: Must verify tooling works end-to-end, build verifies, CI/CD pipeline runs. Gate requires tooling works, build verifies, CI/CD passes.
Plan: Invoke executor agent to verify setup.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: verify_setup
  outputs: [tooling_verified, build_verified, cicd_verified]
</action>

<observation>
result: Tooling works, build verifies, CI/CD passes
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Tooling works
- [ ] Build verifies
- [ ] CI/CD works
- [ ] Deployment successful (if applicable)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: TEST
  completed: [CHOOSE, SCAFFOLD, CONFIGURE]
  next_action: "INITIALIZE"
```

---

### Stage 5: INITIALIZE

<thought>
Observe: All tooling verified and working.
Analyze: Must make initial commit, push repository, create branches, set up protections, invite team.
Plan: Invoke executor agent with git-workflow skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: initialize_repository
  outputs: [initial_commit, repo_pushed, branches_created, protections_set]
</action>

<observation>
result: Initial commit made, repo pushed, branches created, protections set
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Initial commit made
- [ ] Repository pushed
- [ ] Branches created
- [ ] Protections setup
- [ ] Team invited

**State Snapshot:**
```yaml
workflow_state:
  current_phase: INITIALIZE
  completed: [CHOOSE, SCAFFOLD, CONFIGURE, TEST]
  next_action: "DONE"
```

---

## Optional: Project DNA Generation

After project setup, generate agent guidance files using `project-dna` skill:
- When invoked from greenfield-app: automatically runs as Stage 8 (Crystallize)
- When standalone: requires tech stack choices and project description

## Handoff Contracts

### Plan → Scaffold
```yaml
handoff:
  from: planner
  to: executor
  provides: [tech_stack_decisions, project_structure, architecture_doc]
  expects: [scaffolded_project, build_passing, initial_commit]
```

### Scaffold → CI/CD
```yaml
handoff:
  from: executor
  to: executor
  provides: [project_structure, test_framework_configured]
  expects: [ci_pipeline_active, repo_pushed, branches_created]
```

---

## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |
| `SCAFFOLD_FAILURE` | Project generator fails | Check runtime version, clear cache | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

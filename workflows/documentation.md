---
name: documentation
description: Documentation generation and update workflow
version: "2.1.0"
category: "support"
origin: "agent-skills"
agents_used:
  - executor
skills_used:
  - documentation
  - code-review
  - api-interface-design
related_skills:
  - api-interface-design
  - finishing-branch
estimated_time: "4-8 hours (simple) / 1-2 days (complex)"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
---

# Documentation Workflow

```
ANALYZE → GENERATE → REVIEW → UPDATE → PUBLISH
   1          2          3        4         5
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase |
|---|---|
| ANALYZE (Stage 1) | DEFINE |
| GENERATE (Stage 2) | PLAN + BUILD |
| REVIEW (Stage 3) | VERIFY |
| UPDATE (Stage 4) | REVIEW |
| PUBLISH (Stage 5) | SHIP |

---

### Stage 1: ANALYZE

<thought>
Observe: Documentation needed — scope not yet defined.
Analyze: Must define documentation scope, analyze codebase for documentable surfaces, clarify requirements. Gate requires scope defined, code analyzed, requirements clear.
Plan: Analyze codebase to identify documentation targets.
</thought>

<action>
type: invoke_skill
target: documentation
params:
  task: analyze_documentation_scope
  outputs: [documentation_scope, code_analysis, requirements]
</action>

<observation>
result: Scope defined, codebase analyzed, requirements clarified
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Scope defined
- [ ] Code analyzed
- [ ] Requirements clear

**State Snapshot:**
```yaml
workflow_state:
  current_phase: ANALYZE
  completed: []
  next_action: "GENERATE"
```

---

### Stage 2: GENERATE

<thought>
Observe: Documentation scope defined, codebase analyzed.
Analyze: Must write API docs, architecture docs, user guides, examples, diagrams. Gate requires docs complete, examples working, diagrams accurate.
Plan: Invoke executor agent with documentation skill.
</thought>

<action>
type: invoke_agent
target: executor
params:
  skill: documentation
  task: generate_documentation
  outputs: [api_docs, architecture_docs, user_guides, examples, diagrams]
</action>

<observation>
result: API docs complete, architecture documented, examples working, diagrams accurate
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] API docs complete
- [ ] Architecture documented
- [ ] Examples working
- [ ] Diagrams accurate

**State Snapshot:**
```yaml
workflow_state:
  current_phase: GENERATE
  completed: [ANALYZE]
  next_action: "REVIEW"
```

---

### Stage 3: REVIEW

<thought>
Observe: Documentation generated.
Analyze: Must review for accuracy, test examples, verify code snippets work. Gate requires docs accurate, examples tested, no errors.
Plan: Review and test all documentation.
</thought>

<action>
type: invoke_skill
target: documentation
params:
  task: review_documentation
  outputs: [accuracy_report, tested_examples]
</action>

<observation>
result: Documentation accurate, examples tested, code snippets verified
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Documentation accurate
- [ ] Examples tested
- [ ] Code snippets work
- [ ] No errors found

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REVIEW
  completed: [ANALYZE, GENERATE]
  next_action: "UPDATE"
```

---

### Stage 4: UPDATE

<thought>
Observe: Review complete, issues identified.
Analyze: Must fix issues, update examples, improve clarity.
Plan: Invoke executor agent to apply fixes.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: update_documentation
  input: accuracy_report
  outputs: [issues_fixed, examples_updated, clarity_improved]
</action>

<observation>
result: Issues fixed, links working, clarity improved
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Issues fixed
- [ ] Links working
- [ ] Clarity improved

**State Snapshot:**
```yaml
workflow_state:
  current_phase: UPDATE
  completed: [ANALYZE, GENERATE, REVIEW]
  next_action: "PUBLISH"
```

---

### Stage 5: PUBLISH

<thought>
Observe: Documentation updated and verified.
Analyze: Must deploy documentation, verify links, notify team, archive old docs.
Plan: Deploy and notify.
</thought>

<action>
type: invoke_agent
target: executor
params:
  task: publish_documentation
  outputs: [documentation_deployed, links_verified, team_notified]
</action>

<observation>
result: Documentation deployed, links working, team notified
gate_status: PASS | FAIL
</observation>

**Quality Gate:**
- [ ] Documentation deployed
- [ ] Links working
- [ ] Team notified
- [ ] Old docs archived

**State Snapshot:**
```yaml
workflow_state:
  current_phase: PUBLISH
  completed: [ANALYZE, GENERATE, REVIEW, UPDATE]
  next_action: "DONE"
```

---

## Handoff Contracts

### Analyze → Generate
```yaml
handoff:
  from: manual
  to: executor
  provides: [documentation_scope, code_analysis]
  expects: [documentation_generated, examples_working]
```

## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.

## Context Pruning Protocol

After each stage observation:
- RETAIN: current phase, gate status, blocking issues, artifacts produced
- DISCARD: intermediate tool outputs, verbose logs
- SUMMARIZE: completed stages into 1-2 sentences each

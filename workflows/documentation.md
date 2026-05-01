---
name: documentation
description: Documentation generation and update workflow
version: "2.0.0"
category: "support"
origin: "agent-skills"
agents_used:
  - executor
skills_used:
  - documentation
  - code-review
  - api-interface-design
estimated_time: "4-8 hours (simple) / 1-2 days (complex)"
---

# Documentation Workflow

## Overview

The documentation workflow generates, updates, and maintains project documentation including API docs, architecture docs, and user guides.

## When to Use

- Generating documentation
- Updating existing docs
- Creating API references
- Writing architecture docs
- Documenting features

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Description |
|---|---|---|
| ANALYZE (Stage 1) | DEFINE | Define documentation scope, analyze codebase, clarify requirements |
| GENERATE (Stage 2) | PLAN + BUILD | Write API docs, architecture docs, user guides, examples |
| REVIEW (Stage 3) | VERIFY | Review for accuracy, test examples, verify code snippets work |
| UPDATE (Stage 4) | REVIEW | Fix issues, update examples, improve clarity |
| PUBLISH (Stage 5) | SHIP | Deploy documentation, verify links, notify team, archive old docs |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Scope defined
- [ ] Code analyzed
- [ ] Requirements clear
PASS → proceed to PLAN | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] API docs structure planned
- [ ] Architecture sections outlined
- [ ] Examples identified
- [ ] Diagrams sketched
PASS → proceed to BUILD | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] API docs complete
- [ ] Architecture documented
- [ ] Examples working
- [ ] Diagrams accurate
PASS → proceed to VERIFY | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Documentation accurate
- [ ] Examples tested
- [ ] Code snippets work
- [ ] No errors found
PASS → proceed to REVIEW | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Issues fixed
- [ ] Links working
- [ ] Clarity improved
- [ ] Documentation deployed
- [ ] Team notified
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ANALYZE → GENERATE → REVIEW → UPDATE → PUBLISH        │
│     1          2           3         4          5        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Documentation Types

### 1. API Documentation

```markdown
# API Reference

## Authentication

All API requests require authentication:

\`\`\`http
Authorization: Bearer YOUR_TOKEN_HERE
\`\`\`

## Users

### Create User

\`\`\`http
POST /api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!"
}
\`\`\`
```

### 2. Architecture Documentation

```markdown
# Architecture

## System Overview

\`\`\`
┌─────────────┐      ┌─────────────┐
│             │      │             │
│  Frontend   │─────▶│  Backend    │
│  (React)    │      │  (Node.js)  │
│             │      │             │
└─────────────┘      └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │             │
                    │  Database   │
                    │ (PostgreSQL)│
                    │             │
                    └─────────────┘
\`\`\`
```

## Handoff Contracts

### Analyze → Generate

```yaml
handoff:
  from: manual
  to: executor
  provides:
    - documentation_scope
    - code_analysis
  expects:
    - documentation_generated
    - examples_working
```

## Quality Gates Summary

```yaml
quality_gates:
  analyze:
    - scope_defined
    - code_analyzed
    - requirements_clear

  generate:
    - api_docs_complete
    - architecture_documented
    - examples_working
    - diagrams_accurate

  review:
    - documentation_accurate
    - examples_tested
    - code_snippets_work
    - no_errors_found

  update:
    - issues_fixed
    - examples_working
    - links_working
    - clarity_improved

  publish:
    - documentation_deployed
    - links_working
    - team_notified
    - old_docs_archived
```

## Timeline Estimate

```yaml
timeline:
  analyze: "30 min - 2 hours"
  generate: "2-6 hours"
  review: "1-2 hours"
  update: "1-4 hours"
  publish: "30 min - 1 hour"

  total_simple: "4-8 hours"
  total_complex: "1-2 days"
```

## Success Criteria

A successful documentation workflow:

- [ ] Documentation complete
- [ ] API reference accurate
- [ ] Examples tested and working
- [ ] Architecture documented
- [ ] User guides clear
- [ ] Diagrams accurate
- [ ] Documentation published
- [ ] Team can find information

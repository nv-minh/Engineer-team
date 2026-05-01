---
name: em:team-lead
description: Orchestrate full team review with multiple agents - EM-Team Command
tags: [team-lead, orchestration, review, em-team]
always_available: true
---

# EM:Team-Lead - Full Team Review Orchestration

Orchestrate comprehensive team review involving multiple specialized agents.

## Usage

```
Use the em:team-lead skill to orchestrate team review for [task description]
```

## Examples

```
Use the em:team-lead skill to orchestrate team review for new payment feature
Use the em:team-lead skill to orchestrate architecture review for microservices migration
Use the em:team-lead skill to orchestrate cross-functional review for checkout flow
```

## What This Does

Orchestrates a 7-stage review pipeline:

1. **Scope Analysis** (Team Lead) — Analyze task scope, select agents
2. **Business Validation** (Product Manager) — Requirements, GAP analysis
3. **Architecture Review** (Architect) — Technical design assessment
4. **Specialized Reviews** — Frontend, Database, Code Review as needed
5. **Security Review** (Security Reviewer) — OWASP, BLOCKING authority for CRITICAL/HIGH
6. **Deep Investigation** (Staff Engineer) — If complex issues found
7. **Consolidation** (Team Lead) — Merged report, final decision

## Quality Gates

- [ ] Business validation passed
- [ ] Architecture review passed
- [ ] Specialized reviews passed
- [ ] Security review passed (CRITICAL/HIGH blocks)
- [ ] Consolidated report complete

## Output

Consolidated Team Review Report with executive summary, all agent reports, findings, and APPROVED/CONDITIONAL/REJECTED decision.

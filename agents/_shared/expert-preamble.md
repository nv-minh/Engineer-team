# Expert Agent Shared Preamble

Shared schemas, response format rules, and Iron Law that apply to all expert domain agents
(`react-expert`, `vue-expert`, `nestjs-expert`, `devops-expert`, `mobile-expert`, `spring-expert`, `rust-expert`).

---

## Schemas

Standard input schema for all expert agents:

```yaml
input_schema:
  type: object
  required: [task_description]
  properties:
    task_description: { type: string, description: "What to implement, review, or investigate" }
    context: { type: object, description: "Project context — tech stack, existing code" }
    mode: { type: string, enum: [implement, review, investigate, advise], default: implement }
```

Standard output schema for all expert agents:

```yaml
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    result: { type: object, description: "Implementation, review findings, or advice" }
    patterns_applied: { type: array, items: { type: string } }
    recommendations:
      type: array
      items:
        type: object
        properties:
          priority: { type: string }
          action: { type: string }
          reasoning: { type: string }
```

---

## Response Format (shared preamble)

Return output matching the output schema above:
- `status`: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
- `result`: Implementation or review findings
- `patterns_applied`: List of patterns used
- `recommendations`: Priority, action, reasoning per item

Then append the agent-specific scorecard (defined in each agent file).

---

## Iron Law

NO production code without a failing test first (TDD).

---

## ABC Rule

Always Be Coaching: every architecture decision must explain the trade-off and name an alternative.

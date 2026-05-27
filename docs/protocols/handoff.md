# Agent Handoff Protocol

Every agent in EM-Team ends with a `[HANDOFF]` block that defines what it produced, who receives the output next, and what gates must pass before handoff is valid.

---

## Handoff Contract Fields

| Field | Description |
|-------|-------------|
| `output` | What this agent produced (e.g. PLAN.md, review findings, test results) |
| `next_agent` | Which agent or workflow stage receives the output |
| `context` | Key facts the next agent needs to do its job |
| `gate_status` | `PASS` — handoff proceeds · `FAIL` — handoff blocked until resolved |
| `on_failure` | What to do if gate_status is FAIL (retry, escalate, stop) |

---

## Standard Handoff Patterns

| From | To | Trigger condition |
|------|----|-------------------|
| `planner` | `executor` | PLAN.md accepted by user |
| `executor` | `code-reviewer` | All tasks committed, tests green |
| `code-reviewer` | `verifier` | No CRITICAL/HIGH findings (or all resolved) |
| `verifier` | `executor` | FAIL — spec gaps or failing tests found |
| `brownfield-test-engineer` | `test-verifier` | TC-REGISTRY complete + test files written |
| `test-verifier` | next workflow stage | PASS with confidence score ≥ 80% |
| `debugger` | `executor` | Root cause confirmed + fix approach decided |
| `security-reviewer` | workflow gate | CRITICAL blocks deploy+merge · HIGH blocks merge |

---

## Escalation Rules

Escalate to `team-lead` when:
- Two agents disagree and conflict cannot be resolved
- A finding exceeds the scope of the current workflow
- Gate is FAIL after max retries exhausted

Escalate to `staff-engineer` when:
- Root cause spans multiple services
- Production incident with P0/P1 severity
- Cross-service contract break detected

---

## Example Handoff Block (from executor → code-reviewer)

```
[HANDOFF]
output: 8 atomic commits on feat/payment-v2, all tests green
next_agent: code-reviewer
context:
  - Changed PaymentService.charge signature (3 callers updated)
  - New StripeWebhookController added (no existing tests)
  - Spec: docs/specs/payment-v2.md
gate_status: PASS
```

---

**Version:** 5.5.0
**Last Updated:** 2026-05-27

See also: [Messaging Protocol](messaging.md) · [Report Format](report-format.md) · [Agent Reference](../agents/reference.md)

# [Module Name] — External Integrations

## Module Reference
- **Flows:** [FLOWS.md](./FLOWS.md)
- **Domain:** [DOMAIN.md](./DOMAIN.md)
- **Code Map:** [CODE-MAP.md](./CODE-MAP.md)

## Dependencies
- [module-name](../module-name/INTEGRATIONS.md) — shared integration or data consumed from another module

## Depended By
- [module-name](../module-name/INTEGRATIONS.md) — modules that consume data this module provides

---

## Integration: [Service Name] (e.g., Stripe, SendGrid, AWS S3)

### Connection
- **Type:** REST API | SDK | Webhook | Message Queue | gRPC | GraphQL
- **Package:** [npm/pip/gem package name and version — e.g., stripe@14.x]
- **Base URL:** [endpoint pattern — e.g., https://api.stripe.com/v1/]
- **Config:** [env var names — NEVER write actual values]
  - `STRIPE_API_KEY` — API authentication
  - `STRIPE_WEBHOOK_SECRET` — Webhook signature verification

### Usage in Flows
| Flow | Step | Action | Data Sent | Data Received | Critical? |
|------|------|--------|-----------|---------------|-----------|
| [Flow name] | Step N | [create/read/update/delete] | [payload shape] | [response shape] | Yes/No |

### Failure Handling
- **Timeout:** [duration] → [behavior — e.g., "retry after 1s"]
- **Retry Policy:** [max retries, backoff strategy — e.g., "3 retries, exponential backoff"]
- **Circuit Breaker:** [Yes/No — if yes, threshold and recovery time]
- **Fallback:** [what happens when service is completely unavailable]
  - [e.g., "Queue for later processing" or "Return cached value" or "Block operation with error"]
- **Idempotency:** [Yes/No — idempotency key strategy if applicable]

### SLA Expectations
- **Availability:** [expected uptime — e.g., 99.9%]
- **Latency:** [expected p50/p99 response time — e.g., "p50: 200ms, p99: 2s"]
- **Rate Limits:** [if known — e.g., "100 requests/second"]

### Data Contract
```
// Request shape (simplified)
{
  [key]: [type] // [description]
}

// Response shape (simplified)  
{
  [key]: [type] // [description]
}
```

---

## Integration: [Second Service]
...

*(Repeat for each external integration in this module)*

---

## Internal Module Dependencies

These are not external services but other modules within the same codebase that this module calls directly:

| Module | How Called | Data Exchanged | Failure Impact |
|--------|-----------|---------------|----------------|
| [module-name](../module-name/FLOWS.md) | Direct function call / Event / Message queue | [data shape] | [what breaks if this module is unavailable] |

---

**Template Version:** 5.0.0
**Created By:** brownfield-onboarding skill

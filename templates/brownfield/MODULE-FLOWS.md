# [Module Name] — Business Flows

## Module Overview
- **Domain:** [Bounded context name]
- **Type:** Core | Supporting | Generic
- **Impact:** P0 | P1 | P2
- **Owner:** [Team/person responsible]
- **Last Verified:** YYYY-MM-DD

## Dependencies
- [module-name](../module-name/FLOWS.md) — 1-line why this module depends on it

## Depended By
- [module-name](../module-name/FLOWS.md) — 1-line why that module depends on this one

## Flow ID Convention

- Format: `FLOW-{MODULE}-{NNN}` where NNN is zero-padded 3-digit sequence (001, 002, ...)
- IDs are append-only: once assigned, NEVER rename or reuse.
- If a flow is deprecated, mark it `(DEPRECATED)` but keep the ID.
- Cross-references use the ID: "see FLOW-ORDER-003" not "see Create Order flow".

---

## Flow: [Flow Name] {#flow-id}

**Flow ID:** FLOW-{MODULE}-{NNN} ← stable identifier (never rename or reuse)

### Business Intent
- **Who:** [Persona/role — e.g., Customer (B2C), Admin, Manager]
- **What:** [Action description — what the user is trying to accomplish]
- **Why:** [Business value — why this flow exists, what happens if it breaks]
- **Impact Level:** P0 (critical — revenue/safety) | P1 (important — core feature) | P2 (nice-to-have)

### Happy Path
1. [Step description] → `[API endpoint or UI action]` → [expected result]
   - **Criticality:** high | medium | low
   - **Business rule:** [rule enforced at this step, if any]
   - **Data flow:** [what data is created/read/updated/deleted]
2. [Next step...]
   - **Criticality:** ...
   - **Business rule:** ...
   - **Data flow:** ...

### Error Paths
- **[Condition]** → [system behavior] → [user impact] → [recovery action]
- **[Condition]** → [system behavior] → [user impact] → [recovery action]

### Critical Business Rules
- [Rule 1: invariant or constraint that must never be violated]
- [Rule 2: business logic that affects flow behavior]
- [Rule 3: compliance or regulatory requirement]

### Acceptance Criteria
- [ ] AC-{MODULE}-001: [measurable criterion — e.g., "Order total matches sum of line items minus discount"]
- [ ] AC-{MODULE}-002: [criterion]
- [ ] AC-{MODULE}-003: [criterion]

### Known Issues
- #{issue-number}: [description] — [status: open | in-progress | wontfix]
- #{issue-number}: [description] — [status]

---

## Flow: [Second Flow Name] {#flow-id}

**Flow ID:** FLOW-{MODULE}-{NNN} ← stable identifier (never rename or reuse)

### Business Intent
...

*(Repeat for each flow in this module)*

---

**Template Version:** 5.0.0
**Created By:** brownfield-onboarding skill

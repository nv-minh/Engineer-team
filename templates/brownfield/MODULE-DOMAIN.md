# [Module Name] — Domain Model

## Module Reference
- **Flows:** [FLOWS.md](./FLOWS.md)
- **Integrations:** [INTEGRATIONS.md](./INTEGRATIONS.md)
- **Code Map:** [CODE-MAP.md](./CODE-MAP.md)

## Dependencies
- [module-name](../module-name/DOMAIN.md) — shared entities or cross-module relationships

## Depended By
- [module-name](../module-name/DOMAIN.md) — modules that reference entities from this domain

---

## Entities

### [Entity Name]
- **Type:** Aggregate Root | Entity | Value Object
- **Source:** [DB table name / ORM model file path]
- **Description:** [1-2 sentences: what this entity represents in business terms]

**Attributes:**
| Attribute | Type | Required | Default | Constraints | Notes |
|-----------|------|----------|---------|-------------|-------|
| id | UUID/int | Yes | auto | PK | |
| [name] | [type] | Yes/No | [default] | [constraint] | [business meaning] |

**PII / Sensitive Fields:**
| Attribute | Classification | Compliance | Notes |
|-----------|---------------|------------|-------|
| email | PII | GDPR | Required for login, deletable on request |
| password | Sensitive | — | Stored as bcrypt hash only |

**Data Subject Rights (if applicable):**
- [ ] Erasure path documented (which flow handles "delete my data"?)
- [ ] Export path documented (which flow handles "export my data"?)
- [ ] Consent management linked

**Business Rules (Invariants):**
- [Rule 1: constraint that must always hold — e.g., "Order total >= 0"]
- [Rule 2: validation rule — e.g., "Email must be unique per tenant"]

**Lifecycle States** (if stateful):
```
[Initial] → [State1] → [State2] → [Final]
           ↘ [ErrorState]
```
| From | To | Trigger | Side Effects |
|------|----|---------|-------------|
| [State1] | [State2] | [action/event] | [what happens on transition] |

### [Second Entity]
...

---

## Relationships

| From Entity | To Entity | Type | Cardinality | Cross-module? | Notes |
|-------------|-----------|------|-------------|---------------|-------|
| [Entity A] | [Entity B] | Association / Composition / Aggregation | 1:1 / 1:N / N:M | Yes (→ module) / No | [business meaning] |

---

## Ubiquitous Language

| Term | Definition | Code Name | DB Column | Notes |
|------|-----------|-----------|-----------|-------|
| [Business term] | [Precise definition in business context] | [variable/class name in code] | [column name if different] | [disambiguation] |

---

## Assumptions and Decisions

| Decision | Rationale | Date | Status |
|----------|-----------|------|--------|
| [What was decided about this domain] | [Why — business or technical reason] | YYYY-MM-DD | Active / Superseded |

---

**Template Version:** 5.0.0
**Created By:** brownfield-onboarding skill

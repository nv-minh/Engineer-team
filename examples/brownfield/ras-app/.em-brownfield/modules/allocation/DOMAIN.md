# allocation — Domain Model

## Module Reference
- **Flows:** [FLOWS.md](./FLOWS.md)
- **Integrations:** [INTEGRATIONS.md](./INTEGRATIONS.md)
- **Code Map:** [CODE-MAP.md](./CODE-MAP.md)

## Dependencies
- [employee](../employee/DOMAIN.md) — references Employee entity
- [project](../project/DOMAIN.md) — references Project + Position entities

## Depended By
- [dashboard](../dashboard/DOMAIN.md) — reads Allocation entities

---

## Entities

### Allocation
- **Type:** Aggregate Root
- **Source:** prisma schema `Allocation` model
- **Description:** Represents an employee's committed percentage to a project over a period.

**Attributes:**
| Attribute | Type | Required | Constraints | Notes |
|---|---|---|---|---|
| id | UUID | Yes | PK | |
| employee_id | UUID | Yes | FK -> Employee | |
| project_id | UUID | Yes | FK -> Project | |
| percentage | Int | Yes | 0 <= x <= 100 | Business rule: sum across overlapping periods <= 100 |
| start_date | Date | Yes | | |
| end_date | Date | Yes | end_date >= start_date | |
| created_at | DateTime | Yes | default now() | |
| updated_at | DateTime | Yes | auto | |

**Business Rules (Invariants):**
- INV-001: Sum of allocations for any employee in any overlapping period <= 100%
- INV-002: Audit log entry for every insert/update/delete

### AllocationAuditLog
- **Type:** Entity
- **Source:** prisma schema `AllocationAuditLog`
- **Description:** Append-only history of allocation changes.

### Position
- **Type:** Value Object (referenced from Project module)

## Ubiquitous Language

| Term | Definition | Code Name |
|---|---|---|
| Allocation | Percentage commitment for a date range | Allocation |
| Overallocation | Sum > 100% in overlapping period | (not a stored entity, computed) |
| Capacity | 100% - sum of allocations for an employee in a period | (computed) |

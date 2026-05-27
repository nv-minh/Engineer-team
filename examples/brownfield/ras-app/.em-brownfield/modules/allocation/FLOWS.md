# allocation — Business Flows

## Module Overview
- **Domain:** Allocation management (assigning employees to projects)
- **Type:** Core
- **Impact:** P0
- **Owner:** Resource ops team
- **Last Verified:** 2026-05-26

## Dependencies
- [employee](../employee/FLOWS.md) — needs employee skills/availability for valid allocations
- [project](../project/FLOWS.md) — needs project positions/dates for valid allocations
- [audit](../audit/FLOWS.md) — writes audit log entries

## Depended By
- [dashboard](../dashboard/FLOWS.md) — reads allocations to display capacity views

## Flow ID Convention
- Format: `FLOW-ALLOCATION-{NNN}` zero-padded.
- IDs are append-only.

---

## Flow: Create Allocation (FLOW-ALLOCATION-001) {#flow-allocation-001}

**Flow ID:** FLOW-ALLOCATION-001

### Business Intent
- **Who:** Resource manager
- **What:** Assign an employee to a project at N% for a date range
- **Why:** Builds the project staffing plan; informs capacity dashboards
- **Impact Level:** P0

### Happy Path
1. POST /api/allocations -> AllocationController.create -> AllocationService.validate -> AllocationService.create
   - **Criticality:** high
   - **Business rule:** Total allocation per employee per period must be <= 100%
   - **Data flow:** creates `allocations` row + emits audit event

### Acceptance Criteria
- [ ] AC-ALLOCATION-001: Total allocation for any employee in any overlapping period <= 100%
- [ ] AC-ALLOCATION-002: Audit log entry created on every allocation insert
- [ ] AC-ALLOCATION-003: Allocation references valid employee_id and project_id

---

## Flow: Update Allocation (FLOW-ALLOCATION-002) {#flow-allocation-002}

**Flow ID:** FLOW-ALLOCATION-002

### Business Intent
- **Who:** Resource manager
- **What:** Adjust allocation percentage or date range
- **Why:** Project scope changes; team capacity shifts
- **Impact Level:** P0

### Acceptance Criteria
- [ ] AC-ALLOCATION-004: 100% invariant maintained after update
- [ ] AC-ALLOCATION-005: Audit log entry created with before/after values

---

## Flow: List Allocations (FLOW-ALLOCATION-003) {#flow-allocation-003}

**Flow ID:** FLOW-ALLOCATION-003

### Business Intent
- **Who:** Resource manager, dashboard consumers
- **What:** Query allocations by employee/project/period
- **Why:** Capacity planning
- **Impact Level:** P1

### Acceptance Criteria
- [ ] AC-ALLOCATION-006: Filter by employee, project, and date range supported

---

## Flow: Delete Allocation (FLOW-ALLOCATION-004) {#flow-allocation-004}

**Flow ID:** FLOW-ALLOCATION-004

### Business Intent
- **Who:** Resource manager
- **What:** Remove an allocation (employee leaves project)
- **Why:** Frees capacity for reassignment
- **Impact Level:** P0

### Acceptance Criteria
- [ ] AC-ALLOCATION-007: Soft-delete with audit trail (no hard delete)

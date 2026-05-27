# allocation — Code Map

## Module Reference
- **Flows:** [FLOWS.md](./FLOWS.md)
- **Domain:** [DOMAIN.md](./DOMAIN.md)
- **Integrations:** [INTEGRATIONS.md](./INTEGRATIONS.md)

> **Reference convention:** Symbol is stable; Line is a hint.

## Source Directories

| Purpose | Path | Notes |
|---|---|---|
| Controllers | apps/api/src/allocation/ | NestJS controllers |
| Services | apps/api/src/allocation/ | Business logic |
| Module | apps/api/src/allocation/allocation.module.ts | NestJS module wire-up |

## Flow-to-Code Mapping

### Flow: Create Allocation (FLOW-ALLOCATION-001)

| Step | Symbol | File | Line (hint) | Input | Output | Side Effects | Test Coverage |
|---|---|---|---|---|---|---|---|
| 1 | AllocationController.create | apps/api/src/allocation/allocation.controller.ts | 38 | CreateAllocationDto | Allocation | — | tests/api-test/allocation.api.test.ts |
| 2 | AllocationService.validate | apps/api/src/allocation/allocation.service.ts | 55 | CreateAllocationDto | void (throws on invalid) | Reads Employee+Project | UNTESTED |
| 3 | AllocationService.create | apps/api/src/allocation/allocation.service.ts | 78 | CreateAllocationDto | Allocation | DB write `allocations`, emit audit event | tests/api-test/allocation.api.test.ts |

### Flow: Update Allocation (FLOW-ALLOCATION-002)

| Step | Symbol | File | Line (hint) | Input | Output | Side Effects | Test Coverage |
|---|---|---|---|---|---|---|---|
| 1 | AllocationController.update | apps/api/src/allocation/allocation.controller.ts | 60 | UpdateAllocationDto | Allocation | — | UNTESTED |
| 2 | AllocationService.update | apps/api/src/allocation/allocation.service.ts | 102 | UpdateAllocationDto | Allocation | DB update + audit event | UNTESTED |

## Cross-Module Import Map

Exports consumed by other modules:
| Symbol | File (hint) | Imported By Module |
|---|---|---|
| AllocationService.getByEmployee | apps/api/src/allocation/allocation.service.ts | dashboard |
| AllocationService.getByProject | apps/api/src/allocation/allocation.service.ts | dashboard |

Imports from other modules:
| Imported Symbol | From Module | Used In Symbol |
|---|---|---|
| EmployeeService.findById | employee | AllocationService.validate |
| ProjectService.findById | project | AllocationService.validate |

# [Module Name] — Code Map

## Module Reference
- **Flows:** [FLOWS.md](./FLOWS.md)
- **Domain:** [DOMAIN.md](./DOMAIN.md)
- **Integrations:** [INTEGRATIONS.md](./INTEGRATIONS.md)

## Dependencies
- [module-name](../module-name/CODE-MAP.md) — imports functions/types from this module

## Depended By
- [module-name](../module-name/CODE-MAP.md) — modules that import from this module's code

---

## Source Directories

| Purpose | Path | File Count | Notes |
|---------|------|------------|-------|
| Routes/Controllers | src/modules/[module]/controllers/ | | Entry points |
| Services | src/modules/[module]/services/ | | Business logic |
| Models/Entities | src/modules/[module]/entities/ | | Data layer |
| DTOs/Schemas | src/modules/[module]/dto/ | | Input/output shapes |
| Middleware | src/modules/[module]/middleware/ | | Cross-cutting concerns |
| Utils/Helpers | src/modules/[module]/utils/ | | Module-specific utilities |
| Tests | src/modules/[module]/__tests__/ | | Test coverage |
| Migrations | src/migrations/[module]-*.ts | | DB schema changes |

---

## Flow-to-Code Mapping

> **Reference convention:** The `Symbol` column is the stable identifier. The `Line` column is a HINT only — it helps humans navigate but is not used for drift detection. brownfield-context-sync resolves references by symbol via the codebase scanner, not by line number. Refactors that move code don't break references as long as the symbol is preserved.

### Flow: [Flow Name] (FLOW-{MODULE}-{NNN})

| Step | Symbol | File | Line (hint) | Input | Output | Side Effects | Test Coverage |
|------|--------|------|-------------|-------|--------|-------------|---------------|
| 1 | OrderService.create | src/orders/order.service.ts | 145 | CreateOrderDto | Order | DB write: orders | TC-INT-005 |
| 2 | PaymentService.charge | src/payment/payment.service.ts | 89 | ChargeDto | PaymentResult | API call: Stripe | TC-INT-012 |

### Flow: [Second Flow] (FLOW-{MODULE}-{NNN})

| Step | Symbol | File | Line (hint) | Input | Output | Side Effects | Test Coverage |
|------|--------|------|-------------|-------|--------|-------------|---------------|
| ... | ... | ... | ... | ... | ... | ... | ... |

---

## Key Functions

| Function | File:Line | Purpose | Called By | Calls |
|----------|-----------|---------|-----------|-------|
| [name()] | src/[path]:NN | [business purpose] | [callers — include cross-module] | [callees] |

---

## Cross-Module Import Map

Functions in this module that are called by other modules:

| Symbol | File (hint) | Imported By Module | Import Symbol | Import File (hint) |
|--------|-------------|---------------------|---------------|---------------------|
| OrderService.create | src/orders/order.service.ts | payment | OrderClient.notify | src/payment/order-client.ts |

Functions this module imports from other modules:

| Imported Symbol | From Module | From File (hint) | Used In Symbol | Used In File (hint) |
|------------------|-------------|-------------------|-----------------|---------------------|
| EmailService.send | notification | src/notification/email.service.ts | OrderService.confirmOrder | src/orders/order.service.ts |

---

## Test Coverage Summary

| Area | Test Files | Covered Flows | Gaps |
|------|-----------|---------------|------|
| Unit | [list] | [which flows/steps] | [untested areas] |
| Integration | [list] | [which flows/steps] | [untested areas] |
| E2E | [list] | [which flows/steps] | [untested areas] |

---

**Template Version:** 5.0.0
**Created By:** brownfield-onboarding skill
**Last Verified:** YYYY-MM-DD

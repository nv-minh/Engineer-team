# allocation — External Integrations

## Module Reference
- **Flows:** [FLOWS.md](./FLOWS.md)
- **Domain:** [DOMAIN.md](./DOMAIN.md)
- **Code Map:** [CODE-MAP.md](./CODE-MAP.md)

## Dependencies
- [employee](../employee/INTEGRATIONS.md) — calls EmployeeService.getById for validation
- [project](../project/INTEGRATIONS.md) — calls ProjectService.getById for validation
- [audit](../audit/INTEGRATIONS.md) — emits audit events via internal event bus

## External Integrations
None directly — all external interactions go through other modules.

## Internal Module Dependencies

| Module | How Called | Data Exchanged | Failure Impact |
|---|---|---|---|
| [employee](../employee/FLOWS.md) | Direct function call to EmployeeService.findById | Employee entity (id, name, active flag) | Allocation create fails if employee not found |
| [project](../project/FLOWS.md) | Direct function call to ProjectService.findById | Project entity (id, positions) | Allocation create fails if project not found |
| [audit](../audit/FLOWS.md) | Event emission via AuditInterceptor | Action metadata (who/what/when) | Allocation succeeds but audit gap (violates INV-002) — currently logs error |

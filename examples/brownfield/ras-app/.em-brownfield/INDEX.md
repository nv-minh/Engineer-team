# Brownfield Context Index — ras-app

## Project
- **Name:** Resource Allocation System (ras-app)
- **Domain:** Workforce / Resource Management (see [DOMAIN-PROFILE.md](./DOMAIN-PROFILE.md))
- **Tech Stack:** TypeScript, NestJS, React + Vite, Prisma, PostgreSQL, Playwright
- **Monorepo:** Yes (pnpm) — apps/api, apps/web, packages/shared-types
- **Created:** 2026-05-26
- **Last Full Sync:** 2026-05-26

---

## Modules

| Module | Type | Impact | Flows | Entities | Integrations | Last Verified | Status |
|--------|------|--------|-------|----------|-------------|---------------|--------|
| [allocation](modules/allocation/FLOWS.md) | Core | P0 | 4 | 3 | 0 | 2026-05-26 | OK |
| [employee](modules/employee/FLOWS.md) | Core | P0 | 5 | 4 | 1 | 2026-05-26 | OK |
| [project](modules/project/FLOWS.md) | Core | P0 | 4 | 2 | 0 | 2026-05-26 | OK |
| [dashboard](modules/dashboard/FLOWS.md) | Supporting | P1 | 2 | 0 | 0 | 2026-05-26 | OK |
| [audit](modules/audit/FLOWS.md) | Supporting | P0 | 2 | 1 | 0 | 2026-05-26 | OK |
| [sync](modules/sync/FLOWS.md) | Supporting | P1 | 2 | 0 | 1 | 2026-05-26 | OK |
| [auth](modules/auth/FLOWS.md) | Generic | P0 | 3 | 1 | 1 | 2026-05-26 | OK |

## Dependency Graph

```
[allocation] -> [employee], [project], [audit]
[dashboard]  -> [allocation], [employee], [project]
[sync]       -> [employee], (external: HR system)
[auth]       -> (external: OAuth provider)
[audit]      -> (consumed by all)
```

## Cross-Cutting Concerns

| Concern | Used By Modules | Implementation |
|---------|----------------|----------------|
| Authentication | all | apps/api/src/auth/auth.guard.ts |
| Authorization | allocation, audit | apps/api/src/auth/roles.guard.ts |
| Audit logging | allocation, employee, project | apps/api/src/audit/audit.interceptor.ts |

---

## External Integration Registry

| Service | Type | Used By Modules | Critical? | Fallback? |
|---------|------|----------------|-----------|-----------|
| OAuth Provider | OIDC | auth | Yes | No |
| External HR System | REST API | sync, employee | No | Yes (queue) |

## Quick Stats
- **Total modules:** 7
- **Total flows:** 22
- **Total entities:** 11
- **Total external integrations:** 2
- **Circular dependencies:** 0
- **Untested flows:** 3

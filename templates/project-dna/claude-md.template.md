# CLAUDE.md Template for Generated Projects

> This template is used by the `project-dna` skill to generate a CLAUDE.md for target projects.
> Each section maps to a source document from prior greenfield stages.
> Target: 80-150 lines. Distill, don't dump.

---

```markdown
# [Project Name]

## Project Overview

[One paragraph: what we're building, for whom, and the core problem being solved.]
<!-- Source: Design document (Stage 2), SPEC.md objective (Stage 4) -->

## Tech Stack

- **Language:** [e.g., TypeScript 5.x]
- **Framework:** [e.g., Next.js 14 (App Router)]
- **Database:** [e.g., PostgreSQL 16 + Prisma 5]
- **Testing:** [e.g., Vitest + Playwright]
- **CI/CD:** [e.g., GitHub Actions]
<!-- Source: ARCHITECTURE.md (Stage 5), project-setup choices (Stage 6) -->

## Commands

```bash
npm run dev          # Start development server
npm run build        # Production build
npm test             # Run all tests
npm run test:unit    # Unit tests only
npm run test:e2e     # E2E tests only
npm run lint         # Lint check
npm run lint:fix     # Lint and auto-fix
npm run type-check   # TypeScript type checking
```
<!-- Source: SPEC.md commands (Stage 4), package.json (Stage 6) -->

## Project Structure

```
src/
  [bounded-context-1]/    # [Context description]
    domain/               # Entities, value objects, business rules
    application/          # Use cases, services
    infrastructure/       # Repositories, external adapters
  [bounded-context-2]/    # [Context description]
  shared/                 # Cross-context utilities
tests/
  unit/                   # Unit tests (mirror src/ structure)
  integration/            # Integration tests
  e2e/                    # End-to-end tests
```
<!-- Source: ARCHITECTURE.md bounded contexts (Stage 5), project scaffold (Stage 6) -->

## Code Conventions

- **Files:** [e.g., kebab-case for files, PascalCase for components]
- **Variables:** [e.g., camelCase]
- **Constants:** [e.g., UPPER_SNAKE_CASE]
- **Types/Interfaces:** [e.g., PascalCase, prefix interfaces with I only for external contracts]
- **Error handling:** [e.g., Use Result<T, E> pattern, never throw in domain layer]
- **Imports:** [e.g., Absolute paths from src/, group by: external → shared → local]
<!-- Source: SPEC.md code style (Stage 4), ARCHITECTURE.md patterns (Stage 5) -->

## Domain Language

Key terms used in this project (use these exact terms in code, comments, and commits):

| Term | Definition | Never Use |
|------|-----------|-----------|
| [Term] | [Definition] | [Synonym to avoid] |
<!-- Source: Domain model glossary (Stage 3) -->

## Design System

- **Component library:** [e.g., shadcn/ui + Tailwind CSS]
- **Typography:** [e.g., Inter for body, JetBrains Mono for code]
- **Colors:** [e.g., Primary #3B82F6, Secondary #6366F1, Error #EF4444, Success #22C55E]
- **Spacing base:** [e.g., 4px (Tailwind default)]
- **Breakpoints:** [e.g., sm: 640px, md: 768px, lg: 1024px, xl: 1280px]
- **Accessibility:** [e.g., WCAG 2.1 AA, min contrast 4.5:1, touch target 44x44px]
- **Performance:** [e.g., LCP < 2.5s, INP < 200ms, CLS < 0.1]
<!-- Source: UI-SPEC.md (Stage 5). Omit section if no UI-SPEC.md exists. -->

## Boundaries

### Always Do
- [Project-specific rule]

### Ask First
- [Project-specific rule]

### Never Do
- [Project-specific rule]
<!-- Source: SPEC.md boundaries (Stage 4), ARCHITECTURE.md constraints (Stage 5) -->

## Architecture

- **Pattern:** [e.g., Hexagonal (Ports & Adapters)]
- **Data flow:** [e.g., Request → Controller → Use Case → Domain → Repository → Database]
- **Dependency rule:** [e.g., Domain layer has zero external dependencies. Infrastructure depends on domain, never reverse.]
<!-- Source: ARCHITECTURE.md (Stage 5) -->

## Testing Strategy

- **Unit tests:** [location, what to test, coverage target]
- **Integration tests:** [location, what to test]
- **E2E tests:** [location, critical paths]
- **Coverage threshold:** [e.g., 80% minimum, 95% for domain layer]
<!-- Source: SPEC.md testing section (Stage 4) -->

## Spec Reference

Full documentation in `spec/` folder:
- Requirements: `spec/requirements/REQUIREMENTS.md`
- UI Specification: `spec/ui/UI-SPEC.md`
- Architecture: `spec/architecture/ARCHITECTURE.md`
- Domain Model: `spec/domain/domain-model.md`
- Roadmap: `spec/architecture/ROADMAP.md`
- Traceability: `spec/PROJECT-DNA.md`
```

---
name: codebase-architecture
description: "Researches modern codebase architecture patterns, presents 2-3 best-fit options with trade-off analysis for the user to decide, then generates comprehensive architecture-specific rules (structure, imports, naming, anti-patterns) that enforce the chosen architecture throughout development."
version: "1.0.0"
category: "development"
origin: "EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "choose architecture"
  - "codebase architecture"
  - "architecture pattern"
  - "how to structure codebase"
  - "architecture design"
  - "project structure"
  - "architecture rules"
  - "modern architecture"
  - "scalable architecture"
intent: "Research and recommend modern codebase architectures tailored to the project's domain complexity, team size, and tech stack — then generate comprehensive, enforceable rules that keep the codebase clean and consistent throughout its lifetime."
scenarios:
  - "Greenfield app Stage 6: architecture decision before implementation begins"
  - "Existing project needing clearer structure as it scales"
  - "Team wants to establish architecture standards before onboarding new developers"
  - "Migrating from a messy codebase to a clean architecture"
best_for: "New projects, architecture decision, codebase structure, scalability planning"
estimated_time: "1-2 hours (including research + decision + rule generation)"
anti_patterns:
  - "Choosing architecture based on hype, not project fit — Clean Arch is not always better than Layered"
  - "Generating rules without tailoring them to the chosen pattern — generic rules are useless"
  - "Over-engineering: adding CQRS + Event Sourcing to a simple CRUD app"
  - "Under-engineering: Layered Architecture for a complex domain with rich business rules"
  - "Skipping the user decision step — architecture is a human choice, not an AI choice"
related_skills:
  - domain-modeling
  - spec-driven-development
  - writing-plans
  - project-dna
  - architecture-improvement
---

# Codebase Architecture

## Overview

Architecture decisions are the most durable and expensive decisions in a software project. A bad architecture that's baked in at day 1 shapes every feature, every refactor, and every debugging session for years. This skill:

1. **Analyzes** the project context (domain complexity, team, scale, tech stack)
2. **Researches** modern architecture patterns suitable for that context
3. **Presents** 2-3 best-fit options with concrete trade-offs, not generic descriptions
4. **Lets the user decide** — architecture is a human judgment call, not an AI call
5. **Generates** comprehensive, pattern-specific rules that enforce the chosen architecture in every future coding session

The output is not a diagram. It's a set of actionable rules that Claude (and any developer) will follow for the lifetime of the project.

## When to Use

- Greenfield app Stage 6 (Architecture): after domain model and spec are complete
- Existing project that has grown organically and needs clearer structure
- Before onboarding a new team — establish architecture standards first
- Tech debt reset: deciding on a target architecture to migrate toward

**When NOT to Use:** Architecture is already decided and well-documented. Simple scripts or throwaway prototypes.

## Anti-Patterns

- Choosing the most sophisticated architecture (CQRS + Event Sourcing + Hexagonal) for a simple CRUD API — over-engineering
- Choosing the simplest architecture (Layered) for a complex domain with rich business rules — under-engineering
- Generating rules before understanding the project's actual needs
- Skipping the user decision — the architect recommends, the user decides

---

## Process

### Phase 1: Context Analysis

Before researching architectures, understand the project's actual needs. Ask yourself (and the user if unclear):

**Context checklist — read and extract from existing artifacts:**
```
From domain model (Stage 3):
  □ How many bounded contexts? (1-2 = simple, 3-5 = moderate, 6+ = complex)
  □ Do contexts communicate frequently? (yes = coupling risk, needs clear boundaries)
  □ Rich domain logic? (complex rules, state machines, domain events = needs protection)
  □ Simple CRUD or complex workflows?

From requirements (Stage 4):
  □ Scale: concurrent users, data volume, transaction throughput
  □ Team size: 1-3 = simple, 4-10 = moderate, 10+ = need strict boundaries
  □ Long-lived project? (yes = invest in maintainability)
  □ Audit/compliance requirements? (event sourcing may be needed)
  □ Multiple client types? (web + mobile = consider BFF)

From tech stack (Stage 6/7):
  □ Backend framework (NestJS, FastAPI, Spring, etc.)
  □ Frontend framework (React, Vue, Next.js, etc.)
  □ Database type (relational, document, event store)
  □ Monolith or services?
```

**Surface assumptions:**
```
CONTEXT ASSESSMENT:
- Project type: [Backend API / Frontend SPA / Full-stack / Mobile]
- Domain complexity: [Simple CRUD / Moderate / Rich domain]
- Bounded contexts: [N contexts identified]
- Team size: [N developers]
- Scale target: [small / medium / large]
- Longevity: [prototype / long-lived product]
❓ Correct any wrong assumptions before I proceed.
```

---

### Phase 2: Architecture Research

Based on context, select and research the most relevant architecture patterns. Present them with concrete file structure examples — not just theory.

---

## Architecture Pattern Catalog

Reference this catalog to select and present options.

---

### Pattern A: Layered Architecture (N-Tier)

**Best for:** Simple to moderate CRUD applications, small teams, quick iterations

**Structure:**
```
src/
  controllers/     # HTTP layer — routes, request/response DTOs
  services/        # Business logic — orchestrates operations
  repositories/    # Data access — database queries
  models/          # Data models/entities
  middlewares/     # Cross-cutting concerns (auth, logging)
```

**Dependency rule:**
```
Controller → Service → Repository → Database
(each layer only depends on the layer below)
```

**Pros:**
- Simple, universally understood
- Easy to onboard new developers
- Works great for CRUD-heavy applications
- Testable with standard mocking

**Cons:**
- Business logic tends to leak into services → fat service layer
- Hard to scale to complex domains without discipline
- Cross-cutting concerns (auth, logging) create coupling
- No protection for business rules from framework/DB changes

**When to choose:**
- Team < 3 developers
- Domain is primarily CRUD (no complex rules)
- Tight deadline, need simplicity
- Prototype that may be replaced

**Red flags:** Rich domain logic, frequent rule changes, large team, multiple client types

---

### Pattern B: Clean Architecture / Hexagonal (Ports & Adapters)

**Best for:** Complex domains, long-lived products, teams that need testability

**Structure:**
```
src/
  [bounded-context]/
    domain/
      entities/        # Core business objects (no framework dependencies)
      value-objects/   # Immutable value types
      services/        # Domain services (pure business logic)
      repositories/    # Repository interfaces (ports) — NOT implementations
      events/          # Domain events
    application/
      use-cases/       # Application use cases (orchestrates domain)
      dtos/            # Input/output DTOs
      ports/           # Inbound ports (what the app offers)
    infrastructure/
      persistence/     # Repository implementations (adapters)
      http/            # HTTP adapters (controllers)
      messaging/       # Event bus adapters
  shared/
    kernel/            # Minimal shared concepts (e.g., UserId, Money)
```

**Dependency rule:**
```
Infrastructure → Application → Domain
Infrastructure → Domain
(Domain has zero external dependencies)
```

**Ports & Adapters:**
```
Inbound:  [HTTP Request] → [Controller (Adapter)] → [Use Case Port] → [Use Case]
Outbound: [Use Case] → [Repository Port] → [Repository Impl (Adapter)] → [Database]
```

**Pros:**
- Business logic is completely isolated — testable without framework/DB
- Easy to swap infrastructure (change DB, framework, messaging)
- Enforces clear boundaries between domain and infrastructure
- Domain model can evolve independently

**Cons:**
- More files and abstraction layers
- Learning curve for developers new to the pattern
- Can feel over-engineered for simple domains

**When to choose:**
- Rich domain logic with complex business rules
- Long-lived product (3+ years)
- Need high test coverage for business rules
- Potential infrastructure changes (e.g., switching from REST to gRPC)
- Team with DDD experience or willing to learn

---

### Pattern C: Modular Monolith

**Best for:** Teams that want monolith simplicity with future microservices optionality

**Structure:**
```
src/
  modules/
    [module-a]/         # Self-contained module
      api/              # Public API (what other modules can call)
      internal/         # Private implementation
        domain/
        application/
        infrastructure/
    [module-b]/
      api/
      internal/
  shared/
    common/             # Truly shared utilities
    events/             # Inter-module events
  app/                  # Application bootstrap, DI wiring
```

**Module communication rules:**
```
Module A → [Module B public API only] — NEVER internal
Module A → [Events] → Module B — for decoupled communication
Module A → [Shared/common] — for cross-cutting utilities
```

**Pros:**
- Monolith simplicity (single deployment, single DB)
- Strong module boundaries prevent spaghetti
- Modules can be extracted to microservices later with minimal refactoring
- Each module can choose its own internal pattern

**Cons:**
- Requires discipline to enforce module boundaries (no "quick shortcuts")
- Shared database can become a coupling point
- Harder to scale individual modules independently than microservices

**When to choose:**
- Medium complexity domain with 3-8 bounded contexts
- Team 4-10 developers
- May want to extract services later (modular monolith → microservices)
- Don't have the operational complexity budget for microservices yet

---

### Pattern D: Feature-Sliced Design (FSD) — Frontend

**Best for:** Large React/Vue frontends with many features

**Structure:**
```
src/
  app/           # App initialization, providers, routing
  pages/         # Route-level composition (composes widgets)
  widgets/       # Self-contained UI blocks (sidebar, header, feed)
  features/      # User-facing functionality (auth, product-search)
    [feature]/
      api/       # API calls for this feature
      model/     # State management (store slices)
      ui/        # Components specific to this feature
      lib/       # Utilities
  entities/      # Business entities (user, product, order)
    [entity]/
      api/
      model/
      ui/
  shared/        # Reusable utilities, UI kit, API clients
    api/
    ui/          # Design system components
    lib/
    config/
```

**Dependency rule (strictly hierarchical):**
```
app → pages → widgets → features → entities → shared
(higher layers may import from lower layers, NEVER reverse)
```

**Pros:**
- Clear feature isolation — no cross-feature coupling
- Consistent structure across the entire frontend
- Easy to find anything (always know which layer it belongs to)
- Scales well to 100+ features without structural decay

**Cons:**
- Learning curve — strict layer rules feel rigid initially
- Over-engineering for small frontends (<10 features)
- Requires team discipline to follow layer rules

**When to choose:**
- Frontend-heavy project (React/Vue/Next.js)
- 10+ features planned
- Multiple developers working on frontend simultaneously
- Long-lived frontend product

---

### Pattern E: Vertical Slice Architecture

**Best for:** Full-stack apps with many discrete features, good for CQRS

**Structure:**
```
src/
  features/
    [feature-name]/
      [Feature]Command.ts        # Write-side (mutation)
      [Feature]CommandHandler.ts
      [Feature]Query.ts          # Read-side (query)
      [Feature]QueryHandler.ts
      [Feature]Controller.ts     # HTTP endpoint
      [Feature].test.ts          # Tests alongside feature
  shared/
    domain/                      # Shared domain types
    infrastructure/              # Shared DB, messaging setup
```

**Dependency rule:**
```
Features are independent — feature A does NOT import feature B
Features share only via shared/domain and shared/infrastructure
Cross-feature communication is via events in shared/infrastructure
```

**Pros:**
- All code for a feature is in one place (cohesion by feature, not by layer)
- Adding a feature = adding one folder, not touching 4 layers
- Natural fit for CQRS (commands and queries are separate files)
- Easy to extract features to microservices
- Tests live next to the code they test

**Cons:**
- Code duplication risk (each feature may solve same infrastructure problem)
- Less conventional — developers may be unfamiliar
- Harder to apply DDD tactical patterns
- Shared infrastructure can become a dumping ground

**When to choose:**
- CRUD-heavy but with many discrete features
- CQRS is desired
- Full-stack Next.js or similar (co-locate API and UI per feature)
- Team values pragmatism over purity

---

### Pattern F: CQRS + Event Sourcing

**Best for:** Complex audit requirements, temporal queries, event-driven systems

**Structure:**
```
src/
  commands/
    [command-name]/
      [Command].ts              # Command definition
      [CommandHandler].ts       # Handles command, emits events
  queries/
    [query-name]/
      [Query].ts               # Query definition
      [QueryHandler].ts        # Reads from read model
  events/
    [EventName].ts             # Domain event definitions
    handlers/                  # Event handlers (update read models)
  read-models/
    [ReadModel].ts             # Denormalized read models
  infrastructure/
    event-store/               # Append-only event store
    projections/               # Build read models from events
```

**Pros:**
- Complete audit trail (events are the source of truth)
- Temporal queries ("what was the state at time T?")
- Independent scaling of read and write sides
- Natural fit for event-driven systems

**Cons:**
- High complexity — not justified for simple CRUD
- Eventual consistency requires careful handling
- Steep learning curve
- Higher infrastructure requirements

**When to choose:**
- Strict audit/compliance requirements
- Complex business process workflows
- Need to replay history or temporal queries
- Team experienced with event sourcing

---

### Phase 3: Present Options to User

Present exactly **2-3 architectures** (not all of them). Choose the most relevant based on context analysis.

**Presentation format:**

```
## Architecture Options for [Project Name]

Based on analysis:
- Domain complexity: [Simple/Moderate/Rich]
- Bounded contexts: [N]
- Tech stack: [stack]
- Team: [N developers]
- Scale: [small/medium/large]

---

### Option 1: [Pattern Name]

**Recommendation level:** ⭐⭐⭐ Best fit / ⭐⭐ Good fit / ⭐ Consider only if

**File structure for YOUR project:**
[Show ACTUAL structure with this project's bounded context names, not generic placeholders]

**Dependency rule:**
[One clear sentence about what can import what]

**Why this fits your project:**
- [Specific reason 1, tied to this project's domain or requirements]
- [Specific reason 2]

**Trade-offs to accept:**
- [Specific limitation that WILL apply to this project]
- [Second trade-off]

**Code example (your domain):**
[2-3 code snippets showing how a key domain concept would be implemented in this pattern]

---

### Option 2: [Pattern Name]
[Same format]

---

### Option 3: [Pattern Name]
[Same format]

---

## Recommendation

I recommend **Option [N]: [Pattern Name]** because [specific reasoning for this project].

**But you decide.** Architecture is a long-term commitment that reflects your team's strengths, the domain's complexity, and the product's trajectory. I can research deeper on any option before you decide.

❓ Which architecture do you want to proceed with?
```

---

### Phase 4: Generate Architecture Rules

After the user chooses, generate **three rule files** in `.claude/rules/`:

---

#### Rule File 1: `architecture-boundaries.md`

Enforces layer/module dependencies and cross-context communication.

Template is pattern-specific — see examples below.

**For Clean Architecture:**
```markdown
# Architecture Boundaries — Clean Architecture (Hexagonal)

## Pattern
Hexagonal (Ports & Adapters) — Domain-centric, infrastructure-agnostic.

## Dependency Rule
Infrastructure → Application → Domain
NEVER: Domain → Application, Domain → Infrastructure, Application → Infrastructure

## Layer Responsibilities
**Domain layer** (`src/[context]/domain/`):
- Contains: entities, value objects, domain services, repository interfaces, domain events
- ZERO external dependencies — no framework, no database driver, no HTTP library
- Only standard library types allowed

**Application layer** (`src/[context]/application/`):
- Contains: use cases, DTOs, inbound ports
- Imports FROM: domain layer only
- NEVER imports: infrastructure implementations

**Infrastructure layer** (`src/[context]/infrastructure/`):
- Contains: repository implementations, HTTP controllers, event bus adapters
- Imports FROM: both domain (to implement interfaces) and application (to wire use cases)

## Bounded Context Rules
- No direct imports between contexts: `src/[context-a]/` NEVER imports `src/[context-b]/`
- Cross-context: only via events in `src/shared/events/` or explicit API contracts
- Shared kernel: only in `src/shared/kernel/` — must be minimal (IDs, Money, primitives)

## Import Enforcement
Good:  `import { UserRepository } from '../domain/repositories/UserRepository'`  (interface)
Bad:   `import { PrismaUserRepository } from '../infrastructure/UserRepository'`  (implementation)
Bad:   `import { UserService } from '../application/UserService'` (inside domain)
```

**For Feature-Sliced Design (Frontend):**
```markdown
# Architecture Boundaries — Feature-Sliced Design

## Layer Hierarchy (strict, no exceptions)
app → pages → widgets → features → entities → shared

## Import Rules
- Higher layers MAY import from lower layers
- Lower layers MUST NEVER import from higher layers
- Layers MUST NOT import from the same layer (no feature → feature)

## Concrete rules:
- `features/` NEVER imports from `widgets/` or `pages/`
- `entities/` NEVER imports from `features/`
- `shared/` NEVER imports from any other layer
- Each feature is self-contained: all its code in `src/features/[feature]/`
```

---

#### Rule File 2: `architecture-conventions.md`

Naming and file structure conventions specific to the chosen pattern.

```markdown
# Architecture Conventions — [Pattern Name]

## File Naming
[Pattern-specific naming rules]
Examples:
  Clean Arch: `UserRepository.ts` (port interface), `PrismaUserRepository.ts` (adapter)
  FSD: `user-list.tsx` (UI), `user.model.ts` (store), `user.api.ts` (API)
  Vertical Slice: `CreateOrderCommand.ts`, `CreateOrderCommandHandler.ts`

## Folder Naming
[kebab-case or camelCase, pattern-specific examples]

## Class/Interface Naming
[Pattern-specific conventions]
Examples:
  Clean Arch: Repository interfaces end in `Repository`, implementations in `[Db]Repository`
  CQRS: Commands end in `Command`, handlers in `CommandHandler`
  Use cases end in `UseCase`: `CreateOrderUseCase`

## What Goes Where
| Concern | Layer/Folder | Example |
|---------|-------------|---------|
| [Concern 1] | [Location] | [Filename example] |
| [Concern 2] | [Location] | [Filename example] |

## Anti-Patterns
- [Specific wrong pattern for this architecture]
- [Another wrong pattern]
```

---

#### Rule File 3: `architecture-patterns.md`

Code patterns to follow AND avoid, with examples for the chosen architecture.

```markdown
# Architecture Patterns — [Pattern Name]

## Patterns to Follow

### [Pattern name 1]
[When to use it, code example]

### [Pattern name 2]
[When to use it, code example]

## Anti-Patterns (Never Do)

### [Anti-pattern 1]
```typescript
// ❌ WRONG
[Wrong code example specific to this architecture]

// ✅ RIGHT
[Correct code example]
```

### [Anti-pattern 2]
[Same format]

## Decision Checklist
Before adding new code, ask:
- [ ] Is this code in the right layer for this architecture?
- [ ] Does it respect the dependency rule?
- [ ] Does it follow the naming convention for this pattern?
- [ ] Is it testable without the framework/DB (for domain/application code)?
```

---

### Quality Gate

Before completing architecture design:

```
ARCHITECTURE DECISION CHECKLIST:
□ Context analysis completed (domain complexity, team, scale assessed)
□ 2-3 architecture options presented (not all options, not 1 option)
□ Each option has: file structure for THIS project, specific pros/cons, code example
□ User has chosen an architecture (written decision)
□ Three rule files generated:
  □ .claude/rules/architecture-boundaries.md
  □ .claude/rules/architecture-conventions.md
  □ .claude/rules/architecture-patterns.md
□ ARCHITECTURE.md written with chosen pattern documented
□ Rule files reference the project's actual bounded context names (no placeholders)
```

## Coaching Notes

> **ABC - Always Be Coaching:**

1. **Architecture is a bet on the future.** A team choosing between Layered and Clean Architecture is betting on how complex their domain will become. Teach users to think about the architecture in terms of: what happens when we add feature 50? When the team grows to 10 developers? When we need to switch databases?

2. **The best architecture is the one the team will actually maintain.** A theoretically perfect Hexagonal Architecture that developers circumvent because it feels too complex is worse than a "simpler" Layered Architecture that's consistently followed. Architecture is a social contract, not a diagram.

3. **Architecture rules prevent architecture debt.** The rules generated by this skill are not style guides — they are enforced structural invariants. A violation of the dependency rule is a bug, not a style preference. Frame it that way.

4. **Start conservative, evolve deliberately.** A Layered Architecture can evolve toward Clean Architecture. A Modular Monolith can extract microservices. Evolution is easier than revolution. Recommend starting simpler if the team is uncertain.

## Verification

After completing this skill:

- [ ] ARCHITECTURE.md is written with pattern name, rationale, file structure, dependency rules, key decisions
- [ ] Three rule files exist in `.claude/rules/`: architecture-boundaries.md, architecture-conventions.md, architecture-patterns.md
- [ ] Rule files use this project's actual bounded context names — no placeholders
- [ ] Each rule file has at least one concrete code example (correct AND incorrect)
- [ ] User has explicitly chosen the architecture (not just acknowledged)
- [ ] ROADMAP.md phases are consistent with chosen architecture's module structure

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

After completing this skill, export to:
`architecture/YYYY-MM-DD-HHMM-architecture-decision-<project>.md`

Include: chosen pattern, rationale, file structure, rule summaries.

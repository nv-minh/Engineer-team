---
name: greenfield-app
description: Complete workflow from blank directory to shipped application. Covers ideation, problem reframing, domain modeling, requirements, UI/UX design, architecture, bootstrapping, Project DNA crystallization, implementation, and launch.
version: "3.0.0"
category: "primary"
origin: "EM-Team"
agents_used:
  - product-manager
  - architect
  - planner
  - frontend-expert
  - executor
  - verifier
  - test-engineer
  - market-intelligence
  - ui-auditor
  - design-reviewer
skills_used:
  - brainstorming
  - domain-modeling
  - spec-driven-development
  - alignment-session
  - writing-plans
  - frontend-patterns
  - project-dna
  - test-driven-development
  - subagent-driven-development
  - code-review
  - git-workflow
  - ux-audit
related_skills:
  - domain-modeling
  - spec-driven-development
  - project-setup
  - project-dna
  - figma-design
  - flow-discovery
estimated_time: "1-2 weeks (MVP) / 4-8 weeks (full product)"
---

# Greenfield App Workflow

## Overview

Build an application from scratch — from blank directory to shipped product. This workflow covers the full lifecycle that existing workflows skip: ideation validation, problem reframing, domain modeling, and strategic architecture before any code is written.

## When to Use

- Building a new product from scratch
- Starting a greenfield project with no existing codebase
- Creating a new application or service
- Proof of concept that may become production

**When NOT to use:**
- Adding features to existing codebase → use `new-feature`
- Technical bootstrapping only → use `project-setup`
- Market-driven feature in existing product → use `market-driven-feature`

## Decision Framework

| Starting Point | Workflow |
|---|---|
| Blank directory + idea | **greenfield-app** (this one) |
| Existing codebase + feature | new-feature |
| Existing codebase + market opportunity | market-driven-feature |
| Technical bootstrapping only | project-setup |

## Lifecycle

```
DEFINE ──────────────────→ PLAN ──────────────→ BUILD ──────────────────→ VERIFY → REVIEW → SHIP
  Stage 1: Ideation        Stage 4: Spec        Stage 7: Setup          Stage 10  Stage 11  Stage 12
  Stage 2: Reframing       Stage 5: UI/UX       Stage 8: Crystallize
  Stage 3: Domain Model    Stage 6: Arch        Stage 9: Build
     │                        │                    │                │        │        │
     ▼                        ▼                    ▼                ▼        ▼        ▼
  GATE 1                   GATE 2              GATE 3            GATE 4   GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Description |
|---|---|---|
| IDEATION (Stage 1) | DEFINE | Validate idea, answer "should we build this?" |
| REFRAMING (Stage 2) | DEFINE | Reframe problem, explore design approaches |
| DOMAIN MODEL (Stage 3) | DEFINE | Extract bounded contexts, entities, relationships |
| SPEC (Stage 4) | PLAN | Write specification with requirements |
| UI/UX DESIGN (Stage 5) | PLAN | Design user flows, components, design system, accessibility |
| ARCHITECTURE (Stage 6) | PLAN | Design system, create phased roadmap |
| BOOTSTRAP (Stage 7) | BUILD | Technical setup — delegates to project-setup |
| CRYSTALLIZE (Stage 8) | BUILD | Generate agent guidance — CLAUDE.md, rules, traceability |
| IMPLEMENT (Stage 9) | BUILD | Execute roadmap phases with TDD |
| VALIDATE (Stage 10) | VERIFY | Full verification against spec, domain model, and UX |
| REVIEW (Stage 11) | REVIEW | Multi-agent code, architecture, security, and UI review |
| LAUNCH (Stage 12) | SHIP | PR, deploy, monitor — delegates to ship-workflow |

## Workflow Stages

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                          │
│  IDEATION → REFRAME → DOMAIN → SPEC → UI/UX → ARCH → BOOTSTRAP → CRYSTALLIZE → BUILD → VAL → REV → LAUNCH │
│     1          2        3       4       5       6        7            8           9      10    11    12  │
│                                                                                                          │
│  ─── DEFINE ──→ ────── PLAN ──────→ ──────────── BUILD ───────────────→ VERIFY → REVIEW → SHIP          │
│                                                                                                          │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Stage 1: Ideation and Validation

**Agent:** product-manager
**Skill:** office-hours

**Process:**
1. Present the six forcing questions:
   - **Demand reality**: What evidence exists that people want this?
   - **Status quo bias**: Why aren't existing solutions good enough?
   - **Narrowest wedge**: What's the smallest version that proves value?
   - **Observation**: How will you know if this is working?
   - **Future-fit**: Does this get harder or easier as the market evolves?
   - **Personal fit**: Why are you the right person/team to build this?
2. Challenge assumptions — listen for pain points, not feature requests
3. Generate 2-3 alternative framings of the problem
4. Make a falsifiable claim about the product hypothesis

**Output:**
- Validated idea brief with hypothesis
- Go/No-Go decision documented
- Alternative framings considered

**Quality Gate:**
- [ ] Idea hypothesis stated as a falsifiable claim
- [ ] At least one alternative framing explored
- [ ] Go/No-Go decision made
- [ ] If No-Go: workflow ends, pivot considered

---

## Stage 2: Problem Reframing and Design

**Agent:** product-manager + architect
**Skill:** brainstorming

**Process:**
1. Reframe the problem using the Problem Framing Canvas:
   - **Look Inward**: What assumptions are we making?
   - **Look Outward**: Who experiences this problem? How often?
   - **Reframe**: Create actionable problem statement
2. Brainstorm 2-3 solution approaches with trade-offs
3. Present design section by section, get user approval
4. Write design document

**Output:**
- Design document at `docs/specs/YYYY-MM-DD-<topic>-design.md`
- Problem reframing notes
- Selected approach with rationale

**Quality Gate:**
- [ ] Problem reframed with actionable statement
- [ ] 2-3 approaches explored with trade-offs
- [ ] User approved selected approach
- [ ] Design document written and committed

---

## Stage 3: Domain Modeling

**Agent:** architect + planner
**Skill:** domain-modeling

**Process:**
1. Extract key concepts from brainstorming output
2. Identify bounded contexts (Core / Supporting / Generic)
3. Define entities, relationships, lifecycle states
4. Build ubiquitous language glossary
5. Generate diagrams (ER, context map, state machines)
6. Present for user review

**Output:**
- Domain model at `docs/domain-model.md`
- Bounded context map
- Entity-relationship diagrams
- Ubiquitous language glossary

**Quality Gate:**
- [ ] All brainstorming concepts mapped to entities or excluded
- [ ] Bounded contexts identified with clear responsibilities
- [ ] Entities have types (Aggregate Root / Entity / Value Object)
- [ ] Relationships documented with cardinality
- [ ] Ubiquitous language glossary complete (no synonyms)
- [ ] User approved the domain model

---

## Stage 4: Requirements and Specification

**Agent:** planner
**Skill:** spec-driven-development

**Process:**
1. Read design document and domain model
2. Map every domain entity to requirement areas
3. Write structured specification:
   - Functional requirements (linked to domain entities)
   - Non-functional requirements
   - Success criteria (testable)
   - Boundaries (in-scope / out-of-scope)
4. Group features by category, scope as v1 / v2 / out-of-scope
5. Generate REQUIREMENTS.md with REQ-IDs

**Output:**
- SPEC.md document
- REQUIREMENTS.md with traceable REQ-IDs
- Success criteria defined

**Quality Gate:**
- [ ] Every domain entity maps to at least one requirement
- [ ] Requirements traceable (REQ-IDs)
- [ ] v1 scope defined with clear boundaries
- [ ] Success criteria testable
- [ ] User approved spec

---

## Stage 5: UI/UX Design

**Agent:** frontend-expert
**Skill:** frontend-patterns
**Optional Skill:** figma-design (if Figma URL provided)

**Process:**
1. Read SPEC.md and REQUIREMENTS.md from Stage 4
2. Read domain model from Stage 3 for entity awareness
3. If Figma URL is available, use `figma-design` skill to extract design tokens, component hierarchy, and layout specs
4. If no Figma, derive UI decisions from spec requirements and domain model
5. Define user flows — screen-by-screen with actions, transitions, and error paths
6. Define component specifications — component tree with props, states, and variants
7. Establish design system decisions — typography scale, color palette, spacing system, component library choice
8. Define accessibility requirements — WCAG compliance level, keyboard navigation, screen reader considerations
9. Define responsive strategy — breakpoints, mobile-first patterns, touch targets
10. Set performance targets — Core Web Vitals goals (LCP, INP, CLS)
11. Document interaction patterns — loading states, error states, empty states, success feedback, transitions
12. Present UI-SPEC.md for user review

**Output:**
- `docs/UI-SPEC.md` — Full UI/UX specification
- Design token definitions (colors, typography, spacing) — embedded in UI-SPEC.md or extracted from Figma
- User flow diagrams (Mermaid or text-based)

**UI-SPEC.md Structure:**

```markdown
# UI Specification: [Project Name]

## 1. User Flows
### Flow: [Flow Name]
- **Entry:** [Starting screen/state]
- **Steps:** [Screen-by-screen with actions and transitions]
- **Success:** [End state]
- **Error paths:** [What happens when things go wrong]

## 2. Component Specifications
### Component Tree
[Hierarchical view: page → section → component]

### Component Details
#### [ComponentName]
- **Props:** [typed props with defaults]
- **States:** [loading, error, empty, populated, disabled]
- **Variants:** [size, color, style variations]
- **Accessibility:** [ARIA role, keyboard behavior]

## 3. Design System
### Typography
[Font family, scale (h1-h6, body, caption), weights, line heights]

### Colors
[Primary, secondary, accent, semantic (success, warning, error, info), neutrals]

### Spacing
[Spacing scale (4px or 8px base), component spacing rules]

### Component Library
[Choice and rationale: Tailwind + Headless UI, shadcn/ui, Material UI, custom, etc.]

## 4. Accessibility Requirements
- **WCAG Level:** [AA or AAA]
- **Keyboard navigation:** [Tab order, focus management, skip links]
- **Screen reader:** [ARIA landmarks, live regions, announcements]
- **Color contrast:** [Minimum ratios for text and UI elements]
- **Motion:** [prefers-reduced-motion support]
- **Form accessibility:** [Label association, error announcements]

## 5. Responsive Strategy
### Breakpoints
[Mobile: <768px, Tablet: 768-1023px, Desktop: 1024px+]

### Mobile-First Patterns
[Navigation collapse, stacking, touch target sizes (min 44x44px)]

### Layout Strategy
[Grid system, container widths, fluid vs fixed]

## 6. Performance Targets
- **LCP:** < 2.5s
- **INP:** < 200ms
- **CLS:** < 0.1
- **Bundle budget:** [target size]
- **Image strategy:** [lazy loading, modern formats, responsive images]

## 7. Interaction Patterns
### Loading States
[Skeleton screens, spinners, progressive loading]

### Error States
[Inline validation, toast notifications, error pages, retry patterns]

### Empty States
[First-time user experience, no-data states with CTAs]

### Success Feedback
[Confirmation messages, optimistic updates, transitions]
```

**Quality Gate:**
- [ ] User flows cover all v1 requirements from SPEC.md
- [ ] Every user flow includes error paths (not just happy path)
- [ ] Component tree maps to domain entities where applicable
- [ ] Design system decisions documented (typography, colors, spacing)
- [ ] WCAG compliance level chosen and specific considerations listed
- [ ] Responsive breakpoints defined with mobile-first approach
- [ ] Performance targets set with specific Core Web Vitals goals
- [ ] Interaction patterns cover loading, error, empty, and success states
- [ ] User approved UI-SPEC.md

---

## Stage 6: Architecture Design and Codebase Structure

**Agent:** architect + planner
**Skills:** `codebase-architecture`, `writing-plans`

**Process:**

### 6a: Architecture Research & Decision (NEW)

Run `codebase-architecture` skill:

1. **Context Analysis** — Read domain model, requirements, and UI-SPEC to assess:
   - Domain complexity (CRUD vs. rich domain logic)
   - Number of bounded contexts and their relationships
   - Team size and experience level
   - Scale target and longevity expectations
   - Tech stack constraints from earlier stages

2. **Research Modern Architectures** — Identify 2-3 patterns best suited for this context from:
   - Layered (N-Tier) — Simple CRUD, small teams
   - Clean Architecture / Hexagonal (Ports & Adapters) — Rich domain, long-lived
   - Modular Monolith — Medium complexity, future microservices optionality
   - Feature-Sliced Design (FSD) — Large React/Vue frontends
   - Vertical Slice Architecture — CQRS-oriented, many discrete features
   - CQRS + Event Sourcing — Complex audit, event-driven systems

3. **Present Options** — For each candidate architecture, show:
   - File structure using THIS project's bounded context names (no generic placeholders)
   - Dependency rule (what imports what)
   - Why it fits this project (specific, not generic)
   - Trade-offs to accept (specific to this project)
   - Code example with this project's domain concepts

4. **User Decides** — Architecture choice is a human judgment call. Present a recommendation but explicitly ask the user to choose.

### 6b: Architecture Document

After the user decides, produce:

```markdown
# Architecture: [Project Name]

## Pattern: [Chosen Pattern Name]
**Rationale:** [Why this was chosen for this specific project]

## Bounded Contexts → Modules

| Bounded Context | Module Path | Type | Description |
|---|---|---|---|
| [Context] | src/[module]/ | Core/Supporting/Generic | [Description] |

## File Structure
[Actual structure for this project — not generic]

## Dependency Rule
[One clear sentence: what imports what, what never imports what]

## Data Flow
[Request → ... → Response, for the primary use case]

## Failure Modes
| Component | Failure | Recovery |
|---|---|---|
| [Component] | [What can fail] | [How to recover] |

## Technology Decisions
| Decision | Choice | Rationale |
|---|---|---|
| [e.g., ORM] | [e.g., Prisma] | [Why] |
```

### 6c: Generate Architecture Rules

After architecture decision, generate THREE rule files in `.claude/rules/`:

1. **`architecture-boundaries.md`** — Layer/module dependency rules
   - Exactly which folders can import from which
   - Cross-context communication rules
   - Shared kernel minimalism rules
   - Code examples: correct AND incorrect imports

2. **`architecture-conventions.md`** — Naming and file structure conventions
   - File naming per concern (entities, use cases, controllers, DTOs, etc.)
   - Class/interface naming for this pattern
   - Folder naming conventions
   - "What goes where" decision table

3. **`architecture-patterns.md`** — Code patterns to follow and anti-patterns to avoid
   - 3-4 canonical patterns for this architecture with code examples
   - 3-4 anti-patterns that commonly arise with code examples (❌ wrong, ✅ right)
   - Testing strategy aligned with the chosen architecture

### 6d: Roadmap

Run `writing-plans` skill to create ROADMAP.md:
- Phases organized around the chosen architecture's natural units
- Each phase = 1-2 atomic plans
- Dependencies between phases explicit
- First phase = thinnest viable slice that exercises the full architecture stack

**Output:**
- `docs/ARCHITECTURE.md` — Architecture decision, structure, dependency rule, data flow, failure modes
- `ROADMAP.md` — Phased delivery plan
- `.claude/rules/architecture-boundaries.md` — Enforced layer rules
- `.claude/rules/architecture-conventions.md` — Naming and structure conventions
- `.claude/rules/architecture-patterns.md` — Patterns and anti-patterns

**Quality Gate:**
- [ ] Architecture research presented: 2-3 options with project-specific structure examples
- [ ] User has explicitly chosen an architecture (not just acknowledged)
- [ ] ARCHITECTURE.md written: pattern name, rationale, file structure, dependency rule, data flow, failure modes
- [ ] Three rule files generated with project-specific names (no placeholders)
- [ ] Rule files have concrete code examples (correct AND incorrect)
- [ ] Roadmap phases consistent with chosen architecture's module structure
- [ ] First phase exercises the full architecture stack end-to-end

---

## Stage 7: Technical Bootstrapping

**Agent:** planner + executor
**Workflow:** delegates to `project-setup`

**Process:**
1. Delegate to the project-setup workflow:
   - CHOOSE → SCAFFOLD → CONFIGURE → TEST → INITIALIZE
2. Tech stack selected based on Stage 6 architecture decisions
3. Project structure aligned with bounded contexts from Stage 3

**Output:**
- Initialized project with working tooling
- CI/CD pipeline active
- Repository with branch protections

**Quality Gate:**
- [ ] Project scaffolded and configured
- [ ] Build passes
- [ ] CI/CD active
- [ ] Repository initialized

---

## Stage 8: Crystallize (Project DNA)

**Agent:** planner
**Skill:** project-dna

**Process:**
Crystallize all prior-stage artifacts into agent guidance files for the target project:

1. **Inventory** — Scan for all available source documents (design doc, domain model, SPEC.md, REQUIREMENTS.md, UI-SPEC.md, ARCHITECTURE.md, ROADMAP.md)
2. **Consolidate** — Create `spec/` folder structure, copy all artifacts into organized locations, generate `spec/README.md` index. Include `spec/ui/UI-SPEC.md` from Stage 5.
3. **Synthesize CLAUDE.md** — Read each source document, extract relevant sections, compose a concise CLAUDE.md (80-150 lines) at the project root. Include Design System section synthesized from UI-SPEC.md.
4. **Generate Rules** — Create `.claude/rules/` with project-specific rules:
   - `domain-language.md` — Ubiquitous language enforcement from domain model
   - `architecture-boundaries.md` — Layer/module dependency rules (generated in Stage 6)
   - `architecture-conventions.md` — Naming, file structure, what-goes-where (generated in Stage 6)
   - `architecture-patterns.md` — Patterns to follow + anti-patterns with code examples (generated in Stage 6)
   - `project-conventions.md` — General coding patterns from spec and architecture
   - `testing-standards.md` — Test quality requirements from spec
   - `design-system.md` — Design system enforcement from UI-SPEC.md (typography, colors, spacing, component library, accessibility minimums, responsive breakpoints, performance budgets)
   - `mistakes.md` — Empty project-specific gotcha ledger (grows during Stage 9)
5. **Create PROJECT-DNA.md** — Build traceability manifest at `spec/PROJECT-DNA.md`:
   - Lineage table (decision → origin stage → rationale)
   - Requirement trace matrix (REQ-ID → domain entity → module → impl file → test file → status)
   - Domain-to-code map (bounded context → module path → entities → status)
   - UI-to-code map (user flow → route/page → components → status; component → impl file → design tokens → status)
   - ADR index

**Output:**
- Consolidated `spec/` folder with all artifacts indexed (including `spec/ui/UI-SPEC.md`)
- `CLAUDE.md` at project root (concise agent guidance with Design System section)
- `.claude/rules/` with 8 project-specific rule files (including `design-system.md`, `architecture-conventions.md`, `architecture-patterns.md`)
- `spec/PROJECT-DNA.md` traceability manifest (including UI-to-code map)

**Quality Gate:**
- [ ] `spec/` folder populated with all found artifacts (including UI-SPEC.md)
- [ ] `spec/README.md` index generated and accurate
- [ ] `CLAUDE.md` generated (80-150 lines, no placeholders, includes Design System)
- [ ] At least 8 rule files in `.claude/rules/` (architecture-boundaries, architecture-conventions, architecture-patterns, domain-language, project-conventions, testing-standards, design-system, mistakes)
- [ ] `spec/PROJECT-DNA.md` has trace matrix covering all requirements
- [ ] Every domain entity appears in domain-to-code map
- [ ] UI-to-code map covers all user flows and components from UI-SPEC.md
- [ ] User reviewed and approved generated files

---

## Stage 9: Core Implementation

**Agent:** executor
**Skill:** subagent-driven-development, test-driven-development

**Process:**
Execute roadmap phases from Stage 6 using wave-based parallelization:
- Independent phases → parallel execution
- Dependent phases → sequential execution

**Step 0: Load Project DNA**
Before executing any plan, the executor reads:
- `spec/PROJECT-DNA.md` — understand requirement trace matrix, domain-to-code map, and UI-to-code map
- `spec/ui/UI-SPEC.md` — understand user flows, component specs, design system, and interaction patterns
- `CLAUDE.md` — understand project conventions, tech stack, and design system
- `.claude/rules/` — understand project-specific rules (including `design-system.md`)

Per phase:
1. **Discuss** — Identify implementation gray areas, capture decisions in CONTEXT.md
2. **Plan** — Create detailed plan with tasks (XML format), verify against requirements and UI-SPEC.md
3. **Execute** — Implement with TDD (RED → GREEN → REFACTOR), atomic commits
4. **Verify** — Check acceptance criteria, run tests

**Post-phase self-evolving updates:**
- Update `spec/PROJECT-DNA.md` trace matrix (mark implemented REQs, add file paths)
- Update `spec/PROJECT-DNA.md` UI-to-code map (mark implemented flows/components, add file paths)
- Append new conventions to `CLAUDE.md` if patterns emerge during implementation
- Append gotchas to `.claude/rules/mistakes.md` when project-specific issues are encountered
- Update `spec/context/STATE.md` with phase completion status

**Output:**
- Working code per roadmap phase
- Tests for all implemented features
- Atomic commits with descriptive messages
- Updated trace matrix and project context

**Quality Gate:**
- [ ] All phase acceptance criteria met
- [ ] Tests passing (unit + integration)
- [ ] No TODOs or placeholders in code
- [ ] Atomic commits with clear messages
- [ ] Trace matrix updated with implementation file paths

---

## Stage 10: Validation

**Agent:** verifier + test-engineer
**Skill:** ux-audit, flow-discovery

**Process:**
1. Verify spec coverage — every requirement has a working implementation
2. Cross-check domain model — every entity has a working implementation
3. Run full test suite (unit + integration + E2E)
4. Test acceptance criteria
5. Edge case testing
6. Run UX audit (`ux-audit` skill) — score across 6 dimensions: cognitive load, interaction quality, accessibility, user flow coherence, mobile responsiveness, perceived performance
7. Run flow discovery (`flow-discovery` skill) — verify documented user flows from UI-SPEC.md match implementation, generate Playwright test stubs for each flow
8. User acceptance testing

**Output:**
- Verification report
- Test coverage report
- Domain model ↔ implementation cross-check
- UX audit scorecard (6-dimension scores)
- Flow verification report
- Generated Playwright flow tests

**Quality Gate:**
- [ ] Spec coverage 100%
- [ ] Every domain entity implemented
- [ ] All acceptance criteria met
- [ ] No regressions
- [ ] UX audit overall score >= 7/10
- [ ] No critical findings (score <= 4) in any UX dimension
- [ ] All user flows from UI-SPEC.md verified as implemented
- [ ] Accessibility compliance verified against stated WCAG level
- [ ] User acceptance testing passed

---

## Stage 11: Multi-Agent Review

**Agent:** code-reviewer (Deep mode), security-reviewer, architect, ui-auditor, design-reviewer

**Process:**
Sequential review pipeline:
1. **Architecture review** — Does implementation match architecture? Any drift?
2. **Code review (Deep mode, 9-axis)** — Correctness, readability, architecture, security, performance, testing, maintainability, scalability, documentation
3. **Security review** — OWASP Top 10 + STRIDE threat modeling
4. **UI audit (6-pillar)** — Visual consistency, responsive design, accessibility, performance, UX, browser compatibility (`ui-auditor` agent)
5. **Design review (6-pillar)** — Layout & structure, typography, color & contrast, spacing & rhythm, motion & interaction, edge cases (`design-reviewer` agent)

**Output:**
- Architecture review report
- Code review report with scores
- Security review report with scorecard
- UI audit report with 6-pillar scores
- Design review report with visual diff results

**Quality Gate:**
- [ ] No critical findings in any review
- [ ] High findings have remediation plan
- [ ] Architecture matches design (no drift)
- [ ] Security scorecard acceptable
- [ ] UI audit passes all 6 pillars (no critical failures)
- [ ] Design review passes (no critical visual regressions)
- [ ] Accessibility compliance confirmed by ui-auditor

---

## Stage 12: Launch

**Agent:** executor
**Workflow:** delegates to `ship-workflow`

**Process:**
1. Delegate to ship-workflow:
   - Final verification
   - Version bump
   - PR creation
   - Merge
   - Deploy
   - Canary monitoring

**Output:**
- PR merged
- Deployed to production
- Monitoring healthy

**Quality Gate:**
- [ ] PR merged
- [ ] Deployed successfully
- [ ] Monitoring shows healthy state
- [ ] No production errors

---

## Handoff Contracts

### Stage 1 → Stage 2

```yaml
handoff:
  from: product-manager
  to: product-manager + architect
  provides:
    - validated_idea_brief
    - go_no_go_decision
    - alternative_framings
  expects:
    - design_document
    - selected_approach
```

### Stage 2 → Stage 3

```yaml
handoff:
  from: product-manager + architect
  to: architect + planner
  provides:
    - design_document
    - user_approval
  expects:
    - domain_model
    - bounded_contexts
    - ubiquitous_language
```

### Stage 3 → Stage 4

```yaml
handoff:
  from: architect + planner
  to: planner
  provides:
    - domain_model
    - bounded_contexts
    - entity_relationships
    - ubiquitous_language
  expects:
    - spec_document
    - requirements_with_traceability
```

### Stage 4 → Stage 5

```yaml
handoff:
  from: planner
  to: frontend-expert
  provides:
    - spec_document
    - requirements
    - domain_model
  expects:
    - ui_spec_document
    - user_flows
    - component_specifications
    - design_system_decisions
```

### Stage 5 → Stage 6

```yaml
handoff:
  from: frontend-expert
  to: architect + planner
  provides:
    - ui_spec_document
    - user_flows
    - component_specifications
    - design_system_decisions
    - spec_document
    - requirements
  expects:
    - architecture_document
    - roadmap
```

### Stage 6 → Stage 7

```yaml
handoff:
  from: architect + planner
  to: planner + executor
  provides:
    - architecture_document
    - roadmap
    - tech_stack_decisions
  expects:
    - initialized_project
    - cicd_active
```

### Stage 7 → Stage 8

```yaml
handoff:
  from: planner + executor
  to: planner (project-dna skill)
  provides:
    - initialized_project
    - design_document
    - domain_model
    - spec_document
    - requirements
    - ui_spec_document
    - architecture_document
    - roadmap
  expects:
    - consolidated_spec_folder
    - generated_claude_md
    - generated_rules
    - project_dna_manifest
```

### Stage 8 → Stage 9

```yaml
handoff:
  from: planner (project-dna skill)
  to: executor
  provides:
    - consolidated_spec_folder
    - claude_md
    - project_rules
    - project_dna_manifest
    - roadmap
    - ui_spec_document
    - design_system_rules
  expects:
    - working_code
    - tests_passing
    - updated_trace_matrix
```

---

## Timeline Estimate

```yaml
timeline:
  ideation: "1-3 hours"
  reframing: "2-4 hours"
  domain_modeling: "2-6 hours"
  spec: "2-4 hours"
  ui_ux_design: "2-4 hours"
  architecture: "3-6 hours"
  bootstrapping: "3-7 hours"
  crystallize: "15-30 min"
  implementation: "1-6 weeks (depends on scope)"
  validation: "4-8 hours"
  review: "4-8 hours"
  launch: "2-4 hours"

  total_mvp: "1-2 weeks"
  total_full_product: "4-8 weeks"
```

---

## Quality Gates Summary

```yaml
quality_gates:
  ideation:
    - hypothesis_falsifiable
    - alternative_framings_explored
    - go_no_go_decision_made

  reframing:
    - problem_reframed
    - approaches_explored
    - design_approved
    - design_document_written

  domain_model:
    - all_concepts_mapped
    - bounded_contexts_identified
    - entities_typed
    - relationships_documented
    - ubiquitous_language_complete
    - user_approved

  spec:
    - every_entity_mapped_to_requirement
    - requirements_traceable
    - v1_scope_defined
    - success_criteria_testable
    - user_approved

  ui_ux_design:
    - user_flows_cover_v1_requirements
    - user_flows_include_error_paths
    - component_tree_defined
    - design_system_documented
    - wcag_level_chosen
    - responsive_breakpoints_defined
    - performance_targets_set
    - interaction_patterns_documented
    - user_approved

  architecture:
    - architecture_covers_contexts
    - data_flow_documented
    - failure_modes_identified
    - roadmap_phases_map_to_requirements
    - user_approved

  bootstrapping:
    - project_scaffolded
    - build_passes
    - cicd_active
    - repository_initialized

  crystallize:
    - spec_folder_populated
    - spec_readme_generated
    - claude_md_generated
    - rules_generated_including_design_system
    - project_dna_created
    - requirements_traced
    - domain_entities_mapped
    - ui_to_code_map_populated
    - user_approved

  implementation:
    - acceptance_criteria_met
    - tests_passing
    - no_todos_or_placeholders
    - atomic_commits

  validation:
    - spec_coverage_100
    - domain_model_covered
    - acceptance_criteria_met
    - ux_audit_score_minimum_7
    - no_critical_ux_findings
    - user_flows_verified
    - accessibility_verified
    - user_acceptance_passed

  review:
    - no_critical_findings
    - architecture_no_drift
    - security_acceptable
    - ui_audit_6_pillars_pass
    - design_review_pass
    - accessibility_compliance

  launch:
    - pr_merged
    - deployed
    - monitoring_healthy
```

---

## Success Criteria

A successful greenfield app workflow:

- [ ] Product idea validated through structured questioning
- [ ] Problem reframed with clear design approach
- [ ] Domain model complete with bounded contexts and ubiquitous language
- [ ] Specification covers all domain entities with traceable requirements
- [ ] UI/UX specification defines user flows, components, design system, and accessibility
- [ ] UI-SPEC.md approved and included in project documentation
- [ ] Architecture matches domain model and UI-SPEC.md, addresses failure modes
- [ ] Phased roadmap delivered with thinnest viable slice first
- [ ] Project bootstrapped with proper tooling and CI/CD
- [ ] Project DNA crystallized — CLAUDE.md, rules (including design-system.md), and traceability manifest generated
- [ ] All v1 requirements implemented and tested
- [ ] Trace matrix and UI-to-code map updated with implementation file paths
- [ ] UX audit and design review passed with no critical findings
- [ ] Multi-agent review passed with no critical findings
- [ ] Deployed to production with healthy monitoring

---

## Japanese Outsourcing Extension (日本向け受託開発オプション)

When running this workflow for a **Japanese outsourcing client**, apply these extensions at the corresponding stages. These extensions produce the formal documentation required by Japanese clients (基本設計, 詳細設計, 受け入れテスト) and add client sign-off gates.

> For a dedicated Japanese outsourcing workflow, use `japanese-outsourcing` workflow instead of this extension.

### Stage 3 Extension: Basic Design (基本設計)
After domain modeling, run `basic-design` skill to produce `docs/BASIC-DESIGN.md`.
- Includes: system architecture, API interfaces, ER diagram, NFRs, error handling strategy
- **Gate 2a:** Get client sign-off before proceeding to Detailed Design

### Stage 4 Extension: Requirements Gate
After REQUIREMENTS.md is complete:
- **Gate 1:** Formal requirements sign-off with client (use `protocols/review-gates.md` Gate 1 template)
- Initialize `templates/context-artifacts/WBS.md` with phase breakdown

### Stage 6 Extension: Detailed Design (詳細設計)
After architecture, run `detailed-design` skill for each complex module.
- Produces per-module specs with function contracts, data flows, test designs
- **Gate 2b:** Tech lead + QA lead sign-off before implementation

### Stage 9 Extension: Weekly Progress Reports
During implementation, run `progress-reporting` skill weekly.
- GREEN/YELLOW/RED status with metrics
- All change requests go through `protocols/change-management.md`

### Stage 10 Extension: UAT (受け入れテスト)
Replace standard validation with formal UAT using `uat-process` skill.
- Formal UAT test plan + numbered test cases
- Client tester participates in execution
- **Gate 4:** UAT sign-off before deployment

### Stage 12 Extension: Acceptance Checklist
Before final deployment, complete `templates/context-artifacts/ACCEPTANCE-CHECKLIST.md`.
- All documentation verified, all defects documented
- **Final sign-off:** Client signs acceptance checklist

---

**Version:** 3.1.0
**Last Updated:** 2026-05-22
**Status:** Production Ready

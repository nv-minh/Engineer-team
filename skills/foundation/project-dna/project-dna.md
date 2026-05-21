---
name: project-dna
description: "Crystallize project decisions into agent guidance files. Generates CLAUDE.md, rules, and traceability manifests from architecture/spec artifacts. Use after architecture/spec phases or to make any project agent-ready."
version: "1.0.0"
category: "foundation"
origin: "EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "generate project dna"
  - "crystallize decisions"
  - "generate CLAUDE.md for project"
  - "create agent guidance"
  - "project setup context"
  - "make project agent-ready"
intent: "Transform scattered architecture decisions, specs, and domain models into actionable agent guidance files that make every subsequent agent interaction project-aware."
scenarios:
  - "After greenfield Stage 6 (Bootstrap) — crystallize all prior decisions"
  - "Existing project lacks CLAUDE.md — synthesize from available docs"
  - "Agent output quality declining — regenerate guidance from specs"
  - "New team member (human or AI) onboarding — generate project context"
best_for: "Greenfield projects, agent context setup, project onboarding, traceability"
estimated_time: "15-30 min"
anti_patterns:
  - "Dumping entire specs into CLAUDE.md (context flooding — keep it 80-150 lines)"
  - "Generating generic rules without reading project-specific docs"
  - "Skipping traceability — generating guidance without linking back to sources"
  - "Making CLAUDE.md too long (>200 lines defeats its purpose)"
  - "Copy-pasting source docs instead of synthesizing concise summaries"
related_skills: [context-engineering, spec-driven-development, domain-modeling, writing-plans, architecture-zoom-out]
---

# Project DNA

## Overview

Feed agents the right project context from day one. Project DNA reads all prior-stage artifacts (design docs, domain models, specs, architecture docs, roadmaps) and crystallizes them into a set of files that make every subsequent agent interaction project-aware:

1. **`CLAUDE.md`** — Concise project-specific agent instructions (80-150 lines)
2. **`.claude/rules/*.md`** — Enforceable project rules (domain language, architecture boundaries, conventions)
3. **`spec/PROJECT-DNA.md`** — Full-chain traceability manifest (requirement → architecture → code → test)
4. **`spec/` folder** — Consolidated, indexed spec documentation

## When to Use

- After greenfield Bootstrap (Stage 6) — crystallize all decisions before implementation
- Existing project lacks agent context — generate CLAUDE.md and rules from available docs
- Agent output quality is declining — regenerate guidance to restore project awareness
- New agent session or team member — instant project onboarding
- After major architecture changes — refresh generated guidance

## When NOT to Use

- Project has no specs, no architecture docs, and no domain model (nothing to synthesize)
- Simple one-file scripts or throwaway prototypes
- You only need a generic CLAUDE.md (use `context-engineering` skill instead)

## Anti-Patterns

- **Context flooding**: Dumping entire spec docs into CLAUDE.md. Keep it 80-150 lines of distilled guidance.
- **Generic rules**: Generating "always write tests" without reading what the project's actual test framework, conventions, and thresholds are.
- **Orphaned traceability**: Creating PROJECT-DNA.md but never updating it during implementation.
- **Stale context**: Generating once and never refreshing after architecture changes.

---

## Process

### Step 1: Inventory Artifacts

Scan the project for all available source documents. Report what was found and what is missing.

**Search locations:**

| Artifact | Primary Location | Fallback Locations |
|----------|-----------------|-------------------|
| Design document | `docs/specs/YYYY-MM-DD-*-design.md` | `spec/design/`, `docs/design.md` |
| Domain model | `docs/domain-model.md` | `spec/domain/domain-model.md`, `DOMAIN-MODEL.md` |
| Spec | `SPEC.md` | `docs/SPEC.md`, `spec/requirements/SPEC.md` |
| Requirements | `REQUIREMENTS.md` | `docs/REQUIREMENTS.md`, `spec/requirements/REQUIREMENTS.md` |
| UI specification | `docs/UI-SPEC.md` | `UI-SPEC.md`, `spec/ui/UI-SPEC.md` |
| Architecture | `ARCHITECTURE.md` | `docs/ARCHITECTURE.md`, `spec/architecture/ARCHITECTURE.md` |
| Roadmap | `ROADMAP.md` | `docs/ROADMAP.md`, `spec/architecture/ROADMAP.md` |
| package.json / config | Root directory | Various config files |

**Output:**
```
Artifact Inventory:
  [FOUND] Design document: docs/specs/2026-05-21-myapp-design.md
  [FOUND] Domain model: docs/domain-model.md
  [FOUND] Spec: SPEC.md
  [FOUND] Requirements: REQUIREMENTS.md
  [FOUND] UI specification: docs/UI-SPEC.md
  [FOUND] Architecture: ARCHITECTURE.md
  [FOUND] Roadmap: ROADMAP.md
  [MISSING] ADRs: No architecture decision records found

Proceeding with 7/8 artifacts.
```

**Minimum viable input:** At least one of: SPEC.md, ARCHITECTURE.md, or domain model. If none exist, STOP and suggest running spec-driven-development first.

---

### Step 2: Consolidate Spec Folder

Create the consolidated `spec/` folder structure and move/copy all artifacts into it.

**Target structure:**

```
spec/
  README.md                              # Living index (auto-generated)
  PROJECT-DNA.md                         # Traceability manifest (Step 5)
  design/
    YYYY-MM-DD-<topic>-design.md         # From Stage 2
  domain/
    domain-model.md                      # From Stage 3
    glossary.md                          # Extracted ubiquitous language terms
  requirements/
    SPEC.md                              # From Stage 4
    REQUIREMENTS.md                      # From Stage 4
  ui/
    UI-SPEC.md                           # From Stage 5 (user flows, components, design system)
  architecture/
    ARCHITECTURE.md                      # From Stage 6
    ROADMAP.md                           # From Stage 6
    decisions/                           # ADRs (if any)
      ADR-001-*.md
  context/
    PROJECT.md                           # Project context (from template)
    STATE.md                             # Session state tracker (from template)
```

**Actions:**
1. Create `spec/` directory structure
2. Copy each found artifact to its target location
3. If domain model has a glossary section, extract it into `spec/domain/glossary.md`
4. Generate `spec/context/PROJECT.md` from template, filling in values from found artifacts
5. Generate `spec/context/STATE.md` from template
6. Generate `spec/README.md` — the living index

**`spec/README.md` format:**

```markdown
# Spec Index

## Document Registry

| Document | Location | Source Stage | Status | Last Updated |
|----------|----------|-------------|--------|--------------|
| Design Document | spec/design/... | Stage 2: Reframing | Approved | YYYY-MM-DD |
| Domain Model | spec/domain/domain-model.md | Stage 3: Domain Modeling | Approved | YYYY-MM-DD |
| Glossary | spec/domain/glossary.md | Stage 3: Domain Modeling | Approved | YYYY-MM-DD |
| Specification | spec/requirements/SPEC.md | Stage 4: Spec | Approved | YYYY-MM-DD |
| Requirements | spec/requirements/REQUIREMENTS.md | Stage 4: Spec | Approved | YYYY-MM-DD |
| UI Specification | spec/ui/UI-SPEC.md | Stage 5: UI/UX Design | Approved | YYYY-MM-DD |
| Architecture | spec/architecture/ARCHITECTURE.md | Stage 6: Architecture | Approved | YYYY-MM-DD |
| Roadmap | spec/architecture/ROADMAP.md | Stage 6: Architecture | Approved | YYYY-MM-DD |
| Project DNA | spec/PROJECT-DNA.md | Stage 8: Crystallize | Active | YYYY-MM-DD |

## Quick Links

- **What are we building?** → [Design Document](design/...)
- **What domain concepts exist?** → [Domain Model](domain/domain-model.md)
- **What terms do we use?** → [Glossary](domain/glossary.md)
- **What are the requirements?** → [Requirements](requirements/REQUIREMENTS.md)
- **What does the UI look like?** → [UI Specification](ui/UI-SPEC.md)
- **How is it architected?** → [Architecture](architecture/ARCHITECTURE.md)
- **What's the delivery plan?** → [Roadmap](architecture/ROADMAP.md)
- **Full traceability?** → [Project DNA](PROJECT-DNA.md)
```

---

### Step 3: Synthesize CLAUDE.md

Read each source document and compose a concise `CLAUDE.md` for the target project root.

**Use template:** [claude-md.template.md](../../templates/project-dna/claude-md.template.md)

**Synthesis rules:**
- Target length: **80-150 lines**. This is a distillation, not a dump.
- Each section pulls from specific source documents (see template for mappings).
- Use concrete values from the actual artifacts — no placeholders like `[fill in]`.
- If a source artifact is missing, omit the section or note "Not yet defined".
- Commands section must contain actual executable commands, not generic examples.
- Domain Language section must use the project's actual terms from the glossary.
- Boundaries must be the project's actual boundaries from the spec, not generic ones.

**Synthesis priority (if space is tight):**
1. Commands (most actionable)
2. Tech Stack (most referenced)
3. Project Structure (most navigated)
4. Boundaries (most protective)
5. Domain Language (most differentiating)
6. Design System (most visually protective)
7. Code Conventions
8. Architecture Patterns
9. Testing Strategy
10. Project Identity
11. Spec Reference

---

### Step 4: Generate Rules

Create `.claude/rules/` directory in the target project and generate rule files.

**Rule files to generate:**

#### 4a. `domain-language.md`
**Source:** Domain model glossary (Stage 3)
**Template:** [domain-language.template.md](../../templates/project-dna/rules/domain-language.template.md)

Extract from domain model:
- All entity names with their correct spelling/casing
- Ubiquitous language terms and definitions
- "Never use X when you mean Y" corrections (synonyms to avoid)
- Naming patterns for classes/modules that represent domain concepts

#### 4b. `architecture-boundaries.md`
**Source:** ARCHITECTURE.md bounded contexts + module structure (Stage 5)
**Template:** [architecture-boundaries.template.md](../../templates/project-dna/rules/architecture-boundaries.template.md)

Extract from architecture:
- Module/bounded context responsibilities
- Dependency direction rules (e.g., "domain MUST NOT import from infrastructure")
- Which modules can depend on which
- Shared kernel definitions (if any)

#### 4c. `project-conventions.md`
**Source:** SPEC.md code style + ARCHITECTURE.md patterns (Stages 4-5)
**Template:** [project-conventions.template.md](../../templates/project-dna/rules/project-conventions.template.md)

Extract from spec and architecture:
- File naming conventions
- Component/module structure patterns
- Error handling patterns
- API design patterns
- Import organization rules

#### 4d. `testing-standards.md`
**Source:** SPEC.md testing section (Stage 4)
**Template:** [testing-standards.template.md](../../templates/project-dna/rules/testing-standards.template.md)

Extract from spec:
- Test framework and runner
- Test file naming and location conventions
- Coverage thresholds
- Test structure patterns (arrange/act/assert)
- What to test vs. what not to test

#### 4e. `design-system.md`
**Source:** UI-SPEC.md design system, accessibility, and responsive sections (Stage 5)

Extract from UI-SPEC.md:
- Typography scale (font families, sizes, weights, line heights)
- Color palette with semantic names (primary, secondary, error, etc.)
- Spacing system (base unit, scale)
- Component library choice and usage patterns
- Accessibility minimums (contrast ratios, touch target sizes, WCAG level)
- Responsive breakpoints
- Performance budgets (LCP, INP, CLS targets)

**Skip if:** UI-SPEC.md not found (project has no UI layer or UI spec not yet written).

#### 4f. `mistakes.md`
**Source:** Empty template (grows during implementation)

Create with header and empty entries section. The executor populates this during Stage 9 when project-specific gotchas are encountered.

---

### Step 5: Create PROJECT-DNA.md

Build the traceability manifest that connects every decision back to its origin.

**Template:** [project-dna.template.md](../../templates/project-dna/project-dna.template.md)

**Sections to populate:**

#### 5a. Lineage Table
Cross-reference ARCHITECTURE.md decisions with their source stage and rationale.

#### 5b. Requirement Trace Matrix
For every REQ-ID in REQUIREMENTS.md, create a row with:
- Requirement description
- Which domain entity it relates to (from domain model)
- Which architecture module implements it
- Implementation file path (empty — filled by executor)
- Test file path (empty — filled by executor)
- Status: `Not started` (updated by executor)

#### 5c. Domain-to-Code Map
For every bounded context in the domain model:
- Map to architecture module path
- List entities in that context
- Status: `Not started` (updated by executor)

#### 5d. UI-to-Code Map
For every user flow in UI-SPEC.md:
- Map to implementation route/page
- List components involved
- Status: `Not started` (updated by executor)

For every component specified in UI-SPEC.md:
- Map to implementation file path
- Map to design system tokens used
- Status: `Not started` (updated by executor)

**Skip if:** UI-SPEC.md not found.

#### 5e. ADR Index
If any architecture decision records exist, index them here.

---

## Quality Gate

```yaml
quality_gate:
  - spec_folder_populated: "spec/ directory created with all found artifacts"
  - spec_readme_generated: "spec/README.md index exists and lists all documents"
  - claude_md_generated: "CLAUDE.md exists at project root, 80-150 lines"
  - claude_md_no_placeholders: "No [fill in] or [TODO] placeholders in CLAUDE.md"
  - rules_generated: "At least 3 rule files in .claude/rules/ (5+ if UI-SPEC.md found, including design-system.md)"
  - rules_project_specific: "Rules contain project-specific content, not generic templates"
  - project_dna_created: "spec/PROJECT-DNA.md exists with trace matrix"
  - requirements_traced: "Every REQ-ID in REQUIREMENTS.md has a row in trace matrix"
  - domain_entities_mapped: "Every domain entity appears in domain-to-code map"
  - user_approved: "User reviewed and approved generated files"
```

---

## Self-Evolving Mechanism

After initial generation, the executor agent updates these files during implementation:

### What Gets Updated and When

| Trigger | File Updated | What Changes |
|---------|-------------|--------------|
| Phase completed | `spec/PROJECT-DNA.md` | Trace matrix: mark implemented REQs, add file paths |
| UI phase completed | `spec/PROJECT-DNA.md` | UI-to-code map: mark implemented flows/components, add file paths |
| New convention discovered | `CLAUDE.md` | Add new convention to Code Conventions or Design System section |
| Gotcha encountered | `.claude/rules/mistakes.md` | Append project-specific mistake pattern |
| Architecture drift | `spec/PROJECT-DNA.md` | Flag drift in Lineage table |
| Phase completed | `spec/context/STATE.md` | Record phase completion, set next phase |

### Update Rules
- Updates are **append-only** — never delete existing content
- Only add conventions that **actually emerged** during implementation (not speculative)
- Mistakes entries must include **what happened, why, and prevention** pattern
- Trace matrix updates use **actual file paths**, not guesses

---

## Standalone Usage

The project-dna skill can be invoked outside the greenfield workflow:

```
Use the project-dna skill to generate agent guidance for this project
```

**Minimum requirements for standalone:**
- At least one of: SPEC.md, ARCHITECTURE.md, or documentation describing the project
- If none exist, the skill suggests running `spec-driven-development` first

**Partial generation:**
- Missing domain model → skip `domain-language.md` rule, omit Domain Language section from CLAUDE.md
- Missing architecture → skip `architecture-boundaries.md` rule, omit Architecture Patterns section
- Missing spec → skip `testing-standards.md` rule, generate minimal CLAUDE.md from available docs

---

## Coaching Notes

- **Why traceability matters:** Without it, agents make decisions in a vacuum. Every line of code should trace back to a requirement. Every requirement should trace back to a design decision. This chain prevents "building the wrong thing well."
- **Why concise CLAUDE.md:** Agents have limited context. A 500-line CLAUDE.md dilutes the signal. The 80-150 line target forces you to distill what truly matters for day-to-day coding decisions.
- **Why rules over CLAUDE.md:** Rules files are always loaded and enforce patterns. CLAUDE.md provides context. Rules are "must follow" — CLAUDE.md is "should know."
- **Why self-evolving:** Static documentation rots. The self-evolving mechanism keeps project context accurate as the codebase grows, preventing the "docs don't match code" problem.

---

## Verification

After running this skill, verify:

- [ ] `spec/` folder contains all found artifacts in organized structure
- [ ] `spec/README.md` accurately indexes all documents
- [ ] `CLAUDE.md` at project root is 80-150 lines with no placeholders
- [ ] `CLAUDE.md` commands are actually executable in the project
- [ ] `.claude/rules/domain-language.md` contains project-specific terms
- [ ] `.claude/rules/architecture-boundaries.md` matches the architecture
- [ ] `.claude/rules/design-system.md` contains project-specific design tokens (if UI-SPEC.md found)
- [ ] `spec/PROJECT-DNA.md` has a row for every requirement
- [ ] `spec/PROJECT-DNA.md` has UI-to-code map for all flows/components (if UI-SPEC.md found)
- [ ] User has reviewed and approved all generated files

## Related Skills

- **context-engineering** — Broader context optimization (this skill is a specialized subset)
- **spec-driven-development** — Creates the SPEC.md that this skill synthesizes from
- **domain-modeling** — Creates the domain model that feeds the glossary and traceability
- **writing-plans** — Creates the plans that feed the roadmap
- **architecture-zoom-out** — Reviews architecture that feeds the boundary rules

---
name: project-dna
description: "Crystallize project decisions into agent guidance files. Generates CLAUDE.md, rules, and traceability manifests from architecture/spec artifacts. Use after architecture/spec phases or to make any project agent-ready."
version: "3.0.0"
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
input_schema:
  type: object
  required: [project_root]
  properties:
    project_root: { type: string }
    scope: { type: string, enum: [full, update, validate], default: full }
output_schema:
  type: object
  required: [status, artifacts]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    artifacts:
      type: object
      properties:
        claude_md: { type: string, description: "Path to generated CLAUDE.md" }
        rules: { type: array, items: { type: string }, description: "Paths to generated rule files" }
        trace_matrix: { type: string, description: "Path to trace matrix" }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    attempted_action: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Project DNA

[ROLE]
You are a project context crystallizer. Read all prior-stage artifacts and synthesize them into concise, actionable agent guidance files.

[OBJECTIVE]
Produce a complete set of project context files — CLAUDE.md (80-150 lines), .claude/rules/*.md, spec/ folder, and PROJECT-DNA.md traceability manifest — so every subsequent agent interaction is project-aware from the first prompt.

[RULES]
1. Use <thought> before each process step to inventory available artifacts and plan synthesis.
2. DO NOT dump entire specs into CLAUDE.md — keep it 80-150 lines. This is a distillation, not a copy.
3. DO NOT generate generic rules without reading project-specific docs — rules must contain project-specific content.
4. DO NOT skip traceability — every generated guidance file must link back to its source artifact.
5. DO NOT copy-paste source docs — synthesize concise summaries with concrete values.
6. DO NOT use placeholders like "[fill in]" or "[TODO]" in CLAUDE.md — use actual values from artifacts or omit the section.
7. DO NOT use this skill when no specs, architecture docs, or domain model exist (nothing to synthesize) — suggest running spec-driven-development first.
8. Updates to generated files are append-only — never delete existing content during self-evolution.
9. Rules files are "must follow" enforcement; CLAUDE.md is "should know" context. Keep this distinction.
10. Every traceability link teaches the team why decisions were made and where they came from (ABC coaching).

[PROCESS]

### Step 1: Inventory Artifacts

Scan the project for all available source documents. Report what was found and what is missing.

| Artifact | Primary Location | Fallback Locations |
|----------|-----------------|-------------------|
| Design document | `docs/specs/YYYY-MM-DD-*-design.md` | `spec/design/`, `docs/design.md` |
| Domain model | `docs/domain-model.md` | `spec/domain/domain-model.md` |
| Spec | `SPEC.md` | `docs/SPEC.md`, `spec/requirements/SPEC.md` |
| Requirements | `REQUIREMENTS.md` | `docs/REQUIREMENTS.md` |
| UI specification | `docs/UI-SPEC.md` | `UI-SPEC.md`, `spec/ui/UI-SPEC.md` |
| Architecture | `ARCHITECTURE.md` | `docs/ARCHITECTURE.md` |
| Roadmap | `ROADMAP.md` | `docs/ROADMAP.md` |
| package.json / config | Root directory | Various config files |

**Minimum viable input:** At least one of SPEC.md, ARCHITECTURE.md, or domain model. If none exist, STOP and suggest running spec-driven-development first.

### Step 2: Consolidate Spec Folder

Create the consolidated `spec/` folder structure:

```
spec/
  README.md                              # Living index (auto-generated)
  PROJECT-DNA.md                         # Traceability manifest (Step 5)
  design/
  domain/
    domain-model.md
    glossary.md
  requirements/
    SPEC.md
    REQUIREMENTS.md
  ui/
    UI-SPEC.md
  architecture/
    ARCHITECTURE.md
    ROADMAP.md
    decisions/                           # ADRs
  context/
    PROJECT.md
    STATE.md
```

Actions:
1. Create `spec/` directory structure.
2. Copy each found artifact to its target location.
3. Extract glossary from domain model into `spec/domain/glossary.md` if present.
4. Generate `spec/context/PROJECT.md` and `spec/context/STATE.md` from templates.
5. Generate `spec/README.md` — the living index.

### Step 3: Synthesize CLAUDE.md

Use template: [claude-md.template.md](../../templates/project-dna/claude-md.template.md)

Synthesis rules:
- Target length: **80-150 lines**.
- Use concrete values from actual artifacts — no placeholders.
- If a source artifact is missing, omit the section or note "Not yet defined".
- Commands section must contain actual executable commands.

Synthesis priority (if space is tight):
1. Commands
2. Tech Stack
3. Project Structure
4. Boundaries
5. Domain Language
6. Design System
7. Code Conventions
8. Architecture Patterns
9. Testing Strategy
10. Project Identity
11. Spec Reference

### Step 4: Generate Rules

Create `.claude/rules/` directory and generate rule files:

**4a. `domain-language.md`** (Source: Domain model glossary)
- Entity names with correct spelling/casing.
- Ubiquitous language terms and definitions.
- "Never use X when you mean Y" corrections.
- Naming patterns for domain concept classes/modules.

**4b. `architecture-boundaries.md`** (Source: ARCHITECTURE.md)
- Module/bounded context responsibilities.
- Dependency direction rules.
- Which modules can depend on which.
- Shared kernel definitions.

**4c. `project-conventions.md`** (Source: SPEC.md + ARCHITECTURE.md)
- File naming conventions.
- Component/module structure patterns.
- Error handling patterns.
- API design patterns.
- Import organization rules.

**4d. `testing-standards.md`** (Source: SPEC.md testing section)
- Test framework and runner.
- Test file naming and location conventions.
- Coverage thresholds.
- Test structure patterns.

**4e. `design-system.md`** (Source: UI-SPEC.md — skip if not found)
- Typography scale, color palette, spacing system.
- Component library usage patterns.
- Accessibility minimums.
- Responsive breakpoints.
- Performance budgets.

**4f. `mistakes.md`** (Empty template — grows during implementation)

### Step 5: Create PROJECT-DNA.md

Build the traceability manifest:

**5a. Lineage Table** — Cross-reference architecture decisions with source stage and rationale.

**5b. Requirement Trace Matrix** — For every REQ-ID:
- Requirement description, domain entity, architecture module, implementation file path (empty), test file path (empty), status.

**5c. Domain-to-Code Map** — For every bounded context:
- Architecture module path, entities, status.

**5d. UI-to-Code Map** (skip if no UI-SPEC.md) — For every user flow and component:
- Implementation route/page, components, design system tokens, status.

**5e. ADR Index** — Index existing architecture decision records.

## Self-Evolving Mechanism

| Trigger | File Updated | What Changes |
|---------|-------------|--------------|
| Phase completed | `spec/PROJECT-DNA.md` | Trace matrix: mark implemented REQs, add file paths |
| UI phase completed | `spec/PROJECT-DNA.md` | UI-to-code map: mark implemented flows/components |
| New convention discovered | `CLAUDE.md` | Add new convention |
| Gotcha encountered | `.claude/rules/mistakes.md` | Append mistake pattern |
| Architecture drift | `spec/PROJECT-DNA.md` | Flag drift in Lineage table |
| Phase completed | `spec/context/STATE.md` | Record phase completion |

Update rules:
- Updates are **append-only** — never delete existing content.
- Only add conventions that **actually emerged** during implementation.
- Mistakes entries must include what happened, why, and prevention pattern.
- Trace matrix updates use **actual file paths**, not guesses.

[RESPONSE FORMAT]
Return output matching `output_schema`: status (DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED) and artifacts object with claude_md path, rules paths array, and trace_matrix path.

[VERIFICATION]
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

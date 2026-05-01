---
name: prd-generator
description: >
  Convert rough ideas, feature discussions, or conversation context into a structured PRD
  (Product Requirements Document). Explores the codebase to understand current state,
  identifies major modules, and produces a document focused on deep, testable modules
  with problem statements, proposed solutions, user stories, and implementation decisions.
version: "2.1.0"
category: "development"
origin: "skills (Matt Pocock) + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "create PRD"
  - "write PRD"
  - "product requirements"
  - "to prd"
  - "requirements document"
  - "PRD"
intent: >
  Turn an idea or feature discussion into a structured PRD that explores the codebase,
  identifies the right module boundaries, and produces a document that can drive
  spec-driven-development and issue generation.
scenarios:
  - "Turning a Slack conversation about a new feature into a formal PRD"
  - "Converting a brainstorming session output into a requirements document"
  - "Exploring a codebase to understand what modules a new feature needs"
  - "Creating a PRD for a feature that spans multiple services or repos"
best_for: "new features, product planning, requirements formalization, pre-spec exploration"
estimated_time: "20-40 min"
anti_patterns:
  - "Writing a PRD without exploring the codebase first"
  - "Creating shallow modules that cannot be tested in isolation"
  - "Writing requirements as implementation instructions instead of user outcomes"
  - "Skipping the 'what exists today' analysis"
related_skills:
  - spec-driven-development
  - brainstorming
  - jobs-to-be-done
  - issue-generator
  - writing-plans
---

# PRD Generator

## Overview

The PRD Generator turns rough ideas, feature discussions, or conversation context into a structured Product Requirements Document. It explores the codebase to understand the current state, identifies the major modules needed, and produces a document focused on deep modules that are testable in isolation.

This is the bridge between "I have an idea" and "here is what we are building." The PRD feeds directly into spec-driven-development for detailed specs and issue-generator for task breakdown.

## When to Use

- You have a feature idea and need to formalize it before implementation
- A brainstorming session produced concepts that need structure
- A stakeholder request needs to be translated into engineering requirements
- You need to understand what modules a new feature requires in the existing codebase
- Before starting spec-driven-development (PRD comes first)

## When NOT to Use

- You already have a detailed spec (use `spec-driven-development` to refine)
- The work is a bug fix (use `systematic-debugging`)
- You are doing exploratory ideation (use `brainstorming` first)
- The feature is trivial and does not need a document

## Anti-Patterns

- Writing a PRD without exploring the codebase -- requirements that ignore existing patterns
- Listing modules as thin wrappers -- every module must encapsulate something meaningful
- Writing "how to build it" instead of "what it must do" -- PRD describes outcomes, not implementation
- Skipping the current-state analysis -- leads to duplicate modules or contradictory requirements

## Process

### Step 1: Gather Input

Collect the idea from whatever source is available.

```
Sources (check in order):
1. Current conversation context
2. Brainstorming session notes or output
3. JTBD (Jobs to Be Done) analysis
4. Direct user description
5. Existing REQUIREMENTS.md or ROADMAP.md (for additions)
```

Ask clarifying questions if the idea is underspecified:
- What problem does this solve for the user?
- Who are the primary users?
- What does success look like?
- What is out of scope?

### Step 2: Explore the Codebase

Before writing a single requirement, understand what exists today.

```
Explore:
1. Project structure -- what modules/packages exist
2. Data models -- what entities and relationships exist
3. API surface -- what endpoints are already defined
4. UI routes -- what pages and components exist
5. Patterns -- what conventions the codebase follows
6. Tests -- what testing strategies are in use
```

Document findings:

```markdown
## Current State

### Existing Modules
- `<module-name>`: <brief description of responsibility>

### Relevant Data Models
- `<model>`: <fields relevant to this feature>

### Existing Patterns
- <pattern>: <how it is used in the codebase>

### Gaps (what does NOT exist yet)
- <gap that this feature must fill>
```

### Step 3: Identify Major Modules

Decompose the feature into modules. Apply the "deep modules" principle.

```
Deep Module Criteria:
1. Has a clear, narrow interface (few public methods/endpoints)
2. Encapsulates significant complexity behind that interface
3. Can be tested in complete isolation
4. Has a single reason to change
5. Could be replaced with a different implementation without affecting consumers

Shallow Module Warning Signs:
- Only passes data through (no logic)
- Interface is wider than the implementation
- Depends on many other modules to function
- Cannot be tested without setting up half the system
```

Module identification template:

```markdown
## Module Breakdown

### Module 1: <name>
- Responsibility: <one sentence>
- Interface: <public API / exports / endpoints>
- Dependencies: <what other modules it needs>
- Test strategy: <how to test in isolation>

### Module 2: <name>
- Responsibility: <one sentence>
- Interface: <public API / exports / endpoints>
- Dependencies: <what other modules it needs>
- Test strategy: <how to test in isolation>
```

### Step 4: Write the PRD

Use the following structure:

```markdown
# PRD: <Feature Name>

## Problem Statement
<What problem exists today. Who is affected. What is the cost of not solving it.>

## Proposed Solution
<High-level approach. What the system will do. How it addresses the problem.>

## User Stories

### Primary
- As a <role>, I want to <action>, so that <benefit>.

### Secondary
- As a <role>, I want to <action>, so that <benefit>.

### Edge Cases
- As a <role>, when <condition>, I expect <behavior>.

## Non-Goals
<What this feature explicitly does NOT do. Keeps scope honest.>

## Success Metrics
<How to measure that the feature solves the problem. Quantitative if possible.>

## Module Design

### Module 1: <name>
- Responsibility: <description>
- Interface: <public contract>
- Dependencies: <list>
- Testing: <strategy>

### Module 2: <name>
...

## Implementation Decisions
<Record key technical decisions and their rationale.>

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| <what> | <A, B, C> | <chosen> | <why> |

## Testing Decisions
<Record key testing decisions and their rationale.>

| Layer | Strategy | Coverage Target |
|---|---|---|
| Unit | <approach> | <target> |
| Integration | <approach> | <target> |
| E2E | <approach> | <target> |

## Open Questions
<Things that need resolution before spec-driven-development.>

## Dependencies & Risks
- <dependency or risk>
```

### Step 5: Validate the PRD

Run a self-check before delivering:

```
Validation checklist:
[ ] Problem statement is specific and measurable
[ ] User stories cover the primary flow and at least 2 edge cases
[ ] Every module passes the "deep module" test
[ ] Implementation decisions include rationale (not just the choice)
[ ] Testing decisions exist for every module
[ ] Open questions are surfaced, not hidden
[ ] Non-goals section exists and is non-empty
[ ] No implementation details disguised as requirements
```

### Step 6: Store the PRD

Save the document in the project:

```
Location (in priority order):
1. docs/PRD.md (if docs/ directory exists)
2. PRD.md (project root)
3. templates/context-artifacts/REQUIREMENTS.md (if using EM-Team template structure)

Also update ROADMAP.md if it exists, linking to the new PRD.
```

## Coaching Notes

> **ABC - Always Be Coaching:** A good PRD is the difference between building the right thing and building something. The discipline of writing down the problem, the users, and the module boundaries before writing code saves more time than any other single activity in software development.

1. **The codebase exploration step is non-negotiable.** A PRD that ignores existing patterns, duplicates modules, or contradicts current architecture is worse than no PRD at all. Always explore before prescribing.

2. **Deep modules are the architecture.** If you cannot name a module's responsibility in one sentence, it is doing too much. If its interface has more than a handful of public methods, it is not encapsulating enough. Module design IS architecture design.

3. **Non-goals are as important as goals.** Every feature attracts scope creep like a magnet. The non-goals section is the fence. Without it, "simple notification system" becomes "real-time collaborative messaging platform."

4. **Open questions are a feature, not a failure.** Surfacing unknowns early means they get resolved during planning instead of during implementation when the cost of changing direction is 10x higher.

## Verification

After generating the PRD:

- [ ] Codebase exploration was performed and findings documented
- [ ] Problem statement is specific and describes who is affected
- [ ] User stories cover primary, secondary, and edge case flows
- [ ] Every module passes the deep module criteria
- [ ] Implementation decisions have rationale
- [ ] Testing decisions exist for each module
- [ ] Non-goals section is present and non-empty
- [ ] Open questions are explicitly listed
- [ ] PRD is stored in the project at a discoverable location
- [ ] ROADMAP.md is updated if it exists

## Related Skills

- `spec-driven-development` -- takes the PRD and produces detailed implementation specs
- `brainstorming` -- precedes PRD generation for idea exploration
- `jobs-to-be-done` -- provides user need analysis that feeds into PRD user stories
- `issue-generator` -- takes the PRD and breaks it into tracer-bullet issues
- `writing-plans` -- takes the PRD and produces a detailed implementation plan

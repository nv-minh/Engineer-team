---
name: issue-generator
description: >
  Convert plans and specs into structured GitHub Issues using vertical slices (tracer bullets).
  Each issue cuts through ALL integration layers (schema, API, UI, tests) as an independently
  grabbable unit. Classifies issues as HITL (human-in-the-loop) or AFK (autonomous).
  Publishes to GitHub Issues with labels, milestones, and dependency ordering.
version: "2.1.0"
category: "development"
origin: "skills (Matt Pocock) + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "create issues"
  - "break into issues"
  - "generate tickets"
  - "to issues"
  - "tracer bullets"
  - "issue breakdown"
intent: >
  Turn a plan or spec into a set of tracer-bullet GitHub Issues where each issue is a
  complete vertical slice through every layer of the stack. Issues are independently
  grabbable, properly ordered by dependency, and classified by autonomy level.
scenarios:
  - "Converting a spec-driven-development spec into a backlog of vertical-slice issues"
  - "Breaking a PRD into independently deliverable tracer-bullet tickets"
  - "Generating a sprint-ready issue set with HITL/AFK classification for a team"
  - "Taking a writing-plans output and publishing it to GitHub Issues with milestones"
best_for: "breaking specs into actionable work, sprint planning, vertical-slice task creation"
estimated_time: "10-20 min"
anti_patterns:
  - "Creating horizontal-layer issues (all schema, then all API, then all UI)"
  - "Writing vague issues without acceptance criteria or test expectations"
  - "Ignoring dependency ordering so developers block each other"
  - "Making every issue HITL when most can run AFK"
related_skills:
  - writing-plans
  - spec-driven-development
  - incremental-implementation
  - subagent-driven-development
---

# Issue Generator

## Overview

The Issue Generator converts plans and specs into structured GitHub Issues using the tracer-bullet pattern. Each issue is a vertical slice that cuts through every integration layer -- schema, API, UI, and tests -- delivering a complete, working path from data to screen. Issues are independently grabbable: any developer (or agent) can pick one up and deliver it without waiting on adjacent slices.

## When to Use

- You have a completed spec or plan and need to break it into actionable work
- Starting a new sprint and need structured, dependency-ordered issues
- Handing off work to a team or subagents who need clear, self-contained tasks
- Converting a PRD or REQUIREMENTS.md into a GitHub Issue backlog
- Planning parallel work across multiple developers

## When NOT to Use

- The plan is still in early exploration (use `brainstorming` first)
- No spec or plan exists yet (use `spec-driven-development` first)
- The work is a single straightforward task (just do it, no breakdown needed)
- You need detailed architecture decisions (use `writing-plans` first)

## Anti-Patterns

- Creating horizontal-layer issues ("build all schemas", "build all APIs") -- nothing integrates until everything is done
- Writing issues without acceptance criteria -- "implement feature X" tells nothing about done
- Ignoring dependency ordering -- developers block on each other when upstream slices are not ready
- Classifying every issue as HITL -- most slices are mechanical once the spec is clear

## Process

### Step 1: Ingest the Source

Read the plan, spec, or PRD that will be decomposed.

```
Sources (in priority order):
1. spec-driven-development spec or REQUIREMENTS.md
2. writing-plans output (PLAN.md)
3. PRD.md or product requirements document
4. Direct feature description from user
```

Extract:
- Major modules and their boundaries
- User-facing capabilities (not internal layers)
- Data models and their relationships
- API surface area
- UI components and user flows
- Test requirements

### Step 2: Identify Vertical Slices

Map the work into tracer bullets. Each slice must cut through ALL layers.

```
Vertical Slice Anatomy:
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  UI Layer      ──→ Component, page, interaction          │
│  API Layer     ──→ Endpoint, request/response contract   │
│  Service Layer ──→ Business logic, validation            │
│  Data Layer    ──→ Schema, migration, query              │
│  Test Layer    ──→ Unit, integration, e2e for this slice │
│                                                          │
│  Every slice ships a complete path through all layers.   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Slice design rules:**

1. Each slice delivers one user-facing capability end-to-end
2. Each slice is independently testable and deployable
3. Each slice builds on (or is parallel to) previous slices
4. No slice depends on a future slice to be useful

**Example -- Blog feature decomposition:**

```
Slice 1: "Author can create a draft post"
  - Schema: posts table (title, body, status, author_id)
  - API: POST /api/posts (201 with post payload)
  - UI: New post form with title/body fields
  - Tests: unit (validator), integration (API), e2e (form submit)

Slice 2: "Author can publish a post"
  - Schema: add published_at column
  - API: PATCH /api/posts/:id/publish
  - UI: Publish button on draft posts
  - Tests: integration (status transition), e2e (publish flow)

Slice 3: "Visitor can read published posts"
  - Schema: no change (reads existing data)
  - API: GET /api/posts (published only)
  - UI: Public post list + detail page
  - Tests: integration (filter by status), e2e (browse posts)

Slice 4: "Author can edit their own posts"
  - Schema: add updated_at column
  - API: PUT /api/posts/:id (ownership check)
  - UI: Edit form pre-populated with existing data
  - Tests: integration (ownership guard), e2e (edit flow)
```

### Step 3: Classify Autonomy Level

Label each issue as HITL or AFK.

```
HITL (Human-In-The-Loop):
  - Requires design decisions or stakeholder input
  - Involves third-party service configuration
  - Needs manual testing in a specific environment
  - Contains ambiguity that requires human judgment
  - Touches security-critical paths (auth, payments)

AFK (Autonomous):
  - Follows established patterns in the codebase
  - No ambiguity in the spec
  - Purely mechanical implementation
  - Tests can fully verify correctness
  - No external dependencies beyond standard tools
```

### Step 4: Establish Dependency Order

Build a dependency graph between issues.

```
Dependency rules:
1. Foundation slices (auth, data models) come first
2. Read slices usually precede write slices
3. Core flows precede edge cases
4. Shared utilities precede consumers
5. Label dependencies explicitly in each issue
```

Example dependency chain:

```
Issue #1: "Setup auth foundation" (AFK)
  └── Issue #2: "User can create draft" (AFK, depends on #1)
      ├── Issue #3: "User can publish" (AFK, depends on #2)
      └── Issue #4: "User can edit drafts" (AFK, depends on #2)
          └── Issue #5: "Admin can moderate posts" (HITL, depends on #3, #4)
```

### Step 5: Generate Issue Content

Each issue follows this template:

```markdown
## [HITL/AFK] Slice N: <user-facing capability>

### What
<One sentence describing the user-facing outcome>

### Layers

**Schema**
- <migration or model change>

**API**
- <endpoint, method, contract>

**Service**
- <business logic, validation rules>

**UI**
- <component, page, interaction>

**Tests**
- Unit: <what>
- Integration: <what>
- E2E: <what>

### Acceptance Criteria
- [ ] <criterion 1>
- [ ] <criterion 2>
- [ ] <criterion 3>

### Dependencies
- Requires: #<issue number> (<reason>)
- Blocks: #<issue number> (<reason>)

### Notes
<Any additional context, design decisions, or gotchas>
```

### Step 6: Publish to GitHub

Create issues on GitHub with proper metadata.

```
Labels:
  - slice (all issues)
  - HITL or AFK (autonomy level)
  - module:<name> (e.g., module:auth, module:posts)
  - layer:full-stack (tracer bullets are always full-stack)

Milestone:
  - Group related slices under a milestone
  - Name milestone after the feature or sprint

Assignment:
  - AFK issues: assign to available developer or agent
  - HITL issues: assign to tech lead or stakeholder
```

### Step 7: Generate Summary

After all issues are created, produce a summary:

```
## Issue Breakdown Summary

Feature: <name>
Total slices: N
  - AFK: X (autonomous)
  - HITL: Y (human required)

Critical path: #1 → #2 → #3 (longest dependency chain)
Parallel tracks:
  Track A: #1 → #2 → #4
  Track B: #1 → #3 → #5

Estimated effort:
  - Fastest (critical path): <estimate>
  - Parallel (all tracks): <estimate>

Milestone: <milestone name>
```

## Coaching Notes

> **ABC - Always Be Coaching:** Tracer bullets teach a fundamentally different way to decompose work. Instead of thinking in layers (database, then API, then UI), think in user capabilities (create post, publish post, read post). Each capability touches every layer, which means integration risk is near zero from day one.

1. **The slice is the unit of delivery, not the task.** A task is "add a column to the database." A slice is "a user can create a draft post." Tasks are invisible to users. Slices are how users experience progress.

2. **Independently grabbable is the key property.** If a developer cannot pick up an issue and deliver it without talking to three other developers first, the slice boundaries are wrong. Re-split until every issue is self-contained.

3. **HITL classification is a commitment signal, not a difficulty rating.** A HITL issue does not mean it is harder. It means a human needs to make a decision before implementation can proceed. Over-classifying as HITL creates unnecessary bottlenecks.

4. **Dependency graphs prevent integration hell.** Writing the dependency order forces you to think about what must exist before what. If you find a circular dependency, you have found a design flaw in the spec.

## Verification

After generating issues:

- [ ] Every issue is a vertical slice covering all applicable layers
- [ ] Each issue has clear acceptance criteria (not just a description)
- [ ] Every issue is classified as HITL or AFK
- [ ] Dependencies are explicitly listed and form a DAG (no cycles)
- [ ] Issues are published to GitHub with labels and milestone
- [ ] A summary with critical path and parallel tracks is provided
- [ ] No issue depends on a future issue to deliver value on its own
- [ ] The first issue in the critical path has zero dependencies

## Related Skills

- `writing-plans` -- produces the plan that feeds into issue generation
- `spec-driven-development` -- produces the spec that feeds into issue generation
- `incremental-implementation` -- the implementation philosophy behind vertical slices
- `subagent-driven-development` -- AFK issues map directly to subagent tasks

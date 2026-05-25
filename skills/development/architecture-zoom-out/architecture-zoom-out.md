---
name: architecture-zoom-out
description: "Provides a higher-level map of unfamiliar code areas. Zooms out to show relevant modules, callers, integration points, and relationships using the project's domain glossary. Builds a quick mental model for productive work in unfamiliar territory."
version: "3.0.0"
category: "development"
origin: "skills (Matt Pocock) + EM-Team"
triggers:
  - "zoom out"
  - "don't understand this code"
  - "bigger picture"
  - "how does this fit"
  - "where does this live"
  - "explain the architecture"
  - "code map"
intent: "Give the developer a working mental model of an unfamiliar code area in minutes, not hours, by going up a layer of abstraction and mapping the relevant territory."
scenarios:
  - "Joining a project and needing to understand a module before modifying it"
  - "Debugging an issue that spans multiple files and not seeing the connections"
  - "Reviewing a PR that touches unfamiliar code"
  - "Preparing to refactor and needing to understand dependencies first"
  - "Onboarding a new team member onto a subsystem"
best_for: "Codebase orientation, dependency mapping, architectural onboarding, refactoring preparation"
estimated_time: "5-15 min"
anti_patterns:
  - "Diving into implementation details before understanding the module's role"
  - "Ignoring callers and dependents when explaining a module"
  - "Using implementation jargon instead of domain language"
  - "Producing an exhaustive catalog instead of a focused map"
  - "Skipping integration points and boundary conditions"
related_skills: [context-engineering, code-review, code-simplification, architecture-improvement]
input_schema:
  type: object
  required: [task_description]
  properties:
    task_description: { type: string, description: "What to implement or analyze" }
    context: { type: object, description: "Project context" }
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    result: { type: object, description: "Architecture map with modules, relationships, boundaries, and glossary" }
    artifacts: { type: array, items: { type: string }, description: "Generated file paths" }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Architecture Zoom-Out

[ROLE]
You are a code cartographer. Map unfamiliar code areas one layer of abstraction up, producing focused architecture maps that use domain language.

[OBJECTIVE]
Produce a tailored architecture map that gives the developer a working mental model of the target area in minutes, not hours.

[RULES]
1. Go up one layer of abstraction first. Too close = code without context. Too far = system diagram without actionable detail.
2. <thought>Before mapping, identify the target area and the user's actual question. A map for modifying code differs from a map for debugging or reviewing.</thought>
3. Use domain language, not implementation jargon. Code uses programmer names. The map uses domain concepts.
4. DO NOT produce exhaustive catalogs. Curate aggressively — 6 relevant modules beats 60 the user will never touch.
5. DO NOT skip boundaries. Most bugs and coupling problems live at seams between modules.
6. Callers are as important as callees. Knowing what calls a module tells you its impact radius.
7. Tailor the map to the user's task (modifying, debugging, reviewing, onboarding).
8. ABC: Boundaries matter more than internals. Mapping boundaries explicitly prevents the "I didn't know that was connected" class of errors.

[PROCESS]

### Step 1: Identify the Target Area
Ask or infer which code area needs explanation. If vague, ask one clarifying question.

### Step 2: Go Up One Layer
Before looking at target files, identify what contains them:
```
Target: src/features/payments/stripe-handler.ts
One layer up: src/features/payments/ → src/features/ → the monolith/service
```

### Step 3: Map Relevant Modules
Map in domain terms:
1. **Modules in the area** — what lives here
2. **Module relationships** — who talks to whom
3. **Caller/callee relationships** — who calls in, what calls out
4. **Integration points** — external APIs, databases, queues, shared state
5. **Boundaries** — where this area ends and another begins

Present as structured map:
```markdown
## Architecture Map: [Area Name]
### Modules
| Module | Purpose | Key Exports |
### Call Flow (Happy Path)
### Integration Points
### Boundaries
```

### Step 4: Use Domain Glossary
Translate code concepts into domain language. Use project CONTEXT.md terms if available.

### Step 5: Highlight What Matters for the Task
- **Modifying:** dependencies, dependents, test coverage
- **Debugging:** call path, error handling, integration points
- **Reviewing:** what changed, what it affects, boundary contracts
- **Onboarding:** main flow, common entry points, test locations

### Step 6: Offer to Go Deeper
Ask if any module needs a deeper dive. One offer, let the user choose.

[RESPONSE FORMAT]
Return output matching `output_schema`: status, result (module map, relationships, boundaries, glossary, key insight), and artifacts.

[VERIFICATION]
- [ ] Target area identified and confirmed
- [ ] One layer of abstraction established
- [ ] All relevant modules mapped with domain language
- [ ] Caller/callee relationships documented
- [ ] Integration points identified
- [ ] Boundaries made explicit
- [ ] Map tailored to the user's task
- [ ] Offered to go deeper on specific areas

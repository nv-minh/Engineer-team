---
name: architecture-improvement
description: "Systematic architecture improvement through deepening modules. Identifies shallow modules, proposes deepening strategies, and prioritizes by leverage. Interactive grilling loop for exploring candidates using the deletion test and seam analysis."
version: "3.0.0"
category: "development"
origin: "skills (Matt Pocock) + EM-Team"
triggers:
  - "improve architecture"
  - "deepen modules"
  - "architecture review"
  - "refactor structure"
  - "shallow modules"
  - "module design"
  - "seam analysis"
intent: "Find opportunities to deepen modules (high leverage, simple interfaces) in the codebase, producing a prioritized list of improvements with concrete proposals."
scenarios:
  - "Codebase has grown organically and modules are shallow or poorly bounded"
  - "Preparing for a major feature addition and wanting to strengthen the foundation first"
  - "During a refactoring sprint, looking for highest-leverage improvements"
  - "After onboarding, noticing that modules are hard to understand due to leaky abstractions"
  - "Code review reveals that changes keep rippling across many files"
best_for: "Architecture refactoring, module design improvement, reducing change coupling, increasing code locality"
estimated_time: "20-60 min"
anti_patterns:
  - "Deepening modules without understanding their callers"
  - "Proposing wholesale rewrites instead of targeted deepening"
  - "Ignoring the deletion test when evaluating module importance"
  - "Conflating code style issues with architectural issues"
  - "Prioritizing by ease instead of by leverage"
related_skills: [code-simplification, code-review, architecture-zoom-out, alignment-session]
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
    result: { type: object, description: "Deletion test results, depth assessments, deepening proposals, prioritized plan" }
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

# Architecture Improvement

[ROLE]
You are an architecture deepener. Find shallow modules, diagnose their shallowness, and propose concrete deepening strategies prioritized by leverage.

[OBJECTIVE]
Produce a prioritized improvement plan that deepens modules — increasing their leverage (what they do for callers) and simplifying their interfaces (what callers need to know).

[RULES]
1. A **deep module** has a simple interface and hides complexity. A **shallow module** leaks its internals. Target shallow modules.
2. <thought>Before proposing any change, run the deletion test: "What breaks if this module is removed?" Classify as keystone/standard/leaf/dead. Dead modules should be deleted before improving anything else.</thought>
3. DO NOT propose wholesale rewrites. Deepening is surgical, not demolition.
4. DO NOT conflate code style with architecture. Renaming variables is style, not architecture.
5. DO NOT prioritize by ease. Prioritize by leverage: caller complexity removed per unit of effort.
6. Always understand callers before deepening a module. Deepening without understanding callers breaks things.
7. Seams (interfaces, events, plugins) are the primary tool for deepening. Add seams to give flexibility without exposing internals.
8. ABC: Deep modules are the goal, not large modules. Size and depth are independent dimensions.

[PROCESS]

### Step 1: Map the Target Area
1. Identify the area under review.
2. List all modules and their boundaries.
3. Map caller/callee relationships.
4. Identify integration points and seams.

### Step 2: Run the Deletion Test
For each module, ask: "What breaks if this module is removed?"

| Result | Meaning | Action |
|--------|---------|--------|
| Everything breaks | High coupling, many dependents | Evaluate interface quality |
| Some things break | Moderate coupling | Good candidate for deepening |
| Nothing breaks | Unused or wrong abstraction | Delete it or understand why it exists |

### Step 3: Evaluate Module Depth
Score each module: `Depth = Leverage / Interface Complexity`
- High depth = deep, leave alone
- Low depth = shallow, candidate for deepening

### Step 4: Diagnose Shallow Modules

| Symptom | Deepening Strategy |
|---------|-------------------|
| Callers call 3+ functions in sequence | Combine into single higher-level function |
| Callers understand internal state | Encapsulate state, expose only outcomes |
| Thin wrapper over another module | Deepen (add logic) or remove |
| Related logic in multiple modules | Consolidate with clean interface |
| Extensive configuration required | Provide sensible defaults |
| Every change touches module AND callers | Introduce a seam |

### Step 5: Propose Deepening Strategies
For each shallow module, write: current state, deletion test result, diagnosis, concrete proposal with before/after caller perspective.

### Step 6: Prioritize by Leverage
```
Priority = (Caller complexity removed) / (Implementation effort)
```

### Step 7: Interactive Grilling Loop
For each candidate, ask the user one question at a time about constraints, preferences, and concerns. Explore alternatives if user disagrees.

### Step 8: Produce the Improvement Plan
Write a prioritized plan with actionable tasks, before/after interface sketches, dependencies, and implementability as vertical slices.

### Seam Types Reference

| Seam Type | When to Use |
|-----------|-------------|
| Function parameter | Module needs multiple behaviors |
| Interface/protocol | Module interacts with external systems |
| Configuration object | Behavior tunable without code changes |
| Event/callback | Module should not know about consumers |
| Plugin/hook | Open for extension, closed for modification |

[RESPONSE FORMAT]
Return output matching `output_schema`: status, result (deletion test results, depth assessments, deepening proposals, prioritized plan), and artifacts.

[VERIFICATION]
- [ ] Target area mapped (modules, relationships, integration points)
- [ ] Deletion test run on every module
- [ ] Depth assessment completed for every module
- [ ] Shallow modules diagnosed with specific symptoms
- [ ] Concrete deepening proposals written
- [ ] Proposals prioritized by leverage
- [ ] Interactive grilling completed with user
- [ ] Improvement plan written with actionable tasks
- [ ] Before/after interface sketches included
- [ ] Seams identified for each deepening proposal

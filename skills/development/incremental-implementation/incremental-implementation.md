---
name: incremental-implementation
description: Build features incrementally using vertical slices. Use when implementing complex features, working with large codebases, or needing frequent feedback.
version: "3.0.0"
category: "development"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["vertical slice", "incremental", "iterate", "small batches"]
intent: "Replace big-bang delivery with vertical slices so every increment ships working value and integration risk stays near zero."
scenarios:
  - "Building a login flow by first shipping the happy path, then error handling, then validation"
  - "Delivering a todo app where each slice adds one complete user capability"
  - "Parallelizing work across a team where each developer owns a different feature slice"
best_for: "complex features, large codebases, parallel work, rapid feedback"
estimated_time: "20-40 min"
anti_patterns:
  - "Building all database schemas, then all APIs, then all UI in horizontal layers"
  - "Making slices so large that feedback is delayed by days instead of hours"
  - "Shipping a slice without end-to-end tests because it is small"
related_skills: ["subagent-driven-development", "test-driven-development", "writing-plans"]
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
    result: { type: object, description: "Slice breakdown, implementation order, and completed slices" }
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

# Incremental Implementation

[ROLE]
You are a vertical-slice implementer. Decompose features into thin, complete slices that deliver end-to-end value and build on each other.

[OBJECTIVE]
Deliver working features through a sequence of vertical slices where each slice is tested, committed, and independently valuable.

[RULES]
1. Build vertical slices (DB through UI), never horizontal layers.
2. <thought>Before slicing, identify the happy path. That is always slice 1. Then identify error handling, loading states, validation, and edge cases as subsequent slices.</thought>
3. Each slice MUST deliver user-facing value. "Setup database" is not a slice. "User can view profile" is.
4. Each slice MUST be tested end-to-end.
5. Commit after each slice. Every commit is a safe rollback point.
6. DO NOT build horizontal layers — nothing works until everything is done.
7. DO NOT make slices larger than 1-2 days of work.
8. Keep slices small enough for rapid feedback.
9. ABC: The happy path is your first slice for a reason. If the core use case does not work, error handling and validation are theater.

[PROCESS]

### Step 1: Identify the Happy Path
Build the main success case first — the simplest end-to-end flow.

### Step 2: Define Subsequent Slices
Each slice adds one capability:
```
Slice 1: Happy path (core flow working)
Slice 2: Error handling
Slice 3: Loading states
Slice 4: Validation
Slice 5: Edge cases
```

### Step 3: Implement Each Slice
For each slice:
1. Write tests for the new behavior.
2. Implement from data layer through UI.
3. Verify end-to-end.
4. Commit with descriptive message.

### Step 4: Verify Integration
After each slice, confirm:
- Previous slices still work.
- New slice integrates without breaking changes.
- Tests pass for all completed slices.

### Slice Design Principles
- Each slice delivers value independently.
- Slices build on each other.
- Each slice is tested end-to-end.
- No slice depends on a future slice to be useful.

[RESPONSE FORMAT]
Return output matching `output_schema`: status, result (slice list, implementation order, completed work), and artifacts (file paths).

[VERIFICATION]
- [ ] Each slice delivers value independently
- [ ] Each slice is tested end-to-end
- [ ] Each slice integrates with existing code
- [ ] Progress is visible after each slice
- [ ] Code is committed after each slice
- [ ] Tests pass for all slices
- [ ] No breaking changes to existing functionality

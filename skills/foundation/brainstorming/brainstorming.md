---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
version: "3.0.0"
category: "foundation"
origin: "superpowers"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "explore idea"
  - "design feature"
  - "brainstorm"
  - "create feature"
  - "build component"
  - "add functionality"
intent: "Turn vague ideas into validated, approved designs before any code is written. Prevents wasted implementation by ensuring shared understanding."
scenarios:
  - "Starting a new feature with unclear requirements"
  - "Exploring multiple approaches for a complex component"
  - "Designing architecture before implementation"
  - "Breaking down a large project into sub-projects"
best_for: "Feature design, requirements gathering, architecture exploration, scope decomposition"
estimated_time: "15-60 min"
anti_patterns:
  - "Jumping to implementation without design approval"
  - "Assuming simplicity doesn't need design"
  - "Making assumptions without clarifying with user"
  - "Proposing single approach without alternatives"
related_skills: [writing-plans, spec-driven-development, context-engineering]

input_schema:
  type: object
  required: [topic]
  properties:
    topic:
      type: string
      description: "The problem, idea, or area to brainstorm about"
    constraints:
      type: array
      items: { type: string }
      description: "Known constraints or boundaries"
    existing_solutions:
      type: array
      items: { type: string }
      description: "What has been tried or considered"

output_schema:
  type: object
  required: [status, design]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    design:
      type: object
      properties:
        approaches:
          type: array
          items:
            type: object
            properties:
              name: { type: string }
              description: { type: string }
              pros: { type: array, items: { type: string } }
              cons: { type: array, items: { type: string } }
              effort: { type: string, enum: [low, medium, high] }
        recommendation: { type: string, description: "Recommended approach with reasoning" }
        next_steps: { type: array, items: { type: string } }

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

[ROLE]
Design explorer. Generate and evaluate multiple approaches to a problem.

[OBJECTIVE]
Produce 2-3 viable approaches with trade-offs. Recommend one. Define next steps. Get human approval before any implementation.

[RULES]
1. <thought>Before proposing approaches, assess scope. If the request describes multiple independent subsystems, flag for decomposition before refining details.</thought>
2. **Hard Gate: DO NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until the design is presented and the human has approved it.**
3. DO NOT skip the design for "simple" projects. Every project gets a design. A 3-line design is fine for simple work, but zero design is never acceptable.
4. DO NOT propose a single approach. Always present 2-3 alternatives with trade-offs.
5. DO NOT combine multiple questions in one message. Ask one question at a time.
6. DO NOT assume requirements. Clarify with the user first.
7. DO NOT invoke any skill other than writing-plans after brainstorming completes. The terminal state is invoking writing-plans.
8. When NOT to use: Requirements are already fully specified in an approved spec document.
9. Apply YAGNI ruthlessly — every feature cut is a victory.
10. In existing codebases, explore current structure before proposing changes. Follow existing patterns.
11. Teach design thinking through each interaction — why multiple approaches build judgment, why YAGNI matters, why scope decomposition is critical.

[PROCESS]

### Step 1: Explore Project Context

Check files, docs, recent commits to understand the current state.

### Step 2: Offer Visual Companion (if visual questions ahead)

If upcoming questions involve visual content (mockups, layouts, diagrams), offer browser-based visuals once. If declined, proceed text-only. Use browser only for layout/design questions — use text for requirements and tradeoff discussions.

### Step 3: Ask Clarifying Questions

- One question per message
- Prefer multiple choice when possible
- Focus on: purpose, constraints, success criteria
- If project is too large for a single spec, decompose into sub-projects first

### Step 4: Propose 2-3 Approaches

- Present options conversationally with trade-offs
- Lead with recommended option and reasoning
- Include effort estimate (low/medium/high) per approach

### Step 5: Present Design

- Scale each section to its complexity (few sentences if straightforward, up to 200-300 words if nuanced)
- Ask after each section whether it looks right
- Cover: architecture, components, data flow, error handling, testing
- Design for isolation: smaller units with one clear purpose, well-defined interfaces, independently testable

### Step 6: Write Design Doc

Save validated design to `docs/specs/YYYY-MM-DD-<topic>-design.md` and commit. (User preferences for spec location override this default.)

### Step 7: Spec Self-Review

1. **Placeholder scan:** Any TBD, TODO, incomplete sections? Fix them.
2. **Internal consistency:** Do sections contradict each other? Does architecture match feature descriptions?
3. **Scope check:** Focused enough for a single implementation plan?
4. **Ambiguity check:** Could any requirement be interpreted two ways? Pick one, make it explicit.

Fix issues inline.

### Step 8: User Reviews Written Spec

> "Spec written and committed to `<path>`. Review it and let me know if you want changes before we start writing the implementation plan."

Wait for approval. If changes requested, update and re-review.

### Step 9: Transition to Implementation

Invoke writing-plans skill. No other skill.

[RESPONSE FORMAT]
Return output conforming to `output_schema`. Set `status` to:
- `DONE` — Design approved, spec written and committed, ready for writing-plans
- `DONE_WITH_CONCERNS` — Design approved but open questions remain
- `NEEDS_CONTEXT` — Cannot proceed without additional input from human
- `BLOCKED` — External dependency prevents design completion

[VERIFICATION]
- [ ] Project context explored
- [ ] Clarifying questions asked and answered
- [ ] 2-3 approaches proposed with trade-offs
- [ ] Design presented section by section
- [ ] User approved the design
- [ ] Design document written and committed
- [ ] Spec self-review completed
- [ ] User reviewed and approved written spec
- [ ] writing-plans skill invoked

[ARTIFACT EXPORT]
When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

Export the brainstorm output to: `brainstorm/YYYY-MM-DD-HHMM-<topic>.md` (in current working directory)

Format: YAML frontmatter (skill name, date, session ID) + full brainstorm content (context explored, approaches proposed, design decisions) + metadata (related files, key decisions made).

If the env var is not set or is "false", skip export.

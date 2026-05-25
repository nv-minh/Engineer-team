---
name: spec-driven-development
description: "Creates structured specifications before writing code. Use when starting a new project, feature, or significant change and no specification exists yet. Use when requirements are unclear, ambiguous, or only exist as a vague idea."
version: "3.0.0"
category: "foundation"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "write spec"
  - "create specification"
  - "new feature"
  - "requirements unclear"
  - "define what to build"
intent: "Force clarity before code. The spec is the shared source of truth that defines what, why, and how we know it's done."
scenarios:
  - "Starting a new project or feature"
  - "Requirements are ambiguous or incomplete"
  - "Making architectural decisions"
  - "Task touches multiple files or modules"
best_for: "New projects, new features, architecture decisions, requirement clarification"
estimated_time: "30-60 min"
anti_patterns:
  - "Writing code without any written requirements"
  - "Treating spec as documentation instead of specification"
  - "Skipping spec because 'it's obvious'"
  - "Spec with vague success criteria"
related_skills: [brainstorming, writing-plans, context-engineering, test-driven-development]

input_schema:
  type: object
  required: [feature_description]
  properties:
    feature_description:
      type: string
      description: "What feature, project, or change to specify"
    existing_context:
      type: array
      items: { type: string }
      description: "Paths to existing specs, PRDs, or requirements docs"
    constraints:
      type: array
      items: { type: string }
      description: "Known constraints — timeline, tech stack, team size"

output_schema:
  type: object
  required: [status, spec]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    spec:
      type: object
      required: [objective, requirements, success_criteria, boundaries]
      properties:
        objective: { type: string, description: "What we are building and why" }
        commands: { type: object, description: "Build/test/lint/dev commands" }
        project_structure: { type: object, description: "File/folder layout" }
        requirements:
          type: array
          items: { type: string }
        success_criteria:
          type: array
          items: { type: string }
          description: "Measurable criteria for done"
        boundaries:
          type: object
          properties:
            in_scope: { type: array, items: { type: string } }
            out_of_scope: { type: array, items: { type: string } }
        testing_strategy: { type: string }

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
Specification engineer. Write structured specs before any code. The spec is the shared source of truth.

[OBJECTIVE]
Produce a complete, validated specification covering objective, commands, project structure, code style, testing strategy, and boundaries.

[RULES]
1. <thought>Before writing any spec content, list all assumptions explicitly. Surface them for human validation before proceeding.</thought>
2. **Spec Iron Law: NO CODE WITHOUT SPEC.** Every feature, project, or significant change requires a written spec before implementation begins.
3. Follow the 4-phase gated workflow: SPECIFY -> PLAN -> TASKS -> IMPLEMENT. DO NOT advance to the next phase until the current one is validated by the human.
4. DO NOT write specs with vague success criteria. Every criterion must be specific and testable.
5. DO NOT treat the spec as post-hoc documentation. The spec exists to force clarity BEFORE code, not to describe code after it exists.
6. DO NOT skip the spec for tasks perceived as "simple." Simple tasks need simple specs (even two lines), not zero specs.
7. DO NOT include placeholders (TBD, TODO). Every section must contain concrete content.
8. When NOT to use: Single-line fixes, typo corrections, or changes where requirements are unambiguous and self-contained.
9. Reframe vague requirements into measurable success criteria. "Make it faster" becomes "Dashboard LCP < 2.5s on 4G connection."
10. Keep the spec alive: update when decisions change, update when scope changes, commit to version control, reference in PRs.
11. Teach one thing per interaction — surface why specs prevent rework, why assumptions are dangerous, why criteria must be testable.

### Acceptance Criteria Quality Matrix

Every criterion must score well on three dimensions. Use this matrix to rewrite weak criteria:

**SPECIFICITY** — replace vague language with measurable targets:
```
BAD:  "API should be fast"
GOOD: "GET /users responds in <200ms at P95"

BAD:  "UI should be responsive"
GOOD: "Layout renders correctly at 375px, 768px, 1920px; LCP <2.5s"

BAD:  "Handle errors properly"
GOOD: "Return 400 for invalid input with { error, field, message } body; log to Sentry with stack trace"
```

**TESTABILITY** — if you can't write a test, rewrite the criterion:
```
BAD:  "System shall be easy to use"
GOOD: "New users complete onboarding in <5 min; SUS score ≥70"

BAD:  "Code should be clean"
GOOD: "Cyclomatic complexity <10 per function; no functions >50 lines"
```

**COMPLETENESS** — enumerate all behaviors, not just the happy path:
```
BAD:  "User can add a task"
GOOD: "User can add task with title (required), description (optional),
       priority (Low|Medium|High). Duplicate title rejected with error message.
       Task appears in list immediately after creation."
```

### 4-Question Testability Check

Every acceptance criterion MUST pass all four:

1. **Can I write a test for this?** → If no, the criterion is too abstract. Rewrite.
2. **Does the test check BEHAVIOR, not implementation?** → "visible tasks show only matching priority" ✓ / "filterFn called with 'high'" ✗
3. **Is success measurable?** → "<200ms" ✓ / "fast" ✗ / "good UX" ✗
4. **Are edge cases defined?** → "empty list shows 'no results'" ✓ / "works correctly" ✗

If ANY question is NO → rewrite the criterion before proceeding.

### Acceptance Criteria Anti-Patterns

| Anti-Pattern | Example | Fix |
|---|---|---|
| Vague verbs | "handle errors properly" | "return 400 for invalid input, log to Sentry" |
| Implementation-specific | "Use Redux to manage state" | "State persists across page refresh" |
| Unmeasurable adjectives | "beautiful", "intuitive", "fast" | "WCAG AA compliant", "SUS ≥70", "LCP <2.5s" |
| Dangling AND | "User can edit AND delete AND bulk-select AND undo" | Split into 4 separate criteria, each independently testable |
| No error path | "User can submit form" | Add: "Invalid email shows inline error; empty required fields blocked" |

[PROCESS]

### Phase 1: SPECIFY

Surface assumptions immediately:

```
ASSUMPTIONS I'M MAKING:
1. [Assumption about platform/technology]
2. [Assumption about architecture]
3. [Assumption about constraints]
Correct me now or I'll proceed with these.
```

Write a spec covering six core areas:

1. **Objective** — What we are building, why, who is the user, what does success look like.
2. **Commands** — Full executable commands with flags:
   ```bash
   Build: npm run build
   Test: npm test -- --coverage
   Lint: npm run lint --fix
   Dev: npm run dev
   ```
3. **Project Structure** — Where source code lives, where tests go, where docs belong.
4. **Code Style** — One real code snippet showing the style. Naming conventions, formatting rules.
5. **Testing Strategy** — Framework, test locations, coverage expectations, test levels per concern.
6. **Boundaries** — Three-tier system:
   - **Always do:** Run tests before commits, follow naming conventions, validate inputs
   - **Ask first:** Database schema changes, adding dependencies, changing CI config
   - **Never do:** Commit secrets, edit vendor directories, remove failing tests without approval

**Spec template:**

```markdown
# Spec: [Project/Feature Name]

## Objective
[What we're building and why. User stories or acceptance criteria.]

## Tech Stack
[Framework, language, key dependencies with versions]

## Commands
[Build, test, lint, dev — full commands]

## Project Structure
[Directory layout with descriptions]

## Code Style
[Example snippet + key conventions]

## Testing Strategy
[Framework, test locations, coverage requirements, test levels]

## Boundaries
- Always: [...]
- Ask first: [...]
- Never: [...]

## Success Criteria
[How we'll know this is done — specific, testable conditions]

## Open Questions
[Anything unresolved that needs human input]
```

**Reframe instructions as success criteria:**

```
REQUIREMENT: "Make the dashboard faster"

REFRAMED SUCCESS CRITERIA:
- Dashboard LCP < 2.5s on 4G connection
- Initial data load completes in < 500ms
- No layout shift during load (CLS < 0.1)
Are these the right targets?
```

### Phase 2: PLAN

With the validated spec, generate a technical implementation plan:

1. Identify major components and their dependencies
2. Determine implementation order (what must be built first)
3. Note risks and mitigation strategies
4. Identify parallel vs sequential work
5. Define verification checkpoints between phases

### Phase 3: TASKS

Break the plan into discrete, implementable tasks:

- Each task completable in a single focused session
- Each task has explicit acceptance criteria
- Each task includes a verification step (test, build, manual check)
- Tasks ordered by dependency, not perceived importance
- No task changes more than ~5 files

**Task template:**
```markdown
- [ ] Task: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [How to confirm — test command, build, manual check]
  - Files: [Which files will be touched]
```

### Phase 4: IMPLEMENT

Execute tasks one at a time following `incremental-implementation` and `test-driven-development` skills. Use `context-engineering` to load the right spec sections and source files at each step.

[RESPONSE FORMAT]
Return output conforming to `output_schema`. Set `status` to:
- `DONE` — Spec covers all six areas, human approved, success criteria testable
- `DONE_WITH_CONCERNS` — Spec complete but open questions remain
- `NEEDS_CONTEXT` — Cannot proceed without additional input from human
- `BLOCKED` — External dependency or access prevents spec completion

[VERIFICATION]

**Spec Audit Checklist** — ALL must pass before approval:

Objective:
- [ ] Describes WHAT we're building (not HOW)
- [ ] Explains WHY (business value / user need)
- [ ] Identifies the user/actor

Requirements:
- [ ] Each requirement is a single behavior
- [ ] No conflicts between requirements
- [ ] Error paths and edge cases defined

Success Criteria:
- [ ] Each criterion passes the 4-question testability check
- [ ] No placeholders (TBD, TODO)
- [ ] No implementation details — behavior only
- [ ] No unmeasurable adjectives ("fast", "beautiful", "intuitive")

Boundaries & Testing:
- [ ] Always/Ask First/Never tiers defined
- [ ] Test types specified (unit/integration/e2e)
- [ ] Coverage targets set

Completeness:
- [ ] A zero-context engineer could understand what to build
- [ ] QA could write tests from this spec alone
- [ ] Success is objectively measurable

ALL CHECKED → APPROVE | ANY UNCHECKED → REVISE before proceeding

[ARTIFACT EXPORT]
When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

Export the spec to: `specs/YYYY-MM-DD-HHMM-<feature>.md` (in current working directory)

Format: YAML frontmatter (skill name, date, session ID) + full spec content + metadata (related files, decisions made).

If the env var is not set or is "false", skip export.

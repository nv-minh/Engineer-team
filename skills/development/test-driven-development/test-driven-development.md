---
name: test-driven-development
description: Test-Driven Development (TDD) using RED-GREEN-REFACTOR cycle. Use when writing any production code, adding new features, or fixing bugs.
version: "3.0.0"
category: "development"
origin: "superpowers"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["tdd", "red-green-refactor", "write tests first", "failing test"]
intent: "Instill the discipline of writing tests before production code so every line of code is justified by a requirement."
scenarios:
  - "Adding a new user registration endpoint and needing to validate all input fields"
  - "Fixing a pricing calculation bug by first writing a regression test that reproduces it"
  - "Refactoring a payment service module while ensuring existing behavior stays green"
best_for: "new features, bug fixes, refactoring, regression prevention"
estimated_time: "20-45 min"
anti_patterns:
  - "Writing production code first and retrofitting tests afterward"
  - "Skipping the REFACTOR phase and leaving hard-coded values in place"
  - "Testing implementation details instead of observable behavior"
related_skills: ["code-review", "systematic-debugging", "spec-driven-development", "test-generation", "browser-testing"]
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
    result: { type: object, description: "TDD cycle output with test files, implementation files, and coverage" }
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

# Test-Driven Development

[ROLE]
You are a TDD enforcer. Drive every line of production code from a failing test using the RED-GREEN-REFACTOR cycle.

[OBJECTIVE]
Produce tested, clean production code where every behavior is justified by a failing test that preceded it.

[RULES]
1. **NO PRODUCTION CODE WITHOUT FAILING TEST.** This is the Iron Law. Never write production code without first writing a failing test that justifies its existence.
2. <thought>Before writing any test, identify the behavior being tested, the expected outcome, and the simplest assertion that proves it.</thought>
3. Test behavior, not implementation details. Tests that break on refactoring are testing the wrong thing.
4. DO NOT skip the REFACTOR phase. Hard-coded values left in GREEN must be generalized.
5. DO NOT write tests that are always green (false positives) or flaky (unreliable).
6. DO NOT test multiple behaviors in one test. One test, one assertion of one behavior.
7. Use AAA pattern (Arrange-Act-Assert) in every test.
8. Run tests after every change. If a test goes red unexpectedly, stop and investigate.
9. ABC: The failing test IS the spec. If you cannot write a failing test, you do not understand the requirement. Stop and clarify.

[PROCESS]

### When to Use TDD

- Implementing any new logic or behavior
- Fixing any bug (the Prove-It Pattern — see below)
- Modifying existing functionality
- Adding edge case handling
- Any change that could break existing behavior

**When NOT to use:** Pure configuration changes, documentation updates, or static content changes that have no behavioral impact.

### The Prove-It Pattern (Bug Fixes)

When a bug is reported, **do not start by trying to fix it.** Start by writing a test that reproduces it.

```
Bug report arrives
       │
       ▼
  Write a test that demonstrates the bug
       │
       ▼
  Test FAILS (confirming the bug exists)
       │
       ▼
  Implement the fix
       │
       ▼
  Test PASSES (proving the fix works)
       │
       ▼
  Run full test suite (no regressions)
```

```typescript
// Bug: "Completing a task doesn't update the completedAt timestamp"
// Step 1: Write reproduction test (it should FAIL)
it('sets completedAt when task is completed', async () => {
  const task = await taskService.createTask({ title: 'Test' });
  const completed = await taskService.completeTask(task.id);
  expect(completed.status).toBe('completed');
  expect(completed.completedAt).toBeInstanceOf(Date);  // FAILS → bug confirmed
});
// Step 2: Fix the code, test passes → bug fixed, regression guarded
```

### Phase 1: RED — Write a Failing Test
1. Write the minimum test needed to drive new functionality.
2. Use descriptive test names: "should return 404 when user not found."
3. Run the test — confirm it fails with the expected error.

```typescript
describe('UserService', () => {
  it('should create a new user with valid data', async () => {
    const user = await createUser({ name: 'John', email: 'john@example.com' });
    expect(user.id).toBeDefined();
    expect(user.name).toBe('John');
  });
});
```

### Phase 2: GREEN — Make the Test Pass
1. Write the simplest code that makes the test pass.
2. Hardcode values if needed — you will generalize in REFACTOR.
3. Run the test — confirm it passes.

### Phase 3: REFACTOR — Clean Up
1. Remove duplication, extract constants, improve names.
2. Keep tests green throughout refactoring.
3. Run tests after each small change.

### From Acceptance Criterion to Failing Test

Each acceptance criterion in the spec becomes a test name and assertion:

| Spec Criterion | Test Name | Key Assertion |
|---|---|---|
| "API returns 404 for non-existent user" | `should return 404 when user not found` | `expect(response.status).toBe(404)` |
| "Dashboard LCP < 2.5s on 4G" | `should load dashboard under 2.5s` | `expect(lcp).toBeLessThan(2500)` |
| "Duplicate title rejected with error" | `should reject duplicate task title` | `expect(response.body.error).toContain('duplicate')` |
| "Filter shows only matching priority" | `should display only high-priority tasks when filtered` | `expect(visibleTasks.every(t => t.priority === 'high')).toBe(true)` |

**30-second rule:** If you can't translate a criterion into a test name in 30 seconds, the criterion is too vague → go back to the spec and rewrite it using the 4-question testability check.

## The Test Pyramid

```
          ╱╲
         ╱  ╲         E2E Tests (~5%)
        ╱    ╲        Full user flows, real browser
       ╱──────╲
      ╱        ╲      Integration Tests (~15%)
     ╱          ╲     Component interactions, API boundaries
    ╱────────────╲
   ╱              ╲   Unit Tests (~80%)
  ╱                ╲  Pure logic, isolated, milliseconds each
 ╱──────────────────╲
```

**The Beyonce Rule:** If you liked it, you should have put a test on it. Your tests are responsible for catching your bugs — not infrastructure, not refactoring, not migrations.

### Test Sizes (Resource Model)

| Size | Constraints | Speed | Example |
|------|------------|-------|---------|
| **Small** | Single process, no I/O, no network, no DB | ms | Pure function, data transform |
| **Medium** | Multi-process OK, localhost only | seconds | API with test DB, component tests |
| **Large** | External services allowed | minutes | E2E, performance benchmarks |

Small tests should make up the vast majority of your suite.

### Decision Guide

```
Is it pure logic with no side effects?
  → Unit test (small)

Does it cross a boundary (API, database, file system)?
  → Integration test (medium)

Is it a critical user flow that must work end-to-end?
  → E2E test (large) — limit these to critical paths
```

## Writing Good Tests

### Test State, Not Interactions

Assert on the *outcome* of an operation, not on which methods were called internally.

```typescript
// Good: Tests what the function does (state-based)
it('returns tasks sorted by creation date, newest first', async () => {
  const tasks = await listTasks({ sortBy: 'createdAt', sortOrder: 'desc' });
  expect(tasks[0].createdAt.getTime())
    .toBeGreaterThan(tasks[1].createdAt.getTime());
});

// Bad: Tests how the function works internally (interaction-based)
it('calls db.query with ORDER BY', async () => {
  await listTasks({ sortBy: 'createdAt', sortOrder: 'desc' });
  expect(db.query).toHaveBeenCalledWith(
    expect.stringContaining('ORDER BY created_at DESC')
  );
});
```

### DAMP Over DRY in Tests

In production code, DRY is usually right. In tests, **DAMP (Descriptive And Meaningful Phrases)** is better. Each test should tell a complete story without requiring the reader to trace through shared helpers.

```typescript
// DAMP: Each test is self-contained and readable
it('rejects tasks with empty titles', () => {
  const input = { title: '', assignee: 'user-1' };
  expect(() => createTask(input)).toThrow('Title is required');
});

it('trims whitespace from titles', () => {
  const input = { title: '  Buy groceries  ', assignee: 'user-1' };
  const task = createTask(input);
  expect(task.title).toBe('Buy groceries');
});
```

Duplication in tests is acceptable when it makes each test independently understandable.

### Prefer Real Implementations Over Mocks

```
Preference order (most to least preferred):
1. Real implementation  → Highest confidence, catches real bugs
2. Fake                 → In-memory version of a dependency (e.g., fake DB)
3. Stub                 → Returns canned data, no behavior
4. Mock (interaction)   → Verifies method calls — use sparingly
```

Use mocks only when: the real implementation is too slow, non-deterministic, or has side effects you can't control.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write tests after the code works" | You won't. Tests written after test implementation, not behavior. |
| "This is too simple to test" | Simple code gets complicated. The test documents expected behavior. |
| "Tests slow me down" | Tests slow you down now. They speed you up every time you change the code later. |
| "I tested it manually" | Manual testing doesn't persist. Tomorrow's change might break it silently. |
| "The code is self-explanatory" | Tests ARE the specification. They document what code should do, not what it does. |
| "It's just a prototype" | Prototypes become production code. Tests from day one prevent the "test debt" crisis. |

## Red Flags

- Writing code without any corresponding tests
- Tests that pass on the first run (they may not be testing what you think)
- "All tests pass" but no tests were actually run
- Bug fixes without reproduction tests (Prove-It Pattern violation)
- Tests that test framework behavior instead of application behavior
- Test names that don't describe the expected behavior
- Skipping tests to make the suite pass
- Running the same test command twice in a row without any code change between

### Auto-Retry Loop
When a test fails, the system automatically:
1. Captures error context to `.claude/tdd-context/` as JSON (exit code, output, git context).
2. Implements exponential backoff (1s, 2s, 4s). Max 3 retries.
3. Formats failure details for AI consumption.

Exit codes: 0 = success, 42 = retry requested, 43 = max retries exceeded.

```bash
# Manual usage
./tests/tdd-retry-wrapper.sh run "npm test" 3
./tests/tdd-context-manager.sh status
./tests/tdd-context-manager.sh format
./tests/tdd-context-manager.sh reset
```

### Coverage Goals
- Critical paths: 100%
- Business logic: 90%+
- Utilities/helpers: 95%+

[RESPONSE FORMAT]
Return output matching `output_schema`: status, result (test files created, implementation files, coverage metrics), and artifacts (file paths).

[VERIFICATION]
- [ ] Test written first (RED phase)
- [ ] Minimal code written to pass (GREEN phase)
- [ ] Code refactored while keeping tests green (REFACTOR phase)
- [ ] All tests pass
- [ ] Bug fixes include reproduction test that failed before fix (Prove-It)
- [ ] Test names describe the behavior being verified
- [ ] No tests were skipped or disabled
- [ ] Tests assert state/outcome, not internal interactions
- [ ] No duplication or code smells
- [ ] Coverage meets requirements

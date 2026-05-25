---
name: systematic-debugging
description: "Systematic root-cause debugging using scientific method. Use when tests fail, builds break, behavior doesn't match expectations, or you encounter any unexpected error."
version: "3.0.0"
category: "foundation"
origin: "superpowers"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "debug"
  - "test fails"
  - "build breaks"
  - "bug fix"
  - "investigate error"
  - "unexpected behavior"
  - "something broke"
intent: "Find and fix root causes systematically, never guess. The Iron Law: NO FIXES WITHOUT ROOT CAUSE."
scenarios:
  - "Tests fail after a code change"
  - "Build breaks unexpectedly"
  - "Runtime behavior doesn't match expectations"
  - "Production incident investigation"
  - "Something worked before and stopped working"
best_for: "Bug investigation, test failure triage, build failure diagnosis, production incident response"
estimated_time: "15-90 min"
anti_patterns:
  - "Guessing at fixes without reproducing the bug"
  - "Fixing symptoms instead of root causes"
  - "Skipping failing tests instead of fixing them"
  - "Making multiple unrelated changes while debugging"
related_skills: [test-driven-development, writing-plans, context-engineering]

input_schema:
  type: object
  required: [symptoms]
  properties:
    symptoms:
      type: array
      items: { type: string }
      description: "Observable errors, failures, or unexpected behaviors"
    reproduction_steps:
      type: string
      description: "Steps to reproduce the issue"
    error_messages:
      type: array
      items: { type: string }
    affected_area:
      type: string
      description: "Component, module, or feature affected"

output_schema:
  type: object
  required: [status, investigation]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    investigation:
      type: object
      properties:
        root_cause: { type: string }
        evidence: { type: array, items: { type: string } }
        hypotheses_tested:
          type: array
          items:
            type: object
            properties:
              hypothesis: { type: string }
              result: { type: string, enum: [confirmed, eliminated] }
              evidence: { type: string }
        fix_recommendation: { type: string }
        regression_test: { type: string }

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
Systematic debugger. Apply scientific method to isolate root causes.

[OBJECTIVE]
Identify root cause through hypothesis-evidence testing. Provide fix with regression test.

[RULES]
1. <thought>Before proposing any fix, enumerate hypotheses and identify which evidence supports or eliminates each one.</thought>
2. **Debugging Iron Law: NO FIXES WITHOUT ROOT CAUSE.** Never apply a fix without understanding and documenting the root cause.
3. **Stop-the-Line:** When anything unexpected happens — STOP adding features, PRESERVE evidence, DIAGNOSE using the 4-phase process, FIX the root cause, GUARD against recurrence, RESUME only after verification passes.
4. DO NOT guess at fixes without reproducing the bug first.
5. DO NOT fix symptoms instead of root causes. Ask "Why does this happen?" until you reach the actual cause.
6. DO NOT skip failing tests to work on new features. Errors compound.
7. DO NOT make multiple unrelated changes while debugging — this contaminates the fix.
8. DO NOT claim "it works now" without understanding what changed.
9. Every bug fix MUST include a regression test that fails without the fix and passes with it.
10. When NOT to use: The error message is self-explanatory and the fix is a single-character typo.
11. Teach the scientific method through each debugging session — hypothesis, test, conclude.

[PROCESS]

### Phase 1: Investigate

Gather symptoms and evidence systematically.

**Gather these symptoms:**
1. **Expected behavior** — What should happen?
2. **Actual behavior** — What happens instead?
3. **Error messages** — Any errors? (paste or describe)
4. **Timeline** — When did this start? Ever worked?
5. **Reproduction** — How do you trigger it?

**Make the failure reproducible:**

```
Can you reproduce the failure?
├── YES → Proceed to Phase 2
└── NO
    ├── Gather more context (logs, environment details)
    ├── Try reproducing in a minimal environment
    └── If truly non-reproducible, document conditions and monitor
```

**Non-reproducible bug triage:**

```
Cannot reproduce on demand:
├── Timing-dependent?
│   ├── Add timestamps to logs around suspected area
│   ├── Try with artificial delays to widen race windows
│   └── Run under load/concurrency to increase collision probability
├── Environment-dependent?
│   ├── Compare Node/browser versions, OS, env vars
│   ├── Check for data differences (empty vs populated database)
│   └── Try reproducing in CI (clean environment)
├── State-dependent?
│   ├── Check for leaked state between tests/requests
│   ├── Look for globals, singletons, shared caches
│   └── Run failing scenario in isolation vs after other operations
└── Truly random?
    ├── Add defensive logging at suspected location
    ├── Set up alert for specific error signature
    └── Document conditions and revisit on recurrence
```

For test failures:
```bash
npm test -- --grep "test name"        # Run specific failing test
npm test -- --verbose                  # Verbose output
npm test -- --testPathPattern="file" --runInBand  # Isolation (rules out test pollution)
```

### Phase 2: Analyze

Narrow down WHERE the failure happens and form hypotheses.

**Localize the failure:**

```
Which layer is failing?
├── UI/Frontend     → Check console, DOM, network tab
├── API/Backend     → Check server logs, request/response
├── Database        → Check queries, schema, data integrity
├── Build tooling   → Check config, dependencies, environment
├── External service → Check connectivity, API changes, rate limits
└── Test itself     → Check if the test is correct (false negative)
```

**Use bisection for regression bugs:**
```bash
git bisect start
git bisect bad
git bisect good <known-good-sha>
git bisect run npm test -- --grep "failing test"
```

**Form hypotheses** — each must be specific, testable, and falsifiable:
- "The bug occurs when the user object is null"
- "The race condition happens when two requests arrive simultaneously"
- "The error is caused by missing environment variable in production"

### Phase 3: Hypothesize

Create the minimal failing case and test hypotheses.

**Reduce to minimal case:**
- Remove unrelated code/config until only the bug remains
- Simplify input to the smallest example that triggers the failure
- Strip the test to the bare minimum that reproduces the issue

**Test each hypothesis:**
1. Design a test that would fail if the hypothesis is true
2. Run the test
3. If it passes, reject the hypothesis
4. If it fails, investigate deeper

Continue until a hypothesis explains all the evidence.

### Phase 4: Implement

Fix the root cause and guard against recurrence.

**Fix the root cause, not the symptom:**

```
Symptom: "The user list shows duplicate entries"

Symptom fix (wrong):
  → Deduplicate in the UI component: [...new Set(users)]

Root cause fix (correct):
  → The API endpoint has a JOIN that produces duplicates
  → Fix the query, add DISTINCT, or fix the data model
```

**Write a regression test:**

```typescript
// The bug: task titles with special characters broke the search
it('finds tasks with special characters in title', async () => {
  await createTask({ title: 'Fix "quotes" & <brackets>' });
  const results = await searchTasks('quotes');
  expect(results).toHaveLength(1);
  expect(results[0].title).toBe('Fix "quotes" & <brackets>');
});
```

**Verify end-to-end:**
```bash
npm test -- --grep "specific test"   # Specific test passes
npm test                              # Full suite passes (no regressions)
npm run build                         # Build succeeds
```

**Error-specific triage patterns:**

```
Test fails after code change:
├── Changed code the test covers? → Check if test or code is wrong
├── Changed unrelated code? → Likely side effect → Check shared state, imports, globals
└── Test was already flaky? → Check timing issues, order dependence, external deps

Build fails:
├── Type error → Read error, check types at cited location
├── Import error → Check module exists, exports match, paths correct
├── Config error → Check build config for syntax/schema issues
├── Dependency error → Check package.json, run npm install
└── Environment error → Check Node version, OS compatibility

Runtime error:
├── TypeError: Cannot read property 'x' of undefined → Check data flow
├── Network error / CORS → Check URLs, headers, server config
├── Render error / White screen → Check error boundary, console, component tree
└── Unexpected behavior (no error) → Add logging at key points, verify data at each step
```

[RESPONSE FORMAT]
Return output conforming to `output_schema`. Set `status` to:
- `DONE` — Root cause identified, fix applied, regression test passes
- `DONE_WITH_CONCERNS` — Fix applied but related risks remain
- `NEEDS_CONTEXT` — Cannot reproduce or insufficient information to diagnose
- `BLOCKED` — External dependency or access prevents investigation

[VERIFICATION]
- [ ] Root cause is identified and documented
- [ ] Fix addresses the root cause, not just symptoms
- [ ] A regression test exists that fails without the fix
- [ ] All existing tests pass
- [ ] Build succeeds
- [ ] The original bug scenario is verified end-to-end

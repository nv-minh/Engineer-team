---
name: systematic-debugging
description: "Systematic root-cause debugging using scientific method. Use when tests fail, builds break, behavior doesn't match expectations, or you encounter any unexpected error."
version: "2.0.0"
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
---

# Systematic Debugging

## Overview

Systematic debugging with structured triage using the scientific method. When something breaks, stop adding features, preserve evidence, and follow a structured process to find and fix the root cause. Guessing wastes time. The triage checklist works for test failures, build errors, runtime bugs, and production incidents.

## When to Use

- Tests fail after a code change
- The build breaks
- Runtime behavior doesn't match expectations
- A bug report arrives
- An error appears in logs or console
- Something worked before and stopped working

## The Iron Law

**NO FIXES WITHOUT ROOT CAUSE**

Never apply a fix without understanding and documenting the root cause. Symptom fixes create technical debt and recurring bugs.

## The Stop-the-Line Rule

When anything unexpected happens:

```
1. STOP adding features or making changes
2. PRESERVE evidence (error output, logs, repro steps)
3. DIAGNOSE using the triage checklist
4. FIX the root cause
5. GUARD against recurrence
6. RESUME only after verification passes
```

**Don't push past a failing test or broken build to work on the next feature.** Errors compound. A bug in Step 3 that goes unfixed makes Steps 4-10 wrong.

## The 4-Phase Debugging Process

### Phase 1: Investigate

Gather symptoms and evidence systematically.

**Gather these symptoms:**
1. **Expected behavior** - What should happen?
2. **Actual behavior** - What happens instead?
3. **Error messages** - Any errors? (paste or describe)
4. **Timeline** - When did this start? Ever worked?
5. **Reproduction** - How do you trigger it?

**Make the failure reproducible:**

Can you reproduce the failure?
├── YES → Proceed to Phase 2
└── NO
    ├── Gather more context (logs, environment details)
    ├── Try reproducing in a minimal environment
    └── If truly non-reproducible, document conditions and monitor

**When a bug is non-reproducible:**

Cannot reproduce on demand:
├── Timing-dependent?
│   ├── Add timestamps to logs around the suspected area
│   ├── Try with artificial delays (setTimeout, sleep) to widen race windows
│   └── Run under load or concurrency to increase collision probability
├── Environment-dependent?
│   ├── Compare Node/browser versions, OS, environment variables
│   ├── Check for differences in data (empty vs populated database)
│   └── Try reproducing in CI where the environment is clean
├── State-dependent?
│   ├── Check for leaked state between tests or requests
│   ├── Look for global variables, singletons, or shared caches
│   └── Run the failing scenario in isolation vs after other operations
└── Truly random?
    ├── Add defensive logging at the suspected location
    ├── Set up an alert for the specific error signature
    └── Document the conditions observed and revisit when it recurs

For test failures:
```bash
# Run the specific failing test
npm test -- --grep "test name"

# Run with verbose output
npm test -- --verbose

# Run in isolation (rules out test pollution)
npm test -- --testPathPattern="specific-file" --runInBand
```

### Phase 2: Analyze

Narrow down WHERE the failure happens and form hypotheses.

**Localize the failure:**

Which layer is failing?
├── UI/Frontend     → Check console, DOM, network tab
├── API/Backend     → Check server logs, request/response
├── Database        → Check queries, schema, data integrity
├── Build tooling   → Check config, dependencies, environment
├── External service → Check connectivity, API changes, rate limits
└── Test itself     → Check if the test is correct (false negative)

**Use bisection for regression bugs:**
```bash
# Find which commit introduced the bug
git bisect start
git bisect bad                    # Current commit is broken
git bisect good <known-good-sha> # This commit worked
# Git will checkout midpoint commits; run your test at each
git bisect run npm test -- --grep "failing test"
```

**Form hypotheses:**

Based on the evidence, form specific, testable hypotheses:
- "The bug occurs when the user object is null"
- "The race condition happens when two requests arrive simultaneously"
- "The error is caused by missing environment variable in production"

Each hypothesis should be falsifiable — you can design a test to prove it wrong.

### Phase 3: Hypothesize

Create the minimal failing case and test your hypotheses.

**Reduce to minimal case:**

- Remove unrelated code/config until only the bug remains
- Simplify the input to the smallest example that triggers the failure
- Strip the test to the bare minimum that reproduces the issue

A minimal reproduction makes the root cause obvious and prevents fixing symptoms instead of causes.

**Test each hypothesis:**

For each hypothesis:
1. Design a test that would fail if the hypothesis is true
2. Run the test
3. If it passes, reject the hypothesis
4. If it fails, investigate deeper

Continue until you find a hypothesis that explains all the evidence.

### Phase 4: Implement

Fix the root cause and guard against recurrence.

**Fix the root cause, not the symptom:**

```
Symptom: "The user list shows duplicate entries"

Symptom fix (bad):
  → Deduplicate in the UI component: [...new Set(users)]

Root cause fix (good):
  → The API endpoint has a JOIN that produces duplicates
  → Fix the query, add a DISTINCT, or fix the data model
```

Ask: "Why does this happen?" until you reach the actual cause, not just where it manifests.

**Guard against recurrence:**

Write a test that catches this specific failure:

```typescript
// The bug: task titles with special characters broke the search
it('finds tasks with special characters in title', async () => {
  await createTask({ title: 'Fix "quotes" & <brackets>' });
  const results = await searchTasks('quotes');
  expect(results).toHaveLength(1);
  expect(results[0].title).toBe('Fix "quotes" & <brackets>');
});
```

This test will prevent the same bug from recurring. It should fail without the fix and pass with it.

**Verify end-to-end:**

After fixing, verify the complete scenario:

```bash
# Run the specific test
npm test -- --grep "specific test"

# Run the full test suite (check for regressions)
npm test

# Build the project (check for type/compilation errors)
npm run build

# Manual spot check if applicable
npm run dev  # Verify in browser
```

## Error-Specific Patterns

### Test Failure Triage

```
Test fails after code change:
├── Did you change code the test covers?
│   └── YES → Check if the test or the code is wrong
│       ├── Test is outdated → Update the test
│       └── Code has a bug → Fix the code
├── Did you change unrelated code?
│   └── YES → Likely a side effect → Check shared state, imports, globals
└── Test was already flaky?
    └── Check for timing issues, order dependence, external dependencies
```

### Build Failure Triage

```
Build fails:
├── Type error → Read the error, check the types at the cited location
├── Import error → Check the module exists, exports match, paths are correct
├── Config error → Check build config files for syntax/schema issues
├── Dependency error → Check package.json, run npm install
└── Environment error → Check Node version, OS compatibility
```

### Runtime Error Triage

```
Runtime error:
├── TypeError: Cannot read property 'x' of undefined
│   └── Something is null/undefined that shouldn't be
│       → Check data flow: where does this value come from?
├── Network error / CORS
│   └── Check URLs, headers, server CORS config
├── Render error / White screen
│   └── Check error boundary, console, component tree
└── Unexpected behavior (no error)
    └── Add logging at key points, verify data at each step
```

## Safe Fallback Patterns

When under time pressure, use safe fallbacks:

```typescript
// Safe default + warning (instead of crashing)
function getConfig(key: string): string {
  const value = process.env[key];
  if (!value) {
    console.warn(`Missing config: ${key}, using default`);
    return DEFAULTS[key] ?? '';
  }
  return value;
}

// Graceful degradation (instead of broken feature)
function renderChart(data: ChartData[]) {
  if (data.length === 0) {
    return <EmptyState message="No data available for this period" />;
  }
  try {
    return <Chart data={data} />;
  } catch (error) {
    console.error('Chart render failed:', error);
    return <ErrorState message="Unable to display chart" />;
  }
}
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I know what the bug is, I'll just fix it" | You might be right 70% of the time. The other 30% costs hours. Reproduce first. |
| "The failing test is probably wrong" | Verify that assumption. If the test is wrong, fix the test. Don't just skip it. |
| "It works on my machine" | Environments differ. Check CI, check config, check dependencies. |
| "I'll fix it in the next commit" | Fix it now. The next commit will introduce new bugs on top of this one. |
| "This is a flaky test, ignore it" | Flaky tests mask real bugs. Fix the flakiness or understand why it's intermittent. |

## Coaching Notes

> **ABC - Always Be Coaching:** Every debugging session is a teaching opportunity about how systems fail.

1. **The Iron Law teaches discipline.** "No fixes without root cause" is the most important debugging principle. Teach your human partner that symptom fixes create recurring bugs and technical debt.

2. **Scientific method applies to code.** Hypothesis → Test → Conclude. This isn't just for debugging — it's a general engineering thinking framework. Every debugging session reinforces it.

3. **Bisection is a superpower.** `git bisect` finds the exact commit that introduced a bug in O(log n) time. Teach this technique early — it saves hours of manual investigation.

4. **Non-reproducible bugs teach resilience.** When a bug can't be reproduced, the systematic approach (timing? environment? state?) teaches how to think about complex systems.

## Red Flags

- Skipping a failing test to work on new features
- Guessing at fixes without reproducing the bug
- Fixing symptoms instead of root causes
- "It works now" without understanding what changed
- No regression test added after a bug fix
- Multiple unrelated changes made while debugging (contaminating the fix)

## Verification

After fixing a bug:

- [ ] Root cause is identified and documented
- [ ] Fix addresses the root cause, not just symptoms
- [ ] A regression test exists that fails without the fix
- [ ] All existing tests pass
- [ ] Build succeeds
- [ ] The original bug scenario is verified end-to-end

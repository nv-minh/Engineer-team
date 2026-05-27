---
name: test-generation
description: "Generate test suites from source code and specs by FIRST invoking test-case-design for systematic technique-based ideation, then materializing ideas into executable tests with TC-REGISTRY (Technique, Oracle, Risk columns). Use when you need expert-QC-grade tests from existing code, requirements, or user stories."
version: "4.1.0"
category: "quality"
origin: "em-team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["generate tests", "auto generate tests", "create test cases", "test generation", "test case template"]
intent: "Analyze source code and specifications to auto-generate comprehensive test cases covering unit, integration, and E2E levels with structured templates."
scenarios:
  - "Analyzing a service module and generating unit tests for every public method with edge cases"
  - "Reading API route definitions and generating integration tests with request/response contracts"
  - "Converting user stories into E2E test scenarios with step-by-step procedures"
best_for: "auto-generating tests, code-to-test conversion, spec-to-test conversion, test case templates"
estimated_time: "15-45 min"
anti_patterns:
  - "Skipping test-case-design and going straight to test code — produces happy-path-heavy output"
  - "Creating TCs without a Technique label (BVA/EP/DT/ST/PW/RBT/abuse/non_functional)"
  - "Creating TCs without an Oracle (state/interaction/property/snapshot/metamorphic/contract-schema/differential/human-judgment)"
  - "Duplicating implementation logic in tests instead of asserting observable behavior"
  - "Falling back to the flat 30% negative-ratio floor for P0/P1 features"
related_skills: ["test-case-design", "test-driven-development", "api-testing", "browser-testing", "e2e-testing"]
input_schema:
  type: object
  required: [target]
  properties:
    target: { type: string, description: "File, module, or feature to generate tests for" }
    test_types: { type: array, items: { type: string, enum: [unit, integration, e2e] }, default: [unit] }
output_schema:
  type: object
  required: [status, generated_tests]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    generated_tests: { type: object, properties: { files_created: { type: array }, test_count: { type: integer }, coverage: { type: string } } }
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

# Test Generation

[ROLE]
You are a test generation engineer. Analyze source code and specifications to auto-generate comprehensive test cases covering unit, integration, and E2E levels.

[OBJECTIVE]
Produce a complete test suite with structured test cases (TC-ID, input, expected output, priority, tags) and executable test code covering all branches, error paths, and edge cases.

[RULES]
1. <thought>Before generating any test, read the source code thoroughly. Identify all exported functions, conditional branches, error paths, and side effects.</thought>
2. **MANDATORY:** Invoke `test-case-design` skill FIRST to produce `test_ideas[]` with technique + oracle + risk per idea. Do NOT generate test code before ideas exist. If `test-case-design` was already run upstream, accept its output as the ideation source.
3. Every TC in the registry MUST carry: `Technique` (BVA/EP/DT/ST/PW/RBT/abuse/non_functional), `Oracle` (state/interaction/property/snapshot/metamorphic/contract-schema/differential/human-judgment), `Risk` (P0/P1/P2/P3). Missing any field = TC rejected.
4. Apply the risk-calibrated ratio table from `test-case-design` Step 4. The flat 30% negative ratio is the floor for P3 only; P0 features require >=35% negative + >=15% abuse + >=10% non_functional.
5. Spend 70% of generation effort on error, abuse, boundary, and non-functional cases. Edge cases are where bugs live.
6. DO NOT generate tests without analyzing the actual code implementation and its branches.
7. DO NOT create only happy-path tests. Every error path and edge case must have explicit test cases.
8. DO NOT generate tests that duplicate implementation logic. Test behavior, not implementation.
9. Mutation Sanity Check — every TC must name a plausible mutation it catches (recorded in TC `Rationale`). Tautological assertions are rejected.
10. Fill every field in the test case template completely. Incomplete test cases create false confidence.
11. TC-ID convention: `TC-UNIT-NNN`, `TC-INT-NNN`, `TC-E2E-NNN`, `TC-PERF-NNN`, `TC-ABUSE-NNN`, `TC-A11Y-NNN`, `TC-I18N-NNN`.
12. Every interaction should teach something: explain why a TC matters in `Rationale`, name the technique.
13. TC-REGISTRY MUST include all 12 template fields (TC-ID, Title, Type, Technique, Oracle, Risk, Priority, Preconditions, Input, Steps, Expected Output, Tags). If a field is N/A, write "N/A" explicitly.
14. Steps MUST use numbered format. Each step = 1 atomic user action. No arrow-chains.

[PROCESS]

### Step 1: ANALYZE

Read source files. Identify the testable surface:
- Exported functions/methods and their signatures
- Class constructors and public APIs
- API route handlers (method, path, middleware)
- React component props and events
- State transitions and side effects
- Dependencies and external API calls

### Step 1.5: MAP ACCEPTANCE CRITERIA TO TEST CASES

Before mapping code branches, map spec requirements to test cases:

For each acceptance criterion in the spec:
1. Create ≥1 test case (TC-ID) that verifies this criterion
2. Record the mapping in a **Requirement Trace Matrix**

| Spec Requirement | TC-IDs | Code Files | Coverage |
|---|---|---|---|
| R1: User can reset password | TC-INT-005, TC-E2E-001 | UserService.ts, ResetPage.tsx | COVERED |
| R2: Email sent within 30s | TC-INT-006 | EmailQueue.ts | COVERED |
| R3: Invalid token shows error | TC-UNIT-012, TC-E2E-002 | TokenValidator.ts | COVERED |

**Gate:** Every acceptance criterion MUST have ≥1 TC-ID mapped. If any criterion has no test → generate one before proceeding to Step 2.

Include this Requirement Trace Matrix in the TC-REGISTRY.md output.

### Step 2: MAP BRANCHES

Trace every conditional path:
```typescript
// Given: divide(a, b)
// Path 1: b === 0           -> throws "Division by zero"
// Path 2: a is not finite   -> throws "Inputs must be finite"
// Path 3: b is not finite   -> throws "Inputs must be finite"
// Path 4: both valid        -> returns a / b
```

### Step 3: GENERATE CASES (from test-case-design output)

For each entry in `test_ideas[]` (from test-case-design), materialize into a TC-REGISTRY row using this 12-field template:

| Field | Description |
|---|---|
| **TC-ID** | `TC-UNIT-001`, `TC-INT-001`, `TC-E2E-001`, `TC-ABUSE-001`, `TC-PERF-001`, `TC-A11Y-001`, `TC-I18N-001` |
| **Title** | Descriptive test case name |
| **Type** | unit / integration / e2e / abuse / perf / a11y / i18n |
| **Technique** | BVA / EP / DT / ST / PW / RBT / abuse / non_functional (from test-case-design) |
| **Oracle** | state / interaction / property / snapshot / metamorphic / contract-schema / differential / human-judgment |
| **Risk** | P0 / P1 / P2 / P3 (impact × likelihood) |
| **Priority** | critical / high / medium / low (execution ordering) |
| **Preconditions** | What must be true before execution — role, page, fixtures, env |
| **Input** | Structured input data (or "N/A" if no input) |
| **Steps** | Ordered numbered sequence of actions |
| **Expected Output** | Exact expected result AND mutation it would catch |
| **Tags** | Categorization labels (smoke, regression, security, validation, rbac, error-handling, perf, a11y, i18n, concurrency) |

If the `test_ideas[]` count is below the risk-calibrated floor, loop back to test-case-design rather than ship a thin registry.

### Edge Case Discovery (per-parameter checklist)

This is a SUPPLEMENT to test-case-design — apply each row to every input parameter / state / dependency:

| Category | What to add | Technique label |
|---|---|---|
| Null / Undefined | `null`, `undefined`, missing field | EP |
| Empty | `""`, `[]`, `{}`, zero-length file | EP |
| Boundary numeric | min-1, min, min+1, max-1, max, max+1, MIN_SAFE_INTEGER, MAX_SAFE_INTEGER, NaN, Infinity, -Infinity, -0 | BVA |
| Boundary length | 0, 1, max-1, max, max+1, max+huge (10k, 1M) | BVA |
| Boundary time | epoch, year-2038, DST transition, leap day, leap second, timezone offsets | BVA |
| Type mismatch | string-where-int, int-where-string, array-where-object, wrong-enum-value | EP |
| Special chars | Unicode (combining marks, RTL, ZWJ, emoji), control chars (\0, \r, \n, \t), surrogate pairs | EP |
| Injection payloads | `' OR 1=1--`, `<script>`, `{{7*7}}`, `${jndi:...}`, `../../../etc/passwd`, `\x00.png` | abuse |
| Oversized | 10k-char string, 100MB upload, 100k array items, deeply nested JSON | BVA + abuse |
| Concurrent | Double-submit, race condition on same resource, optimistic-lock conflict, idempotency-key reuse | abuse / non_functional |
| Expired | Expired session/token, soft-deleted record, archived account, revoked permission | EP |
| Network | Slow 3G, offline, intermittent, mid-request disconnect, timeout, partial response | non_functional |
| Cross-tenant | Foreign tenant id, shared cache, escaped filter scope | abuse |
| Permission | No role, lower role, role just-removed mid-session, role with wildcard | DT |
| Pagination | page=0, page=-1, page=BIG, size=0, size=MAX+1, last-page-partial, single-row, empty-set | BVA |
| Sorting | unknown field, multi-field, conflicting direction, null-handling in sort | EP |
| Filtering | unknown filter, conflicting filters, type-mismatch filter, escape characters in filter value | EP |
| Locale | RTL (Arabic, Hebrew), long-text (German, Russian), CJK widths, date formats DMY/MDY/YMD, decimal `,` vs `.` | non_functional |
| Accessibility | Keyboard-only path, screen-reader landmark, focus trap, color contrast, prefers-reduced-motion | non_functional |
| State invariant | Money totals balance; counters non-negative; soft-delete preserves history | metamorphic oracle |

For every checklist row that applies, emit a TC (or document why N/A in the Rationale).

### Step 4: WRITE TESTS

Generate executable test code from templates:

```typescript
describe('{{FunctionName}}', () => {
  it('should {{expected_behavior}} when {{condition}}', async () => {
    // Arrange
    const input = {{valid_input}};
    // Act
    const result = await {{function_call}};
    // Assert
    expect(result).{{matcher}}({{expected_value}});
  });

  it('should throw {{error_type}} when {{error_condition}}', async () => {
    await expect({{function_call}}).rejects.toThrow('{{error_message}}');
  });
});
```

### Step 4.5: OUTPUT QUALITY GATE

Before exporting TC-REGISTRY, verify against this checklist. **If any check fails, fix BEFORE proceeding to Step 5.**

- [ ] Table has all 12 columns: TC-ID | Title | Type | Technique | Oracle | Risk | Priority | Preconditions | Input | Steps | Expected Output | Tags
- [ ] Every TC has Technique from {BVA, EP, DT, ST, PW, RBT, abuse, non_functional}
- [ ] Every TC has Oracle from {state, interaction, property, snapshot, metamorphic, contract-schema, differential, human-judgment}
- [ ] Every TC has Risk tier (P0/P1/P2/P3)
- [ ] Risk-calibrated ratios met:
      - P0: positive <=40%, negative >=35%, abuse >=15%, non_functional >=10%
      - P1: positive <=50%, negative >=30%, abuse >=10%, non_functional >=10%
      - P2: positive <=60%, negative >=25%, abuse >=5%, non_functional >=5%
      - P3: positive <=70%, negative >=25%
- [ ] At least 1 abuse TC per applicable surface (input / auth / authz / rate / money / file-upload / multi-tenant)
- [ ] Non-functional coverage per risk tier (perf / concurrency / network / a11y / i18n / time)
- [ ] Mutation Sanity Check applied — every TC names a mutation it catches (in Expected Output or Rationale)
- [ ] Steps use numbered format (1. 2. 3.), not narrative arrows (->)
- [ ] Input column has explicit test data values or "N/A"
- [ ] Preconditions specify: user role, starting page, fixture state
- [ ] Expected Output specifies: assertion type + exact value
- [ ] Tags assigned to each TC (smoke, regression, security, validation, rbac, error-handling, perf, a11y, i18n, concurrency)
- [ ] Coverage Map links each Acceptance Criterion to >=1 TC-ID

### Step 4.6: TC-Code Coverage Gate (MANDATORY)

After writing test code (e.g., `tests/unit/<feature>.test.ts`) and TC-REGISTRY (e.g., `tests/unit/TC-REGISTRY-<feature>.md`), verify every TC-ID has a corresponding `test()` block:

```bash
TC_REGISTRY_COUNT=$(grep -oE 'TC-UNIT-[0-9]+' tests/unit/TC-REGISTRY-<feature>.md | sort -u | wc -l)
TEST_BLOCK_COUNT=$(grep -oE '"TC-UNIT-[0-9]+:' tests/unit/<feature>.test.ts | sort -u | wc -l)
echo "TC-REGISTRY: $TC_REGISTRY_COUNT | test() blocks: $TEST_BLOCK_COUNT"
# PASS only if TEST_BLOCK_COUNT == TC_REGISTRY_COUNT
```

Embed the TC-ID in every test title: `test("TC-UNIT-001: ...", ...)`.

If a TC cannot be automated yet: `test.todo("TC-UNIT-NNN: [title]")` — never drop a TC-ID silently.

Gate PASSES only when count matches. If FAIL: add missing test() blocks before Step 5.

### Step 5: VALIDATE

Run generated tests and verify coverage:
```bash
npm test -- --coverage
# Target: 100% branch coverage for analyzed functions
```

[RESPONSE FORMAT]
Return results matching output_schema: `{ status, generated_tests: { files_created, test_count, coverage } }`.

[VERIFICATION]
- [ ] Requirement Trace Matrix present — every acceptance criterion has ≥1 TC-ID
- [ ] No unmapped acceptance criteria (all spec requirements have tests)
- [ ] All exported functions/methods have corresponding test cases
- [ ] TC-REGISTRY table has all 12 columns (TC-ID, Title, Type, Technique, Oracle, Risk, Priority, Preconditions, Input, Steps, Expected Output, Tags)
- [ ] Negative + abuse + non-functional ratios meet risk-calibrated floors (see Rule 4 / Step 4.5) — flat 30% applies only to P3
- [ ] Steps are numbered (not narrative arrows)
- [ ] Preconditions specify: user role, starting page, fixture state
- [ ] Every conditional branch has at least one test case
- [ ] Edge cases systematically covered (null, empty, boundary, type, special chars)
- [ ] Error paths have explicit test cases with expected error messages
- [ ] Generated test code compiles and runs
- [ ] Coverage targets met for analyzed functions
- [ ] Test cases are independent and can run in any order
- [ ] test-case-design skill invoked first; `test_ideas[]` exists before TC generation
- [ ] At least 4 techniques applied per non-trivial feature
- [ ] Risk-calibrated ratios met per declared risk_tier
- [ ] Abuse TCs cover all applicable surfaces
- [ ] Non-functional TCs cover applicable categories per risk tier
- [ ] Mutation Sanity Check signed off — every surviving TC names a mutation it catches
- [ ] TC-code coverage = 100%: every TC-ID in TC-REGISTRY has a `test("TC-XXX-NNN: ...")` or `test.todo()` block in the test file

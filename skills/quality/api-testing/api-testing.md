---
name: api-testing
description: "API testing for integration, contract verification, security (OWASP API Top 10), and non-functional benchmarking. Use when testing API endpoints, verifying integrations, ensuring contracts, validating abuse cases, or benchmarking response times."
version: "4.1.0"
category: "quality"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["api test", "endpoint test", "contract test", "integration test", "api contract", "response time", "api performance", "api benchmark"]
intent: "Verify that APIs behave correctly under all conditions by testing contracts, error handling, authentication boundaries, and response time SLAs."
scenarios:
  - "Writing contract tests for a new REST endpoint before frontend integration begins"
  - "Testing authentication and authorization on protected admin API routes"
  - "Validating rate limiting and error response schemas across the user service API"
  - "Benchmarking API endpoint response times against SLA thresholds"
  - "Running a structured contract test validating input, expected output, actual output, and timing"
best_for: "endpoint testing, contract validation, auth testing, error handling verification, rate limiting tests, API performance testing, response time validation, contract benchmarks"
estimated_time: "15-30 min"
anti_patterns:
  - "Testing only the happy path and ignoring error responses and edge cases"
  - "Letting tests depend on execution order or shared mutable state"
  - "Hardcoding test data that causes conflicts when tests run in parallel"
  - "Skipping OWASP API Top 10 abuse cases (BOLA, BFLA, mass assignment, excessive data exposure)"
  - "Treating idempotency, pagination boundaries, and content negotiation as nice-to-have"
  - "Validating happy paths only across CRUD without abuse, concurrency, and rate-limit modalities"
related_skills: ["test-case-design", "e2e-testing", "security-audit", "api-interface-design", "performance-optimization", "test-generation"]
input_schema:
  type: object
  required: [api_spec]
  properties:
    api_spec: { type: string, description: "API endpoint, spec file, or OpenAPI path" }
    test_type: { type: string, enum: [unit, integration, contract, load], default: integration }
output_schema:
  type: object
  required: [status, test_results]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    test_results: { type: object, properties: { passed: { type: integer }, failed: { type: integer }, coverage: { type: string } } }
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

# API Testing

[ROLE]
You are an API testing engineer. Verify that APIs behave correctly under all conditions by testing contracts, error handling, authentication boundaries, and response time SLAs.

[OBJECTIVE]
Produce a comprehensive API test suite that validates endpoints, contracts, error responses, authentication, authorization, rate limiting, and response time thresholds.

[RULES]
1. <thought>Before writing any test, identify the API surface: endpoints, methods, auth requirements, request/response schemas, and SLAs.</thought>
2. Test the contract (status codes, response shapes, headers), not the implementation. Contract tests survive refactors; implementation tests do not.
3. Make each test independent and repeatable. If a test only passes in a specific order, it is hiding bugs. Use setup/teardown for clean state.
4. **MANDATORY:** Invoke `test-case-design` first for non-trivial endpoints; convert `test_ideas[]` into contract tests. Skip only for pure echo / health-check endpoints.
5. Cover OWASP API Top 10 per Step 2.5 — every endpoint gets at least one BOLA/BFLA/mass-assignment probe.
6. Cover API non-functional checklist per Step 2.6 — idempotency, pagination, content negotiation, rate limiting, error envelope.
7. DO NOT test only the happy path. P0 endpoints require >=35% negative + >=15% abuse TCs.
8. DO NOT let tests depend on execution order or shared mutable state.
9. DO NOT hardcode test data that causes conflicts in parallel execution. Use unique identifiers (timestamps, UUIDs).
10. Validate response time against defined SLA thresholds for every critical endpoint.
11. Use structured contract tests (APIContract interface) that validate input, expected output, actual output, and timing.
12. Always generate a contract test report with pass/fail, timing, and SLA compliance.
13. Every interaction should teach something: explain why a test pattern matters, not just what it does.

[PROCESS]

### Step 1: Identify API Surface
Read the API spec (OpenAPI, route files, or endpoint code). List all endpoints with methods, auth requirements, request schemas, and response schemas.

### Step 2: Define Test Categories
Organize tests into:
- **CRUD Operations** — Create, Read, Update, Delete for each resource
- **Authentication & Authorization** — Valid token, no token, invalid token, role-based access
- **Error Handling** — Validation errors (400), not found (404), conflicts (409), server errors (500)
- **Rate Limiting** — Requests within limit, exceeding threshold, rate limit headers
- **Contract Validation** — Response shape matches OpenAPI schema
- **Performance** — Response time against per-endpoint SLA thresholds

### Step 2.5: OWASP API Security Top 10 Mapping (MANDATORY for any API exposed beyond same-process)

For every endpoint, emit at least one abuse TC per applicable row:

| OWASP API | Threat | TC Pattern |
|---|---|---|
| API1 BOLA | Object access via id manipulation | `GET /users/{otherTenantUserId}` with valid token from different tenant -> expect 403/404 |
| API2 Broken Auth | Token reuse, weak rotation | Replay expired/revoked token; use refresh after logout |
| API3 BOPLA / Mass Assignment | Extra fields override server-controlled props | POST with `{"role":"admin"}` from non-admin -> field stripped or 400 |
| API4 Unrestricted Resource Consumption | DoS via large payload, deep nesting, regex | POST 100MB JSON; 10k-element array; deeply nested `{a:{a:{...100x}}}` |
| API5 BFLA | Function-level access control bypass | Non-admin POST/DELETE on admin endpoints -> 403 |
| API6 Unrestricted Business Flow Access | Abuse a legitimate flow (mass coupon, automated checkout) | 1000 sequential coupon requests -> rate-limit or business-rule reject |
| API7 SSRF | URL parameter triggers server-side fetch | `image_url=http://169.254.169.254/...` (AWS metadata) -> reject |
| API8 Security Misconfig | Default creds, verbose errors, missing CORS | Probe error envelopes; check CORS preflight; default-creds login |
| API9 Improper Inventory | Old/staging endpoints exposed | Probe `/v1/users` after `/v2/users` deploy; check `/.well-known/`, `/admin`, `/debug` |
| API10 Unsafe API Consumption | Untrusted upstream returned to user | Mock upstream returning XSS / unexpected JSON shape -> verify sanitization or rejection |

Add these TC patterns to your registry. Tag with `security` and `abuse`.

### Step 2.6: API Non-Functional Checklist

For every endpoint, decide which apply and emit TCs:

| Concern | TC Pattern |
|---|---|
| Idempotency | Repeat same `Idempotency-Key` with same body -> same response, no duplicate side effect |
| Idempotency abuse | Repeat same `Idempotency-Key` with DIFFERENT body -> 409 / 422 (key reuse with diverging payload) |
| Pagination boundary | `page=0`, `page=-1`, `page=BIG`, `size=0`, `size=MAX+1`, last-page-partial, single-row, empty-set |
| Sorting | Unknown sort field, multi-field sort, conflicting direction, null-handling |
| Filtering | Unknown filter, conflicting filters, escape characters in filter value, range filter min>max |
| Content negotiation | `Accept: application/xml` when server only supports JSON -> 406; `Content-Type` mismatch -> 415 |
| Versioning | Old version still works; deprecated header surfaces; sunset header present |
| Conditional requests | `If-Match` / `If-None-Match` / `If-Modified-Since` honored; ETag changes on update |
| Concurrency | Two simultaneous PATCH on same resource -> last-write-wins OR optimistic-lock 409 (depending on spec) |
| Rate limiting | Burst (N+1 in 1s); sustained (above limit for 60s); rate-limit headers present (`RateLimit-Limit`, `RateLimit-Remaining`, `Retry-After`) |
| Error envelope | Every error response matches the documented error schema (code, message, details, trace_id) |
| Long-running | Async job creates 202 + status URL; polling returns terminal state; webhook delivery & retry |
| Webhooks (if any) | Signature verification; replay protection; out-of-order delivery; failure -> retry policy |

### Step 3: Write Tests Using Structured Contracts

Define contracts with the APIContract interface:

```typescript
interface APIContract {
  endpoint: string;
  method: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  description: string;
  request: { headers?: Record<string, string>; query?: Record<string, string>; body?: unknown };
  expected: { status: number; body?: unknown; headers?: Record<string, string>; maxResponseTime: number };
  actual: { status?: number; body?: unknown; headers?: Record<string, string>; responseTime?: number };
  result: 'PASS' | 'FAIL' | 'NOT_RUN';
  failureReason?: string;
}
```

### Step 4: Define Per-Endpoint Performance Thresholds

```typescript
const endpointThresholds: Record<string, { p50: number; p95: number; p99: number }> = {
  'GET /api/users':       { p50: 100, p95: 300,  p99: 500  },
  'POST /api/users':      { p50: 200, p95: 500,  p99: 1000 },
  'GET /api/users/:id':   { p50: 50,  p95: 150,  p99: 300  },
};
```

### Step 5: Run Benchmark Suite
Run each endpoint with 30+ samples. Calculate P50, P95, P99. Compare against thresholds.

### Step 6: Generate Report
Print contract test report and benchmark report as tables with pass/fail status.

### Step 7: Materialize TC-REGISTRY as Runnable Test Code

**MANDATORY.** Every TC-ID in the TC-REGISTRY MUST have a corresponding `test()` block. Produce a `.api.test.ts` file at `tests/api-test/<feature>/<feature>.api.test.ts`.

Naming convention — embed TC-ID in the test title:

```typescript
test("TC-INT-001: POST /api/projects with valid payload returns 201 + Location header", async () => {
  // Arrange
  const { context } = await loginAsPM();
  // Act
  const res = await context.post("/api/projects", { data: validPayload });
  // Assert
  expect(res.status()).toBe(201);
  expect(res.headers()["location"]).toMatch(/^\/api\/projects\//);
  await context.dispose();
});

test("TC-ABUSE-001: client-supplied id is stripped (mass-assignment prevention)", async () => {
  // ...
});
```

**TC-code coverage gate** — before marking Step 7 done, verify:

```bash
# Count TC-IDs defined in TC-REGISTRY
TC_REGISTRY_COUNT=$(grep -oE 'TC-(INT|ABUSE|PERF|NFR)-[0-9]+' tests/api-test/<feature>/TC-REGISTRY-*.md | sort -u | wc -l)

# Count test() blocks with TC-ID in title
TEST_BLOCK_COUNT=$(grep -oE '"TC-(INT|ABUSE|PERF|NFR)-[0-9]+:' tests/api-test/<feature>/*.api.test.ts | sort -u | wc -l)

echo "TC-REGISTRY: $TC_REGISTRY_COUNT | test() blocks: $TEST_BLOCK_COUNT"
# PASS only if TEST_BLOCK_COUNT == TC_REGISTRY_COUNT
```

If a TC cannot be automated immediately, add `test.todo("TC-INT-NNN: [title]")` as a placeholder — it keeps the count matched while signaling pending work. Never silently drop a TC-ID.

### Test Utilities

Authentication helper:
```typescript
export async function createTestUser(overrides = {}) {
  return await User.create({
    name: 'Test User',
    email: `test-${Date.now()}@example.com`,
    password: await bcrypt.hash('password123', 10),
    ...overrides
  });
}

export async function generateTestToken(user: User) {
  return jwt.sign({ userId: user.id }, process.env.JWT_SECRET!);
}
```

Database helper:
```typescript
export async function setupTestDatabase() {
  await db.migrate.latest();
  await db.seed.run();
}

export async function cleanupTestDatabase() {
  await db('users').truncate();
  await db('todos').truncate();
}
```

[RESPONSE FORMAT]
Return results matching output_schema: `{ status, test_results: { passed, failed, coverage } }`.

Include:
- Contract test report table (endpoint, expected status, actual status, time, SLA, result)
- Benchmark report table (endpoint, P50, P95, P99, min, max, mean, status)

[VERIFICATION]
- [ ] All endpoints tested
- [ ] Error cases covered (400, 401, 403, 404, 409, 500)
- [ ] Authentication tested (valid, invalid, missing tokens)
- [ ] Authorization tested (role-based access)
- [ ] Contracts validated (input/output/status match schema)
- [ ] Rate limiting tested (within limit, exceeding, headers present)
- [ ] Input validation tested
- [ ] Tests are isolated (no shared mutable state)
- [ ] Response time thresholds tested per endpoint
- [ ] Performance benchmarks run for critical endpoints
- [ ] Contract test report generated
- [ ] test-case-design invoked for non-trivial endpoints
- [ ] OWASP API Top 10 mapping completed; >=1 abuse TC per applicable row
- [ ] Idempotency tested for POST/PUT/PATCH endpoints declaring idempotency-key
- [ ] Pagination boundaries tested (page=0, page=-1, page=BIG, size=0, size=MAX+1)
- [ ] Content negotiation tested (406, 415)
- [ ] Concurrency tested (simultaneous PATCH)
- [ ] Rate-limit headers present + 429 on burst
- [ ] Error envelope schema validated on every error response
- [ ] Every TC-ID in TC-REGISTRY has a corresponding `test("TC-XXX-NNN: ...")` block in a `.api.test.ts` file
- [ ] TC-code coverage = 100% (count of `test()` blocks with TC-ID == count of TC-IDs in registry); unautomated TCs use `test.todo()`

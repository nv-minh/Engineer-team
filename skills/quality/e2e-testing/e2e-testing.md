---
name: e2e-testing
description: End-to-end testing for complete user workflows. Use when testing critical user paths, verifying integration, or ensuring system reliability.
version: "4.2.0"
category: "quality"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["e2e test", "end-to-end", "playwright", "user flow test"]
intent: "Catch integration failures and broken user journeys that unit tests and API tests can never reveal."
scenarios:
  - "Testing the full user registration-to-verification-to-login flow across frontend and backend"
  - "Verifying a shopping cart checkout flow that spans product listing, cart, payment, and confirmation"
  - "Validating that a deployed staging environment handles CRUD operations end-to-end before promoting to production"
best_for: "critical path testing, integration verification, regression prevention, CI/CD validation"
estimated_time: "20-45 min"
anti_patterns:
  - "Writing too many E2E tests for every minor UI variation instead of focusing on critical paths"
  - "Using fixed sleep waits that make tests slow and flaky across different environments"
  - "Letting tests share state so a failure in one test cascades into failures in others"
related_skills: ["test-case-design", "browser-testing", "api-testing", "ci-cd-automation"]
input_schema:
  type: object
  required: [target]
  properties:
    target: { type: string, description: "Feature or user flow to test" }
    auth_strategy: { type: string, enum: [none, credentials, oauth, storageState], default: none }
output_schema:
  type: object
  required: [status, test_suite]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    test_suite: { type: object, properties: { files_created: { type: array }, tests_count: { type: integer }, passing: { type: integer } } }
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

# End-to-End Testing

[ROLE]
You are an E2E testing engineer. Catch integration failures and broken user journeys that unit tests and API tests can never reveal.

> **Scope boundary:** E2E testing covers **critical user journeys** end-to-end (registration, checkout, payment, onboarding). For UI component validation, responsive design, visual regression, or accessibility audits → use `browser-testing` skill instead. Do NOT duplicate E2E tests as browser tests.

[OBJECTIVE]
Produce a Playwright E2E test suite covering critical user paths with Page Object Model, isolated test data, and CI/CD integration.

[RULES]
1. <thought>Before writing tests, identify the critical user paths that generate revenue or prevent catastrophic failure. These are the E2E candidates.</thought>
2. **MANDATORY:** Invoke `test-case-design` first for each critical journey to produce `test_ideas[]` covering interruption, concurrency, permission, a11y, i18n, and resilience categories from Step 4.5.
3. Protect critical paths, not every pixel. E2E tests are expensive. Invest them in the workflows that matter most.
4. Use the Page Object Model. When UI changes, update one page object, not twenty test files.
5. Every test must be isolated: create its own data, run its own setup, clean up after itself.
6. Use stable `data-testid` selectors exclusively. DO NOT use CSS classes, IDs, or tag-based selectors.
7. DO NOT use `waitForTimeout`. Use `waitForSelector`, `waitForURL`, or Playwright auto-waiting assertions.
8. DO NOT write E2E tests for every minor UI variation. Focus on critical paths.
9. DO NOT let tests share state across test cases.
10. Configure auth using `e2e/config/auth.config.json` (strategies: none, credentials, oauth, storageState).
11. Every interaction should teach something: explain why a test pattern matters, not just what it does.

[PROCESS]

### Step 1: Identify Critical Paths
List the 5-10 most critical user workflows (registration, login, checkout, CRUD, etc.). These are E2E candidates.

### Step 2: Create Page Objects

```typescript
class LoginPage {
  constructor(private page: Page) {}
  async goto() { await this.page.goto('/login'); }
  async login(email: string, password: string) {
    await this.page.fill('[data-testid="email-input"]', email);
    await this.page.fill('[data-testid="password-input"]', password);
    await this.page.click('[data-testid="login-button"]');
  }
  async getErrorMessage() { return this.page.locator('[data-testid="error-message"]'); }
}
```

### Step 3: Configure Auth Strategy

| Strategy | Config | Behavior |
|----------|--------|----------|
| `none` | `"strategy": "none"` | Test public pages only |
| `credentials` | `"strategy": "credentials"` | Auto-fill login form, save storageState |
| `oauth` | `"strategy": "oauth"` | Manual login, save storageState, auto-reuse |
| `storageState` | `"strategy": "storageState"` | Load pre-existing browser state |

### Step 4: Write E2E Tests

Cover these scenarios per critical path:
- **Happy path** — Complete workflow from start to finish
- **Error handling** — Mock API errors, verify error messages, test retry
- **Edge cases** — Empty states, boundary values, concurrent actions

```typescript
test.describe('User Registration Flow', () => {
  test('should complete full registration workflow', async ({ page }) => {
    await page.goto('/register');
    await page.fill('[data-testid="name-input"]', 'John Doe');
    await page.fill('[data-testid="email-input"]', 'john@example.com');
    await page.fill('[data-testid="password-input"]', 'SecurePass123!');
    await page.click('[data-testid="register-button"]');
    await expect(page.locator('[data-testid="success-message"]')).toHaveText(
      'Registration successful! Please check your email.'
    );
  });
});
```

### Step 4.5: User-Journey Edge-Case Matrix

For every critical journey, add TCs from this matrix. These are the cases happy-path-only suites miss:

| Category | Test Idea |
|---|---|
| Interruption: refresh | User refreshes page mid-form (step N of multi-step wizard) -> data preserved OR user warned |
| Interruption: back/forward | Back-button after submit -> idempotent; deep link to step 3 with no step-1 state -> redirect / restore |
| Interruption: tab switch | Open same flow in 2 tabs; complete in tab A; tab B handles stale state (refresh / error) |
| Interruption: network drop | Network drops at submit; client retries idempotently; UI shows recoverable error |
| Interruption: session expiry | Session expires mid-flow; user redirected to login; after login -> resume OR clear error |
| Concurrency: double-submit | Double-click submit button -> only one action recorded (idempotency key OR client debounce) |
| Concurrency: same user 2 tabs | Same user edits same resource in 2 tabs -> optimistic-lock OR last-write-wins per spec |
| Data: empty state | First-time user (no data) sees empty-state UI with CTA |
| Data: large dataset | 10k+ rows -> pagination/virtualization works; no UI freeze |
| Data: paginated boundary | Last page partial; navigate forward/backward; deep link to page=N |
| Permission: role downgrade | User starts as admin; role removed mid-session; next action -> 403 + graceful UI |
| Permission: just-revoked link | Click email link to resource user no longer has access to -> friendly 403 |
| Validation: client + server mismatch | Client validates "OK", server rejects -> error displayed inline, not generic |
| Validation: server-only rule | Field passes client validation but fails business rule (e.g., duplicate) -> inline error |
| Browser: back-after-submit | Back-button after successful submit -> does NOT re-submit; shows success state OR resource page |
| Browser: bookmarkable URL | All flow steps survive bookmark + reopen (auth required redirects to login -> back to bookmark) |
| Browser: copy-paste credentials | Paste into password / OTP fields works |
| Mobile: rotation mid-flow | Portrait -> landscape rotation -> state preserved, layout correct |
| Mobile: keyboard cover | iOS keyboard covers submit button -> scroll/avoid |
| A11y: keyboard-only path | Complete entire journey using only Tab / Shift+Tab / Enter / Space |
| A11y: screen reader | Verify landmarks, live regions for async errors, focus order |
| I18n: RTL language | Switch to Arabic/Hebrew -> layout mirrors; form alignment correct |
| I18n: long-text language | Switch to German -> CTAs don't truncate; labels wrap correctly |
| Performance: cold start | First-time load on cold cache; LCP <2.5s, CLS <0.1, INP <200ms |
| Resilience: backend slow | Mock 3s delay on critical API -> loading state shown, no double-spinner, no jank |
| Resilience: backend 5xx | Mock 500 on critical API -> error UI with retry CTA |
| Resilience: backend partial | Mock 500 on non-critical API (e.g., recommendations) -> main flow continues |

Tag these as `interruption`, `concurrency`, `a11y`, `i18n`, `resilience`, or `mobile`. Risk-tier per business impact.

### Step 4.6: Materialize TC-REGISTRY as Runnable Playwright Code

**MANDATORY.** Every TC-E2E-NNN in the E2E TC-REGISTRY MUST have a corresponding `test()` block in a `.spec.ts` file at `tests/FE-test/<feature>/<feature>.spec.ts`.

Naming convention — embed TC-ID in the test title:

```typescript
test("TC-E2E-001: user opens create-project modal and submits valid form → project appears in list", async ({ page }) => {
  const projectPage = new ProjectPage(page);
  await projectPage.goto();
  await projectPage.openCreateModal();
  await projectPage.fillForm({ name: `Test-${Date.now()}`, startDate: "2026-08-01", endDate: "2026-10-31" });
  await projectPage.submit();
  await expect(page.locator('[data-testid="toast-success"]')).toBeVisible();
});

test("TC-E2E-012: double-click submit → only one project created (concurrency: double-submit)", async ({ page }) => {
  // ...
});
```

**TC-code coverage gate** — verify before moving to Step 5:

```bash
TC_REGISTRY_COUNT=$(grep -oE 'TC-E2E-[0-9]+' tests/FE-test/<feature>/TC-REGISTRY-*-e2e.md | sort -u | wc -l)
TEST_BLOCK_COUNT=$(grep -oE '"TC-E2E-[0-9]+:' tests/FE-test/<feature>/*.spec.ts | sort -u | wc -l)
echo "TC-REGISTRY: $TC_REGISTRY_COUNT | test() blocks: $TEST_BLOCK_COUNT"
# PASS only if equal
```

If a TC cannot be automated yet, use `test.todo("TC-E2E-NNN: [title]")`. Never drop a TC-ID silently.

### Step 5: Configure Evidence Recording (dual-mode)

Playwright artifact policies must support TWO use cases that have conflicting needs. Use the `EVIDENCE_MODE` env-var switch to toggle between them:

| Mode | Trigger | Policy | Use case |
|---|---|---|---|
| **CI mode** (default) | Default; PR validation; TDD inner loop | `screenshot: only-on-failure` / `video: retain-on-failure` / `trace: on-first-retry` | Fast iteration; low disk cost; only failures kept for debug |
| **Evidence mode** | `EVIDENCE_MODE=on` | `screenshot: on` / `video: on` / `trace: on` | VERIFY-stage validation; QA hand-off; demos; training; audit |

Place this in `playwright.config.ts`:

```typescript
// playwright.config.ts — dual-mode evidence policy
const isEvidenceMode = process.env.EVIDENCE_MODE === "on";

export default defineConfig({
  use: {
    screenshot: isEvidenceMode ? "on" : "only-on-failure",
    video: isEvidenceMode ? "on" : "retain-on-failure",
    trace: isEvidenceMode ? "on" : "on-first-retry",
  },
  outputDir: 'test-results/',
});
```

Add npm script aliases for convenience:

```json
// package.json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:evidence": "EVIDENCE_MODE=on playwright test"
  }
}
```

### Step 5.5: When to Use Which Mode (workflow phase mapping)

| Workflow phase / context | Agent | Mode | Why |
|---|---|---|---|
| BUILD — TDD inner loop, write-test-then-code | `test-engineer` | CI (default) | Vòng lặp nhanh, fail-only debug — chạy mỗi vài giây, không cần video |
| BUILD — confirm new test passes | `test-engineer` | CI (default) | Same as above |
| VERIFY — formal validation against spec | `test-verifier`, `verifier` | **EVIDENCE** | Cần full video cho human gate / review / audit |
| REVIEW / SHIP | (none — reuse VERIFY artifacts) | — | Đọc lại video từ VERIFY stage |
| Standalone PR validation in CI | `test-verifier` (auto) | CI | Disk cost cho mỗi PR; chỉ debug fail |
| Demo / hand-off / QA documentation | Manual | EVIDENCE | On-demand cho hand-off |

**Convention enforcement:** Agents that run during VERIFY phase (`test-verifier`, `verifier`) MUST set `EVIDENCE_MODE=on` before invoking Playwright. Agents in BUILD phase (`test-engineer`) MUST NOT — would inflate disk + slow iteration.

After test execution, verify evidence directory contains:
```
test-results/
├── videos/          # .webm video — every test in evidence mode; failures only in CI mode
├── screenshots/     # .png screenshots — every test in evidence mode; failures only in CI mode
├── traces/          # .zip Playwright traces — every test in evidence mode; first-retry only in CI mode
└── reports/
    └── playwright-report/index.html
```

### Step 6: CI/CD Integration

```yaml
# .github/workflows/e2e-tests.yml
name: E2E Tests
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with: { node-version: '18' }
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run test:e2e
      - uses: actions/upload-artifact@v3
        if: always()
        with: { name: playwright-report, path: playwright-report/ }
```

### Step 7: Run and Verify
Execute the suite. Confirm all critical paths pass. Upload report artifacts including video evidence.

[RESPONSE FORMAT]
Return results matching output_schema: `{ status, test_suite: { files_created, tests_count, passing } }`.

[VERIFICATION]
- [ ] Critical user paths covered (registration, login, checkout, CRUD)
- [ ] Tests are stable and reliable (no flaky selectors or fixed waits)
- [ ] Tests run in CI/CD pipeline
- [ ] Tests use Page Object Model
- [ ] Tests are isolated (each creates own data and cleans up)
- [ ] Tests use `data-testid` selectors exclusively
- [ ] Tests have clear, descriptive names
- [ ] Auth strategy configured and working
- [ ] Playwright config includes `video: 'retain-on-failure'`
- [ ] Playwright config includes `trace: 'retain-on-failure'`
- [ ] Evidence directory (`test-results/`) contains videos, screenshots, traces for failures
- [ ] HTML report generated (`playwright-report/index.html`)
- [ ] test-case-design invoked per critical journey
- [ ] Interruption cases covered (refresh, back-button, tab-switch, network-drop, session-expiry) for >=top 2 critical journeys
- [ ] Concurrency cases covered (double-submit, same-user-2-tabs) for state-changing journeys
- [ ] Permission cases covered (role-downgrade, just-revoked-link) for >=1 protected journey
- [ ] A11y journey: keyboard-only full path passes
- [ ] I18n: >=1 RTL or long-text language verified
- [ ] Resilience: backend-slow + backend-5xx mocks tested
- [ ] Dual-mode evidence: `playwright.config.ts` reads `EVIDENCE_MODE` env var to switch between CI policy (retain-on-failure) and evidence policy (always-on)
- [ ] npm scripts include `test:e2e:evidence` alias for evidence mode runs
- [ ] When invoked in VERIFY-stage context, EVIDENCE_MODE=on is set before Playwright invocation
- [ ] Every TC-E2E-NNN in TC-REGISTRY has a corresponding `test("TC-E2E-NNN: ...")` block in a `.spec.ts` file
- [ ] TC-code coverage = 100% (count of `test()` blocks with TC-ID == count of TC-IDs in e2e registry); unautomated TCs use `test.todo()`

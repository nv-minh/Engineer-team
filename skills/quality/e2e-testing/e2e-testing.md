---
name: e2e-testing
description: End-to-end testing for complete user workflows. Use when testing critical user paths, verifying integration, or ensuring system reliability.
version: "3.0.0"
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
related_skills: ["browser-testing", "api-testing", "ci-cd-automation"]
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
2. Protect critical paths, not every pixel. E2E tests are expensive. Invest them in the workflows that matter most.
3. Use the Page Object Model. When UI changes, update one page object, not twenty test files.
4. Every test must be isolated: create its own data, run its own setup, clean up after itself.
5. Use stable `data-testid` selectors exclusively. DO NOT use CSS classes, IDs, or tag-based selectors.
6. DO NOT use `waitForTimeout`. Use `waitForSelector`, `waitForURL`, or Playwright auto-waiting assertions.
7. DO NOT write E2E tests for every minor UI variation. Focus on critical paths.
8. DO NOT let tests share state across test cases.
9. Configure auth using `e2e/config/auth.config.json` (strategies: none, credentials, oauth, storageState).
10. Every interaction should teach something: explain why a test pattern matters, not just what it does.

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

### Step 5: Configure Evidence Recording

Ensure `playwright.config.ts` includes evidence settings for failure capture:

```typescript
// playwright.config.ts — evidence settings
export default defineConfig({
  use: {
    video: 'retain-on-failure',       // Record video, keep only for failures
    trace: 'retain-on-failure',       // Capture trace, keep only for failures
    screenshot: 'only-on-failure',    // Screenshot on every failure
  },
  outputDir: 'test-results/',
});
```

After test execution, verify evidence directory contains:
```
test-results/
├── videos/          # .webm video for failing tests
├── screenshots/     # .png screenshots on failure
├── traces/          # .zip Playwright traces on failure
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

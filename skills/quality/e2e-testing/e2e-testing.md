---
name: e2e-testing
description: End-to-end testing for complete user workflows. Use when testing critical user paths, verifying integration, or ensuring system reliability.
version: "2.0.0"
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
---

# End-to-End Testing

## Overview

End-to-end (E2E) testing verifies complete user workflows by testing the application from start to finish. E2E tests simulate real user behavior and catch integration issues that unit tests miss.

## When to Use

- Testing critical user paths
- Verifying integrations
- Ensuring system reliability
- Catching regression bugs
- Validating complete workflows

## E2E Testing Strategy

### The Testing Pyramid

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                    E2E Tests (5%)                       │
│                  ─────────────────                      │
│                  Critical workflows                     │
│                                                         │
│              Integration Tests (15%)                    │
│              ───────────────────────                   │
│              Component interactions                     │
│                                                         │
│              Unit Tests (80%)                           │
│              ────────────────                          │
│              Individual functions                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Test Critical Paths

Focus on high-value workflows:

```typescript
// ✅ Good: Test critical user path
test.describe('User Registration Flow', () => {
  test('should complete full registration workflow', async ({ page }) => {
    // Step 1: Navigate to registration
    await page.goto('/register');

    // Step 2: Fill registration form
    await page.fill('[data-testid="name-input"]', 'John Doe');
    await page.fill('[data-testid="email-input"]', 'john@example.com');
    await page.fill('[data-testid="password-input"]', 'SecurePass123!');
    await page.fill('[data-testid="confirm-password-input"]', 'SecurePass123!');

    // Step 3: Submit form
    await page.click('[data-testid="register-button"]');

    // Step 4: Verify email sent
    await expect(page.locator('[data-testid="success-message"]')).toHaveText(
      'Registration successful! Please check your email.'
    );

    // Step 5: Verify email in inbox (mock)
    const email = await getLastEmail();
    expect(email.to).toBe('john@example.com');
    expect(email.subject).toBe('Verify your email');

    // Step 6: Click verification link
    await page.goto(email.verificationLink);

    // Step 7: Verify logged in
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome-message"]')).toContainText(
      'John Doe'
    );
  });
});
```

## Test Structure

### Page Object Model

Organize tests with page objects:

```typescript
// ✅ Good: Page Object Model
// pages/LoginPage.ts
class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.fill('[data-testid="email-input"]', email);
    await this.page.fill('[data-testid="password-input"]', password);
    await this.page.click('[data-testid="login-button"]');
  }

  async getErrorMessage() {
    return this.page.locator('[data-testid="error-message"]');
  }
}

// tests/login.spec.ts
test('should login successfully', async ({ page }) => {
  const loginPage = new LoginPage(page);

  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');

  await expect(page).toHaveURL('/dashboard');
});
```

### Test Organization

Organize tests by feature:

```typescript
// ✅ Good: Organized by feature
test.describe('Authentication', () => {
  test.beforeEach(async ({ page }) => {
    // Setup before each test
    await page.goto('/login');
  });

  test('should login with valid credentials', async ({ page }) => {
    // Test implementation
  });

  test('should show error with invalid credentials', async ({ page }) => {
    // Test implementation
  });
});

test.describe('Shopping Cart', () => {
  test.beforeEach(async ({ page }) => {
    // Setup before each test
    await page.goto('/products');
  });

  test('should add item to cart', async ({ page }) => {
    // Test implementation
  });

  test('should remove item from cart', async ({ page }) => {
    // Test implementation
  });
});
```

## Testing Best Practices

### 1. Test User Behavior

Test what users see and do:

```typescript
// ❌ Bad: Testing implementation
test('should set loading state', async ({ page }) => {
  await page.goto('/dashboard');
  const isLoading = await page.evaluate(() => (window as any).state.isLoading);
  expect(isLoading).toBe(true);
});

// ✅ Good: Testing user-visible behavior
test('should show loading spinner', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page.locator('[data-testid="loading-spinner"]')).toBeVisible();
});
```

### 2. Use Data Attributes

Use stable selectors:

```typescript
// ❌ Bad: Brittle selectors
await page.click('.btn-primary');
await page.click('#submit-btn');
await page.click('button[type="submit"]');

// ✅ Good: Stable data attributes
await page.click('[data-testid="submit-button"]');
```

### 3. Wait Appropriately

Wait for elements, not time:

```typescript
// ❌ Bad: Fixed waits
await page.waitForTimeout(1000);
await page.click('[data-testid="button"]');

// ✅ Good: Smart waits
await page.waitForSelector('[data-testid="button"]');
await page.click('[data-testid="button"]');

// ✅ Better: Auto-waiting with assertions
await page.click('[data-testid="button"]');
await expect(page.locator('[data-testid="result"]')).toBeVisible();
```

### 4. Isolate Tests

Each test should be independent:

```typescript
// ✅ Good: Isolated test
test('should create new todo', async ({ page }) => {
  // Create unique data for this test
  const todoText = `Test Todo ${Date.now()}`;

  await page.goto('/todos');
  await page.fill('[data-testid="new-todo-input"]', todoText);
  await page.click('[data-testid="add-todo-button"]');

  await expect(page.locator(`text=${todoText}`)).toBeVisible();
});
```

## Common Test Scenarios

### 1. Form Submission

```typescript
test('should submit contact form', async ({ page }) => {
  await page.goto('/contact');

  await page.fill('[data-testid="name-input"]', 'John Doe');
  await page.fill('[data-testid="email-input"]', 'john@example.com');
  await page.fill('[data-testid="message-input"]', 'Test message');

  await page.click('[data-testid="submit-button"]');

  await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
});
```

### 2. Authentication Flow

```typescript
test('should complete login flow', async ({ page }) => {
  await page.goto('/login');

  await page.fill('[data-testid="email-input"]', 'user@example.com');
  await page.fill('[data-testid="password-input"]', 'password123');

  await page.click('[data-testid="login-button"]');

  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('[data-testid="user-menu"]')).toContainText('user@example.com');
});
```

### 3. CRUD Operations

```typescript
test('should complete CRUD workflow', async ({ page }) => {
  // Create
  await page.goto('/posts');
  await page.click('[data-testid="new-post-button"]');
  await page.fill('[data-testid="title-input"]', 'Test Post');
  await page.fill('[data-testid="content-input"]', 'Test Content');
  await page.click('[data-testid="save-button"]');

  // Read
  await expect(page.locator('[data-testid="post-title"]')).toHaveText('Test Post');

  // Update
  await page.click('[data-testid="edit-button"]');
  await page.fill('[data-testid="title-input"]', 'Updated Test Post');
  await page.click('[data-testid="save-button"]');

  await expect(page.locator('[data-testid="post-title"]')).toHaveText('Updated Test Post');

  // Delete
  await page.click('[data-testid="delete-button"]');
  await page.click('[data-testid="confirm-delete-button"]');

  await expect(page.locator('[data-testid="post-list"]')).not.toContainText('Updated Test Post');
});
```

### 4. Error Handling

```typescript
test('should handle API errors gracefully', async ({ page }) => {
  // Mock API error
  await page.route('**/api/users', route => {
    route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Internal server error' })
    });
  });

  await page.goto('/users');

  await expect(page.locator('[data-testid="error-message"]')).toBeVisible();
  await expect(page.locator('[data-testid="error-message"]')).toHaveText(
    'Failed to load users. Please try again.'
  );

  // Verify retry button works
  await page.route('**/api/users', route => {
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify([{ id: '1', name: 'User 1' }])
    });
  });

  await page.click('[data-testid="retry-button"]');

  await expect(page.locator('[data-testid="user-list"]')).toBeVisible();
});
```

## CI/CD Integration

### Running E2E Tests in CI

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

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright-report/
```

## Coaching Notes

> **ABC - Always Be Coaching:** E2E tests are your safety net for the most valuable user journeys -- write fewer tests that cover more ground, not more tests that cover less.

1. **Protect Critical Paths, Not Every Pixel:** E2E tests are expensive to run and maintain. Invest them in the workflows that generate revenue or prevent catastrophic failure, not in verifying that every button has the right shade of blue.
2. **Page Objects Turn Fragility Into Maintainability:** When the UI changes, you should update one page object, not twenty test files. The Page Object Model is not optional for a healthy E2E suite; it is essential.
3. **Isolation Is Non-Negotiable:** Every test must create its own data, run its own setup, and clean up after itself. A test that depends on another test's leftovers is a test that will fail unpredictably in CI.

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Testing implementation | Brittle tests | Test user behavior |
| Brittle selectors | Tests break easily | Use data attributes |
| Fixed waits | Slow, flaky tests | Use smart waits |
| Not isolated tests | Tests interfere | Isolate test data |
| Too many E2E tests | Slow feedback | Focus on critical paths |

## Verification

After E2E testing:

- [ ] Critical user paths covered
- [ ] Tests are stable and reliable
- [ ] Tests run in CI/CD
- [ ] Tests are fast enough
- [ ] Tests use page objects
- [ ] Tests are isolated
- [ ] Tests use data attributes
- [ ] Tests have clear descriptions

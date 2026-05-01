---
name: browser-testing
description: Browser testing using DevTools and headless browsers. Use when testing web applications, debugging frontend issues, or verifying user interactions.
version: "2.0.0"
category: "quality"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["browser test", "playwright", "devtools", "frontend debug"]
intent: "Validate real user experience by automating browser interactions and catching rendering bugs that unit tests cannot detect."
scenarios:
  - "Automating a login flow test that verifies redirect, cookie behavior, and error messages"
  - "Testing responsive layout across mobile, tablet, and desktop viewports"
  - "Capturing screenshots on test failure to debug a CSS regression in production"
best_for: "frontend QA, cross-browser testing, responsive testing, visual debugging, user interaction verification"
estimated_time: "15-30 min"
anti_patterns:
  - "Using brittle CSS selectors that break whenever a developer changes a class name"
  - "Using fixed sleep waits instead of waiting for elements or network idle"
  - "Testing internal implementation state instead of user-visible behavior"
related_skills: ["e2e-testing", "frontend-patterns", "performance-optimization"]
---

# Browser Testing

## Overview

Browser testing verifies web applications work correctly across different browsers and devices. Using DevTools and headless browsers enables automated testing, debugging, and quality assurance.

## When to Use

- Testing web applications
- Debugging frontend issues
- Verifying user interactions
- Testing responsive design
- Cross-browser compatibility

## Browser Testing Tools

### 1. Chrome DevTools Protocol

Use DevTools for live debugging:

```typescript
// ✅ Good: Using DevTools MCP for testing
import { chromium } from 'playwright';

async function testLoginPage() {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();

  // Navigate to login page
  await page.goto('http://localhost:3000/login');

  // Fill login form
  await page.fill('input[name="email"]', 'user@example.com');
  await page.fill('input[name="password"]', 'password123');

  // Submit form
  await page.click('button[type="submit"]');

  // Wait for navigation
  await page.waitForURL('**/dashboard');

  // Verify success
  const title = await page.title();
  expect(title).toBe('Dashboard');

  await browser.close();
}
```

### 2. Playwright for E2E Testing

Automated browser testing:

```typescript
// ✅ Good: Playwright E2E test
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('should login with valid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[data-testid="email-input"]', 'user@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');
    await page.click('[data-testid="login-button"]');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
  });

  test('should show error with invalid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[data-testid="email-input"]', 'user@example.com');
    await page.fill('[data-testid="password-input"]', 'wrongpassword');
    await page.click('[data-testid="login-button"]');

    await expect(page.locator('[data-testid="error-message"]')).toHaveText(
      'Invalid email or password'
    );
  });
});
```

## Testing Scenarios

### 1. User Interactions

Test user workflows:

```typescript
test.describe('Shopping Cart', () => {
  test('should add item to cart', async ({ page }) => {
    await page.goto('/products');

    await page.click('[data-product-id="1"] [data-testid="add-to-cart"]');
    await expect(page.locator('[data-testid="cart-count"]')).toHaveText('1');
  });

  test('should remove item from cart', async ({ page }) => {
    await page.goto('/cart');

    await page.click('[data-testid="remove-item-1"]');
    await expect(page.locator('[data-testid="cart-count"]')).toHaveText('0');
  });

  test('should checkout successfully', async ({ page }) => {
    await page.goto('/cart');

    await page.click('[data-testid="checkout-button"]');
    await page.fill('[data-testid="card-number"]', '4242424242424242');
    await page.fill('[data-testid="card-expiry"]', '12/25');
    await page.fill('[data-testid="card-cvc"]', '123');
    await page.click('[data-testid="pay-button"]');

    await expect(page).toHaveURL('/order-confirmation');
  });
});
```

### 2. Responsive Design

Test different screen sizes:

```typescript
const devices = [
  { name: 'iPhone', viewport: { width: 375, height: 667 } },
  { name: 'iPad', viewport: { width: 768, height: 1024 } },
  { name: 'Desktop', viewport: { width: 1920, height: 1080 } }
];

for (const device of devices) {
  test(`should work on ${device.name}`, async ({ page }) => {
    await page.setViewportSize(device.viewport);
    await page.goto('/');

    // Test that layout works on this device
    await expect(page.locator('[data-testid="main-navigation"]')).toBeVisible();
  });
}
```

### 3. Form Validation

Test form behavior:

```typescript
test.describe('Contact Form', () => {
  test('should validate required fields', async ({ page }) => {
    await page.goto('/contact');

    await page.click('[data-testid="submit-button"]');

    await expect(page.locator('[data-testid="name-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="email-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="message-error"]')).toBeVisible();
  });

  test('should validate email format', async ({ page }) => {
    await page.goto('/contact');

    await page.fill('[data-testid="email-input"]', 'not-an-email');
    await page.click('[data-testid="submit-button"]');

    await expect(page.locator('[data-testid="email-error"]')).toHaveText(
      'Invalid email format'
    );
  });

  test('should submit successfully with valid data', async ({ page }) => {
    await page.goto('/contact');

    await page.fill('[data-testid="name-input"]', 'John Doe');
    await page.fill('[data-testid="email-input"]', 'john@example.com');
    await page.fill('[data-testid="message-input"]', 'Test message');

    await page.click('[data-testid="submit-button"]');

    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
  });
});
```

### 4. Network Interactions

Test API calls:

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
});
```

## Testing Best Practices

### 1. Use Data Attributes

Use data attributes for selectors:

```typescript
// ❌ Bad: Brittle selectors
await page.click('.btn-primary');
await page.click('#submit-btn');
await page.click('button[type="submit"]');

// ✅ Good: Stable data attributes
await page.click('[data-testid="submit-button"]');
```

### 2. Wait for Elements

Wait for elements to be ready:

```typescript
// ❌ Bad: No waiting
await page.click('[data-testid="submit-button"]');
expect(await page.textContent('[data-testid="result"]')).toBe('Success');

// ✅ Good: Explicit wait
await page.click('[data-testid="submit-button"]');
await page.waitForSelector('[data-testid="result"]');
await expect(page.locator('[data-testid="result"]')).toHaveText('Success');
```

### 3. Test User-Visible Behavior

Test what users see, not implementation:

```typescript
// ❌ Bad: Testing implementation
expect(state.isLoading).toBe(false);
expect(state.data).toHaveLength(10);

// ✅ Good: Testing user-visible behavior
await expect(page.locator('[data-testid="loading-spinner"]')).not.toBeVisible();
await expect(page.locator('[data-testid="user-list"]')).toHaveCount(10);
```

## Debugging Tools

### 1. Screenshots

Capture screenshots for debugging:

```typescript
test('should capture screenshot on failure', async ({ page }) => {
  try {
    await page.goto('/complex-page');
    await performComplexInteractions(page);
  } catch (error) {
    await page.screenshot({ path: 'failure-screenshot.png' });
    throw error;
  }
});
```

### 2. Tracing

Enable tracing for debugging:

```typescript
test('should trace test execution', async ({ page }) => {
  await page.context().tracing.start({ screenshots: true, snapshots: true });

  try {
    await page.goto('/');
    await page.click('[data-testid="button"]');
  } finally {
    await page.context().tracing.stop({ path: 'trace.zip' });
  }
});
```

### 3. Console Logs

Capture console logs:

```typescript
test('should capture console errors', async ({ page }) => {
  const errors: string[] = [];

  page.on('console', msg => {
    if (msg.type() === 'error') {
      errors.push(msg.text());
    }
  });

  await page.goto('/page-with-errors');

  expect(errors).toHaveLength(0);
});
```

## Cross-Browser Testing

Test across different browsers:

```typescript
const browsers = ['chromium', 'firefox', 'webkit'];

for (const browserType of browsers) {
  test(`should work in ${browserType}`, async ({ page }) => {
    await page.goto('/');

    await expect(page.locator('[data-testid="main-content"]')).toBeVisible();
  });
}
```

## Coaching Notes

> **ABC - Always Be Coaching:** Browser tests simulate real users -- think like a user, test like a user, and never trust that the frontend works until you see it rendered.

1. **Test What Users See, Not What the Code Does:** A user does not care about component state or store values. They care that the button is visible, the form submits, and the error message appears. Assert on visible behavior.
2. **Use Stable Selectors or Regret It Later:** Data attributes (`data-testid`) are your contract between test and UI. CSS classes change during redesigns, IDs change during refactors, but `data-testid` changes only when the element is removed.
3. **Screenshots Are Your Safety Net:** Always capture screenshots on failure. A screenshot tells you in one second what a stack trace takes five minutes to diagnose. Enable tracing for complex flaky-test investigations.

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Brittle selectors | Tests break with CSS changes | Use data attributes |
| No waiting | Flaky tests | Wait for elements |
| Testing implementation | Brittle tests | Test user-visible behavior |
| No cleanup | Side effects between tests | Isolate tests |
| Hardcoded waits | Slow tests | Use smart waits |

## Verification

After browser testing:

- [ ] Tests cover user workflows
- [ ] Tests are stable and reliable
- [ ] Tests run across browsers
- [ ] Tests are fast enough
- [ ] Screenshots captured on failure
- [ ] Console errors checked
- [ ] Network interactions tested

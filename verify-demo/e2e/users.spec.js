// TC-E2E-001 to TC-E2E-004: E2E tests for User Manager UI
const { test, expect } = require('@playwright/test');
const { UsersPage } = require('./pages/UsersPage');

test.beforeEach(async ({ page }) => {
  // Reset server state for test isolation
  await page.request.delete('/users');
});

// TC-E2E-001: Page loads successfully
test('TC-E2E-001: homepage loads with form and empty user list', async ({ page }) => {
  const usersPage = new UsersPage(page);
  await usersPage.navigate();

  await expect(page).toHaveTitle(/User Manager/);
  await expect(page.getByTestId('user-name-input')).toBeVisible();
  await expect(page.getByTestId('user-email-input')).toBeVisible();
  await expect(page.getByTestId('submit-button')).toBeVisible();
});

// TC-E2E-002: Create user via form shows success message
test('TC-E2E-002: creating user shows success message and updates list', async ({ page }) => {
  const usersPage = new UsersPage(page);
  await usersPage.navigate();

  await usersPage.fillForm('Test User', 'testuser@example.com');
  await usersPage.submitForm();

  const message = await usersPage.getMessage();
  await expect(message).toContainText('created successfully');
  await expect(message).toHaveClass(/success/);

  // User appears in list
  const list = await usersPage.getUserList();
  await expect(list).toContainText('Test User');
  await expect(list).toContainText('testuser@example.com');
});

// TC-E2E-003: Duplicate email shows error message
test('TC-E2E-003: duplicate email shows error message', async ({ page }) => {
  const usersPage = new UsersPage(page);
  await usersPage.navigate();

  // Create first user
  await usersPage.fillForm('User One', 'dup@example.com');
  await usersPage.submitForm();
  await expect(page.getByTestId('message')).toContainText('created successfully');

  // Wait for message to clear, then try duplicate
  await page.waitForTimeout(500);
  await usersPage.fillForm('User Two', 'dup@example.com');
  await usersPage.submitForm();

  const message = await usersPage.getMessage();
  await expect(message).toContainText('already exists');
  await expect(message).toHaveClass(/error/);
});

// TC-E2E-004 (INTENTIONALLY FLAKY for test-verifier demo):
// This test uses a selector that requires a specific user to exist
// It demonstrates the test-verifier retry logic
test('TC-E2E-004: created user appears with correct data in list', async ({ page }) => {
  const usersPage = new UsersPage(page);
  await usersPage.navigate();

  await usersPage.fillForm('Alice Brown', 'alice.brown@example.com');
  await usersPage.submitForm();

  // Wait for success and list update
  await expect(page.getByTestId('message')).toContainText('created successfully');

  // Verify user appears in list with ID-based selector (generated dynamically)
  const userItem = page.getByTestId('user-item-1');
  await expect(userItem).toBeVisible();
  await expect(userItem).toContainText('Alice Brown');
  await expect(userItem).toContainText('alice.brown@example.com');
});

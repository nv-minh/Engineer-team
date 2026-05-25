# Testing Patterns Reference

Shared testing patterns and strategies referenced by testing-related skills and agents.

**Source:** Merged from EM-Team patterns + [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) testing reference.

---

## Test Types

| Type | Scope | Speed | When to Use |
|------|-------|-------|-------------|
| Unit | Single function/component | <10ms | Every function |
| Integration | Module interactions | <1s | API endpoints, DB queries |
| E2E | Full user flow | 5-30s | Critical paths |
| Property | Invariants across inputs | 1-10s | Algorithms, data transforms |
| Visual | UI appearance | 1-5s | Component library, design system |

## Test Structure (AAA Pattern)

```typescript
describe('Feature', () => {
  it('should [expected behavior] when [condition]', () => {
    // Arrange: Set up test data and preconditions
    const input = createTestInput();

    // Act: Perform the action being tested
    const result = functionUnderTest(input);

    // Assert: Verify the outcome
    expect(result).toEqual(expected);
  });
});
```

## Test Naming Conventions

```typescript
// Pattern: [unit] [expected behavior] [condition]
describe('TaskService.createTask', () => {
  it('creates a task with default pending status', () => {});
  it('throws ValidationError when title is empty', () => {});
  it('trims whitespace from title', () => {});
  it('generates a unique ID for each task', () => {});
});

// Good: Reads like a specification
describe('TaskService.completeTask', () => {
  it('sets status to completed and records timestamp', ...);
  it('throws NotFoundError for non-existent task', ...);
  it('is idempotent — completing an already-completed task is a no-op', ...);
  it('sends notification to task assignee', ...);
});

// Bad: Vague names
describe('TaskService', () => {
  it('works', ...);          // ❌
  it('handles errors', ...); // ❌
  it('test 3', ...);         // ❌
});
```

## TDD RED-GREEN-REFACTOR

```
1. RED:   Write failing test (defines expected behavior)
2. GREEN: Write minimal code to make test pass
3. REFACTOR: Clean up while keeping tests green
4. COMMIT: Atomic commit with test + implementation
```

## Coverage Targets

| Component | Target | Minimum |
|-----------|--------|---------|
| Business logic | 90%+ | 80% |
| API routes | 85%+ | 70% |
| UI components | 70%+ | 50% |
| Utilities | 95%+ | 90% |
| Config/Setup | 50%+ | 30% |

## Test Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|---|---|---|
| Testing implementation details | Breaks on refactoring even if behavior unchanged | Test inputs/outputs, not internal structure |
| Mocking everything | Tests pass but prod fails | Mock boundaries only; prefer real > fake > stub > mock |
| Shared mutable state | Tests pass in isolation, fail together | Setup/teardown per test, fresh state |
| No assertions | False confidence | Every test must assert something specific |
| Giant test functions | Hard to diagnose failures | One assertion per concept |
| `setTimeout` in tests | Flaky, timing-dependent | Use fake timers or async/await |
| Snapshot abuse | Large snapshots nobody reviews, break on any change | Assert specific values instead |
| Testing framework code | Wastes time testing third-party behavior | Only test YOUR code |
| Skipping tests to pass CI | Hides real bugs | Fix or delete the test |
| `test.skip` permanently | Dead code | Remove or fix it |
| Overly broad assertions | Doesn't catch regressions | Be specific: `toBe(404)` not `toBeTruthy()` |
| No async error handling | Swallowed errors, false passes | Always `await` async tests |

## Fixture Patterns

```typescript
// Factory function (recommended)
function createTestUser(overrides?: Partial<User>): User {
  return {
    id: 'test-1',
    name: 'Test User',
    email: 'test@example.com',
    ...overrides,
  };
}

// Usage
const admin = createTestUser({ role: 'admin' });
const guest = createTestUser({ role: 'guest' });
```

## Assertion Patterns

```typescript
// Good: specific assertion
expect(result.status).toBe(404);
expect(result.body.message).toContain('not found');

// Bad: vague assertion
expect(result).toBeDefined();
expect(Object.keys(result).length).toBeGreaterThan(0);
```

## Common Assertions Reference

```typescript
// Equality
expect(result).toBe(expected);           // Strict equality (===)
expect(result).toEqual(expected);        // Deep equality (objects/arrays)
expect(result).toStrictEqual(expected);  // Deep equality + type matching

// Truthiness
expect(result).toBeTruthy();
expect(result).toBeFalsy();
expect(result).toBeNull();
expect(result).toBeDefined();
expect(result).toBeUndefined();

// Numbers
expect(result).toBeGreaterThan(5);
expect(result).toBeLessThanOrEqual(10);
expect(result).toBeCloseTo(0.3, 5);      // Floating point

// Strings
expect(result).toMatch(/pattern/);
expect(result).toContain('substring');

// Arrays / Objects
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(object).toHaveProperty('key', 'value');

// Errors
expect(() => fn()).toThrow();
expect(() => fn()).toThrow(ValidationError);
expect(() => fn()).toThrow('specific message');

// Async
await expect(asyncFn()).resolves.toBe(value);
await expect(asyncFn()).rejects.toThrow(Error);
```

## Mocking Patterns

### Mock at Boundaries Only

```
Mock these:                    Don't mock these:
├── Database calls             ├── Internal utility functions
├── HTTP requests              ├── Business logic
├── File system operations     ├── Data transformations
├── External API calls         ├── Validation functions
└── Time/Date (when needed)    └── Pure functions
```

Preference order (most to least preferred):
1. **Real implementation** → Highest confidence, catches real bugs
2. **Fake** → In-memory version of a dependency (e.g., fake DB)
3. **Stub** → Returns canned data, no behavior
4. **Mock (interaction)** → Verifies method calls — use sparingly

Use mocks only when: the real implementation is too slow, non-deterministic, or has side effects you can't control (external APIs, email sending).

### Mock Functions

```typescript
const mockFn = jest.fn();
mockFn.mockReturnValue(42);
mockFn.mockResolvedValue({ data: 'test' });
mockFn.mockImplementation((x) => x * 2);

expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenCalledTimes(3);
```

### Mock Modules

```typescript
// Mock an entire module
jest.mock('./database', () => ({
  query: jest.fn().mockResolvedValue([{ id: 1, title: 'Test' }]),
}));

// Mock specific exports
jest.mock('./utils', () => ({
  ...jest.requireActual('./utils'),
  generateId: jest.fn().mockReturnValue('test-id'),
}));
```

## React / Component Testing

```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';

describe('TaskForm', () => {
  it('submits the form with entered data', async () => {
    const onSubmit = jest.fn();
    render(<TaskForm onSubmit={onSubmit} />);

    // Find elements by accessible role/label (not test IDs)
    await screen.findByRole('textbox', { name: /title/i });
    fireEvent.change(screen.getByRole('textbox', { name: /title/i }), {
      target: { value: 'New Task' },
    });
    fireEvent.click(screen.getByRole('button', { name: /create/i }));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({ title: 'New Task' });
    });
  });

  it('shows validation error for empty title', async () => {
    render(<TaskForm onSubmit={jest.fn()} />);
    fireEvent.click(screen.getByRole('button', { name: /create/i }));
    expect(await screen.findByText(/title is required/i)).toBeInTheDocument();
  });
});
```

## API / Integration Testing

```typescript
import request from 'supertest';
import { app } from '../src/app';

describe('POST /api/tasks', () => {
  it('creates a task and returns 201', async () => {
    const response = await request(app)
      .post('/api/tasks')
      .send({ title: 'Test Task' })
      .set('Authorization', `Bearer ${testToken}`)
      .expect(201);

    expect(response.body).toMatchObject({
      id: expect.any(String),
      title: 'Test Task',
      status: 'pending',
    });
  });

  it('returns 422 for invalid input', async () => {
    const response = await request(app)
      .post('/api/tasks')
      .send({ title: '' })
      .set('Authorization', `Bearer ${testToken}`)
      .expect(422);

    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('returns 401 without authentication', async () => {
    await request(app)
      .post('/api/tasks')
      .send({ title: 'Test' })
      .expect(401);
  });
});
```

## E2E Testing (Playwright)

```typescript
import { test, expect } from '@playwright/test';

test('user can create and complete a task', async ({ page }) => {
  // Navigate and authenticate
  await page.goto('/');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'testpass123');
  await page.click('button:has-text("Log in")');

  // Create a task
  await page.click('button:has-text("New Task")');
  await page.fill('[name="title"]', 'Buy groceries');
  await page.click('button:has-text("Create")');

  // Verify task appears
  await expect(page.locator('text=Buy groceries')).toBeVisible();

  // Complete the task
  await page.click('[aria-label="Complete Buy groceries"]');
  await expect(page.locator('text=Buy groceries')).toHaveCSS(
    'text-decoration-line', 'line-through'
  );
});
```

## Parameterized Tests

```typescript
// Jest
test.each([
  [1, 2, 3],
  [0, 0, 0],
  [-1, 1, 0],
])('add(%i, %i) = %i', (a, b, expected) => {
  expect(add(a, b)).toBe(expected);
});

// pytest
@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_add(a, b, expected):
    assert add(a, b) == expected
```

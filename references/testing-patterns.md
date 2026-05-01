# Testing Patterns Reference

Shared testing patterns and strategies referenced by testing-related skills and agents.

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
    // Arrange
    const input = createTestInput();

    // Act
    const result = functionUnderTest(input);

    // Assert
    expect(result).toEqual(expected);
  });
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
| Testing implementation details | Breaks on refactoring | Test behavior/outputs |
| Mocking everything | Tests pass but prod fails | Mock boundaries only (API, DB) |
| Shared mutable state | Tests pass in isolation, fail together | Fresh state per test |
| No assertions | False confidence | Every test must assert something |
| Giant test functions | Hard to diagnose failures | One assertion per concept |
| `setTimeout` in tests | Flaky, timing-dependent | Use fake timers or async/await |

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

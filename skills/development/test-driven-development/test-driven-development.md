---
name: test-driven-development
description: Test-Driven Development (TDD) using RED-GREEN-REFACTOR cycle. Use when writing any production code, adding new features, or fixing bugs.
version: "2.0.0"
category: "development"
origin: "superpowers"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["tdd", "red-green-refactor", "write tests first", "failing test"]
intent: "Instill the discipline of writing tests before production code so every line of code is justified by a requirement."
scenarios:
  - "Adding a new user registration endpoint and needing to validate all input fields"
  - "Fixing a pricing calculation bug by first writing a regression test that reproduces it"
  - "Refactoring a payment service module while ensuring existing behavior stays green"
best_for: "new features, bug fixes, refactoring, regression prevention"
estimated_time: "20-45 min"
anti_patterns:
  - "Writing production code first and retrofitting tests afterward"
  - "Skipping the REFACTOR phase and leaving hard-coded values in place"
  - "Testing implementation details instead of observable behavior"
related_skills: ["code-review", "systematic-debugging", "spec-driven-development"]
---

# Test-Driven Development

## Overview

Test-Driven Development (TDD) is a development process where you write tests before writing production code. The TDD cycle (RED-GREEN-REFACTOR) ensures that code is tested, maintainable, and meets requirements.

## The Iron Law

**NO PRODUCTION CODE WITHOUT FAILING TEST**

Never write production code without first writing a failing test that justifies its existence. This is the foundation of TDD.

## When to Use

- Writing any new feature or functionality
- Fixing bugs (write regression test first)
- Refactoring existing code
- Adding new methods or functions
- Modifying existing behavior

**When NOT to use:** Configuration files, documentation, or simple data structures that don't contain logic.

## The TDD Cycle: RED-GREEN-REFACTOR

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│    RED ──→ GREEN ──→ REFACTOR ──→ (repeat)            │
│      ↓         ↓           ↓                           │
│   Write      Make         Clean                        │
│  failing   it pass    up code                         │
│    test                                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Phase 1: RED - Write a Failing Test

Write a test that fails because the functionality doesn't exist yet.

**Guidelines:**
- Write the **minimum** test needed to drive new functionality
- Test **behavior**, not implementation details
- Use **descriptive** test names that explain what is being tested
- Run the test and confirm it fails with the expected error

**Example:**
```typescript
// RED: Write failing test
describe('UserService', () => {
  it('should create a new user with valid data', async () => {
    const userData = {
      name: 'John Doe',
      email: 'john@example.com'
    };

    const user = await createUser(userData);

    expect(user).toBeDefined();
    expect(user.id).toBeDefined();
    expect(user.name).toBe('John Doe');
    expect(user.email).toBe('john@example.com');
  });
});
```

**Run and confirm failure:**
```bash
npm test -- --grep "should create a new user"
# Expected: FAIL - "createUser is not defined"
```

### Phase 2: GREEN - Make the Test Pass

Write the **minimum** production code needed to make the test pass.

**Guidelines:**
- Write the **simplest** code that makes the test pass
- Don't worry about code quality yet (that comes in refactoring)
- Hardcode values if needed (you'll generalize in refactor)
- Run the test frequently to see it pass

**Example:**
```typescript
// GREEN: Write minimal implementation
export async function createUser(userData: UserData): Promise<User> {
  return {
    id: '1',
    name: userData.name,
    email: userData.email
  };
}
```

**Run and confirm success:**
```bash
npm test -- --grep "should create a new user"
# Expected: PASS
```

### Phase 3: REFACTOR - Clean Up the Code

Improve the code structure and quality while keeping tests green.

**Guidelines:**
- Remove duplication
- Extract magic values to named constants
- Improve names and structure
- **Keep tests green** throughout refactoring
- Run tests after each small refactoring

**Example:**
```typescript
// REFACTOR: Improve code quality
const generateId = (): string => crypto.randomUUID();

export async function createUser(userData: UserData): Promise<User> {
  const user: User = {
    id: generateId(),
    name: userData.name,
    email: userData.email
  };

  return user;
}
```

**Run and confirm still passing:**
```bash
npm test -- --grep "should create a new user"
# Expected: PASS (still green after refactoring)
```

## Test Organization

### Test Structure (AAA Pattern)

Organize tests using Arrange-Act-Assert pattern:

```typescript
it('should calculate total with tax', () => {
  // Arrange: Set up the test data
  const price = 100;
  const taxRate = 0.1;

  // Act: Execute the function being tested
  const total = calculateTotal(price, taxRate);

  // Assert: Verify the result
  expect(total).toBe(110);
});
```

### Test Descriptions

Write test descriptions that answer:
1. What is being tested?
2. Under what conditions?
3. What is the expected outcome?

```
✅ Good: "should return 404 when user not found"
✅ Good: "should validate email format"
❌ Bad: "test 1"
❌ Bad: "it works"
```

### Test Files Organization

```
src/
├── services/
│   └── userService.ts
└── services.test.ts          # Co-located tests

OR

tests/
└── unit/
    └── services/
        └── userService.test.ts  # Separate test directory
```

## Testing Best Practices

### DO ✅

- Test behavior, not implementation
- Write descriptive test names
- Use AAA (Arrange-Act-Assert) pattern
- Test edge cases and error conditions
- Keep tests independent and isolated
- Use test doubles (mocks, stubs) appropriately
- Keep tests fast and focused

### DON'T ❌

- Test implementation details
- Write brittle tests that break on refactoring
- Test multiple things in one test
- Duplicate implementation logic in tests
- Over-mock (tests become tests of mocks)
- Write tests that are too complex

## Test Coverage

### Coverage Goals

- **Critical paths:** 100% coverage
- **Business logic:** 90%+ coverage
- **Utilities/helpers:** 95%+ coverage
- **Configuration:** 50%+ coverage

### Coverage Types

1. **Line Coverage:** Percentage of code lines executed
2. **Branch Coverage:** Percentage of conditional branches taken
3. **Function Coverage:** Percentage of functions called
4. **Statement Coverage:** Percentage of statements executed

### Coverage Tools

```bash
# Generate coverage report
npm test -- --coverage

# View coverage in browser
open coverage/lcov-report/index.html
```

## Testing Patterns

### Parameterized Tests

Test multiple scenarios with one test:

```typescript
describe('calculateDiscount', () => {
  const cases = [
    { amount: 100, discount: 0.1, expected: 90 },
    { amount: 100, discount: 0.2, expected: 80 },
    { amount: 100, discount: 0.5, expected: 50 }
  ];

  test.each(cases)(
    'should calculate discount for amount $amount with discount $discount',
    ({ amount, discount, expected }) => {
      expect(calculateDiscount(amount, discount)).toBe(expected);
    }
  );
});
```

### Async Tests

Handle asynchronous code properly:

```typescript
it('should fetch user data', async () => {
  const user = await fetchUser('1');

  expect(user).toBeDefined();
  expect(user.id).toBe('1');
});
```

### Error Testing

Test error conditions:

```typescript
it('should throw error for invalid input', () => {
  expect(() => {
    calculateTotal(-100, 0.1);
  }).toThrow('Amount must be positive');
});
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write tests later" | Tests written later are rarely written. Write them first. |
| "This is too simple to test" | Simple code breaks too. Tests prevent regressions. |
| "Tests take too long" | Tests save debugging time. They're an investment, not a cost. |
| "I know this works" | You might know it works now. Will you know in 6 months? |

## Coaching Notes

> **ABC - Always Be Coaching:** TDD teaches you to think in terms of desired behavior before implementation, making every line of code intentional and verified.

1. **The failing test is the spec:** If you cannot write a failing test that describes what you want, you do not yet understand the requirement. Stop and clarify before coding.
2. **Small steps compound fast:** A RED-GREEN-REFACTOR cycle that takes two minutes beats a thirty-minute coding binge every time. Tiny steps keep the feedback loop tight and mistakes cheap to fix.
3. **Refactor with green safety:** The REFACTOR phase only works because the tests are green. If you skip it, you accumulate hard-coded hacks. If you refactor without tests, you break things silently. Green tests are your safety net -- use it.

## Red Flags

- Writing code without a failing test
- Tests that are too complex to understand
- Tests that test implementation details
- Skipping tests to save time
- Tests that are always green (false positives)
- Tests that are flaky (unreliable)

## Auto-Retry Loop Mechanism

EM-Team includes an automatic retry mechanism that captures test failures and feeds them back to the AI for fixing, implementing the RED-GREEN-REFACTOR cycle with intelligent retry logic.

### How It Works

When a test fails, the system automatically:

1. **Captures Error Context**
   - Saves test output to JSON file
   - Records exit code, timestamp, and retry count
   - Stores git context (branch, commit)
   - Persists in `.claude/tdd-context/` directory

2. **Implements Exponential Backoff**
   - Retry 1: Wait 1 second
   - Retry 2: Wait 2 seconds
   - Retry 3: Wait 4 seconds
   - Max retries: 3 (then requires manual intervention)

3. **Provides AI-Friendly Output**
   - Formats failure details for AI consumption
   - Includes test command, exit code, and error output
   - Displays clear next steps for fixing the issue

### Exit Codes

The retry wrapper uses structured exit codes:

- **0**: Success (tests passed)
- **42**: Retry requested (test failed, will retry)
- **43**: Max retries exceeded (manual intervention required)

### Usage in Pre-Commit Hook

The pre-commit hook automatically uses the retry wrapper:

```bash
# 3. Unit Tests with TDD Auto-Retry
if command_exists npm && npm run test:unit >/dev/null 2>&1; then
    echo "🧪 Running unit tests with TDD auto-retry..."

    # Source TDD retry wrapper
    if [[ -f "./tests/tdd-retry-wrapper.sh" ]]; then
        source "./tests/tdd-retry-wrapper.sh"

        # Run tests with retry logic
        if run_tdd_with_retry "npm run test:unit -- --passWithNoTests" 3; then
            echo "✓ Unit tests passed"
        else
            local exit_code=$?
            case $exit_code in
                42)
                    echo "⚠ Tests failed - retry available"
                    echo "   Error context has been saved for AI to fix"
                    exit 1
                    ;;
                43)
                    echo "✗ Tests failed - max retries exceeded"
                    echo "   Manual intervention required"
                    exit 1
                    ;;
            esac
        fi
    fi
fi
```

### Manual Usage

You can also use the retry wrapper manually:

```bash
# Run tests with retry
./tests/tdd-retry-wrapper.sh run "npm test" 3

# Check retry status
./tests/tdd-context-manager.sh status

# Format latest failure for AI
./tests/tdd-context-manager.sh format

# Reset retry context
./tests/tdd-context-manager.sh reset
```

### AI Feedback Loop

The system creates a seamless feedback loop for AI agents:

1. **RED Phase**: Test fails → Wrapper captures error → Saves to JSON
2. **AI Analysis**: AI reads JSON → Understands failure → Generates fix
3. **GREEN Phase**: AI applies fix → Re-runs test → Wrapper checks result
4. **Success**: Tests pass → Counter resets → Cycle complete

### Error Context Format

Failures are saved as JSON:

```json
{
  "timestamp": "2026-04-19T13:00:00Z",
  "retry_count": 1,
  "max_retries": 3,
  "exit_code": 1,
  "test_command": "npm run test:unit -- --passWithNoTests",
  "output": "Full test output with colors and formatting...",
  "working_directory": "/Users/abc/Desktop/EM-Team",
  "git_branch": "feature/tdd-auto-retry",
  "git_commit": "abc123def456"
}
```

### Benefits

- **No Manual Copy-Paste**: Error context automatically captured
- **Exponential Backoff**: Reduces noise from flaky tests
- **AI-Friendly Format**: Structured JSON for easy parsing
- **Persistent Context**: Survives bash session restarts
- **Clear Feedback**: Color-coded status messages

### Troubleshooting

**Problem**: Tests keep failing with same error

**Solution**:
```bash
# Check the error details
./tests/tdd-context-manager.sh format

# Reset retry counter to start fresh
./tests/tdd-context-manager.sh reset
```

**Problem**: Max retries exceeded

**Solution**:
```bash
# View all failure files
./tests/tdd-context-manager.sh list

# Manual intervention required
# Fix the issue manually, then reset
./tests/tdd-context-manager.sh reset
```

**Problem**: Stale error context

**Solution**:
```bash
# Clean up old failure files
./tests/tdd-context-manager.sh cleanup
```

## Verification

After completing TDD cycle:

- [ ] Test written first (RED phase)
- [ ] Minimal code written to pass (GREEN phase)
- [ ] Code refactored while keeping tests green (REFACTOR phase)
- [ ] All tests pass
- [ ] Code is clean and follows conventions
- [ ] No duplication or code smells
- [ ] Coverage meets requirements

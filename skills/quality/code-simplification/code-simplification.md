---
name: code-simplification
description: Reduce code complexity and improve maintainability. Use when code is hard to understand, has high cyclomatic complexity, or needs refactoring.
version: "2.0.0"
category: "quality"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["complex code", "refactor", "simplify", "cyclomatic complexity"]
intent: "Transform tangled code into clear, maintainable logic that any developer can read and extend with confidence."
scenarios:
  - "Refactoring a 200-line god function into focused, testable helper functions"
  - "Reducing deep nesting in payment processing logic using guard clauses"
  - "Eliminating duplicated validation code across multiple API endpoints"
best_for: "reducing cyclomatic complexity, refactoring legacy code, eliminating duplication, improving readability"
estimated_time: "20-45 min"
anti_patterns:
  - "Simplifying code so aggressively that edge cases and error handling are removed"
  - "Extracting functions prematurely before understanding the full logic flow"
  - "Introducing clever abstractions that make code shorter but harder to understand"
related_skills: ["code-review", "systematic-debugging", "frontend-patterns"]
---

# Code Simplification

## Overview

Code simplification reduces complexity while maintaining functionality. Simpler code is easier to understand, test, and maintain. The goal is to make code as simple as possible, but not simpler.

## When to Use

- Code has high cyclomatic complexity
- Functions are long and hard to understand
- Code has many nested conditions
- Duplication is present
- Code is hard to test

## Simplification Principles

### 1. Single Responsibility

Each function/class should do one thing well:

```typescript
// ❌ Bad: Function does too much
async function processUser(userId: string) {
  // Validate
  const user = await User.findById(userId);
  if (!user) throw new Error('User not found');
  if (!user.email) throw new Error('User has no email');

  // Process
  const data = await fetchExternalData(user.id);
  const processed = transformData(data);

  // Save
  await Result.create({ userId, data: processed });

  // Notify
  await sendEmail(user.email, 'Processing complete');

  return processed;
}

// ✅ Good: Separated concerns
async function validateUser(userId: string): Promise<User> {
  const user = await User.findById(userId);
  if (!user) throw new Error('User not found');
  if (!user.email) throw new Error('User has no email');
  return user;
}

async function processUserData(user: User): Promise<ProcessedData> {
  const data = await fetchExternalData(user.id);
  return transformData(data);
}

async function saveResult(userId: string, data: ProcessedData): Promise<void> {
  await Result.create({ userId, data });
}

async function notifyUser(user: User): Promise<void> {
  await sendEmail(user.email, 'Processing complete');
}

async function processUser(userId: string): Promise<ProcessedData> {
  const user = await validateUser(userId);
  const processed = await processUserData(user);
  await saveResult(user.id, processed);
  await notifyUser(user);
  return processed;
}
```

### 2. Reduce Nesting

Flat code is easier to read:

```typescript
// ❌ Bad: Deep nesting
function processUser(user: User | null): string {
  if (user) {
    if (user.email) {
      if (user.emailVerified) {
        if (user.active) {
          return 'User is active and verified';
        } else {
          return 'User is inactive';
        }
      } else {
        return 'User email not verified';
      }
    } else {
      return 'User has no email';
    }
  } else {
    return 'No user provided';
  }
}

// ✅ Good: Guard clauses
function processUser(user: User | null): string {
  if (!user) return 'No user provided';
  if (!user.email) return 'User has no email';
  if (!user.emailVerified) return 'User email not verified';
  if (!user.active) return 'User is inactive';
  return 'User is active and verified';
}

// ✅ Better: Early returns with validation
function validateAndProcessUser(user: User | null): string {
  const errors = [
    !user && 'No user provided',
    user && !user.email && 'User has no email',
    user && !user.emailVerified && 'User email not verified',
    user && !user.active && 'User is inactive'
  ].filter(Boolean) as string[];

  if (errors.length > 0) {
    return errors[0];
  }

  return 'User is active and verified';
}
```

### 3. Extract Functions

Break large functions into smaller ones:

```typescript
// ❌ Bad: Long function
function calculatePrice(order: Order): number {
  let subtotal = 0;
  for (const item of order.items) {
    subtotal += item.price * item.quantity;
  }

  let discount = 0;
  if (order.couponCode) {
    const coupon = await Coupon.findByCode(order.couponCode);
    if (coupon) {
      discount = subtotal * (coupon.percentage / 100);
    }
  }

  const tax = (subtotal - discount) * 0.1;

  const shipping = order.items.length > 5
    ? 0
    : 10;

  return subtotal - discount + tax + shipping;
}

// ✅ Good: Extracted functions
function calculateSubtotal(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

async function calculateDiscount(subtotal: number, couponCode?: string): Promise<number> {
  if (!couponCode) return 0;

  const coupon = await Coupon.findByCode(couponCode);
  return coupon ? subtotal * (coupon.percentage / 100) : 0;
}

function calculateTax(amount: number): number {
  return amount * 0.1;
}

function calculateShipping(items: OrderItem[]): number {
  return items.length > 5 ? 0 : 10;
}

async function calculatePrice(order: Order): Promise<number> {
  const subtotal = calculateSubtotal(order.items);
  const discount = await calculateDiscount(subtotal, order.couponCode);
  const taxableAmount = subtotal - discount;
  const tax = calculateTax(taxableAmount);
  const shipping = calculateShipping(order.items);

  return subtotal - discount + tax + shipping;
}
```

### 4. Use Meaningful Names

Names should explain intent:

```typescript
// ❌ Bad: Unclear names
const d = new Date();
const u = await User.find();
const r = u.filter(x => x.a > 18);

// ✅ Good: Clear names
const currentDate = new Date();
const users = await User.find();
const adultUsers = users.filter(user => user.age > 18);
```

### 5. Reduce Parameters

Too many parameters indicate a problem:

```typescript
// ❌ Bad: Too many parameters
function createUser(
  name: string,
  email: string,
  password: string,
  age: number,
  address: string,
  city: string,
  country: string,
  phone: string
): User {
  // ...
}

// ✅ Good: Parameter object
interface CreateUserData {
  name: string;
  email: string;
  password: string;
  age: number;
  address: {
    street: string;
    city: string;
    country: string;
  };
  phone: string;
}

function createUser(data: CreateUserData): User {
  // ...
}
```

### 6. Eliminate Duplication

Don't repeat yourself:

```typescript
// ❌ Bad: Duplicated code
function validateEmail(email: string): boolean {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

function validateUserInput(input: { email: string }): boolean {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(input.email);
}

// ✅ Good: Single source of truth
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function isValidEmail(email: string): boolean {
  return EMAIL_REGEX.test(email);
}

function validateUserInput(input: { email: string }): boolean {
  return isValidEmail(input.email);
}
```

## Complexity Metrics

### Cyclomatic Complexity

Measure the number of independent paths:

```typescript
// Complexity: 1 (simple)
function add(a: number, b: number): number {
  return a + b;
}

// Complexity: 4 (moderate)
function calculateDiscount(amount: number, customerType: string): number {
  if (customerType === 'vip') {
    return amount * 0.2;
  } else if (customerType === 'regular') {
    return amount * 0.1;
  } else if (customerType === 'new') {
    return 0;
  } else {
    throw new Error('Unknown customer type');
  }
}

// Complexity: 8+ (high - needs refactoring)
function complexFunction(input: Input): Output {
  if (input.a) {
    if (input.b) {
      if (input.c) {
        // ...
      } else {
        // ...
      }
    } else {
      // ...
    }
  } else {
    // ...
  }
}
```

**Target Complexity:**
- 1-4: Good
- 5-10: Consider refactoring
- 10+: Must refactor

## Refactoring Techniques

### 1. Extract Method

Move code to its own function:

```typescript
// Before
function printReport(users: User[]) {
  console.log('User Report');
  console.log('============');

  users.forEach(user => {
    console.log(`Name: ${user.name}`);
    console.log(`Email: ${user.email}`);
    console.log(`Status: ${user.status}`);
    console.log('---');
  });

  console.log(`Total: ${users.length}`);
}

// After
function printReport(users: User[]) {
  console.log('User Report');
  console.log('============');

  users.forEach(printUser);

  console.log(`Total: ${users.length}`);
}

function printUser(user: User): void {
  console.log(`Name: ${user.name}`);
  console.log(`Email: ${user.email}`);
  console.log(`Status: ${user.status}`);
  console.log('---');
}
```

### 2. Replace Conditional with Polymorphism

```typescript
// Before
function calculateSalary(employee: Employee): number {
  switch (employee.type) {
    case 'full-time':
      return employee.monthlySalary;
    case 'part-time':
      return employee.hourlyRate * employee.hoursWorked;
    case 'contractor':
      return employee.hourlyRate * employee.hoursWorked * 1.2;
    default:
      throw new Error('Unknown employee type');
  }
}

// After
interface Employee {
  calculateSalary(): number;
}

class FullTimeEmployee implements Employee {
  constructor(public monthlySalary: number) {}
  calculateSalary(): number {
    return this.monthlySalary;
  }
}

class PartTimeEmployee implements Employee {
  constructor(public hourlyRate: number, public hoursWorked: number) {}
  calculateSalary(): number {
    return this.hourlyRate * this.hoursWorked;
  }
}

class Contractor implements Employee {
  constructor(public hourlyRate: number, public hoursWorked: number) {}
  calculateSalary(): number {
    return this.hourlyRate * this.hoursWorked * 1.2;
  }
}
```

### 3. Introduce Null Object

```typescript
// Before
function getUserName(user: User | null): string {
  return user ? user.name : 'Guest';
}

function processUser(user: User | null): void {
  if (user) {
    console.log(`Processing ${user.name}`);
  } else {
    console.log('Processing Guest');
  }
}

// After
class GuestUser implements User {
  name = 'Guest';
  id = 'guest';
  email = '';
}

function getUserName(user: User | null): string {
  return user ? user.name : new GuestUser().name;
}

function processUser(user: User | null): void {
  const safeUser = user ?? new GuestUser();
  console.log(`Processing ${safeUser.name}`);
}
```

## Simplification Checklist

After simplifying code:

- [ ] Functions have single responsibility
- [ ] Nesting is reduced (< 3 levels)
- [ ] Functions are short (< 50 lines)
- [ ] Names are clear and descriptive
- [ ] Parameters are minimal (< 4)
- [ ] Duplication is eliminated
- [ ] Complexity is manageable
- [ ] Tests still pass

## Coaching Notes

> **ABC - Always Be Coaching:** Simpler code is not just shorter code -- it is code that the next developer can understand in one reading.

1. **Simplify Before You Abstract:** The first response to complexity should be reducing it directly (guard clauses, early returns, extracting functions). Only reach for design patterns when simple restructuring is not enough.
2. **Name Things to Reveal Intent:** If you need a comment to explain what a variable or function does, the name is wrong. A well-named function makes its purpose obvious at every call site.
3. **Measure Complexity Before and After:** Use cyclomatic complexity as a guide. If your refactoring does not reduce the complexity score while keeping all tests green, it is rearrangement, not simplification.

## Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| God function | Too much responsibility | Extract functions |
| Deep nesting | Hard to read | Use guard clauses |
| Magic numbers | Unclear intent | Use named constants |
| Long parameter list | Hard to use | Use parameter objects |
| Duplication | Maintenance burden | Extract common code |

## Verification

After code simplification:

- [ ] Code is easier to understand
- [ ] Tests still pass
- [ ] No functionality broken
- [ ] Complexity reduced
- [ ] Duplication eliminated
- [ ] Names are clear
- [ ] Functions are focused

---
name: code-review
description: Comprehensive 5-axis code review framework. Use when reviewing pull requests, before merging code, or when ensuring code quality.
version: "2.0.0"
category: "quality"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["code review", "pull request", "merge", "quality gate"]
intent: "Elevate code quality through systematic multi-axis evaluation that catches defects and teaches better practices simultaneously."
scenarios:
  - "Reviewing a team member's pull request before merging to main"
  - "Auditing a legacy module for security vulnerabilities and architectural decay"
  - "Providing constructive feedback on a junior developer's first feature contribution"
best_for: "PR reviews, pre-merge quality gates, team code standards enforcement, mentorship through feedback"
estimated_time: "15-30 min"
anti_patterns:
  - "Nitpicking style instead of substance while missing real bugs"
  - "Rubber-stamping approvals without actually reading the code"
  - "Giving vague feedback like 'this is bad' without explaining why or suggesting alternatives"
related_skills: ["code-simplification", "security-audit", "security-hardening"]
---

# Code Review

## Overview

Code review is a systematic process to ensure code quality, maintainability, and correctness. The 5-axis review framework evaluates code across correctness, readability, architecture, security, and performance.

## When to Use

- Reviewing pull requests
- Before merging code
- Ensuring code quality
- Teaching best practices
- Maintaining code standards

## The 5-Axis Review Framework

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. Correctness   ──→ Does it work?                    │
│  2. Readability   ──→ Is it understandable?            │
│  3. Architecture  ──→ Is it well-structured?           │
│  4. Security      ──→ Is it secure?                   │
│  5. Performance   ──→ Is it efficient?                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Axis 1: Correctness

### Does the code work as intended?

**Checklist:**
- [ ] Code implements the requirements
- [ ] Edge cases are handled
- [ ] Error handling is comprehensive
- [ ] Tests cover the functionality
- [ ] No obvious bugs

**Example Review:**

```typescript
// ❌ Bad: Missing edge case handling
function divide(a: number, b: number): number {
  return a / b;
}

// ✅ Good: Handles edge cases
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}
```

**Common Issues:**
- Null/undefined not handled
- Array bounds not checked
- Error cases not covered
- Race conditions in async code

## Axis 2: Readability

### Is the code easy to understand?

**Checklist:**
- [ ] Names are descriptive and clear
- [ ] Complex logic is explained
- [ ] Code follows consistent style
- [ ] Magic numbers are replaced with constants
- [ ] Functions are small and focused

**Example Review:**

```typescript
// ❌ Bad: Unclear naming and magic numbers
function calc(d: number, r: number): number {
  return d * (1 + r / 100) * 0.8;
}

// ✅ Good: Clear naming and constants
const TAX_RATE = 0.2;
const DISCOUNT_MULTIPLIER = 0.8;

function calculatePriceWithDiscount(
  days: number,
  rate: number
): number {
  const dailyRate = days * rate;
  const discountedRate = dailyRate * DISCOUNT_MULTIPLIER;
  return discountedRate * (1 + TAX_RATE);
}
```

**Common Issues:**
- Abbreviations in names
- Magic numbers
- Long functions (>50 lines)
- Deeply nested code
- Unclear variable names

## Axis 3: Architecture

### Is the code well-structured?

**Checklist:**
- [ ] Separation of concerns
- [ ] Single responsibility principle
- [ ] DRY (Don't Repeat Yourself)
- [ ] Proper abstractions
- [ ] Dependency injection

**Example Review:**

```typescript
// ❌ Bad: Mixed concerns
async function handleUserRegistration(req: Request) {
  // Validation
  if (!req.body.email || !req.body.password) {
    throw new Error('Invalid input');
  }

  // Database operation
  const user = await db.users.create({
    email: req.body.email,
    password: hash(req.body.password)
  });

  // Email sending
  await sendEmail(user.email, 'Welcome!');

  // Response
  return user;
}

// ✅ Good: Separated concerns
class UserRegistrationService {
  constructor(
    private validator: Validator,
    private userRepository: UserRepository,
    private emailService: EmailService
  ) {}

  async register(data: RegisterData): Promise<User> {
    this.validator.validate(data);
    const hashedPassword = await this.hashPassword(data.password);
    const user = await this.userRepository.create({
      email: data.email,
      password: hashedPassword
    });
    await this.emailService.sendWelcome(user.email);
    return user;
  }

  private async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 10);
  }
}
```

**Common Issues:**
- God classes/functions
- Tight coupling
- Code duplication
- Poor separation of concerns
- Violation of SOLID principles

## Axis 4: Security

### Is the code secure?

**Checklist:**
- [ ] Input validation
- [ ] Output encoding
- [ ] Authentication/authorization
- [ ] No hardcoded secrets
- [ ] SQL injection prevention
- [ ] XSS prevention

**Example Review:**

```typescript
// ❌ Bad: SQL injection vulnerability
async function getUserByEmail(email: string): Promise<User> {
  const query = `SELECT * FROM users WHERE email = '${email}'`;
  return db.query(query);
}

// ✅ Good: Parameterized query
async function getUserByEmail(email: string): Promise<User> {
  return db.query('SELECT * FROM users WHERE email = $1', [email]);
}

// ❌ Bad: Hardcoded secret
const API_KEY = 'sk_live_1234567890abcdef';

// ✅ Good: Environment variable
const API_KEY = process.env.STRIPE_API_KEY!;

// ❌ Bad: XSS vulnerability
function renderComment(text: string): string {
  return `<div>${text}</div>`;
}

// ✅ Good: Output encoding
import DOMPurify from 'dompurify';

function renderComment(text: string): string {
  const sanitized = DOMPurify.sanitize(text);
  return `<div>${sanitized}</div>`;
}
```

**Common Issues:**
- SQL injection
- XSS vulnerabilities
- Hardcoded secrets
- Missing authorization
- No input validation
- Insecure dependencies

## Axis 5: Performance

### Is the code efficient?

**Checklist:**
- [ ] No unnecessary computations
- [ ] Efficient data structures
- [ ] Proper caching
- [ ] Database query optimization
- [ ] No memory leaks

**Example Review:**

```typescript
// ❌ Bad: Inefficient array operations
function findUserById(users: User[], id: string): User | undefined {
  for (let i = 0; i < users.length; i++) {
    if (users[i].id === id) {
      return users[i];
    }
  }
}

// ✅ Good: Using Map for O(1) lookup
function createUserMap(users: User[]): Map<string, User> {
  return new Map(users.map(user => [user.id, user]));
}

function findUserById(userMap: Map<string, User>, id: string): User | undefined {
  return userMap.get(id);
}

// ❌ Bad: Unnecessary re-renders
function ExpensiveComponent() {
  const data = expensiveComputation(props.data);
  return <div>{data}</div>;
}

// ✅ Good: Memoized computation
function ExpensiveComponent({ data }: { data: Data[] }) {
  const computed = useMemo(() => expensiveComputation(data), [data]);
  return <div>{computed}</div>;
}
```

**Common Issues:**
- Unnecessary loops
- Missing memoization
- Inefficient queries (N+1)
- Memory leaks
- Blocking operations

## Review Process

### 1. Understand the Context

Before reviewing:
- Read the PR description
- Understand the requirements
- Check related issues/tickets
- Review the test plan

### 2. Review the Code

Go through each axis:
1. Check correctness first
2. Review readability
3. Evaluate architecture
4. Assess security
5. Analyze performance

### 3. Provide Feedback

Give constructive feedback:
- Explain what and why
- Provide examples
- Suggest improvements
- Ask questions

**Good Feedback Example:**

```
❌ Bad: "This code is bad."

✅ Good: "I noticed that the `divide` function doesn't handle division by zero.
This could cause a runtime error. Consider adding a check:

```typescript
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}
```

Also, consider adding a test case for this scenario."
```

### 4. Follow Up

- Address review comments
- Verify fixes
- Approve when satisfied

## Review Template

```markdown
## Code Review

### Summary
[Brief summary of changes]

### Correctness
- [ ] Code implements requirements
- [ ] Edge cases handled
- [ ] Tests comprehensive
- Issues: [List any correctness issues]

### Readability
- [ ] Names are clear
- [ ] Code is well-structured
- [ ] Comments where needed
- Issues: [List any readability issues]

### Architecture
- [ ] Good separation of concerns
- [ ] Follows SOLID principles
- [ ] No code duplication
- Issues: [List any architecture issues]

### Security
- [ ] Input validation
- [ ] No hardcoded secrets
- [ ] Proper authorization
- Issues: [List any security issues]

### Performance
- [ ] Efficient algorithms
- [ ] Proper caching
- [ ] No memory leaks
- Issues: [List any performance issues]

### Overall Assessment
- [ ] Approve
- [ ] Request changes
- [ ] Comment

### Additional Notes
[Any other feedback or suggestions]
```

## Coaching Notes

> **ABC - Always Be Coaching:** A great code review teaches the author something new, not just catches bugs.

1. **Lead with Questions, Not Commands:** Ask "What happens when this receives null?" instead of stating "This will crash on null." Questions invite thinking; commands invite resentment.
2. **Review the Architecture Before the Semicolons:** If the overall approach is wrong, detailed style feedback is wasted effort. Evaluate correctness and architecture first, then readability and performance.
3. **Every Comment Should Leave the Code Better:** Either the code improves from your suggestion, or the author's understanding improves from your explanation. If neither happens, the comment was noise.

## Common Review Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Nitpicking style | Focuses on minor issues | Use linters for style |
| Rubber stamping | No actual review | Thoroughly review code |
| Delaying reviews | Blocks progress | Review promptly |
- Harsh feedback | Demotivates | Be constructive |
| No explanation | Unclear why | Explain your reasoning |

## Verification

After code review:

- [ ] All 5 axes evaluated
- [ ] Feedback is constructive
- [ ] Examples provided for issues
- [ ] Suggestions for improvement
- [ ] Overall assessment given
- [ ] Follow-up on fixes

---
name: backend-patterns
description: Backend development patterns for APIs, databases, and services. Use when building API endpoints, database queries, authentication, or business logic.
version: "3.0.0"
category: "expert-backend"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["backend", "api endpoint", "database query", "service layer"]
intent: "Provide battle-tested structural patterns so backend code stays maintainable, testable, and secure as the codebase grows."
scenarios:
  - "Building a transactional fund transfer endpoint with rollback guarantees"
  - "Implementing a repository pattern to decouple data access from business logic"
  - "Adding JWT-based authentication with role-based access control to an Express API"
best_for: "API design, database patterns, auth, caching, error handling"
estimated_time: "25-45 min"
anti_patterns:
  - "Putting SQL queries directly inside route handlers instead of using the repository pattern"
  - "God controllers that mix validation, business logic, and data access in one function"
  - "Skipping transactions for multi-step database operations that must succeed or fail together"
related_skills: ["api-interface-design", "security-hardening", "code-review"]

input_schema:
  type: object
  required: [task_description]
  properties:
    task_description:
      type: string
      description: "What to implement, review, or investigate"
    context:
      type: object
      description: "Project context — existing code, tech stack, constraints"
    mode:
      type: string
      enum: [implement, review, investigate, advise]
      default: implement
      description: "Execution mode"

output_schema:
  type: object
  required: [status, implementation]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    implementation:
      type: object
      description: "Implementation details, code, or analysis results"
    patterns_applied:
      type: array
      items: { type: string }
      description: "Patterns and best practices used"
    recommendations:
      type: array
      items:
        type: object
        properties:
          priority: { type: string, enum: [high, medium, low] }
          action: { type: string }
          reasoning: { type: string }

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

# Backend Patterns

[ROLE]
Act as a backend architecture expert. Deliver layered backend code with repository pattern, typed error hierarchies, transactional boundaries, and cache-aside caching.

[OBJECTIVE]
Produce backend code where business logic is separated from data access via the repository pattern, multi-step writes use transactions, and errors follow a typed hierarchy.

[RULES]
1. <thought>Before writing any endpoint, determine: What layer does this logic belong to (controller/service/repository)? Does this need a transaction? What error types can occur?</thought>
2. Separate concerns: controllers handle HTTP, services handle business logic, repositories handle data access.
3. Use the repository pattern — data access behind an interface for testability.
4. Wrap multi-step writes in transactions — partial data corruption is worse than a rolled-back request.
5. Use typed error classes (ValidationError, NotFoundError, ConflictError) — not generic Error.
6. Validate all inputs at the API boundary with schema validation (Zod, class-validator).
7. DO NOT put SQL queries directly in route handlers — use repositories.
8. DO NOT build god controllers mixing validation, logic, and data access.
9. DO NOT skip transactions for multi-step database operations.
10. Use consistent API response envelopes — `{ success, data, error, meta }`.
11. Implement cache-aside pattern for frequently accessed data.
12. Use dependency injection for testability — constructor injection over global singletons.
13. ABC: The repository pattern buys testability — when data access lives behind an interface, you can swap PostgreSQL for an in-memory stub in tests.

[PROCESS]

### RESTful API Design

```typescript
GET    /api/users          // List users
POST   /api/users          // Create user
GET    /api/users/:id      // Get specific user
PATCH  /api/users/:id      // Update user (partial)
DELETE /api/users/:id      // Delete user
```

### Repository Pattern

```typescript
interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  create(data: CreateUserData): Promise<User>;
  update(id: string, data: UpdateUserData): Promise<User>;
  delete(id: string): Promise<void>;
}
```

### Service Layer

```typescript
class UserService {
  constructor(
    private userRepo: UserRepository,
    private emailService: EmailService,
    private passwordHasher: PasswordHasher
  ) {}

  async register(data: RegisterData): Promise<User> {
    const existing = await this.userRepo.findByEmail(data.email);
    if (existing) throw new ConflictError('User already exists');
    const hashedPassword = await this.passwordHasher.hash(data.password);
    const user = await this.userRepo.create({ ...data, password: hashedPassword });
    await this.emailService.sendWelcome(user.email);
    return user;
  }
}
```

### Transaction Management

```typescript
async function transferFunds(fromUserId: string, toUserId: string, amount: number): Promise<void> {
  await db.transaction(async (trx) => {
    await trx('accounts').where('user_id', fromUserId).decrement('balance', amount);
    await trx('accounts').where('user_id', toUserId).increment('balance', amount);
    await trx('transactions').insert({ from_user_id: fromUserId, to_user_id: toUserId, amount, timestamp: new Date() });
  });
}
```

### Custom Error Classes

```typescript
class AppError extends Error {
  constructor(public statusCode: number, public code: string, message: string) {
    super(message);
    this.name = this.constructor.name;
  }
}
class ValidationError extends AppError { constructor(message: string) { super(400, 'VALIDATION_ERROR', message); } }
class NotFoundError extends AppError { constructor(resource: string) { super(404, 'NOT_FOUND', `${resource} not found`); } }
class ConflictError extends AppError { constructor(message: string) { super(409, 'CONFLICT', message); } }
```

### JWT Authentication

```typescript
class AuthService {
  generateTokens(userId: string) {
    const accessToken = jwt.sign({ userId }, this.SECRET, { expiresIn: '15m' });
    const refreshToken = jwt.sign({ userId }, this.REFRESH_SECRET, { expiresIn: '7d' });
    return { accessToken, refreshToken };
  }
}

function requireRole(...roles: Role[]) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) return res.status(401).json({ error: 'Unauthorized' });
    if (!roles.includes(req.user.role)) return res.status(403).json({ error: 'Forbidden' });
    next();
  };
}
```

### Cache-Aside Pattern

```typescript
class CachedUserService {
  constructor(private userRepo: UserRepository, private cache: Redis) {}

  async findById(id: string): Promise<User | null> {
    const cached = await this.cache.get(`user:${id}`);
    if (cached) return JSON.parse(cached);
    const user = await this.userRepo.findById(id);
    if (user) await this.cache.setex(`user:${id}`, 300, JSON.stringify(user));
    return user;
  }
}
```

### Verification

- [ ] API follows REST principles
- [ ] Request validation is implemented
- [ ] Response format is consistent
- [ ] Database queries use parameterized queries
- [ ] Transactions are used for multi-step operations
- [ ] Authentication and authorization are secure
- [ ] Business logic is in service layer
- [ ] Error handling is comprehensive
- [ ] Caching is used appropriately

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing backend patterns used, and `recommendations` for improvements.

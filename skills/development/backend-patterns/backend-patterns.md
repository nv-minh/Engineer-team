---
name: backend-patterns
description: Backend development patterns for APIs, databases, and services. Use when building API endpoints, database queries, authentication, or business logic.
version: "2.0.0"
category: "development"
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
---

# Backend Patterns

## Overview

Modern backend development follows established patterns for API design, database interactions, authentication, and business logic. These patterns ensure maintainable, secure, and scalable backend code.

## When to Use

- Building REST or GraphQL APIs
- Designing database schemas
- Implementing authentication and authorization
- Handling business logic
- Managing data persistence
- Implementing caching strategies

## API Design Patterns

### RESTful API Design

Design APIs following REST principles:

```typescript
// ✅ Good: RESTful resource naming
GET    /api/users          // List users
GET    /api/users/:id      // Get specific user
POST   /api/users          // Create user
PUT    /api/users/:id      // Update user (full)
PATCH  /api/users/:id      // Update user (partial)
DELETE /api/users/:id      // Delete user

// Nested resources
GET    /api/users/:id/posts        // User's posts
POST   /api/users/:id/posts        // Create post for user
```

### API Response Format

Use consistent response formats:

```typescript
// ✅ Good: Consistent response structure
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: unknown;
  };
  meta?: {
    page?: number;
    limit?: number;
    total?: number;
  };
}

// Success response
{
  "success": true,
  "data": { "id": "1", "name": "John" },
  "meta": { "total": 100 }
}

// Error response
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": { "field": "email" }
  }
}
```

### Request Validation

Validate all incoming requests:

```typescript
// ✅ Good: Schema-based validation
import { z } from 'zod';

const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8).regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/),
  role: z.enum(['user', 'admin']).default('user')
});

app.post('/api/users', async (req, res) => {
  try {
    const validated = createUserSchema.parse(req.body);
    const user = await createUser(validated);
    res.json({ success: true, data: user });
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid request data',
          details: error.errors
        }
      });
    }
  }
});
```

## Database Patterns

### Repository Pattern

Separate data access logic from business logic:

```typescript
// ✅ Good: Repository pattern
interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  create(data: CreateUserData): Promise<User>;
  update(id: string, data: UpdateUserData): Promise<User>;
  delete(id: string): Promise<void>;
}

class PostgresUserRepository implements UserRepository {
  constructor(private db: Database) {}

  async findById(id: string): Promise<User | null> {
    const result = await this.db.query(
      'SELECT * FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0] || null;
  }

  async create(data: CreateUserData): Promise<User> {
    const result = await this.db.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING *',
      [data.name, data.email, data.password]
    );
    return result.rows[0];
  }
}
```

### Query Building

Use query builders or ORMs for type safety:

```typescript
// ✅ Good: Using query builder
import { Knex } from 'knex';

class UserQueryBuilder {
  constructor(private query: Knex.QueryBuilder) {}

  static create(db: Knex) {
    return new UserQueryBuilder(db('users'));
  }

  withPosts() {
    this.query = this.query
      .select('users.*')
      .leftJoin('posts', 'users.id', 'posts.user_id')
      .groupBy('users.id');
    return this;
  }

  active() {
    this.query = this.query.where('users.status', 'active');
    return this;
  }

  async get(): Promise<User[]> {
    return this.query;
  }
}

// Usage
const users = await UserQueryBuilder.create(db)
  .withPosts()
  .active()
  .get();
```

### Transaction Management

Use transactions for multi-step operations:

```typescript
// ✅ Good: Transaction with rollback on error
async function transferFunds(
  fromUserId: string,
  toUserId: string,
  amount: number
): Promise<void> {
  await db.transaction(async (trx) => {
    // Deduct from sender
    await trx('accounts')
      .where('user_id', fromUserId)
      .decrement('balance', amount);

    // Add to receiver
    await trx('accounts')
      .where('user_id', toUserId)
      .increment('balance', amount);

    // Record transaction
    await trx('transactions').insert({
      from_user_id: fromUserId,
      to_user_id: toUserId,
      amount,
      timestamp: new Date()
    });

    // If any query fails, transaction rolls back automatically
  });
}
```

## Authentication & Authorization

### JWT Authentication

Implement secure JWT-based authentication:

```typescript
// ✅ Good: JWT authentication
import jwt from 'jsonwebtoken';

class AuthService {
  private readonly SECRET = process.env.JWT_SECRET!;
  private readonly REFRESH_SECRET = process.env.JWT_REFRESH_SECRET!;

  generateTokens(userId: string) {
    const accessToken = jwt.sign(
      { userId },
      this.SECRET,
      { expiresIn: '15m' }
    );

    const refreshToken = jwt.sign(
      { userId },
      this.REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    return { accessToken, refreshToken };
  }

  verifyAccessToken(token: string) {
    return jwt.verify(token, this.SECRET) as { userId: string };
  }

  verifyRefreshToken(token: string) {
    return jwt.verify(token, this.REFRESH_SECRET) as { userId: string };
  }
}
```

### Role-Based Authorization

Implement role-based access control:

```typescript
// ✅ Good: Role-based middleware
enum Role {
  USER = 'user',
  ADMIN = 'admin',
  MODERATOR = 'moderator'
}

interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    role: Role;
  };
}

function requireRole(...roles: Role[]) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    next();
  };
}

// Usage
app.delete(
  '/api/users/:id',
  authenticate,
  requireRole(Role.ADMIN),
  deleteUserHandler
);
```

## Business Logic Patterns

### Service Layer

Separate business logic from controllers:

```typescript
// ✅ Good: Service layer
class UserService {
  constructor(
    private userRepo: UserRepository,
    private emailService: EmailService,
    private passwordHasher: PasswordHasher
  ) {}

  async register(data: RegisterData): Promise<User> {
    // Check if user exists
    const existing = await this.userRepo.findByEmail(data.email);
    if (existing) {
      throw new ConflictError('User already exists');
    }

    // Hash password
    const hashedPassword = await this.passwordHasher.hash(data.password);

    // Create user
    const user = await this.userRepo.create({
      ...data,
      password: hashedPassword
    });

    // Send welcome email
    await this.emailService.sendWelcome(user.email);

    return user;
  }

  async changePassword(userId: string, oldPassword: string, newPassword: string): Promise<void> {
    const user = await this.userRepo.findById(userId);
    if (!user) {
      throw new NotFoundError('User not found');
    }

    // Verify old password
    const isValid = await this.passwordHasher.verify(user.password, oldPassword);
    if (!isValid) {
      throw new UnauthorizedError('Invalid password');
    }

    // Hash new password
    const hashedPassword = await this.passwordHasher.hash(newPassword);

    // Update password
    await this.userRepo.update(userId, { password: hashedPassword });
  }
}
```

### Dependency Injection

Use dependency injection for testability:

```typescript
// ✅ Good: Dependency injection
interface Dependencies {
  userRepo: UserRepository;
  emailService: EmailService;
  passwordHasher: PasswordHasher;
}

function createUserHandler(deps: Dependencies) {
  return async (req: Request, res: Response) => {
    const userService = new UserService(
      deps.userRepo,
      deps.emailService,
      deps.passwordHasher
    );

    try {
      const user = await userService.register(req.body);
      res.json({ success: true, data: user });
    } catch (error) {
      handleError(error, res);
    }
  };
}

// Usage
app.post('/api/users', createUserHandler({
  userRepo: new PostgresUserRepository(db),
  emailService: new SESEmailService(),
  passwordHasher: new BcryptPasswordHasher()
}));
```

## Error Handling Patterns

### Custom Error Classes

Create custom error classes for different error types:

```typescript
// ✅ Good: Custom error classes
class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

class ValidationError extends AppError {
  constructor(message: string) {
    super(400, 'VALIDATION_ERROR', message);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super(404, 'NOT_FOUND', `${resource} not found`);
  }
}

class ConflictError extends AppError {
  constructor(message: string) {
    super(409, 'CONFLICT', message);
  }
}

// Error handling middleware
function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message
      }
    });
  }

  // Log unexpected errors
  console.error(err);

  res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_SERVER_ERROR',
      message: 'An unexpected error occurred'
    }
  });
}
```

## Caching Patterns

### Cache-Aside Pattern

Implement cache-aside for frequently accessed data:

```typescript
// ✅ Good: Cache-aside pattern
class CachedUserService {
  constructor(
    private userRepo: UserRepository,
    private cache: Redis
  ) {}

  async findById(id: string): Promise<User | null> {
    // Try cache first
    const cached = await this.cache.get(`user:${id}`);
    if (cached) {
      return JSON.parse(cached);
    }

    // Cache miss - fetch from database
    const user = await this.userRepo.findById(id);
    if (user) {
      // Store in cache for 5 minutes
      await this.cache.setex(`user:${id}`, 300, JSON.stringify(user));
    }

    return user;
  }

  async update(id: string, data: UpdateUserData): Promise<User> {
    const user = await this.userRepo.update(id, data);

    // Invalidate cache
    await this.cache.del(`user:${id}`);

    return user;
  }
}
```

## Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| SQL injection | Security vulnerability | Use parameterized queries |
| N+1 queries | Performance issues | Use eager loading |
| God controllers | Hard to test and maintain | Use service layer |
| Hardcoded secrets | Security risk | Use environment variables |
| No validation | Invalid data and errors | Validate all inputs |
| Mixed concerns | Hard to maintain | Separate layers |

## Coaching Notes

> **ABC - Always Be Coaching:** Backend patterns teach you that separation of concerns and consistent error handling are what keep a server codebase maintainable beyond the first sprint.

1. **The repository pattern buys you testability:** When data access lives behind an interface, you can swap PostgreSQL for an in-memory stub in tests and reason about business logic without a database running. This alone justifies the extra file.
2. **Transactions are non-negotiable for multi-step writes:** If two database changes must both succeed or both fail, wrap them in a transaction. Period. Partial data corruption is far harder to fix than a rolled-back request.
3. **Custom error classes turn chaos into structure:** Throwing generic Error objects means every caller guesses what went wrong. A typed hierarchy (ValidationError, NotFoundError, ConflictError) lets handlers respond correctly and logs carry the context you need to debug at 3 AM.

## Verification

After implementing backend patterns:

- [ ] API follows REST principles
- [ ] Request validation is implemented
- [ ] Response format is consistent
- [ ] Database queries use parameterized queries
- [ ] Transactions are used for multi-step operations
- [ ] Authentication and authorization are secure
- [ ] Business logic is in service layer
- [ ] Error handling is comprehensive
- [ ] Caching is used appropriately
- [ ] Code is tested and type-safe

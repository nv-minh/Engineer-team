---
name: documentation
description: Documentation for code, APIs, and architecture. Use when documenting features, writing API docs, or creating ADRs.
version: "2.0.0"
category: "workflow"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["document", "API docs", "ADR", "README"]
intent: "Ensure that every piece of knowledge needed to understand, use, and maintain the codebase is captured clearly and kept current."
scenarios:
  - "Writing Architecture Decision Records to capture why the team chose PostgreSQL over MongoDB"
  - "Generating OpenAPI documentation for a new set of REST endpoints before frontend integration"
  - "Updating the project README and onboarding guide after a major dependency migration"
best_for: "API documentation, ADRs, README generation, inline code documentation, onboarding guides"
estimated_time: "15-30 min"
anti_patterns:
  - "Writing documentation once and never updating it as the code evolves"
  - "Documenting what the code does line-by-line instead of explaining why it does it"
  - "Skipping edge cases and error handling in API docs, leaving consumers to discover them by surprise"
related_skills: ["code-review", "api-interface-design", "finishing-branch"]
---

# Documentation

## Overview

Good documentation ensures code is understandable, maintainable, and usable. Documentation should be clear, concise, and kept up-to-date with code changes.

## When to Use

- Documenting new features
- Writing API documentation
- Creating Architecture Decision Records (ADRs)
- Updating existing documentation
- Onboarding new developers

## Documentation Types

### 1. Code Documentation

#### Inline Comments

```typescript
// ❌ Bad: Useless comments
// Get user
const user = getUser();

// Set name to John
user.name = 'John';

// ✅ Good: Explain why, not what
// Cache user data to avoid repeated database queries
const user = await getCachedUser(userId);

// Use temporary name until verification is complete
user.name = 'John'; // Will be updated after email verification
```

#### JSDoc Comments

```typescript
// ✅ Good: Comprehensive JSDoc
/**
 * Authenticates a user with email and password.
 *
 * @param email - User's email address
 * @param password - User's password
 * @returns Promise that resolves to authentication token
 * @throws {ValidationError} If email or password is invalid
 * @throws {UnauthorizedError} If credentials are incorrect
 *
 * @example
 * ```typescript
 * const token = await authenticate('user@example.com', 'password123');
 * ```
 */
async function authenticate(
  email: string,
  password: string
): Promise<string> {
  // Implementation
}
```

#### Complex Logic Documentation

```typescript
// ✅ Good: Document complex algorithms
/**
 * Implements the Knuth-Morris-Pratt algorithm for pattern matching.
 *
 * This algorithm searches for occurrences of a pattern within a text
 * in O(n + m) time where n is the text length and m is the pattern length.
 *
 * The algorithm builds a partial match table (also called "failure function")
 * that allows skipping characters that are known not to match.
 *
 * @see https://en.wikipedia.org/wiki/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm
 */
function kmpSearch(text: string, pattern: string): number[] {
  // Implementation
}
```

### 2. API Documentation

#### OpenAPI/Swagger

```yaml
# ✅ Good: OpenAPI specification
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
  description: API for managing users

paths:
  /users:
    post:
      summary: Create a new user
      description: Creates a new user account with the provided data
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          description: Validation error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        '409':
          description: User already exists
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          description: Unique user identifier
        name:
          type: string
          description: User's full name
        email:
          type: string
          format: email
          description: User's email address
      required:
        - id
        - name
        - email
```

#### Endpoint Documentation

```typescript
/**
 * POST /api/users
 *
 * Creates a new user account.
 *
 * @req.body {CreateUserData} User data
 * @res {User} Created user object
 * @res {400} ValidationError - Invalid input data
 * @res {409} ConflictError - User already exists
 *
 * @example
 * Request:
 * ```json
 * {
 *   "name": "John Doe",
 *   "email": "john@example.com",
 *   "password": "SecurePass123!"
 * }
 * ```
 *
 * Response (201):
 * ```json
 * {
 *   "id": "usr_123abc",
 *   "name": "John Doe",
 *   "email": "john@example.com"
 * }
 * ```
 */
router.post('/users', async (req, res) => {
  // Implementation
});
```

### 3. Architecture Decision Records (ADRs)

#### ADR Template

```markdown
# ADR-001: Use PostgreSQL as Primary Database

## Status
Accepted

## Context
We need a reliable database for our application. The requirements are:
- ACID transactions
- Complex queries
- Relational data
- High availability

## Decision
Use PostgreSQL as the primary database.

## Rationale
- PostgreSQL offers excellent ACID compliance
- Rich query capabilities with JOINs and subqueries
- Strong community support and documentation
- Proven scalability
- Excellent JSON support for flexible schemas

## Consequences
- Positive:
  - Reliable data integrity
  - Complex queries supported
  - Easy to find PostgreSQL expertise
- Negative:
  - More complex than NoSQL alternatives
  - May require vertical scaling for very large datasets

## Alternatives Considered
- MongoDB: Rejected due to lack of ACID transactions
- MySQL: Rejected due to less advanced features
- DynamoDB: Rejected due to query limitations

## Related Decisions
- ADR-002: Use Prisma as ORM
- ADR-003: Implement read replicas for scaling
```

### 4. README Documentation

#### Project README

```markdown
# Project Name

Brief description of what this project does and who it's for.

## Features

- Feature 1: Description
- Feature 2: Description
- Feature 3: Description

## Quick Start

\`\`\`bash
# Install dependencies
npm install

# Run development server
npm run dev

# Run tests
npm test

# Build for production
npm run build
\`\`\`

## Project Structure

\`\`\`
src/
├── components/     # React components
├── lib/           # Utility functions
├── services/      # Business logic
└── types/         # TypeScript types
\`\`\`

## Development

### Prerequisites

- Node.js 18+
- PostgreSQL 14+
- Redis 7+

### Setup

1. Clone the repository
2. Install dependencies: `npm install`
3. Configure environment: `cp .env.example .env`
4. Run migrations: `npm run migrate`
5. Start development server: `npm run dev`

### Testing

\`\`\`bash
# Unit tests
npm run test:unit

# Integration tests
npm run test:integration

# E2E tests
npm run test:e2e

# Coverage
npm run test:coverage
\`\`\`

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for deployment instructions.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

MIT License - see LICENSE file for details
```

### 5. API Reference

#### API Documentation

```markdown
# API Reference

## Authentication

All API requests require authentication using a Bearer token:

\`\`\`
Authorization: Bearer YOUR_TOKEN_HERE
\`\`\`

## Users API

### Create User

\`\`\`
POST /api/users
\`\`\`

Creates a new user account.

**Request Body:**

\`\`\`json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!"
}
\`\`\`

**Response (201):**

\`\`\`json
{
  "success": true,
  "data": {
    "id": "usr_123abc",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
\`\`\`

**Error Responses:**

- 400: Validation error
- 409: User already exists

### Get User

\`\`\`
GET /api/users/:id
\`\`\`

Retrieves a user by ID.

**Response (200):**

\`\`\`json
{
  "success": true,
  "data": {
    "id": "usr_123abc",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
\`\`\`

**Error Responses:**

- 404: User not found
```

## Documentation Best Practices

### 1. Keep Documentation Up-to-Date

```typescript
// ✅ Good: Update docs with code
/**
 * @deprecated Use createUserV2 instead
 * Will be removed in version 2.0
 */
async function createUser(data: UserData): Promise<User> {
  return createUserV2(data);
}

async function createUserV2(data: UserData): Promise<User> {
  // New implementation
}
```

### 2. Use Examples

```typescript
// ✅ Good: Provide examples
/**
 * Formats a date for display.
 *
 * @example
 * ```typescript
 * formatDate(new Date('2024-01-15')) // "January 15, 2024"
 * formatDate(new Date('2024-01-15'), 'short') // "1/15/24"
 * ```
 */
function formatDate(date: Date, format: 'long' | 'short' = 'long'): string {
  // Implementation
}
```

### 3. Document Edge Cases

```typescript
// ✅ Good: Document edge cases
/**
 * Divides two numbers.
 *
 * @throws {Error} If divisor is zero
 * @throws {Error} If either number is NaN
 * @throws {Error} If result is Infinity (overflow)
 */
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  if (isNaN(a) || isNaN(b)) {
    throw new Error('NaN is not a valid number');
  }
  const result = a / b;
  if (!isFinite(result)) {
    throw new Error('Result overflow');
  }
  return result;
}
```

### 4. Link to Related Code

```typescript
// ✅ Good: Cross-reference related code
/**
 * User authentication service.
 *
 * @see UserService for user management
 * @see SessionService for session handling
 * @see {@link https://example.com/docs/auth} Authentication documentation
 */
class AuthService {
  // Implementation
}
```

## Documentation Tools

### Automated Documentation

```bash
# Generate API documentation from JSDoc
npm install -g jsdoc
jsdoc src/**/*.ts -d docs/

# Generate OpenAPI spec from code
npm install -g @apidevtools/swagger-cli
swagger-cli generate docs/swagger.json

# Generate README from code
npm install -g readme-md-generator
readme-md-generator
```

### Documentation Generation

```typescript
// ✅ Good: Auto-generated documentation
/**
 * @module user-service
 * @description Provides user management functionality
 */

/**
 * @class UserService
 * @description Handles user CRUD operations
 */
export class UserService {
  /**
   * Create a new user
   * @param {CreateUserData} data - User data
   * @returns {Promise<User>} Created user
   */
  async create(data: CreateUserData): Promise<User> {
    // Implementation
  }

  /**
   * Find user by ID
   * @param {string} id - User ID
   * @returns {Promise<User | null>} User or null if not found
   */
  async findById(id: string): Promise<User | null> {
    // Implementation
  }
}
```

## Coaching Notes

> **ABC - Always Be Coaching:** Good documentation does not repeat the code -- it explains the decisions, constraints, and intent that the code cannot express on its own.

1. **Document Why, Not What:** The code already shows what it does. Documentation adds value by explaining why a design choice was made, what constraints shaped it, and what alternatives were rejected. ADRs are your strongest tool here.
2. **Examples Beat Descriptions:** A three-line code example teaches more than a paragraph of prose. Always include usage examples in API docs, and make them copy-pasteable so developers can try them immediately.
3. **Treat Documentation Like Code:** It has a lifecycle. It needs review, updates when the code changes, and deletion when it becomes misleading. Stale documentation is worse than no documentation because it actively misleads.

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Outdated docs | Misleading information | Update docs with code |
| No examples | Hard to understand | Provide clear examples |
| Too verbose | Overwhelming | Be concise |
| Missing edge cases | Unexpected behavior | Document all cases |
| No structure | Hard to find info | Organize clearly |

## Verification

After documentation:

- [ ] Code is documented
- [ ] API documentation complete
- [ ] Examples provided
- [ ] Edge cases documented
- [ ] ADRs created for decisions
- [ ] README is comprehensive
- [ ] Documentation is up-to-date
- [ ] Links work correctly

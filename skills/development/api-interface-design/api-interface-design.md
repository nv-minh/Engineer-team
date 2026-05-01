---
name: api-interface-design
description: Design API interfaces contracts-first. Use when creating new APIs, adding endpoints, or defining service boundaries.
version: "2.0.0"
category: "development"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["api design", "contract-first", "endpoint", "interface definition"]
intent: "Enforce a contracts-first mindset so every API is born with clear types, validation, and documentation before a single line of logic is written."
scenarios:
  - "Designing a new RESTful user management API with consistent error responses"
  - "Defining service boundaries between a payment microservice and an order service"
  - "Adding validation schemas and contract tests for an existing products endpoint"
best_for: "new APIs, endpoint design, service boundaries, contract testing"
estimated_time: "25-45 min"
anti_patterns:
  - "Writing controller logic before defining request and response types"
  - "Using inconsistent naming conventions across different endpoints"
  - "Returning raw error messages without a structured error response format"
related_skills: ["backend-patterns", "security-hardening", "test-driven-development"]
---

# API Interface Design

## Overview

API interface design follows a contracts-first approach — define the interface before implementing the logic. This ensures clear contracts between services, better testing, and easier maintenance.

## When to Use

- Designing new APIs
- Adding endpoints to existing APIs
- Defining service boundaries
- Creating shared types
- Documenting API contracts

## Contracts-First Design

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. Define Contract        2. Implement                │
│     (Interface)               (Logic)                   │
│                                                         │
│  ┌─────────────┐          ┌─────────────┐              │
│  │ Interface   │          │ Logic       │              │
│  │ Types       │  ──────> │ Service     │              │
│  │ Validation  │          │ Repository  │              │
│  │ Docs        │          │ Controllers │              │
│  └─────────────┘          └─────────────┘              │
│         ↓                                                 │
│  ┌─────────────┐                                        │
│  │ Tests       │                                        │
│  │ (Contract)  │                                        │
│  └─────────────┘                                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Step 1: Define the Contract

### Request/Response Types

Define clear types first:

```typescript
// ✅ Good: Contract-first types
// interfaces/User.ts

export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  createdAt: string;
  updatedAt: string;
}

export interface CreateUserData {
  name: string;
  email: string;
  password: string;
  role?: UserRole;
}

export interface UpdateUserData {
  name?: string;
  email?: string;
  role?: UserRole;
}

export enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
  MODERATOR = 'moderator'
}

// API Request/Response types
export interface CreateUserRequest {
  body: CreateUserData;
}

export interface CreateUserResponse {
  success: true;
  data: User;
}

export interface GetUserRequest {
  params: { id: string };
}

export interface GetUserResponse {
  success: true;
  data: User;
}

export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: unknown;
  };
}

export type ApiResponse<T> = CreateUserResponse | ErrorResponse;
```

### Validation Schema

Define validation schemas:

```typescript
// ✅ Good: Validation schemas
// schemas/user.ts

import { z } from 'zod';

export const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8).regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/),
  role: z.enum(['user', 'admin', 'moderator']).optional().default('user')
});

export const updateUserSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  email: z.string().email().optional(),
  role: z.enum(['user', 'admin', 'moderator']).optional()
}).refine(val => Object.keys(val).length > 0, {
  message: 'At least one field must be provided'
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
```

### API Documentation

Document the contract:

```typescript
// ✅ Good: API documentation
// docs/api/users.md

# Users API

## Create User

Creates a new user account.

### Request

```http
POST /api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123",
  "role": "user"
}
```

### Response

**Success (201)**

```json
{
  "success": true,
  "data": {
    "id": "usr_123abc",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

**Error (400)**

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": {
      "email": "Invalid email format"
    }
  }
}
```

### Validation Rules

- `name`: 2-100 characters
- `email`: Valid email format
- `password`: Min 8 chars, must contain uppercase, lowercase, and number
- `role`: Optional, defaults to "user"
```

## Step 2: Write Contract Tests

Test the contract before implementation:

```typescript
// ✅ Good: Contract tests
// tests/contracts/user-api.test.ts

import { createUserSchema, updateUserSchema } from '@/schemas/user';

describe('User API Contract', () => {
  describe('createUserSchema', () => {
    const validInput = {
      name: 'John Doe',
      email: 'john@example.com',
      password: 'SecurePass123',
      role: 'user' as const
    };

    it('should validate correct input', () => {
      expect(() => createUserSchema.parse(validInput)).not.toThrow();
    });

    it('should reject invalid name', () => {
      const input = { ...validInput, name: 'J' };
      expect(() => createUserSchema.parse(input)).toThrow();
    });

    it('should reject invalid email', () => {
      const input = { ...validInput, email: 'not-an-email' };
      expect(() => createUserSchema.parse(input)).toThrow();
    });

    it('should reject weak password', () => {
      const input = { ...validInput, password: 'weak' };
      expect(() => createUserSchema.parse(input)).toThrow();
    });

    it('should default role to user', () => {
      const input = { name: 'John', email: 'john@example.com', password: 'SecurePass123' };
      const result = createUserSchema.parse(input);
      expect(result.role).toBe('user');
    });
  });

  describe('updateUserSchema', () => {
    const validInput = {
      name: 'John Doe'
    };

    it('should validate partial updates', () => {
      expect(() => updateUserSchema.parse(validInput)).not.toThrow();
    });

    it('should reject empty updates', () => {
      expect(() => updateUserSchema.parse({})).toThrow();
    });
  });
});
```

## Step 3: Implement the Contract

Implement based on the contract:

```typescript
// ✅ Good: Implementation follows contract
// controllers/user.ts

import { createUserSchema, updateUserSchema } from '@/schemas/user';
import { UserService } from '@/services/UserService';
import type { CreateUserRequest, GetUserRequest, ApiResponse } from '@/interfaces/User';

export class UserController {
  constructor(private userService: UserService) {}

  async createUser(req: CreateUserRequest): Promise<ApiResponse> {
    // Validate against contract
    const validated = createUserSchema.parse(req.body);

    // Call service
    const user = await this.userService.create(validated);

    // Return contract response
    return {
      success: true,
      data: user
    };
  }

  async getUser(req: GetUserRequest): Promise<ApiResponse> {
    const user = await this.userService.findById(req.params.id);

    if (!user) {
      return {
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'User not found'
        }
      };
    }

    return {
      success: true,
      data: user
    };
  }

  async updateUser(req: Request & { params: { id: string } }): Promise<ApiResponse> {
    // Validate against contract
    const validated = updateUserSchema.parse(req.body);

    const user = await this.userService.update(req.params.id, validated);

    return {
      success: true,
      data: user
    };
  }
}
```

## API Design Principles

### 1. Consistent Naming

Use consistent naming conventions:

```typescript
// ✅ Good: Consistent naming
GET    /api/users          // List users
GET    /api/users/:id      // Get user
POST   /api/users          // Create user
PATCH  /api/users/:id      // Update user
DELETE /api/users/:id      // Delete user

// Nested resources
GET    /api/users/:id/posts        // User's posts
POST   /api/users/:id/posts        // Create post for user
```

### 2. Proper HTTP Methods

Use correct HTTP methods:

```typescript
// ✅ Good: Correct HTTP methods
GET    /api/users          // Retrieve (safe, idempotent)
POST   /api/users          // Create (not idempotent)
PUT    /api/users/:id      // Full update (idempotent)
PATCH  /api/users/:id      // Partial update (not idempotent)
DELETE /api/users/:id      // Delete (idempotent)
```

### 3. Status Codes

Use appropriate status codes:

```typescript
// ✅ Good: Correct status codes
200 OK              // Successful GET, PUT, PATCH
201 Created         // Successful POST
204 No Content      // Successful DELETE
400 Bad Request     // Validation error
401 Unauthorized    // Not authenticated
403 Forbidden       // Authenticated but not authorized
404 Not Found       // Resource not found
409 Conflict        // Resource already exists
422 Unprocessable   // Business logic violation
500 Server Error    // Unexpected error
```

### 4. Error Responses

Consistent error response format:

```typescript
// ✅ Good: Consistent error format
interface ErrorResponse {
  success: false;
  error: {
    code: string;           // Machine-readable error code
    message: string;        // Human-readable message
    details?: unknown;      // Additional error details
    stack?: string;         // Stack trace (development only)
  };
}
```

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Implementation-first | Unclear contracts | Define contracts first |
| Inconsistent naming | Confusing API | Use consistent naming |
| Wrong HTTP methods | Breaking semantics | Use correct methods |
| No validation | Invalid data | Validate all inputs |
| Poor error responses | Hard to debug | Consistent error format |

## Coaching Notes

> **ABC - Always Be Coaching:** API interface design teaches you that a well-defined contract eliminates ambiguity between teams and makes implementation almost mechanical.

1. **Types are the first draft of documentation:** When you define request and response types before writing logic, you are forced to think through edge cases, optional fields, and error states up front. The types become a spec that humans and compilers can both read.
2. **Validate at the boundary, not deep inside:** Input validation belongs at the API gateway, not scattered through service layers. A Zod schema at the entry point catches bad data before it contaminates your domain.
3. **Consistency is a feature:** When every endpoint uses the same response envelope, error format, and naming convention, consumers spend zero time guessing how to parse your API. Pick one convention and enforce it everywhere.

## Verification

After API interface design:

- [ ] Contract defined before implementation
- [ ] Types and schemas defined
- [ ] API documentation written
- [ ] Contract tests written
- [ ] Implementation follows contract
- [ ] Validation is comprehensive
- [ ] Error responses are consistent
- [ ] HTTP methods are correct
- [ ] Status codes are appropriate

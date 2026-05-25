---
name: api-interface-design
description: Design API interfaces contracts-first. Use when creating new APIs, adding endpoints, or defining service boundaries.
version: "3.0.0"
category: "expert-backend"
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

# API Interface Design

[ROLE]
Act as an API design expert. Define contracts (types, validation schemas, documentation) before implementing any logic.

[OBJECTIVE]
Produce API interfaces where request/response types are defined first, validation schemas enforce correctness, and contract tests verify compliance before implementation begins.

[RULES]
1. <thought>Before writing any implementation, define: What are the request/response types? What validation rules apply? What error responses are possible? What HTTP methods and status codes are correct?</thought>
2. Define contracts first — types, schemas, and docs before logic.
3. Use consistent naming conventions across all endpoints.
4. Use correct HTTP methods and status codes (GET=200, POST=201, DELETE=204, validation=400, not found=404).
5. Use consistent error response format — `{ success: false, error: { code, message, details } }`.
6. Write contract tests before implementation.
7. Validate at the boundary with Zod/class-validator — not deep inside services.
8. DO NOT write controller logic before defining types.
9. DO NOT use inconsistent naming conventions across endpoints.
10. DO NOT return raw error messages without structured format.
11. ABC: Types are the first draft of documentation — when you define request and response types before writing logic, you are forced to think through edge cases and error states up front.

[PROCESS]

### Step 1: Define the Contract

```typescript
export interface User {
  id: string; name: string; email: string; role: UserRole; createdAt: string;
}
export interface CreateUserData { name: string; email: string; password: string; role?: UserRole; }

export const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8).regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/),
  role: z.enum(['user', 'admin', 'moderator']).optional().default('user')
});
```

### Step 2: Write Contract Tests

```typescript
describe('User API Contract', () => {
  it('should validate correct input', () => {
    expect(() => createUserSchema.parse(validInput)).not.toThrow();
  });
  it('should reject invalid email', () => {
    expect(() => createUserSchema.parse({ ...validInput, email: 'not-an-email' })).toThrow();
  });
});
```

### Step 3: Implement the Contract

```typescript
export class UserController {
  async createUser(req: CreateUserRequest): Promise<ApiResponse> {
    const validated = createUserSchema.parse(req.body);
    const user = await this.userService.create(validated);
    return { success: true, data: user };
  }
}
```

### HTTP Status Codes

```
200 OK              // Successful GET, PUT, PATCH
201 Created         // Successful POST
204 No Content      // Successful DELETE
400 Bad Request     // Validation error
401 Unauthorized    // Not authenticated
403 Forbidden       // Not authorized
404 Not Found       // Resource not found
409 Conflict        // Resource already exists
422 Unprocessable   // Business logic violation
```

### Verification

- [ ] Contract defined before implementation
- [ ] Types and schemas defined
- [ ] API documentation written
- [ ] Contract tests written
- [ ] Validation is comprehensive
- [ ] Error responses are consistent
- [ ] HTTP methods and status codes are correct

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with types, schemas, and contract tests, `patterns_applied`, and `recommendations`.

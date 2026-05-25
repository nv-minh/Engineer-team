---
name: typescript-patterns
description: TypeScript patterns for type-safe, idiomatic code covering advanced types, error handling, async, modules, generics, and React/Next.js integration. Use when writing TypeScript that needs to be robust, maintainable, and expressive.
version: "3.0.0"
category: "expert-typescript"
origin: "ecc"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["typescript", "ts patterns", "type safety", "generics", "branded types", "discriminated unions"]
intent: "Equip developers with battle-tested TypeScript patterns that leverage the full type system to catch errors at compile time, not runtime."
scenarios:
  - "Building a domain model with discriminated unions and branded types so illegal states are unrepresentable"
  - "Implementing a type-safe Result monad to replace try/catch error handling across a service layer"
  - "Designing a generic API client with inference that derives response types from endpoint definitions"
best_for: "type system mastery, error handling, async safety, module design, React+TS integration, testing types"
estimated_time: "30-50 min"
anti_patterns:
  - "Using `any` to silence the compiler instead of `unknown` with proper narrowing"
  - "Casting with `as` to bypass type errors instead of fixing the underlying type definitions"
  - "Throwing untyped errors that force callers to guess what went wrong instead of using Result types"
related_skills: ["frontend-patterns", "backend-patterns", "api-interface-design", "test-driven-development", "code-review"]

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

# TypeScript Patterns

[ROLE]
Act as a TypeScript expert. Deliver code that leverages the full type system — discriminated unions, branded types, Result types, and generic inference — to catch errors at compile time.

[OBJECTIVE]
Produce TypeScript code where illegal states are unrepresentable, error handling is explicit via Result types, async operations are properly awaited, and generics provide inference without requiring explicit type annotations at call sites.

[RULES]
1. <thought>Before writing any type, ask: Can this state be invalid? If so, model it as a discriminated union. Can these two string IDs be confused? If so, use branded types.</thought>
2. Use `unknown` over `any` — always narrow before using.
3. Model multi-state values as discriminated unions with exhaustiveness checks.
4. Use branded types to prevent mixing values that share the same primitive type.
5. Use Result types or typed custom error classes — make error handling visible in signatures.
6. DO NOT use `any` — use `unknown` and narrow with type guards.
7. DO NOT use `as` casts to bypass type errors — fix the underlying type definition.
8. DO NOT throw untyped errors — use Result types or typed error hierarchies.
9. DO NOT use `enum` keyword — use `as const` objects or union types.
10. Use `Promise.all` for independent async operations — never sequential awaits for independent work.
11. Use named exports for tree-shaking — no catch-all default exports.
12. Use `satisfies` to validate type shape while preserving literal types.
13. Enable TypeScript strict mode (`strict: true` in tsconfig).
14. ABC: Make illegal states unrepresentable — every `switch` with a `default: never` exhaustiveness check is a bug that will never reach production.

[PROCESS]

### Discriminated Unions

```typescript
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error; retry: () => void };

function handleState<T>(state: RequestState<T>) {
  switch (state.status) {
    case 'idle': return 'Not started';
    case 'loading': return 'Loading...';
    case 'success': return `Got: ${JSON.stringify(state.data)}`;
    case 'error': return `Failed: ${state.error.message}`;
    default: const _exhaustive: never = state; return _exhaustive;
  }
}
```

### Branded Types

```typescript
type Brand<T, B> = T & { __brand: B };
type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;

getUser(userId);   // OK
getUser(orderId);  // Type error!
```

### Result Type

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

async function createUser(data: CreateUserData): Promise<Result<User, UserError>> {
  const existing = await findUserByEmail(data.email);
  if (existing) return err({ type: 'DUPLICATE_EMAIL', email: data.email });
  const user = await saveUser(data);
  return ok(user);
}
```

### Async Patterns

```typescript
// Parallel independent work
const [user, posts, notifications] = await Promise.all([
  getUser(userId), getPosts(userId), getNotifications(userId),
]);

// Cancellation with AbortController
useEffect(() => {
  const controller = new AbortController();
  fetchWithAbort(url, controller.signal).then(setData);
  return () => controller.abort();
}, [url]);

// Batch processing with concurrency limit
async function processInBatch<T, R>(items: T[], processor: (item: T) => Promise<R>, concurrency = 5): Promise<R[]> {
  const results: R[] = [];
  for (let i = 0; i < items.length; i += concurrency) {
    const batch = items.slice(i, i + concurrency);
    results.push(...await Promise.all(batch.map(processor)));
  }
  return results;
}
```

### Generic Patterns

```typescript
// Constrained generics
function findById<T extends { id: string }>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id);
}

// Typed event emitter
class TypedEmitter<Events extends Record<string, unknown>> {
  on<E extends keyof Events>(event: E, handler: (payload: Events[E]) => void): () => void { /* ... */ }
  emit<E extends keyof Events>(event: E, payload: Events[E]): void { /* ... */ }
}
```

### Utility Types

```typescript
type UserProfile = Pick<User, 'name' | 'avatarUrl' | 'role'>;
type UserCreateForm = Omit<User, 'id' | 'createdAt'>;
type UserUpdateForm = Partial<Omit<User, 'id' | 'createdAt'>>;

// Deep partial
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object
    ? T[K] extends Array<infer U> ? Array<DeepPartial<U>> : DeepPartial<T[K]>
    : T[K];
};
```

### React/Next.js TypeScript

```typescript
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return <ul>{items.map(item => <li key={keyExtractor(item)}>{renderItem(item)}</li>)}</ul>;
}
```

### Testing

```typescript
function createFixture<T>(defaults: T): (overrides?: Partial<T>) => T {
  return (overrides = {}) => ({ ...defaults, ...overrides });
}
const createUserFixture = createFixture<User>({ id: 'usr_123', name: 'Jane', email: 'jane@example.com', role: 'viewer', createdAt: new Date('2025-01-01') });
```

### Verification

- [ ] No `any` types without documented justification
- [ ] No `as` casts that bypass type checking
- [ ] Discriminated unions used for multi-state domain models
- [ ] Error handling uses Result types or typed custom errors
- [ ] `Promise.all` used for independent async operations
- [ ] Module exports are tree-shaking friendly
- [ ] Generic functions have proper constraints and inference
- [ ] TypeScript strict mode enabled

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing TypeScript patterns used, and `recommendations` for improvements.

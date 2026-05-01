---
name: typescript-patterns
description: TypeScript patterns for type-safe, idiomatic code covering advanced types, error handling, async, modules, generics, and React/Next.js integration. Use when writing TypeScript that needs to be robust, maintainable, and expressive.
version: "2.0.0"
category: "development"
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
---

# TypeScript Patterns

## Overview

TypeScript's type system is among the most expressive in mainstream languages. When used to its full potential, it eliminates entire categories of runtime errors by making illegal states unrepresentable. This skill covers the patterns that turn TypeScript from "JavaScript with type annotations" into a tool for designing correct-by-construction software.

These patterns are drawn from production codebases and align with the type-safety standards enforced by the TypeScript reviewer agent.

## When to Use

- Building domain models that must prevent invalid states at compile time
- Designing APIs where the type checker enforces correct usage
- Writing async code that needs structured error handling instead of try/catch
- Creating reusable libraries with inference that "just works" for consumers
- Developing React/Next.js applications with end-to-end type safety
- Writing tests with typed mocks, fixtures, and assertions

## When NOT to Use

- Prototyping a quick script where type coverage adds no value
- Migrating a large JavaScript codebase incrementally (start with `noImplicitAny`, not strict mode everywhere)
- Writing runtime validation where Zod or Valibot schemas are the right tool (use them alongside these patterns)

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| `any` type | Disables the type checker entirely | Use `unknown` and narrow with type guards |
| `as` casts to bypass errors | Hides bugs the compiler caught | Fix the underlying type definition |
| Non-null assertion `!` without guard | Crashes at runtime if null | Add a runtime check before assertion |
| Throwing generic `Error` objects | Callers cannot discriminate errors | Use typed Result or custom error classes |
| `async` function returning `Promise<void>` with fire-and-forget | Unhandled rejections silently swallowed | Always await or `.catch()` promises |
| Barrel exports of everything | Kills tree-shaking, slows builds | Export only public API surface |
| `enum` keyword | Generates runtime code, nominal typing issues | Use `as const` objects or union types |
| `@ts-ignore` / `@ts-expect-error` without justification | Suppresses real type errors | Fix the type; comment why if suppression is needed |

## Core Patterns

### 1. Type System Best Practices

#### Discriminated Unions

Model states so the compiler prevents invalid combinations:

```typescript
// ✅ Good: Illegal states are unrepresentable
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error; retry: () => void };

function handleState<T>(state: RequestState<T>) {
  switch (state.status) {
    case 'idle':
      return 'Not started';
    case 'loading':
      return 'Loading...';
    case 'success':
      return `Got: ${JSON.stringify(state.data)}`; // TypeScript knows data exists
    case 'error':
      return `Failed: ${state.error.message}`; // TypeScript knows error exists
    // Exhaustiveness check -- compiler errors if a case is missed
    default:
      const _exhaustive: never = state;
      return _exhaustive;
  }
}

// ❌ Bad: Optional fields allow impossible states
interface BadRequestState<T> {
  isLoading: boolean;
  data?: T;       // could be loading with stale data
  error?: Error;  // could have error AND data
}
```

#### Branded Types (Opaque Types)

Prevent mixing values that share the same primitive type:

```typescript
// ✅ Good: UserId and OrderId are both strings but not interchangeable
type Brand<T, B> = T & { __brand: B };

type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;

function getUser(id: UserId): Promise<User> { /* ... */ }
function getOrder(id: OrderId): Promise<Order> { /* ... */ }

const userId = 'abc123' as UserId;
const orderId = 'ord456' as OrderId;

getUser(userId);   // OK
getUser(orderId);  // Type error! OrderId is not assignable to UserId

// Branded type constructor with validation
function createUserId(value: string): UserId {
  if (!/^usr_[a-z0-9]+$/.test(value)) {
    throw new Error('Invalid user ID format');
  }
  return value as UserId;
}
```

#### Template Literal Types

Constrain strings to known patterns at compile time:

```typescript
// ✅ Good: API route type safety
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type ApiVersion = 'v1' | 'v2';
type ApiRoute = `/${ApiVersion}/${string}`;

type EventName = `${string}:${'created' | 'updated' | 'deleted'}`;
// Valid: "user:created", "order:updated", "invoice:deleted"
// Invalid: "user:fetch" -- type error

// CSS-like utility type
type Spacing = 0 | 1 | 2 | 4 | 8;
type SpacingProperty = 'm' | 'p';
type SpacingDirection = '' | 't' | 'b' | 'l' | 'r' | 'x' | 'y';
type SpacingClass = `${SpacingProperty}${SpacingDirection}-${Spacing}`;
// Valid: "mt-4", "px-2", "m-0"
```

### 2. Error Handling Patterns

#### Result Type (Neverthrow Pattern)

Replace try/catch with explicit, typed error flows:

```typescript
// ✅ Good: Result type makes error handling visible and type-safe
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

// Usage with typed domain errors
type UserError =
  | { type: 'NOT_FOUND'; userId: string }
  | { type: 'DUPLICATE_EMAIL'; email: string }
  | { type: 'VALIDATION'; fields: Record<string, string> };

async function createUser(data: CreateUserData): Promise<Result<User, UserError>> {
  const existing = await findUserByEmail(data.email);
  if (existing) {
    return err({ type: 'DUPLICATE_EMAIL', email: data.email });
  }

  const validationErrors = validateUser(data);
  if (validationErrors) {
    return err({ type: 'VALIDATION', fields: validationErrors });
  }

  const user = await saveUser(data);
  return ok(user);
}

// Callers must handle both cases
const result = await createUser(input);
if (result.ok) {
  console.log('Created:', result.value.id);
} else {
  switch (result.error.type) {
    case 'NOT_FOUND': /* handle */ break;
    case 'DUPLICATE_EMAIL': /* handle */ break;
    case 'VALIDATION': /* handle */ break;
  }
}
```

#### Custom Error Hierarchy

When using exceptions, make them typed and discriminable:

```typescript
// ✅ Good: Structured error hierarchy
abstract class AppError extends Error {
  abstract readonly code: string;
  abstract readonly statusCode: number;
  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
  }
}

class ValidationError extends AppError {
  readonly code = 'VALIDATION_ERROR';
  readonly statusCode = 400;
  constructor(message: string, public readonly fields: string[]) {
    super(message);
  }
}

class NotFoundError extends AppError {
  readonly code = 'NOT_FOUND';
  readonly statusCode = 404;
  constructor(public readonly resource: string, public readonly id: string) {
    super(`${resource} with id ${id} not found`);
  }
}

class UnauthorizedError extends AppError {
  readonly code = 'UNAUTHORIZED';
  readonly statusCode = 401;
  constructor(reason: string) {
    super(reason);
  }
}

// Type-safe error handler
function isError<T extends AppError>(
  error: unknown,
  type: new (...args: any[]) => T
): error is T {
  return error instanceof type;
}

// Usage
try {
  await deleteUser(userId);
} catch (error) {
  if (isError(error, NotFoundError)) {
    return res.status(404).json({ code: error.code, resource: error.resource });
  }
  if (isError(error, UnauthorizedError)) {
    return res.status(401).json({ code: error.code });
  }
  throw error; // re-throw unknown errors
}
```

#### Type-Safe Error Handling with `unknown`

Never catch `any`; always catch `unknown` and narrow:

```typescript
// ✅ Good: Safe error narrowing
function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  if (typeof error === 'string') {
    return error;
  }
  return String(error);
}

// ❌ Bad: Catching any
catch (e: any) {
  console.log(e.message); // could be undefined
}
```

### 3. Async Patterns

#### Async/Await Best Practices

```typescript
// ✅ Good: Parallel independent work
async function loadDashboard(userId: string) {
  const [user, posts, notifications] = await Promise.all([
    getUser(userId),
    getPosts(userId),
    getNotifications(userId),
  ]);
  return { user, posts, notifications };
}

// ✅ Good: Sequential dependent work (explicit)
async function createUserAndSendWelcome(data: CreateUserData) {
  const user = await createUser(data);
  await sendWelcomeEmail(user.email); // depends on user being created first
  return user;
}

// ❌ Bad: Sequential awaits for independent work
async function slowDashboard(userId: string) {
  const user = await getUser(userId);         // waits...
  const posts = await getPosts(userId);        // then waits...
  const notifications = await getNotifications(userId); // then waits...
}

// ❌ Bad: forEach with async (does not await)
items.forEach(async (item) => {
  await processItem(item); // fires and forgets
});

// ✅ Good: Proper async iteration
for (const item of items) {
  await processItem(item);
}
// Or in parallel:
await Promise.all(items.map((item) => processItem(item)));
```

#### Promise Utilities

```typescript
// ✅ Good: Concurrent batch processing with limit
async function processInBatch<T, R>(
  items: T[],
  processor: (item: T) => Promise<R>,
  concurrency: number = 5
): Promise<R[]> {
  const results: R[] = [];
  for (let i = 0; i < items.length; i += concurrency) {
    const batch = items.slice(i, i + concurrency);
    const batchResults = await Promise.all(batch.map(processor));
    results.push(...batchResults);
  }
  return results;
}

// ✅ Good: Timeout wrapper
function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  return Promise.race([
    promise,
    new Promise<never>((_, reject) =>
      setTimeout(() => reject(new Error(`Timed out after ${ms}ms`)), ms)
    ),
  ]);
}

// Usage
const data = await withTimeout(fetchUser(userId), 5000);

// ✅ Good: Retry with exponential backoff
async function retry<T>(
  fn: () => Promise<T>,
  maxAttempts: number = 3,
  baseDelay: number = 1000
): Promise<T> {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxAttempts) throw error;
      const delay = baseDelay * Math.pow(2, attempt - 1);
      await new Promise((r) => setTimeout(r, delay));
    }
  }
  throw new Error('Unreachable');
}
```

#### Cancellation with AbortController

```typescript
// ✅ Good: Cancellable async operations
async function fetchWithAbort(
  url: string,
  signal: AbortSignal
): Promise<Response> {
  const response = await fetch(url, { signal });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }
  return response;
}

// Usage in a React effect
function useUserData(userId: string) {
  const [data, setData] = useState<User | null>(null);

  useEffect(() => {
    const controller = new AbortController();
    fetchWithAbort(`/api/users/${userId}`, controller.signal)
      .then((res) => res.json())
      .then(setData)
      .catch((err) => {
        if (err.name !== 'AbortError') throw err;
      });
    return () => controller.abort();
  }, [userId]);

  return data;
}
```

### 4. Module Patterns

#### Tree-Shaking Friendly Exports

```typescript
// ✅ Good: Named exports -- tree-shaker can remove unused ones
export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
}

export function formatDate(date: Date): string {
  return new Intl.DateTimeFormat('en-US').format(date);
}

// ❌ Bad: Default export of object with everything
export default {
  formatCurrency,
  formatDate,
  // ... 50 more functions
}; // forces bundler to include everything

// ✅ Good: Selective barrel file (index.ts)
// Only re-export the public API surface
export { formatCurrency, formatDate } from './formatters';
export { validateEmail, validatePhone } from './validators';
export type { User, Order, Product } from './types';
// Do NOT export internal helpers or test utilities
```

#### Namespace Organization with Type-Only Imports

```typescript
// ✅ Good: Type-only imports erased at runtime
import type { User, UserCreateInput } from './types';
import { createUser, findUser } from './repository';

// ✅ Good: Grouped by domain
// domain/user/types.ts
export interface User {
  id: UserId;
  email: string;
  name: string;
  role: UserRole;
  createdAt: Date;
}

export type UserRole = 'admin' | 'editor' | 'viewer';
export type UserCreateInput = Omit<User, 'id' | 'createdAt'>;

// domain/user/repository.ts
export async function findUser(id: UserId): Promise<User | null> { /* ... */ }
export async function createUser(input: UserCreateInput): Promise<User> { /* ... */ }

// domain/user/index.ts (barrel)
export type { User, UserRole, UserCreateInput } from './types';
export { findUser, createUser } from './repository';
```

### 5. Utility Types Patterns

#### Built-in Utility Types in Practice

```typescript
interface User {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'editor' | 'viewer';
  avatarUrl: string | null;
  createdAt: Date;
}

// Pick: select specific fields (e.g., public profile)
type UserProfile = Pick<User, 'name' | 'avatarUrl' | 'role'>;

// Omit: exclude fields (e.g., create form without auto-generated fields)
type UserCreateForm = Omit<User, 'id' | 'createdAt'>;

// Partial: all fields optional (e.g., update form)
type UserUpdateForm = Partial<Omit<User, 'id' | 'createdAt'>>;

// Required: remove optional modifier
type StrictConfig = Required<Config>;

// Record: dictionary types
type UserIndex = Record<string, User>;
type PermissionMap = Record<UserRole, string[]>;

// Extract / Exclude: filter union members
type AdminRole = Extract<UserRole, 'admin'>;
type NonAdminRole = Exclude<UserRole, 'admin'>;

// ReturnType / Parameters: derive types from functions
function createUser(input: UserCreateForm): Promise<User> { /* ... */ }
type CreateUserInput = Parameters<typeof createUser>[0];
type CreateUserResult = Awaited<ReturnType<typeof createUser>>;
```

#### Conditional Types

```typescript
// ✅ Good: Type-level function that transforms types
type ApiResponse<T> = T extends Array<infer U>
  ? { items: U[]; total: number }
  : { data: T };

// ApiResponse<User[]> => { items: User[]; total: number }
// ApiResponse<User>   => { data: User }

// Infer return type conditionally
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;

// Distributive conditional type
type NonNullableKeys<T> = {
  [K in keyof T]: null extends T[K] ? never : K;
}[keyof T];
```

#### Mapped Types

```typescript
// ✅ Good: Transform every property
type Optional<T> = {
  [K in keyof T]?: T[K];
};

// ✅ Good: Make specific properties required
type WithRequired<T, K extends keyof T> = T & Required<Pick<T, K>>;
type UserWithEmail = WithRequired<User, 'email'>;

// ✅ Good: Deep partial (recursive)
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object
    ? T[K] extends Array<infer U>
      ? Array<DeepPartial<U>>
      : DeepPartial<T[K]>
    : T[K];
};

// ✅ Good: Typed object from entries
function fromEntries<K extends string, V>(entries: [K, V][]): Record<K, V> {
  const result = {} as Record<K, V>;
  for (const [key, value] of entries) {
    result[key] = value;
  }
  return result;
}
```

### 6. Generic Patterns

#### Generic Constraints

```typescript
// ✅ Good: Constrain generic to objects with an id
function findById<T extends { id: string }>(
  items: T[],
  id: string
): T | undefined {
  return items.find((item) => item.id === id);
}

// ✅ Good: Constrain to string union keys
function pick<T, K extends keyof T>(obj: T, keys: K[]): Pick<T, K> {
  const result = {} as Pick<T, K>;
  for (const key of keys) {
    result[key] = obj[key];
  }
  return result;
}

// ✅ Good: Event emitter with typed events
interface EventMap {
  'user:login': { userId: string; timestamp: Date };
  'user:logout': { userId: string };
  'order:created': { orderId: string; total: number };
}

class TypedEmitter<Events extends Record<string, unknown>> {
  private handlers = new Map<keyof Events, Set<Function>>();

  on<E extends keyof Events>(
    event: E,
    handler: (payload: Events[E]) => void
  ): () => void {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, new Set());
    }
    this.handlers.get(event)!.add(handler);
    return () => this.handlers.get(event)?.delete(handler);
  }

  emit<E extends keyof Events>(event: E, payload: Events[E]): void {
    this.handlers.get(event)?.forEach((handler) => handler(payload));
  }
}

const emitter = new TypedEmitter<EventMap>();
emitter.on('user:login', (payload) => {
  console.log(payload.userId); // fully typed
});
```

#### Generic Defaults and Inference

```typescript
// ✅ Good: Generic with default
interface PaginatedResult<T, Meta = { total: number; page: number }> {
  items: T[];
  meta: Meta;
}

// ✅ Good: Inferred generic from argument
function createQuery<T>(config: {
  queryFn: () => Promise<T>;
  queryKey: string[];
}) {
  return config;
}

const query = createQuery({
  queryFn: () => fetch('/api/users').then((r) => r.json() as Promise<User[]>),
  queryKey: ['users'],
});
// query.queryFn return type is inferred as Promise<User[]>

// ✅ Good: Builder pattern with chained generics
class QueryBuilder<T> {
  constructor(private table: string) {}

  where(condition: (row: T) => boolean): this {
    // ...
    return this;
  }

  select<K extends keyof T>(...columns: K[]): QueryBuilder<Pick<T, K>> {
    // ...
    return this as unknown as QueryBuilder<Pick<T, K>>;
  }

  async execute(): Promise<T[]> { /* ... */ }
}

// Type narrows with each call
const users = await new QueryBuilder<User>('users')
  .where((u) => u.active)
  .select('id', 'name') // type becomes Pick<User, 'id' | 'name'>
  .execute();
```

### 7. React / Next.js TypeScript Patterns

#### Component Types

```typescript
// ✅ Good: Proper component typing
interface UserCardProps {
  user: User;
  onEdit: (userId: string) => void;
  variant?: 'compact' | 'full';
}

// Function declaration (preferred for hoisting and generics)
function UserCard({ user, onEdit, variant = 'full' }: UserCardProps) {
  return (
    <div className={`user-card user-card--${variant}`}>
      <h3>{user.name}</h3>
      <button onClick={() => onEdit(user.id)}>Edit</button>
    </div>
  );
}

// ✅ Good: Generic component
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  keyExtractor: (item: T) => string;
  emptyMessage?: string;
}

function List<T>({ items, renderItem, keyExtractor, emptyMessage }: ListProps<T>) {
  if (items.length === 0 && emptyMessage) {
    return <p>{emptyMessage}</p>;
  }
  return (
    <ul>
      {items.map((item) => (
        <li key={keyExtractor(item)}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}

// Usage: T is inferred from items
<List
  items={users}
  renderItem={(user) => <span>{user.name}</span>}
  keyExtractor={(user) => user.id}
/>
```

#### Hooks Typing

```typescript
// ✅ Good: Custom hook with full type safety
function useAsync<T>(
  asyncFn: () => Promise<T>,
  deps: unknown[] = []
): {
  data: T | null;
  error: Error | null;
  isLoading: boolean;
  execute: () => Promise<void>;
} {
  const [state, setState] = useState<{
    data: T | null;
    error: Error | null;
    isLoading: boolean;
  }>({ data: null, error: null, isLoading: false });

  const execute = useCallback(async () => {
    setState((prev) => ({ ...prev, isLoading: true, error: null }));
    try {
      const data = await asyncFn();
      setState({ data, error: null, isLoading: false });
    } catch (error) {
      setState({ data: null, error: error as Error, isLoading: false });
    }
  }, deps);

  return { ...state, execute };
}

// ✅ Good: Context with discriminated types
interface AuthState {
  isAuthenticated: true;
  user: User;
  token: string;
} | {
  isAuthenticated: false;
  user: null;
  token: null;
}

const AuthContext = createContext<AuthState>({
  isAuthenticated: false,
  user: null,
  token: null,
});

function useAuth(): AuthState {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be inside AuthProvider');
  return context;
}

// Consumer gets narrowed types automatically
function Header() {
  const auth = useAuth();
  if (auth.isAuthenticated) {
    return <span>{auth.user.name}</span>; // TypeScript knows user exists
  }
  return <span>Guest</span>;
}
```

#### Next.js TypeScript Patterns

```typescript
// ✅ Good: Typed route params and search params
interface PageProps {
  params: { id: string };
  searchParams: { tab?: string };
}

async function UserPage({ params, searchParams }: PageProps) {
  const user = await getUser(params.id);
  const activeTab = searchParams.tab ?? 'profile';
  // ...
}

// ✅ Good: Typed API route handlers (Next.js App Router)
import { NextRequest, NextResponse } from 'next/server';

interface RouteContext {
  params: { id: string };
}

export async function GET(
  request: NextRequest,
  context: RouteContext
): Promise<NextResponse<ApiResponse<User> | ApiError>> {
  const user = await getUser(context.params.id);
  if (!user) {
    return NextResponse.json(
      { success: false, error: { code: 'NOT_FOUND', message: 'User not found' } },
      { status: 404 }
    );
  }
  return NextResponse.json({ success: true, data: user });
}

// ✅ Good: Typed server actions
'use server';

async function createUser(formData: FormData): Promise<Result<User, UserError>> {
  const raw = {
    name: formData.get('name') as string,
    email: formData.get('email') as string,
  };

  const validated = createUserSchema.safeParse(raw);
  if (!validated.success) {
    return err({ type: 'VALIDATION', fields: formatZodErrors(validated.error) });
  }

  const user = await saveUser(validated.data);
  return ok(user);
}
```

### 8. Testing Patterns

#### Typed Mocks

```typescript
// ✅ Good: Type-safe mock creation
type MockedFunction<T extends (...args: any[]) => any> = jest.Mock<
  ReturnType<T>,
  Parameters<T>
>;

function createMock<T extends (...args: any[]) => any>(
  implementation?: T
): MockedFunction<T> {
  return jest.fn(implementation) as MockedFunction<T>;
}

// Usage: compiler checks mock matches real signature
const mockGetUser = createMock<(id: string) => Promise<User>>(
  async (id) => ({ id, name: 'Test', email: 'test@test.com', role: 'viewer', createdAt: new Date() })
);

// ✅ Good: Partial mock of a module
type UserService = {
  getUser: (id: string) => Promise<User>;
  createUser: (data: CreateUserData) => Promise<User>;
  deleteUser: (id: string) => Promise<void>;
};

function createUserServiceMock(
  overrides: Partial<UserService> = {}
): UserService {
  return {
    getUser: jest.fn(),
    createUser: jest.fn(),
    deleteUser: jest.fn(),
    ...overrides,
  };
}
```

#### Test Utilities

```typescript
// ✅ Good: Type-safe fixture factory
function createFixture<T>(defaults: T): (overrides?: Partial<T>) => T {
  return (overrides = {}) => ({ ...defaults, ...overrides });
}

const createUserFixture = createFixture<User>({
  id: 'usr_123',
  name: 'Jane Doe',
  email: 'jane@example.com',
  role: 'viewer',
  createdAt: new Date('2025-01-01'),
});

// Usage
const user = createUserFixture({ role: 'admin' });
// user.role is 'admin', everything else uses defaults

// ✅ Good: Type-safe test case definition
interface TestCase<I, E> {
  name: string;
  input: I;
  expected: E;
}

function runTests<I, E>(
  fn: (input: I) => E,
  cases: TestCase<I, E>[]
) {
  cases.forEach(({ name, input, expected }) => {
    test(name, () => {
      expect(fn(input)).toEqual(expected);
    });
  });
}

// Usage: input and expected types are inferred from the function
runTests(formatCurrency, [
  { name: 'formats zero', input: 0, expected: '$0.00' },
  { name: 'formats positive', input: 1234.56, expected: '$1,234.56' },
  { name: 'formats negative', input: -100, expected: '-$100.00' },
]);
```

### 9. Performance Patterns

#### `satisfies` Operator

Validate a value matches a type without widening:

```typescript
// ✅ Good: satisfies checks the shape but preserves literal types
const routes = {
  '/users': { method: 'GET', handler: getUsers },
  '/users': { method: 'POST', handler: createUser },
  '/users/:id': { method: 'GET', handler: getUser },
} satisfies Record<string, { method: HttpMethod; handler: Handler }>;

// routes['/users'].method is 'GET' | 'POST' (narrow literal), not HttpMethod (wide)

// ❌ Bad: type annotation widens to HttpMethod
const routes: Record<string, { method: HttpMethod; handler: Handler }> = { ... };
// routes['/users'].method is HttpMethod -- lost the literal
```

#### Const Assertions and Narrow Inference

```typescript
// ✅ Good: const assertion preserves literal types and readonly
const ROLES = ['admin', 'editor', 'viewer'] as const;
type Role = typeof ROLES[number]; // 'admin' | 'editor' | 'viewer'

const CONFIG = {
  apiUrl: 'https://api.example.com',
  maxRetries: 3,
  timeout: 5000,
} as const;
// CONFIG.apiUrl is 'https://api.example.com', not string

// ✅ Good: Satisfies + const for route definitions
const HTTP_METHODS = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'] as const;
type HttpMethod = typeof HTTP_METHODS[number];

const STATUS_CODES = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  NOT_FOUND: 404,
  INTERNAL_ERROR: 500,
} as const;
type StatusCode = typeof STATUS_CODES[keyof typeof STATUS_CODES]; // 200 | 201 | 400 | 404 | 500
```

#### Lazy Types and Code Splitting for Types

```typescript
// ✅ Good: type-only imports add zero runtime cost
import type { HeavyConfig } from './heavy-config';

// ✅ Good: conditional type loading
async function loadConfig(): Promise<HeavyConfig> {
  const { default: config } = await import('./heavy-config');
  return config;
}

// ✅ Good: Use interface for declaration merging (open-ended)
// Use type for closed, precise unions
interface AppConfig {
  apiUrl: string;
  timeout: number;
}
// Can be extended later: declaration merging works with interface, not type

type ApiResponseStatus = 'success' | 'error' | 'loading'; // closed union -- use type
```

## Coaching Notes

> **ABC - Always Be Coaching:** TypeScript patterns teach you that the type system is not an annoyance to work around -- it is a design tool that makes correctness visible and refactoring safe.

1. **Make illegal states unrepresentable:** If a `User` can be in one of three states, model it as a discriminated union, not an object with three optional booleans. The compiler then prevents you from forgetting a case. Every `switch` statement with a `default: never` exhaustiveness check is a bug that will never reach production.

2. **`unknown` over `any`, always:** Every `any` in your code is a hole in the safety net. `unknown` forces you to narrow before using, which is exactly what you should be doing anyway. If you reach for `any`, ask yourself: "Do I not know the type, or do I not want to write the type?" The answer is almost always the latter.

3. **Result types make error handling honest:** `try/catch` is invisible at the call site -- a function that might throw looks identical to one that cannot. Returning `Result<T, E>` makes failure visible in the type signature, forces callers to handle both paths, and makes refactoring safe because adding a new error case triggers a compile error at every unhandled call site.

4. **Generics are for the caller, not the implementer:** Write generic functions so the consumer gets inference for free. If someone has to explicitly write `<SomeType>` when calling your function, the generic signature is not designed well enough. Use constraints, defaults, and inference to make the call site clean.

## Verification Checklist

After implementing TypeScript patterns:

- [ ] No `any` types without a documented justification
- [ ] No `as` casts that bypass type checking (use type guards instead)
- [ ] No non-null assertions (`!`) without a preceding runtime check
- [ ] Discriminated unions used for multi-state domain models
- [ ] Error handling uses Result types or typed custom errors
- [ ] Async code has no floating promises or fire-and-forget
- [ ] `Promise.all` used for independent async operations
- [ ] Module exports are tree-shaking friendly (no catch-all default exports)
- [ ] Utility types used to derive related types (Pick, Omit, Record, etc.)
- [ ] Generic functions have proper constraints and inference
- [ ] React components and hooks are fully typed with explicit prop interfaces
- [ ] `satisfies` used where literal type preservation matters
- [ ] `as const` used for configuration objects and literal unions
- [ ] Test mocks and fixtures are type-safe
- [ ] TypeScript strict mode is enabled (`strict: true` in tsconfig)

## Related Skills

- **frontend-patterns** -- React/Next.js component patterns, state management, data fetching
- **backend-patterns** -- API design, repository pattern, transactions, caching
- **api-interface-design** -- Contract-first API design, OpenAPI, schema validation
- **test-driven-development** -- TDD red-green-refactor cycle, test strategies
- **code-review** -- 5-axis code review framework including type safety
- **security-hardening** -- OWASP patterns, input validation, secret management

---
name: deprecation-migration
description: Code-as-liability mindset with deprecation and migration strategies. Use when phasing out old code, migrating to new systems, or managing technical debt.
version: "2.0.0"
category: "workflow"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["deprecation", "migration", "technical debt", "refactor legacy"]
intent: "Systematically reduce code liability by planning, executing, and communicating the removal or replacement of deprecated systems."
scenarios:
  - "Migrating from session-based authentication to JWT with a gradual rollout using feature flags"
  - "Deprecating a legacy API version while maintaining backward compatibility for existing consumers"
  - "Identifying and removing dead code from a codebase that has accumulated unused modules over three years"
best_for: "legacy code removal, library migration, API versioning, technical debt reduction, dependency upgrades"
estimated_time: "20-45 min"
anti_patterns:
  - "Removing deprecated code without a migration period or communication, breaking downstream consumers"
  - "Marking code as deprecated but never actually removing it, creating a permanent maintenance burden"
  - "Rewriting from scratch instead of using incremental migration patterns like strangler fig"
related_skills: ["code-simplification", "documentation", "ci-cd-automation"]
---

# Deprecation and Migration

## Overview

Code is a liability — it requires maintenance, has bugs, and accumulates technical debt. Deprecation and migration strategies help manage this liability by systematically removing old code and migrating to better solutions.

## When to Use

- Phasing out deprecated features
- Migrating to new libraries/frameworks
- Managing technical debt
- Removing unused code
- Upgrading dependencies

## Code-as-Liability Mindset

### Every Line of Code Has a Cost

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Code Liability = Maintenance Cost + Risk + Debt        │
│                                                         │
│  Less Code → Less Liability → More Velocity            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### The Liability Equation

```
Total Liability = (Lines of Code × Complexity) × (Age × Dependency Count)

More code = More liability
More complexity = More liability
Older code = More liability
More dependencies = More liability
```

## Deprecation Strategy

### 1. Mark as Deprecated

```typescript
// ✅ Good: Deprecation warning
/**
 * Legacy authentication method.
 *
 * @deprecated Use `authenticateV2` instead. Will be removed in version 2.0.
 * @see authenticateV2
 *
 * @example
 * // Old way (deprecated)
 * const token = await authenticate(email, password);
 *
 * // New way
 * const token = await authenticateV2({ email, password });
 */
export async function authenticate(
  email: string,
  password: string
): Promise<string> {
  console.warn('authenticate is deprecated. Use authenticateV2 instead.');
  return authenticateV2({ email, password });
}
```

### 2. Add Migration Period

```typescript
// ✅ Good: Gradual migration
class UserService {
  /**
   * @deprecated Use `createUserV2` instead. Will be removed in version 3.0.
   */
  async createUser(data: LegacyUserData): Promise<User> {
    // Log deprecation warning
    this.logger.warn('createUser is deprecated. Use createUserV2 instead.');

    // Migrate to new format
    return this.createUserV2(this.migrateData(data));
  }

  /**
   * New user creation method with validation and improved error handling.
   */
  async createUserV2(data: UserData): Promise<User> {
    // New implementation
  }

  private migrateData(legacy: LegacyUserData): UserData {
    return {
      ...legacy,
      createdAt: legacy.created_at ?? new Date(),
      updatedAt: legacy.updated_at ?? new Date()
    };
  }
}
```

### 3. Document Migration Path

```markdown
# Migration Guide: authenticate to authenticateV2

## Why Migrate?

The new `authenticateV2` method provides:
- Better error handling
- Improved security (CSRF protection)
- Support for multi-factor authentication
- Better logging and monitoring

## Migration Steps

### Step 1: Update Function Calls

**Before:**
\`\`\`typescript
const token = await authenticate(email, password);
\`\`\`

**After:**
\`\`\`typescript
const token = await authenticateV2({ email, password });
\`\`\`

### Step 2: Update Type Definitions

**Before:**
\`\`\`typescript
interface AuthResult {
  token: string;
  user: User;
}
\`\`\`

**After:**
\`\`\`typescript
interface AuthenticateV2Input {
  email: string;
  password: string;
  mfaCode?: string;
}

interface AuthenticateV2Result {
  token: string;
  refreshToken: string;
  user: User;
  expiresAt: Date;
}
\`\`\`

### Step 3: Handle New Features

The new method supports optional MFA:
\`\`\`typescript
const result = await authenticateV2({
  email,
  password,
  mfaCode: userHasMfa ? mfaCode : undefined
});
\`\`\`

### Step 4: Update Error Handling

**Before:**
\`\`\`typescript
try {
  const token = await authenticate(email, password);
} catch (error) {
  // Generic error handling
}
\`\`\`

**After:**
\`\`\`typescript
try {
  const result = await authenticateV2({ email, password });
} catch (error) {
  if (error instanceof InvalidCredentialsError) {
    // Handle invalid credentials
  } else if (error instanceof MFARequiredError) {
    // Handle MFA requirement
  }
}
\`\`\`

## Timeline

- **Version 2.0**: Both methods available
- **Version 2.5**: Deprecation warnings added
- **Version 3.0**: `authenticate` removed

## Questions?

See [Authentication Documentation](/docs/auth.md) or create an issue.
```

## Migration Strategies

### 1. Strangler Fig Pattern

Gradually replace old system with new system:

```typescript
// ✅ Good: Strangler fig pattern
class Router {
  async route(request: Request): Promise<Response> {
    // New system handles specific routes
    if (this.isNewRoute(request.path)) {
      return this.newRouter.handle(request);
    }

    // Old system handles everything else
    return this.oldRouter.handle(request);
  }

  private isNewRoute(path: string): boolean {
    const newRoutes = ['/api/v2/users', '/api/v2/posts'];
    return newRoutes.some(route => path.startsWith(route));
  }
}
```

### 2. Feature Flags

Use feature flags for gradual rollout:

```typescript
// ✅ Good: Feature flag migration
class PaymentProcessor {
  async processPayment(amount: number): Promise<PaymentResult> {
    if (featureFlags.isEnabled('new-payment-system')) {
      return this.newPaymentSystem.process(amount);
    } else {
      return this.oldPaymentSystem.process(amount);
    }
  }
}
```

### 3. Adapter Pattern

Create adapter to bridge old and new:

```typescript
// ✅ Good: Adapter pattern
interface OldPaymentSystem {
  charge(amount: number): Promise<PaymentResult>;
}

interface NewPaymentSystem {
  processPayment(amount: number): Promise<PaymentResult>;
}

class PaymentAdapter implements OldPaymentSystem {
  constructor(private newSystem: NewPaymentSystem) {}

  async charge(amount: number): Promise<PaymentResult> {
    // Adapt old interface to new system
    return this.newSystem.processPayment(amount);
  }
}
```

## Dependency Migration

### 1. Library Migration

```typescript
// ✅ Good: Migrating from library A to library B

// Before: Library A
import { formatDate } from 'library-a';
const formatted = formatDate(date, 'YYYY-MM-DD');

// After: Library B (with adapter)
import { format } from 'library-b';

// Adapter function during migration
function formatDate(date: Date, formatString: string): string {
  // Log deprecation warning
  console.warn('formatDate from library-a is deprecated');

  // Map old format to new format
  const newFormat = mapFormatString(formatString);
  return format(date, newFormat);
}

// Eventually replace with direct usage
// const formatted = format(date, 'yyyy-MM-dd');
```

### 2. API Migration

```typescript
// ✅ Good: API version migration
class APIClient {
  private apiVersion: 'v1' | 'v2' = 'v1';

  async getUsers(): Promise<User[]> {
    if (this.apiVersion === 'v1') {
      return this.getUsersV1();
    } else {
      return this.getUsersV2();
    }
  }

  private async getUsersV1(): Promise<User[]> {
    // Old API call
    const response = await fetch('/api/v1/users');
    return response.json();
  }

  private async getUsersV2(): Promise<User[]> {
    // New API call
    const response = await fetch('/api/v2/users');
    const data = await response.json();
    return data.users; // Different response structure
  }

  useV2() {
    this.apiVersion = 'v2';
  }
}
```

## Technical Debt Management

### 1. Track Debt

```markdown
## Technical Debt Log

### Debt #1: Legacy Authentication System

**Description:**
Old authentication system using sessions instead of JWT.

**Impact:**
- Harder to scale (requires sticky sessions)
- More complex to implement mobile apps
- Security concerns with session storage

**Effort:** 5 days
**Priority:** High
**Risk:** Security vulnerability if not addressed

**Migration Plan:**
1. Implement JWT authentication alongside sessions (2 days)
2. Migrate all clients to JWT (2 days)
3. Remove session-based auth (1 day)

**Status:** In Progress (Step 1 complete)
**Target:** Version 2.0 release
```

### 2. Debt Prioritization

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Priority = (Impact × Risk) / Effort                   │
│                                                         │
│  High Impact + High Risk + Low Effort = DO FIRST       │
│  Low Impact + Low Risk + High Effort = MAYBE LATER     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 3. Debt Paydown

```typescript
// ✅ Good: Allocate time for debt paydown
// Rule of thumb: 20% of sprint time for technical debt

const sprintTasks = [
  // Feature work (80%)
  { type: 'feature', title: 'Add user profile', effort: 5 },
  { type: 'feature', title: 'Implement search', effort: 3 },

  // Debt paydown (20%)
  { type: 'debt', title: 'Migrate to JWT auth', effort: 2 },
  { type: 'debt', title: 'Remove unused code', effort: 1 }
];
```

## Code Removal

### 1. Identify Unused Code

```bash
# ✅ Good: Find unused code

# Find unused exports
npx ts-prune

# Find unused dependencies
npx depcheck

# Find dead code in JavaScript
npx eslint --ext .js,.ts src/ --rule 'no-unused-vars: error'
```

### 2. Remove Deprecated Code

```typescript
// ✅ Good: Remove deprecated code after migration period

// Step 1: Mark as deprecated
/**
 * @deprecated Will be removed in version 2.0
 */
export function oldFunction() {
  // Implementation
}

// Step 2: Migrate all callers
// Update all code to use newFunction instead

// Step 3: Remove after migration period
// Delete oldFunction and update documentation
```

### 3. Remove Dead Code

```typescript
// ❌ Bad: Dead code remains
class UserService {
  async createUser(data: UserData): Promise<User> {
    // New implementation
  }

  // Dead code - never called
  private async legacyCreateUser(data: any): Promise<any> {
    // Old implementation
  }
}

// ✅ Good: Remove dead code
class UserService {
  async createUser(data: UserData): Promise<User> {
    // Implementation
  }
}
```

## Best Practices

### 1. Deprecation Timeline

```
Phase 1 (Current): Both old and new available
Phase 2 (1 release later): Old marked as deprecated
Phase 3 (2 releases later): Old shows warnings
Phase 4 (3 releases later): Old removed
```

### 2. Communication

```markdown
## Deprecation Notice

**Feature:** Legacy Authentication
**Removed In:** Version 3.0
**Migration Guide:** [Link to guide]

**Action Required:** Update your code to use the new authentication method before version 3.0.

**Questions?** Open an issue or contact the team.
```

### 3. Testing

```typescript
// ✅ Good: Test migration path
describe('Migration: oldFunction to newFunction', () => {
  it('should produce same result', () => {
    const input = { test: 'data' };
    const oldResult = oldFunction(input);
    const newResult = newFunction(input);

    expect(newResult).toEqual(oldResult);
  });

  it('should handle edge cases', () => {
    const edgeCases = [
      null,
      undefined,
      {},
      { test: null }
    ];

    edgeCases.forEach(input => {
      const oldResult = oldFunction(input);
      const newResult = newFunction(input);

      expect(newResult).toEqual(oldResult);
    });
  });
});
```

## Coaching Notes

> **ABC - Always Be Coaching:** Code is a liability -- every line you remove is a line you never have to debug, test, or explain again.

1. **Deprecation Is a Conversation, Not a Decision:** Marking something deprecated is the start of a communication process, not the end. Provide a migration guide, a timeline, and a clear replacement. Give consumers time and a path forward.
2. **Migrate Incrementally, Never Rewrite Wholesale:** The strangler fig pattern works because each small migration is independently testable and revertable. A big-bang rewrite is a bet-the-company risk. Replace one route, one module, one endpoint at a time.
3. **Dead Code Should Terrify You:** Code that no one uses, no one tests, and no one understands is a time bomb. It still gets dependencies updated under it, still gets accidentally imported, and still confuses new developers. Find it and remove it ruthlessly.

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| No migration plan | Confusion and breakage | Document migration path |
| Abrupt removal | Breaking changes | Gradual deprecation |
| No timeline | Unclear when to migrate | Set clear dates |
| No testing | Regressions | Test migration thoroughly |
| Not communicating | Users surprised | Announce changes early |

## Verification

After deprecation/migration:

- [ ] Old code marked as deprecated
- [ ] Migration guide written
- [ ] New implementation tested
- [ ] Migration path tested
- [ ] Timeline communicated
- [ ] Users notified
- [ ] Documentation updated
- [ ] Old code removed after period

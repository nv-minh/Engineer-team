# Code Quality Reference

Shared code quality standards referenced by code-review, code-simplification, and related skills.

---

## 5-Axis Code Review Framework

| Axis | Questions to Ask | Weight |
|------|-----------------|--------|
| **Correctness** | Does it match requirements? Edge cases handled? Error paths covered? | 30% |
| **Readability** | Clear names? Self-documenting? No unnecessary comments? | 20% |
| **Architecture** | Clean boundaries? No circular deps? Right abstraction level? | 20% |
| **Security** | Input validated? No secrets? Auth checks? | 20% |
| **Performance** | No N+1 queries? Pagination? No unbounded operations? | 10% |

## 9-Axis Code Review (Extended)

Add these axes to the 5-axis review for deep reviews:

| Axis | Questions |
|------|-----------|
| **Error Handling** | Graceful degradation? Meaningful messages? Recovery paths? |
| **Concurrency** | Race conditions? Deadlocks? Thread safety? |
| **Testing** | Tests cover the change? Good assertions? Not testing implementation? |

## Complexity Thresholds

| Metric | Good | Acceptable | Refactor |
|--------|------|------------|----------|
| Cyclomatic complexity | 1-5 | 6-10 | 11+ |
| Function length | <20 lines | 20-40 | 40+ |
| File length | <200 lines | 200-400 | 400+ |
| Parameters | 1-3 | 4-5 | 6+ |
| Nesting depth | 1-2 | 3 | 4+ |

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Variables | camelCase | `userName`, `isActive` |
| Constants | UPPER_SNAKE | `MAX_RETRIES`, `API_BASE_URL` |
| Functions | camelCase (verb) | `getUser()`, `validateInput()` |
| Classes | PascalCase | `UserService`, `AuthMiddleware` |
| Types/Interfaces | PascalCase | `UserData`, `ApiResponse` |
| Files | kebab-case | `user-service.ts`, `auth-middleware.ts` |
| Directories | kebab-case | `api-handlers/`, `test-utils/` |
| Booleans | is/has/should prefix | `isLoading`, `hasPermission`, `shouldRetry` |

## Code Smells

| Smell | Detection | Fix |
|-------|-----------|-----|
| Long method | >40 lines | Extract smaller functions |
| Deep nesting | >3 levels | Early returns, guard clauses |
| Magic numbers | Unnamed constants | Extract to named constants |
| Duplicate code | Same logic in 3+ places | Extract shared utility |
| Feature envy | Method uses another class more | Move method to that class |
| God class | >500 lines, many responsibilities | Split by responsibility |
| Dead code | Unreachable, unused imports | Remove immediately |

## Refactoring Patterns

### Extract Function
```typescript
// Before
function processOrder(order: Order) {
  // 30 lines of validation
  // 20 lines of calculation
  // 15 lines of persistence
}

// After
function processOrder(order: Order) {
  validateOrder(order);
  const total = calculateTotal(order);
  persistOrder(order, total);
}
```

### Replace Conditional with Polymorphism
```typescript
// Before
function getPrice(item: Item): number {
  if (item.type === 'book') return item.base * 0.9;
  if (item.type === 'electronics') return item.base * 1.1;
  return item.base;
}

// After
interface Item { getPrice(): number; }
class BookItem implements Item { getPrice() { return this.base * 0.9; } }
class ElectronicsItem implements Item { getPrice() { return this.base * 1.1; } }
```

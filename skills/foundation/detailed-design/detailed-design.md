---
name: detailed-design
description: "Creates a formal 詳細設計 (Detailed Design Document) — module-level design specifications before implementation. Use after Basic Design is approved, for each module or component that needs per-function specs, class diagrams, and test design before coding."
version: "1.0.0"
category: "foundation"
origin: "EM-Team (Japanese outsourcing)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "detailed design"
  - "詳細設計"
  - "module design"
  - "class diagram"
  - "function spec"
  - "design per module"
intent: "Produce per-module Detailed Design Documents that specify class structures, function contracts, data flows, exception handling, and test designs at a level sufficient for implementation without ambiguity."
scenarios:
  - "Japanese outsourcing context requiring 詳細設計 before implementation sign-off"
  - "Complex module with multiple collaborating classes that needs upfront design"
  - "Team handoff where offshore developers need per-function specifications"
  - "High-risk module (payment, auth) requiring detailed review before coding"
best_for: "Pre-implementation design, team handoff, high-risk modules, Japanese outsourcing"
estimated_time: "1-3 hours per module"
anti_patterns:
  - "Writing Detailed Design without an approved Basic Design"
  - "Class diagrams that show every private field — focus on interfaces and contracts"
  - "Skipping test design — test cases should be designed before implementation"
  - "Over-specifying trivial modules — reserve detailed design for complex/risky code"
related_skills:
  - spec-driven-development
  - writing-plans
  - test-driven-development
  - api-interface-design
---

# Detailed Design (詳細設計)

## Overview

The Detailed Design Document (詳細設計書) specifies how each module implements the system design approved in the Basic Design. Where Basic Design answers "what does the system do and how are components connected," Detailed Design answers "how does each component work internally."

In Japanese outsourcing practice, Detailed Design is required per module before implementation begins. It enables:
- Developer onboarding without verbal explanation
- Review of logic before code is written
- Basis for test case design (test design from spec, not from code)
- Traceability from requirements → design → implementation → tests

## When to Use

- Starting implementation of a complex module after Basic Design approval
- Module has multiple classes, non-trivial state management, or complex algorithms
- Team handoff: offshore team needs unambiguous specs to implement
- High-risk module (auth, payments, data migration) requiring upfront logic review

**When NOT to Use:** Simple CRUD endpoints with no business logic, utility functions under 20 lines, UI-only changes with no new business rules.

## When NOT to Use

- Trivial CRUD operations with no business logic
- UI-only components with no state management
- Basic Design not yet approved (do not start Detailed Design prematurely)

## Anti-Patterns

- Starting implementation without Detailed Design review for complex modules
- Showing every private field in class diagrams — focus on public contracts and key internal state
- Designing without test cases — test cases derived from design are far better than those derived from code
- Creating a monolithic Detailed Design for the whole system — one doc per module, sized to fit in one review session

## Process

### Step 1: Identify Modules for Detailed Design

Not every module needs a Detailed Design document. Use this decision matrix:

```
Does this module have:                          → Action
  Complex business logic (>3 conditions)?         Detailed Design required
  Non-trivial state machine?                       Detailed Design required
  Multiple collaborating classes?                  Detailed Design required
  External system integration?                     Detailed Design required
  Authentication/authorization logic?              Detailed Design required
  Data migration or transformation?                Detailed Design required
  Simple CRUD, no business rules?                  Skip (spec is enough)
  Utility function < 20 lines?                     Skip
```

### Step 2: Write the Detailed Design Document

Create `docs/detailed-design/<module-name>.md` for each module:

---

**Detailed Design Document Template:**

```markdown
# Detailed Design: [Module Name] (詳細設計書)
**Module:** [e.g., OrderService]
**Version:** 1.0.0
**Date:** YYYY-MM-DD
**Author:** [Author]
**Based on:** docs/BASIC-DESIGN.md v[X.X]
**Status:** Draft | Under Review | Approved

---

## 1. Module Overview (モジュール概要)

### 1.1 Purpose
[What this module does. One paragraph.]

### 1.2 Responsibilities
- [ ] [Responsibility 1: e.g., Validate order data against business rules]
- [ ] [Responsibility 2: e.g., Calculate order total including tax and discounts]
- [ ] [Responsibility 3: e.g., Persist order to database atomically]

### 1.3 What This Module Does NOT Do
- [e.g., Does NOT process payments — that is PaymentService's responsibility]
- [e.g., Does NOT send email notifications — that is NotificationService]

---

## 2. Class/Module Diagram (クラス図)

```
┌──────────────────────────────────┐
│         OrderService             │
├──────────────────────────────────┤
│ - orderRepo: OrderRepository     │
│ - paymentService: PaymentService │
│ - eventBus: EventBus             │
├──────────────────────────────────┤
│ + createOrder(dto): Order        │
│ + cancelOrder(id): void          │
│ + getOrder(id): Order            │
│ - validateOrder(dto): void       │
│ - calculateTotal(items): Money   │
└──────────────────────────────────┘
         │ uses
         ▼
┌──────────────────────────────────┐
│         OrderRepository          │
├──────────────────────────────────┤
│ + save(order): Order             │
│ + findById(id): Order | null     │
│ + findByUserId(userId): Order[]  │
└──────────────────────────────────┘
```

---

## 3. Function Specifications (関数仕様)

For each public function/method:

### 3.1 `createOrder(dto: CreateOrderDto): Promise<Order>`

**Purpose:** Create a new order with validation and payment reservation.

**Pre-conditions:**
- User must be authenticated (userId exists in session)
- All items in dto.items must exist in the product catalog
- dto.items must have at least one item

**Post-conditions:**
- Order is persisted with status PENDING
- Payment reservation is created
- OrderCreated event is emitted

**Parameters:**
| Param | Type | Required | Validation |
|---|---|---|---|
| dto.userId | UUID | Yes | Must exist in users table |
| dto.items | Item[] | Yes | Min 1 item, each item.productId must exist |
| dto.shippingAddress | Address | Yes | All address fields required |

**Returns:** `Order` object with id, status, total, items

**Errors:**
| Error Code | Condition | HTTP Status |
|---|---|---|
| `PRODUCT_NOT_FOUND` | Any item.productId does not exist | 404 |
| `INSUFFICIENT_STOCK` | Any item quantity > available stock | 422 |
| `PAYMENT_FAILED` | Payment reservation failed | 402 |
| `VALIDATION_ERROR` | DTO validation fails | 400 |

**Algorithm:**
```
1. Validate DTO (throw VALIDATION_ERROR if invalid)
2. For each item: fetch product, verify stock (throw if insufficient)
3. Calculate total = sum(item.price * item.quantity) + tax
4. Create order record with status = PENDING
5. Reserve payment via paymentService.reserve(orderId, total)
   - If payment fails: delete order record, throw PAYMENT_FAILED
6. Update order status = CONFIRMED
7. Emit OrderCreated event
8. Return order
```

---

### 3.2 `cancelOrder(id: UUID): Promise<void>`

**Purpose:** Cancel an existing order, releasing payment reservation.

**Pre-conditions:**
- Order with given id must exist
- Order status must be PENDING or CONFIRMED (not SHIPPED or DELIVERED)

**Post-conditions:**
- Order status is CANCELLED
- Payment reservation is released
- OrderCancelled event is emitted

**Errors:**
| Error Code | Condition | HTTP Status |
|---|---|---|
| `ORDER_NOT_FOUND` | Order id does not exist | 404 |
| `INVALID_STATUS` | Order cannot be cancelled in current status | 422 |

**Algorithm:**
```
1. Fetch order by id (throw ORDER_NOT_FOUND if not found)
2. Verify status is PENDING or CONFIRMED (throw INVALID_STATUS otherwise)
3. Release payment via paymentService.release(orderId)
4. Update order status = CANCELLED
5. Emit OrderCancelled event
```

---

## 4. Data Flow Diagram (データフロー図)

**createOrder flow:**
```
Request
  │
  ▼
[Validate DTO] ──error──→ [400 Response]
  │ ok
  ▼
[Fetch Products] ──not found──→ [404 Response]
  │ found
  ▼
[Check Stock] ──insufficient──→ [422 Response]
  │ ok
  ▼
[Calculate Total]
  │
  ▼
[Save Order (PENDING)] ──db error──→ [500 Response]
  │ ok
  ▼
[Reserve Payment] ──failed──→ [Rollback Order] → [402 Response]
  │ ok
  ▼
[Update Order (CONFIRMED)]
  │
  ▼
[Emit OrderCreated Event]
  │
  ▼
[200 Response: Order]
```

---

## 5. Exception Handling Table (例外処理一覧)

| Exception | Where Thrown | Where Caught | Recovery Action |
|---|---|---|---|
| ProductNotFoundException | fetchProduct() | createOrder() | Throw PRODUCT_NOT_FOUND |
| InsufficientStockException | checkStock() | createOrder() | Throw INSUFFICIENT_STOCK |
| PaymentException | paymentService.reserve() | createOrder() | Rollback order, throw PAYMENT_FAILED |
| DatabaseException | orderRepo.save() | Global handler | Log, return 500 |

---

## 6. Test Design (テスト設計)

### 6.1 Unit Test Cases

| Test ID | Test Case | Input | Expected Output |
|---|---|---|---|
| UT-001 | createOrder success | Valid DTO, stock available | Returns Order with status CONFIRMED |
| UT-002 | createOrder invalid DTO | Missing userId | Throws VALIDATION_ERROR |
| UT-003 | createOrder product not found | Non-existent productId | Throws PRODUCT_NOT_FOUND |
| UT-004 | createOrder insufficient stock | Quantity > stock | Throws INSUFFICIENT_STOCK |
| UT-005 | createOrder payment failure | paymentService throws | Order rolled back, throws PAYMENT_FAILED |
| UT-006 | cancelOrder success | CONFIRMED order | Status CANCELLED, event emitted |
| UT-007 | cancelOrder not found | Non-existent id | Throws ORDER_NOT_FOUND |
| UT-008 | cancelOrder invalid status | SHIPPED order | Throws INVALID_STATUS |

### 6.2 Integration Test Scenarios

| Test ID | Scenario | Setup | Assertion |
|---|---|---|---|
| IT-001 | Full order flow | Real DB, mock payment | Order persisted with CONFIRMED status |
| IT-002 | Concurrent order creation | Parallel requests for same product | Stock correctly reduced, no overselling |

---

## 7. Configuration & Dependencies (設定・依存関係)

### 7.1 Dependencies
| Dependency | Version | Purpose |
|---|---|---|
| OrderRepository | Internal | Data access |
| PaymentService | Internal | Payment processing |
| EventBus | Internal | Event emission |

### 7.2 Configuration
| Config Key | Type | Default | Description |
|---|---|---|---|
| `ORDER_EXPIRY_HOURS` | number | 24 | Hours before PENDING order expires |
| `MAX_ITEMS_PER_ORDER` | number | 50 | Maximum line items per order |

---

## 8. Open Issues (課題)

| ID | Issue | Impact | Owner | Due |
|---|---|---|---|---|
| DD-001 | [Issue description] | [High/Med/Low] | [Name] | YYYY-MM-DD |

---

## 9. Sign-Off (承認)

| Role | Name | Signature | Date |
|---|---|---|---|
| Tech Lead | | | |
| Dev Lead | | | |
| QA Lead | | | |

**Status after sign-off:** Approved → Proceed to Implementation
```

---

### Step 3: Review Gate

Before implementation begins on this module:

```
DETAILED DESIGN REVIEW CHECKLIST:
□ All public functions have complete pre/post-conditions
□ All error codes are defined with HTTP status
□ Data flow diagram covers success AND error paths
□ Exception handling table covers all exceptions
□ Test cases derived from spec (not from code)
□ Unit test IDs match function specs (every error path has a test)
□ Dependencies are listed with versions
□ Configuration is documented with defaults
□ Tech lead and QA lead have reviewed and signed off

GATE: Do not start implementation until sign-off section is complete.
```

## Document Lifecycle

- One Detailed Design document per module (not per class, not per function)
- Version bump (1.0 → 1.1) when function signatures change during review
- Major version bump (1.x → 2.0) when module responsibilities change
- Link back to BASIC-DESIGN.md version in frontmatter
- Archived when module is deprecated

## Coaching Notes

> **ABC - Always Be Coaching:**

1. **Test cases designed from spec are far more valuable than test cases derived from code.** When you write tests after implementation, you naturally test what the code does, not what it should do. Designing tests from the Detailed Design catches missing requirements before code exists.

2. **Pre/post-conditions are contracts, not comments.** They define what callers must provide and what the function guarantees. This enables parallel development: frontend can mock based on contracts without waiting for backend.

3. **Exception handling is a first-class concern.** Most production incidents come from unhandled edge cases. The exception handling table forces you to think through all failure modes before they happen in production.

4. **Detailed Design is not a UML class diagram generator.** Its purpose is to answer: "can a developer implement this module correctly without asking questions?" If the answer is yes, the design is done.

## Verification

Before marking Detailed Design complete for a module:

- [ ] All public methods have pre/post-conditions, parameters, return type, and errors
- [ ] Data flow diagram shows all paths (success + all error paths)
- [ ] Exception handling table covers every exception that can be thrown
- [ ] Test design covers every error code defined in the spec
- [ ] Sign-off section completed
- [ ] Saved to `docs/detailed-design/<module-name>.md`

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

After completing this skill, export to:
`architecture/YYYY-MM-DD-HHMM-detailed-design-<module>.md`

Include YAML frontmatter: skill name, module name, date, version, related basic-design version.

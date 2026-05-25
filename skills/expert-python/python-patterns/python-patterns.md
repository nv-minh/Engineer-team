---
name: python-patterns
description: Python development patterns for modern Python 3.10+ codebases. Covers type hints, async, data models, design patterns, testing, APIs, databases, and performance. Use when writing Python services, libraries, scripts, or any Python code that should be production-grade.
version: "3.0.0"
category: "expert-python"
origin: "ecc"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["python", "pydantic", "fastapi", "django", "asyncio", "type hints", "pytest"]
intent: "Equip developers with idiomatic, modern Python patterns that produce code which is type-safe, testable, performant, and maintainable at scale."
scenarios:
  - "Building a FastAPI service with Pydantic models, async database access, and structured error handling"
  - "Refactoring a legacy Django project to use type hints, dataclasses, and the repository pattern"
  - "Writing a data pipeline using async generators, SQLAlchemy 2.0, and property-based tests"
best_for: "type hints, async patterns, data models, API design, testing, database access, performance"
estimated_time: "30-50 min"
anti_patterns:
  - "Using bare except clauses or catching Exception everywhere instead of specific exception types"
  - "Placing SQL queries directly in route handlers instead of using the repository pattern"
  - "Using mutable default arguments like def f(x=[]) or sharing state across async tasks without locks"
related_skills: ["backend-patterns", "api-interface-design", "test-driven-development", "security-hardening"]

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

# Python Patterns

[ROLE]
Act as a Python expert. Deliver modern Python 3.10+ code with comprehensive type hints, structured error hierarchies, async patterns, and Pydantic at API boundaries.

[OBJECTIVE]
Produce Python code that is type-safe (mypy --strict), uses Pydantic at API boundaries and dataclasses internally, handles errors with custom exception hierarchies, and uses generators for memory-efficient data pipelines.

[RULES]
1. <thought>Before writing any Python function, determine: What are the input/output types? Is this sync or async? Does it need Pydantic (API boundary) or dataclass (internal)?</thought>
2. Annotate all public functions with parameter types and return types.
3. Use `Protocol` over abstract base classes for structural subtyping.
4. Use Pydantic at API boundaries, frozen dataclasses internally.
5. Build custom exception hierarchies — never use bare `except:`.
6. Use `asyncio.TaskGroup` (Python 3.11+) for structured concurrency.
7. DO NOT use `def f(x=[])` — mutable default arguments are shared across calls.
8. DO NOT use bare `except:` or `except Exception: pass` — catch specific types.
9. DO NOT use `Any` everywhere in type hints — use specific types, Protocol, or TypeVar.
10. DO NOT mix sync and async code without `run_in_executor`.
11. DO NOT use `print()` for logging — use `logging` module or `structlog`.
12. Use generators for lazy evaluation and memory-efficient data pipelines.
13. Use `asyncio.Semaphore` for bounded concurrent tasks.
14. ABC: Generators are Python's secret weapon — a chain of generators processes billions of rows with constant memory.

[PROCESS]

### Type Hints

```python
from collections.abc import Sequence
from typing import Protocol, TypeVar

T = TypeVar("T")

@runtime_checkable
class Repository(Protocol[T]):
    def find_by_id(self, id: str) -> T | None: ...
    def save(self, entity: T) -> T: ...

def first(items: Sequence[T]) -> T | None:
    return items[0] if items else None
```

### Error Handling

```python
class AppError(Exception):
    def __init__(self, message: str, code: str, status: int = 500) -> None:
        super().__init__(message)
        self.message, self.code, self.status = message, code, status

class ValidationError(AppError):
    def __init__(self, message: str, field: str | None = None) -> None:
        super().__init__(message, code="VALIDATION_ERROR", status=400)
        self.field = field

class NotFoundError(AppError):
    def __init__(self, resource: str, id: str) -> None:
        super().__init__(f"{resource} '{id}' not found", code="NOT_FOUND", status=404)
```

### Async Patterns

```python
async def fetch_dashboard(user_id: str) -> dict:
    async with asyncio.TaskGroup() as tg:
        user_task = tg.create_task(fetch_user(user_id))
        orders_task = tg.create_task(fetch_orders(user_id))
    return {"user": user_task.result(), "orders": orders_task.result()}

async def fetch_many(urls: list[str], *, max_concurrent: int = 10) -> list[dict]:
    semaphore = asyncio.Semaphore(max_concurrent)
    async def fetch_one(url: str) -> dict:
        async with semaphore:
            async with httpx.AsyncClient() as client:
                resp = await client.get(url)
                return resp.json()
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_one(url)) for url in urls]
    return [task.result() for task in tasks]
```

### Data Models

```python
@dataclass(frozen=True)
class Money:
    amount: int  # cents
    currency: str = "USD"
    def add(self, other: Money) -> Money:
        if self.currency != other.currency: raise ValueError("Currency mismatch")
        return Money(amount=self.amount + other.amount, currency=self.currency)

class CreateUserRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: str = Field(..., pattern=r"^[\w.-]+@[\w.-]+\.\w+$")
    role: UserRole = UserRole.VIEWER
```

### Design Patterns

```python
# Dependency injection via Protocol
class NotificationSender(Protocol):
    async def send(self, recipient: str, message: str) -> bool: ...

class NotificationService:
    def __init__(self, sender: NotificationSender) -> None:
        self._sender = sender

# Factory pattern
def get_pricing_strategy(tier: str) -> PricingStrategy:
    strategies = {"standard": StandardPricing(), "bulk": BulkDiscountPricing()}
    if tier not in strategies: raise ValueError(f"Unknown tier: {tier}")
    return strategies[tier]
```

### Testing

```python
@pytest.fixture
def user_service(mock_repo, mock_email):
    return UserService(user_repo=mock_repo, email_service=mock_email)

@pytest.mark.asyncio
async def test_register_new_user(user_service, mock_repo, mock_email):
    user = await user_service.register("Alice", "alice@example.com")
    assert user.name == "Alice"
    mock_repo.save.assert_called_once()

@pytest.mark.parametrize("name, email, expected_error", [
    ("", "alice@example.com", "Name too short"),
    ("Alice", "not-an-email", "Invalid email"),
])
def test_register_invalid_input(name, email, expected_error):
    with pytest.raises(ValueError, match=expected_error):
        validate_registration(name, email)
```

### Database (SQLAlchemy 2.0)

```python
class UserRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def find_by_email(self, email: str) -> UserORM | None:
        stmt = select(UserORM).where(UserORM.email == email)
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

class UnitOfWork:
    async def __aenter__(self) -> UnitOfWork:
        self._session = self._session_factory()
        return self
    async def __aexit__(self, exc_type, exc_val, exc_tb) -> None:
        if exc_type: await self._session.rollback()
        else: await self._session.commit()
        await self._session.close()
```

### Performance

```python
# Generators for lazy evaluation
def read_large_file(path: str) -> Iterator[dict]:
    with open(path) as f:
        for line in f:
            parts = line.strip().split(",")
            yield {"id": parts[0], "value": float(parts[1])}

def batch(data: Iterator[dict], size: int = 100) -> Iterator[list[dict]]:
    current_batch: list[dict] = []
    for record in data:
        current_batch.append(record)
        if len(current_batch) >= size:
            yield current_batch
            current_batch = []
    if current_batch: yield current_batch
```

### Verification

- [ ] All public functions have type annotations (mypy --strict)
- [ ] Error handling uses custom exception hierarchy, not bare except
- [ ] Resources managed via context managers
- [ ] Async code does not block the event loop
- [ ] Pydantic at API boundaries, dataclasses internally
- [ ] Database access uses repository pattern with async sessions
- [ ] Tests use fixtures and parametrize
- [ ] No mutable default arguments, no wildcard imports

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing Python patterns used, and `recommendations` for improvements.

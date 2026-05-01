---
name: python-patterns
description: Python development patterns for modern Python 3.10+ codebases. Covers type hints, async, data models, design patterns, testing, APIs, databases, and performance. Use when writing Python services, libraries, scripts, or any Python code that should be production-grade.
version: "2.0.0"
category: "development"
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
---

# Python Patterns

## Overview

Modern Python (3.10+) offers a rich set of tools for writing clean, type-safe, and performant code. This skill covers the patterns that distinguish production-grade Python from quick scripts: comprehensive type hints, structured error hierarchies, async best practices, data modeling with Pydantic and dataclasses, classic design patterns adapted for Python, testing with pytest, API development with FastAPI, database access with SQLAlchemy 2.0, and performance optimization.

## When to Use

- Writing new Python services, libraries, or modules
- Refactoring legacy Python to modern idioms
- Building REST or GraphQL APIs with FastAPI or Flask
- Designing database schemas and queries with SQLAlchemy
- Writing async I/O-bound code with asyncio
- Setting up testing infrastructure with pytest
- Optimizing Python performance for CPU-bound or I/O-bound workloads

## When NOT to Use

- One-off scripts under 50 lines where patterns add more overhead than value
- Prototyping where speed of iteration matters more than structural correctness
- Legacy Python 3.8 or earlier where modern type syntax is unavailable (prefer upgrading instead)

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| `def f(x=[])` | Mutable default shared across calls | Use `x: list \| None = None` and assign inside function |
| Bare `except:` or `except Exception: pass` | Silently swallows bugs | Catch specific exceptions, always log or re-raise |
| `type(x) == int` | Breaks subclass relationships | Use `isinstance(x, int)` |
| `from module import *` | Namespace pollution, hidden dependencies | Import only what you need explicitly |
| `print()` for logging | No timestamps, levels, or routing | Use `logging` module or `structlog` |
| God functions > 50 lines | Hard to test, read, and maintain | Extract into smaller functions or classes |
| `Any` everywhere in type hints | Defeats the purpose of typing | Use specific types, `Protocol`, or `TypeVar` |
| String concatenation in loops | O(n^2) performance | Use `"".join(parts)` |
| Mixing sync and async code | Event loop blocking, deadlocks | Run sync code in `run_in_executor`, keep boundaries clear |
| SQL via f-strings | SQL injection vulnerability | Use parameterized queries or ORM methods |

## Core Patterns

### 1. Type Hints Best Practices

Use modern Python 3.10+ union syntax, generic types, Protocol for structural subtyping, and TypeVar for reusable generics.

```python
from __future__ import annotations

from collections.abc import Callable, Iterable, Sequence
from typing import Protocol, TypeVar, runtime_checkable

# --- Modern union syntax (Python 3.10+) ---
def greet(name: str | None = None) -> str:
    return f"Hello, {name or 'world'}"

# --- Generic types ---
T = TypeVar("T")
K = TypeVar("K")
V = TypeVar("V")

def first(items: Sequence[T]) -> T | None:
    return items[0] if items else None

def pluck(items: Iterable[T], key: Callable[[T], K]) -> list[K]:
    return [key(item) for item in items]

# --- Protocol for structural subtyping ---
@runtime_checkable
class Closeable(Protocol):
    def close(self) -> None: ...

@runtime_checkable
class Repository(Protocol[T]):
    def find_by_id(self, id: str) -> T | None: ...
    def save(self, entity: T) -> T: ...
    def delete(self, id: str) -> bool: ...

# Any class with matching methods satisfies the Protocol -- no inheritance needed
class InMemoryUserRepo:
    def __init__(self) -> None:
        self._store: dict[str, dict] = {}

    def find_by_id(self, id: str) -> dict | None:
        return self._store.get(id)

    def save(self, entity: dict) -> dict:
        self._store[entity["id"]] = entity
        return entity

    def delete(self, id: str) -> bool:
        return self._store.pop(id, None) is not None

# InMemoryUserRepo satisfies Repository[dict] without declaring it
def process_with_repo(repo: Repository[dict]) -> None:
    repo.save({"id": "1", "name": "Alice"})

# --- Type aliases ---
type Vector = list[float]
type Matrix = list[Vector]
type JSON = str | int | float | bool | None | list["JSON"] | dict[str, "JSON"]

# --- Overloads for complex signatures ---
from typing import overload

@overload
def get_item(key: int) -> str: ...
@overload
def get_item(key: str) -> list[str]: ...
def get_item(key: int | str) -> str | list[str]:
    if isinstance(key, int):
        return f"item-{key}"
    return [f"item-{i}" for i in range(3)]
```

### 2. Error Handling Patterns

Build a custom exception hierarchy, use context managers for resource cleanup, and never swallow exceptions silently.

```python
import logging
from contextlib import contextmanager
from dataclasses import dataclass

logger = logging.getLogger(__name__)

# --- Custom exception hierarchy ---
class AppError(Exception):
    """Base for all application errors."""

    def __init__(self, message: str, code: str, status: int = 500) -> None:
        super().__init__(message)
        self.message = message
        self.code = code
        self.status = status


class ValidationError(AppError):
    def __init__(self, message: str, field: str | None = None) -> None:
        super().__init__(message, code="VALIDATION_ERROR", status=400)
        self.field = field


class NotFoundError(AppError):
    def __init__(self, resource: str, id: str) -> None:
        super().__init__(
            f"{resource} with id '{id}' not found",
            code="NOT_FOUND",
            status=404,
        )


class ConflictError(AppError):
    def __init__(self, message: str) -> None:
        super().__init__(message, code="CONFLICT", status=409)


class ExternalServiceError(AppError):
    def __init__(self, service: str, detail: str) -> None:
        super().__init__(
            f"External service '{service}' failed: {detail}",
            code="EXTERNAL_SERVICE_ERROR",
            status=502,
        )


# --- Context manager for resource cleanup ---
@contextmanager
def transaction_scope(conn):
    """Wrap database operations in a transaction that auto-commits or rolls back."""
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        logger.exception("Transaction rolled back")
        raise


# Usage
# with transaction_scope(db_conn) as conn:
#     conn.execute("INSERT INTO users ...", {"name": "Alice"})
#     conn.execute("INSERT INTO audit_log ...", {"action": "create_user"})

# --- Context manager for timing ---
import time

@contextmanager
def timed(operation: str):
    """Log how long an operation takes."""
    start = time.perf_counter()
    try:
        yield
    finally:
        elapsed = time.perf_counter() - start
        logger.info("%s completed in %.3fs", operation, elapsed)

# Usage
# with timed("data_import"):
#     import_data(large_file)

# --- Result type pattern (alternative to exceptions for expected failures) ---
from dataclasses import dataclass
from typing import Generic

@dataclass
class Ok(Generic[T]):
    value: T

@dataclass
class Err:
    error: AppError

type Result[T] = Ok[T] | Err

def divide(a: float, b: float) -> Result[float]:
    if b == 0:
        return Err(ValidationError("Division by zero", field="b"))
    return Ok(a / b)

# Usage with match
# match divide(10, 0):
#     case Ok(value):
#         print(f"Result: {value}")
#     case Err(err):
#         print(f"Error: {err.message}")
```

### 3. Async Patterns

Use asyncio for I/O-bound work. Prefer structured concurrency with TaskGroups (Python 3.11+). Never block the event loop.

```python
import asyncio
import logging
from collections.abc import AsyncIterator
from typing import Any

logger = logging.getLogger(__name__)

# --- Basic async function ---
async def fetch_user(user_id: str) -> dict[str, Any]:
    """Fetch a user from an external API."""
    # Use httpx or aiohttp for async HTTP
    import httpx
    async with httpx.AsyncClient() as client:
        response = await client.get(f"https://api.example.com/users/{user_id}")
        response.raise_for_status()
        return response.json()

# --- Concurrent execution with TaskGroup (Python 3.11+) ---
async def fetch_dashboard(user_id: str) -> dict[str, Any]:
    """Fetch multiple resources concurrently using structured concurrency."""
    async with asyncio.TaskGroup() as tg:
        user_task = tg.create_task(fetch_user(user_id))
        orders_task = tg.create_task(fetch_orders(user_id))
        settings_task = tg.create_task(fetch_settings(user_id))

    return {
        "user": user_task.result(),
        "orders": orders_task.result(),
        "settings": settings_task.result(),
    }

async def fetch_orders(user_id: str) -> list[dict]:
    # Stub
    return []

async def fetch_settings(user_id: str) -> dict:
    # Stub
    return {}

# --- Async generator for streaming ---
async def paginated_fetch(
    url: str,
    *,
    page_size: int = 100,
) -> AsyncIterator[list[dict[str, Any]]]:
    """Yield pages of results from a paginated API."""
    import httpx
    async with httpx.AsyncClient() as client:
        page = 1
        while True:
            response = await client.get(
                url, params={"page": page, "size": page_size}
            )
            response.raise_for_status()
            data = response.json()
            if not data:
                break
            yield data
            if len(data) < page_size:
                break
            page += 1

# Usage
# async for page in paginated_fetch("https://api.example.com/items"):
#     process_page(page)

# --- Run sync code without blocking the event loop ---
async def sync_in_executor(func, *args):
    """Run a blocking sync function in a thread pool."""
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(None, func, *args)

# Usage
# result = await sync_in_executor(cpu_intensive_computation, data)

# --- Async context manager for resource lifecycle ---
class AsyncDatabaseConnection:
    async def __aenter__(self) -> "AsyncDatabaseConnection":
        logger.info("Opening database connection")
        # await self._connect()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb) -> None:
        logger.info("Closing database connection")
        # await self._close()

    async def execute(self, query: str, params: dict | None = None) -> list[dict]:
        # Stub
        return []

# Usage
# async with AsyncDatabaseConnection() as db:
#     users = await db.execute("SELECT * FROM users WHERE active = :active", {"active": True})

# --- Semaphore-limited concurrent tasks ---
async def fetch_many(urls: list[str], *, max_concurrent: int = 10) -> list[dict]:
    """Fetch many URLs with bounded concurrency."""
    semaphore = asyncio.Semaphore(max_concurrent)

    async def fetch_one(url: str) -> dict:
        async with semaphore:
            import httpx
            async with httpx.AsyncClient() as client:
                resp = await client.get(url)
                resp.raise_for_status()
                return resp.json()

    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_one(url)) for url in urls]

    return [task.result() for task in tasks]
```

### 4. Data Models

Choose the right tool: dataclasses for internal DTOs, Pydantic for API boundaries, attrs for advanced features, NamedTuple for lightweight immutable records.

```python
from __future__ import annotations

import uuid
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import NamedTuple

# --- Dataclass with frozen immutability ---
@dataclass(frozen=True)
class Address:
    street: str
    city: str
    state: str
    zip_code: str
    country: str = "US"


@dataclass(frozen=True)
class Money:
    amount: int  # Store as cents to avoid float issues
    currency: str = "USD"

    def add(self, other: Money) -> Money:
        if self.currency != other.currency:
            raise ValueError(f"Currency mismatch: {self.currency} vs {other.currency}")
        return Money(amount=self.amount + other.amount, currency=self.currency)

    def display(self) -> str:
        return f"${self.amount / 100:.2f} {self.currency}"


# --- Dataclass with default_factory for mutable defaults ---
@dataclass
class Order:
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    items: list[str] = field(default_factory=list)
    created_at: datetime = field(default_factory=datetime.utcnow)
    status: str = "pending"

    def add_item(self, item: str) -> None:
        self.items.append(item)
        self.status = "updated"


# --- Pydantic for API boundary validation ---
from pydantic import BaseModel, Field, field_validator, model_validator

class UserRole(str, Enum):
    ADMIN = "admin"
    EDITOR = "editor"
    VIEWER = "viewer"


class CreateUserRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: str = Field(..., pattern=r"^[\w.-]+@[\w.-]+\.\w+$")
    role: UserRole = UserRole.VIEWER
    age: int | None = Field(None, ge=0, le=150)

    @field_validator("name")
    @classmethod
    def name_must_be_capitalized(cls, v: str) -> str:
        if not v[0].isupper():
            raise ValueError("Name must start with a capital letter")
        return v.strip()


class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    role: UserRole
    created_at: datetime

    model_config = {"from_attributes": True}  # Enable ORM mode


class PasswordChangeRequest(BaseModel):
    old_password: str = Field(..., min_length=8)
    new_password: str = Field(..., min_length=8)

    @model_validator(mode="after")
    def passwords_must_differ(self) -> "PasswordChangeRequest":
        if self.old_password == self.new_password:
            raise ValueError("New password must differ from old password")
        return self


# --- NamedTuple for lightweight immutable records ---
class Point(NamedTuple):
    x: float
    y: float

    def distance_to(self, other: Point) -> float:
        return ((self.x - other.x) ** 2 + (self.y - other.y) ** 2) ** 0.5


class Coordinates(NamedTuple):
    latitude: float
    longitude: float
```

### 5. Design Patterns

Dependency injection, repository pattern, factory, and strategy -- all adapted for Pythonic style.

```python
from __future__ import annotations

import logging
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Protocol, runtime_checkable

logger = logging.getLogger(__name__)

# --- Dependency Injection via Protocol ---
@runtime_checkable
class NotificationSender(Protocol):
    async def send(self, recipient: str, message: str) -> bool: ...


class EmailSender:
    async def send(self, recipient: str, message: str) -> bool:
        logger.info("Sending email to %s", recipient)
        # Actual email sending logic
        return True


class SmsSender:
    async def send(self, recipient: str, message: str) -> bool:
        logger.info("Sending SMS to %s", recipient)
        # Actual SMS sending logic
        return True


class NotificationService:
    def __init__(self, sender: NotificationSender) -> None:
        self._sender = sender

    async def notify(self, user_id: str, message: str) -> bool:
        # Resolve recipient from user_id in real code
        recipient = user_id
        return await self._sender.send(recipient, message)


# --- Repository Pattern ---
@dataclass(frozen=True)
class Product:
    id: str
    name: str
    price: float
    in_stock: bool


class ProductRepository(Protocol):
    async def find_by_id(self, id: str) -> Product | None: ...
    async def find_all(self, *, limit: int = 100, offset: int = 0) -> list[Product]: ...
    async def save(self, product: Product) -> Product: ...
    async def delete(self, id: str) -> bool: ...


class InMemoryProductRepository:
    def __init__(self) -> None:
        self._store: dict[str, Product] = {}

    async def find_by_id(self, id: str) -> Product | None:
        return self._store.get(id)

    async def find_all(self, *, limit: int = 100, offset: int = 0) -> list[Product]:
        all_products = list(self._store.values())
        return all_products[offset : offset + limit]

    async def save(self, product: Product) -> Product:
        self._store[product.id] = product
        return product

    async def delete(self, id: str) -> bool:
        return self._store.pop(id, None) is not None


# --- Factory Pattern ---
class PricingStrategy(ABC):
    @abstractmethod
    def calculate(self, base_price: float, quantity: int) -> float: ...


class StandardPricing(PricingStrategy):
    def calculate(self, base_price: float, quantity: int) -> float:
        return base_price * quantity


class BulkDiscountPricing(PricingStrategy):
    def __init__(self, threshold: int = 10, discount: float = 0.1) -> None:
        self.threshold = threshold
        self.discount = discount

    def calculate(self, base_price: float, quantity: int) -> float:
        total = base_price * quantity
        if quantity >= self.threshold:
            total *= 1 - self.discount
        return total


class SubscriptionPricing(PricingStrategy):
    def __init__(self, monthly_rate: float) -> None:
        self.monthly_rate = monthly_rate

    def calculate(self, base_price: float, quantity: int) -> float:
        # quantity = number of months
        return self.monthly_rate * quantity


def get_pricing_strategy(tier: str) -> PricingStrategy:
    """Factory function to create the right pricing strategy."""
    strategies: dict[str, PricingStrategy] = {
        "standard": StandardPricing(),
        "bulk": BulkDiscountPricing(threshold=10, discount=0.15),
        "enterprise": BulkDiscountPricing(threshold=5, discount=0.25),
        "subscription": SubscriptionPricing(monthly_rate=9.99),
    }
    if tier not in strategies:
        raise ValueError(f"Unknown pricing tier: {tier}")
    return strategies[tier]

# Usage
# strategy = get_pricing_strategy("bulk")
# total = strategy.calculate(base_price=100.0, quantity=15)
```

### 6. Testing Patterns

Use pytest with fixtures, parametrize, typed mocks, and property-based testing for thorough coverage.

```python
from __future__ import annotations

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from dataclasses import dataclass

# --- Fixtures for dependency injection ---
@dataclass(frozen=True)
class User:
    id: str
    name: str
    email: str


class UserService:
    def __init__(self, user_repo, email_service) -> None:
        self._repo = user_repo
        self._email = email_service

    async def register(self, name: str, email: str) -> User:
        existing = await self._repo.find_by_email(email)
        if existing:
            raise ValueError(f"User with email {email} already exists")
        user = User(id="new-id", name=name, email=email)
        await self._repo.save(user)
        await self._email.send_welcome(email)
        return user


@pytest.fixture
def mock_repo():
    repo = AsyncMock()
    repo.find_by_email.return_value = None
    repo.save.return_value = None
    return repo


@pytest.fixture
def mock_email():
    return AsyncMock()


@pytest.fixture
def user_service(mock_repo, mock_email):
    return UserService(user_repo=mock_repo, email_service=mock_email)


# --- Basic test ---
@pytest.mark.asyncio
async def test_register_new_user(user_service, mock_repo, mock_email):
    user = await user_service.register("Alice", "alice@example.com")

    assert user.name == "Alice"
    assert user.email == "alice@example.com"
    mock_repo.save.assert_called_once()
    mock_email.send_welcome.assert_called_once_with("alice@example.com")


# --- Parametrized tests ---
@pytest.mark.parametrize(
    "name, email, expected_error",
    [
        ("", "alice@example.com", "Name too short"),
        ("A", "alice@example.com", "Name too short"),
        ("Alice", "not-an-email", "Invalid email"),
        ("Alice", "", "Invalid email"),
    ],
)
def test_register_invalid_input(name, email, expected_error):
    with pytest.raises(ValueError, match=expected_error):
        validate_registration(name, email)


def validate_registration(name: str, email: str) -> None:
    if len(name) < 2:
        raise ValueError("Name too short")
    if "@" not in email:
        raise ValueError("Invalid email")


# --- Typed mock with spec for safety ---
def test_process_order():
    payment_gateway = MagicMock(spec=PaymentGateway)
    payment_gateway.charge.return_value = {"status": "success", "transaction_id": "tx-123"}

    order_service = OrderService(payment_gateway)
    result = order_service.process(Order(id="1", total=99.99))

    payment_gateway.charge.assert_called_once_with(amount=99.99)
    assert result.status == "processed"


class PaymentGateway:
    def charge(self, amount: float) -> dict:
        ...


@dataclass(frozen=True)
class Order:
    id: str
    total: float


class OrderService:
    def __init__(self, gateway: PaymentGateway) -> None:
        self._gateway = gateway

    def process(self, order: Order):
        self._gateway.charge(amount=order.total)
        return type("Result", (), {"status": "processed"})()


# --- Property-based testing with Hypothesis ---
# from hypothesis import given, strategies as st, settings
#
# @given(st.text(min_size=1, max_size=100), st.emails())
# @settings(max_examples=50)
# def test_register_valid_inputs_always_succeeds(name, email):
#     # This runs 50 times with random inputs
#     validate_registration(name, email)  # Should never raise
#
# @given(st.integers(min_value=1), st.integers(min_value=1))
# def test_pricing_is_always_positive(price, quantity):
#     strategy = StandardPricing()
#     result = strategy.calculate(float(price), quantity)
#     assert result > 0

# --- Test markers for categorization ---
# pytest.ini or pyproject.toml:
# [tool.pytest.ini_options]
# markers = ["unit: unit tests", "integration: integration tests", "slow: slow tests"]
#
# pytest -m "unit"              # Run only unit tests
# pytest -m "integration"       # Run only integration tests
# pytest -m "not slow"          # Skip slow tests
```

### 7. API Patterns

FastAPI and Flask typing patterns with request/response models and middleware.

```python
from __future__ import annotations

import logging
import time
from datetime import datetime

from fastapi import Depends, FastAPI, HTTPException, Request, Response, status
from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)

# --- FastAPI with typed request/response models ---
app = FastAPI(title="User Service", version="1.0.0")


class CreateUserRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: str = Field(..., pattern=r"^[\w.-]+@[\w.-]+\.\w+$")


class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    created_at: datetime


class ErrorResponse(BaseModel):
    code: str
    message: str
    detail: dict | None = None


class ListResponse(BaseModel):
    items: list[UserResponse]
    total: int
    page: int
    page_size: int


# --- Dependency injection in FastAPI ---
class UserService:
    def __init__(self, repo) -> None:
        self._repo = repo

    async def create_user(self, data: CreateUserRequest) -> UserResponse:
        existing = await self._repo.find_by_email(data.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail={"code": "CONFLICT", "message": "Email already registered"},
            )
        user = await self._repo.create(data)
        return UserResponse(
            id=user["id"],
            name=user["name"],
            email=user["email"],
            created_at=user["created_at"],
        )


def get_user_service() -> UserService:
    # In production, wire up the real repository
    return UserService(repo=None)


@app.post(
    "/api/users",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        409: {"model": ErrorResponse, "description": "Email already exists"},
        422: {"model": ErrorResponse, "description": "Validation error"},
    },
)
async def create_user(
    request: CreateUserRequest,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    """Create a new user account."""
    return await service.create_user(request)


@app.get("/api/users/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    user = await service._repo.find_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse(**user)


# --- Middleware for logging and timing ---
@app.middleware("http")
async def request_logging_middleware(request: Request, call_next):
    start = time.perf_counter()
    request_id = request.headers.get("X-Request-ID", "unknown")

    logger.info(
        "request_start method=%s path=%s request_id=%s",
        request.method,
        request.url.path,
        request_id,
    )

    try:
        response: Response = await call_next(request)
    except Exception as exc:
        logger.exception("request_error request_id=%s", request_id)
        raise

    elapsed = time.perf_counter() - start
    response.headers["X-Response-Time"] = f"{elapsed:.3f}s"
    logger.info(
        "request_end method=%s path=%s status=%d elapsed=%.3fs request_id=%s",
        request.method,
        request.url.path,
        response.status_code,
        elapsed,
        request_id,
    )

    return response


# --- Exception handler ---
from fastapi.responses import JSONResponse

class AppError(Exception):
    def __init__(self, message: str, code: str, status: int) -> None:
        self.message = message
        self.code = code
        self.status = status


@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status,
        content={"code": exc.code, "message": exc.message},
    )
```

### 8. Database Patterns

SQLAlchemy 2.0 with async sessions, the repository pattern, and migration discipline.

```python
from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import String, Text, select, func
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

# --- SQLAlchemy 2.0 declarative model ---
class Base(DeclarativeBase):
    pass


class UserORM(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    bio: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        default=datetime.utcnow, nullable=False
    )


# --- Async engine and session factory ---
engine = create_async_engine(
    "postgresql+asyncpg://user:pass@localhost/db",
    echo=False,
    pool_size=10,
    max_overflow=20,
)

async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


# --- Repository pattern with async SQLAlchemy ---
class UserRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def find_by_id(self, id: str) -> UserORM | None:
        return await self._session.get(UserORM, id)

    async def find_by_email(self, email: str) -> UserORM | None:
        stmt = select(UserORM).where(UserORM.email == email)
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_all(
        self, *, limit: int = 100, offset: int = 0
    ) -> list[UserORM]:
        stmt = select(UserORM).order_by(UserORM.created_at.desc()).limit(limit).offset(offset)
        result = await self._session.execute(stmt)
        return list(result.scalars().all())

    async def count(self) -> int:
        stmt = select(func.count()).select_from(UserORM)
        result = await self._session.execute(stmt)
        return result.scalar_one()

    async def create(self, name: str, email: str) -> UserORM:
        user = UserORM(name=name, email=email)
        self._session.add(user)
        await self._session.flush()
        return user

    async def delete(self, id: str) -> bool:
        user = await self.find_by_id(id)
        if not user:
            return False
        await self._session.delete(user)
        await self._session.flush()
        return True


# --- Unit of Work pattern ---
class UnitOfWork:
    def __init__(self, session_factory: async_sessionmaker[AsyncSession]) -> None:
        self._session_factory = session_factory

    async def __aenter__(self) -> UnitOfWork:
        self._session = self._session_factory()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb) -> None:
        if exc_type:
            await self._session.rollback()
        else:
            await self._session.commit()
        await self._session.close()

    @property
    def users(self) -> UserRepository:
        return UserRepository(self._session)


# Usage
# async with UnitOfWork(async_session) as uow:
#     user = await uow.users.create("Alice", "alice@example.com")
#     # Auto-commits on exit, auto-rolls back on exception

# --- Migration best practices ---
# Use Alembic for migrations:
#   alembic init migrations
#   alembic revision --autogenerate -m "create users table"
#   alembic upgrade head
#
# Rules:
#   1. Always review autogenerated migrations before applying
#   2. Never edit applied migrations -- create a new revision
#   3. Add data migrations separately from schema migrations
#   4. Test migrations on a copy of production data before deploying
#   5. Include rollback (downgrade) in every migration
```

### 9. Performance Patterns

Caching, lazy evaluation with generators, async I/O, and profiling-driven optimization.

```python
from __future__ import annotations

import functools
import hashlib
import logging
import time
from collections.abc import AsyncIterator, Iterator, Sequence
from typing import Any, Callable

logger = logging.getLogger(__name__)

# --- Memoization / caching ---
from functools import lru_cache

@lru_cache(maxsize=256)
def compute_score(user_id: str, model_version: str) -> float:
    """Expensive computation cached by arguments."""
    # Simulate expensive work
    time.sleep(0.1)
    return hash(user_id + model_version) % 100 / 100.0


# --- TTL cache for data that expires ---
import asyncio

class TTLCache:
    def __init__(self, ttl_seconds: float = 300.0) -> None:
        self._store: dict[str, tuple[float, Any]] = {}
        self._ttl = ttl_seconds

    def get(self, key: str) -> Any | None:
        if key in self._store:
            cached_at, value = self._store[key]
            if time.monotonic() - cached_at < self._ttl:
                return value
            del self._store[key]
        return None

    def set(self, key: str, value: Any) -> None:
        self._store[key] = (time.monotonic(), value)

    def invalidate(self, key: str) -> None:
        self._store.pop(key, None)


cache = TTLCache(ttl_seconds=300)

async def get_user_with_cache(user_id: str) -> dict:
    cached = cache.get(f"user:{user_id}")
    if cached:
        return cached
    # Fetch from database
    user = {"id": user_id, "name": "Alice"}
    cache.set(f"user:{user_id}", user)
    return user


# --- Generators for lazy evaluation and memory efficiency ---
def read_large_file(path: str) -> Iterator[dict]:
    """Yield parsed lines one at a time -- never loads full file into memory."""
    with open(path) as f:
        for line in f:
            parts = line.strip().split(",")
            yield {"id": parts[0], "value": float(parts[1])}


def process_pipeline(data: Iterator[dict]) -> Iterator[dict]:
    """Chain transformations lazily using generator composition."""
    for record in data:
        # Filter
        if record["value"] < 0:
            continue
        # Transform
        record["value_usd"] = record["value"] * 1.0
        # Enrich
        record["processed_at"] = time.time()
        yield record


def batch(data: Iterator[dict], size: int = 100) -> Iterator[list[dict]]:
    """Group lazy records into batches for bulk operations."""
    current_batch: list[dict] = []
    for record in data:
        current_batch.append(record)
        if len(current_batch) >= size:
            yield current_batch
            current_batch = []
    if current_batch:
        yield current_batch


# Usage -- processes a 10GB file with constant memory
# for b in batch(process_pipeline(read_large_file("transactions.csv"))):
#     db.bulk_insert(b)


# --- Async generator for streaming API responses ---
async def stream_results(query: str) -> AsyncIterator[dict]:
    """Stream database results without loading all rows into memory."""
    # async with async_session() as session:
    #     result = await session.stream(text(query))
    #     async for row in result:
    #         yield dict(row._mapping)
    yield {"id": "1", "name": "Alice"}  # Stub
    yield {"id": "2", "name": "Bob"}


# --- Profiling decorator ---
def profile(func: Callable) -> Callable:
    """Decorator that logs execution time and call count."""
    call_count = 0

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        nonlocal call_count
        call_count += 1
        start = time.perf_counter()
        try:
            result = func(*args, **kwargs)
            return result
        finally:
            elapsed = time.perf_counter() - start
            logger.info(
                "profile %s call #%d took %.4fs",
                func.__qualname__,
                call_count,
                elapsed,
            )

    return wrapper


# --- Connection pooling pattern ---
class DatabasePool:
    """Manage a pool of database connections with health checks."""

    def __init__(self, max_connections: int = 10) -> None:
        self._max = max_connections
        self._pool: list[Any] = []
        self._in_use: set[Any] = set()

    async def acquire(self) -> Any:
        if self._pool:
            conn = self._pool.pop()
        elif len(self._in_use) < self._max:
            conn = await self._create_connection()
        else:
            raise RuntimeError("Connection pool exhausted")
        self._in_use.add(conn)
        return conn

    async def release(self, conn: Any) -> None:
        self._in_use.discard(conn)
        self._pool.append(conn)

    async def _create_connection(self) -> Any:
        # Actual connection creation logic
        return object()
```

## Coaching Notes

> **ABC - Always Be Coaching:** Python patterns teach you that explicit typing, structured error handling, and lazy evaluation are what separate production Python from prototype scripts.

1. **Type hints are documentation that the compiler enforces:** Annotating every public function with parameter types and return types costs seconds to write but saves hours of debugging. Use `Protocol` over abstract base classes -- structural subtyping is more Pythonic and avoids tight coupling.

2. **Never block the event loop:** In async code, every `time.sleep()`, synchronous file read, or CPU-heavy computation blocks all other coroutines. Use `asyncio.to_thread()` or `loop.run_in_executor()` to offload blocking work. If a function is CPU-bound, consider multiprocessing instead of asyncio.

3. **Pydantic at the boundary, dataclasses internally:** Validate and deserialize external data with Pydantic at API edges. Inside your domain logic, use frozen dataclasses for immutability and clarity. This keeps validation costs at the edges and domain objects fast and predictable.

4. **Generators are Python's secret weapon for data pipelines:** A chain of generators processes billions of rows with constant memory. Compose `read_large_file -> transform -> filter -> batch -> write` and each step yields one item at a time. This pattern alone eliminates an entire class of out-of-memory errors.

5. **Test with the same structure as your code:** If you use dependency injection via Protocol, your tests can swap in async mocks without patching. If your error hierarchy is explicit, your tests can assert `with pytest.raises(ValidationError)` instead of catching generic exceptions.

## Verification

After implementing Python patterns:

- [ ] All public functions have type annotations (enforced by mypy --strict or pyright)
- [ ] Error handling uses a custom exception hierarchy, not bare except
- [ ] Resources (files, connections, locks) are managed via context managers
- [ ] Async code does not block the event loop (verified with pytest-asyncio)
- [ ] Data models use Pydantic at API boundaries and dataclasses internally
- [ ] Database access uses the repository pattern with async sessions
- [ ] Tests use fixtures for dependency injection and parametrize for edge cases
- [ ] API endpoints have typed request/response models and proper status codes
- [ ] Performance-critical paths use generators, caching, or async I/O
- [ ] Code passes `ruff check`, `mypy --strict`, and `pytest --cov` with >80% coverage
- [ ] No mutable default arguments, no wildcard imports, no print statements

## Related Skills

- **backend-patterns** -- General backend patterns (API design, auth, caching) language-agnostic
- **api-interface-design** -- Contract-first API design methodology
- **test-driven-development** -- TDD red-green-refactor cycle
- **security-hardening** -- OWASP Top 10 and security patterns
- **code-review** -- 5-axis code review framework
- **performance-optimization** -- Measure-first performance methodology

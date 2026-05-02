---
name: fastapi
description: >
  FastAPI framework patterns for high-performance Python APIs. Covers async handlers, Pydantic models,
  dependency injection, middleware, authentication, database integration, testing, and deployment.
  Use when building REST APIs, async services, or microservices with FastAPI.
version: "1.0.0"
category: "expert-python"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "fastapi"
  - "python api"
  - "async api"
  - "pydantic model"
  - "uvicorn"
  - "openapi docs"
  - "dependency injection fastapi"
intent: >
  Equip developers with production-grade FastAPI patterns covering routing, validation,
  dependency injection, middleware, auth, testing, and deployment.
scenarios:
  - "Building a REST API with async database access, Pydantic validation, and OpenAPI docs"
  - "Adding authentication, middleware, and rate limiting to an existing FastAPI service"
  - "Testing FastAPI endpoints with pytest and TestClient"
best_for: "FastAPI REST APIs, async Python services, Pydantic validation, dependency injection"
estimated_time: "20-40 min"
anti_patterns:
  - "Placing business logic directly in route handlers instead of service classes"
  - "Using synchronous database drivers with async endpoints, blocking the event loop"
  - "Skipping Pydantic models and accepting raw dict/JSON in endpoints"
related_skills: ["python-patterns", "api-interface-design", "backend-patterns", "test-driven-development"]
---

# FastAPI Patterns

## Overview

FastAPI is a modern, high-performance Python web framework for building APIs with automatic OpenAPI documentation, Pydantic validation, and native async support. This skill covers the patterns that produce production-grade FastAPI services: structured routing, dependency injection, middleware, authentication, database integration, testing, and deployment.

## When to Use

- Building new REST or async APIs with Python
- Creating microservices with automatic OpenAPI documentation
- Implementing authenticated endpoints with OAuth2 or JWT
- Integrating async databases (SQLAlchemy, Tortoise, Prisma)
- Building high-throughput I/O-bound services

## When NOT to Use

- Simple server-rendered HTML pages (use Django or Flask instead)
- CPU-bound workloads where async adds no value (use Celery or multiprocessing)
- Prototypes under 50 lines where framework overhead is wasteful

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Business logic in route handlers | Hard to test and reuse | Extract into service classes |
| Sync DB drivers in async endpoints | Blocks the event loop | Use asyncpg, aiomysql, or async SQLAlchemy |
| Raw dict parameters | No validation, no docs | Use Pydantic BaseModel for all inputs/outputs |
| `async def` everywhere | Unnecessary overhead for simple routes | Use `def` for sync, `async def` only for I/O |
| Missing error responses in docs | API consumers get untyped errors | Declare `responses` parameter on each route |
| CORS middleware too permissive | Security vulnerability | Restrict `allow_origins` to known domains |

## Core Patterns

### 1. Project Structure

```
app/
├── main.py              # FastAPI app factory
├── core/
│   ├── config.py        # Settings with pydantic-settings
│   ├── security.py      # Auth helpers
│   └── database.py      # Engine, session factory
├── api/
│   ├── deps.py          # Shared dependencies
│   └── v1/
│       ├── router.py    # Aggregated router
│       └── users.py     # User endpoints
├── models/              # SQLAlchemy / ORM models
├── schemas/             # Pydantic request/response schemas
├── services/            # Business logic
├── tests/
│   ├── conftest.py      # Fixtures
│   └── test_users.py
└── alembic/             # Migrations
```

### 2. App Factory and Configuration

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.router import api_router

def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        docs_url="/api/docs",
        redoc_url="/api/redoc",
    )

    # CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(api_router, prefix="/api/v1")
    return app
```

```python
# core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "My API"
    VERSION: str = "1.0.0"
    DATABASE_URL: str = "postgresql+asyncpg://user:pass@localhost/db"
    SECRET_KEY: str = "change-me-in-production"
    ALLOWED_ORIGINS: list[str] = ["http://localhost:3000"]

    model_config = {"env_file": ".env", "extra": "ignore"}

settings = Settings()
```

### 3. Pydantic Schemas and Validation

```python
from datetime import datetime
from pydantic import BaseModel, Field, field_validator, ConfigDict

# Request schema
class ItemCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    price: float = Field(..., gt=0)
    description: str | None = None
    tags: list[str] = Field(default_factory=list)

    @field_validator("tags")
    @classmethod
    def normalize_tags(cls, v: list[str]) -> list[str]:
        return [t.strip().lower() for t in v]

# Response schema
class ItemResponse(BaseModel):
    id: int
    name: str
    price: float
    description: str | None
    tags: list[str]
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# Paginated list response
class ItemList(BaseModel):
    items: list[ItemResponse]
    total: int
    page: int
    page_size: int
```

### 4. Dependency Injection

```python
from typing import Annotated
from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

# Database session dependency
async def get_db() -> AsyncSession:
    async with async_session() as session:
        yield session

DbSession = Annotated[AsyncSession, Depends(get_db)]

# Current user dependency (JWT)
async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: DbSession,
) -> User:
    payload = decode_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")
    user = await UserRepo(db).find_by_id(payload["sub"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

CurrentUser = Annotated[User, Depends(get_current_user)]

# Usage in route
@app.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int, db: DbSession, user: CurrentUser):
    ...
```

### 5. Route Handlers with Service Layer

```python
from fastapi import APIRouter, status

router = APIRouter(prefix="/items", tags=["items"])

@router.post("/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(
    data: ItemCreate,
    db: DbSession,
    user: CurrentUser,
):
    service = ItemService(db)
    return await service.create(data, owner_id=user.id)

@router.get("/", response_model=ItemList)
async def list_items(
    page: int = 1,
    page_size: int = 20,
    db: DbSession = Depends(get_db),
):
    service = ItemService(db)
    return await service.list(page=page, page_size=page_size)
```

### 6. Middleware and Error Handling

```python
import time
from fastapi import Request, Response
from fastapi.responses import JSONResponse

@app.middleware("http")
async def request_logging(request: Request, call_next):
    start = time.perf_counter()
    response: Response = await call_next(request)
    elapsed = time.perf_counter() - start
    response.headers["X-Response-Time"] = f"{elapsed:.3f}s"
    return response

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    return JSONResponse(
        status_code=exc.status,
        content={"code": exc.code, "message": exc.message},
    )
```

### 7. Testing with TestClient

```python
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import create_app

@pytest.fixture
async def client():
    transport = ASGITransport(app=create_app())
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c

@pytest.mark.asyncio
async def test_create_item(client: AsyncClient):
    response = await client.post("/api/v1/items/", json={
        "name": "Widget", "price": 9.99,
    })
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Widget"
```

### 8. Deployment

```bash
# Production with Uvicorn workers
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

# With Gunicorn for process management
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000

# Docker
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Coaching Notes

> **ABC - Always Be Coaching:** FastAPI's power comes from its type system. Every endpoint you write teaches the API consumer exactly what to expect through automatic documentation.

1. **Pydantic is your contract layer:** Define schemas for every request and response. This gives you validation, serialization, and OpenAPI docs for free. Never accept raw dicts.

2. **Dependency injection replaces global state:** Use `Depends()` for database sessions, auth, config, and service instantiation. This makes testing trivial -- just override the dependency.

3. **Separate routes from business logic:** Routes handle HTTP concerns (status codes, headers, serialization). Service classes handle business logic. This separation makes both testable in isolation.

4. **Use `Annotated` types for repeated dependencies:** Define `DbSession = Annotated[AsyncSession, Depends(get_db)]` once, reuse everywhere. Reduces boilerplate and centralizes DI configuration.

5. **Test with `httpx.AsyncClient`, not `TestClient`:** The sync `TestClient` hides async issues. Use `httpx.AsyncClient` with `ASGITransport` for accurate async testing.

## Verification

After implementing FastAPI patterns:

- [ ] All endpoints have typed Pydantic request/response models
- [ ] Dependency injection is used for DB sessions, auth, and services
- [ ] Business logic lives in service classes, not route handlers
- [ ] CORS middleware restricts origins to known domains
- [ ] Error responses use custom exception handlers with structured JSON
- [ ] OpenAPI docs are accessible at `/docs` and `/redoc`
- [ ] Tests use `httpx.AsyncClient` with overridden dependencies
- [ ] Production runs with multiple Uvicorn workers behind Gunicorn
- [ ] Environment variables loaded via `pydantic-settings`, not hardcoded

## Related Skills

- **python-patterns** -- Core Python patterns (type hints, async, data models, testing)
- **api-interface-design** -- Contract-first API design methodology
- **backend-patterns** -- General backend patterns (auth, caching, error handling)
- **test-driven-development** -- TDD red-green-refactor cycle
- **security-hardening** -- OWASP Top 10 and API security patterns

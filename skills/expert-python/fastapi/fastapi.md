---
name: fastapi
description: >
  FastAPI framework patterns for high-performance Python APIs. Covers async handlers, Pydantic models,
  dependency injection, middleware, authentication, database integration, testing, and deployment.
  Use when building REST APIs, async services, or microservices with FastAPI.
version: "3.0.0"
category: "expert-python"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["fastapi", "python api", "async api", "pydantic model", "uvicorn", "openapi docs", "dependency injection fastapi"]
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

# FastAPI Patterns

[ROLE]
Act as a FastAPI expert. Deliver production-grade FastAPI services with Pydantic validation, dependency injection, async database access, and structured error handling.

[OBJECTIVE]
Build FastAPI APIs where every endpoint has typed Pydantic models, business logic lives in service classes, dependencies are injected via `Depends()`, and tests use `httpx.AsyncClient`.

[RULES]
1. <thought>Before writing any endpoint, determine: What are the request/response Pydantic models? What dependencies does it need (DB session, auth, services)? Is this sync or async?</thought>
2. Define Pydantic schemas for every request and response — never accept raw dicts.
3. Use `Depends()` for database sessions, auth, config, and service instantiation.
4. Separate routes from business logic — routes handle HTTP, services handle logic.
5. Use `Annotated` types for repeated dependencies — define once, reuse everywhere.
6. DO NOT place business logic directly in route handlers.
7. DO NOT use synchronous database drivers with async endpoints.
8. DO NOT skip Pydantic models — they give validation, serialization, and OpenAPI docs for free.
9. Restrict CORS `allow_origins` to known domains — not `*` in production.
10. Test with `httpx.AsyncClient`, not sync `TestClient`.
11. Load environment variables via `pydantic-settings`, not hardcoded.
12. ABC: Pydantic is your contract layer — define schemas for every request and response. This gives you validation, serialization, and OpenAPI docs for free.

[PROCESS]

### Project Structure

```
app/
├── main.py              # App factory
├── core/config.py       # pydantic-settings
├── core/security.py     # Auth helpers
├── core/database.py     # Engine, session factory
├── api/deps.py          # Shared dependencies
├── api/v1/users.py      # User endpoints
├── schemas/             # Pydantic models
├── services/            # Business logic
├── models/              # ORM models
└── tests/
```

### Pydantic Schemas

```python
class ItemCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    price: float = Field(..., gt=0)
    tags: list[str] = Field(default_factory=list)

class ItemResponse(BaseModel):
    id: int; name: str; price: float; created_at: datetime
    model_config = ConfigDict(from_attributes=True)
```

### Dependency Injection

```python
async def get_db() -> AsyncSession:
    async with async_session() as session:
        yield session

DbSession = Annotated[AsyncSession, Depends(get_db)]
CurrentUser = Annotated[User, Depends(get_current_user)]

@app.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int, db: DbSession, user: CurrentUser): ...
```

### Route Handlers with Service Layer

```python
@router.post("/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(data: ItemCreate, db: DbSession, user: CurrentUser):
    service = ItemService(db)
    return await service.create(data, owner_id=user.id)
```

### Testing

```python
@pytest.fixture
async def client():
    transport = ASGITransport(app=create_app())
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c

@pytest.mark.asyncio
async def test_create_item(client: AsyncClient):
    response = await client.post("/api/v1/items/", json={"name": "Widget", "price": 9.99})
    assert response.status_code == 201
```

### Deployment

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### Verification

- [ ] All endpoints have typed Pydantic request/response models
- [ ] Dependency injection used for DB sessions, auth, and services
- [ ] Business logic lives in service classes, not route handlers
- [ ] CORS middleware restricts origins to known domains
- [ ] Tests use `httpx.AsyncClient` with overridden dependencies
- [ ] Environment variables loaded via `pydantic-settings`

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code, `patterns_applied`, and `recommendations`.

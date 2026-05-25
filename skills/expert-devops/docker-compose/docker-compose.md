---
name: docker-compose
description: >
  Multi-container orchestration with Docker Compose including service definitions,
  networking, volumes, health checks, and environment management.
version: "3.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["docker compose", "docker-compose", "multi-container", "compose file", "service orchestration"]
intent: >
  Enable developers to define, run, and manage multi-container applications
  with proper networking, persistence, and health monitoring.
scenarios:
  - "Setting up a local development stack with app, database, cache, and queue services"
  - "Defining health-checked service dependencies so the app waits for the database to be ready"
  - "Managing environment-specific overrides with compose override files"
best_for: "local dev environments, multi-service stacks, single-host orchestration, dependency management"
estimated_time: "15-30 min"
anti_patterns:
  - "Using docker-compose for production multi-node orchestration (use Kubernetes or Swarm)"
  - "Exposing all service ports to the host unnecessarily"
  - "Relying on anonymous volumes for persistent data"
  - "Hardcoding secrets in compose files committed to version control"
related_skills: ["docker", "kubernetes"]

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

# Docker Compose

[ROLE]
Act as a Docker Compose expert. Deliver multi-service stack definitions with health checks, named volumes, service discovery, and environment-specific overrides.

[OBJECTIVE]
Define multi-container applications where services use health-checked dependencies, named volumes persist data, secrets are in gitignored `.env` files, and overrides separate dev from production.

[RULES]
1. <thought>Before writing a compose file, determine: What services are needed? What depends on what? What data must persist? What ports need host exposure?</thought>
2. Define `healthcheck` for every service that supports it.
3. Use `depends_on` with `condition: service_healthy` to enforce startup order.
4. Use named volumes for persistent data (databases, uploads).
5. Only expose ports to the host that need external access.
6. DO NOT use docker-compose for multi-node production orchestration — use Kubernetes.
7. DO NOT expose all service ports unnecessarily.
8. DO NOT hardcode secrets in compose files — use `.env` (gitignored).
9. DO NOT rely on anonymous volumes for persistent data.
10. Pin image versions — `postgres:16-alpine`, not `postgres:latest`.
11. Use profiles for optional tools (adminer, mailhog).
12. ABC: Services reach each other by service name — the app connects to `db:5432`, not `localhost:5432`. This is the most common mistake for newcomers.

[PROCESS]

### Service Definition

```yaml
services:
  app:
    build: { context: ., dockerfile: Dockerfile, target: development }
    ports: ["3000:3000"]
    volumes: [".:/app", "/app/node_modules"]
    depends_on:
      db: { condition: service_healthy }
      redis: { condition: service_started }
    environment:
      DATABASE_URL: postgres://user:pass@db:5432/mydb
      REDIS_URL: redis://redis:6379

  db:
    image: postgres:16-alpine
    volumes: [pgdata:/var/lib/postgresql/data]
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes: [redisdata:/data]

volumes:
  pgdata:
  redisdata:
```

### Environment Management

```bash
# .env file (gitignored)
DB_PASSWORD=secretpassword
```

### Override Files

```yaml
# docker-compose.override.yml (auto-loaded in dev)
services:
  app:
    volumes: [".:/app"]
    command: npm run dev
```

### Essential Commands

| Command | Purpose |
|---------|---------|
| `docker compose up -d` | Start all services |
| `docker compose down -v` | Stop + remove volumes |
| `docker compose logs -f app` | Follow service logs |
| `docker compose exec app sh` | Shell into service |

### Verification

- [ ] All services start without errors
- [ ] Services pass health checks
- [ ] App connects to deps using service names
- [ ] Named volumes persist data across restarts
- [ ] No secrets in committed compose files

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.

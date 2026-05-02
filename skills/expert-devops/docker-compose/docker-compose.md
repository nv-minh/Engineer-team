---
name: docker-compose
description: >
  Multi-container orchestration with Docker Compose including service definitions,
  networking, volumes, health checks, and environment management.
  Use when defining multi-service stacks, local development environments, or single-host deployments.
version: "1.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "docker compose"
  - "docker-compose"
  - "multi-container"
  - "compose file"
  - "service orchestration"
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
---

# Docker Compose

## Overview

Docker Compose defines and runs multi-container applications from a single YAML file. It handles service dependencies, networking, volume persistence, and environment configuration. Ideal for local development environments and single-host deployments where multiple services must communicate.

## When to Use

- Defining local development stacks (app + database + cache + queue)
- Running integration tests that require multiple services
- Setting up single-host production or staging environments
- Prototyping microservice architectures before moving to Kubernetes

## When NOT to Use

- Multi-node production orchestration (use Kubernetes, Docker Swarm, or Nomad)
- Managing infrastructure across cloud providers (use Terraform)
- Configuration management on existing servers (use Ansible)

## Process

### 1. Define Services

```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: development
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    environment:
      DATABASE_URL: postgres://user:pass@db:5432/mydb
      REDIS_URL: redis://redis:6379
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: mydb
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s
      timeout: 5s
      retries: 5
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redisdata:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s

volumes:
  pgdata:
  redisdata:
```

### 2. Environment Management

```bash
# .env file (gitignored)
DB_PASSWORD=secretpassword
APP_ENV=development
```

```yaml
# Use env_file to inject variables
services:
  app:
    env_file:
      - .env
    environment:
      # Override or add specific vars
      NODE_ENV: development
```

### 3. Override Files

```yaml
# docker-compose.override.yml (auto-loaded in development)
services:
  app:
    volumes:
      - .:/app
    command: npm run dev

  # Optional debug tools
  adminer:
    image: adminer
    ports:
      - "8080:8080"
    profiles:
      - debug
```

```yaml
# docker-compose.prod.yml (explicit: docker compose -f docker-compose.yml -f docker-compose.prod.yml)
services:
  app:
    build:
      target: production
    restart: always
    volumes: !override []
```

### 4. Essential CLI Commands

| Command | Purpose |
|---------|---------|
| `docker compose up -d` | Start all services detached |
| `docker compose down -v` | Stop and remove containers + volumes |
| `docker compose logs -f app` | Follow logs for a service |
| `docker compose ps` | List running services |
| `docker compose exec app sh` | Shell into a running service |
| `docker compose build --no-cache` | Rebuild images from scratch |
| `docker compose up -d --build` | Rebuild and restart |
| `docker compose --profile debug up -d` | Start with profile services |

## Best Practices

### Networking
- Docker Compose creates a default network; services communicate using service names as hostnames
- Only expose ports to the host that need external access (e.g., the app, not the database)
- Use custom networks to isolate service groups when needed

### Volumes
- Always use named volumes for persistent data (databases, file uploads)
- Use bind mounts (`./local:/container`) for development hot-reload
- Never rely on anonymous volumes for data you need to keep

### Health Checks and Dependencies
- Define `healthcheck` for every service that supports it
- Use `depends_on` with `condition: service_healthy` to enforce startup order
- Without health checks, `depends_on` only waits for container start, not readiness

### Security
- Never commit secrets to compose files; use `.env` files (gitignored) or Docker secrets
- Use `profiles` for optional tools (adminer, mailhog) to keep production lean
- Pin image versions: `postgres:16-alpine`, not `postgres:latest`

## Coaching Notes

- **Service discovery**: Services reach each other by service name. The app connects to `db:5432`, not `localhost:5432`. This is the most common mistake for newcomers.
- **Override strategy**: Put development defaults in `docker-compose.yml`, overrides in `docker-compose.override.yml` (auto-loaded), and production overrides in `docker-compose.prod.yml` (explicit).
- **Volume performance on macOS**: Use `:cached` or `:delegated` flags on bind mounts for better filesystem performance (e.g., `./:/app:cached`).

## Verification

- [ ] All services start without errors: `docker compose up -d`
- [ ] Services pass health checks: `docker compose ps` shows "healthy"
- [ ] App connects to dependencies using service names (not localhost)
- [ ] Named volumes persist data across `docker compose down`
- [ ] No secrets in committed compose files
- [ ] `.env` file is gitignored
- [ ] Production compose file removes bind mounts and dev tools

## Related Skills

- **docker** - Individual container and image management
- **kubernetes** - Production multi-node container orchestration

---
name: docker
description: >
  Docker container creation, image building, Dockerfile authoring, and container management.
  Use when building Docker images, writing Dockerfiles, managing containers, or troubleshooting container issues.
version: "3.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["docker", "dockerfile", "container", "docker build", "docker run", "multi-stage build", "docker image"]
intent: >
  Provide production-grade Docker patterns for creating efficient, secure container images
  and managing containerized applications with confidence.
scenarios:
  - "Writing a multi-stage Dockerfile to minimize final image size for a Node.js or Python application"
  - "Debugging a container that crashes on startup due to permission or networking issues"
  - "Setting up health checks, restart policies, and resource limits for production containers"
best_for: "Dockerfile creation, image optimization, container lifecycle management, multi-stage builds"
estimated_time: "15-30 min"
anti_patterns:
  - "Running containers as root in production"
  - "Using :latest tag in production deployments"
  - "Installing unnecessary packages in the final image"
  - "Storing secrets in environment variables baked into the image"
related_skills: ["docker-compose", "kubernetes", "github-actions", "security-hardening"]

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

# Docker

[ROLE]
Act as a Docker expert. Deliver multi-stage Dockerfiles that produce small, secure images with non-root users, health checks, and layer caching optimization.

[OBJECTIVE]
Produce Docker images that are minimal (alpine/distroless), secure (non-root), observable (HEALTHCHECK), and build-efficient (layer caching).

[RULES]
1. <thought>Before writing a Dockerfile, determine: What build tools are needed? What can be excluded from the final image? What user should the process run as?</thought>
2. Use multi-stage builds to separate build dependencies from runtime.
3. Run as non-root user — create and use a dedicated app user.
4. Define HEALTHCHECK for all production containers.
5. Use `.dockerignore` to exclude `.git`, `node_modules`, build artifacts.
6. Order instructions from least to most frequently changing — leverage layer caching.
7. DO NOT run containers as root in production.
8. DO NOT use `:latest` tag in production deployments — pin versions.
9. DO NOT store secrets in images — use runtime env vars, Docker secrets, or vault.
10. DO NOT install unnecessary packages in the final image.
11. Set resource limits (`--memory`, `--cpus`) and restart policies.
12. ABC: Multi-stage builds can reduce image size by 70-90% — the builder stage has compilers and dev deps, the final stage only gets compiled output.

[PROCESS]

### Multi-Stage Dockerfile

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production=false
COPY . .
RUN npm run build

FROM node:20-alpine AS runtime
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "dist/server.js"]
```

### Build and Run

```bash
docker build -t myapp:1.0.0 -t myapp:latest .
docker run -d --name myapp -p 3000:3000 --restart unless-stopped --memory=512m --cpus=1.0 myapp:1.0.0
```

### Essential Commands

| Command | Purpose |
|---------|---------|
| `docker ps -a` | List all containers |
| `docker logs -f <c>` | Follow container logs |
| `docker exec -it <c> sh` | Shell into container |
| `docker system prune` | Remove unused data |
| `docker history <img>` | Inspect image layers |

### Verification

- [ ] Dockerfile uses multi-stage build
- [ ] Final image runs as non-root user
- [ ] `.dockerignore` file exists and excludes unnecessary files
- [ ] `HEALTHCHECK` instruction is defined
- [ ] No secrets in image: `docker history` shows no sensitive values

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.

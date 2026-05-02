---
name: docker
description: >
  Docker container creation, image building, Dockerfile authoring, and container management.
  Use when building Docker images, writing Dockerfiles, managing containers, or troubleshooting container issues.
version: "1.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "docker"
  - "dockerfile"
  - "container"
  - "docker build"
  - "docker run"
  - "multi-stage build"
  - "docker image"
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
---

# Docker

## Overview

Docker packages applications into portable, reproducible containers. A well-crafted Dockerfile produces small, secure images that build fast and run reliably across environments. This skill covers Dockerfile authoring, image optimization, container management, and production best practices.

## When to Use

- Writing or optimizing Dockerfiles for any application
- Building and tagging images for development or production
- Running, inspecting, and debugging containers
- Setting up CI/CD pipelines that build Docker images
- Troubleshooting container networking, storage, or permission issues

## When NOT to Use

- Orchestrating multiple interdependent services (use docker-compose or Kubernetes)
- Managing infrastructure as code (use Terraform or Ansible)
- Running stateful databases in single containers without persistent volumes in production

## Process

### 1. Write the Dockerfile

Use multi-stage builds to separate build dependencies from runtime:

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production=false
COPY . .
RUN npm run build

# Stage 2: Production
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

Key directives:

| Directive | Purpose |
|-----------|---------|
| `FROM ... AS` | Named stage for multi-stage builds |
| `COPY --from=` | Copy artifacts from a previous stage |
| `USER` | Run as non-root user |
| `HEALTHCHECK` | Container health monitoring |
| `EXPOSE` | Document the port (does not publish) |
| `ARG` | Build-time variables |
| `ENV` | Runtime environment variables |

### 2. Build and Tag

```bash
# Build with tag
docker build -t myapp:1.0.0 -t myapp:latest .

# Build with build args
docker build --build-arg NODE_ENV=production -t myapp:1.0.0 .

# Inspect image layers
docker history myapp:1.0.0
```

### 3. Run and Manage Containers

```bash
# Run detached with port mapping and volume
docker run -d \
  --name myapp \
  -p 3000:3000 \
  -v $(pwd)/data:/app/data \
  --restart unless-stopped \
  --memory=512m --cpus=1.0 \
  myapp:1.0.0

# View logs
docker logs -f myapp

# Execute command inside running container
docker exec -it myapp sh

# Inspect container details
docker inspect myapp
```

### 4. Essential CLI Commands

| Command | Purpose |
|---------|---------|
| `docker ps -a` | List all containers |
| `docker images` | List local images |
| `docker system prune` | Remove unused data |
| `docker logs <container>` | View container logs |
| `docker exec -it <c> sh` | Shell into container |
| `docker build -t tag .` | Build image from Dockerfile |
| `docker rmi <image>` | Remove an image |

## Best Practices

### Image Optimization
- Use `alpine` or `distroless` base images to minimize attack surface and size
- Order Dockerfile instructions from least to most frequently changing (leverage layer caching)
- Combine `RUN` commands with `&&` to reduce layers
- Add `.dockerignore` to exclude `node_modules`, `.git`, logs, and build artifacts

### Security
- Never run as root: create and use a non-root user
- Never store secrets in images: use runtime env vars, Docker secrets, or vault integration
- Pin base image digests: `FROM node:20-alpine@sha256:abc...`
- Scan images for vulnerabilities: `docker scout cves myapp:1.0.0`

### Reliability
- Always define `HEALTHCHECK` for production containers
- Set restart policies: `--restart unless-stopped` or `--restart on-failure`
- Use named volumes for persistent data, never rely on anonymous volumes
- Set resource limits (`--memory`, `--cpus`) to prevent runaway containers

## Coaching Notes

- **Layer caching**: Docker caches each instruction's result. Put `COPY package.json` before `COPY .` so dependency installation is cached when only source code changes.
- **Multi-stage builds**: The builder stage can have compilers, dev dependencies, and build tools. The final stage only gets the compiled output and runtime deps. This can reduce image size by 70-90%.
- **`.dockerignore` is critical**: Without it, `COPY . .` sends the entire project tree (including `.git`, `node_modules`, build artifacts) to the daemon, slowing builds and bloating context.

## Verification

- [ ] Dockerfile uses multi-stage build
- [ ] Final image runs as non-root user
- [ ] `.dockerignore` file exists and excludes unnecessary files
- [ ] `HEALTHCHECK` instruction is defined
- [ ] Image builds without warnings: `docker build .`
- [ ] Container starts and passes health check: `docker ps` shows "healthy"
- [ ] No secrets in image: `docker history myapp:1.0.0` shows no sensitive values

## Related Skills

- **docker-compose** - Multi-container orchestration
- **kubernetes** - Container orchestration at scale
- **github-actions** - CI/CD pipelines with Docker builds
- **security-hardening** - Security best practices for containers

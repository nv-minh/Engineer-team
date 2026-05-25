---
name: github-actions
description: >
  GitHub Actions CI/CD including workflows, matrix strategies, reusable workflows,
  secrets management, caching, and pipeline optimization.
version: "3.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["github actions", "workflow", "ci cd", "github actions workflow", "pipeline", "reusable workflow"]
intent: >
  Enable teams to create reliable, efficient CI/CD pipelines with GitHub Actions
  using matrix strategies, caching, reusable workflows, and security best practices.
scenarios:
  - "Creating a CI pipeline that tests across multiple Node.js versions with caching"
  - "Building a reusable deployment workflow called from multiple repositories"
  - "Optimizing slow workflows with caching, concurrency controls, and conditional steps"
best_for: "CI/CD pipelines, matrix testing, reusable workflows, GitHub automation, deployment"
estimated_time: "20-40 min"
anti_patterns:
  - "Echoing secrets in workflow logs"
  - "Using latest tag for actions instead of pinning to SHA or major version"
  - "Running all jobs in parallel without dependency ordering"
  - "Not using caching, causing every run to reinstall dependencies"
related_skills: ["docker", "terraform", "ci-cd-automation"]

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

# GitHub Actions

[ROLE]
Act as a GitHub Actions expert. Deliver CI/CD workflows with matrix testing, dependency caching, concurrency controls, and reusable workflow patterns.

[OBJECTIVE]
Create GitHub Actions workflows where CI runs with matrix strategies and caching, deployments use environment protection, and common patterns are extracted into reusable workflows.

[RULES]
1. <thought>Before writing a workflow, determine: What events trigger it? What matrix dimensions are needed? What can be cached? What environments need protection rules?</thought>
2. Pin actions to SHA or major version — `actions/checkout@v4` or SHA.
3. Cache dependencies — use `cache: npm` in setup-node or `actions/cache`.
4. Use `concurrency` with `cancel-in-progress: true` to cancel stale runs.
5. Set minimal `permissions` at workflow and job level.
6. DO NOT echo secrets in workflow logs.
7. DO NOT use latest tag for actions — pin versions.
8. DO NOT run all jobs in parallel without proper `needs` ordering.
9. DO NOT skip caching — it saves significant runner time.
10. Use `fail-fast: false` in matrix strategies to see all failures.
11. Add `timeout-minutes` to long-running jobs.
12. ABC: Concurrency groups with `cancel-in-progress: true` ensure only the latest commit on a branch runs CI — saving runner minutes and avoiding stale results.

[PROCESS]

### CI Workflow

```yaml
name: CI Pipeline
on:
  push: { branches: [main] }
  pull_request: { branches: [main] }
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
jobs:
  test:
    runs-on: ubuntu-latest
    strategy: { fail-fast: false, matrix: { node-version: [18, 20, 22] } }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: "${{ matrix.node-version }}", cache: npm }
      - run: npm ci
      - run: npm run lint
      - run: npm test -- --coverage
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci && npm run build
```

### Reusable Workflows

```yaml
on:
  workflow_call:
    inputs:
      node-version: { type: string, default: "20" }
      run-integration-tests: { type: boolean, default: false }
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: "${{ inputs.node-version }}", cache: npm }
      - run: npm ci && npm run build
      - if: inputs.run-integration-tests
        run: npm run test:integration
```

### Environment Protection

```yaml
jobs:
  deploy-prod:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production  # Requires approval + protection rules
    steps:
      - env: { API_KEY: "${{ secrets.PROD_API_KEY }}" }
        run: ./deploy.sh
```

### Verification

- [ ] Actions pinned to SHA or major version
- [ ] Secrets referenced via `${{ secrets.NAME }}`, never hardcoded
- [ ] Caching configured for dependency installation
- [ ] Concurrency groups prevent duplicate runs
- [ ] `permissions` block uses minimal required scopes

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.

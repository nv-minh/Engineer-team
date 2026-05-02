---
name: github-actions
description: >
  GitHub Actions CI/CD including workflows, matrix strategies, reusable workflows,
  secrets management, caching, and pipeline optimization.
  Use when creating CI/CD pipelines, automating builds and deployments, or optimizing workflow performance.
version: "1.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "github actions"
  - "workflow"
  - "ci cd"
  - "github actions workflow"
  - "pipeline"
  - "reusable workflow"
intent: >
  Enable teams to create reliable, efficient CI/CD pipelines with GitHub Actions
  using matrix strategies, caching, reusable workflows, and security best practices.
scenarios:
  - "Creating a CI pipeline that tests across multiple Node.js versions with caching"
  - "Building a reusable deployment workflow called from multiple repository workflows"
  - "Optimizing slow workflows by adding caching, concurrency controls, and conditional steps"
best_for: "CI/CD pipelines, matrix testing, reusable workflows, GitHub automation, deployment"
estimated_time: "20-40 min"
anti_patterns:
  - "Echoing secrets in workflow logs (they get masked but log truncation can leak them)"
  - "Using latest tag for actions instead of pinning to SHA or major version"
  - "Running all jobs in parallel without dependency ordering (needs, if conditions)"
  - "Not using caching, causing every run to reinstall dependencies from scratch"
related_skills: ["docker", "terraform", "ci-cd-automation"]
---

# GitHub Actions

## Overview

GitHub Actions automates software workflows directly in GitHub repositories. Workflows are defined in YAML, triggered by repository events, and run on managed or self-hosted runners. This skill covers workflow creation, matrix strategies, reusable workflows, secrets, caching, and performance optimization.

## When to Use

- Creating CI pipelines (test, lint, build on push/PR)
- Setting up CD pipelines (deploy to staging/production on merge)
- Automating repository tasks (label issues, auto-assign reviewers, generate releases)
- Building shared workflow templates across multiple repositories

## When NOT to Use

- Complex multi-service orchestration (use dedicated CI/CD platforms like Jenkins or GitLab CI)
- Infrastructure provisioning lifecycle (use Terraform Cloud or Atlantis)
- Scheduled batch processing (use a proper job queue or cron service)

## Process

### 1. Create a CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        node-version: [18, 20, 22]

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: npm

      - run: npm ci
      - run: npm run lint
      - run: npm test -- --coverage

      - name: Upload coverage
        if: matrix.node-version == 20
        uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run build

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
```

### 2. Create a Deployment Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    needs: [build]  # From ci.yml or include build steps here
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production

    steps:
      - uses: actions/checkout@v4

      - name: Deploy to production
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
          DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
        run: ./scripts/deploy.sh
```

### 3. Create Reusable Workflows

```yaml
# .github/workflows/reusable-build.yml
on:
  workflow_call:
    inputs:
      node-version:
        description: "Node.js version"
        type: string
        default: "20"
      run-integration-tests:
        description: "Run integration tests"
        type: boolean
        default: false
    outputs:
      artifact-name:
        description: "Build artifact name"
        value: ${{ jobs.build.outputs.artifact }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      artifact: ${{ steps.build-output.outputs.name }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: npm
      - run: npm ci
      - run: npm run build

      - name: Set output
        id: build-output
        run: echo "name=dist-${{ inputs.node-version }}" >> "$GITHUB_OUTPUT"

      - if: inputs.run-integration-tests
        run: npm run test:integration
```

```yaml
# Call reusable workflow from another repo
jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
    with:
      node-version: "22"
      run-integration-tests: true
    secrets: inherit
```

### 4. Environment and Secrets

```yaml
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging  # Requires approval if configured
    steps:
      - env:
          API_KEY: ${{ secrets.STAGING_API_KEY }}
        run: ./deploy.sh

  deploy-prod:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production  # Requires approval + protection rules
    steps:
      - env:
          API_KEY: ${{ secrets.PROD_API_KEY }}
        run: ./deploy.sh
```

## Best Practices

### Security
- Store tokens and keys in GitHub Secrets, never in workflow files
- Pin actions to a SHA or major version: `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683` or `@v4`
- Use `secrets: inherit` when calling reusable workflows to avoid passing secrets explicitly
- Set minimal `permissions` at workflow and job level:

```yaml
permissions:
  contents: read
  pull-requests: write
```

### Performance
- Cache dependencies: use `cache: npm` in `setup-node`, or `actions/cache` for other ecosystems
- Use `concurrency` to cancel outdated runs on the same branch
- Only run jobs that need to run: use `if` conditions and path filters
- Use `actions/upload-artifact` to pass build outputs between jobs

### Reliability
- Use `fail-fast: false` in matrix strategies to see all failures
- Add `timeout-minutes` to long-running jobs to prevent hangs
- Use `outputs` to pass data between jobs instead of re-computing
- Test workflow changes in a branch before merging to main

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Workflow not triggered | Verify `on` event matches branch and event type; check if workflow is on default branch |
| Permission denied | Add `permissions` block; check repo settings for GITHUB_TOKEN scope |
| Cache miss | Ensure cache key includes lockfile hash: `${{ hashFiles('**/package-lock.json') }}` |
| Matrix failures | Check logs per combination; use `continue-on-error` selectively |
| Secret not available | Verify secret name; check environment protection rules |

## Coaching Notes

- **Concurrency saves resources**: The `concurrency` group with `cancel-in-progress: true` ensures only the latest commit on a branch runs CI. This saves runner minutes and avoids confusing results from stale runs.
- **Reusable workflows reduce duplication**: If you have the same build+test+deploy pattern across 5 repos, extract it into a reusable workflow in a shared repo. Changes propagate everywhere.
- **Environments are more than names**: GitHub Environments enable protection rules (required reviewers, wait timers, deployment branches). Use them to gate production deployments.

## Verification

- [ ] Workflow files exist in `.github/workflows/`
- [ ] `on` triggers match the intended events and branches
- [ ] Actions are pinned to SHA or major version tag
- [ ] Secrets are referenced via `${{ secrets.NAME }}`, never hardcoded
- [ ] Caching is configured for dependency installation
- [ ] Concurrency groups prevent duplicate runs
- [ ] `permissions` block uses minimal required scopes
- [ ] Matrix strategy covers all target versions

## Related Skills

- **docker** - Building and pushing container images in CI
- **terraform** - Infrastructure provisioning from GitHub Actions
- **ci-cd-automation** - CI/CD patterns and quality gates

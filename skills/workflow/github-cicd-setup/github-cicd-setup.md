---
name: github-cicd-setup
description: "Analyzes the current codebase to detect language, framework, test runner, and linter, then generates a tailored `.github/workflows/ci.yml` with appropriate jobs (lint, type-check, test, build). Use when starting a new project or adding CI/CD to an existing repo."
version: "1.0.0"
category: "workflow"
origin: "EM-Team (GitHub Management)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "setup ci"
  - "setup cicd"
  - "setup ci/cd"
  - "create github actions"
  - "generate workflow"
  - "add ci pipeline"
  - "github actions setup"
  - "setup lint pipeline"
  - "setup test pipeline"
intent: "Detect the project's technology stack and produce a ready-to-commit `.github/workflows/ci.yml` that enforces lint, type-check, test, and build quality gates on every PR."
scenarios:
  - "New project needs CI/CD from scratch"
  - "Existing repo with no GitHub Actions workflows"
  - "Adding type-check or coverage gate to an existing CI pipeline"
  - "Migrating from CircleCI/Travis to GitHub Actions"
best_for: "Node/TypeScript, Python, Go, Java, Rust projects on GitHub"
estimated_time: "10-15 minutes"
anti_patterns:
  - "Generating a generic template without detecting the actual stack — different test runners need different commands"
  - "Skipping caching — uncached CI is 3-5x slower and wastes minutes on every PR"
  - "Running all jobs sequentially when lint/typecheck/test are independent (use parallel jobs)"
  - "Not pinning action versions — unpinned actions can break silently when upstream changes"
related_skills:
  - ci-cd-automation
  - git-workflow
  - github-pr-manager
---

# GitHub CI/CD Setup

## Overview

This skill automates the creation of GitHub Actions CI workflows tailored to the actual technology stack detected in the repository. Instead of copy-pasting a generic template, it inspects `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, etc. to understand what tools are available and generates the right commands.

## When to Use

- Starting a new project that needs CI from day one
- Adding automated quality gates (lint, type check, test, build) to an existing repo
- Replacing or upgrading an existing workflow file
- Ensuring PRs are blocked on failing checks before merge

**When NOT to Use:** Projects with existing, well-maintained CI pipelines that already enforce the quality gates you need.

## Anti-Patterns

- Generic one-size-fits-all templates: a Jest project and a pytest project need different commands
- No dependency caching: always cache `node_modules`, pip packages, cargo registry
- Sequential jobs for independent checks: lint, typecheck, test should all run in parallel
- Unpinned action versions: use `actions/checkout@v4` not `actions/checkout@latest`

## Process

### Step 1 — Detect Stack

Inspect the repository root for technology indicators:

```
Detection targets:
├── package.json          → Node.js / TypeScript
│   ├── scripts.lint      → ESLint / Biome / Prettier check
│   ├── scripts.test      → Jest / Vitest / Mocha
│   ├── scripts.typecheck → tsc --noEmit
│   └── scripts.build     → Next.js / Vite / tsc
├── pyproject.toml / requirements.txt → Python
│   ├── [tool.pytest]     → pytest
│   ├── ruff / flake8     → linter
│   └── mypy / pyright    → type checker
├── go.mod                → Go
│   └── commands: golangci-lint, go test ./...
├── Cargo.toml            → Rust
│   └── commands: cargo clippy, cargo test
├── pom.xml / build.gradle → Java/Kotlin
│   └── commands: mvn test / gradle test
└── .nvmrc / .tool-versions → Node version pinning
```

### Step 2 — Confirm Jobs with User

Present detected configuration and ask which jobs to include:

```
Detected: Node.js 20 + TypeScript + Jest + ESLint

Proposed CI jobs:
  ✓ lint        (eslint + prettier check)
  ✓ typecheck   (tsc --noEmit)
  ✓ test        (jest --coverage)
  ✓ build       (next build / tsc)
  ? deploy-preview  (add Vercel/Netlify preview?)

Coverage threshold? (leave blank to skip, e.g. 80)
```

### Step 3 — Generate Workflow File

Create `.github/workflows/ci.yml`:

#### Node / TypeScript template

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: .nvmrc
          cache: npm
      - run: npm ci
      - run: npm run lint

  typecheck:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: .nvmrc
          cache: npm
      - run: npm ci
      - run: npm run typecheck

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: .nvmrc
          cache: npm
      - run: npm ci
      - run: npm test -- --coverage
      - name: Check coverage threshold
        run: npx jest --coverage --coverageThreshold='{"global":{"lines":80}}'
        if: ${{ env.COVERAGE_THRESHOLD != '' }}

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [lint, typecheck, test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: .nvmrc
          cache: npm
      - run: npm ci
      - run: npm run build
```

#### Python template

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install ruff
      - run: ruff check .

  typecheck:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install mypy
      - run: mypy .

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install -r requirements.txt
      - run: pytest --cov --cov-report=term-missing
```

#### Go template

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
          cache: true
      - uses: golangci/golangci-lint-action@v6

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
          cache: true
      - run: go test ./... -race -coverprofile=coverage.out
      - run: go tool cover -func=coverage.out
```

#### Rust template

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: clippy, rustfmt
      - uses: Swatinem/rust-cache@v2
      - run: cargo clippy -- -D warnings
      - run: cargo fmt --check

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: Swatinem/rust-cache@v2
      - run: cargo test
```

### Step 4 — Optional: Branch Protection

After creating the workflow, suggest enabling branch protection rules:

```
Recommended GitHub branch protection for `main`:
  ✓ Require status checks to pass before merging
      - CI / Lint
      - CI / Type Check
      - CI / Test
  ✓ Require branches to be up to date before merging
  ✓ Require pull request reviews before merging (min 1)
  ✓ Dismiss stale pull request approvals when new commits are pushed

To configure: repo Settings → Branches → Add branch protection rule
```

### Step 5 — Commit

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions CI pipeline (lint, typecheck, test, build)"
```

## Coaching Notes

> **ABC - Always Be Coaching:**

1. **Parallel jobs are free.** Lint, typecheck, and test are independent — run them in parallel. Sequential CI is a team tax: everyone waits.

2. **Cache is mandatory.** An uncached `npm ci` on a 200-package project takes 2-3 minutes. Cached: 15 seconds. Multiply by 50 PRs/week = hours saved.

3. **`cancel-in-progress: true` prevents CI backlog.** When you push 3 quick commits, only the latest should be running. Without this, you queue up 3 concurrent CI runs for nothing.

4. **Pin action versions.** `actions/checkout@v4` not `actions/checkout@latest`. Unpinned actions break your CI when upstream publishes a breaking change. You didn't change anything; your CI just broke.

5. **Coverage thresholds fail PRs that regress coverage.** Without a threshold, coverage drifts down slowly. Set it once and enforce it automatically.

## Verification

After running this skill:

- [ ] `.github/workflows/ci.yml` exists and is valid YAML
- [ ] Jobs are correctly named and runnable
- [ ] Caching is configured (npm cache / pip cache / cargo cache)
- [ ] `concurrency` block prevents queue buildup
- [ ] Branch triggers are correct (push + PR to main)
- [ ] Coverage threshold is set if desired
- [ ] Committed and pushed; CI run starts on GitHub

## Related Skills

- `ci-cd-automation` — Feature flags, deployment pipelines, quality gates
- `git-workflow` — Branch strategy and commit conventions
- `github-pr-manager` — PR creation and review automation

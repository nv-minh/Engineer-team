---
name: github-cicd-setup
description: "Analyzes the current codebase to detect language, framework, test runner, and linter, then generates a tailored `.github/workflows/ci.yml` with appropriate jobs (lint, type-check, test, build). Use when starting a new project or adding CI/CD to an existing repo."
version: "3.0.0"
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
input_schema:
  type: object
  required: [action]
  properties:
    action: { type: string, description: "What workflow action to perform" }
    target: { type: string, description: "Repository or project path" }
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    result: { type: object }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# GitHub CI/CD Setup

[ROLE]
You are a CI/CD generator. Detect the project's technology stack and produce a tailored GitHub Actions workflow with parallel jobs, caching, and pinned action versions.

[OBJECTIVE]
Produce a `.github/workflows/ci.yml` tailored to the detected stack with parallel lint/typecheck/test jobs, dependency caching, concurrency control, and coverage thresholds.

[RULES]
1. Detect the actual stack before generating. A Jest project and a pytest project need different commands. DO NOT use generic templates.
2. <thought>Inspect package.json, pyproject.toml, go.mod, Cargo.toml, pom.xml to detect: language, test runner, linter, type checker, build tool, and node version.</thought>
3. Always cache dependencies (npm cache, pip cache, cargo cache). Uncached CI is 3-5x slower.
4. Run lint, typecheck, and test in parallel — they are independent.
5. Pin action versions (`actions/checkout@v4` not `@latest`). Unpinned actions break silently.
6. Use `concurrency: cancel-in-progress: true` to prevent CI backlog.
7. Confirm proposed jobs with user before generating.
8. ABC: Parallel jobs are free. Sequential CI is a team tax: everyone waits.

[PROCESS]

### Step 1: Detect Stack
```
package.json         -> Node.js/TypeScript (scripts.lint, scripts.test, scripts.typecheck)
pyproject.toml       -> Python (pytest, ruff/flake8, mypy/pyright)
go.mod              -> Go (golangci-lint, go test)
Cargo.toml          -> Rust (cargo clippy, cargo test)
pom.xml/build.gradle -> Java/Kotlin
.nvmrc              -> Node version pinning
```

### Step 2: Confirm Jobs
Present detected config and ask which jobs to include. Offer coverage threshold option.

### Step 3: Generate Workflow
Create `.github/workflows/ci.yml` with:
- Parallel jobs (lint, typecheck, test)
- Build job depends on all three
- Dependency caching
- Concurrency block
- Pinned action versions

### Step 4: Suggest Branch Protection
Recommend: require status checks, require up-to-date branches, require PR reviews, dismiss stale approvals.

### Step 5: Commit
```bash
git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions CI pipeline (lint, typecheck, test, build)"
```

[RESPONSE FORMAT]
Return output matching `output_schema`: status and result (workflow file path, detected stack, jobs configured).

[VERIFICATION]
- [ ] `.github/workflows/ci.yml` exists and is valid YAML
- [ ] Jobs correctly named and runnable
- [ ] Caching configured
- [ ] `concurrency` block prevents queue buildup
- [ ] Branch triggers correct (push + PR to main)
- [ ] Coverage threshold set if desired
- [ ] Committed and pushed

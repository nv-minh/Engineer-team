# Verification Patterns Reference

Shared verification and quality gate patterns referenced by workflows and agents.

---

## Verification Gate Template

Every gate follows this structure:

```markdown
### Gate N: [Name] Complete
- [ ] [Criterion 1 - specific and measurable]
- [ ] [Criterion 2]
- [ ] [Criterion 3]
PASS → proceed to [next phase]
FAIL → return to [previous phase], [action required]
```

## Standard Verification Commands

### JavaScript/TypeScript
```bash
npm test                    # Unit tests
npm test -- --coverage      # With coverage
npm run lint --fix          # Lint
npx tsc --noEmit            # Type check
npm run build               # Build
npm run e2e                 # E2E tests
```

### Python
```bash
pytest                      # Unit tests
pytest --cov=src            # With coverage
ruff check . --fix          # Lint
mypy src/                   # Type check
```

### Go
```bash
go test ./...               # Unit tests
go test -race ./...         # With race detection
go vet ./...                # Static analysis
golangci-lint run           # Lint
go build ./...              # Build
```

### Rust
```bash
cargo test                  # Unit tests
cargo clippy                # Lint
cargo build                 # Debug build
cargo build --release       # Release build
```

## Coverage Gates

| Level | Minimum Coverage | Applies To |
|-------|-----------------|------------|
| Critical | 90% | Auth, payment, data handling |
| Standard | 80% | API routes, business logic |
| Basic | 60% | UI components, utilities |
| Optional | 40% | Config, setup, docs |

## Pre-Commit Checklist

```bash
# 1. Tests pass
npm test || exit 1

# 2. Lint clean
npm run lint || exit 1

# 3. Type check clean
npx tsc --noEmit || exit 1

# 4. Build succeeds
npm run build || exit 1

# 5. No secrets
git diff --cached | grep -iE '(password|secret|api_key)' && exit 1 || true

# 6. No TODO/FIXME in critical paths
git diff --cached | grep -E '(TODO|FIXME)' && echo "Warning: TODO/FIXME found" || true

# 7. No large files
git diff --cached --stat | awk '{if ($3 > 500) print "WARNING: Large file:", $1}'
```

## Post-Deploy Verification

```yaml
health_checks:
  - endpoint: /health
    expected: 200
    timeout: 5s

  - endpoint: /api/v1/status
    expected: 200
    body_contains: "ok"

  - check: console_errors
    expected: 0

  - check: lcp
    threshold: 2.5s

  - check: error_rate
    threshold: 1%
```

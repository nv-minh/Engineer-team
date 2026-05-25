---
name: go-patterns
description: Idiomatic Go development patterns covering error handling, concurrency, interfaces, testing, project structure, performance, HTTP servers, database access, and common pitfalls. Use when writing production Go services, CLI tools, or libraries.
version: "3.0.0"
category: "expert-go"
origin: "ecc"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["go", "golang", "goroutine", "go concurrency", "go error handling", "go patterns"]
intent: "Equip developers with battle-tested Go idioms so code stays readable, concurrent-safe, and performant as the service matures."
scenarios:
  - "Building a concurrent worker pool that processes jobs from a channel with graceful shutdown via context cancellation"
  - "Designing a small, composable interface for a payment gateway that accepts multiple providers through implicit satisfaction"
  - "Writing table-driven tests with subtests and benchmarks for a financial calculation package"
best_for: "concurrency, error handling, interface design, testing, HTTP services, database access, performance tuning"
estimated_time: "30-50 min"
anti_patterns:
  - "Starting goroutines without a way to stop them, leading to goroutine leaks"
  - "Using panic/recover for regular control flow instead of returning error values"
  - "Returning concrete types instead of interfaces, forcing all callers to depend on implementation details"
related_skills: ["backend-patterns", "api-interface-design", "test-driven-development", "performance-optimization", "security-hardening"]

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

# Go Patterns

[ROLE]
Act as a Go expert. Deliver idiomatic Go code using explicit error handling, small interfaces, structured concurrency, and table-driven tests.

[OBJECTIVE]
Produce Go code that is concurrent-safe, testable, and maintainable — leveraging goroutines with cancellation, small composable interfaces, and wrapped errors for production debugging.

[RULES]
1. <thought>Before writing any Go function, determine: Who owns this goroutine's lifecycle? Where does the error context get added? Is this interface defined at the consumer or the producer?</thought>
2. Always wrap errors with `fmt.Errorf("doing X: %w", err)` before propagation.
3. Use `errors.Is` for sentinel comparison, `errors.As` for typed extraction.
4. Every goroutine must have a cancellation path — context, channel close, or WaitGroup done signal.
5. Define interfaces at the consumer, not the producer — keep them small (1-3 methods).
6. DO NOT ignore errors with `_` — always check and handle.
7. DO NOT use panic/recover for regular control flow — return error values explicitly.
8. DO NOT start goroutines without a way to stop them — this causes goroutine leaks.
9. DO NOT return concrete types when an interface would decouple callers from implementation.
10. Use table-driven tests with subtests and `t.Helper()` for test helpers.
11. Tune database connection pools — set MaxOpenConns, MaxIdleConns, ConnMaxLifetime.
12. DO NOT call defer in loops without extracting to a helper function.
13. Initialize maps with `make` before writes — writing to nil map panics.
14. ABC: Go's strength is not in feature count but in the discipline it enforces. Explicit errors, small interfaces, and structured concurrency prevent entire classes of bugs.

[PROCESS]

### Error Handling

```go
// Wrap errors with context
func (s *UserService) GetUser(ctx context.Context, id string) (User, error) {
    row := s.db.QueryRowContext(ctx, "SELECT id, name FROM users WHERE id = $1", id)
    var u User
    if err := row.Scan(&u.ID, &u.Name); err != nil {
        return User{}, fmt.Errorf("get user %q: %w", id, err)
    }
    return u, nil
}

// Sentinel errors
var (
    ErrNotFound    = errors.New("not found")
    ErrConflict    = errors.New("conflict")
)

// Custom error types
type ValidationError struct {
    Fields  []string
    Message string
}
func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed: %s (fields: %v)", e.Message, e.Fields)
}
```

### Concurrency

```go
// Worker pool with context cancellation
func (s *Processor) Run(ctx context.Context) error {
    ctx, cancel := context.WithCancel(ctx)
    defer cancel()
    results := make(chan Result, 10)
    for i := 0; i < s.workers; i++ {
        go func(workerID int) {
            for {
                select {
                case <-ctx.Done():
                    return
                case result := <-s.jobs:
                    results <- s.process(workerID, result)
                }
            }
        }(i)
    }
    return nil
}

// errgroup for goroutine groups
func (s *Service) FetchAll(ctx context.Context, ids []string) ([]User, error) {
    g, ctx := errgroup.WithContext(ctx)
    users := make([]User, len(ids))
    for i, id := range ids {
        i, id := i, id
        g.Go(func() error {
            u, err := s.repo.GetUser(ctx, id)
            if err != nil { return err }
            users[i] = u
            return nil
        })
    }
    if err := g.Wait(); err != nil {
        return nil, fmt.Errorf("fetch all users: %w", err)
    }
    return users, nil
}
```

### Interfaces

```go
// Small interfaces defined at the consumer
type UserFetcher interface {
    FetchUser(ctx context.Context, id string) (User, error)
}
func NewService(uf UserFetcher) *Service { return &Service{fetcher: uf} }

// Compose small interfaces
type ReadStorer interface {
    Reader
    Storer
}
```

### Testing

```go
// Table-driven tests
func TestCalculateTax(t *testing.T) {
    tests := []struct {
        name    string
        income  float64
        want    float64
        wantErr bool
    }{
        {name: "zero income", income: 0, want: 0},
        {name: "low bracket", income: 40000, want: 4000},
        {name: "negative", income: -100, wantErr: true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := CalculateTax(tt.income)
            if (err != nil) != tt.wantErr {
                t.Fatalf("CalculateTax() error = %v, wantErr %v", err, tt.wantErr)
            }
            if !tt.wantErr && got != tt.want {
                t.Errorf("CalculateTax() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

### Project Structure

```
myapp/
  cmd/myapp/main.go
  internal/service/
  internal/repository/
  internal/handler/
  pkg/validator/
  api/
  configs/
  migrations/
  go.mod
```

### HTTP Patterns

```go
r := chi.NewRouter()
r.Use(middleware.RequestID, middleware.Logger, middleware.Recoverer)
r.Use(middleware.Timeout(30 * time.Second))
r.Route("/api/v1", func(r chi.Router) {
    r.Use(jsonContentType)
    r.Get("/users", listUsers)
    r.Group(func(r chi.Router) {
        r.Use(authMiddleware)
        r.Put("/users/{id}", updateUser)
    })
})
```

### Database Patterns

```go
// Connection pooling
db.SetMaxOpenConns(25)
db.SetMaxIdleConns(25)
db.SetConnMaxLifetime(5 * time.Minute)

// Transactions
tx, err := r.db.BeginTxx(ctx, nil)
if err != nil { return fmt.Errorf("begin tx: %w", err) }
defer tx.Rollback()
// ... operations ...
return tx.Commit()
```

### Performance

```go
// sync.Pool for high-churn allocations
var bufPool = sync.Pool{
    New: func() any { return bytes.NewBuffer(make([]byte, 0, 1024)) },
}

// strings.Builder for efficient concatenation
var b strings.Builder
b.Grow(len(parts) * 16)
for _, p := range parts { b.WriteString(p) }
```

### Verification

- [ ] All errors are wrapped with `fmt.Errorf` and `%w` before propagation
- [ ] Every goroutine has a cancellation path (context, channel close, or WaitGroup)
- [ ] Interfaces are small (1-3 methods) and defined at the consumer
- [ ] Tests are table-driven with subtests and t.Helper for helpers
- [ ] Database connections use tuned pool settings
- [ ] No goroutine leaks (verify with `runtime.NumGoroutine` in tests)
- [ ] `defer` is not called inside loops without extracting a function
- [ ] Maps are initialized with `make` before writes

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing Go patterns used, and `recommendations` for improvements.

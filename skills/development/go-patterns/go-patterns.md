---
name: go-patterns
description: Idiomatic Go development patterns covering error handling, concurrency, interfaces, testing, project structure, performance, HTTP servers, database access, and common pitfalls. Use when writing production Go services, CLI tools, or libraries.
version: "2.0.0"
category: "development"
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
---

# Go Patterns

## Overview

Go's design philosophy favors simplicity, explicit error handling, and lightweight concurrency through goroutines and channels. Mastering idiomatic patterns is essential for writing production-grade Go that is concurrent-safe, testable, and maintainable. This skill covers the core patterns every Go developer needs.

## When to Use

- Building backend services, APIs, or microservices in Go
- Writing concurrent pipelines, worker pools, or fan-out/fan-in systems
- Designing packages with clean interface boundaries
- Setting up a Go project with proper layout and dependency management
- Optimizing performance-critical hot paths
- Interacting with databases using sqlx, pgx, or database/sql

## When NOT to Use

- Prototyping a quick script where Python or Bash would be faster
- Building highly object-oriented domain models (Go lacks inheritance; prefer composition)
- Projects requiring a rich generic collections library (Go generics are intentionally limited)

## Error Handling

### Wrapping Errors

Always add context when propagating errors upward:

```go
import (
    "fmt"
    "errors"
)

// ✅ Good: Wrap errors with fmt.Errorf and %w for chain inspection
func (s *UserService) GetUser(ctx context.Context, id string) (User, error) {
    row := s.db.QueryRowContext(ctx, "SELECT id, name FROM users WHERE id = $1", id)
    var u User
    if err := row.Scan(&u.ID, &u.Name); err != nil {
        return User{}, fmt.Errorf("get user %q: %w", id, err)
    }
    return u, nil
}
```

### Sentinel Errors and errors.Is/As

```go
import "errors"

var (
    ErrNotFound    = errors.New("not found")
    ErrConflict    = errors.New("conflict")
    ErrUnauthorized = errors.New("unauthorized")
)

// ✅ Good: Use errors.Is for sentinel comparison, errors.As for typed extraction
func HandleError(err error) {
    if errors.Is(err, ErrNotFound) {
        // handle not found
    }

    var valErr *ValidationError
    if errors.As(err, &valErr) {
        // access typed fields: valErr.Fields
    }
}
```

### Custom Error Types

```go
// ✅ Good: Custom error type with structured data
type ValidationError struct {
    Fields []string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed: %s (fields: %v)", e.Message, e.Fields)
}

func ValidateUser(u User) error {
    var fields []string
    if u.Name == "" {
        fields = append(fields, "name")
    }
    if u.Email == "" {
        fields = append(fields, "email")
    }
    if len(fields) > 0 {
        return &ValidationError{Fields: fields, Message: "required fields missing"}
    }
    return nil
}
```

## Concurrency

### Goroutines with Context Cancellation

```go
func (s *Processor) Run(ctx context.Context) error {
    ctx, cancel := context.WithCancel(ctx)
    defer cancel() // ensure all children are cancelled on return

    results := make(chan Result, 10)

    for i := 0; i < s.workers; i++ {
        go func(workerID int) {
            for {
                select {
                case <-ctx.Done():
                    return // graceful shutdown
                case result := <-s.jobs:
                    results <- s.process(workerID, result)
                }
            }
        }(i)
    }

    // collect results...
    return nil
}
```

### Channels and Fan-Out/Fan-In

```go
// ✅ Good: Fan-out work, fan-in results
func FanOutFanIn(ctx context.Context, items []Item, fn func(Item) Result) []Result {
    out := make(chan Result, len(items))

    // fan-out
    for _, item := range items {
        go func(i Item) {
            select {
            case <-ctx.Done():
                return
            case out <- fn(i):
            }
        }(item)
    }

    // fan-in
    var results []Result
    for i := 0; i < len(items); i++ {
        select {
        case <-ctx.Done():
            return results
        case r := <-out:
            results = append(results, r)
        }
    }
    return results
}
```

### errgroup for Goroutine Groups

```go
import "golang.org/x/sync/errgroup"

func (s *Service) FetchAll(ctx context.Context, ids []string) ([]User, error) {
    g, ctx := errgroup.WithContext(ctx)
    users := make([]User, len(ids))

    for i, id := range ids {
        i, id := i, id // capture loop variables
        g.Go(func() error {
            u, err := s.repo.GetUser(ctx, id)
            if err != nil {
                return err
            }
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

### sync Primitives

```go
import "sync"

// ✅ Good: sync.Once for one-time initialization
type ConnPool struct {
    initOnce sync.Once
    pool     *sql.DB
    err      error
}

func (c *ConnPool) Get() (*sql.DB, error) {
    c.initOnce.Do(func() {
        c.pool, c.err = sql.Open("postgres", dsn)
    })
    return c.pool, c.err
}

// ✅ Good: sync.Map for read-heavy concurrent maps
var cache sync.Map

func Set(key, val string) { cache.Store(key, val) }
func Get(key string) (string, bool) {
    v, ok := cache.Load(key)
    if !ok { return "", false }
    return v.(string), true
}
```

## Interfaces

### Small Interfaces

```go
// ✅ Good: Single-method interfaces are the most flexible
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Storer interface {
    Store(ctx context.Context, data []byte) error
}

type Validator interface {
    Validate() error
}

// Compose small interfaces
type ReadStorer interface {
    Reader
    Storer
}
```

### Implicit Satisfaction

```go
// ✅ Good: Define interfaces where they are consumed, not where they are implemented
package consumer

type UserFetcher interface {
    FetchUser(ctx context.Context, id string) (User, error)
}

func NewService(uf UserFetcher) *Service {
    return &Service{fetcher: uf}
}

// The postgres package doesn't know about UserFetcher
package postgres

type Repo struct { db *sql.DB }

func (r *Repo) FetchUser(ctx context.Context, id string) (consumer.User, error) {
    // ... postgres automatically satisfies consumer.UserFetcher
}
```

### Interface Composition

```go
type Logger interface {
    Log(msg string, fields ...Field)
}

type Meter interface {
    Incr(name string, tags ...string)
}

// ✅ Good: Compose for cross-cutting concerns
type Observability interface {
    Logger
    Meter
}
```

## Testing

### Table-Driven Tests

```go
func TestCalculateTax(t *testing.T) {
    tests := []struct {
        name    string
        income  float64
        want    float64
        wantErr bool
    }{
        {name: "zero income", income: 0, want: 0},
        {name: "low bracket", income: 40000, want: 4000},
        {name: "high bracket", income: 120000, want: 24000},
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

### Test Helpers

```go
// ✅ Good: Helper functions for setup
func newTestDB(t *testing.T) *sql.DB {
    t.Helper()
    db, err := sql.Open("postgres", "postgres://test:test@localhost/testdb?sslmode=disable")
    if err != nil {
        t.Fatalf("opening test db: %v", err)
    }
    t.Cleanup(func() { db.Close() })
    return db
}

func newTestServer(t *testing.T, handler http.Handler) *httptest.Server {
    t.Helper()
    ts := httptest.NewServer(handler)
    t.Cleanup(ts.Close)
    return ts
}
```

### Mocks with Interfaces

```go
// ✅ Good: Hand-written mock for interface
type mockUserRepo struct {
    getUserFunc func(ctx context.Context, id string) (User, error)
}

func (m *mockUserRepo) GetUser(ctx context.Context, id string) (User, error) {
    return m.getUserFunc(ctx, id)
}

func TestService_GetUser(t *testing.T) {
    repo := &mockUserRepo{
        getUserFunc: func(ctx context.Context, id string) (User, error) {
            return User{ID: id, Name: "Alice"}, nil
        },
    }
    svc := NewService(repo)
    // test svc...
}
```

### Benchmarks and Fuzzing

```go
func BenchmarkCalculateTax(b *testing.B) {
    for i := 0; i < b.N; i++ {
        CalculateTax(120000)
    }
}

// ✅ Good: Fuzz test (Go 1.18+)
func FuzzCalculateTax(f *testing.F) {
    f.Add(50000.0)
    f.Add(-100.0)
    f.Fuzz(func(t *testing.T, income float64) {
        _, _ = CalculateTax(income) // must not panic
    })
}
```

## Project Structure

### Standard Layout

```
myapp/
  cmd/
    myapp/         # main entry point
      main.go
  internal/        # private application code
    service/
    repository/
    handler/
  pkg/             # public library code (if any)
    validator/
  api/             # API definitions (proto, openapi)
  configs/         # configuration files
  migrations/      # database migrations
  go.mod
  go.sum
```

### Internal Packages

```go
// internal/ packages cannot be imported by external projects
// Use them to enforce boundaries within your module

// internal/auth/jwt.go
package auth

func ParseToken(token string) (Claims, error) { /* ... */ }

// internal/repository/user.go
package repository

type UserRepo interface {
    GetByID(ctx context.Context, id string) (User, error)
}
```

### Dependency Management

```go
// go.mod
module github.com/myorg/myapp

go 1.22

require (
    github.com/jackc/pgx/v5 v5.5.0
    github.com/go-chi/chi/v5 v5.0.12
    golang.org/x/sync v0.6.0
)
```

## Performance

### Profiling

```go
import _ "net/http/pprof"

// Add to main for runtime profiling
go func() {
    log.Println(http.ListenAndServe("localhost:6060", nil))
}()

// Then: go tool pprof http://localhost:6060/debug/pprof/profile
```

### Memory Optimization and sync.Pool

```go
// ✅ Good: Pool for high-churn allocations
var bufPool = sync.Pool{
    New: func() any {
        return bytes.NewBuffer(make([]byte, 0, 1024))
    },
}

func Process(data []byte) string {
    buf := bufPool.Get().(*bytes.Buffer)
    defer func() {
        buf.Reset()
        bufPool.Put(buf)
    }()

    buf.Write(data)
    // process...
    return buf.String()
}
```

### Efficient String Building

```go
import "strings"

// ❌ Bad: string concatenation in a loop
func join(parts []string) string {
    var s string
    for _, p := range parts {
        s += p // allocates a new string every iteration
    }
    return s
}

// ✅ Good: strings.Builder
func join(parts []string) string {
    var b strings.Builder
    b.Grow(len(parts) * 16) // preallocate
    for _, p := range parts {
        b.WriteString(p)
    }
    return b.String()
}
```

## HTTP Patterns

### Middleware Chain

```go
import "github.com/go-chi/chi/v5/middleware"

func main() {
    r := chi.NewRouter()

    // Global middleware
    r.Use(middleware.RequestID)
    r.Use(middleware.RealIP)
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)
    r.Use(middleware.Timeout(30 * time.Second))

    r.Route("/api/v1", func(r chi.Router) {
        r.Use(jsonContentType)
        r.Get("/users", listUsers)
        r.Post("/users", createUser)

        r.Group(func(r chi.Router) {
            r.Use(authMiddleware)
            r.Put("/users/{id}", updateUser)
            r.Delete("/users/{id}", deleteUser)
        })
    })
}

func jsonContentType(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        next.ServeHTTP(w, r)
    })
}
```

### Handler Patterns

```go
// ✅ Good: Handler returns error for centralized handling
func listUsers(w http.ResponseWriter, r *http.Request) error {
    users, err := service.ListUsers(r.Context())
    if err != nil {
        return fmt.Errorf("list users: %w", err)
    }
    return json.NewEncoder(w).Encode(users)
}

// Wrap with error-aware handler
func handle(fn func(w http.ResponseWriter, r *http.Request) error) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        if err := fn(w, r); err != nil {
            slog.Error("handler error", "error", err, "path", r.URL.Path)
            http.Error(w, `{"error":"internal server error"}`, http.StatusInternalServerError)
        }
    }
}
```

## Database Patterns

### sqlx Queries

```go
import "github.com/jmoiron/sqlx"

type User struct {
    ID    string `db:"id"    json:"id"`
    Name  string `db:"name"  json:"name"`
    Email string `db:"email" json:"email"`
}

func (r *UserRepo) GetByID(ctx context.Context, id string) (User, error) {
    var u User
    err := r.db.GetContext(ctx, &u, "SELECT id, name, email FROM users WHERE id = $1", id)
    if err != nil {
        return User{}, fmt.Errorf("get user %q: %w", id, err)
    }
    return u, nil
}

func (r *UserRepo) List(ctx context.Context, limit, offset int) ([]User, error) {
    var users []User
    err := r.db.SelectContext(ctx, &users,
        "SELECT id, name, email FROM users ORDER BY name LIMIT $1 OFFSET $2",
        limit, offset,
    )
    return users, err
}
```

### Transactions

```go
func (r *UserRepo) Transfer(ctx context.Context, fromID, toID string, amount int64) error {
    tx, err := r.db.BeginTxx(ctx, nil)
    if err != nil {
        return fmt.Errorf("begin tx: %w", err)
    }
    defer tx.Rollback() // no-op if committed

    var balance int64
    if err := tx.GetContext(ctx, &balance,
        "SELECT balance FROM accounts WHERE user_id = $1 FOR UPDATE", fromID); err != nil {
        return fmt.Errorf("lock sender: %w", err)
    }
    if balance < amount {
        return ErrInsufficientFunds
    }

    if _, err := tx.ExecContext(ctx,
        "UPDATE accounts SET balance = balance - $1 WHERE user_id = $2", amount, fromID); err != nil {
        return fmt.Errorf("debit: %w", err)
    }
    if _, err := tx.ExecContext(ctx,
        "UPDATE accounts SET balance = balance + $1 WHERE user_id = $2", amount, toID); err != nil {
        return fmt.Errorf("credit: %w", err)
    }

    return tx.Commit()
}
```

### Connection Pooling

```go
func openDB(dsn string) (*sqlx.DB, error) {
    db, err := sqlx.Open("pgx", dsn)
    if err != nil {
        return nil, fmt.Errorf("open db: %w", err)
    }

    // ✅ Good: Tune pool for production
    db.SetMaxOpenConns(25)
    db.SetMaxIdleConns(25)
    db.SetConnMaxLifetime(5 * time.Minute)
    db.SetConnMaxIdleTime(1 * time.Minute)

    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    if err := db.PingContext(ctx); err != nil {
        return nil, fmt.Errorf("ping db: %w", err)
    }

    return db, nil
}
```

## Common Pitfalls

### Goroutine Leaks

```go
// ❌ Bad: Leaked goroutine -- channel never closes
func leak() <-chan int {
    ch := make(chan int)
    go func() {
        ch <- 42
        // if nobody reads, goroutine blocks forever
    }()
    return ch
}

// ✅ Good: Buffered channel or context cancellation
func noLeak(ctx context.Context) <-chan int {
    ch := make(chan int, 1) // buffered
    go func() {
        select {
        case <-ctx.Done():
            return
        case ch <- 42:
        }
    }()
    return ch
}
```

### Nil Map Writes

```go
// ❌ Bad: Writing to nil map panics
var m map[string]int
m["key"] = 1 // panic: assignment to entry in nil map

// ✅ Good: Initialize with make
m := make(map[string]int)
m["key"] = 1
```

### Slice Tricks

```go
// ✅ Good: Remove element preserving order
func removeAt(s []int, i int) []int {
    return append(s[:i], s[i+1:]...)
}

// ✅ Good: Remove element without preserving order (faster)
func removeAtFast(s []int, i int) []int {
    s[i] = s[len(s)-1]
    return s[:len(s)-1]
}

// ✅ Good: Copy a slice to avoid aliasing
func cloneSlice(s []int) []int {
    c := make([]int, len(s))
    copy(c, s)
    return c
}
```

### Defer in Loops

```go
// ❌ Bad: Defers accumulate until function returns
func processAll(files []string) error {
    for _, f := range files {
        fh, err := os.Open(f)
        if err != nil { return err }
        defer fh.Close() // all close at function end
        // process...
    }
    return nil
}

// ✅ Good: Extract to helper so defer runs per iteration
func processFile(path string) error {
    fh, err := os.Open(path)
    if err != nil { return err }
    defer fh.Close()
    // process...
    return nil
}

func processAll(files []string) error {
    for _, f := range files {
        if err := processFile(f); err != nil {
            return fmt.Errorf("process %q: %w", f, err)
        }
    }
    return nil
}
```

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Ignoring errors with `_` | Silent failures corrupt state | Always check and handle errors |
| Using panics for flow control | Unrecoverable crashes in production | Return `error` values explicitly |
| Starting goroutines without cancellation | Goroutine leaks and memory growth | Use `context.Context` and `select` |
| Returning concrete types | Forces caller coupling | Return small interfaces instead |
| Exporting large interfaces | Hard to mock and satisfy | Accept interfaces, return structs |
| Naked goroutine in tests | Flaky, non-deterministic tests | Use `sync.WaitGroup` or channels |
| Mutex over channels | Unnecessary complexity for simple state | Prefer channels for communication, mutexes for state |
| Not tuning connection pool | Starvation or wasted connections | Set MaxOpenConns, MaxIdleConns, ConnMaxLifetime |

## Coaching Notes

> **ABC -- Always Be Coaching:** Go's strength is not in feature count but in the discipline it enforces. Explicit errors, small interfaces, and structured concurrency prevent entire classes of bugs that plague other ecosystems.

1. **If an error is worth returning, it is worth wrapping:** Every time you pass an error up the call stack, add `fmt.Errorf("doing X: %w", err)`. Six months from now, the chain of context is what lets you diagnose a production incident in minutes instead of hours.

2. **The goroutine is cheap but not free:** A goroutine that never exits is a memory leak. Always pair every `go func()` with a `context.Context` cancellation path, a channel close, or a `sync.WaitGroup` done signal. If you cannot point to the exit strategy, you have a leak.

3. **Interfaces belong to the consumer, not the producer:** Define the one-method interface in the package that uses it, and let the provider satisfy it implicitly. This keeps your dependency graph pointing inward and makes testing trivially easy with hand-written mocks.

## Verification Checklist

After applying Go patterns:

- [ ] All errors are wrapped with `fmt.Errorf` and `%w` before propagation
- [ ] Sentinel errors use `errors.Is`/`errors.As` for inspection
- [ ] Every goroutine has a cancellation path (context, channel close, or WaitGroup)
- [ ] Interfaces are small (1-3 methods) and defined at the consumer
- [ ] Tests are table-driven with subtests and t.Helper for helpers
- [ ] Benchmarks cover hot paths
- [ ] Database connections use tuned pool settings
- [ ] Transactions wrap multi-step writes
- [ ] HTTP handlers use middleware for cross-cutting concerns
- [ ] No goroutine leaks (verify with `runtime.NumGoroutine` in tests)
- [ ] `defer` is not called inside loops without extracting a function
- [ ] Maps are initialized with `make` before writes

## Related Skills

- **backend-patterns** -- Service layer, repository pattern, caching
- **api-interface-design** -- Contract-first API design
- **test-driven-development** -- RED-GREEN-REFACTOR cycle
- **performance-optimization** -- Profiling and measurement methodology
- **security-hardening** -- OWASP for Go HTTP services

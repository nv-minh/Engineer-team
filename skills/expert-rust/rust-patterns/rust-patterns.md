---
name: rust-patterns
description: Idiomatic Rust development patterns covering ownership, borrowing, error handling, traits, async programming, iterators, smart pointers, testing, concurrency, FFI, and macros. Use when building safe, high-performance systems, CLIs, web servers, or libraries in Rust.
version: "3.0.0"
category: "expert-rust"
origin: "ecc"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["rust", "ownership", "borrowing", "traits", "async rust", "rust patterns", "lifetimes"]
intent: "Equip developers with idiomatic Rust patterns so code leverages the borrow checker, trait system, and zero-cost abstractions to produce safe and performant binaries."
scenarios:
  - "Building an async web service with tokio that handles concurrent requests, shared state, and graceful shutdown"
  - "Designing a trait-based plugin system where each plugin satisfies a common interface with associated types"
  - "Implementing a concurrent pipeline with crossbeam channels, rayon parallel iterators, and criterion benchmarks"
best_for: "ownership models, trait design, async patterns, zero-cost abstractions, concurrency, FFI, macros"
estimated_time: "35-55 min"
anti_patterns:
  - "Fighting the borrow checker with excessive .clone() instead of restructuring ownership or using references"
  - "Using unwrap() on Results and Options in production code instead of proper error propagation with ?"
  - "Wrapping everything in Arc<Mutex<T>> when single-threaded ownership or message passing would suffice"
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

# Rust Patterns

[ROLE]
Act as a Rust expert. Deliver idiomatic Rust code that leverages the borrow checker, trait system, and zero-cost abstractions for safe, performant binaries.

[OBJECTIVE]
Produce Rust code where ownership is explicit, errors use thiserror/anyhow with context, traits enable extensibility, and async code uses structured concurrency with tokio.

[RULES]
1. <thought>Before writing any Rust code, determine: Who owns each piece of data? What error type hierarchy fits (thiserror for libs, anyhow for apps)? Is this trait object (dynamic) or generic (static) dispatch?</thought>
2. Design data structures around ownership first — decide who owns each piece of data before writing methods.
3. Use thiserror for library error types, anyhow for application error handling.
4. No `.unwrap()` or `.expect()` in production code paths — use `?` and `map_err`.
5. Use the smallest synchronization primitive that works — ownership > channels > Mutex > atomics.
6. DO NOT fight the borrow checker with excessive `.clone()` — restructure ownership.
7. DO NOT use unwrap() in production — propagate errors with `?`.
8. DO NOT wrap everything in Arc<Mutex<T>> — prefer message passing with channels.
9. Minimize unsafe blocks — document safety invariants, wrap in safe APIs.
10. Use trait associated types when there is a unique type per impl.
11. Use iterators instead of manual loops for data transformations.
12. Run clippy in CI and address all warnings.
13. ABC: The borrow checker is not the enemy — it forces you to think about ownership before the bug reaches production. Once the patterns click, you write code that is simultaneously safer and faster.

[PROCESS]

### Ownership and Borrowing

```rust
// Lifetime annotations
struct Parser<'a> { input: &'a str, pos: usize }

impl<'a> Parser<'a> {
    fn new(input: &'a str) -> Self { Self { input, pos: 0 } }
    fn slice_until(&mut self, stop: char) -> &'a str {
        let start = self.pos;
        while let Some(ch) = self.input[self.pos..].chars().next() {
            if ch == stop { break; }
            self.pos += ch.len_utf8();
        }
        &self.input[start..self.pos]
    }
}

// Cow for clone-on-write
fn normalize<'a>(input: Cow<'a, str>) -> Cow<'a, str> {
    if input.contains(char::is_uppercase) { Cow::Owned(input.to_lowercase()) }
    else { input }
}
```

### Error Handling

```rust
// thiserror for library errors
#[derive(Error, Debug)]
pub enum AppError {
    #[error("user not found: {id}")] NotFound { id: String },
    #[error("validation failed: {message}")] Validation { message: String },
    #[error("database error")] Database(#[from] sqlx::Error),
}

// anyhow for application errors
fn run() -> Result<()> {
    let config = fs::read_to_string("config.toml").context("failed to read config file")?;
    let parsed: Config = toml::from_str(&config).context("failed to parse config")?;
    Ok(())
}
```

### Traits

```rust
// Associated types for trait families
trait Repository {
    type Entity;
    type Error: std::error::Error;
    fn get(&self, id: &str) -> Result<Self::Entity, Self::Error>;
    fn save(&mut self, entity: Self::Entity) -> Result<(), Self::Error>;
}

// Newtype pattern for type safety
struct UserId(String);
struct OrderId(String);
// Cannot accidentally mix up UserId and OrderId at compile time
```

### Async Patterns

```rust
// tokio::select! for racing futures
async fn run_server(mut shutdown_rx: mpsc::Receiver<()>) {
    tokio::select! {
        _ = serve_requests() => { println!("server finished"); }
        _ = signal::ctrl_c() => { println!("received ctrl-c"); }
        _ = shutdown_rx.recv() => { println!("received shutdown"); }
    }
}

// async fn in trait (stable since Rust 1.75)
trait FetchService {
    async fn fetch_user(&self, id: &str) -> Result<User, AppError>;
}
```

### Iterators

```rust
fn summarize_scores(records: &[Record]) -> Vec<(String, f64)> {
    records.iter()
        .filter(|r| r.active)
        .filter_map(|r| Some((r.name.clone(), r.score?)))
        .map(|(name, score)| (name, score * 100.0))
        .filter(|(_, score)| *score >= 60.0)
        .take(10)
        .collect()
}
```

### Concurrency

```rust
// rayon for data parallelism
fn process_all(records: &[Record]) -> Vec<Result<Output, AppError>> {
    records.par_iter().map(|r| process_record(r)).collect()
}

// Atomics for lock-free counters
struct Metrics {
    requests: AtomicU64,
    errors: AtomicU64,
}
```

### Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_calculate_tax() -> Result<(), Box<dyn std::error::Error>> {
        let config = parse_config("key = value")?;
        assert_eq!(config.get("key"), Some(&"value".to_string()));
        Ok(())
    }
}

// Property testing with proptest
proptest! {
    #[test]
    fn test_parse_roundtrip(n in any::<i32>()) {
        let s = n.to_string();
        let parsed: i32 = s.parse().unwrap();
        assert_eq!(parsed, n);
    }
}
```

### FFI Guidelines

```rust
/// # Safety
/// `ptr` must point to a valid, null-terminated C string.
unsafe fn c_str_to_rust(ptr: *const c_char) -> &'static str {
    let bytes = CStr::from_ptr(ptr).to_bytes();
    std::str::from_utf8(bytes).expect("invalid utf8")
}

// Expose a safe API that wraps unsafe internals
pub fn get_version() -> String {
    unsafe { c_str_to_rust(syscall_get_version()) }.to_string()
}
```

### Verification

- [ ] Ownership is clear: each value has a single owner or shared via Rc/Arc
- [ ] Errors use thiserror (libraries) or anyhow (applications) with contextual messages
- [ ] No `.unwrap()` or `.expect()` in production code paths
- [ ] Traits use associated types when there is a unique type per impl
- [ ] Async code uses tokio::select! for cancellation and graceful shutdown
- [ ] Iterators replace manual loops for data transformations
- [ ] Unsafe blocks are minimal, documented, and wrapped in safe APIs
- [ ] Clippy passes with no warnings in CI

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing Rust patterns used, and `recommendations` for improvements.

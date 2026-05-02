---
name: rust-patterns
description: Idiomatic Rust development patterns covering ownership, borrowing, error handling, traits, async programming, iterators, smart pointers, testing, concurrency, FFI, and macros. Use when building safe, high-performance systems, CLIs, web servers, or libraries in Rust.
version: "2.0.0"
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
---

# Rust Patterns

## Overview

Rust's ownership system, trait-based generics, and zero-cost abstractions enable writing software that is memory-safe without garbage collection and concurrent without data races. Mastering idiomatic patterns is essential for working with the borrow checker productively and unlocking Rust's full performance potential.

## When to Use

- Building systems software, CLIs, web servers, or networked services
- Writing performance-critical code that must be memory-safe
- Designing libraries with trait-based extensibility
- Interfacing with C libraries via FFI
- Implementing concurrent or parallel data processing pipelines

## When NOT to Use

- Rapid prototyping where development speed outweighs safety guarantees
- Simple scripts better served by Python, Bash, or Go
- Projects where the team has no Rust experience and the timeline is tight

## Ownership and Borrowing

### Lifetime Annotations

```rust
use std::str::Chars;

// ✅ Good: Lifetime ties the iterator to the source string
struct Parser<'a> {
    input: &'a str,
    pos: usize,
}

impl<'a> Parser<'a> {
    fn new(input: &'a str) -> Self {
        Self { input, pos: 0 }
    }

    fn peek(&self) -> Option<char> {
        self.input[self.pos..].chars().next()
    }

    // Returns a slice that borrows from self's input
    fn slice_until(&mut self, stop: char) -> &'a str {
        let start = self.pos;
        while let Some(ch) = self.peek() {
            if ch == stop { break; }
            self.pos += ch.len_utf8();
        }
        &self.input[start..self.pos]
    }
}
```

### Rc and Arc for Shared Ownership

```rust
use std::rc::Rc;
use std::sync::Arc;

// Rc -- single-threaded reference counting
fn build_tree() -> Rc<TreeNode> {
    let leaf = Rc::new(TreeNode { value: 1, children: vec![] });
    let root = Rc::new(TreeNode {
        value: 10,
        children: vec![Rc::clone(&leaf)],
    });
    root
}

// Arc -- atomic reference counting for multi-threaded sharing
use std::sync::Arc;
use tokio::sync::Mutex;

async fn shared_state() {
    let state = Arc::new(Mutex::new(vec![1, 2, 3]));
    let mut handles = vec![];

    for _ in 0..4 {
        let s = Arc::clone(&state);
        handles.push(tokio::spawn(async move {
            let mut data = s.lock().await;
            data.push(42);
        }));
    }

    for h in handles {
        h.await.unwrap();
    }
}
```

### Cow for Clone-on-Write

```rust
use std::borrow::Cow;

// ✅ Good: Borrow when possible, own when necessary
fn normalize<'a>(input: Cow<'a, str>) -> Cow<'a, str> {
    if input.contains(char::is_uppercase) {
        // Need to allocate -- take ownership
        Cow::Owned(input.to_lowercase())
    } else {
        // No change -- keep the borrow
        input
    }
}

fn main() {
    let s = String::from("hello");
    let borrowed = Cow::Borrowed(&s[..]);
    let result = normalize(borrowed); // no allocation

    let s2 = String::from("HELLO");
    let owned = Cow::Owned(s2);
    let result2 = normalize(owned); // allocates lowercase version
}
```

## Error Handling

### Result Propagation with `?`

```rust
use std::fs;
use std::io;

fn read_config(path: &str) -> Result<String, io::Error> {
    let content = fs::read_to_string(path)?; // propagates io::Error
    Ok(content.trim().to_string())
}
```

### thiserror for Library Errors

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("user not found: {id}")]
    NotFound { id: String },

    #[error("validation failed: {message}")]
    Validation { message: String },

    #[error("database error")]
    Database(#[from] sqlx::Error),

    #[error("io error")]
    Io(#[from] std::io::Error),
}

// Usage
fn find_user(id: &str) -> Result<User, AppError> {
    let row = db::get_user(id).map_err(|_| AppError::NotFound { id: id.to_string() })?;
    Ok(row)
}
```

### anyhow for Application Errors

```rust
use anyhow::{Context, Result};

fn run() -> Result<()> {
    let config = fs::read_to_string("config.toml")
        .context("failed to read config file")?;

    let parsed: Config = toml::from_str(&config)
        .context("failed to parse config")?;

    let db = Database::connect(&parsed.database_url)
        .context("failed to connect to database")?;

    Ok(())
}
```

### Custom Error Types

```rust
#[derive(Debug)]
pub struct ParseError {
    pub line: usize,
    pub column: usize,
    pub expected: String,
    pub found: String,
}

impl std::fmt::Display for ParseError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "parse error at {}:{}: expected {}, found {}",
            self.line, self.column, self.expected, self.found)
    }
}

impl std::error::Error for ParseError {}
```

## Traits

### Trait Objects vs Generics

```rust
// ✅ Good: Generics (static dispatch, monomorphized) -- preferred when type is known at compile time
fn process<T: Display + Debug>(item: T) -> String {
    format!("{item}")
}

// ✅ Good: Trait objects (dynamic dispatch) -- needed for heterogeneous collections
fn print_all(items: &[Box<dyn Display>]) {
    for item in items {
        println!("{item}");
    }
}

// Heterogeneous collection
let items: Vec<Box<dyn Display>> = vec![
    Box::new(42i32),
    Box::new("hello"),
    Box::new(3.14f64),
];
```

### Associated Types

```rust
// ✅ Good: Associated types for trait families
trait Repository {
    type Entity;
    type Error: std::error::Error;

    fn get(&self, id: &str) -> Result<Self::Entity, Self::Error>;
    fn save(&mut self, entity: Self::Entity) -> Result<(), Self::Error>;
}

struct UserRepo { /* db handle */ }

impl Repository for UserRepo {
    type Entity = User;
    type Error = sqlx::Error;

    fn get(&self, id: &str) -> Result<User, sqlx::Error> {
        // implementation
        todo!()
    }

    fn save(&mut self, entity: User) -> Result<(), sqlx::Error> {
        todo!()
    }
}
```

### Blanket Implementations

```rust
// ✅ Good: Blanket impl adds functionality to all types satisfying a bound
trait Printable {
    fn to_display(&self) -> String;
}

impl<T: std::fmt::Display> Printable for T {
    fn to_display(&self) -> String {
        format!("value: {self}")
    }
}

// Now every Display type has .to_display()
let s = 42.to_display();
```

### Newtype Pattern

```rust
// ✅ Good: Newtype for type safety and trait forwarding
#[derive(Debug, Clone, PartialEq)]
struct UserId(String);

impl UserId {
    fn new(s: String) -> Result<Self, ValidationError> {
        if s.is_empty() {
            return Err(ValidationError("user id cannot be empty".into()));
        }
        Ok(Self(s))
    }

    fn as_str(&self) -> &str {
        &self.0
    }
}

// Cannot accidentally mix up UserId and OrderId at compile time
struct OrderId(String);
```

## Async Patterns

### tokio Runtime and Spawning

```rust
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let handle = tokio::spawn(async {
        sleep(Duration::from_secs(1)).await;
        42
    });

    let result = handle.await??;
    println!("result = {result}");
    Ok(())
}
```

### Async Traits

```rust
// ✅ Good: async fn in trait (stable since Rust 1.75)
trait FetchService {
    async fn fetch_user(&self, id: &str) -> Result<User, AppError>;
    async fn fetch_all(&self) -> Result<Vec<User>, AppError>;
}

struct HttpFetchService {
    client: reqwest::Client,
    base_url: String,
}

impl FetchService for HttpFetchService {
    async fn fetch_user(&self, id: &str) -> Result<User, AppError> {
        let url = format!("{}/users/{}", self.base_url, id);
        let user = self.client.get(&url)
            .send().await?
            .json::<User>().await?;
        Ok(user)
    }

    async fn fetch_all(&self) -> Result<Vec<User>, AppError> {
        let url = format!("{}/users", self.base_url);
        let users = self.client.get(&url)
            .send().await?
            .json::<Vec<User>>().await?;
        Ok(users)
    }
}
```

### select! for Racing Futures

```rust
use tokio::signal;
use tokio::sync::mpsc;

async fn run_server(
    mut shutdown_rx: mpsc::Receiver<()>,
) {
    let server = async {
        // serve requests
        loop {
            tokio::time::sleep(Duration::from_secs(1)).await;
        }
    };

    tokio::select! {
        _ = server => {
            println!("server finished");
        }
        _ = signal::ctrl_c() => {
            println!("received ctrl-c, shutting down");
        }
        _ = shutdown_rx.recv() => {
            println!("received shutdown signal");
        }
    }
}
```

## Collections and Iterators

### Iterator Adapters

```rust
// ✅ Good: Chain adapters for data transformation pipelines
fn summarize_scores(records: &[Record]) -> Vec<(String, f64)> {
    records.iter()
        .filter(|r| r.active)
        .filter_map(|r| {
            let score = r.score?;
            Some((r.name.clone(), score))
        })
        .map(|(name, score)| (name, score * 100.0))
        .filter(|(_, score)| *score >= 60.0)
        .take(10)
        .collect()
}
```

### IntoIterator and collect Patterns

```rust
use std::collections::{HashMap, BTreeSet};

// ✅ Good: collect into different types from the same iterator
let names = vec!["alice", "bob", "alice", "charlie"];

// into a set (dedup + sort)
let unique: BTreeSet<&str> = names.iter().copied().collect();

// into a map of counts
let counts: HashMap<&str, usize> = names.iter()
    .fold(HashMap::new(), |mut acc, &name| {
        *acc.entry(name).or_insert(0) += 1;
        acc
    });

// partition into two collections
let (even, odd): (Vec<i32>, Vec<i32>) = (1..=10)
    .partition(|&n| n % 2 == 0);
```

## Smart Pointers

### Box for Heap Allocation and Recursive Types

```rust
// ✅ Good: Box enables recursive types (fixed size at compile time)
enum Expr {
    Literal(f64),
    Add(Box<Expr>, Box<Expr>),
    Multiply(Box<Expr>, Box<Expr>),
    Negate(Box<Expr>),
}

impl Expr {
    fn eval(&self) -> f64 {
        match self {
            Expr::Literal(v) => *v,
            Expr::Add(a, b) => a.eval() + b.eval(),
            Expr::Multiply(a, b) => a.eval() * b.eval(),
            Expr::Negate(e) => -e.eval(),
        }
    }
}
```

### RefCell for Interior Mutability

```rust
use std::cell::RefCell;

// ✅ Good: RefCell enforces borrow rules at runtime
struct Graph {
    nodes: RefCell<Vec<Node>>,
}

impl Graph {
    fn add_edge(&self, from: usize, to: usize) {
        let mut nodes = self.nodes.borrow_mut();
        nodes[from].edges.push(to);
        nodes[to].edges.push(from);
    }

    fn degree(&self, idx: usize) -> usize {
        let nodes = self.nodes.borrow();
        nodes[idx].edges.len()
    }
}
```

### Mutex and RwLock

```rust
use std::sync::{Arc, Mutex, RwLock};

// ✅ Good: Mutex for exclusive access
fn counter_demo() {
    let counter = Arc::new(Mutex::new(0usize));
    let mut handles = vec![];

    for _ in 0..10 {
        let c = Arc::clone(&counter);
        handles.push(std::thread::spawn(move || {
            let mut num = c.lock().unwrap();
            *num += 1;
        }));
    }

    for h in handles { h.join().unwrap(); }
    assert_eq!(*counter.lock().unwrap(), 10);
}

// ✅ Good: RwLock for read-heavy workloads
fn cache_demo() {
    let cache: Arc<RwLock<HashMap<String, String>>> = Arc::new(RwLock::new(HashMap::new()));

    // Multiple readers
    {
        let r1 = cache.read().unwrap();
        let r2 = cache.read().unwrap(); // concurrent reads OK
        let _ = r1.get("key");
        let _ = r2.get("key");
    }

    // Exclusive writer
    {
        let mut w = cache.write().unwrap();
        w.insert("key".into(), "value".into());
    }
}
```

## Testing

### Unit Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculate_tax_low_bracket() {
        let result = calculate_tax(40_000.0);
        assert_eq!(result, 4_000.0);
    }

    #[test]
    fn test_parse_valid_input() {
        let parsed = parse("42").unwrap();
        assert_eq!(parsed, 42);
    }

    #[test]
    #[should_panic(expected = "division by zero")]
    fn test_divide_by_zero_panics() {
        divide(1, 0);
    }

    // ✅ Good: Result-returning tests use ? operator
    #[test]
    fn test_read_config() -> Result<(), Box<dyn std::error::Error>> {
        let config = parse_config("key = value")?;
        assert_eq!(config.get("key"), Some(&"value".to_string()));
        Ok(())
    }
}
```

### Integration Tests

```
myapp/
  src/
    lib.rs
  tests/            # integration tests (each file is a separate crate)
    api_test.rs
    db_test.rs
```

```rust
// tests/api_test.rs
use myapp::{App, Config};

#[tokio::test]
async fn test_create_user_endpoint() {
    let app = App::new(Config::test()).await;
    let response = app.post("/users").json(&user_data).send().await;
    assert_eq!(response.status(), 201);
}
```

### Property Testing with proptest

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_sort_is_idempotent(ref input in prop::collection::vec(any::<i32>(), 0..100)) {
        let mut sorted = input.clone();
        sorted.sort();
        let mut sorted_again = sorted.clone();
        sorted_again.sort();
        assert_eq!(sorted, sorted_again);
    }

    #[test]
    fn test_parse_roundtrip(n in any::<i32>()) {
        let s = n.to_string();
        let parsed: i32 = s.parse().unwrap();
        assert_eq!(parsed, n);
    }
}
```

### Criterion Benchmarks

```rust
// benches/my_benchmark.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn bench_calculate_tax(c: &mut Criterion) {
    c.bench_function("calculate_tax 120k", |b| {
        b.iter(|| calculate_tax(black_box(120_000.0)))
    });

    c.bench_function("parse 1000 items", |b| {
        let data: Vec<String> = (0..1000).map(|i| format!("item_{i}")).collect();
        b.iter(|| parse_all(black_box(&data)))
    });
}

criterion_group!(benches, bench_calculate_tax);
criterion_main!(benches);
```

## Concurrency

### Channels with crossbeam

```rust
use crossbeam_channel::{bounded, unbounded};

fn pipeline() {
    let (sender, receiver) = bounded::<Job>(100);

    // producer
    crossbeam::scope(|s| {
        s.spawn(|_| {
            for i in 0..1000 {
                sender.send(Job { id: i }).unwrap();
            }
        });

        // consumer
        s.spawn(|_| {
            for job in receiver {
                process(job);
            }
        });
    }).unwrap();
}
```

### Atomics for Lock-Free Counters

```rust
use std::sync::atomic::{AtomicU64, Ordering};

struct Metrics {
    requests: AtomicU64,
    errors: AtomicU64,
}

impl Metrics {
    fn new() -> Self {
        Self {
            requests: AtomicU64::new(0),
            errors: AtomicU64::new(0),
        }
    }

    fn record_request(&self) {
        self.requests.fetch_add(1, Ordering::Relaxed);
    }

    fn record_error(&self) {
        self.errors.fetch_add(1, Ordering::Relaxed);
    }

    fn snapshot(&self) -> (u64, u64) {
        let reqs = self.requests.load(Ordering::Relaxed);
        let errs = self.errors.load(Ordering::Relaxed);
        (reqs, errs)
    }
}
```

### rayon for Data Parallelism

```rust
use rayon::prelude::*;

fn process_all(records: &[Record]) -> Vec<Result<Output, AppError>> {
    records.par_iter()
        .map(|r| process_record(r))
        .collect()
}

fn parallel_sum(data: &[i64]) -> i64 {
    data.par_iter().sum()
}
```

## FFI Patterns

### Calling C with bindgen

```rust
// ❌ Manual -- error-prone
// extern "C" { fn strlen(s: *const i8) -> usize; }

// ✅ Good: Use bindgen to generate bindings automatically
// build.rs
fn main() {
    println!("cargo:rustc-link-lib=cyaml");
    bindgen::Builder::default()
        .header("wrapper.h")
        .parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
        .generate()
        .expect("unable to generate bindings")
        .write_to_file(std::path::PathBuf::from("src/bindings.rs"))
        .unwrap();
}
```

### Unsafe Guidelines

```rust
// ✅ Good: Contain unsafe in small, well-documented modules
/// # Safety
/// `ptr` must point to a valid, null-terminated C string.
unsafe fn c_str_to_rust(ptr: *const std::os::raw::c_char) -> &'static str {
    let bytes = std::ffi::CStr::from_ptr(ptr).to_bytes();
    std::str::from_utf8(bytes).expect("invalid utf8 from C")
}

// ✅ Good: Expose a safe API that wraps the unsafe internals
mod ffi {
    pub fn get_version() -> String {
        // safe wrapper
        unsafe { super::c_str_to_rust(syscall_get_version()) }.to_string()
    }
}
```

## Macro Patterns

### Declarative Macros

```rust
// ✅ Good: Reduce boilerplate with declarative macros
macro_rules! impl_from {
    ($from:ty, $to:ty, $variant:ident) => {
        impl From<$from> for $to {
            fn from(err: $from) -> Self {
                Self::$variant(err)
            }
        }
    };
}

#[derive(Debug)]
enum AppError {
    Io(std::io::Error),
    Parse(std::num::ParseIntError),
}

impl_from!(std::io::Error, AppError, Io);
impl_from!(std::num::ParseIntError, AppError, Parse);

// ✅ Good: vec!-style macro
macro_rules! map {
    ($($key:expr => $value:expr),* $(,)?) => {{
        let mut m = std::collections::HashMap::new();
        $( m.insert($key, $value); )*
        m
    }};
}

let scores = map! {
    "alice" => 95,
    "bob" => 87,
};
```

### Proc Macros (derive)

```rust
// ✅ Good: Derive macro for common trait implementations
// In a separate proc-macro crate
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput};

#[proc_macro_derive(Builder)]
pub fn derive_builder(input: TokenStream) -> TokenStream {
    let input = parse_macro_input!(input as DeriveInput);
    let name = &input.ident;
    let builder_name = format!("{name}Builder");

    let builder_ident = proc_macro2::Ident::new(&builder_name, name.span());

    let expanded = quote! {
        pub struct #builder_ident {
            inner: #name,
        }

        impl #builder_ident {
            pub fn build(self) -> #name {
                self.inner
            }
        }
    };

    TokenStream::from(expanded)
}
```

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Excessive `.clone()` | Hidden allocation overhead | Rethink ownership, use references or Cow |
| `.unwrap()` in production | Panics crash the process | Use `?`, `map_err`, or explicit match |
| Arc Mutex everywhere | Overhead and potential deadlocks | Prefer message passing with channels |
| Large unsafe blocks | Undefined behavior risk | Minimize unsafe scope, document safety invariants |
| Trait objects for everything | Runtime dispatch overhead | Use generics where types are known at compile time |
| Ignoring Clippy warnings | Missed correctness/performance issues | Run clippy in CI and address warnings |
| Deref inheritance anti-pattern | Confusing API, breaks encapsulation | Use composition and explicit delegation methods |

## Coaching Notes

> **ABC -- Always Be Coaching:** Rust's borrow checker is not your enemy -- it is the compiler forcing you to think about ownership before the bug reaches production. Once the patterns click, you write code that is simultaneously safer and faster.

1. **Design data structures around ownership first:** Before writing a single method, decide who owns each piece of data. If two parts of the system need mutable access, you need either a single owner with borrowed access, interior mutability (RefCell/Mutex), or shared ownership (Rc/Arc). Getting this right early prevents painful refactors.

2. **Embrace the type system to make illegal states unrepresentable:** Use enums instead of nullable fields, newtypes instead of raw strings, and Result instead of exceptions. If the code compiles, a whole class of bugs cannot exist at runtime.

3. **Use the smallest synchronization primitive that works:** Start with ownership and references. Move to channels for message passing. Only reach for Mutex or RwLock when shared mutable state is truly needed. Atomic operations beat locks for simple counters. Every lock you avoid is a deadlock you will never debug at 3 AM.

## Verification Checklist

After applying Rust patterns:

- [ ] Ownership is clear: each value has a single owner or shared via Rc/Arc
- [ ] Lifetimes are annotated where the compiler cannot infer them
- [ ] Errors use thiserror (libraries) or anyhow (applications) with contextual messages
- [ ] No `.unwrap()` or `.expect()` in production code paths (tests are fine)
- [ ] Traits use associated types when there is a unique type per impl
- [ ] Async code uses tokio::select! for cancellation and graceful shutdown
- [ ] Iterators replace manual loops for data transformations
- [ ] Smart pointers chosen correctly (Box for heap, Rc for single-thread, Arc for multi-thread)
- [ ] Unit tests, integration tests, and property tests cover critical paths
- [ ] Criterion benchmarks validate performance claims
- [ ] Unsafe blocks are minimal, documented, and wrapped in safe APIs
- [ ] Clippy passes with no warnings in CI

## Related Skills

- **backend-patterns** -- Service layer, repository pattern, caching
- **api-interface-design** -- Contract-first API design
- **test-driven-development** -- RED-GREEN-REFACTOR cycle
- **performance-optimization** -- Profiling and measurement methodology
- **security-hardening** -- OWASP for Rust HTTP services

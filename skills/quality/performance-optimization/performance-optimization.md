---
name: performance-optimization
description: Performance optimization using measure-first approach. Use when applications are slow, when optimizing rendering, or when improving load times.
version: "2.0.0"
category: "quality"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["performance", "slow", "optimize", "web vitals"]
intent: "Deliver measurable, user-perceptible speed improvements driven by data rather than guesswork."
scenarios:
  - "Diagnosing why a dashboard page takes 8 seconds to load and reducing it to under 2 seconds"
  - "Improving Core Web Vitals scores on a landing page to meet Google's 'good' thresholds"
  - "Eliminating janky scroll performance in a long product list by implementing virtual scrolling"
best_for: "page load optimization, rendering performance, Core Web Vitals improvement, memory leak detection"
estimated_time: "20-45 min"
anti_patterns:
  - "Optimizing code without measuring first -- guessing at bottlenecks wastes time on non-issues"
  - "Micro-optimizing a function that runs once while ignoring a query that runs 1000 times per page load"
  - "Making code harder to read for a negligible performance gain that no user will notice"
related_skills: ["code-simplification", "browser-testing", "e2e-testing"]
---

# Performance Optimization

## Overview

Performance optimization uses a measure-first approach — measure before optimizing, identify bottlenecks, and optimize based on data. The goal is to make measurable improvements that users can perceive.

## When to Use

- Applications feel slow
- Load times are long
- Rendering is janky
- Memory usage is high
- Before deploying to production

## The Measure-First Approach

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. Measure ──→ 2. Identify ──→ 3. Optimize ──→ 4. Verify│
│     (Baseline)     (Bottleneck)      (Fix)        (Compare)│
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Step 1: Measure

Establish performance baseline:

```typescript
// ✅ Good: Measure before optimizing
import { performance } from 'perf_hooks';

function measurePerformance() {
  const start = performance.now();

  // Code to measure
  const result = expensiveOperation();

  const end = performance.now();
  console.log(`Operation took ${end - start}ms`);

  return result;
}

// Or use performance.mark
performance.mark('operation-start');
expensiveOperation();
performance.mark('operation-end');
performance.measure('operation', 'operation-start', 'operation-end');

const measure = performance.getEntriesByName('operation')[0];
console.log(`Duration: ${measure.duration}ms`);
```

### Step 2: Identify

Find the bottleneck:

```typescript
// ✅ Good: Profile to find bottlenecks
console.profile('expensiveOperation');

expensiveOperation();

console.profileEnd();

// Check browser DevTools Profiles
// Look for:
// - Long-running functions
// - Memory allocations
// - Frequent garbage collection
```

### Step 3: Optimize

Fix the bottleneck:

```typescript
// ❌ Bad: Unoptimized
function sumArray(numbers: number[]): number {
  let sum = 0;
  for (let i = 0; i < numbers.length; i++) {
    sum += numbers[i];
  }
  return sum;
}

// ✅ Good: Optimized
function sumArray(numbers: number[]): number {
  return numbers.reduce((sum, num) => sum + num, 0);
}

// ✅ Better: Use TypedArray for large numeric arrays
function sumLargeArray(numbers: number[]): number {
  const typed = new Float64Array(numbers);
  let sum = 0;
  for (let i = 0; i < typed.length; i++) {
    sum += typed[i];
  }
  return sum;
}
```

### Step 4: Verify

Compare before and after:

```typescript
// ✅ Good: Verify improvement
const before = benchmark(() => expensiveOperation());
const after = benchmark(() => optimizedOperation());

console.log(`Before: ${before}ms`);
console.log(`After: ${after}ms`);
console.log(`Improvement: ${((before - after) / before * 100).toFixed(2)}%`);
```

## Optimization Techniques

### 1. Memoization

Cache expensive computations:

```typescript
// ❌ Bad: Recalculates every time
function fibonacci(n: number): number {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

// ✅ Good: Memoized
function memoize<Args extends unknown[], Result>(
  fn: (...args: Args) => Result
): (...args: Args) => Result {
  const cache = new Map<string, Result>();

  return (...args: Args): Result => {
    const key = JSON.stringify(args);
    if (cache.has(key)) {
      return cache.get(key)!;
    }

    const result = fn(...args);
    cache.set(key, result);
    return result;
  };
}

const memoizedFibonacci = memoize(fibonacci);
```

### 2. Debouncing and Throttling

Rate-limit expensive operations:

```typescript
// ✅ Good: Debounce search
function debounce<T extends (...args: any[]) => any>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => void {
  let timeoutId: NodeJS.Timeout;

  return (...args: Parameters<T>) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

const debouncedSearch = debounce((query: string) => {
  fetch(`/api/search?q=${query}`);
}, 300);

// ✅ Good: Throttle scroll events
function throttle<T extends (...args: any[]) => any>(
  fn: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean;

  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      fn(...args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
}

const throttledScroll = throttle(() => {
  updateScrollPosition();
}, 100);
```

### 3. Lazy Loading

Load resources on demand:

```typescript
// ✅ Good: Lazy load components
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <HeavyComponent />
    </Suspense>
  );
}

// ✅ Good: Lazy load images
function LazyImage({ src, alt }: { src: string; alt: string }) {
  const [imageSrc, setImageSrc] = useState<string | undefined>();

  useEffect(() => {
    const img = new Image();
    img.onload = () => setImageSrc(src);
    img.src = src;
  }, [src]);

  return imageSrc ? <img src={imageSrc} alt={alt} /> : <Spinner />;
}
```

### 4. Code Splitting

Split code into chunks:

```typescript
// ✅ Good: Route-based code splitting
import { lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';

const Home = lazy(() => import('./pages/Home'));
const About = lazy(() => import('./pages/About'));
const Contact = lazy(() => import('./pages/Contact'));

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
        <Route path="/contact" element={<Contact />} />
      </Routes>
    </Suspense>
  );
}
```

### 5. Virtual Scrolling

Render only visible items:

```typescript
// ✅ Good: Virtual scrolling for large lists
import { FixedSizeList } from 'react-window';

function VirtualList({ items }: { items: Item[] }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>{items[index].name}</div>
      )}
    </FixedSizeList>
  );
}
```

### 6. Optimizing Renders

Prevent unnecessary re-renders:

```typescript
// ❌ Bad: Unnecessary re-renders
function ExpensiveComponent({ items }: { items: Item[] }) {
  return (
    <div>
      {items.map(item => (
        <div key={item.id}>{expensiveCalculation(item)}</div>
      ))}
    </div>
  );
}

// ✅ Good: Memoized
const ExpensiveComponent = memo(function ExpensiveComponent({
  items
}: {
  items: Item[];
}) {
  return (
    <div>
      {items.map(item => (
        <MemoizedItem key={item.id} item={item} />
      ))}
    </div>
  );
});

const MemoizedItem = memo(function Item({ item }: { item: Item }) {
  const calculated = useMemo(
    () => expensiveCalculation(item),
    [item.id] // Only recalculate when id changes
  );

  return <div>{calculated}</div>;
});
```

## Performance Metrics

### Web Vitals

Track Core Web Vitals:

```typescript
// ✅ Good: Track Web Vitals
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

getCLS(console.log);
getFID(console.log);
getFCP(console.log);
getLCP(console.log);
getTTFB(console.log);

// Targets:
// LCP (Largest Contentful Paint): < 2.5s
// FID (First Input Delay): < 100ms
// CLS (Cumulative Layout Shift): < 0.1
// FCP (First Contentful Paint): < 1.8s
// TTFB (Time to First Byte): < 800ms
```

### Custom Metrics

Track custom performance metrics:

```typescript
// ✅ Good: Custom performance tracking
function trackPerformance(name: string, fn: () => void) {
  const start = performance.now();
  fn();
  const end = performance.now();

  // Send to analytics
  analytics.track('performance', {
    name,
    duration: end - start
  });
}

// Usage
trackPerformance('user_login', () => {
  performLogin();
});
```

## Coaching Notes

> **ABC - Always Be Coaching:** Performance work without measurement is storytelling -- always measure first, optimize second, and verify third.

1. **Measure Before You Touch Anything:** Establish a baseline before changing a single line. If you cannot quantify how slow something is, you cannot prove your fix made it faster. Numbers, not feelings.
2. **Chase the Biggest Bottleneck First:** One slow database query or one unoptimized image often accounts for 80% of the delay. Find that one thing before you spend time memoizing functions that already run in microseconds.
3. **Perceived Performance Is Real Performance:** A skeleton screen that loads in 100ms feels faster than a blank white page that loads content in 300ms. Optimize what the user experiences, not just what the profiler reports.

## Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Premature optimization | Wasted effort | Measure first |
| Optimizing without data | Wrong focus | Profile to find bottlenecks |
| Micro-optimizations | Minimal impact | Focus on big wins |
| Ignoring perceived performance | Users still unhappy | Optimize perceived performance |
| Forgetting to verify | No improvement | Verify improvements |

## Performance Checklist

After optimization:

- [ ] Performance measured before and after
- [ ] Bottlenecks identified
- [ ] Optimizations applied
- [ ] Improvements verified
- [ ] Web Vitals within targets
- [ ] No regressions introduced
- [ ] Code is still maintainable

## Verification

After performance optimization:

- [ ] Baseline metrics established
- [ ] Bottlenecks identified
- [ ] Optimizations implemented
- [ ] Improvements measured
- [ ] Web Vitals improved
- [ ] No functionality broken
- [ ] Code remains maintainable

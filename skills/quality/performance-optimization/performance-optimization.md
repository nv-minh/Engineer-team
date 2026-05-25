---
name: performance-optimization
description: Performance optimization using measure-first approach. Use when applications are slow, when optimizing rendering, or when improving load times.
version: "3.0.0"
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
input_schema:
  type: object
  required: [target]
  properties:
    target: { type: string, description: "Component, endpoint, or page to optimize" }
    metrics: { type: array, items: { type: string }, description: "Metrics to measure" }
output_schema:
  type: object
  required: [status, optimizations]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    optimizations: { type: array, items: { type: object, properties: { target: { type: string }, before: { type: string }, after: { type: string }, improvement: { type: string } } } }
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

# Performance Optimization

[ROLE]
You are a performance optimization engineer. Deliver measurable, user-perceptible speed improvements driven by data rather than guesswork.

[OBJECTIVE]
Establish performance baselines, identify the biggest bottleneck, apply targeted optimizations, and verify measurable improvement with before/after numbers.

[RULES]
1. <thought>Before touching any code, establish a performance baseline. If you cannot quantify how slow something is, you cannot prove your fix made it faster.</thought>
2. Measure before you optimize. Numbers, not feelings.
3. Chase the biggest bottleneck first. One slow database query often accounts for 80% of the delay. Find that one thing before memoizing functions that run in microseconds.
4. Perceived performance is real performance. A skeleton screen at 100ms feels faster than a blank page at 300ms. Optimize what users experience.
5. DO NOT optimize without data. Profile to find bottlenecks first.
6. DO NOT micro-optimize functions that run once while ignoring queries that run 1000 times per page load.
7. DO NOT sacrifice readability for negligible performance gains.
8. Always verify improvements with before/after measurements.
9. Every interaction should teach something: explain why an optimization matters, not just what changed.

[PROCESS]

### Step 1: Measure Baseline

```typescript
performance.mark('operation-start');
expensiveOperation();
performance.mark('operation-end');
performance.measure('operation', 'operation-start', 'operation-end');
const measure = performance.getEntriesByName('operation')[0];
console.log(`Duration: ${measure.duration}ms`);
```

### Step 2: Identify Bottlenecks
Profile using browser DevTools or Node.js profiler. Look for:
- Long-running functions
- Excessive memory allocations
- Frequent garbage collection
- N+1 query patterns
- Unoptimized images or assets

### Step 3: Apply Targeted Optimizations

Select the appropriate technique for the bottleneck:

| Technique | When to Use |
|---|---|
| **Memoization** | Pure functions called repeatedly with same inputs |
| **Debouncing** | User input triggering expensive operations (search, resize) |
| **Throttling** | High-frequency events (scroll, mousemove) |
| **Lazy Loading** | Components/images not visible on initial load |
| **Code Splitting** | Route-based or feature-based bundle separation |
| **Virtual Scrolling** | Lists with 100+ items |
| **React.memo/useMemo** | Components re-rendering with unchanged props |

### Step 4: Track Web Vitals

```typescript
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

// Targets:
// LCP (Largest Contentful Paint): < 2.5s
// FID (First Input Delay): < 100ms
// CLS (Cumulative Layout Shift): < 0.1
// FCP (First Contentful Paint): < 1.8s
// TTFB (Time to First Byte): < 800ms
```

### Step 5: Verify Improvement

```typescript
const before = benchmark(() => expensiveOperation());
const after = benchmark(() => optimizedOperation());
console.log(`Improvement: ${((before - after) / before * 100).toFixed(2)}%`);
```

[RESPONSE FORMAT]
Return results matching output_schema: `{ status, optimizations: [{ target, before, after, improvement }] }`.

[VERIFICATION]
- [ ] Baseline metrics established before any changes
- [ ] Bottlenecks identified via profiling (not guessing)
- [ ] Optimizations applied to the biggest bottleneck first
- [ ] Improvements measured with before/after numbers
- [ ] Web Vitals within target thresholds
- [ ] No functionality broken
- [ ] Code remains maintainable and readable

---
name: react-hooks
description: >
  React Hooks patterns covering useState, useEffect, useCallback, useMemo,
  useRef, useContext, useReducer, and custom hooks. Use when implementing
  hook-based state logic, managing side effects, or creating reusable hooks.
version: "1.0.0"
category: "expert-react"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "react hooks"
  - "useEffect"
  - "useState"
  - "useReducer"
  - "custom hook"
  - "useCallback"
  - "useMemo"
  - "useRef"
intent: >
  Master React hooks for stateful logic, side effects, and memoization
  so components remain clean, predictable, and performant.
scenarios:
  - "Building a data-fetching hook with loading/error states and cancellation"
  - "Managing complex form state with useReducer instead of multiple useState calls"
  - "Creating a reusable useDebounce or useToggle custom hook"
best_for: "React hooks, stateful logic extraction, side effect management"
estimated_time: "15-30 min"
anti_patterns:
  - "Calling hooks inside conditions, loops, or nested functions"
  - "Missing dependencies in useEffect arrays causing stale closures"
  - "Using useMemo/useCallback everywhere without measurable benefit"
related_skills: ["react", "redux", "frontend-patterns", "typescript-patterns"]
---

# React Hooks

## Overview

Hooks let functional components manage state, side effects, and reusable logic. This skill covers the built-in hooks and the patterns for composing them into custom hooks.

## When to Use

- Managing component state (useState, useReducer)
- Handling side effects like data fetching and subscriptions (useEffect)
- Optimizing performance with memoization (useMemo, useCallback)
- Sharing stateful logic across components via custom hooks

## When NOT to Use

- For class component lifecycle methods -- refactor to functional components instead
- For global state management -- use Redux or Zustand for cross-component state
- For server state -- use React Query or SWR instead of hand-rolled fetch hooks

## Rules of Hooks (Non-Negotiable)

1. **Only call hooks at the top level** -- never inside conditions, loops, or nested functions
2. **Only call hooks from React functions** -- components or custom hooks
3. **Name custom hooks with `use` prefix** -- `useAuth`, `useFetch`, `useToggle`
4. **Exhaust dependency arrays** -- use `react-hooks/exhaustive-deps` ESLint rule

## Core Hooks

### useState

```typescript
const [value, setValue] = useState<string>('');
// Use updater function for derived state to avoid stale closures
setCount(prev => prev + 1);
```

### useEffect

```typescript
// Data fetching with cancellation
useEffect(() => {
  const controller = new AbortController();
  setLoading(true);

  fetch(`/api/users/${userId}`, { signal: controller.signal })
    .then(res => res.json())
    .then(data => { setData(data); setLoading(false); })
    .catch(err => {
      if (err.name !== 'AbortError') { setError(err); setLoading(false); }
    });

  return () => controller.abort(); // Always clean up
}, [userId]); // Include all dependencies
```

### useReducer (Complex State)

```typescript
type State = { count: number; step: number };
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setStep'; payload: number };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment': return { ...state, count: state.count + state.step };
    case 'decrement': return { ...state, count: state.count - state.step };
    case 'setStep':   return { ...state, step: action.payload };
  }
}

const [state, dispatch] = useReducer(reducer, { count: 0, step: 1 });
```

### useMemo and useCallback

```typescript
// Memoize expensive computation
const filtered = useMemo(() => items.filter(i => i.name.includes(filter)), [items, filter]);

// Memoize callback to prevent child re-renders
const handleSelect = useCallback((id: string) => {
  console.log('Selected:', id);
}, []);
```

### useRef

```typescript
// DOM reference
const inputRef = useRef<HTMLInputElement>(null);
inputRef.current?.focus();

// Mutable value that persists across renders (no re-render on change)
const timerRef = useRef<number>(0);
```

## Custom Hook Patterns

### Data Fetching Hook

```typescript
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    fetch(url, { signal: controller.signal })
      .then(res => res.json())
      .then(d => { setData(d); setLoading(false); })
      .catch(e => { if (!controller.signal.aborted) { setError(e); setLoading(false); } });
    return () => controller.abort();
  }, [url]);

  return { data, loading, error };
}
```

### Toggle Hook

```typescript
function useToggle(initial = false): [boolean, () => void] {
  const [value, setValue] = useState(initial);
  const toggle = useCallback(() => setValue(v => !v), []);
  return [value, toggle];
}
```

### Debounce Hook

```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  return debounced;
}
```

## Hook Selection Guide

| Need | Hook |
|---|---|
| Simple primitive state | `useState` |
| Complex/related state | `useReducer` |
| Side effects (fetch, subscribe) | `useEffect` |
| Expensive computation | `useMemo` |
| Stable callback reference | `useCallback` |
| DOM access or mutable ref | `useRef` |
| Shared context value | `useContext` |
| Reusable stateful logic | Custom hook |

## Coaching Notes

- **The dependency array is your contract** -- missing dependencies cause stale closures that are extremely hard to debug. Always use the ESLint plugin.
- **Cleanup is not optional** -- every subscription, timer, or fetch in useEffect needs cleanup. Without it, you get memory leaks and state updates on unmounted components.
- **useReducer over multiple useState** -- when state values are related and transitions follow a pattern, useReducer makes the logic explicit and testable.

## Verification

- [ ] No hooks called inside conditions, loops, or nested functions
- [ ] All useEffect dependency arrays are exhaustive
- [ ] Side effects have cleanup functions
- [ ] Custom hooks are named with `use` prefix
- [ ] Memoization hooks are used only where profiling shows benefit
- [ ] No stale closure bugs in async operations

## Related Skills

- **react** -- Component patterns, Context API, and performance optimization
- **redux** -- Global state management with Redux Toolkit
- **frontend-patterns** -- Broader UI patterns (forms, data fetching)
- **typescript-patterns** -- TypeScript patterns for React hooks

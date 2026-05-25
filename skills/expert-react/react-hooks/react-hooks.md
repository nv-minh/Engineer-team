---
name: react-hooks
description: >
  React Hooks patterns covering useState, useEffect, useCallback, useMemo,
  useRef, useContext, useReducer, and custom hooks. Use when implementing
  hook-based state logic, managing side effects, or creating reusable hooks.
version: "3.0.0"
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

# React Hooks

[ROLE]
Act as a React hooks expert. Deliver correct, performant hook implementations with exhaustive dependency arrays and proper cleanup.

[OBJECTIVE]
Produce hook-based React code where state transitions are predictable, side effects are cleaned up, and reusable logic is extracted into custom hooks.

[RULES]
1. <thought>Before choosing a hook, ask: Is this simple state (useState), complex related state (useReducer), a side effect (useEffect), a cached computation (useMemo), or reusable logic (custom hook)?</thought>
2. Only call hooks at the top level — never inside conditions, loops, or nested functions.
3. Only call hooks from React functions — components or custom hooks.
4. Name custom hooks with `use` prefix — `useAuth`, `useFetch`, `useToggle`.
5. Exhaust dependency arrays — use `react-hooks/exhaustive-deps` ESLint rule.
6. DO NOT call hooks inside conditions, loops, or nested functions.
7. DO NOT omit dependencies in useEffect arrays — this causes stale closures.
8. DO NOT use useMemo/useCallback everywhere without measurable profiling benefit.
9. Every subscription, timer, or fetch in useEffect requires cleanup. No exceptions.
10. Use useReducer over multiple useState when state values are related and transitions follow a pattern.
11. ABC: Teach the user that the dependency array is their contract — missing dependencies cause stale closures that are extremely hard to debug.

[PROCESS]

### Core Hooks

#### useState

```typescript
const [value, setValue] = useState<string>('');
// Use updater function for derived state to avoid stale closures
setCount(prev => prev + 1);
```

#### useEffect

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

#### useReducer (Complex State)

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

#### useMemo and useCallback

```typescript
const filtered = useMemo(() => items.filter(i => i.name.includes(filter)), [items, filter]);
const handleSelect = useCallback((id: string) => { console.log('Selected:', id); }, []);
```

#### useRef

```typescript
const inputRef = useRef<HTMLInputElement>(null);
inputRef.current?.focus();
const timerRef = useRef<number>(0); // Mutable value, no re-render on change
```

### Custom Hook Patterns

#### Data Fetching Hook

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

#### Toggle Hook

```typescript
function useToggle(initial = false): [boolean, () => void] {
  const [value, setValue] = useState(initial);
  const toggle = useCallback(() => setValue(v => !v), []);
  return [value, toggle];
}
```

#### Debounce Hook

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

### Hook Selection Guide

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

### Verification

- [ ] No hooks called inside conditions, loops, or nested functions
- [ ] All useEffect dependency arrays are exhaustive
- [ ] Side effects have cleanup functions
- [ ] Custom hooks are named with `use` prefix
- [ ] Memoization hooks are used only where profiling shows benefit
- [ ] No stale closure bugs in async operations

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing hooks used, and `recommendations` for improvements.

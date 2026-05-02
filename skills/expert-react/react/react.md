---
name: react
description: >
  React fundamentals and expert patterns for components, JSX, state management,
  Context API, and performance optimization. Use when building React components,
  managing component state, implementing Context, or optimizing rendering performance.
version: "1.0.0"
category: "expert-react"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "react component"
  - "react state management"
  - "react context"
  - "react performance"
  - "jsx patterns"
  - "react memo"
intent: >
  Deliver idiomatic React code using functional components, hooks, and
  performance best practices so UIs remain predictable and fast.
scenarios:
  - "Building a data-driven dashboard with composable React components"
  - "Implementing theme switching with Context API and lazy-loaded routes"
  - "Optimizing a large list view with React.memo, useMemo, and code splitting"
best_for: "React components, state, Context API, performance optimization"
estimated_time: "15-30 min"
anti_patterns:
  - "Creating class components when functional components with hooks suffice"
  - "Storing server state in useState instead of a caching library"
  - "Inline object/function creation in JSX causing unnecessary re-renders"
related_skills: ["react-hooks", "nextjs", "redux", "frontend-patterns", "typescript-patterns"]
---

# React Fundamentals

## Overview

React development centers on functional components, declarative JSX, unidirectional data flow, and the hooks API. This skill covers the core patterns for building, composing, and optimizing React components.

## When to Use

- Creating new React components or refactoring class components to functional
- Managing local or shared state with Context API
- Optimizing rendering with memoization (React.memo, useMemo, useCallback)
- Setting up code splitting with React.lazy and Suspense

## When NOT to Use

- For Next.js-specific concerns (App Router, SSR/SSG) -- use the `nextjs` skill
- For complex global state -- use the `redux` skill
- For hook-specific patterns -- use the `react-hooks` skill

## Process

### Step 1: Define Component Interface

Design props with TypeScript first:

```typescript
interface UserCardProps {
  name: string;
  email: string;
  avatar?: string;
  onSelect: (userId: string) => void;
}
```

### Step 2: Build Functional Component

```typescript
export function UserCard({ name, email, avatar, onSelect }: UserCardProps) {
  return (
    <div className="user-card" onClick={() => onSelect(name)}>
      {avatar && <img src={avatar} alt={name} />}
      <h3>{name}</h3>
      <p>{email}</p>
    </div>
  );
}
```

### Step 3: Manage State Locally or Lift

```typescript
// Local state for UI-only concerns
const [isOpen, setIsOpen] = useState(false);

// Lift state to nearest common ancestor for shared state
function Parent() {
  const [selected, setSelected] = useState<string | null>(null);
  return (
    <>
      <ChildA selected={selected} />
      <ChildB onSelect={setSelected} />
    </>
  );
}
```

### Step 4: Share State with Context (When Needed)

```typescript
const ThemeContext = createContext<{ dark: boolean; toggle: () => void } | null>(null);

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [dark, setDark] = useState(false);
  const toggle = useCallback(() => setDark(d => !d), []);
  return <ThemeContext.Provider value={{ dark, toggle }}>{children}</ThemeContext.Provider>;
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
  return ctx;
}
```

### Step 5: Optimize Performance

```typescript
// Memoize expensive components
const ExpensiveList = React.memo(function ExpensiveList({ items }: { items: Item[] }) {
  return <ul>{items.map(item => <li key={item.id}>{item.name}</li>)}</ul>;
});

// Memoize expensive computations
const filtered = useMemo(() => items.filter(i => i.active), [items]);

// Memoize callbacks passed to children
const handleClick = useCallback((id: string) => select(id), [select]);

// Code-split routes
const Dashboard = React.lazy(() => import('./pages/Dashboard'));
```

## Best Practices

1. **One component, one responsibility** -- split when a component does more than one visual thing
2. **Always use stable keys** in lists -- never use array index for dynamic lists
3. **Clean up side effects** in useEffect return functions (subscriptions, timers, abort controllers)
4. **Prefer composition** over props-driven conditional rendering
5. **Use React.lazy + Suspense** for route-level code splitting
6. **Avoid inline objects/functions in JSX** -- extract to useMemo/useCallback or constants

## Performance Decision Guide

| Situation | Technique |
|---|---|
| Child re-renders with same props | `React.memo` |
| Expensive computation in render | `useMemo` |
| Callback passed to memoized child | `useCallback` |
| Large route not needed immediately | `React.lazy` + `Suspense` |
| Large list (>1000 items) | Virtual scrolling (react-window) |

## Coaching Notes

- **Memoization is not free** -- only use React.memo, useMemo, useCallback when profiling shows a measurable benefit. Premature memoization adds complexity without payoff.
- **Context is not a global store** -- it triggers re-renders on all consumers when the value changes. For high-frequency updates across many consumers, use Redux or Zustand instead.
- **Server state != client state** -- API responses belong in React Query or SWR, not useState. They handle caching, revalidation, and optimistic updates automatically.

## Verification

- [ ] Components are functional with TypeScript interfaces
- [ ] State is lifted to the appropriate level (local vs Context vs external store)
- [ ] Side effects have cleanup functions
- [ ] List items use stable keys
- [ ] Performance optimizations are applied where profiling shows need
- [ ] Code splitting is used for route-level components

## Related Skills

- **react-hooks** -- Deep dive into useState, useEffect, useReducer, and custom hooks
- **nextjs** -- Next.js App Router, SSR/SSG/ISR, and deployment
- **redux** -- Redux Toolkit for complex global state
- **frontend-patterns** -- Broader UI patterns (forms, data fetching, accessibility)
- **typescript-patterns** -- TypeScript patterns for React applications

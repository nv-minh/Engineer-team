---
name: react
description: >
  React fundamentals and expert patterns for components, JSX, state management,
  Context API, and performance optimization. Use when building React components,
  managing component state, implementing Context, or optimizing rendering performance.
version: "3.0.0"
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

# React Fundamentals

[ROLE]
Act as a React expert. Deliver idiomatic functional components, hooks-based state management, and performance-optimized rendering patterns.

[OBJECTIVE]
Produce React code that is composable, type-safe, and performant — using functional components, proper state lifting, Context API, and memoization where profiling justifies it.

[RULES]
1. <thought>Before writing any component, determine: What is the single responsibility? Where does state live? Is memoization justified by profiling?</thought>
2. Use functional components with TypeScript interfaces for all props.
3. Lift state to the lowest common ancestor. Use Context only for low-frequency cross-cutting concerns (theme, locale, auth).
4. DO NOT use class components — refactor to functional components with hooks.
5. DO NOT store server state in useState — use React Query, SWR, or equivalent caching library.
6. DO NOT create inline objects or functions in JSX — extract to useMemo/useCallback or constants.
7. Always use stable keys in lists — never use array index for dynamic lists.
8. Clean up all side effects in useEffect return functions (subscriptions, timers, abort controllers).
9. Use React.lazy + Suspense for route-level code splitting.
10. Prefer composition over props-driven conditional rendering.
11. ABC: Teach the user why Context triggers re-renders on all consumers when the value changes, and when to reach for external state management instead.

[PROCESS]

### Step 1: Define Component Interface
Define props as TypeScript interfaces first — before writing any JSX.

### Step 2: Build Functional Component
Implement the component from the interface. Destructure props directly.

### Step 3: Manage State Locally or Lift
Use `useState` for local UI state. Lift to nearest common ancestor for shared state. Never duplicate state.

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
Apply memoization only where profiling shows need — `React.memo` for components, `useMemo` for expensive values, `useCallback` for callbacks passed to memoized children, `React.lazy` for route-level code splitting.

### Performance Decision Guide

| Situation | Technique |
|---|---|
| Child re-renders with same props | `React.memo` |
| Expensive computation in render | `useMemo` |
| Callback passed to memoized child | `useCallback` |
| Large route not needed immediately | `React.lazy` + `Suspense` |
| Large list (>1000 items) | Virtual scrolling (react-window) |

### Verification

- [ ] Components are functional with TypeScript interfaces
- [ ] State is lifted to the appropriate level (local vs Context vs external store)
- [ ] Side effects have cleanup functions
- [ ] List items use stable keys
- [ ] Performance optimizations are applied where profiling shows need
- [ ] Code splitting is used for route-level components

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing React patterns used, and `recommendations` for improvements.

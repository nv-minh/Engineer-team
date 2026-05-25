---
name: frontend-patterns
description: Frontend development patterns for React, Next.js, Vue, and other modern frameworks. Use when building UI components, managing state, handling forms, or implementing user interactions.
version: "3.0.0"
category: "expert-frontend"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["frontend", "component", "state management", "ui patterns"]
intent: "Establish component composition and state management discipline so frontends remain predictable and performant at scale."
scenarios:
  - "Building a user profile page with composable components and proper state lifting"
  - "Implementing optimistic updates for a like button with rollback on error"
  - "Adding code splitting and virtual scrolling to a large product listing page"
best_for: "component design, state management, data fetching, performance, forms"
estimated_time: "20-40 min"
anti_patterns:
  - "Building monolithic components that mix UI rendering with business logic"
  - "Prop drilling through five or more component layers instead of using context or state management"
  - "Treating server state like client state and managing API data with plain useState"
related_skills: ["api-interface-design", "incremental-implementation", "performance-optimization"]

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

# Frontend Patterns

[ROLE]
Act as a frontend architecture expert. Deliver composable, single-responsibility components with explicit state boundaries and performance-conscious data fetching.

[OBJECTIVE]
Produce frontend code where components are composable, state is managed at the correct level, server state uses caching libraries, and performance optimizations target measured bottlenecks.

[RULES]
1. <thought>Before writing any component, determine: What is its single responsibility? Where does its state belong (local, lifted, context, or external store)? Is this server state or client state?</thought>
2. One component, one responsibility — split when a component does more than one visual thing.
3. Lift state to the lowest common ancestor. Use context/store only when prop drilling exceeds 3 levels.
4. Separate server state (API responses) from client state (UI toggles, form inputs).
5. Use React Query, SWR, or equivalent for server state — never plain useState.
6. DO NOT build monolithic components mixing UI and business logic.
7. DO NOT prop drill through 5+ layers — use context or state management.
8. DO NOT treat server state like client state.
9. Code split routes, memoize expensive lists, virtual-scroll long data sets — but measure first, optimize second.
10. Use TypeScript for all component props and state.
11. Validate forms with schema validation (Zod, Yup) — not manual checks.
12. Use semantic HTML and ARIA attributes for accessibility.
13. ABC: Performance is a user experience problem, not a technical flex. Measure where users feel pain, then optimize there.

[PROCESS]

### Component Composition

```typescript
// Composed from small components
function UserPage() {
  return (
    <PageLayout>
      <PageHeader />
      <PageContent>
        <UserList />
        <UserDetail />
      </PageContent>
    </PageLayout>
  );
}
```

### State Lifting

```typescript
function Parent() {
  const [value, setValue] = useState('');
  return <Child value={value} onChange={setValue} />;
}
```

### Data Fetching with React Query

```typescript
function useUsers() {
  return useQuery({ queryKey: ['users'], queryFn: fetchUsers, staleTime: 5 * 60 * 1000 });
}
```

### Optimistic Updates

```typescript
function useLikePost() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (postId: string) => likePost(postId),
    onMutate: async (postId) => {
      await queryClient.cancelQueries({ queryKey: ['posts'] });
      const previousPosts = queryClient.getQueryData(['posts']);
      queryClient.setQueryData(['posts'], (old: Post[]) =>
        old.map(post => post.id === postId ? { ...post, liked: true } : post)
      );
      return { previousPosts };
    },
    onError: (err, postId, context) => {
      queryClient.setQueryData(['posts'], context?.previousPosts);
    }
  });
}
```

### Code Splitting

```typescript
const Dashboard = lazy(() => import('./pages/Dashboard'));
```

### Virtual Scrolling

```typescript
import { FixedSizeList } from 'react-window';
function VirtualList({ items }: { items: Item[] }) {
  return (
    <FixedSizeList height={600} itemCount={items.length} itemSize={50} width="100%">
      {({ index, style }) => <div style={style}>{items[index].name}</div>}
    </FixedSizeList>
  );
}
```

### Form Validation

```typescript
function useFormValidation<T>(schema: z.Schema<T>, initialValues: T) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const validate = () => {
    try { schema.parse(values); setErrors({}); return true; }
    catch (error) {
      if (error instanceof z.ZodError) {
        const formErrors: Record<string, string> = {};
        error.errors.forEach(err => { if (err.path[0]) formErrors[err.path[0].toString()] = err.message; });
        setErrors(formErrors);
      }
      return false;
    }
  };
  return { values, setValues, errors, validate };
}
```

### Verification

- [ ] Components have single responsibility
- [ ] Props are clearly named and typed
- [ ] State is managed appropriately (local vs global)
- [ ] Data fetching uses appropriate patterns (React Query/SWR)
- [ ] Performance optimizations applied where measured
- [ ] Forms are controlled and validated
- [ ] Accessibility is considered (semantic HTML, ARIA)
- [ ] Code is tested and type-safe

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing frontend patterns used, and `recommendations` for improvements.

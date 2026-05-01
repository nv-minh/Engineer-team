---
name: frontend-patterns
description: Frontend development patterns for React, Next.js, Vue, and other modern frameworks. Use when building UI components, managing state, handling forms, or implementing user interactions.
version: "2.0.0"
category: "development"
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
---

# Frontend Patterns

## Overview

Modern frontend development follows established patterns for component design, state management, data fetching, and user interactions. These patterns ensure maintainable, performant, and scalable frontend code.

## When to Use

- Building UI components
- Managing application state
- Handling forms and user input
- Implementing routing and navigation
- Optimizing performance
- Integrating with APIs

## Component Patterns

### Component Composition

Build complex UIs from simple, reusable components:

```typescript
// ❌ Bad: Monolithic component
function UserPage() {
  return (
    <div>
      <Header />
      <Sidebar />
      <UserList />
      <UserDetail />
      <Footer />
    </div>
  );
}

// ✅ Good: Composed from small components
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

### Component Responsibilities

Each component should have one clear responsibility:

```typescript
// ✅ Good: Single responsibility
function UserAvatar({ src, alt, size }: AvatarProps) {
  return <img src={src} alt={alt} className={`avatar-${size}`} />;
}

function UserProfile({ user }: { user: User }) {
  return (
    <div>
      <UserAvatar src={user.avatar} alt={user.name} size="md" />
      <UserName name={user.name} />
      <UserEmail email={user.email} />
    </div>
  );
}
```

### Props Design

Design props for flexibility and clarity:

```typescript
// ❌ Bad: Vague prop names
function Card({ data, handle, config }: CardProps) {
  // What does data contain? What does handle do?
}

// ✅ Good: Clear, descriptive props
function Card({
  title,
  description,
  onEdit,
  onDelete,
  variant = 'default'
}: CardProps) {
  // Clear what each prop does
}
```

## State Management Patterns

### Local State vs Global State

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Local State                    Global State            │
│  ───────────                   ───────────             │
│  • UI-only state               • Shared data           │
│  • Form inputs                 • User auth             │
│  • UI toggles                  • Application settings  │
│  • Temporary data              • Cached data           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### State Lifting

Lift state to the lowest common ancestor:

```typescript
// ❌ Bad: Duplicated state
function Parent() {
  const [value, setValue] = useState('');
  return <Child value={value} />;
}

function Child({ value }: { value: string }) {
  const [localValue, setLocalValue] = useState(value); // Duplicate!
}

// ✅ Good: Single source of truth
function Parent() {
  const [value, setValue] = useState('');
  return <Child value={value} onChange={setValue} />;
}

function Child({
  value,
  onChange
}: {
  value: string;
  onChange: (val: string) => void;
}) {
  return <input value={value} onChange={(e) => onChange(e.target.value)} />;
}
```

### Custom Hooks

Extract reusable state logic into custom hooks:

```typescript
// ✅ Good: Reusable hook
function useForm<T>(initialValues: T) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleChange = (name: keyof T) => (value: string) => {
    setValues((prev) => ({ ...prev, [name]: value }));
  };

  const validate = (rules: ValidationRules<T>) => {
    const newErrors = validateRules(values, rules);
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  return { values, errors, handleChange, validate };
}

// Usage
function LoginForm() {
  const { values, errors, handleChange, validate } = useForm({
    email: '',
    password: ''
  });

  // ... rest of component
}
```

## Data Fetching Patterns

### Server State vs Client State

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Server State                    Client State           │
│  ───────────                   ───────────             │
│  • API responses               • Form inputs           │
│  • Database data               • UI toggles            │
│  • Not owned by frontend       • Owned by frontend     │
│  • Requires sync               • No sync needed        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Data Fetching with React Query/SWR

```typescript
// ✅ Good: Using React Query for server state
function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000 // 10 minutes
  });
}

function UserList() {
  const { data, isLoading, error } = useUsers();

  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} />;

  return (
    <ul>
      {data?.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### Optimistic Updates

Update UI immediately, rollback on error:

```typescript
function useLikePost() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (postId: string) => likePost(postId),
    onMutate: async (postId) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['posts'] });

      // Snapshot previous value
      const previousPosts = queryClient.getQueryData(['posts']);

      // Optimistically update
      queryClient.setQueryData(['posts'], (old: Post[]) =>
        old.map((post) =>
          post.id === postId ? { ...post, liked: true } : post
        )
      );

      // Return context with rollback
      return { previousPosts };
    },
    onError: (err, postId, context) => {
      // Rollback on error
      queryClient.setQueryData(['posts'], context?.previousPosts);
    }
  });
}
```

## Performance Patterns

### Code Splitting

Split code into chunks loaded on demand:

```typescript
// ✅ Good: Route-based code splitting
import { lazy } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

### Memoization

Prevent unnecessary re-renders:

```typescript
// ✅ Good: Memoized expensive component
const ExpensiveList = memo(function ExpensiveList({
  items
}: {
  items: Item[];
}) {
  return (
    <ul>
      {items.map((item) => (
        <li key={item.id}>{item.name}</li>
      ))}
    </ul>
  );
});

// ✅ Good: Memoized expensive computation
function useFilteredItems(items: Item[], filter: string) {
  return useMemo(() => {
    return items.filter((item) => item.name.includes(filter));
  }, [items, filter]);
}
```

### Virtual Scrolling

Render only visible items for large lists:

```typescript
// ✅ Good: Using react-window for virtual scrolling
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

## Form Patterns

### Controlled Components

Use controlled components for forms:

```typescript
// ✅ Good: Controlled form
function ContactForm() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: ''
  });

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Submit formData
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        name="name"
        value={formData.name}
        onChange={handleChange}
      />
      <input
        type="email"
        name="email"
        value={formData.email}
        onChange={handleChange}
      />
      <textarea
        name="message"
        value={formData.message}
        onChange={handleChange}
      />
      <button type="submit">Submit</button>
    </form>
  );
}
```

### Form Validation

Validate forms with clear error messages:

```typescript
function useFormValidation<T>(
  schema: z.Schema<T>,
  initialValues: T
) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validate = () => {
    try {
      schema.parse(values);
      setErrors({});
      return true;
    } catch (error) {
      if (error instanceof z.ZodError) {
        const formErrors: Record<string, string> = {};
        error.errors.forEach((err) => {
          if (err.path[0]) {
            formErrors[err.path[0].toString()] = err.message;
          }
        });
        setErrors(formErrors);
      }
      return false;
    }
  };

  return { values, setValues, errors, validate };
}
```

## Accessibility Patterns

### Semantic HTML

Use semantic elements for accessibility:

```typescript
// ✅ Good: Semantic HTML
function Article({ title, content, author }: ArticleProps) {
  return (
    <article>
      <header>
        <h1>{title}</h1>
        <address>By {author.name}</address>
      </header>
      <main>{content}</main>
      <footer>
        <button>Share</button>
      </footer>
    </article>
  );
}
```

### ARIA Attributes

Use ARIA attributes for custom components:

```typescript
// ✅ Good: Accessible custom button
function IconButton({ icon, label, onClick }: IconButtonProps) {
  return (
    <button
      onClick={onClick}
      aria-label={label}
      type="button"
    >
      {icon}
    </button>
  );
}
```

## Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Giant components | Hard to understand and maintain | Break into smaller components |
| Prop drilling | Props passed through many layers | Use context or state management |
| Duplication | Code repeated across components | Extract custom hooks |
| Mixed concerns | UI and business logic together | Separate presentation and logic |
| No TypeScript | Runtime errors, poor IDE support | Use TypeScript for type safety |

## Coaching Notes

> **ABC - Always Be Coaching:** Frontend patterns teach you that composable, single-responsibility components and explicit state boundaries prevent the tangled spaghetti that kills large UI codebases.

1. **Composition over inheritance, always:** A UserProfile composed of UserAvatar, UserName, and UserEmail is easier to test, reorder, and reuse than a single monolithic component. If a component does more than one visual thing, split it.
2. **Server state and client state are different species:** API responses, pagination cursors, and cache timestamps belong in React Query or SWR -- not in useState. Treating them the same leads to stale data, duplicate fetches, and impossible-to-debug synchronization bugs.
3. **Performance is a user experience problem, not a technical flex:** Code split routes, memoize expensive lists, virtual-scroll long data sets. But do it where users feel the pain, not everywhere. Measure first, optimize second.

## Verification

After implementing frontend patterns:

- [ ] Components have single responsibility
- [ ] Props are clearly named and typed
- [ ] State is managed appropriately (local vs global)
- [ ] Data fetching uses appropriate patterns
- [ ] Performance optimizations applied where needed
- [ ] Forms are controlled and validated
- [ ] Accessibility is considered
- [ ] Code is tested and type-safe

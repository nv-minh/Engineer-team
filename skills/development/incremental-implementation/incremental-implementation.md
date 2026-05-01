---
name: incremental-implementation
description: Build features incrementally using vertical slices. Use when implementing complex features, working with large codebases, or needing frequent feedback.
version: "2.0.0"
category: "development"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["vertical slice", "incremental", "iterate", "small batches"]
intent: "Replace big-bang delivery with vertical slices so every increment ships working value and integration risk stays near zero."
scenarios:
  - "Building a login flow by first shipping the happy path, then error handling, then validation"
  - "Delivering a todo app where each slice adds one complete user capability"
  - "Parallelizing work across a team where each developer owns a different feature slice"
best_for: "complex features, large codebases, parallel work, rapid feedback"
estimated_time: "20-40 min"
anti_patterns:
  - "Building all database schemas, then all APIs, then all UI in horizontal layers"
  - "Making slices so large that feedback is delayed by days instead of hours"
  - "Shipping a slice without end-to-end tests because it is small"
related_skills: ["subagent-driven-development", "test-driven-development", "writing-plans"]
---

# Incremental Implementation

## Overview

Incremental implementation builds features using vertical slices — thin, complete pieces that deliver value end-to-end. Rather than building all infrastructure first, then all business logic, then all UI, you build complete vertical slices from top to bottom.

## When to Use

- Implementing complex features
- Working with large codebases
- Needing frequent feedback
- Reducing integration risk
- Parallelizing work

## Horizontal vs Vertical

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  HORIZONTAL (❌ Bad)            VERTICAL (✅ Good)       │
│  ────────────────              ──────────────           │
│                                                         │
│  Database ───→                Full ───→                 │
│  API ───→                     Feature ───→              │
│  UI ───→                      (Working)                 │
│                                                         │
│  (Nothing works until         (Working feature          │
│   everything is done)          every step)              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## The Vertical Slice Approach

Build complete, working features one slice at a time:

```typescript
// ✅ Good: Vertical slice - complete feature
// Slice 1: User can view their profile
function UserProfile() {
  const { data: user } = useUserProfile();
  return <ProfileCard user={user} />;
}

// Slice 2: User can edit their name
function UserProfile() {
  const { data: user } = useUserProfile();
  const { mutate: updateName } = useUpdateUserName();

  return (
    <ProfileCard user={user}>
      <NameEditor onSave={updateName} />
    </ProfileCard>
  );
}

// Slice 3: User can upload avatar
function UserProfile() {
  const { data: user } = useUserProfile();
  const { mutate: updateName } = useUpdateUserName();
  const { mutate: uploadAvatar } = useUploadAvatar();

  return (
    <ProfileCard user={user}>
      <NameEditor onSave={updateName} />
      <AvatarUploader onUpload={uploadAvatar} />
    </ProfileCard>
  );
}
```

## Slice Design Principles

### 1. Each Slice Delivers Value

Every slice should be useful on its own:

```
✅ Good Slices:
- "User can view profile"
- "User can edit name"
- "User can upload avatar"

❌ Bad Slices:
- "Setup database"
- "Create API endpoints"
- "Build UI components"
```

### 2. Slices Build on Each Other

Each slice adds to the previous:

```typescript
// Slice 1: Basic read
function useTodos() {
  return useQuery(['todos'], fetchTodos);
}

// Slice 2: Add creation
function useTodos() {
  const queryClient = useQueryClient();
  const createMutation = useMutation({
    mutationFn: createTodo,
    onSuccess: () => queryClient.invalidateQueries(['todos'])
  });

  return {
    data: useQuery(['todos'], fetchTodos).data,
    create: createMutation.mutate
  };
}

// Slice 3: Add deletion
function useTodos() {
  const queryClient = useQueryClient();
  const createMutation = useMutation({
    mutationFn: createTodo,
    onSuccess: () => queryClient.invalidateQueries(['todos'])
  });
  const deleteMutation = useMutation({
    mutationFn: deleteTodo,
    onSuccess: () => queryClient.invalidateQueries(['todos'])
  });

  return {
    data: useQuery(['todos'], fetchTodos).data,
    create: createMutation.mutate,
    delete: deleteMutation.mutate
  };
}
```

### 3. Test Each Slice Completely

Each slice is tested end-to-end:

```typescript
// Slice 1 test
describe('View todos', () => {
  it('should display list of todos', async () => {
    render(<TodoApp />);
    await waitFor(() => {
      expect(screen.getByText('Buy groceries')).toBeInTheDocument();
    });
  });
});

// Slice 2 test
describe('Create todo', () => {
  it('should add new todo to list', async () => {
    render(<TodoApp />);
    await userEvent.type(screen.getByPlaceholderText('New todo'), 'Write code');
    await userEvent.click(screen.getByText('Add'));
    await waitFor(() => {
      expect(screen.getByText('Write code')).toBeInTheDocument();
    });
  });
});
```

## Implementation Strategy

### 1. Start with the Happy Path

Build the main success case first:

```typescript
// ✅ Good: Start with happy path
function Login() {
  const { login } = useAuth();

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    await login({
      email: formData.get('email') as string,
      password: formData.get('password') as string
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" />
      <input name="password" type="password" />
      <button type="submit">Login</button>
    </form>
  );
}
```

### 2. Add Error Handling

Add error handling in the next slice:

```typescript
// Slice 2: Add error handling
function Login() {
  const { login, error } = useAuth();
  const [errorMessage, setErrorMessage] = useState('');

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    try {
      await login({
        email: formData.get('email') as string,
        password: formData.get('password') as string
      });
    } catch (err) {
      setErrorMessage('Invalid email or password');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" />
      <input name="password" type="password" />
      {errorMessage && <div className="error">{errorMessage}</div>}
      <button type="submit">Login</button>
    </form>
  );
}
```

### 3. Add Loading States

Add loading states in the next slice:

```typescript
// Slice 3: Add loading state
function Login() {
  const { login, error, isLoading } = useAuth();
  const [errorMessage, setErrorMessage] = useState('');

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    try {
      await login({
        email: formData.get('email') as string,
        password: formData.get('password') as string
      });
    } catch (err) {
      setErrorMessage('Invalid email or password');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" />
      <input name="password" type="password" />
      {errorMessage && <div className="error">{errorMessage}</div>}
      <button type="submit" disabled={isLoading}>
        {isLoading ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
}
```

### 4. Add Validation

Add validation in the final slice:

```typescript
// Slice 4: Add validation
function Login() {
  const { login, error, isLoading } = useAuth();
  const [errorMessage, setErrorMessage] = useState('');
  const [validationErrors, setValidationErrors] = useState({});

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);

    // Validate
    const errors = validateLoginForm(formData);
    if (Object.keys(errors).length > 0) {
      setValidationErrors(errors);
      return;
    }

    try {
      await login({
        email: formData.get('email') as string,
        password: formData.get('password') as string
      });
    } catch (err) {
      setErrorMessage('Invalid email or password');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        name="email"
        type="email"
        className={validationErrors.email ? 'error' : ''}
      />
      {validationErrors.email && <span className="error-text">{validationErrors.email}</span>}
      <input
        name="password"
        type="password"
        className={validationErrors.password ? 'error' : ''}
      />
      {validationErrors.password && <span className="error-text">{validationErrors.password}</span>}
      {errorMessage && <div className="error">{errorMessage}</div>}
      <button type="submit" disabled={isLoading}>
        {isLoading ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
}
```

## Benefits of Incremental Implementation

### 1. Faster Feedback

Get working features quickly:
- Slice 1: 1 day → Basic feature working
- Slice 2: 1 day → Feature with error handling
- Slice 3: 1 day → Feature with loading states

### 2. Reduced Risk

Integration happens continuously:
- Each slice integrates with existing code
- Problems are caught early
- No "big bang" integration

### 3. Parallel Work

Multiple developers can work in parallel:
- Dev A: User profile slice
- Dev B: Todo list slice
- Dev C: Notifications slice

### 4. Easy Pivots

Change direction without wasted work:
- Completed slices deliver value
- Incomplete slices can be dropped
- No sunk cost in unused infrastructure

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| Building horizontal layers | Nothing works until complete | Build vertical slices |
| Making slices too large | Long feedback cycles | Keep slices small (1-2 days) |
| Skipping tests | Regressions introduced | Test each slice completely |
| Not committing frequently | Lost work | Commit after each slice |
| Perfectionism | Slow progress | Ship working, iterate later |

## Coaching Notes

> **ABC - Always Be Coaching:** Incremental implementation teaches you to ship working value early and often, turning big risky launches into a series of safe, observable steps.

1. **Vertical slices reduce integration debt to zero:** When you build database-through-UI in one slice, integration problems surface on day one, not day thirty. Horizontal layers feel organized but hide integration bombs until the end.
2. **The happy path is your first slice for a reason:** If the core use case does not work, error handling, loading spinners, and validation are theater. Prove the happy path works end-to-end, then enrich it slice by slice.
3. **Every slice ships or dies:** A slice that is not committed and tested is work that can vanish at any moment. Commit after each slice, run the tests, and you always have a safe rollback point.

## Verification

After implementing incremental slices:

- [ ] Each slice delivers value independently
- [ ] Each slice is tested end-to-end
- [ ] Each slice integrates with existing code
- [ ] Progress is visible after each slice
- [ ] Code is committed after each slice
- [ ] Tests pass for all slices
- [ ] No breaking changes to existing functionality

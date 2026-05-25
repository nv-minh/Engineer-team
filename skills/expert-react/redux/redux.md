---
name: redux
description: >
  Redux Toolkit patterns for global state management covering stores, slices,
  async thunks, RTK Query, selectors, and middleware. Use when managing complex
  application state, implementing async workflows, or structuring Redux architecture.
version: "3.0.0"
category: "expert-react"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "redux"
  - "redux toolkit"
  - "global state"
  - "createSlice"
  - "rtk query"
  - "createAsyncThunk"
intent: >
  Structure global application state with Redux Toolkit so state transitions
  are predictable, testable, and scalable across the application.
scenarios:
  - "Managing shopping cart state with optimistic updates and persistence"
  - "Building a notification system with async thunks and loading states"
  - "Setting up RTK Query for typed API caching and cache invalidation"
best_for: "Redux Toolkit, global state, async state, RTK Query"
estimated_time: "20-40 min"
anti_patterns:
  - "Writing Redux boilerplate manually instead of using Redux Toolkit"
  - "Storing non-serializable values or DOM references in the store"
  - "Performing async operations inside reducers instead of thunks or RTK Query"
related_skills: ["react", "react-hooks", "frontend-patterns", "typescript-patterns"]

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

# Redux Toolkit

[ROLE]
Act as a Redux Toolkit expert. Deliver structured global state management with RTK slices, typed hooks, and RTK Query for API caching.

[OBJECTIVE]
Structure global application state with Redux Toolkit so state transitions are predictable, testable, and scalable across the application.

[RULES]
1. <thought>Before adding Redux, ask: Is this truly global state shared by many components? Would React Context, useState, or React Query solve this more simply?</thought>
2. Use Redux Toolkit exclusively — never write manual action types, switch statements, or createStore.
3. Keep state flat and normalized — use entity adapters for collections.
4. Reducers must be pure — no side effects, no async in reducers.
5. Use createAsyncThunk or RTK Query for all async operations.
6. Create typed hooks (`useAppDispatch`, `useAppSelector`) for type safety.
7. DO NOT write Redux boilerplate manually — createSlice handles it.
8. DO NOT store non-serializable values or DOM references in the store.
9. DO NOT perform async operations inside reducers — use thunks or RTK Query.
10. Split slices by domain — one slice per feature area (cart, user, products).
11. ABC: RTK Query replaces the fetch-then-dispatch pattern — it manages caching, deduplication, and invalidation automatically. Prefer it for API data.

[PROCESS]

### Step 1: Create a Slice

```typescript
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CartState {
  items: CartItem[];
  total: number;
}

const initialState: CartState = { items: [], total: 0 };

const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers: {
    addItem(state, action: PayloadAction<CartItem>) {
      state.items.push(action.payload);
      state.total = state.items.reduce((sum, i) => sum + i.price, 0);
    },
    removeItem(state, action: PayloadAction<string>) {
      state.items = state.items.filter(i => i.id !== action.payload);
      state.total = state.items.reduce((sum, i) => sum + i.price, 0);
    },
    clearCart(state) {
      state.items = [];
      state.total = 0;
    },
  },
});

export const { addItem, removeItem, clearCart } = cartSlice.actions;
export default cartSlice.reducer;
```

### Step 2: Configure the Store

```typescript
import { configureStore } from '@reduxjs/toolkit';
import cartReducer from './features/cartSlice';
import userReducer from './features/userSlice';

export const store = configureStore({
  reducer: {
    cart: cartReducer,
    user: userReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(loggerMiddleware),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

### Step 3: Create Typed Hooks

```typescript
import { useDispatch, useSelector } from 'react-redux';
import type { RootState, AppDispatch } from './store';

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector = <T>(selector: (state: RootState) => T): T =>
  useSelector(selector);
```

### Step 4: Connect Components

```typescript
import { useAppDispatch, useAppSelector } from '../hooks';
import { addItem, removeItem } from './cartSlice';

export function Cart() {
  const items = useAppSelector(state => state.cart.items);
  const total = useAppSelector(state => state.cart.total);
  const dispatch = useAppDispatch();

  return (
    <div>
      <ul>{items.map(item => (
        <li key={item.id}>
          {item.name} - ${item.price}
          <button onClick={() => dispatch(removeItem(item.id))}>Remove</button>
        </li>
      ))}</ul>
      <p>Total: ${total}</p>
    </div>
  );
}
```

### Step 5: Add Async Thunks

```typescript
import { createAsyncThunk } from '@reduxjs/toolkit';

export const fetchProducts = createAsyncThunk(
  'products/fetch',
  async (category: string, { rejectWithValue }) => {
    try {
      const res = await fetch(`/api/products?cat=${category}`);
      if (!res.ok) throw new Error('Failed to fetch');
      return res.json();
    } catch (err) {
      return rejectWithValue((err as Error).message);
    }
  }
);

// In slice extraReducers:
extraReducers: (builder) => {
  builder
    .addCase(fetchProducts.pending, (state) => { state.loading = true; })
    .addCase(fetchProducts.fulfilled, (state, action) => {
      state.items = action.payload;
      state.loading = false;
    })
    .addCase(fetchProducts.rejected, (state, action) => {
      state.error = action.payload as string;
      state.loading = false;
    });
}
```

### RTK Query (API Caching)

```typescript
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const api = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({ baseUrl: '/api' }),
  tagTypes: ['User', 'Post'],
  endpoints: (builder) => ({
    getUsers: builder.query<User[], void>({
      query: () => 'users',
      providesTags: ['User'],
    }),
    createUser: builder.mutation<User, Partial<User>>({
      query: (body) => ({ url: 'users', method: 'POST', body }),
      invalidatesTags: ['User'],
    }),
  }),
});

export const { useGetUsersQuery, useCreateUserMutation } = api;
```

### Verification

- [ ] Store configured with `configureStore` (not `createStore`)
- [ ] Slices created with `createSlice` (no manual action types)
- [ ] Typed hooks used in all components
- [ ] Async logic uses `createAsyncThunk` or RTK Query
- [ ] State is flat and normalized (no deep nesting)
- [ ] Only serializable data in store
- [ ] Reducers are pure functions

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing Redux patterns used, and `recommendations` for improvements.

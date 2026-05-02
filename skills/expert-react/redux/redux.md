---
name: redux
description: >
  Redux Toolkit patterns for global state management covering stores, slices,
  async thunks, RTK Query, selectors, and middleware. Use when managing complex
  application state, implementing async workflows, or structuring Redux architecture.
version: "1.0.0"
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
---

# Redux Toolkit

## Overview

Redux Toolkit (RTK) is the official, opinionated way to write Redux logic. It provides `createSlice`, `configureStore`, `createAsyncThunk`, and RTK Query to eliminate boilerplate and enforce best practices.

## When to Use

- Managing complex global state that spans many components
- Implementing async workflows (API calls with loading/error states)
- Setting up API data caching with automatic invalidation (RTK Query)
- Coordinating state across multiple feature domains

## When NOT to Use

- For simple local UI state -- use `useState` or `useReducer`
- For server state only -- React Query or SWR may be simpler
- For state shared by only 2-3 nearby components -- use React Context

## Process

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

## RTK Query (API Caching)

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

## Best Practices

1. **Use Redux Toolkit exclusively** -- never write manual action types, switch statements, or createStore
2. **Keep state flat and normalized** -- use entity adapters for collections
3. **Reducers must be pure** -- no side effects, no async in reducers
4. **Use createAsyncThunk or RTK Query** for all async operations
5. **Create typed hooks** (`useAppDispatch`, `useAppSelector`) for type safety
6. **Only store serializable data** -- no functions, class instances, or DOM refs
7. **Split slices by domain** -- one slice per feature area (cart, user, products)

## Coaching Notes

- **Redux Toolkit eliminated the boilerplate problem** -- if you find yourself writing `action.type` strings or switch/case reducers, you are not using RTK correctly. `createSlice` handles all of it.
- **RTK Query replaces the fetch-then-dispatch pattern** -- instead of createAsyncThunk + manual loading/error state, RTK Query manages caching, deduplication, and invalidation automatically. Prefer it for API data.
- **Normalized state scales, nested state does not** -- store entities by ID in a dictionary, keep an array of IDs for ordering. This makes lookups O(1) and avoids deep updates.

## Verification

- [ ] Store configured with `configureStore` (not `createStore`)
- [ ] Slices created with `createSlice` (no manual action types)
- [ ] Typed hooks used in all components
- [ ] Async logic uses `createAsyncThunk` or RTK Query
- [ ] State is flat and normalized (no deep nesting)
- [ ] Only serializable data in store
- [ ] Reducers are pure functions

## Related Skills

- **react** -- Core React patterns for components that consume Redux state
- **react-hooks** -- Hook patterns including useSelector/useDispatch
- **frontend-patterns** -- General UI patterns and data fetching alternatives
- **typescript-patterns** -- TypeScript patterns for typed Redux

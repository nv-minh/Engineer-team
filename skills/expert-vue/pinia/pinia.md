---
name: pinia
description: >
  Pinia state management patterns covering stores, state, getters, actions,
  plugins, SSR support, and Vuex migration. Use when managing Vue 3 application
  state, creating stores, or migrating from Vuex to Pinia.
version: "1.0.0"
category: "expert-vue"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "pinia"
  - "vue state management"
  - "defineStore"
  - "vuex migration"
  - "vue store"
intent: >
  Structure Vue 3 application state with Pinia stores so state management
  is modular, type-safe, and testable.
scenarios:
  - "Building a user auth store with login/logout actions and persisted state"
  - "Creating composable stores that reference each other for cross-feature state"
  - "Migrating a Vuex store to Pinia with modular architecture"
best_for: "Pinia stores, Vue 3 state management, Vuex migration"
estimated_time: "15-30 min"
anti_patterns:
  - "Using Vuex in new Vue 3 projects instead of Pinia"
  - "Storing entire API responses without normalization"
  - "Accessing stores outside of setup() without passing pinia instance"
related_skills: ["vue3", "vue-router", "frontend-patterns", "typescript-patterns"]
---

# Pinia

## Overview

Pinia is the official state management library for Vue 3. It replaces Vuex with a simpler, modular API based on `defineStore`, full TypeScript support, and a flat store architecture (no nested modules).

## When to Use

- Managing shared state across multiple Vue components
- Implementing async operations with store actions
- Persisting state across page navigation
- Migrating from Vuex to a modern state management solution

## When NOT to Use

- For state local to a single component -- use `ref` or `reactive`
- For state shared by only parent-child -- use `provide`/`inject`
- For server state caching -- use Vue Query or a composable with fetch

## Process

### Step 1: Create a Store

```typescript
// stores/user.ts
import { defineStore } from 'pinia';

// Composition API style (recommended)
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null);
  const isAuthenticated = computed(() => !!user.value);
  const fullName = computed(() =>
    user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
  );

  async function login(email: string, password: string) {
    const response = await authApi.login(email, password);
    user.value = response.user;
  }

  function logout() {
    user.value = null;
    router.push('/login');
  }

  return { user, isAuthenticated, fullName, login, logout };
});
```

### Step 2: Register Pinia

```typescript
// main.ts
import { createPinia } from 'pinia';

const app = createApp(App);
app.use(createPinia());
app.mount('#app');
```

### Step 3: Use Store in Components

```vue
<script setup lang="ts">
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();

// Destructure with storeToRefs for reactivity
const { user, isAuthenticated } = storeToRefs(userStore);
const { login, logout } = userStore; // Actions are fine to destructure directly
</script>
```

### Step 4: Compose Stores

```typescript
// stores/cart.ts
export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([]);
  const total = computed(() => items.value.reduce((sum, i) => sum + i.price * i.qty, 0));

  // Reference another store
  const userStore = useUserStore();

  async function checkout() {
    if (!userStore.isAuthenticated) throw new Error('Must be logged in');
    await orderApi.create(items.value, userStore.user!.id);
    items.value = [];
  }

  return { items, total, checkout };
});
```

### Step 5: Add Plugins

```typescript
// plugins/pinia-persist.ts
import type { PiniaPluginContext } from 'pinia';

function persistPlugin({ store }: PiniaPluginContext) {
  const saved = localStorage.getItem(`pinia-${store.$id}`);
  if (saved) store.$patch(JSON.parse(saved));

  store.$subscribe((mutation, state) => {
    localStorage.setItem(`pinia-${store.$id}`, JSON.stringify(state));
  });
}

// main.ts
const pinia = createPinia();
pinia.use(persistPlugin);
```

## Options API Style (Alternative)

```typescript
export const useCounterStore = defineStore('counter', {
  state: () => ({ count: 0, name: 'Counter' }),
  getters: {
    doubleCount: (state) => state.count * 2,
  },
  actions: {
    increment() { this.count++; },
    async fetchCount() {
      this.count = await api.getCount();
    },
  },
});
```

## Testing Stores

```typescript
import { setActivePinia, createPinia } from 'pinia';

beforeEach(() => {
  setActivePinia(createPinia());
});

test('login sets user', async () => {
  const store = useUserStore();
  await store.login('test@example.com', 'password');
  expect(store.isAuthenticated).toBe(true);
});
```

## Vuex Migration Quick Reference

| Vuex | Pinia |
|---|---|
| `state` | `state` (or `ref` in setup stores) |
| `getters` | `getters` (or `computed` in setup stores) |
| `mutations` | Removed -- actions mutate directly |
| `actions` | `actions` (or functions in setup stores) |
| `modules` | Separate stores (flat, no nesting) |
| `namespaced` | Automatic (each store is namespaced) |

## Best Practices

1. **Prefer Composition API (setup) stores** -- they are more flexible and idiomatic with Vue 3
2. **Use `storeToRefs` for destructuring** -- direct destructuring of state loses reactivity
3. **Keep stores focused** -- one store per domain (user, cart, products), not one giant store
4. **Actions can be async** -- no need for separate mutations
5. **Compose stores by referencing each other** -- stores can import and use other stores
6. **Use plugins for cross-cutting concerns** -- persistence, logging, devtools integration

## Coaching Notes

- **Pinia removed mutations for a reason** -- they added boilerplate without real benefit. In Pinia, actions can directly mutate state, which is simpler and just as traceable with DevTools.
- **The flat store architecture is an upgrade** -- Vuex's nested modules created complex namespace chains. Pinia stores are independent, composable, and testable in isolation.
- **`storeToRefs` is the #1 gotcha** -- destructuring a store's state without it breaks reactivity. Always use `storeToRefs` for state and getters, but you can destructure actions directly.

## Verification

- [ ] Stores use Composition API style with `defineStore`
- [ ] State destructured with `storeToRefs` (not direct destructuring)
- [ ] Stores are focused on single domains
- [ ] Async operations in actions (no mutations needed)
- [ ] Plugins configured for persistence or logging if needed
- [ ] Store tests use `setActivePinia(createPinia())` in beforeEach

## Related Skills

- **vue3** -- Core Vue 3 Composition API patterns
- **vue-router** -- Vue Router integration with Pinia stores
- **frontend-patterns** -- General state management patterns
- **typescript-patterns** -- TypeScript patterns for Pinia stores

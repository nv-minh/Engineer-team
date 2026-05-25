---
name: pinia
description: >
  Pinia state management patterns covering stores, state, getters, actions,
  plugins, SSR support, and Vuex migration. Use when managing Vue 3 application
  state, creating stores, or migrating from Vuex to Pinia.
version: "3.0.0"
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

# Pinia

[ROLE]
Act as a Pinia expert. Deliver modular, type-safe Vue 3 state management with Composition API stores.

[OBJECTIVE]
Structure Vue 3 application state with Pinia stores so state management is modular, type-safe, and testable.

[RULES]
1. <thought>Before creating a store, ask: Is this shared across multiple components? Would provide/inject or local ref/reactive suffice?</thought>
2. Prefer Composition API (setup) stores — they are more flexible and idiomatic with Vue 3.
3. Use `storeToRefs` for destructuring state — direct destructuring loses reactivity.
4. Keep stores focused — one store per domain (user, cart, products), not one giant store.
5. Actions can be async — no need for separate mutations.
6. DO NOT use Vuex in new Vue 3 projects — Pinia is the official replacement.
7. DO NOT store entire API responses without normalization.
8. DO NOT access stores outside of setup() without passing the pinia instance.
9. Compose stores by referencing each other — stores can import and use other stores.
10. Use plugins for cross-cutting concerns — persistence, logging, devtools integration.
11. ABC: `storeToRefs` is the #1 gotcha — destructuring a store's state without it breaks reactivity. Always use storeToRefs for state and getters, destructure actions directly.

[PROCESS]

### Step 1: Create a Store

```typescript
// stores/user.ts
import { defineStore } from 'pinia';

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
const { user, isAuthenticated } = storeToRefs(userStore);
const { login, logout } = userStore;
</script>
```

### Step 4: Compose Stores

```typescript
export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([]);
  const total = computed(() => items.value.reduce((sum, i) => sum + i.price * i.qty, 0));
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
function persistPlugin({ store }: PiniaPluginContext) {
  const saved = localStorage.getItem(`pinia-${store.$id}`);
  if (saved) store.$patch(JSON.parse(saved));
  store.$subscribe((mutation, state) => {
    localStorage.setItem(`pinia-${store.$id}`, JSON.stringify(state));
  });
}

const pinia = createPinia();
pinia.use(persistPlugin);
```

### Testing Stores

```typescript
import { setActivePinia, createPinia } from 'pinia';

beforeEach(() => { setActivePinia(createPinia()); });

test('login sets user', async () => {
  const store = useUserStore();
  await store.login('test@example.com', 'password');
  expect(store.isAuthenticated).toBe(true);
});
```

### Vuex Migration Quick Reference

| Vuex | Pinia |
|---|---|
| `state` | `state` (or `ref` in setup stores) |
| `getters` | `getters` (or `computed` in setup stores) |
| `mutations` | Removed — actions mutate directly |
| `actions` | `actions` (or functions in setup stores) |
| `modules` | Separate stores (flat, no nesting) |
| `namespaced` | Automatic (each store is namespaced) |

### Verification

- [ ] Stores use Composition API style with `defineStore`
- [ ] State destructured with `storeToRefs` (not direct destructuring)
- [ ] Stores are focused on single domains
- [ ] Async operations in actions (no mutations needed)
- [ ] Plugins configured for persistence or logging if needed
- [ ] Store tests use `setActivePinia(createPinia())` in beforeEach

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing Pinia patterns used, and `recommendations` for improvements.

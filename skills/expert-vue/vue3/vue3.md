---
name: vue3
description: >
  Vue 3 patterns covering Composition API, reactivity system (ref, reactive, computed),
  templates, components, lifecycle hooks, provide/inject, and TypeScript integration.
  Use when building Vue 3 applications with modern patterns.
version: "1.0.0"
category: "expert-vue"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "vue3"
  - "vue 3"
  - "composition api"
  - "vue reactivity"
  - "vue component"
  - "vue typescript"
intent: >
  Build Vue 3 applications using the Composition API, reactive primitives,
  and TypeScript for maintainable, scalable component architecture.
scenarios:
  - "Building a reactive form wizard with multi-step validation using Composition API"
  - "Creating composable functions for reusable data-fetching and pagination logic"
  - "Setting up a Vue 3 project with TypeScript, provide/inject, and lifecycle hooks"
best_for: "Vue 3 Composition API, reactivity, components, TypeScript"
estimated_time: "20-40 min"
anti_patterns:
  - "Using Options API in new Vue 3 projects when Composition API is the standard"
  - "Mutating props directly instead of emitting events"
  - "Using reactive() for primitive values (use ref instead)"
related_skills: ["pinia", "vue-router", "frontend-patterns", "typescript-patterns"]
---

# Vue 3

## Overview

Vue 3 introduces the Composition API, a reactivity system based on proxies, and first-class TypeScript support. This skill covers the core patterns for building Vue 3 applications with `<script setup>` and composable functions.

## When to Use

- Building new Vue applications (prefer Composition API + `<script setup>`)
- Implementing reactive data flows with ref, reactive, computed, and watchers
- Creating reusable composable functions
- Integrating TypeScript with Vue components

## When NOT to Use

- For Vue 2 projects -- use Options API patterns specific to Vue 2
- For state management -- use the `pinia` skill
- For routing -- use the `vue-router` skill

## Reactivity Fundamentals

### ref (Primitives and Any Value)

```typescript
const count = ref(0);
const name = ref('');
const user = ref<User | null>(null);

// Access with .value in script, auto-unwrapped in template
count.value++;
```

### reactive (Objects)

```typescript
const state = reactive({
  items: [] as Item[],
  loading: false,
  error: null as string | null,
});

// Direct access (no .value needed)
state.loading = true;
state.items.push(newItem);
```

### computed (Derived State)

```typescript
const fullName = computed(() => `${first.value} ${last.value}`);
const activeItems = computed(() => state.items.filter(i => i.active));

// Writable computed
const fullName = computed({
  get: () => `${first.value} ${last.value}`,
  set: (val: string) => {
    const parts = val.split(' ');
    first.value = parts[0];
    last.value = parts[1];
  },
});
```

## Component Patterns

### Script Setup (Recommended)

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';

interface Props {
  title: string;
  items?: Item[];
}

const props = withDefaults(defineProps<Props>(), {
  items: () => [],
});

const emit = defineEmits<{
  select: [id: string];
  delete: [id: string];
}>();

const selected = ref<string | null>(null);
const activeCount = computed(() => props.items.filter(i => i.active).length);

onMounted(() => {
  console.log('Component mounted');
});
</script>

<template>
  <div>
    <h2>{{ title }}</h2>
    <span>Active: {{ activeCount }}</span>
    <ul>
      <li v-for="item in items" :key="item.id" @click="emit('select', item.id)">
        {{ item.name }}
      </li>
    </ul>
  </div>
</template>
```

### Provide/Inject (Deep Prop Passing)

```typescript
// Provider
const theme = ref('dark');
provide('theme', theme); // reactive injection key

// Consumer
const theme = inject<Ref<string>>('theme');
```

## Composable Functions (Reusable Logic)

```typescript
// composables/useFetch.ts
export function useFetch<T>(url: string) {
  const data = ref<T | null>(null);
  const loading = ref(true);
  const error = ref<Error | null>(null);

  async function execute() {
    loading.value = true;
    error.value = null;
    try {
      const res = await fetch(url);
      data.value = await res.json();
    } catch (e) {
      error.value = e as Error;
    } finally {
      loading.value = false;
    }
  }

  onMounted(execute);

  return { data, loading, error, execute };
}

// Usage
const { data: users, loading } = useFetch<User[]>('/api/users');
```

## Watchers

```typescript
// Watch a single ref
watch(selectedId, (newId, oldId) => {
  fetchUser(newId);
});

// Watch multiple sources
watch([firstName, lastName], ([first, last]) => {
  console.log(`Name changed to ${first} ${last}`);
});

// Watch a reactive property with getter
watch(
  () => state.page,
  (newPage) => loadPage(newPage),
);

// Immediate + deep watch
watch(source, callback, { immediate: true, deep: true });
```

## Lifecycle Hooks

```typescript
onMounted(() => { /* DOM is ready */ });
onUpdated(() => { /* Reactive data changed, DOM updated */ });
onUnmounted(() => { /* Cleanup: timers, subscriptions */ });
onBeforeMount(() => { /* Before DOM insertion */ });
onBeforeUnmount(() => { /* Before component removal */ });
```

## TypeScript Integration

```typescript
// Typed props with defaults
interface Props {
  modelValue: string;
  items: Item[];
  disabled?: boolean;
}

const props = defineProps<Props>();
const emit = defineEmits<{
  'update:modelValue': [value: string];
}>();

// Typed template refs
const inputRef = useTemplateRef<HTMLInputElement>('input');
```

## Best Practices

1. **Use `<script setup>` always** -- it is the recommended syntax for SFCs in Vue 3
2. **Prefer `ref` over `reactive`** -- ref works with any value type and is explicit with `.value`
3. **Name composables with `use` prefix** -- `useFetch`, `useAuth`, `usePagination`
4. **Never mutate props** -- emit events to the parent instead
5. **Clean up side effects in `onUnmounted`** -- timers, subscriptions, event listeners
6. **Use `computed` for derived state** -- never compute values in the template

## Coaching Notes

- **Composition API is about code organization, not just syntax** -- composables let you group related state, computed, and methods by feature rather than by option type. This scales better than Options API for complex components.
- **ref vs reactive is a common confusion point** -- use `ref` as the default. Only use `reactive` when you need to destructure an object's properties in the template without `.value`.
- **Vue's reactivity is fine-grained** -- unlike React's render-everything model, Vue only re-renders the components that actually depend on the changed data. This means less manual memoization is needed.

## Verification

- [ ] Components use `<script setup lang="ts">`
- [ ] Composables follow `use` naming convention
- [ ] Props are typed with `defineProps<T>()`
- [ ] No direct prop mutations
- [ ] Side effects cleaned up in `onUnmounted`
- [ ] Computed used for derived state instead of template expressions

## Related Skills

- **pinia** -- Vue 3 state management with Pinia stores
- **vue-router** -- Routing with Vue Router 4
- **frontend-patterns** -- General UI patterns applicable to Vue
- **typescript-patterns** -- TypeScript patterns for Vue applications

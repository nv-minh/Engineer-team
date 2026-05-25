---
name: vue3
description: >
  Vue 3 patterns covering Composition API, reactivity system (ref, reactive, computed),
  templates, components, lifecycle hooks, provide/inject, and TypeScript integration.
  Use when building Vue 3 applications with modern patterns.
version: "3.0.0"
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

# Vue 3

[ROLE]
Act as a Vue 3 expert. Deliver idiomatic Composition API code with reactive primitives, TypeScript, and composable functions.

[OBJECTIVE]
Build Vue 3 applications using the Composition API, `<script setup>`, and composable functions for maintainable, scalable component architecture.

[RULES]
1. <thought>Before writing a component, determine: Is this a simple display (template only), stateful logic (composable), or complex form (reactive state machine)?</thought>
2. Use `<script setup lang="ts">` always — it is the recommended syntax for SFCs in Vue 3.
3. Prefer `ref` over `reactive` — ref works with any value type and is explicit with `.value`.
4. Name composables with `use` prefix — `useFetch`, `useAuth`, `usePagination`.
5. Never mutate props — emit events to the parent instead.
6. Clean up side effects in `onUnmounted` — timers, subscriptions, event listeners.
7. Use `computed` for derived state — never compute values in the template.
8. DO NOT use Options API in new Vue 3 projects — Composition API is the standard.
9. DO NOT mutate props directly — emit events.
10. DO NOT use reactive() for primitive values — use ref instead.
11. ABC: Vue's reactivity is fine-grained — unlike React's render-everything model, Vue only re-renders components that depend on the changed data, so less manual memoization is needed.

[PROCESS]

### Reactivity Fundamentals

#### ref (Primitives and Any Value)

```typescript
const count = ref(0);
const name = ref('');
const user = ref<User | null>(null);

// Access with .value in script, auto-unwrapped in template
count.value++;
```

#### reactive (Objects)

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

#### computed (Derived State)

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

### Component Patterns

#### Script Setup (Recommended)

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

#### Provide/Inject (Deep Prop Passing)

```typescript
// Provider
const theme = ref('dark');
provide('theme', theme);

// Consumer
const theme = inject<Ref<string>>('theme');
```

### Composable Functions (Reusable Logic)

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

### Watchers

```typescript
watch(selectedId, (newId, oldId) => { fetchUser(newId); });
watch([firstName, lastName], ([first, last]) => { console.log(`${first} ${last}`); });
watch(() => state.page, (newPage) => loadPage(newPage));
watch(source, callback, { immediate: true, deep: true });
```

### Lifecycle Hooks

```typescript
onMounted(() => { /* DOM is ready */ });
onUpdated(() => { /* Reactive data changed, DOM updated */ });
onUnmounted(() => { /* Cleanup: timers, subscriptions */ });
```

### TypeScript Integration

```typescript
interface Props {
  modelValue: string;
  items: Item[];
  disabled?: boolean;
}

const props = defineProps<Props>();
const emit = defineEmits<{ 'update:modelValue': [value: string] }>();
const inputRef = useTemplateRef<HTMLInputElement>('input');
```

### Verification

- [ ] Components use `<script setup lang="ts">`
- [ ] Composables follow `use` naming convention
- [ ] Props are typed with `defineProps<T>()`
- [ ] No direct prop mutations
- [ ] Side effects cleaned up in `onUnmounted`
- [ ] Computed used for derived state instead of template expressions

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing Vue 3 patterns used, and `recommendations` for improvements.

---
name: vue-router
description: >
  Vue Router 4 patterns covering dynamic routes, navigation guards, lazy loading,
  nested routes, programmatic navigation, and route meta fields. Use when
  implementing routing in Vue 3 applications.
version: "3.0.0"
category: "expert-vue"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "vue router"
  - "vue routing"
  - "navigation guards"
  - "dynamic routes"
  - "lazy loading routes"
intent: >
  Implement structured routing in Vue 3 applications with proper guards,
  lazy loading, and meta-based access control.
scenarios:
  - "Setting up authenticated routes with beforeEach guards and role-based access"
  - "Implementing nested admin routes with lazy-loaded page components"
  - "Building breadcrumb navigation from route meta fields"
best_for: "Vue Router 4, routing, guards, lazy loading, navigation"
estimated_time: "15-30 min"
anti_patterns:
  - "Using Vue Router 3 API (new VueRouter) in Vue 3 projects"
  - "Storing sensitive data in route params or query strings"
  - "Putting all route logic in a single guard function instead of per-route meta"
related_skills: ["vue3", "pinia", "frontend-patterns", "typescript-patterns"]

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

# Vue Router

[ROLE]
Act as a Vue Router 4 expert. Deliver structured routing with guards, lazy loading, and meta-based access control.

[OBJECTIVE]
Implement routing in Vue 3 applications with proper guards, lazy loading, typed route meta, and named route navigation.

[RULES]
1. <thought>Before defining routes, determine: Which routes need auth guards? Which pages should be lazy-loaded? What meta fields drive access control?</thought>
2. Always lazy-load page components — use dynamic `import()` for every route component.
3. Use named routes — navigate by name + params, not hardcoded paths.
4. Centralize auth logic in `beforeEach` — use route `meta` to mark protected routes.
5. Type route meta — augment the `RouteMeta` interface for type-safe meta access.
6. Use `props: true` — pass route params as component props for testable components.
7. DO NOT use Vue Router 3 API (new VueRouter) in Vue 3 projects.
8. DO NOT store sensitive data in route params or query strings.
9. DO NOT put all route logic in a single guard function — use per-route meta.
10. Configure 404 catch-all route with `/:pathMatch(.*)*`.
11. ABC: Named routes survive refactoring — if you change a path from `/users/:id` to `/people/:id`, named route navigation still works. Hardcoded paths break.

[PROCESS]

### Basic Configuration

```typescript
import { createRouter, createWebHistory } from 'vue-router';

const routes: RouteRecordRaw[] = [
  { path: '/', name: 'home', component: () => import('@/views/Home.vue') },
  { path: '/users/:id', name: 'user-detail', component: () => import('@/views/UserDetail.vue'), props: true },
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    meta: { requiresAuth: true, role: 'admin' },
    children: [
      { path: '', name: 'admin-dashboard', component: () => import('@/views/admin/Dashboard.vue') },
      { path: 'users', name: 'admin-users', component: () => import('@/views/admin/Users.vue') },
    ],
  },
  { path: '/:pathMatch(.*)*', name: 'not-found', component: () => import('@/views/NotFound.vue') },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) { return savedPosition || { top: 0 }; },
});
```

### Navigation Guards

```typescript
router.beforeEach((to, from) => {
  const authStore = useAuthStore();
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } };
  }
  if (to.meta.role && authStore.user?.role !== to.meta.role) {
    return { name: 'forbidden' };
  }
});

router.afterEach((to) => { document.title = (to.meta.title as string) || 'My App'; });
```

### Programmatic Navigation

```typescript
const router = useRouter();
const route = useRoute();
router.push({ name: 'user-detail', params: { id: '123' } });
router.push({ path: '/search', query: { q: 'vue', page: '1' } });
router.replace({ name: 'home' });
const userId = computed(() => route.params.id as string);
```

### Route Meta Best Practices

```typescript
declare module 'vue-router' {
  interface RouteMeta {
    requiresAuth?: boolean;
    role?: string;
    title?: string;
    layout?: 'default' | 'blank' | 'admin';
  }
}
```

### Verification

- [ ] Router uses `createRouter` + `createWebHistory` (Vue 3 API)
- [ ] All page components are lazy loaded with dynamic `import()`
- [ ] Auth guards use route `meta` fields + centralized `beforeEach`
- [ ] Routes use named routes for programmatic navigation
- [ ] Route meta is typed via `RouteMeta` augmentation
- [ ] 404 catch-all route configured

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing routing patterns used, and `recommendations` for improvements.

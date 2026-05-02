---
name: vue-router
description: >
  Vue Router 4 patterns covering dynamic routes, navigation guards, lazy loading,
  nested routes, programmatic navigation, and route meta fields. Use when
  implementing routing in Vue 3 applications.
version: "1.0.0"
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
---

# Vue Router

## Overview

Vue Router 4 is the official router for Vue 3. It supports dynamic routes, nested routing, navigation guards, lazy loading, and route meta fields for access control and layout management.

## When to Use

- Setting up page navigation in Vue 3 SPAs
- Implementing authenticated/authorized routes with guards
- Lazy loading page components for code splitting
- Building nested layouts with child routes

## When NOT to Use

- For Vue 2 projects -- use Vue Router 3 API
- For simple tab/view switching without URL changes -- use component state
- For server-rendered pages -- handle routing on the server side

## Router Setup

### Basic Configuration

```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/views/Home.vue'),
  },
  {
    path: '/users/:id',
    name: 'user-detail',
    component: () => import('@/views/UserDetail.vue'),
    props: true, // Pass route params as component props
  },
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    meta: { requiresAuth: true, role: 'admin' },
    children: [
      { path: '', name: 'admin-dashboard', component: () => import('@/views/admin/Dashboard.vue') },
      { path: 'users', name: 'admin-users', component: () => import('@/views/admin/Users.vue') },
    ],
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/views/NotFound.vue'),
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    return savedPosition || { top: 0 };
  },
});

export default router;
```

### Register in App

```typescript
// main.ts
import router from './router';

const app = createApp(App);
app.use(router);
app.mount('#app');
```

## Navigation Guards

### Global Guards

```typescript
// router/index.ts
router.beforeEach((to, from) => {
  const authStore = useAuthStore();

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } };
  }

  if (to.meta.role && authStore.user?.role !== to.meta.role) {
    return { name: 'forbidden' };
  }
});

router.afterEach((to) => {
  // Analytics, page title
  document.title = (to.meta.title as string) || 'My App';
});
```

### Per-Route Guards

```typescript
const routes = [
  {
    path: '/dashboard',
    component: () => import('@/views/Dashboard.vue'),
    beforeEnter: (to, from) => {
      // Route-specific guard logic
      if (!hasCompletedOnboarding()) return { name: 'onboarding' };
    },
  },
];
```

### In-Component Guards

```typescript
// Composition API
onBeforeRouteLeave((to, from, next) => {
  if (hasUnsavedChanges.value) {
    const confirm = window.confirm('Leave without saving?');
    if (!confirm) return false;
  }
});
```

## Programmatic Navigation

```typescript
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

// Navigate to named route with params
router.push({ name: 'user-detail', params: { id: '123' } });

// Navigate with query
router.push({ path: '/search', query: { q: 'vue', page: '1' } });

// Replace (no history entry)
router.replace({ name: 'home' });

// Go back
router.go(-1);

// Access current route params
const userId = computed(() => route.params.id as string);
```

## Lazy Loading Pattern

```typescript
// All page components should be lazy loaded
const routes = [
  { path: '/', component: () => import('@/views/Home.vue') },
  { path: '/about', component: () => import('@/views/About.vue') },
  { path: '/dashboard', component: () => import('@/views/Dashboard.vue') },
];

// Group routes into chunks
const Dashboard = () => import(/* webpackChunkName: "admin" */ '@/views/Dashboard.vue');
```

## Route Meta Best Practices

```typescript
// Typing route meta
declare module 'vue-router' {
  interface RouteMeta {
    requiresAuth?: boolean;
    role?: string;
    title?: string;
    layout?: 'default' | 'blank' | 'admin';
    breadcrumbs?: Array<{ label: string; to?: string }>;
  }
}
```

## Best Practices

1. **Always lazy-load page components** -- use dynamic `import()` for every route component
2. **Use named routes** -- navigate by name + params, not hardcoded paths
3. **Centralize auth logic in `beforeEach`** -- use route `meta` to mark protected routes
4. **Type route meta** -- augment the `RouteMeta` interface for type-safe meta access
5. **Configure server for HTML5 history** -- return index.html for all routes in production
6. **Use `props: true`** -- pass route params as component props for testable components

## Coaching Notes

- **Route meta is the right place for access control** -- avoid scattering auth checks across components. Define `meta.requiresAuth` and `meta.role` on routes, then enforce centrally in `beforeEach`.
- **Lazy loading is free performance** -- Vue Router's dynamic imports create separate chunks that are only loaded when the route is visited. Every page component should use `() => import(...)`.
- **Named routes survive refactoring** -- if you change a path from `/users/:id` to `/people/:id`, named route navigation still works. Hardcoded paths break.

## Verification

- [ ] Router uses `createRouter` + `createWebHistory` (Vue 3 API)
- [ ] All page components are lazy loaded with dynamic `import()`
- [ ] Auth guards use route `meta` fields + centralized `beforeEach`
- [ ] Routes use named routes for programmatic navigation
- [ ] Route meta is typed via `RouteMeta` augmentation
- [ ] 404 catch-all route configured

## Related Skills

- **vue3** -- Core Vue 3 patterns for route components
- **pinia** -- Store integration for auth state in guards
- **frontend-patterns** -- General UI navigation patterns
- **typescript-patterns** -- TypeScript patterns for typed routing

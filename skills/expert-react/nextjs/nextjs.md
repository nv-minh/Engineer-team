---
name: nextjs
description: >
  Next.js patterns covering App Router, Pages Router, routing, data fetching,
  SSR/SSG/ISR, caching, middleware, and deployment. Use when building
  Next.js applications, configuring routing, or implementing server-side rendering.
version: "1.0.0"
category: "expert-react"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "nextjs"
  - "next.js"
  - "app router"
  - "server components"
  - "SSR"
  - "SSG"
  - "ISR"
  - "next.js middleware"
intent: >
  Build production-ready Next.js applications using the correct routing,
  rendering, and caching strategies for each page's requirements.
scenarios:
  - "Building a marketing site with SSG for static pages and ISR for blog posts"
  - "Creating a dashboard with App Router, server components, and streaming"
  - "Configuring middleware for authentication and locale-based routing"
best_for: "Next.js apps, routing, SSR/SSG/ISR, App Router, deployment"
estimated_time: "20-40 min"
anti_patterns:
  - "Using Pages Router for new projects when App Router is the standard"
  - "Making all components client components ('use client') unnecessarily"
  - "Fetching data in client components when server components can do it directly"
related_skills: ["react", "react-hooks", "redux", "frontend-patterns", "typescript-patterns"]
---

# Next.js

## Overview

Next.js provides a full-stack React framework with file-based routing, multiple rendering strategies (SSR, SSG, ISR), and built-in optimizations. The App Router (Next.js 13+) is the recommended approach for new projects.

## When to Use

- Building React applications with server-side rendering or static generation
- Implementing file-based routing with App Router or Pages Router
- Configuring caching, middleware, or deployment pipelines
- Using React Server Components for data fetching at the component level

## When NOT to Use

- For client-only React apps -- use Vite or CRA with the `react` skill
- For non-React frameworks -- see `vue3` or other framework skills

## Rendering Strategies

| Strategy | Function | Use Case |
|---|---|---|
| SSR | `default` in App Router | Dynamic, personalized pages |
| SSG | Build-time rendering | Static marketing pages, docs |
| ISR | `revalidate` option | Blog posts, product pages |
| CSR | `'use client'` + SWR | Dashboard, real-time data |

## App Router (Recommended)

### Route Structure

```
app/
  layout.tsx        # Root layout (wraps all pages)
  page.tsx          # Home page (/)
  loading.tsx       # Loading UI
  error.tsx         # Error boundary
  not-found.tsx     # 404 page
  users/
    page.tsx        # /users
    [id]/
      page.tsx      # /users/:id
    layout.tsx      # Users layout
```

### Server Components (Default)

```typescript
// app/users/page.tsx -- Server Component (default)
// Can directly access databases, file system, env vars
async function UsersPage() {
  const users = await db.user.findMany();
  return (
    <ul>
      {users.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  );
}
```

### Client Components

```typescript
'use client'; // Opt into client rendering

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>Count: {count}</button>;
}
```

### Data Fetching with Caching

```typescript
// Static (SSG) - cached at build time
async function StaticPage() {
  const data = await fetch('https://api.example.com/posts');
  return <PostList posts={await data.json()} />;
}

// ISR - revalidate every 60 seconds
async function BlogPage() {
  const data = await fetch('https://api.example.com/posts', { next: { revalidate: 60 } });
  return <PostList posts={await data.json()} />;
}

// Dynamic (SSR) - no cache
async function DashboardPage() {
  const data = await fetch('https://api.example.com/user', { cache: 'no-store' });
  return <Dashboard data={await data.json()} />;
}
```

### Layouts and Templates

```typescript
// app/layout.tsx -- persists across navigation
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <nav>{/* Shared navigation */}</nav>
        {children}
      </body>
    </html>
  );
}
```

### Route Handlers (API Routes)

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  const users = await db.user.findMany();
  return NextResponse.json(users);
}

export async function POST(request: Request) {
  const body = await request.json();
  const user = await db.user.create({ data: body });
  return NextResponse.json(user, { status: 201 });
}
```

### Middleware

```typescript
// middleware.ts (root)
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('auth-token');
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}

export const config = {
  matcher: ['/dashboard/:path*', '/admin/:path*'],
};
```

## Pages Router (Legacy)

```typescript
// pages/index.tsx
import { GetServerSideProps } from 'next';

export default function Home({ data }: { data: Post[] }) {
  return <ul>{data.map(p => <li key={p.id}>{p.title}</li>)}</ul>;
}

export const getServerSideProps: GetServerSideProps = async () => {
  const res = await fetch('https://api.example.com/posts');
  return { props: { data: await res.json() } };
};
```

## Best Practices

1. **Default to Server Components** -- only add `'use client'` when you need interactivity (useState, useEffect, event handlers)
2. **Push data fetching to the server** -- avoid client-side fetching when server components can do it directly
3. **Use ISR for semi-dynamic content** -- blogs, product pages, docs that update periodically
4. **Colocate loading and error UI** -- `loading.tsx` and `error.tsx` provide instant feedback
5. **Use middleware for cross-cutting concerns** -- auth checks, redirects, locale detection
6. **Optimize images** -- always use `next/image` for automatic optimization and lazy loading

## Coaching Notes

- **Server Components are a paradigm shift** -- they run on the server and can access databases directly. This eliminates the need for API routes for many data-fetching patterns. Before creating an API route, ask: can a server component fetch this data directly?
- **'use client' is a boundary, not a switch** -- it marks where the server-client boundary is. Components imported by a client component become client components too. Keep the client boundary as low in the tree as possible.
- **App Router vs Pages Router** -- for new projects, always use App Router. For existing Pages Router projects, migrate incrementally (they coexist).

## Verification

- [ ] App Router used for new pages (or Pages Router documented for legacy)
- [ ] Server components used where no interactivity is needed
- [ ] `'use client'` only on components that need it
- [ ] Caching strategy matches page requirements (static/ISR/dynamic)
- [ ] Middleware configured for auth and routing guards
- [ ] Images use next/image for optimization

## Related Skills

- **react** -- Core React patterns (components, JSX, state)
- **react-hooks** -- Hook patterns used in client components
- **redux** -- Global state for complex client-side state
- **frontend-patterns** -- General UI patterns and data fetching
- **typescript-patterns** -- TypeScript patterns for Next.js

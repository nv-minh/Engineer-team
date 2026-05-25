---
name: nextjs
description: >
  Next.js patterns covering App Router, Pages Router, routing, data fetching,
  SSR/SSG/ISR, caching, middleware, and deployment. Use when building
  Next.js applications, configuring routing, or implementing server-side rendering.
version: "3.0.0"
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

# Next.js

[ROLE]
Act as a Next.js expert. Deliver production-ready Next.js code using the correct routing, rendering, and caching strategies for each page's requirements.

[OBJECTIVE]
Build Next.js applications with optimal rendering strategy per page (SSR, SSG, ISR, CSR), server components by default, and proper client boundaries.

[RULES]
1. <thought>Before writing any page, determine: Does this need SSR (dynamic/personalized), SSG (static), ISR (semi-dynamic), or CSR (real-time)? Can this be a server component or does it need 'use client'?</thought>
2. Default to Server Components — only add `'use client'` when you need interactivity (useState, useEffect, event handlers).
3. Push data fetching to the server — avoid client-side fetching when server components can do it directly.
4. DO NOT use Pages Router for new projects — App Router is the standard.
5. DO NOT make all components client components (`'use client'`) unnecessarily.
6. DO NOT fetch data in client components when server components can do it directly.
7. Use ISR with `revalidate` for semi-dynamic content (blogs, product pages, docs).
8. Colocate loading and error UI — `loading.tsx` and `error.tsx` provide instant feedback.
9. Use middleware for cross-cutting concerns — auth checks, redirects, locale detection.
10. Always use `next/image` for automatic image optimization and lazy loading.
11. ABC: `'use client'` is a boundary, not a switch — components imported by a client component become client components too. Keep the client boundary as low in the tree as possible.

[PROCESS]

### Rendering Strategies

| Strategy | Function | Use Case |
|---|---|---|
| SSR | `default` in App Router | Dynamic, personalized pages |
| SSG | Build-time rendering | Static marketing pages, docs |
| ISR | `revalidate` option | Blog posts, product pages |
| CSR | `'use client'` + SWR | Dashboard, real-time data |

### App Router (Recommended)

#### Route Structure

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

#### Server Components (Default)

```typescript
// app/users/page.tsx -- Server Component (default)
async function UsersPage() {
  const users = await db.user.findMany();
  return (
    <ul>
      {users.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  );
}
```

#### Client Components

```typescript
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>Count: {count}</button>;
}
```

#### Data Fetching with Caching

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

#### Layouts and Templates

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

#### Route Handlers (API Routes)

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

#### Middleware

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

### Pages Router (Legacy)

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

### Verification

- [ ] App Router used for new pages (or Pages Router documented for legacy)
- [ ] Server components used where no interactivity is needed
- [ ] `'use client'` only on components that need it
- [ ] Caching strategy matches page requirements (static/ISR/dynamic)
- [ ] Middleware configured for auth and routing guards
- [ ] Images use next/image for optimization

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code and explanation, `patterns_applied` listing Next.js patterns used, and `recommendations` for improvements.

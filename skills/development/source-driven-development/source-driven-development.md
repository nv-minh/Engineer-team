---
name: source-driven-development
description: Code using official documentation and authoritative sources. Use when implementing features with new libraries, APIs, or frameworks.
version: "2.0.0"
category: "development"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["official docs", "source-first", "documentation", "authoritative"]
intent: "Eliminate hallucinated or outdated API usage by always grounding implementation in official, version-verified documentation."
scenarios:
  - "Implementing file uploads with Multer by reading the official GitHub README before coding"
  - "Migrating from an outdated Stack Overflow answer to the current Express body-parser API"
  - "Using MCP Context7 to fetch TanStack Query docs and avoiding AI-hallucinated options"
best_for: "new libraries, API integrations, framework adoption, version verification"
estimated_time: "20-35 min"
anti_patterns:
  - "Trusting AI-generated API calls without cross-referencing official documentation"
  - "Copy-pasting Stack Overflow snippets without checking the library version or deprecation status"
  - "Using a library feature without saving documentation links for future maintainers"
related_skills: ["api-interface-design", "context-engineering", "test-driven-development"]
---

# Source-Driven Development

## Overview

Source-driven development codes from official documentation and authoritative sources rather than relying on AI hallucinations, Stack Overflow answers, or outdated tutorials. This ensures accurate, up-to-date, and maintainable code.

## When to Use

- Using a new library or framework
- Implementing API integrations
- Following best practices for a technology
- Debugging framework-specific issues
- Learning new patterns

## The Source Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Priority 1 (✅ Best)                                   │
│  ─────────────                                          │
│  • Official documentation                               │
│  • Official examples and tutorials                      │
│  • API reference from official sources                  │
│                                                         │
│  Priority 2 (⚠️ Use with caution)                       │
│  ────────────────────────────────                       │
│  • Official blog posts                                  │
│  • Official GitHub repositories                         │
│  • Verified library maintainers                         │
│                                                         │
│  Priority 3 (❌ Avoid when possible)                     │
│  ────────────────────────────────                       │
│  • Stack Overflow (may be outdated)                     │
│  • Blog posts (may be wrong)                            │
│  • AI-generated code (may hallucinate)                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Finding Authoritative Sources

### 1. Official Documentation

Always start with official docs:

```typescript
// ✅ Good: Check official docs first
// Before using React Query, check:
// https://tanstack.com/query/latest/docs/react/overview

// Before using Prisma, check:
// https://www.prisma.io/docs

// Before using Next.js, check:
// https://nextjs.org/docs
```

### 2. Use MCP Context7

Let MCP fetch official documentation:

```typescript
// ✅ Good: Use MCP Context7 for docs
// When implementing a feature with a library:
// 1. Ask Context7 to fetch relevant docs
// 2. Read the official documentation
// 3. Code from the official examples
// 4. Adapt to your use case

// Example: Using React Query
const docs = await context7.fetch('tanstack query useQuery');
// Returns official React Query documentation
```

### 3. Verify with Official Examples

Check official examples and repositories:

```typescript
// ✅ Good: Use official examples
// Before implementing authentication with NextAuth:
// 1. Check official examples:
//    https://github.com/nextauthjs/next-auth/tree/main/examples
// 2. Find the example matching your use case
// 3. Adapt the official example to your project

// Example: NextAuth with credentials
// From: https://github.com/nextauthjs/next-auth/tree/main/examples/credentials-next-auth
```

## Coding from Sources

### Step 1: Read Official Documentation

Read the relevant documentation section:

```typescript
// Task: Implement file upload with Multer

// Step 1: Read official Multer docs
// https://github.com/expressjs/multer/blob/master/doc/README.md
// - Read storage options
// - Read file filter options
// - Read error handling
```

### Step 2: Find Official Example

Find an example from official sources:

```typescript
// Step 2: Find official example
// From Multer GitHub README:

const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

app.post('/profile', upload.single('avatar'), (req, res, next) => {
  // req.file is the `avatar` file
  // req.body will hold the text fields
});
```

### Step 3: Adapt to Your Use Case

Adapt the official example:

```typescript
// Step 3: Adapt to your project
import multer from 'multer';
import path from 'path';

// Configure storage based on official docs
const storage = multer.diskStorage({
  destination: 'uploads/',
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// Configure file filter based on official docs
const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  const allowedTypes = /jpeg|jpg|png|gif/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Images only!'));
  }
};

// Create upload instance based on official example
const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// Use in route based on official example
app.post('/api/users/:id/avatar',
  authenticate,
  upload.single('avatar'),
  handleAvatarUpload
);
```

### Step 4: Test and Verify

Test against official documentation:

```typescript
// Step 4: Test and verify
describe('Avatar upload', () => {
  it('should upload file based on Multer docs', async () => {
    // Test follows official Multer behavior
    const response = await request(app)
      .post('/api/users/1/avatar')
      .attach('avatar', 'test/fixtures/avatar.jpg')
      .expect(200);

    // Verify file was saved according to storage config
    expect(response.body.filename).toMatch(/^avatar-\d+\.jpg$/);
  });
});
```

## Common Pitfalls

### Pitfall 1: Using Outdated Information

```typescript
// ❌ Bad: Using outdated Stack Overflow answer
// From 2016: "Use bodyParser() in Express"

app.use(bodyParser.json());

// ✅ Good: Check current Express docs
// https://expressjs.com/en/4x/api.html
// Express 4.x has built-in body parsing

app.use(express.json());
```

### Pitfall 2: AI Hallucinations

```typescript
// ❌ Bad: AI hallucinated API
// AI might invent: "useQuery({ cache: 'infinite' })"

const data = useQuery({ cache: 'infinite' });

// ✅ Good: Check official React Query docs
// https://tanstack.com/query/latest/docs/react/guides/caching
// Correct API: staleTime: Infinity

const data = useQuery({
  staleTime: Infinity
});
```

### Pitfall 3: Copy-Paste Without Understanding

```typescript
// ❌ Bad: Copy-paste without understanding
const result = someComplexFunction(config);

// ✅ Good: Understand what the code does
// From official docs: "This function merges configs with defaults"
const result = mergeConfigs(defaultConfig, userConfig);
```

## Verification Checklist

After coding from sources:

- [ ] Official documentation was consulted
- [ ] Code matches official examples
- [ ] API usage matches current documentation
- [ ] No deprecated APIs are used
- [ ] Version-specific features are verified
- [ ] Code is tested against official behavior
- [ ] Documentation links are saved for reference

## Documenting Sources

Keep track of sources for future reference:

```typescript
/**
 * User authentication using NextAuth.js
 *
 * Based on:
 * - Documentation: https://next-auth.js.org/getting-started/introduction
 * - Example: https://github.com/nextauthjs/next-auth/tree/main/examples/credentials-next-auth
 * - Version: next-auth@4.24.5
 *
 * @see https://next-auth.js.org/providers/credentials
 */
export const authOptions: NextAuthOptions = {
  // ... implementation
};
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The AI knows this library" | AI training data may be outdated. Check official docs. |
| "Stack Overflow is faster" | Stack Overflow answers may be outdated or wrong. |
| "I've used this before" | APIs change. Verify current documentation. |
| "The tutorial looks good" | Tutorials may be outdated. Use official docs. |

## Coaching Notes

> **ABC - Always Be Coaching:** Source-driven development teaches you to distrust your first instinct and verify against authoritative documentation, because outdated or hallucinated APIs silently break production.

1. **Official docs beat every other source:** Stack Overflow answers age fast, blog posts get abandoned, and AI training data has a cutoff date. When the official docs say the API changed, they are right. Adjust your code accordingly.
2. **Version pin, then verify:** Knowing you are on Next.js 14 vs 15 changes which APIs are available and which are deprecated. Always check the docs for your exact version before trusting any example.
3. **Document your sources in the code:** A comment linking to the official docs page you used makes the code auditable and helps the next developer verify whether the approach is still current six months from now.

## Red Flags

- Code uses APIs not found in official docs
- Examples don't match current documentation
- Version conflicts with official examples
- Deprecated warnings in code
- No documentation links saved

## Verification

After source-driven development:

- [ ] Official documentation was read
- [ ] Code matches official examples
- [ ] API usage is current
- [ ] No deprecated APIs used
- [ ] Tests verify official behavior
- [ ] Sources documented in code
- [ ] Version is noted

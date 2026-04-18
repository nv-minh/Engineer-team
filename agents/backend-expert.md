---
name: backend-expert
type: specialist
trigger: duck:backend
distributed_mode:
  enabled: true
  coordinator_trigger: "duck:techlead-orchestrator"
  reporting_protocol: "protocols/report-format.md"
---

# Backend Expert Agent

## Overview

Backend Expert is a specialist in backend development, API design, database queries, server-side performance, and integration patterns. Has deep expertise in Node.js, Python, Go, API architecture, and backend optimization.

## Responsibilities

1. **API Design & Review** - REST/GraphQL API architecture and design
2. **Backend Performance** - Server-side optimization, caching, async processing
3. **Database Integration** - Query optimization, data access patterns
4. **Authentication & Authorization** - JWT, OAuth, session management
5. **Error Handling** - Proper error responses, logging, monitoring
6. **Integration Patterns** - Third-party integrations, webhooks, message queues

## When to Use

```
"Agent: em-backend-expert - Review the login API performance"
"Agent: em-backend-expert - Design API for user profile feature"
"Agent: em-backend-expert - Investigate backend latency issue"
"Agent: em-backend-expert - Review authentication implementation"
"Agent: em-backend-expert - Optimize database queries"
```

**Trigger Command:** `duck:backend`

## Distributed Mode

When running in distributed mode (coordinated by Tech Lead Orchestrator):

1. **Check for tasks** in `/tmp/claude-work-queue/to-backend/`
2. **Send status updates** to `/tmp/claude-work-queue/to-techlead/`
3. **Write reports** to `/tmp/claude-work-reports/backend/`
4. **Notify Tech Lead** when complete

## API Design Patterns

### REST API Design

```yaml
api_design_principles:
  resource_naming:
    - use_nouns_not_verbs: "/users" not "/getUsers"
    - plural_for_collections: "/users" not "/user"
    - hierarchical_for_relations: "/users/{id}/posts"

  http_methods:
    - GET: "Read resource (idempotent, safe)"
    - POST: "Create resource (non-idempotent)"
    - PUT: "Update resource (idempotent)"
    - PATCH: "Partial update (non-idempotent)"
    - DELETE: "Remove resource (idempotent)"

  status_codes:
    - 200: "OK - Request succeeded"
    - 201: "Created - Resource created"
    - 204: "No Content - Success, no body"
    - 400: "Bad Request - Invalid input"
    - 401: "Unauthorized - Not authenticated"
    - 403: "Forbidden - No permission"
    - 404: "Not Found - Resource doesn't exist"
    - 409: "Conflict - Resource already exists"
    - 422: "Unprocessable Entity - Validation failed"
    - 500: "Internal Server Error - Server error"
```

### API Endpoint Design

```typescript
// ✅ GOOD: RESTful resource naming
GET    /api/users              // List users
GET    /api/users/{id}         // Get specific user
POST   /api/users              // Create user
PUT    /api/users/{id}         // Update user
PATCH  /api/users/{id}         // Partial update
DELETE /api/users/{id}         // Delete user

GET    /api/users/{id}/posts   // Get user's posts
POST   /api/users/{id}/posts   // Create post for user

// ✅ GOOD: Use query parameters for filtering
GET /api/users?status=active&role=admin&page=1&limit=20

// ✅ GOOD: Proper error responses
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": {
      "field": "email",
      "value": null
    },
    "requestId": "req_abc123"
  }
}

// ❌ BAD: Verb-based naming
GET /api/getUsers
POST /api/createUser
DELETE /api/removeUser

// ❌ BAD: Inconsistent error format
{
  "success": false,
  "msg": "error",
  "data": null
}
```

### Pagination Patterns

```typescript
// ✅ Offset-based pagination (simple)
GET /api/users?page=1&limit=20

{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}

// ✅ Cursor-based pagination (better for large datasets)
GET /api/users?cursor=abc123&limit=20

{
  "data": [...],
  "pagination": {
    "nextCursor": "def456",
    "hasMore": true
  }
}

// ✅ Keyset pagination (best for performance)
GET /api/users?since=2026-04-19T10:00:00Z&limit=20

{
  "data": [...],
  "pagination": {
    "lastCreatedAt": "2026-04-19T09:58:00Z",
    "hasMore": true
  }
}
```

## Backend Performance

### Caching Strategies

```typescript
// ✅ Application-level caching (in-memory)
const cache = new Map();

async function getUser(id) {
  // Check cache first
  if (cache.has(id)) {
    return cache.get(id);
  }

  // Fetch from database
  const user = await db.users.findById(id);

  // Cache for 5 minutes
  cache.set(id, user);
  setTimeout(() => cache.delete(id), 5 * 60 * 1000);

  return user;
}

// ✅ Redis caching (distributed)
import Redis from 'ioredis';

const redis = new Redis();

async function getUser(id) {
  // Check Redis
  const cached = await redis.get(`user:${id}`);
  if (cached) {
    return JSON.parse(cached);
  }

  // Fetch from database
  const user = await db.users.findById(id);

  // Cache in Redis for 5 minutes
  await redis.setex(`user:${id}`, 300, JSON.stringify(user));

  return user;
}

// ✅ HTTP caching (ETag)
import crypto from 'crypto';

app.get('/api/users/:id', async (req, res) => {
  const user = await db.users.findById(req.params.id);

  // Generate ETag from user data
  const etag = crypto.createHash('md5')
    .update(JSON.stringify(user))
    .digest('hex');

  // Check if client has cached version
  if (req.headers['if-none-match'] === etag) {
    return res.status(304).end();
  }

  res.set('ETag', etag);
  res.json(user);
});
```

### Async Processing

```typescript
// ✅ Background jobs for long tasks
import { Queue } from 'bull';

const emailQueue = new Queue('emails', 'redis://localhost:6379');

app.post('/api/users', async (req, res) => {
  const user = await db.users.create(req.body);

  // Send welcome email in background
  await emailQueue.add({
    type: 'welcome',
    userId: user.id
  });

  res.status(201).json(user);
});

// ✅ Webhooks for async results
app.post('/api/reports/generate', async (req, res) => {
  const report = await db.reports.create({
    status: 'pending',
    webhookUrl: req.body.webhookUrl
  });

  // Process in background
  processReport(report.id);

  // Return immediately
  res.status(202).json({
    reportId: report.id,
    status: 'pending'
  });
});

// Later, when report is ready:
async function onReportComplete(report) {
  await fetch(report.webhookUrl, {
    method: 'POST',
    body: JSON.stringify({
      reportId: report.id,
      status: 'completed',
      url: `/api/reports/${report.id}`
    })
  });
}
```

### Database Query Optimization

```typescript
// ❌ SLOW: N+1 query problem
async function getUsersWithPosts() {
  const users = await db.users.findAll();  // 1 query

  for (const user of users) {
    user.posts = await db.posts.findByUserId(user.id);  // N queries
  }

  return users;
}

// ✅ FAST: Single query with JOIN
async function getUsersWithPosts() {
  return await db.users.findAll({
    include: [{
      model: db.Post,
      as: 'posts'
    }]
  });
}

// ✅ FAST: DataLoader for batch loading
import DataLoader from 'dataloader';

const postLoader = new DataLoader(async (userIds) => {
  const posts = await db.posts.findAll({
    where: { userId: userIds }
  });

  const postsByUserId = new Map();
  for (const post of posts) {
    if (!postsByUserId.has(post.userId)) {
      postsByUserId.set(post.userId, []);
    }
    postsByUserId.get(post.userId).push(post);
  }

  return userIds.map(id => postsByUserId.get(id) || []);
});

async function getUserWithPosts(userId) {
  const user = await db.users.findById(userId);
  user.posts = await postLoader.load(userId);
  return user;
}
```

## Authentication & Authorization

### JWT Authentication

```typescript
// ✅ JWT authentication
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = '1h';

function generateToken(user) {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
}

function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    throw new Error('Invalid token');
  }
}

// Middleware
function authenticate(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'Token required' });
  }

  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
}

// Usage
app.post('/api/login', async (req, res) => {
  const user = await authenticateUser(req.body.email, req.body.password);

  const token = generateToken(user);

  res.json({
    user,
    token
  });
});

app.get('/api/profile', authenticate, async (req, res) => {
  const user = await db.users.findById(req.user.userId);
  res.json(user);
});
```

### Role-Based Authorization

```typescript
// ✅ Role-based authorization middleware
function authorize(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Not authenticated' });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        error: 'Not authorized',
        required: roles
      });
    }

    next();
  };
}

// Usage
app.post('/api/users', authenticate, authorize('admin'), async (req, res) => {
  const user = await db.users.create(req.body);
  res.json(user);
});

app.get('/api/users', authenticate, authorize('admin', 'moderator'), async (req, res) => {
  const users = await db.users.findAll();
  res.json(users);
});
```

## Error Handling

### Error Response Format

```typescript
// ✅ Consistent error format
class APIError extends Error {
  constructor(code, message, details = {}) {
    super(message);
    this.code = code;
    this.details = details;
  }

  toJSON() {
    return {
      error: {
        code: this.code,
        message: this.message,
        details: this.details
      }
    };
  }
}

// Usage
app.get('/api/users/:id', async (req, res) => {
  try {
    const user = await db.users.findById(req.params.id);

    if (!user) {
      throw new APIError('NOT_FOUND', 'User not found', {
        userId: req.params.id
      });
    }

    res.json(user);
  } catch (error) {
    if (error instanceof APIError) {
      res.status(error.statusCode).json(error.toJSON());
    } else {
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'An unexpected error occurred'
        }
      });
    }
  }
});
```

### Error Logging

```typescript
// ✅ Structured logging
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

app.use((err, req, res, next) => {
  logger.error({
    error: err.message,
    stack: err.stack,
    request: {
      method: req.method,
      url: req.url,
      headers: req.headers,
      body: req.body
    }
  });

  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
      requestId: req.id
    }
  });
});
```

## Integration Patterns

### Third-Party API Integration

```typescript
// ✅ Third-party API client with retry
import axios from 'axios';
import pRetry from 'p-retry';

class ExternalAPIClient {
  constructor(baseURL, apiKey) {
    this.client = axios.create({
      baseURL,
      headers: {
        'Authorization': `Bearer ${apiKey}`
      },
      timeout: 10000
    });
  }

  async get(endpoint, params = {}) {
    return pRetry(
      async () => {
        const response = await this.client.get(endpoint, { params });
        return response.data;
      },
      {
        retries: 3,
        onFailedAttempt: (error) => {
          console.log(`Attempt ${error.attemptNumber} failed. Retrying...`);
        }
      }
    );
  }

  async post(endpoint, data) {
    return pRetry(
      async () => {
        const response = await this.client.post(endpoint, data);
        return response.data;
      },
      { retries: 3 }
    );
  }
}

// Usage
const paymentClient = new ExternalAPIClient(
  'https://api.stripe.com/v1',
  process.env.STRIPE_API_KEY
);

async function createPayment(amount) {
  return paymentClient.post('/charges', {
    amount,
    currency: 'usd'
  });
}
```

### Webhook Handling

```typescript
// ✅ Webhook signature verification
import crypto from 'crypto';

function verifyWebhookSignature(payload, signature, secret) {
  const hmac = crypto.createHmac('sha256', secret);
  const digest = hmac.update(payload).digest('hex');

  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(digest)
  );
}

app.post('/webhooks/payment', async (req, res) => {
  const signature = req.headers['x-webhook-signature'];
  const payload = JSON.stringify(req.body);

  if (!verifyWebhookSignature(payload, signature, process.env.WEBHOOK_SECRET)) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  // Process webhook
  await handlePaymentWebhook(req.body);

  res.status(200).end();
});

// ✅ Idempotent webhook processing
async function handlePaymentWebhook(event) {
  // Check if already processed
  const existing = await db.webhooks.findById(event.id);
  if (existing) {
    return { status: 'already_processed' };
  }

  // Process event
  await processPaymentEvent(event);

  // Mark as processed
  await db.webhooks.create({
    id: event.id,
    type: event.type,
    processedAt: new Date()
  });

  return { status: 'processed' };
}
```

## Monitoring & Observability

### Performance Monitoring

```typescript
// ✅ Request timing middleware
import prometheus from 'prom-client';

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });

  next();
});

// ✅ Database query monitoring
const dbQueryDuration = new prometheus.Histogram({
  name: 'db_query_duration_seconds',
  help: 'Duration of database queries in seconds',
  labelNames: ['query_type', 'table']
});

async function monitoredQuery(queryType, table, query) {
  const start = Date.now();
  try {
    const result = await query();
    const duration = (Date.now() - start) / 1000;
    dbQueryDuration.labels(queryType, table).observe(duration);
    return result;
  } catch (error) {
    const duration = (Date.now() - start) / 1000;
    dbQueryDuration.labels(queryType, table).observe(duration);
    throw error;
  }
}
```

### Health Checks

```typescript
// ✅ Comprehensive health check
app.get('/health', async (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    checks: {}
  };

  // Check database
  try {
    await db.query('SELECT 1');
    health.checks.database = { status: 'healthy' };
  } catch (error) {
    health.status = 'unhealthy';
    health.checks.database = {
      status: 'unhealthy',
      error: error.message
    };
  }

  // Check Redis
  try {
    await redis.ping();
    health.checks.redis = { status: 'healthy' };
  } catch (error) {
    health.status = 'unhealthy';
    health.checks.redis = {
      status: 'unhealthy',
      error: error.message
    };
  }

  // Check external API
  try {
    await externalAPI.get('/health');
    health.checks.externalAPI = { status: 'healthy' };
  } catch (error) {
    health.status = 'degraded';
    health.checks.externalAPI = {
      status: 'unhealthy',
      error: error.message
    };
  }

  const statusCode = health.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(health);
});
```

## Handoff Contracts

### From Team Lead
```yaml
provides:
  - task_description
  - api_requirements
  - performance_requirements
  - security_context

expects:
  - api_design_review
  - backend_performance_analysis
  - database_integration_review
  - authentication_review
  - error_handling_review
```

### To Database Expert
```yaml
provides:
  - query_patterns
  - data_access_requirements

expects:
  - query_optimization
  - schema_recommendations
```

### To Frontend Expert
```yaml
provides:
  - api_specification
  - response_formats
  - error_codes

expects:
  - frontend_integration_review
```

## Output Template

See `protocols/report-format.md` for backend-specific report template.

## Verification Checklist

- [ ] API design reviewed
- [ ] REST/GraphQL best practices followed
- [ ] Error handling implemented
- [ ] Authentication/authorization reviewed
- [ ] Performance optimized
- [ ] Database queries efficient
- [ ] Caching strategy appropriate
- [ ] Monitoring/logging in place
- [ ] Integration patterns solid
- [ ] Report follows standard format

---

**Agent Version:** 1.0.0
**Last Updated:** 2026-04-19
**Specializes in:** API Design, Backend Performance, Database Integration, Auth, Error Handling

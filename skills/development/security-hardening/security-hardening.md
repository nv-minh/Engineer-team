---
name: security-hardening
description: Security hardening following OWASP Top 10 and security best practices. Use when handling user input, authentication, authorization, or sensitive data.
version: "2.0.0"
category: "development"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["security", "owasp", "hardening", "vulnerability prevention"]
intent: "Make security a built-in layer of every feature rather than an afterthought, covering the full OWASP Top 10 attack surface."
scenarios:
  - "Adding authentication with bcrypt hashing, account lockout, and secure session management"
  - "Preventing SQL injection and XSS in a search feature by validating all inputs"
  - "Configuring Helmet, CORS, and rate limiting before deploying a public API"
best_for: "input validation, auth, encryption, headers, OWASP compliance"
estimated_time: "30-45 min"
anti_patterns:
  - "Hardcoding secrets or API keys directly in source code"
  - "Storing passwords in plain text or using weak hashing algorithms"
  - "Running production with debug mode enabled or wildcard CORS origins"
related_skills: ["security-audit", "api-interface-design", "backend-patterns"]
---

# Security Hardening

## Overview

Security hardening protects applications from common vulnerabilities following OWASP Top 10 and security best practices. Security is not an afterthought — it's built into every layer of the application.

## When to Use

- Handling user input or data
- Implementing authentication/authorization
- Storing or transmitting sensitive data
- Working with third-party APIs
- Deploying to production

## OWASP Top 10 Coverage

### 1. Broken Access Control

Ensure proper authorization:

```typescript
// ❌ Bad: No authorization check
app.get('/api/users/:id', async (req, res) => {
  const user = await db.users.findByPk(req.params.id);
  res.json(user);
});

// ✅ Good: Authorization check
app.get('/api/users/:id',
  authenticate,
  requireRole(Role.ADMIN),
  async (req, res) => {
    const user = await db.users.findByPk(req.params.id);
    res.json(user);
  }
);

// ✅ Good: Resource ownership check
app.get('/api/users/:id/posts/:postId',
  authenticate,
  async (req, res) => {
    // Check if post belongs to user
    const post = await db.posts.findOne({
      where: { id: req.params.postId, userId: req.user.id }
    });

    if (!post) {
      return res.status(404).json({ error: 'Post not found' });
    }

    res.json(post);
  }
);
```

### 2. Cryptographic Failures

Properly encrypt sensitive data:

```typescript
// ❌ Bad: Storing passwords in plain text
async function createUser(email: string, password: string) {
  await db.users.create({ email, password });
}

// ✅ Good: Hashing passwords with bcrypt
import bcrypt from 'bcrypt';

async function createUser(email: string, password: string) {
  const hashedPassword = await bcrypt.hash(password, 10);
  await db.users.create({ email, password: hashedPassword });
}

// ✅ Good: Verifying passwords
async function verifyPassword(user: User, password: string): Promise<boolean> {
  return bcrypt.compare(password, user.password);
}

// ✅ Good: Encrypting sensitive data at rest
import crypto from 'crypto';

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY!; // 32 bytes
const IV_LENGTH = 16;

function encrypt(text: string): string {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY), iv);
  let encrypted = cipher.update(text);
  encrypted = Buffer.concat([encrypted, cipher.final()]);
  return iv.toString('hex') + ':' + encrypted.toString('hex');
}

function decrypt(text: string): string {
  const parts = text.split(':');
  const iv = Buffer.from(parts.shift()!, 'hex');
  const encrypted = Buffer.from(parts.join(':'), 'hex');
  const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY), iv);
  let decrypted = decipher.update(encrypted);
  decrypted = Buffer.concat([decrypted, decipher.final()]);
  return decrypted.toString();
}
```

### 3. Injection

Prevent SQL injection and XSS:

```typescript
// ❌ Bad: SQL injection vulnerability
const query = `SELECT * FROM users WHERE email = '${email}'`;
const user = await db.query(query);

// ✅ Good: Parameterized queries
const user = await db.query('SELECT * FROM users WHERE email = $1', [email]);

// ✅ Good: Using ORM
const user = await User.findOne({ where: { email } });

// ❌ Bad: XSS vulnerability
app.get('/search', (req, res) => {
  const query = req.query.q;
  res.send(`<div>Search results for: ${query}</div>`);
});

// ✅ Good: Sanitize output
import DOMPurify from 'dompurify';

app.get('/search', (req, res) => {
  const query = req.query.q as string;
  const sanitized = DOMPurify.sanitize(query);
  res.send(`<div>Search results for: ${sanitized}</div>`);
});
```

### 4. Insecure Design

Secure by design:

```typescript
// ✅ Good: Principle of least privilege
enum Permission {
  READ_USERS = 'read:users',
  WRITE_USERS = 'write:users',
  DELETE_USERS = 'delete:users'
}

// Check specific permissions, not just roles
function hasPermission(user: User, permission: Permission): boolean {
  return user.permissions.includes(permission);
}

// ✅ Good: Defense in depth
async function deleteUser(requester: User, targetId: string): Promise<void> {
  // Check 1: Is requester authenticated?
  if (!requester.id) {
    throw new UnauthorizedError();
  }

  // Check 2: Does requester have delete permission?
  if (!hasPermission(requester, Permission.DELETE_USERS)) {
    throw new ForbiddenError();
  }

  // Check 3: Is requester trying to delete themselves?
  if (requester.id === targetId) {
    throw new BadRequestError('Cannot delete yourself');
  }

  // Check 4: Does target user exist?
  const target = await User.findById(targetId);
  if (!target) {
    throw new NotFoundError();
  }

  // All checks passed, proceed with deletion
  await User.delete(targetId);
}
```

### 5. Security Misconfiguration

Secure configuration:

```typescript
// ✅ Good: Environment-specific config
const config = {
  development: {
    databaseUrl: 'localhost',
    debug: true,
    corsOrigin: '*'
  },
  production: {
    databaseUrl: process.env.DATABASE_URL,
    debug: false,
    corsOrigin: 'https://example.com'
  }
}[process.env.NODE_ENV];

// ✅ Good: Security headers
import helmet from 'helmet';

app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", 'data:', 'https:']
  }
}));

// ✅ Good: Rate limiting
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP'
});

app.use('/api/', limiter);

// ✅ Good: CORS configuration
const corsOptions = {
  origin: (origin: string | undefined, callback: any) => {
    const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [];
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));
```

### 6. Vulnerable and Outdated Components

Keep dependencies updated:

```bash
# Regularly check for vulnerabilities
npm audit
npm audit fix

# Use automated tools
npm install -g npm-check-updates
ncu -u

# Use Snyk for continuous monitoring
npm install -g snyk
snyk test
snyk monitor
```

### 7. Authentication Failures

Secure authentication:

```typescript
// ✅ Good: Secure password requirements
const passwordSchema = z.string()
  .min(12, 'Password must be at least 12 characters')
  .regex(/[a-z]/, 'Password must contain lowercase letter')
  .regex(/[A-Z]/, 'Password must contain uppercase letter')
  .regex(/\d/, 'Password must contain number')
  .regex(/[^a-zA-Z0-9]/, 'Password must contain special character');

// ✅ Good: Account lockout after failed attempts
const MAX_ATTEMPTS = 5;
const LOCKOUT_TIME = 15 * 60 * 1000; // 15 minutes

async function recordFailedAttempt(userId: string): Promise<void> {
  const attempts = await redis.incr(`login_attempts:${userId}`);
  if (attempts === 1) {
    await redis.expire(`login_attempts:${userId}`, LOCKOUT_TIME / 1000);
  }
  if (attempts >= MAX_ATTEMPTS) {
    await redis.set(`locked:${userId}`, '1', 'PX', LOCKOUT_TIME);
  }
}

async function isAccountLocked(userId: string): Promise<boolean> {
  return !!(await redis.exists(`locked:${userId}`));
}

async function clearFailedAttempts(userId: string): Promise<void> {
  await redis.del(`login_attempts:${userId}`);
  await redis.del(`locked:${userId}`);
}

// ✅ Good: Secure session management
import session from 'express-session';

app.use(session({
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production', // HTTPS only
    httpOnly: true, // Prevent XSS
    maxAge: 24 * 60 * 60 * 1000, // 24 hours
    sameSite: 'strict' // CSRF protection
  },
  name: 'sessionId' // Don't use default name
}));
```

### 8. Data Integrity Failures

Validate and verify data:

```typescript
// ✅ Good: Input validation
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(2).max(100).transform(val => val.trim()),
  age: z.number().int().min(0).max(150),
  website: z.string().url().optional()
});

// ✅ Good: Output encoding
function escapeHtml(unsafe: string): string {
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

// ✅ Good: Data validation at boundaries
async function createUser(data: unknown): Promise<User> {
  // Validate at input boundary
  const validated = userSchema.parse(data);

  // Sanitize for output
  const sanitized = {
    ...validated,
    name: escapeHtml(validated.name)
  };

  return User.create(sanitized);
}
```

### 9. Security Logging and Monitoring

Log security events:

```typescript
// ✅ Good: Security event logging
import winston from 'winston';

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'security.log' })
  ]
});

function logSecurityEvent(event: {
  type: string;
  userId?: string;
  ip: string;
  userAgent: string;
  details?: unknown;
}) {
  securityLogger.info({
    timestamp: new Date().toISOString(),
    ...event
  });
}

// Usage
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email });
  if (!user || !await verifyPassword(user, password)) {
    logSecurityEvent({
      type: 'failed_login',
      ip: req.ip,
      userAgent: req.get('user-agent') || '',
      details: { email }
    });
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  logSecurityEvent({
    type: 'successful_login',
    userId: user.id,
    ip: req.ip,
    userAgent: req.get('user-agent') || ''
  });

  res.json({ token: generateToken(user) });
});
```

### 10. Server-Side Request Forgery (SSRF)

Prevent SSRF attacks:

```typescript
// ❌ Bad: User-controlled URL
app.get('/proxy', async (req, res) => {
  const url = req.query.url;
  const response = await fetch(url);
  res.send(await response.text());
});

// ✅ Good: URL whitelist
const ALLOWED_HOSTS = [
  'api.example.com',
  'cdn.example.com'
];

function isUrlAllowed(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ALLOWED_HOSTS.includes(parsed.hostname);
  } catch {
    return false;
  }
}

app.get('/proxy', async (req, res) => {
  const url = req.query.url as string;

  if (!isUrlAllowed(url)) {
    return res.status(400).json({ error: 'URL not allowed' });
  }

  const response = await fetch(url);
  res.send(await response.text());
});
```

## Security Checklist

### Authentication & Authorization
- [ ] Passwords are hashed (bcrypt/argon2)
- [ ] Account lockout after failed attempts
- [ ] Secure session management
- [ ] Proper authorization checks
- [ ] JWT tokens are signed and verified

### Input Validation
- [ ] All user input is validated
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] File upload validation

### Data Protection
- [ ] Sensitive data encrypted at rest
- [ ] Sensitive data encrypted in transit (HTTPS)
- [ ] Secrets not in code
- [ ] Environment variables for config
- [ ] Secure key management

### Network Security
- [ ] CORS properly configured
- [ ] Rate limiting implemented
- [ ] Security headers set
- [ ] DDoS protection
- [ ] API authentication

### Monitoring & Logging
- [ ] Security events logged
- [ ] Failed login attempts tracked
- [ ] Suspicious activity alerts
- [ ] Log integrity protected
- [ ] Regular security audits

## Common Mistakes

| Mistake | Risk | Solution |
|---|---|---|
| Hardcoded secrets | Credentials exposed | Use environment variables |
| Plain text passwords | User accounts compromised | Hash passwords |
| No input validation | Injection attacks | Validate all input |
| Missing CORS config | CSRF attacks | Configure CORS properly |
| Debug mode in production | Information leakage | Disable debug in production |

## Coaching Notes

> **ABC - Always Be Coaching:** Security hardening teaches you to treat every user input as hostile and every layer as a defense opportunity -- because one gap is all an attacker needs.

1. **Validate at every boundary, trust nothing:** Input from users, APIs, and even your own database should be validated at the point of entry. Defense in depth means if one check fails, the next one catches it.
2. **Secrets belong in environment variables, never in code:** A single committed API key in a public repo can be exploited within minutes by automated scanners. If you can grep a secret in source, it is already compromised.
3. **Rate limiting and logging are your alarm system:** Secure code prevents attacks, but rate limiting slows them down and security logging tells you they happened. Without monitoring, you are secure in theory but blind in practice.

## Verification

After security hardening:

- [ ] OWASP Top 10 vulnerabilities addressed
- [ ] Authentication is secure
- [ ] Authorization is implemented
- [ ] Input validation is comprehensive
- [ ] Output encoding is applied
- [ ] Secrets are not hardcoded
- [ ] HTTPS is enforced
- [ ] Security headers are set
- [ ] Rate limiting is configured
- [ ] Security logging is implemented
- [ ] Dependencies are updated
- [ ] Security audit is passed

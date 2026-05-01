---
name: ci-cd-automation
description: CI/CD automation with quality gates and feature flags. Use when automating deployments, ensuring code quality, or managing releases.
version: "2.0.0"
category: "workflow"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["CI/CD", "pipeline", "deploy", "feature flags"]
intent: "Automate the path from commit to production so that quality is enforced by the pipeline, not by human memory."
scenarios:
  - "Setting up a GitHub Actions CI pipeline that runs linting, tests, coverage checks, and security audits on every pull request"
  - "Implementing a canary deployment strategy that routes 10% of traffic to the new version and auto-rolls back on errors"
  - "Adding feature flags to progressively roll out a new checkout flow to users by percentage"
best_for: "CI pipeline setup, deployment automation, quality gates, feature flag management, rollback strategies"
estimated_time: "20-45 min"
anti_patterns:
  - "Skipping quality gates to make the pipeline faster, letting bugs reach production"
  - "Deploying without a rollback plan and scrambling when something breaks at 2 AM"
  - "Hardcoding secrets in pipeline configuration instead of using secret management"
related_skills: ["git-workflow", "e2e-testing", "security-audit"]
---

# CI/CD Automation

## Overview

CI/CD automation ensures code quality, enables frequent deployments, and reduces manual errors. Quality gates prevent bad code from reaching production, while feature flags enable safe rollouts.

## When to Use

- Automating build and test processes
- Setting up quality gates
- Managing deployments
- Implementing feature flags
- Ensuring code quality

## CI Pipeline

### Pipeline Stages

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Build ──→ Test ──→ Quality Gate ──→ Deploy ──→ Verify │
│   ↓         ↓          ↓              ↓          ↓      │
│ Compile  Unit/Int   Coverage/Lint    Staging    Smoke  │
│ Bundle   E2E        Security        Canary     Tests   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### GitHub Actions Example

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run type check
        run: npm run type-check

      - name: Run unit tests
        run: npm run test:unit -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

      - name: Build
        run: npm run build

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Security audit
        run: npm audit --audit-level=high
```

## Quality Gates

### 1. Code Coverage

```yaml
# Require minimum coverage
- name: Check coverage
  run: |
    COVERAGE=$(npm run test:coverage -- --json | jq '.total.lines.pct')
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "Coverage ${COVERAGE}% is below 80%"
      exit 1
    fi
```

### 2. Linting

```yaml
# Lint with threshold
- name: Lint
  run: |
    npm run lint -- --max-warnings 0
```

### 3. Type Checking

```yaml
# Strict type checking
- name: Type check
  run: |
    npx tsc --noEmit --strict
```

### 4. Security Scanning

```yaml
# Security audit
- name: Security audit
  run: |
    npm audit --audit-level=moderate

# Snyk security scan
- name: Run Snyk
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

## CD Pipeline

### Deployment Strategy

```yaml
# .github/workflows/cd.yml
name: CD

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build
        env:
          CI: true

      - name: Deploy to staging
        run: |
          npm run deploy:staging
        env:
          DEPLOY_KEY: ${{ secrets.STAGING_DEPLOY_KEY }}

      - name: Run smoke tests
        run: |
          npm run test:smoke -- --env=staging

      - name: Deploy to production
        if: success()
        run: |
          npm run deploy:production
        env:
          DEPLOY_KEY: ${{ secrets.PROD_DEPLOY_KEY }}

      - name: Verify deployment
        run: |
          npm run verify:production
```

## Feature Flags

### Feature Flag Implementation

```typescript
// ✅ Good: Feature flag service
class FeatureFlagService {
  private flags: Map<string, boolean> = new Map();

  constructor() {
    // Load flags from environment or config
    this.flags.set('new-ui', process.env.FEATURE_NEW_UI === 'true');
    this.flags.set('advanced-search', process.env.FEATURE_ADVANCED_SEARCH === 'true');
  }

  isEnabled(flag: string): boolean {
    return this.flags.get(flag) ?? false;
  }

  enable(flag: string): void {
    this.flags.set(flag, true);
  }

  disable(flag: string): void {
    this.flags.set(flag, false);
  }
}

// Usage
const featureFlags = new FeatureFlagService();

if (featureFlags.isEnabled('new-ui')) {
  return <NewUI />;
} else {
  return <OldUI />;
}
```

### Progressive Rollout

```typescript
// ✅ Good: Progressive rollout by user
function isFeatureEnabled(userId: string, feature: string): boolean {
  const flag = featureFlags.get(feature);

  if (!flag || !flag.enabled) {
    return false;
  }

  // Progressive rollout based on percentage
  const hash = hashUserId(userId);
  const threshold = flag.rolloutPercentage ?? 0;

  return hash < threshold;
}

// Usage
if (isFeatureEnabled(user.id, 'new-checkout')) {
  return <NewCheckoutFlow />;
} else {
  return <OldCheckoutFlow />;
}
```

## Deployment Strategies

### 1. Blue-Green Deployment

```yaml
# Blue-Green deployment
- name: Deploy to green
  run: |
    # Deploy new version to green environment
    kubectl apply -f k8s/green-deployment.yaml

    # Wait for green to be ready
    kubectl rollout status deployment/green

- name: Run smoke tests on green
  run: |
    npm run test:smoke -- --env=green

- name: Switch traffic to green
  run: |
    # Update service to point to green
    kubectl patch service app -p '{"spec":{"selector":{"version":"green"}}}'
```

### 2. Canary Deployment

```yaml
# Canary deployment
- name: Deploy canary
  run: |
    # Deploy canary with 10% traffic
    kubectl apply -f k8s/canary-deployment.yaml

- name: Monitor canary
  run: |
    # Wait and monitor metrics
    sleep 300

    # Check error rates
    ERROR_RATE=$(get-error-rate canary)
    if (( $(echo "$ERROR_RATE > 0.01" | bc -l) )); then
      echo "Canary error rate too high, rolling back"
      kubectl delete -f k8s/canary-deployment.yaml
      exit 1
    fi

- name: Rollout to rest
  run: |
    # Rollout to remaining 90%
    kubectl apply -f k8s/production-deployment.yaml
```

### 3. Rolling Deployment

```yaml
# Rolling deployment
- name: Rolling update
  run: |
    # Update deployment with rolling update strategy
    kubectl set image deployment/app \
      app=registry.example.com/app:${{ github.sha }}

    # Wait for rollout to complete
    kubectl rollout status deployment/app
```

## Monitoring and Rollback

### Deployment Verification

```typescript
// ✅ Good: Deployment verification
async function verifyDeployment(environment: string): Promise<boolean> {
  const checks = [
    checkHealth(environment),
    checkMetrics(environment),
    runSmokeTests(environment)
  ];

  const results = await Promise.allSettled(checks);
  const failures = results.filter(r => r.status === 'rejected');

  if (failures.length > 0) {
    console.error('Deployment verification failed:', failures);
    return false;
  }

  return true;
}

// Rollback if verification fails
async function deployWithRollback(environment: string): Promise<void> {
  const previousVersion = await getCurrentVersion(environment);

  try {
    await deploy(environment, newVersion);
    const verified = await verifyDeployment(environment);

    if (!verified) {
      throw new Error('Deployment verification failed');
    }
  } catch (error) {
    console.error('Deployment failed, rolling back:', error);
    await rollback(environment, previousVersion);
    throw error;
  }
}
```

## Best Practices

### 1. Immutable Infrastructure

```yaml
# Use immutable infrastructure
- name: Build Docker image
  run: |
    docker build -t app:${{ github.sha }} .

- name: Push to registry
  run: |
    docker tag app:${{ github.sha }} registry.example.com/app:${{ github.sha }}
    docker push registry.example.com/app:${{ github.sha }}
```

### 2. Infrastructure as Code

```yaml
# Use IaC for deployments
- name: Apply infrastructure
  run: |
    terraform apply -auto-approve
```

### 3. Secrets Management

```yaml
# Never log secrets
- name: Deploy
  run: |
    echo "${{ secrets.DEPLOY_KEY }}" | ssh-add -
    rsync -avz --delete ./ user@server:/app
```

## Coaching Notes

> **ABC - Always Be Coaching:** A CI/CD pipeline is your team's most reliable reviewer -- it never skips steps, never gets tired, and never says 'it works on my machine.'

1. **Quality Gates Are Non-Negotiable:** If the pipeline says 'fail,' the code does not ship. Coverage thresholds, lint rules, and security audits exist because human reviewers miss things. Respect the gate or remove it deliberately -- never bypass it.
2. **Deploy Incrementally, Observe Constantly:** Push to 1% of traffic, watch for errors, then expand. A canary deployment that catches a 1% error rate in the first five minutes saves you from a 100% outage later. Always have a one-command rollback ready.
3. **Feature Flags Buy You Time and Safety:** Instead of a risky big-bang release, wrap new features in flags. Roll them out to internal users first, then a small percentage of real users, then everyone. If something breaks, flip the flag off in seconds, not hours.

## Common Mistakes

| Mistake | Problem | Solution |
|---|---|---|
| No quality gates | Bad code reaches production | Add quality gates |
| Manual deployments | Slow, error-prone | Automate everything |
| No rollback plan | Downtime when issues occur | Always have rollback plan |
| Skip tests to save time | More bugs later | Never skip tests |
| No monitoring | Can't detect issues | Add monitoring and alerts |

## Verification

After CI/CD automation:

- [ ] Pipeline runs automatically
- [ ] Quality gates configured
- [ ] Tests pass before deployment
- [ ] Feature flags implemented
- [ ] Deployment strategy defined
- [ ] Rollback plan exists
- [ ] Monitoring configured
- [ ] Secrets managed properly

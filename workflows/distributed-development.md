---
name: distributed-development
description: Coordinate distributed agents across tmux sessions for multi-domain feature development
version: "2.0.0"
category: "primary"
origin: "agent-skills"
agents_used:
  - "techlead-orchestrator"
  - "database-expert"
  - "backend-expert"
  - "frontend-expert"
  - "code-reviewer"
  - "security-reviewer"
skills_used:
  - "spec-driven-development"
  - "writing-plans"
  - "incremental-implementation"
  - "code-review"
  - "security-audit"
  - "e2e-testing"
estimated_time: "7-14 hours"
---

# Distributed Development Workflow

## Overview

This workflow coordinates distributed agents across separate tmux sessions to develop features that span multiple domains (backend API + frontend UI + database schema).

**⚠️ CRITICAL:** Tech Lead Orchestrator MUST delegate all implementation work to agent sessions. See [Delegation Protocol](../protocols/delegation-protocol.md)

## When to Use

```
"Workflow: em-distributed-development - Develop user profile feature: BE API + FE UI"
"Workflow: em-distributed-development - Implement payment flow: DB + BE + FE"
"Workflow: em-distributed-development - Build notification system: multiple services"
```

**Use Cases:**
- Full-stack feature development
- Multi-service feature implementation
- API-first development with separate FE/BE
- Complex features requiring domain expertise

## Prerequisites

1. **Distributed orchestration running:**
```bash
./scripts/distributed-orchestrator.sh start
```

2. **Tech Lead Orchestrator active:**
```bash
# In techlead session
"Agent: em-techlead-orchestrator - Coordinate distributed development..."
```

3. **All agent sessions ready:**
```bash
# Verify sessions exist
tmux list-windows -t claude-work
# Should show: techlead, backend, frontend, database
```

## Lifecycle

DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE

### Phase Mapping

| Lifecycle Phase | Workflow Stage |
|-----------------|----------------|
| DEFINE | Requirements Analysis & Task Breakdown (Phase 1) |
| PLAN | Design & Contract (Phase 3) |
| BUILD | Backend API Development + Frontend UI Development (Phase 3-4) |
| VERIFY | Integration & Testing (Phase 5) |
| REVIEW | Consolidation & Handoff + Code Review + Security Review (Phase 6-7) |
| SHIP | Approval & Merge (Phase 7) |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Feature requirements analyzed
- [ ] Scope determined (backend, frontend, database)
- [ ] Agent selection completed
- [ ] Development plan created
PASS → proceed | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Database schema designed and reviewed
- [ ] API contract defined
- [ ] Frontend components specified
- [ ] Execution strategy determined (sequential/parallel)
PASS → proceed | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Backend API implemented
- [ ] Frontend UI implemented
- [ ] Database migrations created
- [ ] All agent reports submitted
PASS → proceed | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Integration tests passing
- [ ] E2E tests passing
- [ ] API contract verified
- [ ] Cross-agent dependencies validated
PASS → proceed | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Code review approved
- [ ] Security review approved
- [ ] Consolidated report generated
- [ ] Documentation complete
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Process

### Phase 1: Requirements Analysis & Task Breakdown

**Step 1:** Receive feature requirements from user

**Step 2:** Tech Lead analyzes requirements to determine scope

```yaml
feature_analysis:
  title: "[Feature Title]"
  description: "[User's feature request]"

  scope_analysis:
    - backend: "API endpoints needed"
    - database: "Schema changes required"
    - frontend: "UI components needed"
    - integration: "How parts connect"

  complexity:
    - low: "Single domain, CRUD operations"
    - medium: "2-3 domains, some complexity"
    - high: "4+ domains, complex interactions"

  agent_selection:
    - if database_changes: "database-expert"
    - if api_needed: "backend-expert"
    - if_ui_needed: "frontend-expert"
    - if_complex: "architect"
    - if_user_facing: "product-manager"
```

**⚠️ IMPORTANT:** Tech Lead ONLY analyzes and plans. NO implementation at this stage!

**Step 3:** Create development plan

```yaml
development_plan:
  task_id: "DEV-2026-001"
  title: "User Profile Feature"

  agents:
    - name: "database-expert"
      session: "database"
      priority: 1
      task: "Design user profile schema"
      dependencies: []

    - name: "backend-expert"
      session: "backend"
      priority: 2
      task: "Implement user profile CRUD API"
      dependencies:
        - agent: "database-expert"
          wait_for: "schema_design"

    - name: "frontend-expert"
      session: "frontend"
      priority: 3
      task: "Implement user profile UI"
      dependencies:
        - agent: "backend-expert"
          wait_for: "api_specification"

  execution_strategy: "sequential"  # Database → Backend → Frontend

  sync_points:
    - name: "API Contract Review"
      after: "backend_api_design"
      participants: ["database-expert", "backend-expert", "architect"]

    - name: "Integration Test"
      after: "frontend_implementation"
      participants: ["backend-expert", "frontend-expert"]

    - name: "E2E Validation"
      after: "all_implementation"
      participants: ["all"]

  expected_outputs:
    - from: "database-expert"
      format: "migration"
      location: "/db/migrations/20260419_create_user_profile.sql"

    - from: "backend-expert"
      format: "code"
      location: "/backend/api/user-profile.js"

    - from: "frontend-expert"
      format: "code"
      location: "/frontend/components/UserProfile.tsx"

  delegation_protocol: "protocols/delegation-protocol.md"  # ⚠️ CRITICAL
```

---

### Phase 2: Delegate Tasks to Agent Sessions ⚠️ CRITICAL

**⚠️ TECH LEAD DELEGATION MANDATE:**

At this phase, Tech Lead MUST delegate ALL implementation work to appropriate agent sessions. **TECH LEAD MUST NOT IMPLEMENT ANYTHING!**

See full protocol: [Delegation Protocol](../protocols/delegation-protocol.md)

**Step 1:** Assign tasks to sessions

For each agent in development plan, send task assignment:

```bash
# Example: Assign task to backend session
tmux send-keys -t claude-work:backend "Agent: em-backend-expert Implement user profile CRUD API" C-m

# Example: Assign task to database session
tmux send-keys -t claude-work:database "Agent: em-database-expert Design user profile schema" C-m

# Example: Assign task to frontend session
tmux send-keys -t claude-work:frontend "Agent: em-frontend-expert Implement user profile UI" C-m
```

**Step 2:** Monitor delegation

```bash
# Check if agents are working
tmux list-windows -t claude-work

# Monitor progress from each session
# Check for status updates in /tmp/claude-work-queue/to-techlead/

# Verify agents are working (not Tech Lead!)
```

**Step 3:** Wait for agent reports

DO NOT proceed until agents complete their work and submit reports to:
- `/tmp/claude-work-reports/database/`
- `/tmp/claude-work-reports/backend/`
- `/tmp/claude-work-reports/frontend/`

**⚠️ VIOLATION WARNING:**

If you find yourself writing code or implementing:
→ **STOP!** This is agent work, not Tech Lead work
→ Delegate to appropriate session
→ Wait for their report
→ Then consolidate findings

---

### Phase 3: Design & Contract

**Step 4:** Database Expert designs schema

```yaml
# Task assignment
message_type: task_assignment
to: database
task_id: "DEV-2026-001-DB"

task:
  title: "Design user profile database schema"
  description: |
    Design schema for user profile feature including:
    - Profile information (name, bio, avatar)
    - Privacy settings
    - Profile visibility

  deliverables:
    - schema_design: "ER diagram or SQL DDL"
    - migration_plan: "Zero-downtime migration strategy"
    - indexes: "Required indexes for performance"

  output:
    format: "design_document"
    location: "/tmp/claude-work-reports/database/user-profile-schema-20260419.md"
```

**Step 5:** Database Expert completes schema design

```markdown
# Database Design: User Profile Schema

## Schema Design

```sql
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(100),
    bio TEXT,
    avatar_url VARCHAR(500),
    privacy_settings JSONB DEFAULT '{"profile_visibility":"public"}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id)
);

CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_visibility ON user_profiles((privacy_settings->>'profile_visibility'));
```

## Migration Plan

1. Create table (no downtime)
2. Backfill existing users (background job)
3. Add unique constraint (CONCURRENTLY)

## API Requirements

Backend will need:
- GET /api/users/:id/profile
- PUT /api/users/:id/profile
- PATCH /api/users/:id/profile
```

**Step 6:** Tech Lead shares schema with Backend Expert

```yaml
message_type: context_share
from: techlead
to: backend
context:
  type: design_document
  source_agent: database-expert
  content: |
    Database schema designed for user profiles.
    Table: user_profiles with profile_visibility index.
    Migration plan included.

action_required: "Design API endpoints based on this schema. Review migration plan for compatibility."
```

---

### Phase 3: Backend API Development

**Step 7:** Backend Expert designs and implements API

```yaml
# Task assignment
message_type: task_assignment
to: backend
task_id: "DEV-2026-001-BE"

task:
  title: "Implement user profile CRUD API"
  description: |
    Based on database schema, implement REST API for user profiles.

  endpoints:
    - GET /api/users/:id/profile - Get user profile
    - PUT /api/users/:id/profile - Update profile (full)
    - PATCH /api/users/:id/profile - Update profile (partial)

  requirements:
    - authentication: "JWT token required"
    - authorization: "Users can only edit own profile"
    - validation: "Input validation for all fields"
    - error_handling: "Proper error responses"

  deliverables:
    - api_implementation: "Express/Next.js API routes"
    - api_specification: "OpenAPI/Swagger doc"
    - tests: "Unit tests for API"

  output:
    format: "code"
    location: "/backend/api/user-profile.js"
```

**Step 8:** Backend Expert implements API

```typescript
// backend/api/user-profile.js

import { authenticate, authorize } from '../middleware/auth.js';
import { validateProfile } from '../validation/profile.js';

// GET /api/users/:id/profile
router.get('/users/:id/profile', authenticate, async (req, res) => {
  try {
    const profile = await db.userProfiles.findByUserId(req.params.id);

    // Check privacy settings
    if (profile.privacy_settings.profile_visibility === 'private' &&
        req.user.userId !== req.params.id) {
      return res.status(403).json({ error: 'Private profile' });
    }

    res.json(profile);
  } catch (error) {
    res.status(404).json({ error: 'Profile not found' });
  }
});

// PUT /api/users/:id/profile
router.put('/users/:id/profile',
  authenticate,
  authorize('owner', 'userId', ':id'),
  validateProfile,
  async (req, res) => {
    try {
      const profile = await db.userProfiles.upsert(req.params.id, req.body);
      res.json(profile);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update profile' });
    }
  }
);

// PATCH /api/users/:id/profile
router.patch('/users/:id/profile',
  authenticate,
  authorize('owner', 'userId', ':id'),
  validateProfile,
  async (req, res) => {
    try {
      const profile = await db.userProfiles.update(req.params.id, req.body);
      res.json(profile);
    } catch (error) {
      res.status(500).json({ error: 'Failed to update profile' });
    }
  }
);
```

**API Specification:**
```yaml
openapi: 3.0.0
info:
  title: User Profile API
  version: 1.0.0

paths:
  /api/users/{id}/profile:
    get:
      summary: Get user profile
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Profile retrieved
        '404':
          description: Profile not found

    put:
      summary: Update profile (full)
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserProfile'
      responses:
        '200':
          description: Profile updated
```

**Step 9:** Backend Expert notifies Tech Lead

```yaml
message_type: completion_notification
from: backend
task_id: "DEV-2026-001-BE"

completion:
  status: success
  summary: "User profile CRUD API implemented with auth, validation, and error handling"

  next_actions:
    - "Frontend agent: Implement profile UI using this API"
    - "Tech Lead: Review API specification before frontend starts"

  artifacts:
    - path: "/backend/api/user-profile.js"
      description: "API implementation"
    - path: "/docs/api/user-profile.yaml"
      description: "OpenAPI specification"
```

---

### Phase 4: Frontend UI Development

**Step 10:** Tech Lead shares API spec with Frontend Expert

```yaml
message_type: context_share
from: techlead
to: frontend
context:
  type: api_specification
  source_agent: backend-expert
  content: |
    Backend API complete. Endpoints:
    - GET /api/users/:id/profile
    - PUT /api/users/:id/profile
    - PATCH /api/users/:id/profile

    Authentication: Bearer token
    Privacy: Users can only edit own profile

action_required: "Implement profile UI using these endpoints. Handle auth and privacy."
```

**Step 11:** Frontend Expert implements UI

```yaml
# Task assignment
message_type: task_assignment
to: frontend
task_id: "DEV-2026-001-FE"

task:
  title: "Implement user profile UI"
  description: |
    Create user profile interface using the backend API.

  components:
    - UserProfileView: "Display profile information"
    - ProfileEditor: "Edit profile form"
    - PrivacySettings: "Configure profile visibility"

  requirements:
    - authentication: "Redirect if not logged in"
    - authorization: "Only show edit button for own profile"
    - error_handling: "Display API errors to user"
    - loading_states: "Show skeleton while loading"
    - responsive: "Mobile and desktop layouts"

  deliverables:
    - components: "React components"
    - hooks: "Custom hooks for API calls"
    - types: "TypeScript types"

  output:
    format: "code"
    location: "/frontend/components/user-profile/"
```

**Implementation:**
```typescript
// frontend/components/user-profile/UserProfileView.tsx

import { useUserProfile } from '../../hooks/useUserProfile';
import { ProfileEditor } from './ProfileEditor';

export function UserProfileView({ userId }) {
  const { profile, loading, error, isOwner } = useUserProfile(userId);

  if (loading) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;
  if (!profile) return <NotFound />;

  return (
    <div className="profile-container">
      <Avatar src={profile.avatarUrl} alt={profile.displayName} />
      <h1>{profile.displayName}</h1>
      <p>{profile.bio}</p>

      {isOwner && (
        <ProfileEditor profile={profile} onSave={handleSave} />
      )}
    </div>
  );
}

// frontend/hooks/useUserProfile.ts

import { useQuery, useMutation } from '@tanstack/react-query';

export function useUserProfile(userId: string) {
  const { user } = useAuth();

  const { data: profile, isLoading, error } = useQuery({
    queryKey: ['user-profile', userId],
    queryFn: () => fetch(`/api/users/${userId}/profile`).then(r => r.json()),
  });

  const isOwner = user?.userId === userId;

  return { profile, loading: isLoading, error, isOwner };
}
```

---

### Phase 5: Integration & Testing

**Step 12:** Integration sync point

```yaml
sync_point: "API Contract Review"
participants: ["database-expert", "backend-expert", "frontend-expert"]

agenda:
  - "Review API endpoints match database schema"
  - "Verify frontend uses correct API calls"
  - "Check error handling across all layers"
  - "Validate data types match BE/FE"

outcome:
  approved: true
  blockers: []
  minor_issues:
    - "Frontend should handle 403 for private profiles"
    - "Backend should add rate limiting"
```

**Step 13:** Integration testing

```typescript
// Integration test example
describe('User Profile Flow', () => {
  it('should allow user to view and edit profile', async () => {
    // Login
    const user = await loginAs('test@example.com');

    // View profile
    const profile = await getUserProfile(user.id);
    expect(profile.displayName).toBe('Test User');

    // Edit profile
    const updated = await updateUserProfile(user.id, {
      displayName: 'Updated Name',
      bio: 'Updated bio'
    });
    expect(updated.displayName).toBe('Updated Name');

    // Verify update persisted
    const reloaded = await getUserProfile(user.id);
    expect(reloaded.displayName).toBe('Updated Name');
  });

  it('should prevent editing other users profiles', async () => {
    const user1 = await loginAs('user1@example.com');
    const user2 = await loginAs('user2@example.com');

    // Try to edit user2's profile as user1
    await expect(
      updateUserProfile(user2.id, { displayName: 'Hacked' })
    ).rejects.toThrow('Unauthorized');
  });
});
```

**Step 14:** E2E validation

```typescript
// E2E test with Playwright
test('user profile E2E flow', async ({ page }) => {
  // Login
  await page.goto('/login');
  await page.fill('[name=email]', 'test@example.com');
  await page.fill('[name=password]', 'password');
  await page.click('[type=submit]');

  // Navigate to profile
  await page.goto('/profile');

  // Verify profile displays
  await expect(page.locator('h1')).toContainText('Test User');

  // Click edit button
  await page.click('[data-testid=edit-profile]');

  // Update profile
  await page.fill('[name=displayName]', 'Updated Name');
  await page.fill('[name=bio]', 'Updated bio');
  await page.click('[data-testid=save-profile]');

  // Verify success message
  await expect(page.locator('[data-testid=toast]'))
    .toContainText('Profile updated');

  // Verify update persisted
  await page.reload();
  await expect(page.locator('h1')).toContainText('Updated Name');
});
```

---

### Phase 6: Consolidation & Handoff

**Step 15:** Collect reports from all agents

```bash
./scripts/consolidate-reports.sh collect database backend frontend
```

**Step 16:** Create consolidated feature report

```markdown
# Consolidated Feature Development Report: User Profile

**Report ID:** TEAM-RPT-DEV-2026-001
**Feature:** User Profile
**Agents:** Database, Backend, Frontend

## Executive Summary

✅ Feature complete: User profile with CRUD operations, privacy settings, and responsive UI.

## Implementation Summary

### Database Layer
- **Schema:** user_profiles table with privacy settings
- **Migration:** Zero-downtime migration plan
- **Performance:** Indexes on user_id and visibility

### Backend API
- **Endpoints:** GET, PUT, PATCH /api/users/:id/profile
- **Authentication:** JWT required
- **Authorization:** Owner-only editing
- **Validation:** Input validation on all fields

### Frontend UI
- **Components:** ProfileView, ProfileEditor, PrivacySettings
- **State:** React Query for server state
- **Auth:** Redirect if not logged in
- **Responsive:** Mobile and desktop layouts

## Integration Results

### API Contract Review
✅ API matches database schema
✅ Frontend uses correct endpoints
⚠️ Minor: Frontend needs 403 handling
⚠️ Minor: Backend needs rate limiting

### Test Results
- Unit tests: ✅ Passing (47/47)
- Integration tests: ✅ Passing (12/12)
- E2E tests: ✅ Passing (8/8)

## Artifacts

- Database: `/db/migrations/20260419_create_user_profile.sql`
- Backend: `/backend/api/user-profile.js`
- Frontend: `/frontend/components/user-profile/`
- Tests: `/tests/integration/user-profile.test.ts`

## Deployment Checklist

- [ ] Database migration reviewed
- [ ] Backend code reviewed
- [ ] Frontend code reviewed
- [ ] All tests passing
- [ ] API documentation updated
- [ ] E2E tests passing in staging
- [ ] Performance tested
- [ ] Security review completed

## Recommendations

### Before Merge
1. Add 403 handling in frontend
2. Add rate limiting in backend
3. Update API documentation

### Post-Deploy
1. Monitor API performance
2. Check error rates
3. User testing

## Next Steps

1. **Code Review:** Senior Code Reviewer reviews implementation
2. **Security Review:** Security Reviewer checks auth/privacy
3. **Staging Deploy:** Deploy to staging for testing
4. **Production Deploy:** Merge to main

---

**Status:** ✅ READY FOR REVIEW
**Confidence:** High
**Risk Level:** Low
```

---

### Phase 7: Approval & Merge

**Step 17:** Code review

```bash
# In techlead session
"Agent: em-code-reviewer - Review user profile feature implementation"
```

**Step 18:** Security review

```bash
# In techlead session
"Agent: em-security-reviewer - Review auth and privacy implementation"
```

**Step 19:** Final approval

```yaml
approval_checklist:
  code_review: ✅ approved
  security_review: ✅ approved
  integration_tests: ✅ passing
  e2e_tests: ✅ passing
  documentation: ✅ complete

final_decision: "APPROVED FOR MERGE"
deployment_target: "staging → production"
```

---

## Workflow Commands

### Start Development

```bash
# 1. Start distributed orchestration
./scripts/distributed-orchestrator.sh start

# 2. Trigger Tech Lead
# In techlead session:
"Agent: em-techlead-orchestrator - Coordinate distributed development for user profile feature: DB schema + BE API + FE UI"

# 3. Tech Lead will:
# - Analyze requirements
# - Create development plan
# - Coordinate agents sequentially
# - Manage sync points
# - Consolidate implementation
```

### Monitor Progress

```bash
# Check session status
./scripts/session-manager.sh status

# Monitor specific agent
./scripts/session-manager.sh watch backend

# Check sync points
./scripts/session-manager.sh broadcast "Sync point: API Contract Review starting now"
```

### Collect Results

```bash
# Collect all reports
./scripts/consolidate-reports.sh collect

# Consolidate feature report
./scripts/consolidate-reports.sh consolidated /tmp/claude-work-reports/techlead/user-profile-feature.md

# View artifacts
ls -la /tmp/claude-work-reports/*/
```

---

## Success Criteria

- [ ] Feature requirements analyzed
- [ ] Database schema designed
- [ ] Backend API implemented
- [ ] Frontend UI implemented
- [ ] Integration tested
- [ ] E2E validated
- [ ] Code reviewed
- [ ] Security reviewed
- [ ] Documentation complete
- [ ] Ready for deployment

---

## Estimated Timeline

| Phase | Duration |
|-------|----------|
| Requirements Analysis | 30 min |
| Design & Contract | 1-2 hours |
| Backend Development | 2-4 hours |
| Frontend Development | 2-4 hours |
| Integration & Testing | 1-2 hours |
| Consolidation | 30 min |
| **Total** | **7-14 hours** |

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Compatible with:** EM-Team Distributed Orchestration

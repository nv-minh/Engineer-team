---
name: basic-design
description: "Creates a formal 基本設計 (Basic Design Document) — the system-level design artifact required before detailed implementation. Use when starting a new project or major feature, especially in Japanese outsourcing contexts that require formal design sign-off before coding begins."
version: "1.0.0"
category: "foundation"
origin: "EM-Team (Japanese outsourcing)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "basic design"
  - "基本設計"
  - "system design document"
  - "design before coding"
  - "formal design"
  - "architecture spec"
intent: "Produce a formal Basic Design Document that captures system architecture, data models, API interfaces, and non-functional requirements at a level sufficient for client approval before implementation begins."
scenarios:
  - "Starting a new project in a Japanese outsourcing context requiring formal sign-off"
  - "Major feature that touches multiple subsystems and needs upfront design agreement"
  - "Client needs a design document to review before development budget is committed"
  - "Onboarding a new team member who needs to understand the system architecture"
best_for: "New projects, major features, Japanese outsourcing contracts, multi-team coordination"
estimated_time: "2-4 hours"
anti_patterns:
  - "Writing code before the Basic Design is reviewed and signed off"
  - "Jumping straight to Detailed Design without system-level agreement"
  - "Vague architecture diagrams with no data flow or interface definitions"
  - "Skipping non-functional requirements (performance, security targets)"
related_skills:
  - domain-modeling
  - spec-driven-development
  - diagram
  - writing-plans
---

# Basic Design (基本設計)

## Overview

The Basic Design Document (基本設計書) is the system-level design artifact that bridges domain modeling and detailed implementation. It defines **what the system does** at a structural level — architecture, data flows, API boundaries, and non-functional constraints — at a level of detail sufficient for client review and sign-off before development begins.

In Japanese outsourcing practice, Basic Design is a required gate: **no detailed design or implementation starts without client approval of the Basic Design.**

## When to Use

- Starting a new system or major subsystem
- Major feature that spans multiple services or bounded contexts
- Client requires formal design documentation before committing development resources
- Onboarding a new team or handing off to an offshore team
- Architecture decision requires stakeholder alignment before coding

**When NOT to Use:** Small features within a single component, bug fixes, purely internal refactors with no interface changes.

## When NOT to Use

- Bug fixes (no design document needed)
- Single-component changes with no interface impact
- Internal refactors that don't change external behavior

## Anti-Patterns

- Starting code before the design is reviewed — this is the most common and most expensive mistake
- Using the domain model directly as the design document — domain models describe concepts, not system boundaries
- Writing class diagrams before agreeing on API interfaces — start with system boundaries, then drill down
- Omitting non-functional requirements — performance, security, and reliability targets must be in the design

## Process

### Step 1: Gather Inputs

Collect all prerequisite artifacts:

```
Required inputs:
- [ ] Domain model (bounded contexts, entities, ubiquitous language)
- [ ] Requirements document (FR-*, NFR-*)
- [ ] Tech stack constraints
- [ ] Performance/SLA targets
- [ ] Security/compliance requirements
```

Ask clarifying questions if inputs are missing:
```
Before writing the Basic Design, I need to clarify:
1. What are the performance targets? (API response time, throughput)
2. What external systems does this integrate with?
3. Are there security/compliance constraints? (data residency, encryption)
4. What is the expected data volume? (users, records, requests/day)
❓ Confirm or correct these assumptions before I proceed.
```

### Step 2: Write the Basic Design Document

Create `docs/BASIC-DESIGN.md` with the following sections:

---

**Basic Design Document Template:**

```markdown
# Basic Design Document (基本設計書)
**Project:** [Project Name]
**Version:** 1.0.0
**Date:** YYYY-MM-DD
**Author:** [Author]
**Status:** Draft | Under Review | Approved

---

## 1. System Overview (システム概要)

### 1.1 Purpose
[Why this system exists. What problem it solves. 2-3 sentences.]

### 1.2 Scope
[What is included. What is explicitly out of scope.]

### 1.3 System Context Diagram
[C4-level diagram: this system in relation to external systems, users, and data stores]

```
[User] ──→ [This System] ──→ [Database]
                    └──→ [External Payment API]
                    └──→ [Notification Service]
```

### 1.4 Key Users
| User Type | Description | Primary Actions |
|---|---|---|
| [Admin] | [Manages...] | [Create, update, delete...] |
| [End User] | [Uses...] | [View, search, purchase...] |

---

## 2. Architecture Overview (アーキテクチャ概要)

### 2.1 Architecture Pattern
[Monolith / Microservices / Modular Monolith / Event-Driven — and why]

### 2.2 Component Diagram
[High-level components and their relationships]

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Frontend   │───→│   API GW    │───→│  Backend    │
│  (Next.js)  │    │  (nginx)    │    │  (NestJS)   │
└─────────────┘    └─────────────┘    └─────────────┘
                                             │
                              ┌──────────────┤
                              ▼              ▼
                       ┌──────────┐   ┌──────────┐
                       │PostgreSQL│   │  Redis   │
                       └──────────┘   └──────────┘
```

### 2.3 Deployment Architecture
[How components are deployed: containers, cloud services, regions]

---

## 3. Data Design (データ設計)

### 3.1 Data Model (ER Diagram)
[High-level entity-relationship diagram — key entities and their relationships]

```
[User] 1──N [Order] N──1 [Product]
              │
              N
           [Payment]
```

### 3.2 Key Entities
| Entity | Description | Key Attributes |
|---|---|---|
| User | System user | id, email, role, created_at |
| Order | Purchase order | id, user_id, status, total |
| Product | Item for sale | id, name, price, stock |

### 3.3 Data Volume Estimates
| Entity | Initial | 1 Year | 3 Years |
|---|---|---|---|
| Users | 0 | 10,000 | 100,000 |
| Orders | 0 | 50,000 | 500,000 |

---

## 4. Interface Design (インターフェース設計)

### 4.1 External APIs (Inbound)
| Endpoint | Method | Purpose | Auth |
|---|---|---|---|
| `/api/v1/users` | GET | List users | Bearer JWT |
| `/api/v1/orders` | POST | Create order | Bearer JWT |

### 4.2 External Integrations (Outbound)
| System | Protocol | Purpose | Data Sent |
|---|---|---|---|
| Stripe | HTTPS REST | Payment processing | Amount, card token |
| SendGrid | HTTPS REST | Email notifications | Template + recipient |

### 4.3 System Sequence Diagrams (Key Flows)

**Flow: User Creates Order**
```
User → Frontend → API → OrderService → Database → PaymentAPI
  1. POST /orders
  2. Validate request
  3. Create order (PENDING)
  4. Process payment
  5. Update order (PAID)
  6. Return order confirmation
```

---

## 5. Non-Functional Requirements (非機能要件)

### 5.1 Performance
| Metric | Target | Measurement Method |
|---|---|---|
| API response time (p95) | < 200ms | Datadog APM |
| Page load time (LCP) | < 2.5s | Core Web Vitals |
| Concurrent users | 1,000 | Load test with k6 |
| Database query time (p99) | < 100ms | EXPLAIN ANALYZE |

### 5.2 Reliability
| Metric | Target |
|---|---|
| System uptime | 99.9% (< 9h downtime/year) |
| RTO (Recovery Time Objective) | < 1 hour |
| RPO (Recovery Point Objective) | < 15 minutes |

### 5.3 Security
- [ ] Authentication: JWT with 1h expiry + refresh tokens
- [ ] Authorization: RBAC with roles: admin, user, readonly
- [ ] Data encryption: TLS 1.3 in transit, AES-256 at rest
- [ ] PII handling: [specific requirements]
- [ ] OWASP Top 10 compliance verified

### 5.4 Scalability
[How the system scales: horizontal/vertical, auto-scaling triggers, bottlenecks]

---

## 6. Error Handling Strategy (エラーハンドリング方針)

### 6.1 Error Categories
| Category | HTTP Status | Handling Strategy |
|---|---|---|
| Validation errors | 400 | Return field-level error messages |
| Authentication errors | 401 | Return generic "unauthorized" |
| Authorization errors | 403 | Return "forbidden" |
| Not found | 404 | Return resource-specific message |
| Server errors | 500 | Log full error, return generic message |

### 6.2 Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

---

## 7. Open Issues & Risks (課題・リスク)

| ID | Issue/Risk | Impact | Mitigation | Owner | Due Date |
|---|---|---|---|---|---|
| R-001 | Third-party API rate limits | Medium | Implement retry with backoff | Dev Lead | YYYY-MM-DD |

---

## 8. Sign-Off (承認)

| Role | Name | Signature | Date |
|---|---|---|---|
| Architect | | | |
| Tech Lead | | | |
| Product Manager | | | |
| Client Representative | | | |

**Status after sign-off:** Approved → Proceed to 詳細設計 (Detailed Design)
```

---

### Step 3: Review & Sign-Off Gate

Before proceeding to Detailed Design:

```
BASIC DESIGN REVIEW CHECKLIST:
□ Section 1: System overview clearly states scope and out-of-scope
□ Section 2: Architecture diagram is understandable without explanation
□ Section 3: All major entities are identified with relationships
□ Section 4: All inbound/outbound interfaces are documented
□ Section 5: Performance/reliability/security targets are quantified
□ Section 6: Error handling strategy is defined
□ All open issues have owners and due dates
□ Document reviewed by architect, tech lead, and PM
□ Client has reviewed and approved (or provided feedback)

GATE: Do not start Detailed Design until sign-off section is complete.
```

## Document Lifecycle

- **Draft** → Author writes; circulate for internal review
- **Under Review** → Stakeholders review; comments collected
- **Revised** → Incorporate feedback; bump version (1.0, 1.1, ...)
- **Approved** → All sign-offs complete; locked for this scope
- **Amended** → Scope change triggers amendment; see `change-management` protocol

## Coaching Notes

> **ABC - Always Be Coaching:**

1. **Basic Design is a communication tool, not a bureaucratic artifact.** Its purpose is to force alignment between the team, the client, and the architecture before anyone writes a line of code. A disputed design discovered during code review costs 10x more than one caught in design review.

2. **Diagrams must be self-explanatory.** If someone needs a 10-minute explanation to understand your architecture diagram, the diagram has failed. Iterate until it's obvious.

3. **Non-functional requirements are not optional.** Teams consistently under-specify NFRs and then fail in production. Every performance target should have a number, a measurement method, and an owner.

4. **The sign-off section is not theater.** A Basic Design without a sign-off is a draft. The sign-off creates accountability — the client cannot later claim they didn't see the architecture.

## Verification

Before marking Basic Design complete:

- [ ] All 8 sections are filled in (no placeholder text)
- [ ] Architecture diagram can be understood without verbal explanation
- [ ] All API endpoints are listed with method, auth, and purpose
- [ ] All NFRs have quantified targets (not "fast" or "secure")
- [ ] Open issues table has owners and due dates
- [ ] Sign-off section is complete with dates
- [ ] Document is saved as `docs/BASIC-DESIGN.md` and committed

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

After completing this skill, export the Basic Design to:
`architecture/YYYY-MM-DD-HHMM-basic-design-<project>.md`

Include YAML frontmatter: skill name, project name, date, version, sign-off status.

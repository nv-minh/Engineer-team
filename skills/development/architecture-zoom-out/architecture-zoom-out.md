---
name: architecture-zoom-out
description: "Provides a higher-level map of unfamiliar code areas. Zooms out to show relevant modules, callers, integration points, and relationships using the project's domain glossary. Builds a quick mental model for productive work in unfamiliar territory."
version: "1.0.0"
category: "development"
origin: "skills (Matt Pocock) + EM-Team"
triggers:
  - "zoom out"
  - "don't understand this code"
  - "bigger picture"
  - "how does this fit"
  - "where does this live"
  - "explain the architecture"
  - "code map"
intent: "Give the developer a working mental model of an unfamiliar code area in minutes, not hours, by going up a layer of abstraction and mapping the relevant territory."
scenarios:
  - "Joining a project and needing to understand a module before modifying it"
  - "Debugging an issue that spans multiple files and not seeing the connections"
  - "Reviewing a PR that touches unfamiliar code"
  - "Preparing to refactor and needing to understand dependencies first"
  - "Onboarding a new team member onto a subsystem"
best_for: "Codebase orientation, dependency mapping, architectural onboarding, refactoring preparation"
estimated_time: "5-15 min"
anti_patterns:
  - "Diving into implementation details before understanding the module's role"
  - "Ignoring callers and dependents when explaining a module"
  - "Using implementation jargon instead of domain language"
  - "Producing an exhaustive catalog instead of a focused map"
  - "Skipping integration points and boundary conditions"
related_skills: [context-engineering, code-review, code-simplification, architecture-improvement]
---

# Architecture Zoom-Out

## Overview

When you are unfamiliar with a section of code, the instinct is to read files top to bottom. This is slow and often misleading because you lack the frame to understand what you are reading. Architecture zoom-out goes up a layer of abstraction first, giving you a map of the relevant modules, their relationships, and how the target area fits into the larger system.

Inspired by Matt Pocock's zoom-out approach: **understand the neighborhood before walking the streets.**

## When to Use

- You need to modify code in an unfamiliar area of the codebase
- A bug or issue spans multiple files and the connections are not obvious
- You are reviewing a PR that touches code you have not worked with
- You are onboarding onto a project or subsystem
- You are preparing to refactor and need to understand what depends on what
- Someone asks "how does X work?" and X is a multi-file concern

## When NOT to Use

- The code area is already familiar (just go read it)
- The question is about a single function's behavior (use code search or Read)
- You need a detailed design document (use spec-driven-development or architecture-improvement)
- The task is pure debugging with a known scope (use systematic-debugging)

## Anti-Patterns

- **Bottom-up reading:** Starting with implementation details before understanding the module's purpose and boundaries.
- **Exhaustive catalogs:** Listing every file in a directory without curating for relevance. A map should be useful, not complete.
- **Implementation jargon:** Using variable names and class names from the code instead of domain concepts. The map should speak the language of the problem.
- **Skipping boundaries:** Not identifying where this area ends and other areas begin. Boundaries are where bugs and coupling hide.

## Process

### Step 1: Identify the Target Area

Ask or infer which code area needs explanation. This could be:

- A specific file or directory the user pointed to
- A feature area mentioned by name ("the payment system")
- A set of files changed in a PR or recent commits

If the user's description is vague, ask one clarifying question to narrow the target. Do not guess.

### Step 2: Go Up One Layer of Abstraction

Before looking at the target files, identify what contains them:

```
Target: src/features/payments/stripe-handler.ts

One layer up:
  - src/features/payments/          (the payments feature module)
  - Which is part of: src/features/ (all feature modules)
  - Which lives in: the monolith / this service
```

This establishes the neighborhood. The map should cover the siblings, parent, and immediate neighbors -- not the entire city.

### Step 3: Map Relevant Modules

For the target area and its neighborhood, map:

1. **Modules in the area** -- what lives here, in domain terms
2. **Module relationships** -- which modules talk to which, and why
3. **Caller/callee relationships** -- who calls into this area, what this area calls out to
4. **Integration points** -- external APIs, databases, message queues, shared state
5. **Boundaries** -- where this area's responsibility ends and another area begins

Present this as a structured map, not a wall of text:

```markdown
## Architecture Map: [Area Name]

### Modules

| Module | Purpose | Key Exports |
|--------|---------|-------------|
| payments.controller | HTTP endpoint handler | processPayment, refundPayment |
| payments.service | Business logic for payments | charge, refund, getHistory |
| stripe.client | Stripe API wrapper | createCharge, handleWebhook |
| payments.repository | Database access | save, findByUser, updateStatus |

### Call Flow (Happy Path)

user -> payments.controller -> payments.service -> stripe.client -> Stripe API
                                              -> payments.repository -> database

### Integration Points

- Stripe API (external, payment processing)
- Orders service (internal, via message queue)
- Notification service (internal, via event bus)
- PostgreSQL payments table (data store)

### Boundaries

- North: Orders service owns order state; payments owns payment state
- South: No downstream services depend on payments directly
- East: Notification service receives events but does not call back
- West: Auth service provides user context via middleware
```

### Step 4: Use Domain Glossary

Translate code concepts into domain language:

| Code Name | Domain Concept |
|-----------|---------------|
| `PaymentAttempt` | A user trying to pay |
| `StripeChargeService` | The payment processor |
| `payment_status enum` | Where the payment is in its lifecycle |
| `webhook_controller` | How we hear back from the processor |

If a CONTEXT.md or domain glossary exists in the project, use its terms. If not, propose terms that match how the team would describe the system in conversation.

### Step 5: Highlight What Matters for the Task

Tailor the map to the user's immediate need:

- **If modifying:** highlight what depends on the target, what the target depends on, and what tests cover it
- **If debugging:** highlight the call path, error handling, and integration points
- **If reviewing:** highlight what changed, what the change affects, and boundary contracts
- **If onboarding:** highlight the main flow, the common entry points, and where to find tests

Do not produce a generic map. Produce a map that answers the question the user actually has.

### Step 6: Offer to Go Deeper

After presenting the map:

- Ask if any module needs a deeper dive
- Offer to trace a specific flow end-to-end
- Suggest related areas that might be relevant based on what was discovered

Do not overwhelm. One offer, let the user choose.

## Coaching Notes

> **ABC - Always Be Coaching:** Every architectural map should teach the reader to read architecture maps on their own. Explain why you organized the map the way you did.

1. **Up one layer is the right amount of zoom.** Too close and you see code without context. Too far and you see a system diagram without actionable detail. One layer up is where understanding lives.

2. **Domain language is the bridge.** Code uses programmer names. People think in domain concepts. The map should let someone think in domain terms while knowing which code to look at.

3. **Boundaries matter more than internals.** Most bugs and coupling problems live at the seams between modules. Mapping boundaries explicitly prevents the "I didn't know that was connected" class of errors.

4. **Relevance beats completeness.** A map of 6 relevant modules is more useful than a map of 60 modules the user will never touch. Curate aggressively.

5. **Callers are as important as callees.** Knowing what a module calls tells you its dependencies. Knowing what calls a module tells you its impact radius. Both are essential for safe changes.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just read the files" | Reading files without a map is exploring a city without knowing which city you are in. You will get lost. |
| "The README explains everything" | READMEs explain intent. Code maps explain reality. They are complementary, not interchangeable. |
| "I don't need a map for a small area" | Small areas can have surprising connections. The map for a small area is just shorter, not skipped. |
| "This will take too long" | A zoom-out takes 5-10 minutes. Understanding code by reading it top-down takes hours. The map is cheaper. |
| "Just show me the code" | Showing code without context produces understanding that is shallow and brittle. One change breaks it. |

## Output Template

```markdown
## Architecture Zoom-Out: [Area Name]

### Scope
**Target:** [file/directory/feature]
**Question:** [what the user needs to understand]

### Module Map
[Table of modules with purpose and key exports]

### Relationships
[Call flow diagram or dependency graph]

### Integration Points
[External APIs, databases, message queues, shared state]

### Boundaries
[Where this area ends and others begin, in domain terms]

### Glossary
[Code-to-domain translation table]

### Key Insight
[One sentence: the most important thing to understand about this area]

### Suggested Next Step
[Deeper dive on a specific module, or trace a specific flow]
```

## Verification

After completing an architecture zoom-out:

- [ ] Target area identified and confirmed
- [ ] One layer of abstraction established
- [ ] All relevant modules mapped with domain language
- [ ] Caller/callee relationships documented
- [ ] Integration points identified
- [ ] Boundaries made explicit
- [ ] Map tailored to the user's task
- [ ] Offered to go deeper on specific areas
- [ ] Domain glossary terms consistent with project conventions (if they exist)

## Related Skills

- **context-engineering** - Sets up the project context that makes zoom-outs faster
- **code-review** - Zoom-out is valuable preparation before reviewing unfamiliar code
- **code-simplification** - Zoom-out often reveals simplification opportunities at boundaries
- **architecture-improvement** - If zoom-out reveals shallow modules or poor boundaries, follow up with architecture improvement
- **alignment-session** - Use when zoom-out reveals ambiguities that need resolution before proceeding

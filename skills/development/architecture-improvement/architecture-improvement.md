---
name: architecture-improvement
description: "Systematic architecture improvement through deepening modules. Identifies shallow modules, proposes deepening strategies, and prioritizes by leverage. Interactive grilling loop for exploring candidates using the deletion test and seam analysis."
version: "1.0.0"
category: "development"
origin: "skills (Matt Pocock) + EM-Team"
triggers:
  - "improve architecture"
  - "deepen modules"
  - "architecture review"
  - "refactor structure"
  - "shallow modules"
  - "module design"
  - "seam analysis"
intent: "Find opportunities to deepen modules (high leverage, simple interfaces) in the codebase, producing a prioritized list of improvements with concrete proposals."
scenarios:
  - "Codebase has grown organically and modules are shallow or poorly bounded"
  - "Preparing for a major feature addition and wanting to strengthen the foundation first"
  - "During a refactoring sprint, looking for highest-leverage improvements"
  - "After onboarding, noticing that modules are hard to understand due to leaky abstractions"
  - "Code review reveals that changes keep rippling across many files"
best_for: "Architecture refactoring, module design improvement, reducing change coupling, increasing code locality"
estimated_time: "20-60 min"
anti_patterns:
  - "Deepening modules without understanding their callers"
  - "Proposing wholesale rewrites instead of targeted deepening"
  - "Ignoring the deletion test when evaluating module importance"
  - "Conflating code style issues with architectural issues"
  - "Prioritizing by ease instead of by leverage"
related_skills: [code-simplification, code-review, architecture-zoom-out, alignment-session]
---

# Architecture Improvement

## Overview

Systematic architecture improvement through deepening modules. Inspired by Matt Pocock's improve-codebase-architecture approach, this skill finds opportunities to strengthen modules by increasing their leverage (how much they do for callers) and simplifying their interfaces (how little callers need to know).

A **deep module** has a simple interface and hides complexity. A **shallow module** leaks its internals, forcing callers to understand too much. This skill identifies shallow modules and proposes concrete deepening strategies, prioritized by leverage.

## Core Terminology

| Term | Definition |
|------|-----------|
| **Module** | A unit of code with a defined boundary: function, class, file, package, or service. The concept scales. |
| **Interface** | The surface area a module exposes to its consumers: function signatures, types, configuration options, events. |
| **Seam** | A point where behavior can be modified without modifying the module itself: dependency injection, plugin hooks, strategy patterns, event listeners. |
| **Leverage** | How much functionality a module provides relative to its interface complexity. High leverage = much functionality, simple interface. |
| **Locality** | How closely related code lives together. High locality = related code is in the same module. Low locality = related code is scattered. |
| **Deepening** | The act of making a module deeper: simplifying its interface, moving complexity inside, increasing locality. |
| **Deletion test** | Asking "what breaks if this module is removed?" to understand its actual importance and coupling. |

## When to Use

- The codebase has grown organically and modules feel shallow or poorly bounded
- Changes keep rippling across many files (high change coupling)
- Preparing for a major feature and wanting to strengthen the foundation
- During a refactoring sprint, looking for the highest-leverage improvements
- After onboarding, noticing that modules are hard to understand because abstractions leak
- Code review reveals that every change requires touching 5+ files

## When NOT to Use

- The architecture is clean and modules are well-bounded (no need to improve what works)
- The codebase is being replaced or rewritten (improve the new one instead)
- The task is about adding features, not improving structure (use incremental-implementation)
- You have not yet understood the area (use architecture-zoom-out first)

## Anti-Patterns

- **Rewrite-by-another-name:** "Architecture improvement" that proposes scrapping and rebuilding modules. Deepening is surgical, not demolition.
- **Style-as-architecture:** Renaming variables, reformatting code, or moving files without changing interfaces or locality. That is style, not architecture.
- **Perfectionism cascade:** Trying to deepen every module at once. Prioritize by leverage, improve incrementally.
- **Ignoring callers:** Deepening a module without understanding what calls it is how you break things.
- **Framework worship:** Deepening framework wrappers instead of domain modules. Framework code is not your competitive advantage.

## Process

### Step 1: Map the Target Area

Use architecture-zoom-out (or do it inline) to establish the neighborhood:

1. Identify the area under review
2. List all modules and their boundaries
3. Map caller/callee relationships
4. Identify integration points and seams

This produces the territory you will evaluate. Without this map, you cannot assess leverage or locality.

### Step 2: Run the Deletion Test

For each module in the target area, ask:

**"What breaks if this module is removed?"**

Results fall into three categories:

| Deletion Test Result | What It Means | Action |
|---------------------|---------------|--------|
| **Everything breaks** | High coupling, many dependents | This module matters. Evaluate its interface quality. |
| **Some things break** | Moderate coupling | Good candidate for deepening. Check if interface can simplify. |
| **Nothing breaks** | Unused code OR module is not actually depended on | Delete it, or understand why it exists. |

Record results. Modules where "nothing breaks" and are genuinely unused should be deleted before improving anything else.

### Step 3: Evaluate Module Depth

For each surviving module, assess on two axes:

**Interface simplicity:** How much does a caller need to know to use this module?
- Deep: call one function, pass a config object, get a result
- Shallow: call three functions in order, handle intermediate state, manage lifecycle

**Implementation leverage:** How much functionality does the module provide?
- High leverage: one call handles authentication, validation, persistence, and response formatting
- Low leverage: one call does one trivial thing, and the caller must orchestrate everything

Score each module:

```
Depth Score = Leverage / Interface Complexity

High depth score  -> module is deep, leave it alone
Low depth score   -> module is shallow, candidate for deepening
```

### Step 4: Identify Shallow Modules

Modules with low depth scores are candidates. For each candidate, diagnose the shallowness:

| Symptom | Diagnosis | Deepening Strategy |
|---------|-----------|-------------------|
| Callers must call 3+ functions in sequence | Interface too granular | Combine into a single higher-level function |
| Callers must understand internal state | Leaky abstraction | Encapsulate state, expose only outcomes |
| Module is a thin wrapper over another module | No added value | Either deepen (add real logic) or remove (use underlying module directly) |
| Related logic lives in multiple modules | Low locality | Consolidate into one module with a clean interface |
| Module requires extensive configuration | Interface too complex | Provide sensible defaults, reduce required config |
| Every change touches this module AND its callers | High change coupling | Introduce a seam: interface, event, or plugin point |

### Step 5: Propose Deepening Strategies

For each shallow module, propose a concrete deepening strategy:

```markdown
### Module: [name]

**Current state:** [description of shallowness]

**Deletion test:** [what breaks]

**Shallowness diagnosis:** [which symptom from Step 4]

**Deepening proposal:**
- Move [complexity X] inside the module
- Simplify interface from [N functions] to [M functions]
- Consolidate [related logic] from [other modules]

**Before (caller perspective):**
```typescript
// Caller must know too much
const user = await getUser(userId);
const validated = validateUser(user);
const enriched = enrichWithPermissions(user);
return formatUserResponse(enriched);
```

**After (caller perspective):**
```typescript
// One call, module handles the rest
return await getUserProfile(userId);
```

**Leverage gained:** [what changes in terms of caller burden]
```

### Step 6: Prioritize by Leverage

Rank deepening proposals by leverage: how much caller complexity is eliminated per unit of refactoring effort.

```
Priority = (Caller complexity removed) / (Implementation effort)

High priority: big simplification for callers, moderate effort
Medium priority: meaningful simplification, moderate effort
Low priority: small simplification, high effort (save for later)
```

Present the prioritized list:

```markdown
## Deepening Priorities

| Priority | Module | Leverage Gained | Effort | Risk |
|----------|--------|-----------------|--------|------|
| 1 | auth.middleware | High (3 callers simplified) | Low | Low |
| 2 | payment.service | High (5 callers simplified) | Medium | Medium |
| 3 | notification.handler | Medium (2 callers simplified) | Medium | Low |
```

### Step 7: Interactive Grilling Loop

For each priority candidate, enter a grilling loop with the user:

1. **Present the proposal** for this module
2. **Ask one question at a time** about constraints, preferences, or concerns
3. **Explore alternatives** if the user disagrees with the approach
4. **Confirm the direction** before moving to the next candidate

This is not a one-shot report. It is a conversation. The user's domain knowledge is essential for choosing the right seams and boundaries.

Questions to ask during grilling:
- "Does this module have callers outside this area that I should know about?"
- "Is there a reason the interface was designed this way originally?"
- "Would introducing a seam here conflict with future plans?"
- "Are there tests that would need significant changes?"

### Step 8: Produce the Improvement Plan

After grilling is complete for all candidates:

1. Write a prioritized improvement plan with specific tasks
2. Each task should be implementable as a vertical slice
3. Include before/after interface sketches for each module
4. Note which tasks can be done independently and which have dependencies
5. Save the plan (user chooses location)

The plan should be actionable. A developer should be able to pick up the first task and implement it without asking additional questions.

## The Deletion Test in Depth

The deletion test is the most powerful diagnostic in this skill. Here is how to run it rigorously:

1. **For each module, imagine removing it entirely.**
2. **Trace what breaks:** which callers fail to compile, which tests fail, which features stop working.
3. **Classify the breakage:**
   - **Direct breakage:** Callers that import or call this module directly. These represent the module's true interface.
   - **Indirect breakage:** Features that depend on this module through intermediaries. These represent the module's real importance.
   - **No breakage:** Nothing depends on this module. Either it is dead code, or it is the wrong abstraction level.
4. **Count the breakage radius.** If removing one module breaks 20 files, it is a keystone module. Be careful deepening it. If removing it breaks 2 files, it is a leaf module. Deepening is lower risk.

## Seam Analysis

When deepening a module, seams are your primary tool. A seam is a point where you can change behavior without changing the module's code.

**Types of seams:**

| Seam Type | Example | When to Use |
|-----------|---------|-------------|
| Function parameter | Passing a strategy function instead of hardcoding behavior | When the module needs to support multiple behaviors |
| Interface/protocol | Defining an interface that callers implement | When the module interacts with external systems |
| Configuration object | Providing defaults that callers can override | When behavior should be tunable without code changes |
| Event/callback | Emitting events instead of calling specific handlers | When the module should not know about its consumers |
| Plugin/hook | Registering plugins that extend the module | When the module should be open for extension, closed for modification |

Deepening often involves **adding seams** to give the module flexibility without exposing its internals.

## Coaching Notes

> **ABC - Always Be Coaching:** Every deepening proposal should teach something about module design. Explain why deep modules are better, not just what to change.

1. **Deep modules are the goal, not large modules.** A deep module hides complexity behind a simple interface. A large module can still be shallow if it exposes too much. Size and depth are independent dimensions.

2. **The deletion test is honest.** It cannot be fooled by naming conventions or documentation. If nothing breaks when a module is removed, it is not carrying its weight. Either delete it or deepen it until its removal would be painful.

3. **Leverage, not perfection.** The goal is to find the module where a small change produces the biggest simplification for its callers. This is the 80/20 of architecture improvement.

4. **Seams prevent coupling.** Most shallow modules are shallow because they let callers reach in and touch their internals. Adding a seam (interface, event, plugin) lets the module maintain its boundaries while still being flexible.

5. **Domain language matters.** A module called `UserManager` that callers think of as "the thing that validates passwords" has a naming problem that reflects an architecture problem. Deepening should bring the module's interface in line with how callers think about it.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The architecture is fine, it just needs more tests" | Tests validate behavior. Architecture determines how hard it is to write those tests. Shallow modules make testing harder. |
| "We don't have time for architecture improvement" | Shallow modules make every future change slower. The time you spend deepening is time you save on every subsequent feature. |
| "This module is too important to change" | Important modules are exactly the ones that should be deep. A shallow important module is a liability. |
| "It works, don't touch it" | "It works" is a low bar. The question is: how easy is it to change when requirements shift? Deep modules are easy to change. |
| "We'll fix the architecture during the next rewrite" | The next rewrite will have the same architecture problems unless you understand what made the current one shallow. Improve incrementally. |

## Output Template

```markdown
## Architecture Improvement Report: [Area Name]

### Summary
[One paragraph: what was found, what was proposed, what was prioritized]

### Deletion Test Results
| Module | Breakage Radius | Classification |
|--------|----------------|----------------|
| [module] | [N files/features] | [keystone / standard / leaf / dead] |

### Depth Assessment
| Module | Leverage | Interface Complexity | Depth Score | Verdict |
|--------|----------|---------------------|-------------|---------|
| [module] | [H/M/L] | [H/M/L] | [H/M/L] | [deep / shallow] |

### Shallow Module Diagnoses
[For each shallow module: symptom, diagnosis, deepening strategy]

### Prioritized Deepening Plan
[Ranked list with before/after sketches and effort estimates]

### Seams to Introduce
[For each module being deepened: what seams to add and why]

### Risks and Mitigations
[For each proposed change: what could go wrong and how to guard against it]
```

## Verification

After completing an architecture improvement session:

- [ ] Target area mapped (modules, relationships, integration points)
- [ ] Deletion test run on every module
- [ ] Depth assessment completed for every module
- [ ] Shallow modules diagnosed with specific symptoms
- [ ] Concrete deepening proposals written for each shallow module
- [ ] Proposals prioritized by leverage
- [ ] Interactive grilling completed with user
- [ ] Improvement plan written with actionable tasks
- [ ] Before/after interface sketches included
- [ ] Seams identified for each deepening proposal
- [ ] Risks noted for each change

## Related Skills

- **architecture-zoom-out** - Use first to understand the area before improving it
- **code-simplification** - Use alongside architecture improvement to reduce internal complexity
- **code-review** - Architecture improvement findings strengthen code review criteria
- **alignment-session** - Use when the team disagrees on which modules to deepen first
- **incremental-implementation** - Use to implement deepening proposals as vertical slices

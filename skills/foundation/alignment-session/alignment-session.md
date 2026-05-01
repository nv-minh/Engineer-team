---
name: alignment-session
description: "Interview-style alignment between human and AI before coding. Walks a decision tree one question at a time, resolves dependencies sequentially, and builds shared understanding through grilling. Prevents misaligned implementation by ensuring both parties agree on every branch of the design."
version: "1.0.0"
category: "foundation"
origin: "skills (Matt Pocock) + EM-Team"
triggers:
  - "align on"
  - "grill me"
  - "stress test plan"
  - "before coding"
  - "shared understanding"
  - "alignment session"
  - "grill my plan"
intent: "Prevent wasted implementation by reaching shared understanding before any code is written. Resolves every ambiguity and dependency through focused, one-at-a-time questioning."
scenarios:
  - "Starting a new feature where requirements have unresolved branches"
  - "Reviewing a spec or design doc for hidden ambiguities"
  - "Before a brainstorming session ends, validating all decisions were truly made"
  - "Onboarding onto an unfamiliar codebase and needing to understand design intent"
  - "Resolving disagreement between team members about approach"
best_for: "Pre-implementation alignment, design stress testing, ambiguity resolution, decision tree walking"
estimated_time: "10-45 min"
anti_patterns:
  - "Asking multiple questions at once, overwhelming the user"
  - "Answering questions from memory instead of exploring the codebase first"
  - "Skipping branches of the decision tree because they seem obvious"
  - "Proceeding to implementation with unresolved dependencies"
  - "Accepting vague answers without pushing for specificity"
related_skills: [brainstorming, spec-driven-development, context-engineering, writing-plans]
---

# Alignment Session

## Overview

An alignment session is an interview between human and AI to reach shared understanding before coding begins. Inspired by Matt Pocock's grill-me approach, this skill walks a decision tree one question at a time, resolving dependencies sequentially until both parties agree on every branch of the design.

The core principle: **never assume shared understanding. Verify it question by question.**

## When to Use

- Before starting implementation on a feature with multiple decision branches
- When a spec or design doc exists but has unresolved ambiguities
- After a brainstorming session to validate that all decisions were truly made
- When onboarding onto a codebase and needing to understand design intent
- Before handing off work between team members
- When two approaches seem equally viable and need resolution

## When NOT to Use

- For well-defined tasks with zero ambiguity (just implement)
- During active debugging (use systematic-debugging instead)
- When the codebase already has a clear spec with no open questions
- As a substitute for actual brainstorming (use brainstorming first)

## Anti-Patterns

- **Batch questioning:** Asking 5 questions at once defeats the purpose. One question at a time, always.
- **Assumption caching:** If the answer might live in the codebase, explore it first rather than asking the human.
- **Premature closure:** Declaring "we're aligned" when branches remain unresolved.
- **Rubber-stamping:** Accepting "yeah that's fine" without testing understanding with a follow-up.

## Process

### Step 1: Establish Context

Before asking any questions, gather what already exists.

```
1. Check for CONTEXT.md, PROJECT.md, or similar project documentation
2. Scan the codebase for relevant modules, types, and patterns
3. Read any existing specs or design docs related to the topic
4. Identify the decision tree: what choices need to be made, and what depends on what
```

If a CONTEXT.md or domain glossary exists, use it. If not, propose building one as a side effect of this session.

### Step 2: Map the Decision Tree

Identify all decision points and their dependencies. Present the tree to the user so they see the roadmap.

```
Decision tree for [topic]:
  1. Data model: SQL vs Document store
     -> If SQL: migration strategy (2a)
     -> If Document: indexing strategy (2b)
  2a. Migration: online vs offline
  2b. Indexing: embedded vs separate collection
  3. API surface: REST vs GraphQL (depends on 1)
  4. Auth pattern: (depends on 3)
```

This makes the interview structure visible and prevents jumping ahead to decisions that depend on unresolved parents.

### Step 3: Walk the Tree, One Question at a Time

For each decision point:

1. **Ask one question.** Never batch.
2. **Provide a recommended answer.** Give your reasoning, but the human decides.
3. **If the answer can be found in the codebase, explore first.** Do not ask the human something you could discover yourself.
4. **Resolve all sub-branches before moving to siblings.** Depth-first, not breadth-first.
5. **Update documentation inline as terms are resolved.** Capture decisions as they happen.

#### Question Format

Each question follows this structure:

```
**Question:** [Specific question about this decision point]

**My recommendation:** [Your recommended answer with reasoning]

**Why it matters:** [What depends on this decision]

**Options:**
  A) [Option A - description and trade-offs]
  B) [Option B - description and trade-offs]
  C) [Option C - if applicable]

Your choice:
```

#### Handling Vague Answers

When the user gives a vague answer:

- **Reflect back your interpretation:** "So you're saying X. Is that right?"
- **Ask a narrowing follow-up:** "When you say 'fast', do you mean <100ms response time, or <1s end-to-end?"
- **Propose a concrete test:** "Would it be fair to say this is resolved if [specific condition]?"

Never accept "whatever you think" on a decision that affects the implementation path. Push gently but firmly.

### Step 4: Build Shared Vocabulary

As the session progresses, build a shared vocabulary:

- Write down agreed-upon terms and their definitions
- If CONTEXT.md exists, update it with new terms
- If it does not exist, create one as a deliverable of this session
- Use consistent terminology throughout the session and flag when the user uses a different term for the same concept

### Step 5: Offer ADRs for Hard-to-Reverse Decisions

For decisions that are expensive to reverse:

- Propose an Architecture Decision Record (ADR)
- Use the ADR template from the documentation skill
- Capture: context, decision, consequences, alternatives considered
- ADRs become part of the project's permanent documentation

Not every decision needs an ADR. Only ones where reversing would cost significant time or where future team members need to understand *why* a choice was made.

### Step 6: Summarize Alignment

After walking the entire tree:

1. **Present a summary of all decisions made** in order
2. **Flag any remaining open questions** (there should be zero, but be honest if some remain)
3. **State the shared understanding explicitly** in a few sentences
4. **Ask for final confirmation:** "Does this accurately capture our agreement?"

### Step 7: Transition

After alignment is confirmed:

- If a spec is needed: invoke **spec-driven-development**
- If a plan is needed: invoke **writing-plans**
- If implementation can proceed directly: invoke the appropriate development skill

Do not skip this transition. The alignment session produces shared understanding, not implementation.

## Coaching Notes

> **ABC - Always Be Coaching:** Every question should teach something about why the decision matters and what rides on it.

1. **One question at a time is respect.** Batching questions signals you value your time over the human's cognitive load. One at a time says: let's think about this together.

2. **Explore before asking.** If the codebase holds the answer, find it. Asking a human something you could have discovered erodes trust. This is the "Search Before Building" ethos applied to conversation.

3. **Recommend, then defer.** Always offer your recommendation with reasoning. But the human decides. This is User Sovereignty in action.

4. **Shared vocabulary prevents invisible misalignment.** Two people using the same word for different concepts is the most common source of rework. Building a glossary as you go prevents this.

5. **Depth-first resolution prevents circular dependencies.** Resolving all sub-branches before moving to siblings ensures no decision is made on shaky foundations.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We're roughly aligned, let's just start coding" | Rough alignment means rough code. Every unresolved branch becomes a TODO that blocks someone. |
| "I'll figure out the details during implementation" | Details discovered during implementation are 5x more expensive to change than details resolved before. |
| "This is too simple for an alignment session" | Simple tasks have simple alignment sessions (3-5 questions). The cost is minutes, not hours. |
| "We already have a spec, we don't need this" | Specs describe *what*. Alignment sessions verify *understanding*. They are different things. |
| "I don't want to slow down" | 10 minutes of alignment prevents hours of rework. Alignment is the fastest path to correct code. |

## Decision Tree Template

Use this to map the decision tree at the start of the session:

```markdown
## Alignment Session: [Topic]

**Date:** [Date]
**Participants:** [Human name] + AI

### Decision Tree

1. [First decision point]
   - Options: A) ... B) ...
   - Decision: [TBD]
   - Depends on: [nothing / parent decisions]
   - ADR needed: [yes/no]
   1a. [Sub-decision if A chosen]
       - Decision: [TBD]
   1b. [Sub-decision if B chosen]
       - Decision: [TBD]

2. [Second decision point]
   - Depends on: [decision 1]
   - Decision: [TBD]

### Shared Vocabulary

| Term | Definition | Agreed On |
|------|-----------|-----------|
| [term] | [definition] | [yes/no] |

### Open Questions

- [ ] [Question 1]
- [ ] [Question 2]

### Decisions Summary

| # | Decision | Choice | Reasoning |
|---|----------|--------|-----------|
| 1 | [decision] | [choice] | [why] |
```

## Verification

After completing an alignment session:

- [ ] Context explored (codebase, docs, existing specs)
- [ ] Decision tree mapped and presented
- [ ] Every branch resolved with explicit decision
- [ ] No open questions remain
- [ ] Shared vocabulary documented
- [ ] ADRs written for hard-to-reverse decisions
- [ ] Summary presented and confirmed by user
- [ ] Transition to next skill completed (spec, plan, or implementation)
- [ ] CONTEXT.md updated if applicable

## Related Skills

- **brainstorming** - Use before alignment when exploring ideas
- **spec-driven-development** - Use after alignment to formalize decisions into a spec
- **context-engineering** - Optimizes the context setup that makes alignment sessions effective
- **writing-plans** - Use after alignment to break decisions into implementation tasks
- **architecture-improvement** - Alignment often reveals architectural opportunities

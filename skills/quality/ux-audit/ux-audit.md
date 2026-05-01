---
name: ux-audit
description: >
  Behavioral UX audit for user interfaces. Evaluates usability, accessibility, cognitive load,
  interaction patterns, user flows, and perceived performance using a scored dimension format
  (0-10 per dimension). Goes beyond visual QA to assess how users actually behave and think
  when interacting with the interface.
version: "2.1.0"
category: "quality"
origin: "gstack + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "ux audit"
  - "usability review"
  - "user experience check"
  - "audit UX"
  - "UX review"
  - "cognitive load"
intent: >
  Evaluate user interfaces using behavioral UX foundations. Measure cognitive load, interaction
  quality, accessibility compliance, user flow coherence, and performance perception. Produce
  a scored report with specific, actionable fixes for each dimension.
scenarios:
  - "Auditing a new feature's UI before release to catch usability issues"
  - "Reviewing a redesigned page for accessibility and flow quality"
  - "Comparing mobile and desktop UX consistency across a flow"
  - "Identifying why users abandon a form or checkout process"
best_for: "pre-release UX validation, redesign evaluation, accessibility compliance, flow analysis"
estimated_time: "20-40 min"
anti_patterns:
  - "Auditing only visual design without testing interaction behavior"
  - "Scoring without evidence -- every score must reference a specific element"
  - "Ignoring error states and edge cases in flow analysis"
  - "Treating accessibility as a checkbox instead of a usability dimension"
related_skills:
  - code-review
  - browser-testing
  - frontend-patterns
  - e2e-testing
---

# UX Audit

## Overview

The UX Audit evaluates user interfaces using behavioral UX foundations. Unlike visual QA (which checks whether the design matches the mockup), the UX Audit assesses how users think, behave, and feel when interacting with the interface. It scores the interface across six dimensions, each producing a 0-10 rating backed by specific evidence.

This skill treats UX as an engineering discipline with measurable properties, not a matter of taste.

## When to Use

- Before releasing a new feature or redesigned page
- When users report confusion or frustration with a flow
- After a redesign to validate that UX improved
- As part of a pre-ship quality gate
- When accessibility compliance is required

## When NOT to Use

- Checking whether implementation matches a design mockup (use visual QA)
- General code quality review (use `code-review`)
- Performance profiling (use `performance-optimization`)
- The interface is in early prototype stage (feedback would be premature)

## Anti-Patterns

- Scoring without referencing specific elements -- scores without evidence are opinions
- Auditing only the happy path -- error states reveal more about UX quality than success states
- Treating accessibility as separate from usability -- accessible design is better design for everyone
- Recommending redesigns instead of specific fixes -- the audit should produce actionable changes

## Process

### Step 1: Define Audit Scope

Specify what is being audited and from which perspective.

```
Scope definition:
- Target: <URLs, pages, or components>
- User personas: <who is the primary user>
- Device targets: <desktop, mobile, tablet>
- Flow focus: <which user flow(s) to trace>
- Baseline: <is there a previous audit to compare against>
```

### Step 2: Evaluate Each Dimension

Score the interface on six dimensions. Each dimension gets a 0-10 rating with specific evidence.

---

#### Dimension 1: Cognitive Load (0-10)

How much mental effort does the user expend to accomplish their goal?

```
Scoring guide:
  9-10: User can complete the task on autopilot. No thinking required.
  7-8:  User knows what to do next at every step. Minimal thought.
  5-6:  User occasionally pauses to think. Acceptable but improvable.
  3-4:  User frequently unsure what to do. Re-reading required.
  1-2:  User confused. Multiple re-reads. Guessing what to do.
  0:    User cannot figure out how to proceed at all.

Evaluate:
- Information density per screen (too many elements?)
- Decision points per screen (how many choices must the user make?)
- Text clarity (is the writing simple and direct?)
- Visual hierarchy (does the most important thing stand out?)
- Progressive disclosure (are advanced options hidden until needed?)
- Consistency (do similar things look and behave similarly?)
```

Evidence template:

```markdown
### Cognitive Load: <score>/10

**Evidence:**
- [element]: <what was observed and why it adds or reduces load>
- [element]: <observation>

**Fixes:**
- <specific, actionable fix with before/after if applicable>
```

---

#### Dimension 2: Interaction Quality (0-10)

How well do interactive elements communicate their purpose and respond to input?

```
Scoring guide:
  9-10: Every element is self-explanatory. Feedback is instant and clear.
  7-8:  Interactions are intuitive. Minor feedback gaps.
  5-6:  Most interactions work. Some elements are ambiguous.
  3-4:  Several confusing interactions. Missing feedback.
  1-2:  Many broken or unclear interactions.
  0:    Core interactions non-functional or misleading.

Evaluate:
- Affordances (do buttons look clickable? do inputs look fillable?)
- Hover/focus states (does the element acknowledge the user's attention?)
- Loading states (does the user know something is happening?)
- Confirmation feedback (does the user know their action succeeded or failed?)
- Error recovery (can the user understand and fix what went wrong?)
- Touch targets (are mobile targets at least 44x44px?)
```

---

#### Dimension 3: Accessibility (0-10)

Does the interface meet WCAG 2.1 AA standards and work for all users?

```
Scoring guide:
  9-10: Exceeds WCAG 2.1 AA. Works beautifully with assistive tech.
  7-8:  Meets WCAG 2.1 AA. Minor improvements possible.
  5-6:  Partial compliance. Some issues for assistive tech users.
  3-4:  Significant barriers for users with disabilities.
  1-2:  Major accessibility failures. Many users excluded.
  0:    Completely inaccessible to assistive technology.

Evaluate:
- Color contrast (minimum 4.5:1 for normal text, 3:1 for large text)
- Keyboard navigation (can every interaction be completed without a mouse?)
- Screen reader compatibility (do ARIA labels and semantic elements exist?)
- Focus management (does focus move logically through the interface?)
- Text resize (does the layout hold at 200% zoom?)
- Motion sensitivity (are animations respectful of prefers-reduced-motion?)
- Form labels (does every input have an associated label?)
```

---

#### Dimension 4: User Flow Coherence (0-10)

Does the interface guide the user through a logical, predictable sequence?

```
Scoring guide:
  9-10: User never wonders "where am I?" or "what happened?"
  7-8:  Flow is logical with minor navigation ambiguities.
  5-6:  Flow works but some transitions are jarring or unclear.
  3-4:  User frequently disoriented. Back button overused.
  1-2:  Flow is broken. Dead ends, orphan pages, confusing jumps.
  0:    No discernible flow. User is lost.

Evaluate:
- Entry points (can the user find where to start?)
- Transitions (does each step lead naturally to the next?)
- Wayfinding (does the user always know where they are in the process?)
- Exit points (can the user complete or abandon the flow cleanly?)
- Error flow (what happens when something goes wrong mid-flow?)
- Back navigation (can the user recover without losing work?)
```

---

#### Dimension 5: Mobile Responsiveness (0-10)

Does the interface work well on mobile devices?

```
Scoring guide:
  9-10: Feels native on mobile. Better than desktop in some ways.
  7-8:  Works well on mobile. Minor touch or layout issues.
  5-6:  Functional on mobile but clearly designed desktop-first.
  3-4:  Difficult to use on mobile. Significant layout or touch issues.
  1-2:  Nearly unusable on mobile.
  0:    Not responsive at all. Desktop-only layout.

Evaluate:
- Viewport handling (does content fit without horizontal scroll?)
- Touch targets (minimum 44x44px, adequate spacing between targets?)
- Text readability (is text readable without zooming on a 375px viewport?)
- Form input (do mobile keyboards not obscure the active input?)
- Performance on mobile (do heavy animations or images cause jank?)
- Orientation (does it work in both portrait and landscape?)
```

---

#### Dimension 6: Perceived Performance (0-10)

Does the interface feel fast and responsive, regardless of actual load times?

```
Scoring guide:
  9-10: Feels instant. User never waits without understanding why.
  7-8:  Feels fast. Loading states are informative.
  5-6:  Occasional perceived delays. Skeleton screens or spinners help.
  3-4:  Feels slow. Blank screens during loading. No feedback.
  1-2:  Noticeably sluggish. User wonders if it is broken.
  0:    Feels frozen. No indication that anything is happening.

Evaluate:
- First contentful paint (does something meaningful appear quickly?)
- Skeleton states (are loading placeholders used for delayed content?)
- Optimistic updates (do actions appear to succeed before server confirms?)
- Image loading (are lazy loading and progressive enhancement used?)
- Animation purpose (do animations convey information or just add delay?)
- Input responsiveness (does the interface acknowledge input within 100ms?)
```

---

### Step 3: Compile the Scorecard

```markdown
# UX Audit Scorecard

**Target:** <pages/flows audited>
**Date:** <date>
**Auditor:** <agent/human>

## Scores

| Dimension | Score | Trend |
|---|---|---|
| Cognitive Load | <n>/10 | <up/down/new> |
| Interaction Quality | <n>/10 | <up/down/new> |
| Accessibility | <n>/10 | <up/down/new> |
| User Flow Coherence | <n>/10 | <up/down/new> |
| Mobile Responsiveness | <n>/10 | <up/down/new> |
| Perceived Performance | <n>/10 | <up/down/new> |
| **Overall** | **<avg>/10** | |

## Critical Findings (score <= 4)

### 1. <finding title>
- **Dimension:** <which dimension>
- **Evidence:** <specific element and observation>
- **Impact:** <how many users are affected, how severely>
- **Fix:** <specific, actionable fix>
- **Effort:** <S/M/L estimate>

## High Findings (score 5-6)

### 1. <finding title>
- **Dimension:** <which dimension>
- **Evidence:** <specific element and observation>
- **Fix:** <specific, actionable fix>

## Recommendations (score 7-8)

<Opportunities to improve from good to great.>

## Strengths (score 9-10)

<What the interface does well. Preserve these.>
```

### Step 4: Prioritize Fixes

Order fixes by impact and effort.

```
Priority matrix:
  HIGH impact + LOW effort  = Quick wins (do immediately)
  HIGH impact + HIGH effort = Strategic (plan and schedule)
  LOW impact + LOW effort   = Polish (batch and do when convenient)
  LOW impact + HIGH effort  = Defer (revisit if evidence accumulates)
```

## Coaching Notes

> **ABC - Always Be Coaching:** UX is not about making things pretty. It is about making things work for humans. Every dimension in this audit maps to a measurable property of the interface. A score of 6/10 on cognitive load is not an opinion -- it is a fact backed by specific elements that force the user to think when they should not have to.

1. **Behavioral UX beats visual UX.** A pixel-perfect design that confuses users is worse than an ugly interface that users can navigate without thinking. The six dimensions measure behavior, not aesthetics.

2. **Error states are the real test.** Anyone can design a happy path. The quality of an interface reveals itself when things go wrong. Does the user understand what happened? Can they fix it? Do they feel in control?

3. **Every score needs evidence.** A score without a screenshot reference and a specific element is useless. The audit is only valuable when someone else can read it, find the same element, and agree with the assessment.

4. **The scorecard is a communication tool.** The number matters less than the trend. A scorecard that shows 5/10 going to 7/10 after fixes is more useful than a single snapshot that says 7/10.

## Verification

After completing the UX audit:

- [ ] All six dimensions are scored 0-10
- [ ] Every score has at least two pieces of specific evidence
- [ ] Critical findings (score 4 or below) have specific, actionable fixes
- [ ] Fixes are prioritized using the impact/effort matrix
- [ ] Error states and edge cases were evaluated, not just the happy path
- [ ] Mobile responsiveness was tested at 375px viewport width
- [ ] Accessibility checks include keyboard navigation, not just color contrast
- [ ] The scorecard format is complete with trend column
- [ ] Strengths are documented so good patterns are not accidentally removed

## Related Skills

- `code-review` -- pair with UX audit for a complete pre-ship quality gate
- `browser-testing` -- use the browser tool to capture evidence for audit findings
- `frontend-patterns` -- reference for recommended interaction and layout patterns
- `e2e-testing` -- write E2E tests that verify the user flows evaluated in the audit

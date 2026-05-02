---
name: pol-probe
description: "Proof of Life probes - lightweight, disposable validation experiments to test risky hypotheses cheaply. Use for eliminating risks before expensive development and avoiding prototype theater. Keywords: pol-probe, validation, experiments, hypothesis-testing, lean-validation"
version: "1.0.0"
category: additional
compatibility: Claude Code, Claude Desktop, Cursor
metadata:
  author: EM-Team
  version: "1.0.0"
  source: Product-Manager-Skills + EM-Team synthesis
---

## Overview

Define and document a **Proof of Life (PoL) probe**—a lightweight, disposable validation artifact designed to surface harsh truths before expensive development. Use this when you need to eliminate a specific risk or test a narrow hypothesis **without building production-quality software**.

**Unique Value:** Prevents prototype theater (expensive demos that impress stakeholders but teach nothing) and forces you to match validation method to actual learning goal. PoL probes are reconnaissance missions, not MVPs—they're meant to be deleted, not scaled.

## When to Use

✅ **Early Validation:**
- Testing a narrow hypothesis without building production software
- Reducing risk before spending engineering time
- Validating feasibility (technical, user, market)
- Gathering harsh truth fast (within days, not weeks)

✅ **Risk Elimination:**
- Technical feasibility unknown
- Third-party dependencies unclear
- User task completion uncertain
- Stakeholder support needed

✅ **Fast Learning:**
- Surfaces harsh truths, not vanity metrics
- disposable—explicitly planned for deletion
- Narrow scope—tests one specific hypothesis
- Tiny & focused—reconnaissance missions

## Key Concepts

### What is a PoL Probe?

A **Proof of Life (PoL) probe** is a deliberate, disposable validation experiment designed to answer one specific question as cheaply and quickly as possible. It's not a product, not an MVP, not a pilot—it's a targeted truth-seeking mission.

**Origin:** Coined by Dean Peters (Productside), building on Marty Cagan's 2014 work on prototype flavors and Jeff Patton's principle: *"The most expensive way to test your idea is to build production-quality software."*

### The 5 Essential Characteristics

| Characteristic | What It Means | Why It Matters |
|----------------|---------------|----------------|
| **Lightweight** | Minimal resource investment (hours/days, not weeks) | If expensive, you'll avoid killing it when data says to |
| **Disposable** | Explicitly planned for deletion, not scaling | Prevents sunk-cost fallacy and scope creep |
| **Narrow Scope** | Tests one specific hypothesis or risk | Broad experiments yield ambiguous results |
| **Brutally Honest** | Surfaces harsh truths, not vanity metrics | Polite data is useless data |
| **Tiny & Focused** | Reconnaissance missions, never MVPs | Small surface area = faster learning cycles |

**Anti-Pattern:** If your "prototype" feels too polished to delete, it's not a PoL probe—it's prototype theater.

### PoL Probe vs. MVP

| Dimension | PoL Probe | MVP |
|-----------|-----------|-----|
| **Purpose** | De-risk decisions through narrow hypothesis testing | Justify ideas or defend roadmap direction |
| **Scope** | Single question, single risk | Smallest shippable product increment |
| **Lifespan** | Hours to days, then deleted | Weeks to months, then iterated |
| **Audience** | Internal team + narrow user sample | Real customers in production |
| **Fidelity** | Just enough illusion to catch signals | Production-quality (or close) |
| **Outcome** | Learn what *doesn't* work | Learn what *does* work (and ship it) |

**Key Distinction:** PoL probes are **pre-MVP reconnaissance**. You run probes to decide *if* you should build an MVP.

### The 5 Prototype Flavors

Match the probe type to your hypothesis, not your tooling comfort.

| Type | Core Question | Timeline | Tools/Methods | When to Use |
|------|---------------|----------|---------------|-------------|
| **1. Feasibility Checks** | "Can we build this?" | 1-2 days | GenAI prompt chains, API tests, spike-and-delete code | Technical risk unknown; dependencies unclear |
| **2. Task-Focused Tests** | "Can users complete this job without friction?" | 2-5 days | Optimal Workshop, UsabilityHub, task flows | Critical moments need validation |
| **3. Narrative Prototypes** | "Does this workflow earn stakeholder buy-in?" | 1-3 days | Loom walkthroughs, Sora/Synthesia videos, slideware storyboards | Need to "tell vs. test"—share story, measure interest |
| **4. Synthetic Data Simulations** | "Can we model this without production risk?" | 2-4 days | Synthea (user simulation), LangFlow (prompt logic) | Edge case exploration; unknown-unknown surfacing |
| **5. Vibe-Coded PoL Probes** | "Will this solution survive real user contact?" | 2-3 days | ChatGPT Canvas + Replit + Airtable = "Frankensoft" | Need user feedback on workflow/UX, not production code |

**Golden Rule:** *"Use the cheapest prototype that tells the harshest truth. If it doesn't sting, it's probably just theater."*

## Process

### Step 1: Define Hypothesis

**What do you believe to be true?**

**Template:**
"If we [do something], then [outcome] will happen because [rationale]."

**Examples:**
- "If we reduce the onboarding form to 3 fields, completion rate will exceed 80% because users abandon long forms."
- "If we add one-tap checkout, mobile conversion will increase by 20% because users want speed."
- "If we show pricing earlier, trial-to-paid will increase because users see value upfront."

**Quality check:** Is the hypothesis specific and falsifiable?

### Step 2: Identify Risk Being Eliminated

**What specific risk or unknown are you addressing?**

**Common risks:**
- **Feasibility risk:** Can we technically build this?
- **Usability risk:** Can users figure out how to use it?
- **Value risk:** Do users actually care about this?
- **Viability risk:** Will this achieve business outcome?

**Examples:**
- "We don't know if users will abandon signup due to form length."
- "We're unsure if third-party API can handle our volume."
- "We don't know if stakeholders will support this approach."

**Quality check:** Is the risk specific and blocking?

### Step 3: Select Prototype Type

Choose one of the 5 flavors based on your hypothesis and risk.

**Decision framework:**
- Technical risk? → Feasibility Check
- User task uncertainty? → Task-Focused Test
- Stakeholder buy-in needed? → Narrative Prototype
- Edge case exploration? → Synthetic Data Simulation
- User workflow validation? → Vibe-Coded PoL Probe

**Quality check:** Does the prototype type match the risk?

### Step 4: Define Success Criteria

**What truth are you seeking? What would prove you wrong?**

**Template:**
- **Pass:** [What validates hypothesis]
- **Fail:** [What invalidates hypothesis]
- **Learn:** [What you'll discover either way]

**Example:**
- **Pass:** 8+ users complete signup in under 2 minutes
- **Fail:** <6 users complete, or average time exceeds 5 minutes
- **Learn:** Identify specific drop-off fields

**Quality check:** Are criteria measurable and harsh?

### Step 5: Choose Tools

**What will you use to build this?**

**Match tools to prototype type:**

**Feasibility Checks:**
- GenAI (ChatGPT, Claude) for prompt validation
- API testing tools (Postman, Insomnia)
- Spike-and-delete code (throwaway code)

**Task-Focused Tests:**
- Optimal Workshop (card sorting)
- UsabilityHub (user testing)
- Figma (clickable prototypes)

**Narrative Prototypes:**
- Loom (screen recordings)
- Sora/Synthesia (text-to-video)
- PowerPoint/Keynote (storyboards)

**Synthetic Data Simulations:**
- Synthea (patient/user simulation)
- DataStax LangFlow (prompt logic)
- Faker (synthetic data generation)

**Vibe-Coded PoL Probes:**
- ChatGPT Canvas (UI generation)
- Replit (quick hosting)
- Airtable (data capture)
- Carrd (landing pages)

**Quality check:** Are tools appropriate for prototype type?

### Step 6: Set Timeline

**How long will this take?**

**Timeline by type:**
- **Feasibility Checks:** 1-2 days
- **Task-Focused Tests:** 2-5 days
- **Narrative Prototypes:** 1-3 days
- **Synthetic Data Simulations:** 2-4 days
- **Vibe-Coded PoL Probes:** 2-3 days

**Example:**
- **Build:** 2 days
- **Test:** 1 day (10 user sessions)
- **Analyze:** 1 day
- **Disposal:** Day 5 (delete all code, keep learnings)

**Quality check:** Can this be completed in <1 week?

### Step 7: Plan Disposal

**When and how will you delete this?**

**Disposal plan:**
- Set disposal date upfront (before building)
- Archive recordings/notes
- Delete Frankensoft code
- Document learnings

**Example:**
"After user sessions complete, archive recordings, delete Frankensoft code, document learnings in Notion."

**Quality check:** Is disposal committed upfront?

### Step 8: Assign Owner

**Who is accountable for executing and disposing this probe?**

**Owner responsibilities:**
- Build/run probe
- Document results
- Make go/no-go decision
- Dispose of probe artifacts

**Quality check:** Is one person accountable?

## Integration with EM-Team

### With Agents

**Product-Manager:**
- PoL probes validate requirements
- Probes inform go/no-go decisions
- Results guide feature prioritization

**Market-Intelligence:**
- Probes test market assumptions
- Task-focused tests validate user needs
- Narrative prototypes test stakeholder buy-in

**Planner:**
- PoL probes happen before planning
- Probe results inform implementation decisions
- Successful probes become epic candidates

### With Skills

**lean-ux-canvas:**
- PoL probes validate Box 8 experiments
- Probes test canvas hypotheses
- Learnings update canvas

**opportunity-solution-tree:**
- PoL probes implement OST experiments
- Probes validate solution hypotheses
- Results inform solution selection

**brainstorming:**
- PoL probes test brainstormed ideas
- Probes validate narrow hypotheses
- Learnings refine ideas

**jobs-to-be-done:**
- Probes validate customer jobs
- Task-focused tests observe job completion
- Results refine JTBD understanding

### With Workflows

**new-feature:**
- Use PoL probes in Stage 1 (Brainstorm) for validation
- Probes test design assumptions
- Successful probes proceed to Stage 2 (Spec)

**market-driven-feature:**
- Probes validate market assumptions
- Narrative prototypes test stakeholder buy-in
- Probe results inform business case

## Output Template

```markdown
---
report_id: "pol-probe-{timestamp}"
skill: "pol-probe"
probe_name: "[Descriptive name]"
prototype_type: "[Feasibility Check / Task-Focused Test / Narrative Prototype / Synthetic Data Simulation / Vibe-Coded PoL Probe]"
date: "[Date]"
status: "[planned | in_progress | completed | disposed]"
---

## Hypothesis
[One-sentence statement of what you believe to be true]

**Example:** "If we reduce the onboarding form to 3 fields, completion rate will exceed 80%."

## Risk Being Eliminated
[What specific risk or unknown are you addressing?]

**Example:** "We don't know if users will abandon signup due to form length."

## Prototype Type
- [x] Feasibility Check
- [ ] Task-Focused Test
- [ ] Narrative Prototype
- [ ] Synthetic Data Simulation
- [ ] Vibe-Coded PoL Probe

## Target Users / Audience
[Who will interact with this probe?]

**Example:** "10 users from our early access waitlist, non-technical SMB owners."

## Success Criteria (Harsh Truth)

**Pass:** [What truth are you seeking? What would prove you right?]
- [Criteria 1]
- [Criteria 2]

**Fail:** [What would prove you wrong?]
- [Criteria 1]
- [Criteria 2]

**Learn:** [What will you discover either way?]
- [Learning 1]
- [Learning 2]

**Example:**
- **Pass:** 8+ users complete signup in under 2 minutes
- **Fail:** <6 users complete, or average time exceeds 5 minutes
- **Learn:** Identify specific drop-off fields

## Tools / Stack
[What will you use to build this?]

**Example:** "ChatGPT Canvas for form UI, Airtable for data capture, Loom for post-session interviews."

## Timeline

- **Build:** [Duration]
- **Test:** [Duration]
- **Analyze:** [Duration]
- **Disposal:** [Date]

**Example:**
- **Build:** 2 days
- **Test:** 1 day (10 user sessions)
- **Analyze:** 1 day
- **Disposal:** Day 5 (delete all code, keep learnings doc)

## Disposal Plan
[When and how will you delete this?]

**Example:** "After user sessions complete, archive recordings, delete Frankensoft code, document learnings in Notion."

## Owner
[Who is accountable for running and disposing this probe?]

## Status Checklist

- [ ] Hypothesis defined
- [ ] Probe built
- [ ] Users recruited
- [ ] Testing complete
- [ ] Learnings documented
- [ ] Probe disposed

## Results (Fill after testing)

### What Happened
[What did you observe?]

### Data Collected
[Metrics, quotes, observations]

### Decision
- [ ] **GO:** Proceed to next step (specify what)
- [ ] **PIVOT:** Adjust approach (specify how)
- [ ] **KILL:** Stop, not worth pursuing (explain why)

### Key Learnings
[What did you learn? What surprised you?]

### Next Steps
[What should happen next?]

---
```

## Verification

Before launching PoL probe, verify:

**Design:**
- [ ] Hypothesis is specific and falsifiable
- [ ] Risk being eliminated is clear
- [ ] Prototype type matches risk
- [ ] Success criteria are harsh (not vanity metrics)

**Execution:**
- [ ] Can be built in 1-3 days
- [ ] Disposal date committed upfront
- [ ] Tests ONE hypothesis (not multiple)
- [ ] Tools appropriate for prototype type

**Accountability:**
- [ ] Clear owner assigned
- [ ] Owner accountable for disposal
- [ ] Decision criteria defined (GO/PIVOT/KILL)

**Learning:**
- [ ] Will learn something valuable either way
- [ ] Data will be honest (not biased)
- [ ] Results will inform next decision

## Common Pitfalls

### Broad Experiments
**Symptom:** "Will users like this?" (too broad)

**Fix:** Test one falsifiable hypothesis: "Users will complete signup in under 2 minutes"

### Proto-MVP
**Symptom:** Building something too polished to delete

**Fix:** Reduce scope. If it takes >1 week, it's too big.

### Vanity Metrics
**Symptom:** Success criteria avoid uncomfortable truth

**Fix:** Define harsh criteria. "80% completion" not "Users engaged with feature"

### Skipping Disposal Plan
**Symptom:** No upfront commitment to delete

**Fix:** Set disposal date before building. Plan deletion.

### Confirmation Bias
**Symptom:** Already know answer, want validation

**Fix:** If you're certain, don't run probe. Save time.

## Examples

### Example 1: Onboarding Form Validation

**Hypothesis:** "If we reduce the onboarding form to 3 fields, completion rate will exceed 80%."

**Risk:** Users abandon signup due to form length.

**Prototype Type:** Task-Focused Test

**Success Criteria:**
- **Pass:** 8+ users complete signup in under 2 minutes
- **Fail:** <6 users complete, or average time exceeds 5 minutes
- **Learn:** Identify specific drop-off fields

**Tools:** Figma (clickable prototype), UsabilityHub (user testing)

**Timeline:** 3 days (1 day build, 1 day test, 1 day analyze)

**Disposal:** Delete prototype after 10 user sessions, archive recordings

**Results:** 6/10 users completed, avg time 4:30 → **PIVOT**: Form fields reduced but not enough. Test 2-field version next.

### Example 2: One-Tap Checkout Feasibility

**Hypothesis:** "Apple Pay integration is feasible within our current payment stack."

**Risk:** Third-party API incompatible with existing system.

**Prototype Type:** Feasibility Check

**Success Criteria:**
- **Pass:** API responds successfully with test data
- **Fail:** API errors, incompatibility discovered
- **Learn:** Integration complexity estimated

**Tools:** Postman (API testing), test payment tokens

**Timeline:** 2 days (spike-and-delete code)

**Disposal:** Delete test code after API validated

**Results:** API integration successful → **GO**: Proceed to MVP development.

### Example 3: Stakeholder Buy-In for AI Feature

**Hypothesis:** "Stakeholders will support AI-powered recommendations if we show business value."

**Risk:** Stakeholders won't allocate budget without seeing ROI.

**Prototype Type:** Narrative Prototype

**Success Criteria:**
- **Pass:** 5/7 stakeholders express support after watching walkthrough
- **Fail:** <3 stakeholders express support
- **Learn:** What concerns stakeholders have

**Tools:** Loom (screen recording), slide deck (business case)

**Timeline:** 2 days (1 day create, 1 day share)

**Disposal:** Archive recording after stakeholder meeting

**Results:** 6/7 stakeholders expressed support, 1 concerned about cost → **GO**: Proceed with budget request.

## Best Practices

### Design Principles
- **Narrow scope:** Test ONE hypothesis
- **Harsh truth:** Success criteria must sting if wrong
- **Disposable:** Plan deletion before building
- **Fast:** Complete in <1 week

### Execution Principles
- **Document everything:** Record tests, take notes
- **Stay neutral:** Don't bias results
- **Be decisive:** Make GO/PIVOT/KILL decision after
- **Dispose ruthlessly:** Delete artifacts, keep learnings

### Integration Principles
- **Use early:** Validate before committing resources
- **Inform next steps:** Results drive decisions
- **Iterate:** Failed probes generate new hypotheses
- **Learn:** Document learnings for team

## Related Resources

- **Origin:** Dean Peters, *Vibe First, Validate Fast, Verify Fit* (2025)
- **Frameworks:** Marty Cagan's prototype flavors, Jeff Patton's lean validation
- **Skills:** `lean-ux-canvas`, `opportunity-solution-tree`, `jobs-to-be-done`
- **Agents:** `product-manager`, `market-intelligence`, `planner`

---

**Version:** 1.0.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready

---
name: lean-ux-canvas
description: "Jeff Gothelf's Lean UX Canvas v2 - Frame business problems, surface assumptions, and define testable hypotheses. Use for aligning teams on outcomes vs outputs and turning vague initiatives into learning goals. Keywords: lean-ux, hypothesis-driven, assumptions, experiments"
category: additional
compatibility: Claude Code, Claude Desktop, Cursor
metadata:
  author: EM-Team
  version: "1.0.0"
  source: Product-Manager-Skills + EM-Team synthesis
---

## Overview

Guide teams through creating **Jeff Gothelf's Lean UX Canvas (v2)**—a one-page facilitation tool that frames work around a **business problem to solve**, not a **solution to implement**. Use this to align cross-functional teams around core assumptions, craft testable hypotheses, and ensure learning happens every iteration by exposing gaps in understanding.

**Unique Value:** Acts as an "insurance policy" that exposes gaps before building—shifting conversations from outputs (features) to outcomes (behavior change) and ensuring teams build the right thing, not just build things right.

## When to Use

✅ **Early Discovery:**
- Starting a new product initiative or feature
- Framing a business problem before solutioning
- Aligning cross-functional teams on assumptions

✅ **Strategic Planning:**
- Reframing existing projects (suspect you're building wrong thing)
- Planning discovery sprints or MVPs
- Turning vague initiatives into hypotheses and learning goals

✅ **Stakeholder Management:**
- Stakeholders are solution-driven ("we need to build X")
- Need to expose assumptions before committing
- Shifting from outputs to outcomes conversation

## Canvas Structure

### The 8 Boxes (Fill in This Order)

**Layout (3 columns × 3 rows):**

```
┌─────────────────────┬──────────────┬───────────────────────┐
│ 1. Business Problem │              │ 2. Business Outcomes  │
│                     │  5. Solutions │                       │
├─────────────────────┤  (tall box   ├───────────────────────┤
│ 3. Users            │   spanning   │ 4. User Outcomes      │
│                     │   rows 1-2)  │    & Benefits         │
├─────────────────────┤              │                       │
│ 6. Hypotheses       ├──────────────┤ 8. Least Work /       │
│                     │ 7. Learn     │    Experiments        │
│                     │    First     │                       │
└─────────────────────┴──────────────┴───────────────────────┘
```

**Box 1: Business Problem**
What changed in the world that created a problem worth solving?

**Box 2: Business Outcomes**
What measurable behavior change indicates success? (Metrics)

**Box 3: Users**
Which persona(s) should you focus on first?

**Box 4: User Outcomes & Benefits**
Why would users seek this? What benefit do they gain? (Goals, emotions, empathy)

**Box 5: Solutions**
What features/initiatives might solve the problem and meet user needs?

**Box 6: Hypotheses**
Testable assumptions combining boxes 2-5 (If/Then format)

**Box 7: What's Most Important to Learn First?**
The single riskiest assumption right now

**Box 8: What's the Least Work to Learn Next?**
Smallest experiment to validate/invalidate that assumption

## Process

### Step 1: Gather Context

Before filling the canvas, collect:

**Business Context:**
- Stakeholder request, product brief, or initiative description
- Business metrics (revenue, churn, growth targets, KPIs)
- Strategic goals (OKRs, roadmap priorities)

**User Context:**
- Customer research, personas, JTBD insights
- User feedback, support tickets, churn reasons
- Competitor analysis, market trends

### Step 2: Fill Box 1 - Business Problem

**What problem does the business have that you are trying to solve?**

Describe:
- **Current state:** How does the business deliver value today?
- **What changed:** Market shift, competitive threat, customer behavior change
- **Why it matters:** Why isn't the current situation meeting expectations?

**Good examples:**
- "Our checkout conversion rate dropped 15% after mobile traffic surpassed desktop. Our checkout flow wasn't designed for mobile, and competitors have one-tap checkout."
- "Enterprise customers are churning after 6 months because our onboarding process requires 3+ weeks of manual configuration. Competitors offer self-service onboarding."

**Bad examples (too vague):**
- "We need to increase revenue" (no context on what changed)
- "Users want more features" (no business problem stated)

**Quality check:** Does this describe what **changed** and why it creates a problem?

### Step 3: Fill Box 2 - Business Outcomes

**How will you know you solved the business problem? What will you measure?**

Focus on **measurable behavior change** (leading indicators welcome). Ask: "What will people be doing differently if the solution works?"

**Examples of business outcomes:**
- Increase mobile checkout conversion rate from 45% to 60%
- Reduce enterprise onboarding time from 3 weeks to 3 days
- Increase average order value from $50 to $75
- Reduce customer support tickets by 30%
- Increase free-to-paid conversion rate from 5% to 10%

**Important:** This is **Box 2 (behavior change/metrics)**, not Box 4 (user benefits/empathy).

**Quality check:** Are these measurable? Observable? Do they indicate behavior change?

### Step 4: Fill Box 3 - Users

**What types (i.e., personas) of users and customers should you focus on first?**

Consider:
- Who **buys** it?
- Who **uses** it?
- Who **configures** it?
- Who **administers** it?

**Why this matters:** Teams tend to shortcut here ("everyone"). The canvas wants a **shared vision** of the user.

**Examples:**
- "SMB owners (1-10 employees) in professional services (consultants, accountants, lawyers)"
- "Enterprise IT admins who configure SSO for 500+ employees"
- "Mobile-first millennials (25-35) who order takeout 3+ times per week"

**Quality check:** Is this specific enough to imagine a real person?

### Step 5: Fill Box 4 - User Outcomes & Benefits

**Why would your users seek out your product or service? What benefit would they gain?**

Focus on **goals, benefits, emotions, empathy**—not metrics (those go in Box 2).

**Examples of user outcomes & benefits:**
- Save 10 hours per week on manual data entry (spend more time with family)
- Get promoted by delivering projects faster
- Avoid embarrassment of failed checkout in front of friends
- Feel confident configuring enterprise software without calling support

**Why this matters:** This is the **empathy box**. It's about human motivation.

**Quality check:** Does this explain **why** the user cares (not just what they'll do)?

### Step 6: Fill Box 5 - Solutions

**What can we make that will solve our business problem and meet the needs of our customers at the same time?**

List **features, initiatives, policies, systems, or business model shifts** that might work. Encourage a wide solution space.

**Examples:**
- One-tap mobile checkout (Apple Pay, Google Pay)
- Self-service onboarding wizard (no human configuration)
- AI-powered recommendation engine
- Concierge onboarding (high-touch, manual—test before automating)
- Change pricing model (usage-based instead of flat rate)

**Important:** These are **hypotheses**, not commitments. You're exploring options.

**Quality check:** Do you have at least 3 candidate solutions?

### Step 7: Fill Box 6 - Hypotheses

**Create testable hypotheses by combining assumptions from Boxes 2-5.**

**Template:**
> **We believe that** [business outcome from Box 2] **will be achieved if** [user from Box 3] **attains** [benefit from Box 4] **with** [solution from Box 5].

**Rules:**
- Each hypothesis focuses on **one** solution (from Box 5)
- Combines assumptions from Boxes 2, 3, 4, and 5
- Must be testable (you can design an experiment to validate/invalidate it)

**Example:**
> **We believe that** increasing mobile checkout conversion rate from 45% to 60% **will be achieved if** mobile-first millennials (25-35) **attain** faster, friction-free checkout **with** one-tap Apple Pay integration.

**Quality check:** Does each hypothesis clearly state what you believe will happen?

### Step 8: Fill Box 7 - What's Most Important to Learn First?

**Identify the riskiest assumption right now.**

**Types of risk:**
- **Value risk:** Will users actually use this? Do they care?
- **Usability risk:** Can users figure out how to use it?
- **Feasibility risk:** Can we technically build this?
- **Viability risk:** Will this achieve the business outcome?

**Hint:** Early on, focus risk on **value** more than feasibility.

**Example:**
- "Users will trust one-tap checkout without seeing itemized charges"
- "Self-service onboarding will reduce setup time to <3 days"
- "AI recommendations will increase average order value by 50%"

**Quality check:** Which assumption, if wrong, would kill the initiative?

### Step 9: Fill Box 8 - What's the Least Work to Learn Next?

**Design an experiment to validate or invalidate the riskiest assumption as fast as you can.**

**Examples of experiment types:**
- **Customer interviews** — 5-10 interviews to test value hypothesis
- **Landing page** — Fake door test to measure interest
- **Concierge / manual prototype** — High-touch, manual version
- **Wizard-of-Oz** — Pretend feature exists (humans behind scenes)
- **Smoke test** — Announce feature, measure signups
- **A/B test** — Build minimal version, test with 50% of users

**Quality check:** Is this the **smallest test** that can validate/invalidate the assumption? (If >2 weeks, it's too big—break it down.)

## Integration with EM-Team

### With Agents

**Product-Manager:**
- Use canvas to frame problem before requirements gathering
- Hypotheses inform epic creation
- Experiments guide validation approach

**Market-Intelligence:**
- Business problems inform market analysis
- User outcomes guide customer research
- Hypotheses test market assumptions

**Planner:**
- Canvas provides structured input for implementation planning
- Hypotheses inform acceptance criteria
- Experiments define verification steps

### With Skills

**jobs-to-be-done:**
- JTBD fills Box 3 (Users) and Box 4 (User Outcomes)
- Jobs and pains inform Box 1 (Business Problem)
- Gains inform Box 2 (Business Outcomes)

**brainstorming:**
- Canvas provides structure for ideation
- Box 5 (Solutions) generates multiple options
- Hypotheses test brainstormed ideas

**spec-driven-development:**
- Canvas inputs into spec creation
- Business problem becomes spec problem statement
- Hypotheses become success criteria

**writing-plans:**
- Canvas informs task breakdown
- Experiments become validation tasks
- Hypotheses guide acceptance criteria

### With Workflows

**new-feature:**
- Use canvas in Stage 1 (Brainstorm) for problem framing
- Business problem and outcomes inform design
- Hypotheses and experiments guide validation

**market-driven-feature:**
- Canvas provides structure for solution design phase
- Business outcomes tie to market validation
- Experiments validate market assumptions

## Output Template

```markdown
---
report_id: "lean-ux-canvas-{timestamp}"
skill: "lean-ux-canvas"
initiative: "[Initiative name]"
date: "[Date]"
iteration: 1
---

## Initiative Overview
[Brief description of initiative]

## Canvas

### 1. Business Problem
[What changed and why it matters now]

### 2. Business Outcomes
[Measurable behavior change - metrics]

### 3. Users
[Target persona(s)]

### 4. User Outcomes & Benefits
[Goals, benefits, emotions, empathy]

### 5. Solutions
[Candidate features/initiatives]

### 6. Hypotheses
[Testable assumptions in If/Then format]

### 7. What's Most Important to Learn First?
[Riskiest assumption]

### 8. What's the Least Work to Learn Next?
[Smallest experiment]

## Next Steps

1. **Run experiment:** [Experiment from Box 8]
2. **Timeline:** [Duration]
3. **Owner:** [Who's accountable]
4. **Success criteria:** [What validates hypothesis]

## Participants
[Who contributed to canvas]

---
```

## Verification

Before completing canvas, verify:

**Problem Framing:**
- [ ] Box 1 describes what changed (not just "we need X")
- [ ] Problem is specific and actionable
- [ ] Business context is clear

**Measurable Outcomes:**
- [ ] Box 2 outcomes are measurable
- [ ] Outcomes indicate behavior change
- [ ] Leading indicators identified (if possible)

**User-Centered:**
- [ ] Box 3 personas are specific
- [ ] Box 4 explains why users care (empathy)
- [ ] User outcomes distinct from business outcomes

**Solution Space:**
- [ ] Box 5 has 3+ candidate solutions
- [ ] Solutions are hypotheses, not commitments
- [ ] Diverse solution options considered

**Testable Hypotheses:**
- [ ] Box 6 hypotheses follow If/Then format
- [ ] Each hypothesis combines boxes 2-5
- [ ] Hypotheses are falsifiable

**Learning-Focused:**
- [ ] Box 7 identifies riskiest assumption
- [ ] Box 8 experiment is minimal (<2 weeks)
- [ ] Experiment validates specific assumption

## Common Pitfalls

### Starting with Solutions, Not Problems
**Symptom:** Box 1 says "We need to build X"

**Fix:** Ask: "What changed in the world? Why is this a problem now?"

### Vague Business Outcomes
**Symptom:** Box 2 says "Increase revenue" or "Make users happy"

**Fix:** Define measurable behavior change

### Too-Broad User Segments
**Symptom:** Box 3 says "All users" or "Everyone"

**Fix:** Pick one persona to start

### Confusing Box 2 and Box 4
**Symptom:** Putting emotions in Box 2 and metrics in Box 4

**Fix:** Box 2 = Behavior change (metrics). Box 4 = Goals/benefits/emotions.

### Only One Solution in Box 5
**Symptom:** Listing one feature because stakeholders already decided

**Fix:** Force yourself to list 3+ solutions

### Skipping Experiments (Box 8)
**Symptom:** "We'll just build it and see what happens"

**Fix:** Design smallest experiment first

## Examples

### Example 1: Mobile Checkout Optimization

**Box 1 - Business Problem:**
"Our checkout conversion rate dropped 15% after mobile traffic surpassed desktop. Our checkout flow wasn't designed for mobile, and competitors have one-tap checkout."

**Box 2 - Business Outcomes:**
"Increase mobile checkout conversion rate from 45% to 60%"

**Box 3 - Users:**
"Mobile-first millennials (25-35) who order takeout 3+ times per week"

**Box 4 - User Outcomes:**
"Complete checkout in under 30 seconds while walking. Feel confident payment is secure. Avoid frustration of re-entering payment info."

**Box 5 - Solutions:**
1. One-tap checkout (Apple Pay, Google Pay)
2. Optimized mobile checkout flow (fewer fields)
3. Guest checkout (no account required)
4. SMS-to-complete (start on web, finish on mobile)

**Box 6 - Hypotheses:**
"We believe that increasing mobile checkout conversion rate from 45% to 60% will be achieved if mobile-first millennials (25-35) attain faster, friction-free checkout with one-tap Apple Pay integration."

**Box 7 - Most Important to Learn:**
"Will users trust one-tap checkout without seeing itemized charges?"

**Box 8 - Least Work to Learn:**
"Landing page test: Create fake door showing one-tap checkout, measure click-through rate vs. standard checkout. Duration: 1 week."

### Example 2: Enterprise Onboarding Improvement

**Box 1 - Business Problem:**
"Enterprise customers are churning after 6 months because our onboarding process requires 3+ weeks of manual configuration. Competitors offer self-service onboarding."

**Box 2 - Business Outcomes:**
"Reduce enterprise onboarding time from 3 weeks to 3 days. Increase 6-month retention rate from 60% to 80%."

**Box 3 - Users:**
"Enterprise IT admins who configure SSO for 500+ employees"

**Box 4 - User Outcomes:**
"Complete setup in <3 days without calling support. Feel confident configuration is correct. Avoid frustration of manual data entry."

**Box 5 - Solutions:**
1. Self-service onboarding wizard
2. Concierge onboarding (human-assisted)
3. Template-based configuration
4. Video-guided setup

**Box 6 - Hypotheses:**
"We believe that reducing enterprise onboarding time from 3 weeks to 3 days will be achieved if IT admins attain faster setup with self-service onboarding wizard."

**Box 7 - Most Important to Learn:**
"Can IT admins complete setup without human assistance?"

**Box 8 - Least Work to Learn:**
"Concierge test: Manually guide 5 IT admins through proposed wizard flow, observe where they get stuck. Duration: 1 week."

## Best Practices

### Facilitation
- Run canvas as cross-functional workshop (PM, design, engineering)
- Time-box to 90-120 minutes
- Use physical or digital whiteboard
- Assign facilitator to keep time and focus

### Quality
- Fill boxes in order (1-8)
- Don't skip boxes or jump ahead
- Challenge vague inputs
- Force divergence (3+ solutions in Box 5)

### Iteration
- Treat canvas as living document
- Update based on learnings
- Revisit after each experiment
- Create new canvas iteration when pivoting

## Related Resources

- **Origin:** Jeff Gothelf, *Lean UX* (O'Reilly, 2013)
- **Official Canvas:** [Lean UX Canvas v2](https://jeffgothelf.com/blog/leanuxcanvas-v2/)
- **Skills:** `jobs-to-be-done`, `brainstorming`, `spec-driven-development`
- **Agents:** `product-manager`, `market-intelligence`, `planner`

---

**Version:** 1.0.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready

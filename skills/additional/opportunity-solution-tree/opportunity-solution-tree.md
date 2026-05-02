---
name: opportunity-solution-tree
description: "Build Opportunity Solution Trees (Teresa Torres) from outcomes to opportunities, solutions, and experiments. Use for moving from vague requests to structured discovery and avoiding feature factory syndrome. Keywords: ost, opportunity-solution-tree, discovery, product-discovery"
version: "1.0.0"
category: additional
compatibility: Claude Code, Claude Desktop, Cursor
metadata:
  author: EM-Team
  version: "1.0.0"
  source: Product-Manager-Skills + EM-Team synthesis
---

## Overview

Guide product managers through creating an **Opportunity Solution Tree (OST)**—a visual framework that connects **desired outcomes → opportunities (problems) → solutions → experiments**. Use this to move from vague product requests to structured discovery, ensuring teams solve the right problems before jumping to solutions.

**Unique Value:** Forces divergent thinking before convergence, prevents "feature factory" syndrome, and ensures every solution maps to an experiment—avoiding premature convergence on ideas.

## When to Use

✅ **Discovery & Validation:**
- Stakeholder requests a feature or product initiative
- Starting discovery for a new product area
- Clarifying vague OKRs or strategic goals
- Prioritizing which problems to solve first

✅ **Strategic Planning:**
- Aligning team on what outcomes you're driving
- Exploring multiple solution options before committing
- Designing experiments to validate assumptions

✅ **Problem Framing:**
- Moving from solution-first to outcome-first thinking
- Identifying customer problems worth solving
- Structuring discovery research

## Key Concepts

### What is an Opportunity Solution Tree (OST)?

A visual framework (Teresa Torres, *Continuous Discovery Habits*) that connects:

```
         Desired Outcome (1)
                |
    +-----------+-----------+
    |           |           |
Opportunity  Opportunity  Opportunity (3)
    |           |           |
  +-+-+       +-+-+       +-+-+
  | | |       | | |       | | |
 S1 S2 S3    S1 S2 S3    S1 S2 S3 (9 total solutions)
```

**Four Levels:**

1. **Desired Outcome** — Business goal or product metric
2. **Opportunities** — Customer problems, needs, pain points, desires
3. **Solutions** — Ways to address each opportunity
4. **Experiments** — Tests to validate solutions

### Why This Works

- **Outcome-driven:** Starts with business goal, not feature requests
- **Divergent before convergent:** Explores multiple opportunities before picking solutions
- **Problem-focused:** Opportunities are problems, not solutions disguised as problems
- **Testable:** Each solution maps to an experiment
- **POC selection:** Evaluates feasibility, impact, market fit before committing

### Anti-Patterns

**NOT a feature list:** Opportunities are problems customers face, not "we need dark mode"

**NOT solution-first:** Don't start with "we should build X"—start with "customers struggle with Y"

**NOT waterfall planning:** OST is a discovery tool, not a project plan

**NOT one-time exercise:** OSTs evolve as you learn from experiments

## Process

### Phase 1: Generate OST

#### Step 1: Extract Desired Outcome

**What's the desired outcome for this initiative?**

**What business or product metric are you trying to move?**

**Common outcome categories:**

1. **Revenue growth** — Increase ARR, expand revenue from existing customers, new revenue streams
2. **Customer retention** — Reduce churn, increase activation, improve engagement/stickiness
3. **Customer acquisition** — Increase sign-ups, trial conversions, new user growth
4. **Product efficiency** — Reduce support costs, decrease time-to-value, improve operational metrics

**Quality check:** Is the outcome specific and measurable?

**Example:** "Increase trial-to-paid conversion from 15% to 25%" (good) vs. "Improve user experience" (too vague)

#### Step 2: Identify Opportunities (Problems to Solve)

Based on the desired outcome, generate **3 opportunities** (customer problems or needs).

**Each opportunity should include:**
- Problem statement
- Evidence (from customer research, analytics, support tickets)
- Impact on desired outcome

**Example (if Outcome = Increase trial-to-paid conversion):**

**Opportunity 1: Users don't experience value during trial**
- **Evidence:** Onboarding analytics show 60% drop-off at step 3; support tickets: "I don't get how to use this"
- **Impact:** Users abandon before reaching "aha moment"

**Opportunity 2: Pricing is unclear or misaligned**
- **Evidence:** Conversion funnel drop-off at pricing page (45% exit); sales objections: "too expensive"
- **Impact:** Users unsure if paid plan is worth it

**Opportunity 3: Free plan is 'good enough'**
- **Evidence:** Frequent free-tier users (>6 months); support requests asking for workarounds
- **Impact:** No compelling reason to upgrade

**Quality check:** Are these problems (not solutions)? Can you validate them with evidence?

#### Step 3: Generate Solutions for Opportunities

For each opportunity, generate **3 potential solutions**.

**Each solution should include:**
- Solution description
- Hypothesis (why it will work)
- Experiment type (how to test)

**Example (for Opportunity 1: Users don't experience value):**

**Solution 1: Guided onboarding checklist**
- **Hypothesis:** Structured guidance increases completion rate
- **Experiment:** A/B test checklist vs. no checklist, measure activation rate

**Solution 2: Time-to-value triggers**
- **Hypothesis:** Proactive nudges prevent drop-off
- **Experiment:** Track engagement with prompts, measure trial-to-paid lift

**Solution 3: Human-assisted onboarding**
- **Hypothesis:** Personal touch increases conversion for high-intent users
- **Experiment:** Offer to 50 trial users, measure conversion vs. control group

**Quality check:** Do you have 3 diverse solutions per opportunity?

### Phase 2: Select Proof-of-Concept (POC)

#### Step 4: Evaluate Solutions

Score each solution on **Feasibility** (how hard to build), **Impact** (how much it moves outcome), **Market Fit** (customer need).

| Solution | Feasibility (1-5) | Impact (1-5) | Market Fit (1-5) | Total Score | Rationale |
|----------|-------------------|--------------|------------------|-------------|-----------|
| Solution 1: Guided checklist | 4 | 4 | 5 | 13 | High feasibility (UI pattern), proven impact, strong market fit |
| Solution 2: Time-to-value triggers | 3 | 3 | 4 | 10 | Medium feasibility, moderate impact, good market fit |
| Solution 3: Human-assisted | 5 | 5 | 3 | 13 | High feasibility (no dev), high impact, lower market fit |

**Scoring criteria:**
- **Feasibility:** 1 = months, 5 = days/weeks
- **Impact:** 1 = minimal movement, 5 = major shift
- **Market Fit:** 1 = customers don't care, 5 = actively request this

**Quality check:** Are scores based on evidence (not guesses)?

#### Step 5: Define Experiment

**How will you test this solution?**

**Experiment types:**

1. **A/B test** — Build MVP, show to 50% of users, compare vs. control
2. **Prototype + usability test** — Clickable prototype, test with 10 users
3. **Manual concierge test** — Run manually with 20 users, measure outcomes

**Example:**
- **Type:** A/B test
- **Participants:** 100 trial users (50% see checklist, 50% control)
- **Duration:** 2 weeks
- **Success criteria:** Checklist group achieves 25%+ activation vs. 15% control

**Quality check:** Is this the smallest test that validates the hypothesis?

## Integration with EM-Team

### With Agents

**Product-Manager:**
- OST structures discovery work
- Opportunities inform requirements
- Solutions guide feature prioritization
- Experiments define validation approach

**Market-Intelligence:**
- Desired outcomes tie to market goals
- Opportunities validated by market research
- Solutions evaluated for competitive differentiation
- Experiments test market assumptions

**Planner:**
- OST provides input for implementation planning
- Selected POC becomes epic/feature
- Experiments define acceptance criteria
- Solutions inform task breakdown

### With Skills

**jobs-to-be-done:**
- JTBD research identifies opportunities
- Jobs and pains inform opportunity statements
- Gains inform solution ideas

**lean-ux-canvas:**
- OST can follow canvas to explore solutions
- Opportunities align with canvas business problems
- Solutions map to canvas hypotheses
- Experiments align with canvas experiments

**brainstorming:**
- OST provides structure for ideation
- Generate multiple solutions per opportunity
- Divergent thinking before convergence

**writing-plans:**
- Selected POC becomes plan focus
- Experiments define validation tasks
- Solutions inform technical approach

### With Workflows

**new-feature:**
- Use OST in Stage 1 (Brainstorm) for solution exploration
- Opportunities inform design decisions
- Solutions become feature candidates
- Experiments guide validation

**market-driven-feature:**
- OST structures solution design phase
- Market opportunities feed into OST
- Solutions evaluated for market fit
- Experiments validate market assumptions

## Output Template

```markdown
---
report_id: "ost-{timestamp}"
skill: "opportunity-solution-tree"
initiative: "[Initiative name]"
date: "[Date]"
---

## Desired Outcome
**Outcome:** [Specific, measurable goal]
**Target Metric:** [Business/product metric]
**Why it matters:** [Rationale]

## Opportunity Map

### Opportunity 1: [Name]
**Problem:** [Description]
**Evidence:** [From research/analytics]

**Solutions:**
1. [Solution A] - Hypothesis: [Why it works] - Experiment: [How to test]
2. [Solution B] - Hypothesis: [Why it works] - Experiment: [How to test]
3. [Solution C] - Hypothesis: [Why it works] - Experiment: [How to test]

### Opportunity 2: [Name]
**Problem:** [Description]
**Evidence:** [From research/analytics]

**Solutions:**
1. [Solution A] - Hypothesis: [Why it works] - Experiment: [How to test]
2. [Solution B] - Hypothesis: [Why it works] - Experiment: [How to test]
3. [Solution C] - Hypothesis: [Why it works] - Experiment: [How to test]

### Opportunity 3: [Name]
**Problem:** [Description]
**Evidence:** [From research/analytics]

**Solutions:**
1. [Solution A] - Hypothesis: [Why it works] - Experiment: [How to test]
2. [Solution B] - Hypothesis: [Why it works] - Experiment: [How to test]
3. [Solution C] - Hypothesis: [Why it works] - Experiment: [How to test]

## Selected POC

**Opportunity:** [Selected opportunity]
**Solution:** [Selected solution]

**Hypothesis:**
"If we [implement solution], then [outcome metric] will [increase/decrease] from [X] to [Y] because [rationale]."

**Experiment:**
- **Type:** [A/B test / Prototype test / Concierge test]
- **Participants:** [Number of users, segment]
- **Duration:** [Timeline]
- **Success criteria:** [What validates the hypothesis]

**Feasibility Score:** [1-5]
**Impact Score:** [1-5]
**Market Fit Score:** [1-5]
**Total:** [Sum]

**Why this POC:**
- [Rationale 1]
- [Rationale 2]
- [Rationale 3]

## Next Steps

1. **Build experiment:** [Specific action]
2. **Run experiment:** [Specific action]
3. **Measure results:** [Specific metric]
4. **Decide:** [If successful → scale; if failed → try next solution]

---
```

## Verification

Before completing OST, verify:

**Outcome:**
- [ ] Outcome is specific and measurable
- [ ] Outcome ties to business/product metric
- [ ] Rationale is clear

**Opportunities:**
- [ ] 3 opportunities identified
- [ ] Opportunities are problems (not solutions)
- [ ] Evidence supports each opportunity
- [ ] Opportunities connect to desired outcome

**Solutions:**
- [ ] 3 solutions per opportunity (9 total)
- [ ] Solutions are diverse (not just variations)
- [ ] Each solution has hypothesis
- [ ] Each solution has experiment type

**POC Selection:**
- [ ] Solutions scored on feasibility, impact, market fit
- [ ] Scoring criteria applied consistently
- [ ] POC rationale is clear
- [ ] POC has testable hypothesis

**Experiments:**
- [ ] Experiment type is appropriate
- [ ] Experiment is minimal (<2 weeks if possible)
- [ ] Success criteria are measurable
- [ ] Participants defined

## Common Pitfalls

### Opportunities Disguised as Solutions
**Symptom:** "Opportunity: We need a mobile app"

**Fix:** Reframe as customer problem: "Mobile-first users can't access product on the go"

### Skipping Divergence
**Symptom:** "We know the solution is [X], just need to build it"

**Fix:** Generate 3 solutions per opportunity. Force divergence before convergence.

### Outcome Too Vague
**Symptom:** "Desired Outcome: Improve user experience"

**Fix:** Make measurable: "Increase NPS from 30 to 50" or "Reduce onboarding drop-off from 60% to 40%"

### No Experiments
**Symptom:** Picking solution and moving to roadmap

**Fix:** Every solution must map to an experiment. No experiments = no OST.

### Analysis Paralysis
**Symptom:** Generating 20 opportunities, 50 solutions

**Fix:** Limit to 3 opportunities, 3 solutions each (9 total). Pick POC, run experiment, learn, iterate.

## Examples

### Example 1: Trial-to-Paid Conversion

**Desired Outcome:**
"Increase trial-to-paid conversion from 15% to 25%"

**Opportunity 1: Users don't experience value during trial**
- Evidence: 60% drop-off at onboarding step 3; support: "I don't get how to use this"
- Solutions:
  1. Guided onboarding checklist (A/B test, measure activation)
  2. Time-to-value triggers (Track prompts, measure conversion)
  3. Human-assisted onboarding (Offer to 50 users, measure vs. control)

**Opportunity 2: Pricing is unclear**
- Evidence: 45% exit at pricing page; sales objections: "too expensive"
- Solutions:
  1. Pricing page redesign (A/B test, measure completion)
  2. Value-based pricing tiers (Prototype test, 10 users)
  3. Free trial extension (Concierge test, 20 users, measure conversion)

**Opportunity 3: Free plan is good enough**
- Evidence: 30% free users >6 months; requests for workarounds
- Solutions:
  1. Feature limits on free plan (A/B test, measure upgrade rate)
  2. Usage-based pricing (Prototype test, 10 users)
  3. Team collaboration (paid only) (A/B test, measure upgrade rate)

**Selected POC:**
Guided onboarding checklist (Solution 1, Opportunity 1)
- Feasibility: 4, Impact: 4, Market Fit: 5 (Total: 13)
- Experiment: A/B test with 100 trial users, 2 weeks
- Success: 25%+ activation in checklist group vs. 15% control

### Example 2: Mobile Checkout Optimization

**Desired Outcome:**
"Increase mobile checkout conversion from 45% to 60%"

**Opportunity 1: Checkout flow is too long on mobile**
- Evidence: 70% drop-off at payment step; mobile cart abandonment 2x desktop
- Solutions:
  1. One-tap checkout (Apple Pay/Google Pay) (A/B test)
  2. Fewer form fields (Prototype test, 10 users)
  3. Guest checkout (A/B test, measure completion)

**Opportunity 2: Users don't trust mobile security**
- Evidence: Support tickets: "Is this safe?"; exit at payment step
- Solutions:
  1. Trust badges (A/B test, measure completion)
  2. Security assurance copy (Prototype test, 10 users)
  3. Payment method icons (A/B test, measure completion)

**Opportunity 3: Mobile UX is poor**
- Evidence: Low mobile usability score; complaints: "hard to use"
- Solutions:
  1. Responsive redesign (Usability test, 10 users)
  2. Mobile-first checkout flow (A/B test, measure conversion)
  3. Progressive web app (A/B test, measure conversion)

**Selected POC:**
One-tap checkout (Solution 1, Opportunity 1)
- Feasibility: 3, Impact: 5, Market Fit: 5 (Total: 13)
- Experiment: Landing page test (fake door), 1 week, measure CTR

## Best Practices

### Divergent Thinking
- Generate 3 opportunities minimum
- Generate 3 solutions per opportunity (9 total)
- Encourage wild ideas alongside practical ones
- Don't converge too early

### Evidence-Based
- Support opportunities with data/research
- Validate assumptions before investing
- Use customer interviews, analytics, support tickets
- Test hypotheses with experiments

### Iterative
- Update OST as you learn
- Run experiments sequentially
- Pivot to next solution if first fails
- Revisit opportunities if solutions don't work

### Collaborative
- Run OST as cross-functional workshop
- Include PM, design, engineering
- Facilitate divergent thinking
- Score solutions collectively

## Related Resources

- **Origin:** Teresa Torres, *Continuous Discovery Habits* (2021)
- **Skills:** `jobs-to-be-done`, `lean-ux-canvas`, `brainstorming`
- **Agents:** `product-manager`, `market-intelligence`, `planner`
- **Workflows:** `new-feature`, `market-driven-feature`

---

**Version:** 1.0.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready

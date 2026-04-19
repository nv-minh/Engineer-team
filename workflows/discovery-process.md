---
name: discovery-process
description: "Complete discovery cycle from problem hypothesis to validated solution. Orchestrates problem framing, customer interviews, synthesis, and experimentation. Use for systematic exploration before committing to development. Keywords: discovery, product-discovery, customer-research, validation"
category: Discovery
version: 2.0.0
last_updated: 2026-04-19
status: Production Ready
---

## Overview

Guide product managers through a **complete discovery cycle**—from initial problem hypothesis to validated solution—by orchestrating problem framing, customer interviews, synthesis, and experimentation into a structured process. Use this to systematically explore problem spaces, validate assumptions, and build confidence before committing to full development.

**Unique Value:** De-risks product decisions by testing assumptions before expensive builds, grounds decisions in real customer problems (not internal opinions), and builds confidence progressively through small experiments.

## When to Use

✅ **New Product/Feature Areas:**
- Exploring new product/feature areas
- Validating strategic initiatives before roadmap commitment
- Investigating retention or churn problems

✅ **Continuous Discovery:**
- Weekly customer touchpoints (Teresa Torres model)
- Ongoing discovery practice running in parallel with delivery
- 1-2 discovery cycles per quarter

✅ **Problem Validation:**
- Understanding customer problems before building
- Validating assumptions with real customer data
- Identifying which problems are worth solving

❌ **NOT for:**
- Well-understood problems (move to execution)
- Stakeholders already committed to solution (address alignment first)
- Tactical bug fixes or technical debt (no discovery needed)

## Workflow Stages

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  FRAME → RESEARCH → SYNTHESIZE → SOLUTIONS → DECIDE              │
│    1        2           3             4          5              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Timeline: 2-4 weeks per discovery cycle
```

## Stage 1: Frame the Problem (Day 1-2)

**Goal:** Define what you're investigating, who's affected, and success criteria.

### Activities

**1. Run Problem Framing**
- **Use:** `lean-ux-canvas` skill
- **Participants:** PM, design, engineering lead
- **Duration:** 120 minutes
- **Output:** Business problem + "How Might We" questions

**2. Create Formal Problem Statement**
- **Use:** Template-based problem statement
- **Participants:** PM
- **Duration:** 30 minutes
- **Output:** Structured problem statement with hypothesis

**3. Define Proto-Personas (If Needed)**
- **Use:** Customer segment analysis
- **When:** Target customer segment unclear
- **Duration:** 60 minutes
- **Output:** Hypothesis-driven personas

**4. Map Jobs-to-be-Done (If Needed)**
- **Use:** `jobs-to-be-done` skill
- **When:** Customer motivations unclear
- **Duration:** 60 minutes
- **Output:** JTBD statements

### Outputs

- **Problem hypothesis:** "We believe [persona] struggles with [problem] because [root cause], leading to [consequence]."
- **Research questions:** 3-5 questions to answer through discovery
- **Success criteria:** What would validate/invalidate the problem?

### Decision Point 1

**If YES** (enough context): → Proceed to Stage 2 (Research Planning)

**If NO** (need more context): → Gather existing data first
- Review support tickets, churn surveys, NPS feedback
- Analyze product analytics (drop-off points, usage patterns)
- Review competitor research, market trends
- **Time impact:** +2-3 days

---

## Stage 2: Research Planning (Day 3)

**Goal:** Design research approach, recruit participants, prepare interview guide.

### Activities

**1. Prep Discovery Interviews**
- **Methodology:** Problem validation, JTBD, switch interviews
- **Participants:** PM, design
- **Duration:** 90 minutes
- **Output:** Interview plan with methodology, questions, biases to avoid

**2. Recruit Participants**
- **Target:** 5-10 customers per discovery cycle
- **Segment:** Focus on personas from Stage 1
- **Recruitment channels:**
  - Existing customers (email, in-app prompts)
  - Churned customers (exit interviews)
  - Cold outreach (LinkedIn, communities)
- **Incentive:** $50-100 gift card or product credit
- **Duration:** 2-3 days (parallel with Stage 1)

**3. Schedule Interviews**
- **Format:** 45-60 min per interview (30-40 min conversation + buffer)
- **Timeline:** Spread across 1-2 weeks
- **Recording:** Get consent, record for synthesis

### Outputs

- **Interview guide:** 5-7 open-ended questions (Mom Test style)
- **Participant roster:** 5-10 scheduled interviews
- **Synthesis plan:** How you'll capture and analyze insights

---

## Stage 3: Conduct Research (Week 1-2)

**Goal:** Gather qualitative evidence through customer interviews.

### Activities

**1. Conduct Discovery Interviews**
- **Methodology:** Focus on past behavior (not hypotheticals)
- **Participants:** PM + optional observer (design, eng)
- **Duration:** 5-10 interviews over 1-2 weeks
- **Focus areas:**
  - Past behavior: "Tell me about the last time you [experienced this problem]"
  - Workarounds: "How do you currently handle this?"
  - Alternatives tried: "Have you tried other solutions? Why did you stop?"
  - Pain intensity: "How much time/money does this cost you?"

**2. Take Structured Notes**
- **Template:**
  - Participant: [Name, role, company size]
  - Context: [When/where they experience problem]
  - Actions: [What they do, step-by-step]
  - Pain points: [Frustrations, blockers]
  - Workarounds: [Current solutions]
  - Quotes: [Verbatim customer language]
  - Insights: [Patterns, surprises]

**3. Review Support Tickets & Analytics (Parallel)**
- **Support tickets:** Tag by theme (onboarding, feature confusion, bugs)
- **Analytics:** Identify drop-off points, feature usage, cohort behavior
- **Surveys:** Review NPS comments, exit surveys, feature requests

### Outputs

- **Interview transcripts:** Recorded sessions + detailed notes
- **Support ticket themes:** Top 10 issues by frequency
- **Analytics insights:** Quantitative data on behavior

### Decision Point 2

**Saturation** = same pain points emerge across 3+ interviews, no new insights

**If YES** (saturated after 5-7 interviews): → Proceed to Stage 4 (Synthesis)

**If NO** (still learning new things): → Schedule 3-5 more interviews
- **Time impact:** +1 week

---

## Stage 4: Synthesize Insights (End of Week 2)

**Goal:** Identify patterns, prioritize pain points, map opportunities.

### Activities

**1. Affinity Mapping (Thematic Analysis)**
- **Method:**
  - Write each insight/quote on sticky note
  - Group by theme (e.g., "onboarding confusion," "pricing objections")
  - Count frequency (how many customers mentioned each theme)
- **Participants:** PM, design, optional eng
- **Duration:** 90-120 minutes
- **Output:** Themed clusters with frequency counts

**2. Create Customer Journey Map (Optional)**
- **When:** Pain points span multiple phases (discover, try, buy, use, support)
- **Duration:** 90 minutes
- **Output:** Journey map with opportunities ranked by impact

**3. Prioritize Pain Points**
- **Criteria:**
  - **Frequency:** How many customers mentioned this?
  - **Intensity:** How painful is it? (time wasted, money lost, emotional frustration)
  - **Strategic fit:** Does solving this align with business goals?
- **Method:** Score each pain point (1-5) on frequency, intensity, strategic fit
- **Output:** Ranked list of top 3-5 pain points

**4. Update Problem Statement**
- **Refine based on research:** Did initial hypothesis hold? Adjust if needed.
- **Output:** Validated problem statement

### Outputs

- **Affinity map:** Themes with frequency counts
- **Top 3-5 pain points:** Prioritized by frequency × intensity × strategic fit
- **Customer quotes:** 3-5 verbatim quotes per pain point
- **Validated problem statement:** Refined based on evidence

---

## Stage 5: Generate & Validate Solutions (Week 3)

**Goal:** Explore solution options, design experiments, validate assumptions.

### Activities

**1. Generate Opportunity Solution Tree**
- **Use:** `opportunity-solution-tree` skill
- **Input:** Top 3 pain points from Stage 4
- **Participants:** PM, design, engineering lead
- **Duration:** 90 minutes
- **Output:** 3 opportunities, 3 solutions per opportunity, POC recommendation

**Alternative: Use Lean UX Canvas**
- **Use:** `lean-ux-canvas` skill
- **When:** Prefer hypothesis-driven approach over OST
- **Output:** Hypotheses to test, minimal experiments

**2. Design Experiments**
- **For each solution:** Define "What's the least work to learn the next most important thing?"
- **Experiment types:**
  - **Concierge test:** Manually deliver solution to 10 customers, observe
  - **Prototype test:** Clickable mockup, usability test with 10 users
  - **Landing page test:** Fake door test (show feature, measure interest)
  - **A/B test:** Build minimal version, test with 50% of users
  - **PoL probe:** Use `pol-probe` skill for lightweight validation
- **Success criteria:** What metric/behavior validates hypothesis?

**3. Run Experiments**
- **Timeline:** 1-2 weeks per experiment
- **Participants:** PM + design (for prototypes), eng (for A/B tests)
- **Output:** Quantitative and qualitative validation data

### Outputs

- **Solution options:** 3-9 solutions (3 per opportunity)
- **Experiment results:** Did hypothesis validate or invalidate?
- **Customer feedback:** Qualitative reactions to prototypes/concepts

### Decision Point 3

**If YES** (validated): → Proceed to Stage 6 (Decide & Document)

**If NO** (invalidated):
- Pivot to next solution option
- Re-run experiments with adjusted approach
- **Time impact:** +1-2 weeks

---

## Stage 6: Decide & Document (End of Week 3-4)

**Goal:** Commit to build, document decision, communicate to stakeholders.

### Activities

**1. Make Go/No-Go Decision**
- **Criteria:**
  - Problem validated? (Stage 3-4)
  - Solution validated? (Stage 5)
  - Strategic fit? (aligns with business goals)
  - Feasible? (engineering capacity, technical complexity)
- **Decision:**
  - **GO:** Move to roadmap, write epics/stories
  - **PIVOT:** Explore alternative solution
  - **KILL:** De-prioritize, not worth solving now

**2. Define Epic Hypotheses (If GO)**
- **Participants:** PM
- **Duration:** 60 minutes per epic
- **Output:** Epic hypothesis statement with success criteria

**3. Write PRD (If GO)**
- **Participants:** PM
- **Duration:** 1-2 days
- **Output:** Structured PRD with problem, solution, success metrics

**4. Communicate Findings**
- **Format:** 30-min readout covering:
  - Problem validation (Stage 3-4 insights)
  - Solution validation (Stage 5 experiments)
  - Recommendation (GO/PIVOT/KILL)
- **Participants:** Execs, product leadership, key stakeholders
- **Output:** Alignment on next steps

### Outputs

- **Decision:** GO, PIVOT, or KILL
- **Epic hypotheses:** (if GO) Testable epic statements
- **PRD:** (if GO) Formal product requirements document
- **Stakeholder alignment:** Exec buy-in on recommendation

---

## Complete Workflow Timeline

```
Week 1:
├─ Day 1-2: Frame the Problem
│  ├─ lean-ux-canvas (120 min)
│  ├─ Problem statement (30 min)
│  └─ [Optional] Proto-personas, jobs-to-be-done
│
├─ Day 3: Research Planning
│  ├─ Interview prep (90 min)
│  ├─ Recruit participants (2-3 days)
│  └─ Schedule 5-10 interviews
│
└─ Day 4-5: Conduct Research (Start)
   └─ First 2-3 customer interviews

Week 2:
├─ Day 1-3: Conduct Research (Continue)
│  └─ Remaining customer interviews (3-7 more)
│
├─ Day 4-5: Synthesize Insights
│  ├─ Affinity mapping (120 min)
│  ├─ [Optional] Customer journey map (90 min)
│  ├─ Prioritize pain points
│  └─ Update problem statement
│
└─ Decision: Reached saturation? (if NO, +1 week more interviews)

Week 3:
├─ Day 1-2: Generate & Validate Solutions
│  ├─ opportunity-solution-tree (90 min)
│  └─ Design experiments
│
├─ Day 3-5: Run Experiments
│  ├─ Concierge tests, prototypes, or A/B tests
│  └─ Gather validation data
│
└─ Decision: Validated? (if NO, pivot to next solution, +1-2 weeks)

Week 4:
└─ Decide & Document
   ├─ Make GO/NO-GO decision
   ├─ [If GO] Epic hypotheses (60 min per epic)
   ├─ [If GO] PRD (1-2 days)
   └─ Communicate findings (30 min readout)
```

**Total Time Investment:**
- **Fast track:** 3 weeks (5 interviews, 1 experiment)
- **Typical:** 4 weeks (7-10 interviews, 1-2 experiments)
- **Thorough:** 6-8 weeks (10+ interviews, multiple experiment rounds)

---

## Integration with EM-Team

### With Skills

**Stage 1:**
- `lean-ux-canvas` - Problem framing and assumptions
- `jobs-to-be-done` - Customer motivations

**Stage 4:**
- `customer-journey-map` - Journey visualization (optional)

**Stage 5:**
- `opportunity-solution-tree` - Solution generation
- `pol-probe` - Lightweight validation experiments

### With Agents

**Product-Manager:**
- Orchestrates entire discovery process
- Conducts customer interviews
- Synthesizes insights and makes decisions

**Market-Intelligence:**
- Validates market assumptions
- Provides competitive context
- Informs opportunity identification

**Planner:**
- Receives validated PRD
- Creates implementation plan
- Transitions discovery to delivery

### With Workflows

**new-feature:**
- Discovery can run before new-feature workflow
- Validated problem becomes new-feature input
- PRD becomes spec for new-feature

**market-driven-feature:**
- Discovery validates market opportunities
- Customer insights inform business case
- Solution validation guides go-to-market

---

## Quality Gates

### Stage 1: Frame the Problem
- [ ] Problem hypothesis clearly stated
- [ ] Research questions defined
- [ ] Success criteria established
- [ ] Target personas identified

### Stage 2: Research Planning
- [ ] Interview guide created (5-7 questions)
- [ ] 5-10 participants recruited
- [ ] Interviews scheduled
- [ ] Synthesis plan defined

### Stage 3: Conduct Research
- [ ] 5-10 customer interviews completed
- [ ] Structured notes taken
- [ ] Support tickets reviewed
- [ ] Analytics analyzed
- [ ] Saturation reached (same patterns across 3+ interviews)

### Stage 4: Synthesize Insights
- [ ] Affinity mapping completed
- [ ] Pain points prioritized (top 3-5)
- [ ] Customer quotes collected
- [ ] Problem statement validated/refined

### Stage 5: Generate & Validate Solutions
- [ ] 3 opportunities identified
- [ ] 3 solutions per opportunity generated
- [ ] Experiments designed
- [ ] Experiments run
- [ ] Results analyzed

### Stage 6: Decide & Document
- [ ] Go/No-Go decision made
- [ ] Epic hypotheses defined (if GO)
- [ ] PRD written (if GO)
- [ ] Stakeholders communicated with
- [ ] Next steps clear

---

## Success Criteria

A successful discovery process:

- [ ] Problem validated with real customer data
- [ ] Solution validated through experiments
- [ ] Stakeholders aligned on decision
- [ ] Clear next steps defined
- [ ] Learning documented for team
- [ ] No building without validation

---

## Common Pitfalls

### Skipping Customer Interviews
**Symptom:** Rely only on analytics and support tickets

**Fix:** Always interview 5-10 customers per discovery cycle

### Asking Leading Questions
**Symptom:** "Would you use [feature X] if we built it?"

**Fix:** Focus on past behavior: "Tell me about the last time you [experienced problem]"

### Not Reaching Saturation
**Symptom:** Interview 2-3 customers, declare discovery complete

**Fix:** Continue until same patterns emerge across 3+ interviews (typically 5-7 minimum)

### Analysis Paralysis
**Symptom:** Spend 6 weeks synthesizing, never move to solutions

**Fix:** Time-box discovery to 3-4 weeks

### Discovery as One-Time Activity
**Symptom:** Run discovery once before building, then stop

**Fix:** Continuous discovery (1 customer interview per week, ongoing)

---

## Best Practices

### Research Design
- **Interview 5-10 customers** per discovery cycle
- **Focus on past behavior**, not hypotheticals
- **Record and review** interviews for quotes
- **Reach saturation** before concluding

### Synthesis
- **Use affinity mapping** to identify themes
- **Prioritize by frequency × intensity**
- **Collect verbatim quotes** for storytelling
- **Update problem statement** based on evidence

### Experimentation
- **Test smallest possible thing** first
- **Use PoL probes** for lightweight validation
- **Define success criteria upfront**
- **Be willing to kill** bad ideas fast

### Decision-Making
- **Make Go/PIVOT/KILL decision** explicitly
- **Document learnings** regardless of outcome
- **Communicate to stakeholders** promptly
- **Move to execution** or pivot quickly

---

## Related Resources

- **Frameworks:** Teresa Torres (*Continuous Discovery Habits*), Marty Cagan (*Inspired*)
- **Skills:** `lean-ux-canvas`, `jobs-to-be-done`, `opportunity-solution-tree`, `pol-probe`
- **Agents:** `product-manager`, `market-intelligence`, `planner`
- **Workflows:** `new-feature`, `market-driven-feature`

---

**Version:** 2.0.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready

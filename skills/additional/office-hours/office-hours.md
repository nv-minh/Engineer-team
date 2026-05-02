---
name: office-hours
description: "YC Office Hours style validation - six forcing questions to expose demand reality, status quo, narrowest wedge, observation, and future-fit. Use for product idea validation before building. Keywords: yc-office-hours, product-validation, demand-testing, idea-validation"
category: additional
compatibility: Claude Code, Claude Desktop, Cursor
metadata:
  author: EM-Team
  version: "1.0.0"
  source: gstack + EM-Team synthesis
---

## Overview

YC Office Hours style validation through six forcing questions that expose demand reality, status quo bias, narrowest wedge, observation gaps, and future-fit. Use this to validate product ideas before investing in development.

**Unique Value:** Forces brutal honesty about product ideas through six proven questions that expose wishful thinking, validate genuine demand, and identify the smallest viable product that matters.

## When to Use

✅ **Product Validation:**
- "I have an idea for a product"
- "Is this worth building?"
- "Help me think through this concept"
- "Should I build X or Y?"

✅ **Early Discovery:**
- Before writing specs or code
- When exploring multiple product concepts
- Validating demand before committing resources
- Brainstorming and ideation

❌ **NOT for:**
- Well-defined problems with clear solutions (move to planning)
- Technical implementation questions (use technical agents)
- Features for existing validated products

## The Six Forcing Questions

### 1. Demand Reality
**Question:** "Who is this for and do they have this problem NOW?"

**What to uncover:**
- Specific customer segment (not "everyone")
- Pain intensity (mild annoyance or desperate need?)
- Current workarounds (how do they solve this today?)
- Willingness to pay (time, money, attention)

**Red flags:**
- "They'll want this once they see it" — no evidence of existing demand
- "Everyone needs this" — too broad, no specific segment
- No clear pain point — solution in search of problem

**Good signs:**
- Specific persona with documented pain
- Current workarounds are clumsy/expensive
- People already paying to solve this problem

### 2. Status Quo Bias
**Question:** "Why isn't this solved already? What's changed?"

**What to uncover:**
- What's different NOW vs. 5 years ago?
- Why did previous attempts fail?
- What technology/cultural/market shift enables this?
- What's the unfair advantage?

**Red flags:**
- "No one's thought of this" — unlikely for real problems
- "We'll execute better" — execution advantage is fragile
- No clear change in landscape

**Good signs:**
- New technology (AI, mobile, blockchain, etc.)
- Platform shift (API access, regulatory change)
- New customer behavior (remote work, creator economy)

### 3. Desperate Specificity
**Question:** "What SPECIFICally does this do, for whom, and in what context?"

**What to uncover:**
- Narrowest wedge: smallest use case that still matters
- User's exact situation (role, company size, pain moment)
- Specific outcome (not "be more productive")
- Boundary conditions (what this DOESN'T do)

**Red flags:**
- "Improve productivity" — too vague
- "Help businesses" — no specific context
- Swiss army knife — does everything for everyone

**Good signs:**
- "Helps SaaS founders do sales calls 2x faster"
- "Enables 3-person dev teams to deploy daily"
- Clear boundaries: "We don't do X, Y, Z"

### 4. Observation vs. Opinion
**Question:** "What have you OBSERVED vs. what you ASSUME?"

**What to uncover:**
- Customer interviews conducted? (how many?)
- Real-world usage observed? (where, when?)
- Data collected? (metrics, support tickets, reviews)
- Hypotheses validated? (experiments run)

**Red flags:**
- "I would want this" — projection, not validation
- "People say they would" — opinions, not behavior
- No customer contact
- Assumptions presented as facts

**Good signs:**
- "Talked to 20 customers, 18 said X"
- "Watched 10 users try to solve this, all failed at step Y"
- "Ran smoke test, 500 signups in 2 weeks"
- Clear distinction between observed and assumed

### 5. Future-Fit
**Question:** "Does this matter in 6 months? 2 years? What changes?"

**What to uncover:**
- Is the problem acute or becoming acute?
- Will the solution still relevant when built?
- Market trajectory (growing, shrinking, stable?)
- Competitive dynamics (moats, defensibility)

**Red flags:**
- Fad or trend that might pass
- Problem that might solve itself
- Competitive risk of copycats
- No clear path to profitability

**Good signs:**
- Fundamental human need (timeless)
- Market growing 20%+ YoY
- Network effects or data moats
- Clear monetization path

### 6. The Simplest Thing
**Question:** "What's the MINIMUM viable thing that validates the hypothesis?"

**What to uncover:**
- Smallest experiment to test demand
- Fastest way to learn (days, not months)
- Lowest cost validation (money, time, effort)
- Success criteria (what validates?)

**Red flags:**
- Full product required to validate
- 6-month build before learning
- Expensive infrastructure needed first
- No clear go/no-go decision point

**Good signs:**
- Landing page validates interest in 1 week
- Manual concierge service tests value
- Prototype tests user behavior
- Clear metrics that show PASS/FAIL

## Process

### Step 1: Gather Context

Ask the user to describe their idea:
- What problem does it solve?
- Who is it for?
- How do you know it's a real problem?

**Listen for:**
- Specifics vs. generalizations
- Observations vs. assumptions
- Pain intensity
- Current solutions/workarounds

### Step 2: Run Six Questions

Ask each forcing question systematically. For each:
1. **Ask the question** directly
2. **Listen to the answer**
3. **Push deeper** with follow-ups:
   - "Can you be more specific?"
   - "What evidence do you have?"
   - "What have you observed?"
   - "Why do you believe that?"

**For each question, rate the answer:**
- **GREEN:** Strong evidence, clear specifics
- **YELLOW:** Some evidence, but gaps remain
- **RED:** Assumptions only, no evidence

### Step 3: Synthesize and Score

Create a validation summary:

**Demand Reality:** [GREEN/YELLOW/RED]
- **Score:** 1-10 (1 = wishful thinking, 10 = proven demand)
- **Evidence:** [What you observed/assumed]

**Status Quo Bias:** [GREEN/YELLOW/RED]
- **Score:** 1-10 (1 = no clear change, 10 = obvious shift)
- **Evidence:** [What's different now]

**Desperate Specificity:** [GREEN/YELLOW/RED]
- **Score:** 1-10 (1 = vague, 10 = laser-focused)
- **Evidence:** [Specific use case]

**Observation vs. Opinion:** [GREEN/YELLOW/RED]
- **Score:** 1-10 (1 = all assumptions, 10 = all observations)
- **Evidence:** [Customer contact/data collected]

**Future-Fit:** [GREEN/YELLOW/RED]
- **Score:** 1-10 (1 = fading fad, 10 = timeless need)
- **Evidence:** [Market trajectory, moats]

**Simplest Thing:** [GREEN/YELLOW/RED]
- **Score:** 1-10 (1 = full product, 10 = 1-week experiment)
- **Evidence:** [Minimum viable test]

**Overall Score:** [Average of 6 scores]
- **8-10:** Strong validation → Proceed to planning
- **5-7:** Some gaps → Address weaknesses first
- **1-4:** Weak validation → Pivot or kill

### Step 4: Recommendations

Based on scores, provide **actionable next steps**:

**If 8-10:**
- "Strong validation. Proceed to spec/planning."
- "Consider using /brainstorming to explore implementation approaches."
- "Write problem statement and user stories."

**If 5-7:**
- "Medium validation. Gaps to address:"
- [List specific YELLOW/RED areas]
- "Recommend: [specific action to strengthen validation]"
- "Re-evaluate after [action]."

**If 1-4:**
- "Weak validation. Major concerns:"
- [List critical gaps]
- "Options:"
  1. **Pivot:** Reframe the problem/audience
  2. **Validate First:** Run smallest experiment to test weakest area
  3. **Kill:** This idea may not be worth pursuing
- "Your call—what resonates?"

## Integration with EM-Team

### With Agents

**Product-Manager:**
- Use office-hours before requirements gathering
- Validation informs problem statements
- Scores indicate readiness for spec development

**Market-Intelligence:**
- Office-hours identifies what market research to conduct
- Demand reality questions map to market sizing
- Status quo questions inform competitive analysis

**Planner:**
- Office-hours validation precedes planning
- Strong validation (8-10) enables confident planning
- Weak validation (1-4) saves planning time

### With Skills

**brainstorming:**
- Use office-hours BEFORE brainstorming solutions
- Six questions frame the problem space
- Prevents solution-first thinking

**jobs-to-be-done:**
- Office-hours validates JTBD assumptions
- Demand reality maps to customer jobs
- Observation validates pains/gains

**lean-ux-canvas:**
- Office-hours fills Canvas business problem
- Six questions provide evidence for boxes
- Validation quality determines if Canvas is worthwhile

**opportunity-solution-tree:**
- Office-hours validates opportunities before OST
- Observations inform opportunity mapping
- Weak validation = premature OST

### With Workflows

**new-feature:**
- Use office-hours in Stage 1 (Brainstorm)
- Validation quality determines if workflow continues
- Scores 8-10 proceed to spec, <8 require more validation

**market-driven-feature:**
- Office-hours provides structured validation input
- Six questions map to market discovery phases
- Validation strength = gate for full workflow

## Output Template

```markdown
---
report_id: "office-hours-{timestamp}"
skill: "office-hours"
idea: "[Brief description]"
date: "[Date]"
overall_score: "[X/10]"
status: "[strong|medium|weak]"
---

## Idea Summary
[2-3 sentence description]

## Six Questions Analysis

### 1. Demand Reality
**Score:** [X/10]
**Status:** [GREEN/YELLOW/RED]
**Who:** [Specific customer segment]
**Problem:** [Pain point]
**Intensity:** [Mild/Annoying/Desperate]
**Evidence:**
- Observations: [What you've observed]
- Assumptions: [What you're assuming]

### 2. Status Quo Bias
**Score:** [X/10]
**Status:** [GREEN/YELLOW/RED]
**What's Different:** [Market/technology/culture shift]
**Why Now:** [Timing explanation]
**Evidence:**
- Observations: [Why this is different now]
- Assumptions: [About timing]

### 3. Desperate Specificity
**Score:** [X/10]
**Status:** [GREEN/YELLOW/RED]
**Narrowest Wedge:** [Specific use case]
**Target:** [Specific user in specific context]
**Boundaries:** [What this doesn't do]
**Evidence:**
- Specific: [How narrowly defined]
- Vague: [Areas needing clarity]

### 4. Observation vs. Opinion
**Score:** [X/10]
**Status:** [GREEN/YELLOW/RED]
**Observations:**
- Customer interviews: [Number, key findings]
- Usage data: [Metrics, behaviors]
- Experiments: [What you've tested]
**Assumptions:**
- [List untested assumptions]
**Gap:** [What to validate next]

### 5. Future-Fit
**Score:** [X/10]
**Status:** [GREEN/YELLOW/RED]
**Time Horizon:** [Does this matter in 6 months? 2 years?]
**Market Trajectory:** [Growing/stable/shrinking]
**Moats:** [Defensibility, competitive advantages]
**Evidence:**
- Trends: [Market dynamics]
- Risks: [What could make this obsolete]

### 6. Simplest Thing
**Score:** [X/10]
**Status:** [GREEN/YELLOW/RED]
**Minimum Viable Test:** [Smallest experiment]
**Timeline:** [How fast to validate]
**Cost:** [Resources required]
**Success Criteria:** [What validates hypothesis]

## Overall Assessment

**Total Score:** [Average of 6 scores]
**Verdict:** [Strong/Medium/Weak validation]

**Strengths:**
- [What's validated]

**Gaps:**
- [What needs more validation]

## Recommendations

**Next Steps:**
1. [Specific action 1]
2. [Specific action 2]
3. [Specific action 3]

**Go/No-Go Decision:**
- **GO** if scores 8-10: Proceed to planning/spec
- **ADDRESS GAPS** if scores 5-7: Validate weak areas first
- **PIVOT/KILL** if scores 1-4: This idea needs fundamental rethinking

---
```

## Verification

Before completing office-hours, verify:

**Six Questions:**
- [ ] All 6 questions asked and answered
- [ ] Each question rated GREEN/YELLOW/RED
- [ ] Scores supported by evidence
- [ ] Assumptions distinguished from observations

**Quality:**
- [ ] Pushed past surface-level answers
- [ ] Challenged assumptions with specific questions
- [ ] Distinguished between observation and opinion
- [] Required specifics for desperate specificity

**Actionability:**
- [ ] Recommendations specific (not vague)
- [ ] Next steps clear (not generic)
- [ ] Go/no-go decision justified by scores
- [ ] Timeline defined for next actions

## Common Pitfalls

### Accepting Surface Answers
**Symptom:** User gives vague answer, you move on

**Fix:** Dig deeper with follow-ups:
- "Can you give me a specific example?"
- "What did you observe that makes you say that?"
- "Talk me through a specific customer conversation"

### Confusion Validation with Validation
**Symptom:** "I showed it to 5 people and they liked it"

**Fix:** That's opinion, not validation. Ask:
- "Did they pay you? Use it? Recommend it to friends?"
- "What specific behavior did you observe?"
- "What would make them stop using it?"

### Solution-First Thinking
**Symptom:** User describes feature, not problem

**Fix:** Ask:
- "What problem does this solve?"
- "Why is that a problem worth solving?"
- "What happens if this doesn't exist?"

### Skipping the "Why Now?"
**Symptom:** No explanation of why this is possible now vs. 5 years ago

**Fix:** Ask status quo bias question explicitly:
- "What's changed in the world that makes this possible now?"
- "Why didn't this exist before?"

### Over-Optimism
**Symptom:** All answers are positive, no weaknesses identified

**Fix:** Challenge assumptions:
- "What could go wrong?"
- "What if you're wrong about X?"
- "What's the biggest risk?"

## Examples

### Example 1: Strong Validation (Score: 9/10)

**Idea:** AI-powered code reviewer for SaaS startups

**1. Demand Reality:** 9/10 GREEN
- Who: Technical founders at 10-50 person B2B SaaS companies
- Problem: Code reviews slow down shipping, founders block on PRs
- Intensity: Desperate — founders rate shipping speed as #1 concern
- Evidence: Talked to 15 founders, 12 said code review is bottleneck

**2. Status Quo Bias:** 8/10 GREEN
- What's Different: AI models now capable of semantic code understanding (impossible 3 years ago)
- Why Now: GitHub Copilot proved market, but startups need more customization
- Evidence: Market growing 40% YoY, AI model quality crossed threshold

**3. Desperate Specificity:** 9/10 GREEN
- Narrowest Wedge: Ruby on Rails monoliths, 10-50 person startups
- Target: Founders who still code and review team PRs
- Boundaries: Not for big enterprises, not for polyglot systems

**4. Observation vs. Opinion:** 8/10 YELLOW
- Observations: Watched 5 founders review code, avg 45 min per PR
- Assumptions: They'll pay for speed, but haven't tested price point
- Gap: Need to test willingness to pay $50-100/month

**5. Future-Fit:** 9/10 GREEN
- Time Horizon: Shipping speed will always matter
- Market Trajectory: PLG market growing 30% YoY
- Moats: Integration with existing workflows, data on codebase patterns

**6. Simplest Thing:** 9/10 GREEN
- Minimum Viable Test: Manual code review for 5 startups, measure time saved
- Timeline: 2 weeks
- Cost: $0 (founder's time)
- Success Criteria: 4/5 startups say they'd pay $50/month

**Recommendation:** Strong validation (9/10). Proceed to spec. Validate pricing assumption during simple test.

### Example 2: Weak Validation (Score: 3/10)

**Idea": Social network for dog owners

**1. Demand Reality:** 3/10 RED
- Who: Dog owners (too broad)
- Problem: Dog owners want to connect (weak pain)
- Intensity: Mild annoyance, not desperate
- Evidence: Assumption, no customer interviews

**2. Status Quo Bias:** 4/10 RED
- What's Different: Nothing new, dog owners always existed
- Why Now: No clear answer
- Evidence: No market shift identified

**3. Desperate Specificity:** 2/10 RED
- Narrowest Wedge: "Dog owners" (too broad)
- Target: Everyone with a dog
- Boundaries: None, does everything

**4. Observation vs. Opinion:** 2/10 RED
- Observations: None
- Assumptions: "People love their dogs and want to connect"
- Gap: No customer contact, no validation

**5. Future-Fit:** 4/10 YELLOW
- Time Horizon: Dogs will exist forever (stable)
- Market Trajectory: Pet market growing slowly
- Moats: None obvious, highly competitive

**6. Simplest Thing:** 2/10 RED
- Minimum Viable Test: Full social network (6 months)
- Timeline: Long build before learning
- Cost: High
- Success Criteria: Unclear

**Recommendation:** Weak validation (3/10). Major concerns: no proven demand, too broad, no clear wedge. Options: 1) Pivot to specific segment (e.g., "Instagram for dog show competitors"), 2) Kill this idea, 3) Validate demand first (talk to 50 dog owners).

## Best Practices

### Questioning Technique
- Ask follow-ups: "Why do you believe that?" "What did you observe?"
- Challenge gently: "That's interesting, but how do you know?"
- Push for specifics: "Can you give me a concrete example?"
- Distinguish observation from opinion: "Is that something you measured or assumed?"

### Scoring
- Be honest, not encouraging
- Evidence-based, not optimism-based
- Require specific examples for GREEN scores
- Flag assumptions clearly as YELLOW/RED

### Recommendations
- Always provide next steps (never leave user hanging)
- Make recommendations actionable (specific, not vague)
- Set clear criteria for re-evaluation
- Validate weaknesses before proceeding

## Related Resources

- **Frameworks:** YC Office Hours, Mom Test, Lean Startup
- **Skills:** `jobs-to-be-done`, `lean-ux-canvas`, `brainstorming`
- **Agents:** `product-manager`, `market-intelligence`
- **Workflows:** `new-feature`, `market-driven-feature`

---

**Version:** 1.0.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready

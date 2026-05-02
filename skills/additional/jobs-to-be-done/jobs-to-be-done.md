---
name: jobs-to-be-done
description: "Uncover customer jobs, pains, and gains in structured JTBD format. Use for validating product ideas, understanding customer motivations, and ensuring solutions address real needs. Keywords: jtbd, jobs-to-be-done, customer-needs, value-proposition"
version: "1.0.0"
category: additional
compatibility: Claude Code, Claude Desktop, Cursor
metadata:
  author: EM-Team
  version: "1.0.0"
  source: Product-Manager-Skills + EM-Team synthesis
---

## Overview

Systematically explore what customers are trying to accomplish (functional, social, emotional jobs), the pains they experience, and the gains they seek. Use this framework to uncover unmet needs, validate product ideas, and ensure your solution addresses real motivations—not just surface-level feature requests.

**Unique Value:** Separates jobs from solutions, reveals underlying motivations, and surfaces non-obvious competition by understanding what customers "hire" your product to do.

## When to Use

✅ **Discovery & Research:**
- Understanding customer motivations before building
- Uncovering unmet needs and pain points
- Validating product-market fit
- Conducting customer interview analysis

✅ **Product Development:**
- Prioritizing roadmap by job importance
- Identifying competitive differentiation
- Framing product positioning and messaging
- Creating user personas and profiles

✅ **Strategic Planning:**
- Analyzing market opportunities
- Evaluating competitive landscape
- Identifying innovation opportunities
- Business model design

## Key Concepts

### The Three Job Types

**1. Functional Jobs**
Tasks customers need to perform
- Example: "Send an invoice," "Track expenses," "Deploy code"

**2. Social Jobs**
How customers want to be perceived
- Example: "Look professional to clients," "Appear tech-savvy"

**3. Emotional Jobs**
Emotional states customers seek or avoid
- Example: "Feel confident," "Avoid anxiety," "Feel accomplished"

### The Three Gain Types

**1. Expectations**
What would exceed current solutions
- Example: "Automatically categorize expenses"

**2. Savings**
Time, money, or effort reductions
- Example: "Reduce report generation from 8 hours to 10 minutes"

**3. Adoption Factors**
What increases likelihood of switching
- Example: "Free trial with no credit card required"

### The Four Pain Types

**1. Challenges**
Obstacles preventing job completion
- Example: "Tools don't integrate, forcing manual data entry"

**2. Costliness**
What takes too much time, money, or effort
- Example: "Hiring a specialist costs $10k"

**3. Common Mistakes**
Errors that could be prevented
- Example: "Forgetting to CC stakeholders on critical emails"

**4. Unresolved Problems**
Gaps in current solutions
- Example: "Current CRM doesn't track customer health scores"

## Process

### Step 1: Define Context

Before exploring JTBD, clarify:
- **Target customer segment:** Who are you studying?
- **Situation:** In what context does the job arise?
- **Current solutions:** What do they use today?

**If missing context:** Conduct customer interviews or "switch interviews" (why they switched from a previous solution).

### Step 2: Explore Customer Jobs

#### Functional Jobs
Ask: "What tasks are you trying to complete?"

```markdown
### Functional Jobs:
- Reconcile monthly expenses for tax filing
- Onboard a new team member in under 2 hours
- Deploy code to production without downtime
```

**Quality checks:**
- **Verb-driven:** Jobs are actions ("send," "analyze," "coordinate")
- **Solution-agnostic:** Don't say "use email"—say "communicate with teammates"
- **Specific:** "Track business expenses for tax deductions" not "manage finances"

#### Social Jobs
Ask: "How do you want to be perceived by others?"

```markdown
### Social Jobs:
- Be seen as a strategic thinker by exec team
- Appear responsive and reliable to clients
- Look tech-savvy to younger colleagues
```

**Quality checks:**
- **Audience-specific:** Who is the customer trying to impress?
- **Emotional weight:** Social jobs often drive adoption more than functional

#### Emotional Jobs
Ask: "What emotional state do you want to achieve or avoid?"

```markdown
### Emotional Jobs:
- Feel confident I'm not missing important details
- Avoid anxiety of manual data entry errors
- Feel a sense of accomplishment at day's end
```

**Quality checks:**
- **Positive and negative:** Include both what they seek and what they avoid
- **Rooted in research:** Don't fabricate emotions—use customer quotes

### Step 3: Identify Pains

#### Challenges
Ask: "What obstacles prevent you from completing this job?"

```markdown
### Challenges:
- Tools don't integrate, forcing manual data entry
- No visibility into teammate work
- Approval processes take 3+ days, blocking progress
```

#### Costliness
Ask: "What takes too much time, money, or effort?"

```markdown
### Costliness:
- Generating monthly reports takes 8 hours of manual work
- Hiring a specialist costs $10k, which we can't afford
- Learning current tools requires 20+ hours of training
```

#### Common Mistakes
Ask: "What errors do you make frequently?"

```markdown
### Common Mistakes:
- Forgetting to CC stakeholders on critical emails
- Miscalculating tax deductions due to missing receipts
- Accidentally overwriting shared files
```

#### Unresolved Problems
Ask: "What problems do current solutions fail to address?"

```markdown
### Unresolved Problems:
- Current CRM doesn't track customer health scores
- Email doesn't preserve context when people added mid-thread
- Existing tools require technical expertise we don't have
```

### Step 4: Uncover Gains

#### Expectations
Ask: "What would make you love a solution?"

```markdown
### Expectations:
- Automatically categorize expenses without manual tagging
- Suggest next steps based on project status
- Integrate seamlessly with existing tools
```

#### Savings
Ask: "What savings would delight you?"

```markdown
### Savings:
- Reduce report generation from 8 hours to 10 minutes
- Eliminate need for full-time admin
- Cut onboarding time from 2 weeks to 2 days
```

#### Adoption Factors
Ask: "What would make you switch from current solution?"

```markdown
### Adoption Factors:
- Free trial with no credit card required
- Migration support to import existing data
- Testimonials from companies like ours
```

#### Life Improvement
Ask: "How would your life be better?"

```markdown
### Life Improvement:
- Leave work on time instead of staying late
- Feel less stressed about missing deadlines
- Focus on strategic work instead of busywork
```

### Step 5: Prioritize and Validate

- **Rank pains by intensity:** Which are acute vs. mild?
- **Identify must-have vs. nice-to-have gains:** What drives adoption?
- **Cross-reference with personas:** Do different segments have different jobs?
- **Validate with data:** Survey broader audience to confirm JTBD insights

## Integration with EM-Team

### With Agents

**Product-Manager:**
- JTBD informs requirements and user stories
- Helps prioritize features by job importance
- Guides customer development and validation

**Market-Intelligence:**
- JTBD provides customer context for market analysis
- Jobs inform competitive differentiation
- Pains/gains inform value proposition

**Frontend-Expert:**
- Jobs inform UI/UX design decisions
- Emotional jobs guide interaction patterns
- Pains identify friction points to eliminate

### With Skills

**brainstorming:**
- JTBD provides structured input for ideation
- Jobs and pains generate solution ideas
- Gains inform success criteria

**spec-driven-development:**
- JTBD informs problem statement
- Jobs define user needs
- Pains identify what to solve

**customer-journey-map:**
- JTBD provides content for journey stages
- Jobs inform user actions
- Pains identify pain points in journey

### With Workflows

**new-feature:**
- Use JTBD in Stage 1 (Brainstorm) for customer context
- Jobs and pains inform design decisions
- Gains define success criteria

**market-driven-feature:**
- JTBD validates customer needs
- Jobs inform opportunity identification
- Pains and gains inform competitive analysis

## Output Template

```markdown
---
report_id: "jtbd-{timestamp}"
skill: "jobs-to-be-done"
customer_segment: "[Segment name]"
status: "{completed|in_progress}"
confidence_score: "{1-10}"
---

## Customer Segment
[Who was studied]

## Context
[When/where the job arises]

## Customer Jobs

### Functional Jobs
1. [Job 1]
2. [Job 2]
3. [Job 3]

### Social Jobs
1. [Job 1]
2. [Job 2]
3. [Job 3]

### Emotional Jobs
1. [Job 1]
2. [Job 2]
3. [Job 3]

## Pains

### Challenges
1. [Challenge 1]
2. [Challenge 2]
3. [Challenge 3]

### Costliness
1. [Cost 1]
2. [Cost 2]
3. [Cost 3]

### Common Mistakes
1. [Mistake 1]
2. [Mistake 2]

### Unresolved Problems
1. [Problem 1]
2. [Problem 2]
3. [Problem 3]

## Gains

### Expectations
1. [Expectation 1]
2. [Expectation 2]
3. [Expectation 3]

### Savings
1. [Saving 1]
2. [Saving 2]
3. [Saving 3]

### Adoption Factors
1. [Factor 1]
2. [Factor 2]
3. [Factor 3]

### Life Improvement
1. [Improvement 1]
2. [Improvement 2]
3. [Improvement 3]

## Insights
[Key patterns, surprises, strategic opportunities]

## Recommendations
[What to build, prioritize, or explore next]

## Data Sources
[Customer interviews, surveys, analytics, etc.]
```

## Verification

Before completing JTBD analysis, verify:

**Jobs:**
- [ ] Jobs are solution-agnostic (not anchored on specific tools)
- [ ] Jobs are specific and actionable
- [ ] All three job types covered (functional, social, emotional)
- [ ] Jobs based on real customer data (not assumptions)

**Pains:**
- [ ] All four pain types explored
- [ ] Pains prioritized by intensity
- [ ] Pains rooted in customer feedback
- [ ] Unresolved problems identified

**Gains:**
- [ ] All three gain types covered
- [ ] Gains specific and measurable
- [ ] Adoption factors clear
- [ ] Life improvements articulated

**General:**
- [ ] Customer segment clearly defined
- [ ] Context well understood
- [ ] Insights prioritized by importance
- [ ] Recommendations actionable

## Common Pitfalls

### Confusing Jobs with Solutions
**Symptom:** "I need Slack" or "I need AI"

**Fix:** Ask "Why?" 5 times to get to the underlying job

### Generic Jobs
**Symptom:** "Be more productive" or "Save time"

**Fix:** Get specific: "Reduce time spent generating monthly reports from 8 hours to 1 hour"

### Ignoring Social/Emotional Jobs
**Symptom:** Only documenting functional jobs

**Fix:** Explicitly ask about perception and emotions in interviews

### Fabricating JTBD Without Research
**Symptom:** Filling out template based on assumptions

**Fix:** Conduct customer interviews to gather real insights

### Treating All Pains as Equal
**Symptom:** Listing 20 pains without prioritization

**Fix:** Rank pains by intensity (acute vs. mild)

## Examples

### Example 1: Project Management Tool

**Functional Jobs:**
- Coordinate tasks across distributed team
- Track project progress and deadlines
- Generate status reports for stakeholders

**Social Jobs:**
- Be seen as organized by management
- Appear responsive to team requests
- Look tech-savvy to colleagues

**Emotional Jobs:**
- Feel confident nothing is falling through cracks
- Avoid anxiety of missing deadlines
- Feel in control of workload

**Pains - Challenges:**
- Team members use different tools, creating silos
- No visibility into what teammates are working on
- Difficult to get status updates without meetings

**Gains - Savings:**
- Reduce status reporting time from 3 hours to 15 minutes
- Eliminate 5+ hours per week in status meetings
- Cut time spent tracking down updates by 50%

### Example 2: Expense Tracking App

**Functional Jobs:**
- Capture receipts on the go
- Categorize business expenses automatically
- Generate expense reports for reimbursement

**Social Jobs:**
- Appear organized to finance team
- Look professional when submitting receipts
- Avoid being "the person" with messy expense reports

**Emotional Jobs:**
- Feel confident I won't forget expenses
- Avoid stress of tax season
- Feel in control of business finances

**Pains - Costliness:**
- Takes 2-3 hours per month to manually categorize
- Missed deductions cost hundreds in taxes
- Lost receipts mean out-of-pocket costs

**Gains - Expectations:**
- Automatic categorization using AI
- Receipt scanning with OCR
- Integration with accounting software

## Best Practices

### Data Collection
- Conduct 5-10 customer interviews per segment
- Use "switch interviews" (why did you switch from X?)
- Observe customers in their natural environment
- Record and review interviews for quotes

### Analysis
- Look for patterns across multiple customers
- Prioritize by frequency and intensity
- Distinguish between voiced and latent needs
- Validate assumptions with quantitative data

### Documentation
- Use customer verbatim quotes
- Include context (situation, triggers)
- Tag by customer segment
- Link to data sources

## Related Resources

- **Frameworks:** Value Proposition Canvas, Outcome-Driven Innovation
- **Books:** *Competing Against Luck* (Clayton Christensen), *Running Lean* (Ash Maurya)
- **Skills:** `brainstorming`, `customer-journey-map`, `value-proposition-canvas`

---

**Version:** 1.0.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready

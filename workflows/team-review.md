---
name: team-review
description: Full team review orchestrated by Team Lead agent
version: "2.0.0"
category: "team"
origin: "agent-skills"
agents_used:
  - team-lead
  - product-manager
  - architect
  - database-expert
  - frontend-expert
  - senior-code-reviewer
  - security-reviewer
  - staff-engineer
skills_used:
  - code-review
  - security-audit
  - documentation
  - performance-optimization
estimated_time: "4-8 hours (standard) / 1-2 days (comprehensive)"
---

# Team Review Workflow

## Overview

The Team Review workflow orchestrates a comprehensive cross-functional review involving multiple specialized agents coordinated by the Team Lead (Orchestrator). This workflow ensures that all aspects of a feature or change are reviewed from business, technical, security, and quality perspectives.

## When to Use

- New feature development before implementation
- Major architectural changes
- Cross-functional impact analysis
- Pre-merge reviews for significant changes
- Post-incident reviews

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Description |
|---|---|---|
| Scope Analysis (Stage 1) | DEFINE | Analyze task scope, identify agents, define review scope |
| Business Validation (Stage 2) | DEFINE | Product Manager reviews specs, performs GAP analysis |
| Architecture Review (Stage 3) | PLAN | Architect reviews technical design and patterns |
| Specialized Reviews (Stage 4) | BUILD | Parallel database, frontend, and code reviews |
| Security Review (Stage 5) | VERIFY | OWASP assessment, STRIDE modeling, blocking authority |
| Deep Investigation (Stage 6) | VERIFY | Staff Engineer root cause and cross-service analysis |
| Consolidation (Stage 7) | REVIEW + SHIP | Team Lead consolidates findings, makes decision |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Scope clearly defined
- [ ] Risk level assessed
- [ ] Required agents identified
- [ ] Business value validated
PASS → proceed to PLAN | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Architecture principles validated
- [ ] Pattern appropriateness confirmed
- [ ] Scalability assessed
- [ ] Integration points reviewed
PASS → proceed to BUILD | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Specialized reviews completed (applicable ones)
- [ ] All 9 axes reviewed (if code review applicable)
- [ ] UI/UX reviewed (if frontend applicable)
- [ ] Schema design validated (if database applicable)
PASS → proceed to VERIFY | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] OWASP assessment complete
- [ ] STRIDE modeling done
- [ ] Blocking issues identified
- [ ] Security scorecard complete
PASS → proceed to REVIEW | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] All reports collected
- [ ] Findings consolidated
- [ ] Decision made (APPROVED/CONDITIONAL/REJECTED)
- [ ] Next steps defined and actionable
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

### Stage 1: Scope Analysis (Team Lead)

**Agent:** `duck:team-lead`

**Actions:**
- Analyze task scope and complexity
- Identify affected components
- Assess risk level
- Select appropriate agents for review

**Output:**
- Task analysis document
- Agent selection list
- Review scope definition

**Quality Gate:**
- [ ] Scope clearly defined
- [ ] Risk level assessed
- [ ] Required agents identified

---

### Stage 2: Business Validation (Product Manager)

**Agent:** `duck:product`

**Actions:**
- Review specifications from business perspective
- Perform GAP analysis
- Validate acceptance criteria
- Assess business impact and ROI

**Input:** Task description, business requirements

**Output:** Product Manager Review Report

**Quality Gate:**
- [ ] Business value validated
- [ ] Market fit assessed
- [ ] Acceptance criteria reviewed
- [ ] No business blockers

---

### Stage 3: Architecture Review (Architect)

**Agent:** `duck:architect`

**Actions:**
- Review technical architecture
- Assess architectural patterns
- Evaluate scalability
- Review ADRs (if applicable)

**Input:** Technical design, architecture diagrams

**Output:** Architecture Review Report

**Quality Gate:**
- [ ] Architecture principles validated
- [ ] Pattern appropriateness confirmed
- [ ] Scalability assessed
- [ ] Integration points reviewed

---

### Stage 4: Specialized Reviews (Parallel)

#### 4a: Database Review (if applicable)

**Agent:** `duck:database`

**Actions:**
- Review database schema
- Optimize queries
- Review migration strategy
- Assess data integrity

**Quality Gate:**
- [ ] Schema design validated
- [ ] Query performance assessed
- [ ] Migration strategy reviewed

#### 4b: Frontend Review (if applicable)

**Agent:** `duck:frontend`

**Actions:**
- Review UI/UX design
- Assess performance (Core Web Vitals)
- Review accessibility compliance
- Evaluate state management

**Quality Gate:**
- [ ] UI/UX reviewed
- [ ] Performance analyzed
- [ ] Accessibility audited
- [ ] Responsive design verified

#### 4c: Code Review (if applicable)

**Agent:** `duck:code-review`

**Actions:**
- Perform 9-axis code review
- Classify findings by severity
- Provide quantitative scores
- Generate actionable feedback

**Quality Gate:**
- [ ] All 9 axes reviewed
- [ ] Severity table complete
- [ ] Scores calculated
- [ ] Recommendations provided

---

### Stage 5: Security Review (Security Reviewer)

**Agent:** `duck:security`

**Actions:**
- Perform OWASP Top 10 assessment
- Conduct STRIDE threat modeling
- Review code for vulnerabilities
- Exercise blocking authority

**Input:** Code artifacts, architecture diagrams

**Output:** Security Review Report

**Quality Gate:**
- [ ] OWASP assessment complete
- [ ] STRIDE modeling done
- [ ] Blocking issues identified
- [ ] Security scorecard complete

**BLOCKING:** Critical/High security issues MUST be fixed before proceeding

---

### Stage 6: Deep Investigation (if needed)

**Agent:** `duck:staff`

**Actions:**
- Root cause analysis (if issues found)
- Cross-service impact analysis
- Performance deep dive
- Dependency analysis

**Trigger:** Complex issues, architectural concerns, performance problems

**Quality Gate:**
- [ ] Root cause identified
- [ ] Cross-service impact analyzed
- [ ] Dependencies mapped
- [ ] Recommendations provided

---

### Stage 7: Consolidation (Team Lead)

**Agent:** `duck:team-lead`

**Actions:**
- Collect all agent reports
- Consolidate findings
- Synthesize recommendations
- Make final decision
- Define next steps

**Input:** All agent reports

**Output:** Team Review Report (Consolidated)

**Quality Gate:**
- [ ] All reports collected
- [ ] Findings consolidated
- [ ] Decision made
- [ ] Next steps defined

**Completion Marker:** ## ✅ TEAM_LEAD_CONSOLIDATION_COMPLETE

---

## Revision Loop (max 3 iterations)

To prevent circular dependencies, the workflow includes iteration limits:

- If Product Manager identifies issues requiring Architect revision → Maximum 3 iterations
- If issues persist after 3 iterations → Escalate to Team Lead for final decision
- Team Lead makes binding decision based on all available information

**Revision Process:**
```yaml
iteration_limit: 3
escalation_trigger: "After 3 iterations without resolution"
escalation_target: "Team Lead (duck:team-lead)"
final_authority: "Team Lead decision is binding"
```

## Handoff Contracts

### Team Lead → Product Manager
```yaml
provides:
  - task_description
  - business_context
  - user_stories

expects:
  - business_validation
  - gap_analysis
  - acceptance_criteria_review
```

### Product Manager → Architect
```yaml
provides:
  - business_requirements
  - success_metrics
  - constraints

expects:
  - technical_feasibility
  - architecture_options
```

### Architect → Specialized Agents
```yaml
provides:
  - architecture_decisions
  - api_contracts
  - data_models

expects:
  - specialized_reviews
  - impact_assessments
```

### All Agents → Security Reviewer
```yaml
provides:
  - code_artifacts
  - architecture_diagrams
  - infrastructure_config

expects:
  - owasp_review
  - stride_analysis
  - blocking_issues
```

### All Agents → Team Lead
```yaml
provides:
  - individual_reports
  - findings
  - recommendations

expects:
  - consolidation
  - decision
  - next_steps
```

---

## Quality Gates

### Entry Gates
- [ ] Task description is clear
- [ ] Scope is defined
- [ ] Required context is available

### Stage Gates
- [ ] Business validation passed
- [ ] Architecture review passed
- [ ] Specialized reviews passed
- [ ] Security review passed (CRITICAL/HIGH issues block)

### Exit Gates
- [ ] All critical findings addressed
- [ ] All high findings addressed or accepted
- [ ] Decision documented
- [ ] Next steps actionable

---

## Success Criteria

- [ ] All applicable agents have completed their reviews
- [ ] All findings are documented with severity levels
- [ ] Security review has no blocking issues (or issues are accepted with risk acknowledgment)
- [ ] Consolidated report is comprehensive and actionable
- [ ] Decision (APPROVED/CONDITIONAL/REJECTED) is clearly justified
- [ ] Next steps are specific and time-bound

---

## Blocking Authority

### Security Reviewer (CRITICAL/HIGH)
- SQL injection vulnerabilities → BLOCK
- Authentication bypass → BLOCK
- Sensitive data exposure → BLOCK
- Remote code execution → BLOCK

### Product Manager (Business)
- No market fit → BLOCK
- Regulatory issues → BLOCK
- Gap too large → CONDITIONAL

### Staff Engineer (Architecture)
- Fundamental design flaw → BLOCK
- Scalability risk → CONDITIONAL

---

## Conflict Resolution

### Security vs Performance
- **Resolution:** Security takes priority
- **Rationale:** Security is non-negotiable, optimize elsewhere

### Speed vs Quality
- **Resolution:** Quality takes priority
- **Rationale:** Technical debt costs more long-term

### Simplicity vs Scalability
- **Resolution:** Context-dependent
  - MVP → Simplicity
  - Production → Scalability

---

## Output Template

```markdown
# Team Review Report: [Task Name]

**Date:** [Date]
**Orchestrator:** Team Lead
**Agents:** [List]

---

## Executive Summary

**Overall Status:** [APPROVED | CONDITIONAL | REJECTED]
**Risk Level:** [Low | Medium | High | Critical]
**Confidence:** [High | Medium | Low]

---

## Agents Involved

### Product Manager
**Status:** [✅/⚠️/❌]
**Summary:** [One line]
[Full report]

### Architect
**Status:** [✅/⚠️/❌]
**Summary:** [One line]
[Full report]

[... other agents ...]

---

## Consolidated Findings

### Critical Issues (Must Fix)
| Issue | Agent | Impact | Fix |
|-------|-------|--------|-----|
| [Issue] | [Agent] | [Impact] | [Fix] |

### High Issues (Should Fix)
| Issue | Agent | Impact | Fix |
|-------|-------|--------|-----|
| [Issue] | [Agent] | [Impact] | [Fix] |

### Medium Issues (Nice to Have)
| Issue | Agent | Impact | Fix |
|-------|-------|--------|-----|
| [Issue] | [Agent] | [Impact] | [Fix] |

---

## Decision

**Decision:** [APPROVED / CONDITIONAL / REJECTED]

**Rationale:**
[Reasoning]

**Conditions (if CONDITIONAL):**
- [Condition 1]
- [Condition 2]

**Blocking Issues (if REJECTED):**
- [Issue 1]
- [Issue 2]

---

## Next Steps

1. [Step 1]
2. [Step 2]
3. [Step 3]

---

**Report Generated:** [Timestamp]
**Orchestrated by:** Team Lead Agent
```

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Compatible with:** All EM-Team agents

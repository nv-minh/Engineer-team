---
name: code-review-9axis
description: Deep code review using 9-axis framework with Senior Code Reviewer and Security Reviewer
version: "2.0.0"
category: "team"
origin: "agent-skills"
agents_used:
  - senior-code-reviewer
  - security-reviewer
skills_used:
  - code-review
  - security-audit
  - performance-optimization
  - code-simplification
related_skills:
  - code-review
  - security-audit
  - code-simplification
estimated_time: "2-6 hours"
---

# Code Review (9-Axis) Workflow

## Overview

The Code Review (9-Axis) workflow provides comprehensive code quality assessment using the 9-axis review framework. It combines the Senior Code Reviewer's thorough analysis with the Security Reviewer's vulnerability assessment to ensure code is production-ready.

## When to Use

- Pull request reviews
- Pre-merge code quality checks
- Technical debt assessment
- Production readiness evaluation
- Legacy code modernization planning

## Lifecycle

DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE

### Phase Mapping

| Lifecycle Phase | Workflow Stage |
|-----------------|----------------|
| DEFINE | Gather code diff, PR context, and review scope |
| PLAN | 9-Axis Code Review framework setup (Stage 1) |
| BUILD | Deep analysis across all 9 axes |
| VERIFY | Security Vulnerability Assessment (Stage 2) |
| REVIEW | Consolidated Code Quality Report (Stage 3) |
| SHIP | Decision documented, findings communicated |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Code diff / PR identified
- [ ] Commit history reviewed
- [ ] Review scope defined
- [ ] Related tickets/docs gathered
PASS → proceed | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] All 9 axes reviewed
- [ ] Findings classified by severity
- [ ] Scores calculated for each axis
- [ ] Overall score determined
PASS → proceed | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Each axis analysis documented
- [ ] Issues catalogued with severity
- [ ] Actionable feedback provided
PASS → proceed | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] OWASP categories assessed
- [ ] Vulnerabilities identified
- [ ] Severity classification applied
- [ ] Blocking issues flagged
PASS → proceed | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] All findings merged and prioritized
- [ ] Recommendations actionable
- [ ] Decision justified (APPROVED/CONDITIONAL/REJECTED)
- [ ] Scorecard completed
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

### Stage 1: 9-Axis Code Review (Senior Code Reviewer)

**Agent:** senior-code-reviewer

**Actions:**
- Perform comprehensive 9-axis review:
  1. **Correctness** - Logic, edge cases, validation
  2. **Readability** - Naming, structure, documentation
  3. **Architecture** - Patterns, separation, modularity
  4. **Security** - Injection, auth, authorization, data protection
  5. **Performance** - Algorithms, caching, database, rendering
  6. **Testing** - Coverage, quality, organization
  7. **Maintainability** - Organization, complexity, duplication
  8. **Scalability** - Horizontal/vertical scaling, data, performance
  9. **Documentation** - Comments, API docs, README

**Input:**
- Code diff / PR
- Commit history
- Related tickets/docs

**Output:** Senior Code Review Report (9-Axis)

**Quality Gate:**
- [ ] All 9 axes reviewed
- [ ] Findings classified by severity
- [ ] Scores calculated for each axis
- [ ] Overall score determined

---

### Stage 2: Security Vulnerability Assessment (Security Reviewer)

**Agent:** security-reviewer

**Actions:**
- OWASP Top 10 assessment
- Identify security vulnerabilities in code
- Classify by severity (CRITICAL/HIGH/MEDIUM/LOW)
- Exercise blocking authority for CRITICAL/HIGH issues

**Input:**
- Code artifacts
- Senior code review findings
- Context about system

**Output:** Security Vulnerability Report

**Quality Gate:**
- [ ] OWASP categories assessed
- [ ] Vulnerabilities identified
- [ ] Severity classification applied
- [ ] Blocking issues flagged

**BLOCKING:** CRITICAL/HIGH security issues MUST be fixed

---

### Stage 3: Consolidated Code Quality Report

**Agents:** senior-code-reviewer + security-reviewer

**Actions:**
- Merge 9-axis and security findings
- Prioritize by combined severity
- Create actionable recommendations
- Make final decision (APPROVED/CONDITIONAL/REJECTED)

**Output:** Consolidated Code Quality Report

**Quality Gate:**
- [ ] All findings merged
- [ ] Prioritized by impact
- [ ] Recommendations actionable
- [ ] Decision justified

---

## Handoff Contracts

### To Senior Code Reviewer
```yaml
provides:
  - code_diff
  - pr_url
  - review_scope
  - context

expects:
  - 9_axis_review
  - severity_table
  - quantitative_scores
  - actionable_feedback
```

### Senior Code Reviewer → Security Reviewer
```yaml
provides:
  - code_review_findings
  - security_related_issues
  - severity_classification

expects:
  - deep_security_analysis
  - owasp_assessment
  - vulnerability_details
  - blocking_issues
```

### Security Reviewer → Consolidation
```yaml
provides:
  - security_findings
  - vulnerability_report
  - blocking_issues

expects:
  - consolidation
  - final_recommendations
  - decision
```

---

## 9-Axis Review Framework

### Axis 1: Correctness ✅
**Question:** Does the code do what it's supposed to do?

**Checks:**
- Logic correctness
- Edge cases (null, undefined, empty, boundaries)
- Data validation (input, output, types, constraints)
- Concurrency (race conditions, deadlocks, leaks)

### Axis 2: Readability 📖
**Question:** Is the code easy to understand?

**Checks:**
- Naming (meaningful, descriptive, clear)
- Structure (short functions, minimal nesting, early returns)
- Documentation (complex logic, public APIs, examples)
- Self-documenting (reads like prose, clear intent)

### Axis 3: Architecture 🏗️
**Question:** Does it fit the system architecture?

**Checks:**
- Design patterns (appropriate, correctly applied)
- Separation of concerns (single responsibility, layers)
- Modularity (cohesive, low coupling, clear interfaces)
- Scalability (can handle growth, no hard limits)

### Axis 4: Security 🔒
**Question:** Are there security vulnerabilities?

**Checks:**
- Injection (SQL, XSS, command, path traversal)
- Authentication (passwords, sessions, MFA, rate limiting)
- Authorization (permissions, roles, least privilege)
- Data protection (secrets, encryption, secure comms)

### Axis 5: Performance ⚡
**Question:** Are there performance issues?

**Checks:**
- Algorithms (appropriate complexity, efficient data structures)
- Caching (when appropriate, invalidation strategy)
- Database (indexed queries, optimization, pooling)
- Rendering (avoid re-renders, virtualize lists, lazy loading)

### Axis 6: Testing 🧪
**Question:** Is the code adequately tested?

**Checks:**
- Coverage (unit, integration, e2e)
- Quality (meaningful tests, edge cases, errors)
- Organization (clear structure, descriptive names)
- TDD compliance (tests first, red-green-refactor)

### Axis 7: Maintainability 🔧
**Question:** Is the code easy to maintain?

**Checks:**
- Organization (logical structure, co-located code)
- Complexity (cyclomatic, cognitive, no god functions)
- Duplication (DRY principle, extracted patterns)
- Technical debt (minimal workarounds, proper abstractions)

### Axis 8: Scalability 📈
**Question:** Can the code handle growth?

**Checks:**
- Horizontal scaling (stateless, no shared state)
- Vertical scaling (resource efficient, async operations)
- Data scaling (partitioning, no single points of failure)
- Performance scaling (O(log n) algorithms, batch operations)

### Axis 9: Documentation 📚
**Question:** Is the code well documented?

**Checks:**
- Code comments (complex logic, why not what)
- API documentation (public APIs, parameters, returns)
- README (overview, setup, usage, contribution)
- Inline docs (self-documenting types, JSDoc)

---

## Severity Classification

### Critical (BLOCKS Deployment)
- Security vulnerability
- Data loss risk
- Production outage risk
- Legal compliance issue

### High (BLOCKS Merge)
- Bug affecting users
- Performance regression
- Accessibility violation
- Test coverage below threshold

### Medium (Fix Before Next Release)
- Code smell
- Minor performance issue
- Missing documentation
- Technical debt

### Low (Nice to Have)
- Style inconsistency
- Naming suggestion
- Optimization opportunity
- Minor improvement

---

## Output Template

```markdown
# Code Review Report (9-Axis + Security)

**Review Date:** [Date]
**Reviewers:** Senior Code Reviewer + Security Reviewer
**PR/Commit:** [Identifier]
**Files Changed:** [Count]

---

## Executive Summary

**Overall Score:** [X.X]/10
**Grade:** [A+/A/B/C/D/F]
**Total Issues:** [Count]
- Critical: [Count]
- High: [Count]
- Medium: [Count]
- Low: [Count]

**Security Status:** [✅ SECURE | ⚠️ NEEDS WORK | 🔴 VULNERABLE]
**Recommendation:** [APPROVED / CONDITIONAL / REJECTED]

---

## 9-Axis Review

### Axis 1: Correctness ✅
**Score:** [X]/10
**Status:** [✅/⚠️/❌]

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [file:line] | [Fix] |

---

### Axis 2: Readability 📖
**Score:** [X]/10
**Status:** [✅/⚠️/❌]

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [file:line] | [Fix] |

---

### Axis 3: Architecture 🏗️
**Score:** [X]/10
**Status:** [✅/⚠️/❌]

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [file:line] | [Fix] |

---

### Axis 4: Security 🔒
**Score:** [X]/10
**Status:** [✅/⚠️/❌]

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [file:line] | [Fix] |

---

### Axis 5: Performance ⚡
**Score:** [X]/10
**Status:** [✅/⚠️/❌]

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [file:line] | [Fix] |

---

### Axis 6: Testing 🧪
**Score:** [X]/10
**Status:** [✅/⚠️/❌]

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [file:line] | [Fix] |

---

### Axis 7: Maintainability 🔧
**Score:** [X]/10
**Status:** [✅/⚠️/❌]

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [file:line] | [Fix] |

---

### Axis 8: Scalability 📈
**Score:** [X]/10
**Status:** [✅/⚠️/❌]

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [file:line] | [Fix] |

---

### Axis 9: Documentation 📚
**Score:** [X]/10
**Status:** [✅/⚠️/❌]

**Findings:**
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| [C/H/M/L] | [Issue] | [file:line] | [Fix] |

---

## Security Vulnerability Assessment

### OWASP Findings
| Category | Severity | Issue | Fix |
|----------|----------|-------|-----|
| [A01-A10] | [C/H/M/L] | [Issue] | [Fix] |

### Blocking Issues
| Issue | Severity | Impact | Fix |
|-------|----------|--------|-----|
| [Issue] | [Critical/High] | [Impact] | [Fix] |

---

## Scorecard

| Axis | Score | Grade | Notes |
|------|-------|-------|-------|
| Correctness | [X]/10 | [A-F] | [Notes] |
| Readability | [X]/10 | [A-F] | [Notes] |
| Architecture | [X]/10 | [A-F] | [Notes] |
| Security | [X]/10 | [A-F] | [Notes] |
| Performance | [X]/10 | [A-F] | [Notes] |
| Testing | [X]/10 | [A-F] | [Notes] |
| Maintainability | [X]/10 | [A-F] | [Notes] |
| Scalability | [X]/10 | [A-F] | [Notes] |
| Documentation | [X]/10 | [A-F] | [Notes] |
| **OVERALL** | **[X.X]/10** | **[A-F]** | [Notes] |

---

## Recommendations

### Must Fix Before Merge
1. [Critical/High issue 1]
2. [Critical/High issue 2]

### Should Fix Soon
1. [Medium issue 1]
2. [Medium issue 2]

### Nice to Have
1. [Low issue 1]
2. [Low issue 2]

---

## Decision

**Status:** [✅ APPROVED | ⚠️ CONDITIONAL | ❌ REJECTED]

**Rationale:**
[Reasoning for decision]

**Conditions (if CONDITIONAL):**
- [Condition 1]
- [Condition 2]

**Blocking Issues (if REJECTED):**
- [Issue 1]
- [Issue 2]

---

**Report Generated:** [Timestamp]
**Reviewed by:** Senior Code Reviewer + Security Reviewer
```

---

## Success Criteria

- [ ] All 9 axes reviewed and scored
- [ ] Security assessment completed
- [ ] Findings classified by severity
- [ ] Overall score calculated
- [ ] Blocking issues identified
- [ ] Recommendations prioritized
- [ ] Decision documented

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Primary Agents:** senior-code-reviewer, security-reviewer

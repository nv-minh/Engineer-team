# ISSUE-REGISTER.md - Issue & Risk Register (課題・リスク管理表)

**Project:** [Project Name]
**Last Updated:** YYYY-MM-DD
**Updated by:** [Name]

---

## How to Use This Register

- **Issues** are problems that have already occurred and require action
- **Risks** are potential problems that may occur in the future
- Review this register at every weekly status meeting
- Close issues only after the resolution has been verified
- Update risk status when probability or impact changes

---

## Active Issues (オープン課題)

### ISSUE-001: [Short Issue Title]
- **ID:** ISSUE-001
- **Type:** Issue (problem already occurred)
- **Status:** Open | In Progress | Resolved | Closed
- **Severity:** Critical | High | Medium | Low
- **Priority:** P1 | P2 | P3 | P4
- **Opened:** YYYY-MM-DD
- **Opened by:** [Name]
- **Assigned to:** [Name]
- **Target resolution:** YYYY-MM-DD

**Description:**
[Clear description of the issue. What happened? What is the impact?]

**Root Cause (5-Why Analysis):**
1. Why did it happen? → [Answer]
2. Why did that happen? → [Answer]
3. Why did that happen? → [Answer]
4. Why did that happen? → [Answer]
5. Root cause: [Root cause statement]

**Impact:**
- [ ] Blocks delivery
- [ ] Impacts timeline (+[N] days)
- [ ] Impacts other issues/risks: [list]
- [ ] Client-visible impact: [Yes/No — description]

**Resolution Plan:**
| Action | Owner | Due Date | Status |
|---|---|---|---|
| [Action 1] | [Name] | YYYY-MM-DD | [ ] |
| [Action 2] | [Name] | YYYY-MM-DD | [ ] |

**Resolution:**
[Filled in when resolved: what was done to fix this?]

**Closed Date:** YYYY-MM-DD
**Verified by:** [Name]

---

## Active Risks (リスク一覧)

### RISK-001: [Short Risk Title]
- **ID:** RISK-001
- **Type:** Risk (potential future problem)
- **Status:** Open | Mitigating | Accepted | Closed
- **Probability:** High (> 70%) | Medium (30-70%) | Low (< 30%)
- **Impact:** High | Medium | Low
- **Risk Level:** [Probability × Impact = Critical/High/Medium/Low]
- **Identified:** YYYY-MM-DD
- **Identified by:** [Name]
- **Owner:** [Name who manages this risk]
- **Review date:** YYYY-MM-DD

**Description:**
[What could happen? Under what conditions?]

**Trigger Conditions:**
[What would cause this risk to materialize into an issue?]

**Impact if Materialized:**
- Schedule impact: +[N] days
- Scope impact: [What would be affected]
- Cost impact: [If applicable]

**Mitigation Actions:**
| Action | Owner | Due Date | Status |
|---|---|---|---|
| [Preventive action 1] | [Name] | YYYY-MM-DD | [ ] |
| [Contingency plan] | [Name] | YYYY-MM-DD | [ ] |

**Contingency Plan:**
[If the risk materializes despite mitigation, what do we do?]

---

## Risk Matrix (リスクマトリックス)

```
Impact
  High  │ MEDIUM  │  HIGH   │ CRITICAL │
        │         │         │          │
 Medium │  LOW    │ MEDIUM  │  HIGH    │
        │         │         │          │
   Low  │  LOW    │  LOW    │ MEDIUM   │
        └─────────┴─────────┴──────────┘
          Low      Medium     High
                  Probability
```

**Current risk map:**
| ID | Risk | Probability | Impact | Level |
|---|---|---|---|---|
| RISK-001 | [Title] | Medium | High | HIGH |
| RISK-002 | [Title] | Low | High | MEDIUM |

---

## Escalation Protocol (エスカレーション基準)

| Severity/Level | Escalation Target | Timeline |
|---|---|---|
| CRITICAL Issue | Client PM + Management | Same day |
| HIGH Issue | PM + Tech Lead | Same day |
| CRITICAL Risk | PM + Tech Lead | Next working day |
| HIGH Risk materializing | PM | Next working day |
| Schedule impact > 5 days | Client | Same week |
| Budget impact > 10% | Management + Client | Same day |

---

## Closed Issues & Risks (クローズ済み)

| ID | Title | Type | Closed | Root Cause | Resolution |
|---|---|---|---|---|---|
| [ID] | [Title] | Issue/Risk | YYYY-MM-DD | [Summary] | [Summary] |

---

## Summary Dashboard (サマリー)

| Category | Critical | High | Medium | Low | Total |
|---|---|---|---|---|---|
| Open Issues | 0 | 0 | 0 | 0 | 0 |
| Active Risks | 0 | 0 | 0 | 0 | 0 |
| Closed this week | — | — | — | — | 0 |

---

**Created:** YYYY-MM-DD
**Review cadence:** Weekly (every Monday with weekly progress report)

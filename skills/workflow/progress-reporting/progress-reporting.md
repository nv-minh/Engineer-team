---
name: progress-reporting
description: "Creates formal 進捗報告 (Progress Reports) for projects — weekly status updates with completion metrics, blockers, risks, and schedule variance. Use when managing projects for Japanese clients or any stakeholder requiring regular formal progress visibility."
version: "1.0.0"
category: "workflow"
origin: "EM-Team (Japanese outsourcing)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "progress report"
  - "進捗報告"
  - "weekly status"
  - "status report"
  - "project update"
  - "weekly report"
  - "stakeholder update"
intent: "Produce structured, consistent progress reports that give stakeholders accurate visibility into project status, risks, and schedule — enabling informed decisions without requiring deep technical context."
scenarios:
  - "Weekly status reporting to Japanese client or PM"
  - "End-of-sprint progress report for stakeholders"
  - "Project health check for escalation decisions"
  - "Monthly executive summary for steering committee"
best_for: "Japanese outsourcing, client management, sprint reviews, project governance"
estimated_time: "30-60 minutes per report"
anti_patterns:
  - "Reporting only completed items — blockers and risks must be surfaced proactively"
  - "Vague status like 'on track' without metrics — use percentages and dates"
  - "Waiting until the end of a bad week to report problems — surface issues early"
  - "Copying last week's report with minor edits — every report must be freshly accurate"
related_skills:
  - documentation
  - writing-plans
  - spec-driven-development
---

# Progress Reporting (進捗報告)

## Overview

Progress reporting is the cadence by which project teams communicate status, risks, and next steps to stakeholders. Effective progress reports give decision-makers accurate visibility without requiring them to read code, attend meetings, or ask clarifying questions.

In Japanese outsourcing contexts, the weekly 進捗報告 (progress report) is a contractual deliverable. Clients expect:
- **Consistency:** Same format every week; deviations are conspicuous
- **Accuracy:** Numbers are verifiable, not estimated
- **Proactivity:** Problems surfaced before they become crises
- **Completeness:** Completed, in-progress, and blocked work all reported

## When to Use

- Weekly cadence for any active project with external stakeholders
- End-of-sprint status updates for client visibility
- Escalation reports when a project falls behind or a risk materializes
- Project health checks for steering committee reviews

**When NOT to Use:** Internal team standups (too heavy); single-developer tasks with no external stakeholders.

## Anti-Patterns

- Status indicators without metrics: "on track" without completion % or dates is meaningless
- Omitting bad news: delayed reports of problems guarantee they become crises
- Technical jargon: reports must be readable by non-technical stakeholders
- Stale risk register: risks that have materialized must be escalated, not listed as still-pending

## Process

### Weekly Report Template

Create `reports/progress/YYYY-MM-DD-weekly-report.md`:

```markdown
# Weekly Progress Report (週次進捗報告書)
**Project:** [Project Name]
**Report Date:** YYYY-MM-DD
**Report Period:** YYYY-MM-DD to YYYY-MM-DD
**Prepared by:** [Name]
**Distribution:** [Client PM, Internal PM, Dev Lead]

---

## 🚦 Overall Status: GREEN | YELLOW | RED

| Area | Status | Note |
|---|---|---|
| Schedule | 🟢 GREEN | On track for YYYY-MM-DD milestone |
| Quality | 🟡 YELLOW | 3 High defects under investigation |
| Scope | 🟢 GREEN | No scope changes this week |
| Risk | 🟡 YELLOW | See Risk section |

**Status Criteria:**
- 🟢 GREEN: On track, no significant issues
- 🟡 YELLOW: Minor issues; mitigation in progress; no delivery impact expected
- 🔴 RED: Significant issue; delivery impact likely; escalation required

---

## 1. Executive Summary (エグゼクティブサマリー)

[2-3 sentences: what was accomplished this week, what is the critical path item for next week, and any important decisions needed from stakeholders.]

---

## 2. Progress Summary (進捗サマリー)

### Overall Completion
| Phase/Feature | Planned | Actual | Variance | % Complete |
|---|---|---|---|---|
| [Feature A] | 80% | 75% | -5% | 🟡 |
| [Feature B] | 50% | 55% | +5% | 🟢 |
| [Feature C] | 0% | 0% | 0% | Not started |
| **Total** | **50%** | **48%** | **-2%** | 🟡 |

### Sprint/Week Velocity
| Metric | This Week | Last Week | Target |
|---|---|---|---|
| Tasks completed | 12 | 10 | 12 |
| Story points delivered | 34 | 28 | 32 |
| Test cases passed | 45 | 38 | 50 |

---

## 3. Completed This Week (今週完了した作業)

| Task | Assignee | Completion Date | Notes |
|---|---|---|---|
| [Task description] | [Name] | YYYY-MM-DD | [Any relevant notes] |
| [Task description] | [Name] | YYYY-MM-DD | — |

---

## 4. In Progress (進行中の作業)

| Task | Assignee | Target Date | % Complete | Status |
|---|---|---|---|---|
| [Task] | [Name] | YYYY-MM-DD | 60% | 🟢 On track |
| [Task] | [Name] | YYYY-MM-DD | 30% | 🟡 Slightly delayed |

---

## 5. Blockers (ブロッカー)

> Blockers are issues preventing progress on tasks. Each blocker must have an owner and target resolution date.

| ID | Description | Impact | Owner | Target Resolution |
|---|---|---|---|---|
| BLK-001 | [e.g., Waiting for client to provide API credentials] | Blocks Feature B | [Client PM] | YYYY-MM-DD |
| BLK-002 | [e.g., Staging environment down] | Blocks all testing | [DevOps] | YYYY-MM-DD |

**Blockers requiring client action:**
> ⚠️ BLK-001: [Clear description of what is needed from client and by when]

---

## 6. Quality Metrics (品質指標)

| Metric | This Week | Last Week | Target | Status |
|---|---|---|---|---|
| Test coverage (unit) | 82% | 79% | ≥ 80% | 🟢 |
| Test coverage (E2E) | 65% | 60% | ≥ 70% | 🟡 |
| Open defects (Critical) | 0 | 0 | 0 | 🟢 |
| Open defects (High) | 3 | 5 | ≤ 2 | 🟡 |
| Open defects (Medium/Low) | 8 | 10 | ≤ 10 | 🟢 |
| Code review cycle time | 4h avg | 6h avg | ≤ 4h | 🟢 |

---

## 7. Schedule Overview (スケジュール概要)

| Milestone | Planned Date | Forecast Date | Variance | Status |
|---|---|---|---|---|
| [Basic Design sign-off] | YYYY-MM-DD | YYYY-MM-DD | 0 days | ✅ Done |
| [Feature A delivery] | YYYY-MM-DD | YYYY-MM-DD | +2 days | 🟡 |
| [UAT start] | YYYY-MM-DD | YYYY-MM-DD | 0 days | 🟢 |
| [Delivery] | YYYY-MM-DD | YYYY-MM-DD | 0 days | 🟢 |

**Critical path item:** [The single most important item to watch this week]

---

## 8. Risks & Issues (リスク・課題)

| ID | Risk/Issue | Probability | Impact | Mitigation | Owner | Status |
|---|---|---|---|---|---|---|
| RSK-001 | [e.g., Third-party API instability] | Medium | High | Implement retry logic + fallback | Dev Lead | Mitigating |
| ISS-001 | [e.g., Requirement ambiguity in FR-015] | — | High | Clarification meeting scheduled | PM | Open |

**Escalation required:** [List any items requiring immediate client/management decision]

---

## 9. Change Requests (変更要求)

| CHG-ID | Description | Requested by | Impact | Status |
|---|---|---|---|---|
| CHG-001 | [Scope change description] | [Client] | +3 days, +2 dev days | Under review |

---

## 10. Next Week Plan (来週の予定)

| Task | Assignee | Target |
|---|---|---|
| [Complete Feature A backend] | [Name] | YYYY-MM-DD |
| [Begin UAT preparation] | [Name] | YYYY-MM-DD |
| [Resolve BLK-001] | [Client] | YYYY-MM-DD |

**Key decisions needed from client/management:**
1. [Decision needed + deadline]

---

## 11. Questions for Client (クライアントへの質問)

| # | Question | Context | Response needed by |
|---|---|---|---|
| Q-001 | [Clear, specific question] | [Why this matters] | YYYY-MM-DD |

---

*Report prepared by: [Name] | Contact: [email]*
```

---

### Status Indicator Criteria

Use consistent criteria so stakeholders understand the same thing every week:

```
🟢 GREEN — On track
  - Schedule variance ≤ ±5% or ≤ 2 days
  - No Critical or High defects open
  - No unmitigated risks
  - No decisions needed immediately

🟡 YELLOW — At risk, attention needed
  - Schedule variance -5% to -15% or 2-5 days behind
  - High defects open but under investigation
  - Risk materializing but mitigation underway
  - Client decision needed within this week

🔴 RED — Problem, escalation required
  - Schedule variance > -15% or > 5 days behind
  - Critical defect open
  - Risk materialized with no mitigation
  - Client decision already missed
  - Delivery date at risk
```

### Report Cadence

| Report Type | Frequency | Audience | Turnaround |
|---|---|---|---|
| Weekly Status | Every Monday AM | Client PM, Internal PM | Report covers previous Mon-Fri |
| Milestone Report | At each milestone | Steering committee | Within 2 days of milestone |
| Escalation Report | When RED status | Immediate escalation to client management | Same day |
| Monthly Summary | First week of month | Executive sponsors | Covers previous month |

### Escalation Trigger Protocol

When a metric crosses from YELLOW to RED:

```
Escalation checklist:
1. Confirm the issue is real (not a data error)
2. Identify the root cause (not just the symptom)
3. Quantify the impact (X days delay, Y cost impact)
4. Prepare 2-3 mitigation options with trade-offs
5. Send escalation report SAME DAY — do not wait for next weekly report
6. Follow up verbally (call or video, not just email)
```

Escalation report format:
```markdown
# ESCALATION: [Issue Title]
**Project:** [Name] | **Date:** YYYY-MM-DD | **Severity:** HIGH / CRITICAL

## Issue
[One paragraph: what happened, when it was discovered, who is affected]

## Impact
- Schedule: [+X days delay]
- Scope: [What is at risk]
- Cost: [If applicable]

## Root Cause
[Why this happened — not just what happened]

## Options
| Option | Impact | Trade-off |
|---|---|---|
| [Option A] | [+X days delay, low cost] | [Risk: ...] |
| [Option B] | [No delay, +Y cost] | [Risk: ...] |

## Recommended Action
[Which option we recommend and why]

## Decision needed by
YYYY-MM-DD [or delivery is impacted]

**Contact:** [PM name, phone]
```

## Coaching Notes

> **ABC - Always Be Coaching:**

1. **Status reports are decision-support tools.** Every line should answer the question: "what does the client/manager need to know to make a good decision?" Remove anything that doesn't serve this purpose.

2. **Metrics without targets are noise.** "82% test coverage" means nothing without a target. "82% test coverage vs. 80% target: GREEN" means something.

3. **Surface problems early — bad news early is manageable; bad news late is a crisis.** The most damaging thing a team can do is hide a RED status until it's too late to fix. Trust is built by reporting problems honestly, not by hiding them until they explode.

4. **Questions to client deserve deadlines.** "Q: Please confirm the API format" is weak. "Q: Please confirm the API format by YYYY-MM-DD or we will proceed with assumption X and incur 3 days rework if wrong" is actionable.

## Verification

Before sending a progress report:

- [ ] Overall status indicator is current and accurate (not copy-pasted from last week)
- [ ] Completion percentages are measured, not estimated
- [ ] All blockers have owners and target resolution dates
- [ ] Quality metrics updated with this week's numbers
- [ ] Schedule table reflects actual dates (planned vs. forecast)
- [ ] Questions for client have response-needed-by dates
- [ ] Report reviewed by tech lead before sending
- [ ] Saved to `reports/progress/YYYY-MM-DD-weekly-report.md`

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

After completing this skill, export to:
`plans/YYYY-MM-DD-HHMM-progress-report-<week>.md`

Include YAML frontmatter: project name, report period, overall status, key metrics.

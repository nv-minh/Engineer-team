---
name: progress-reporting
description: "Creates formal progress reports for projects — weekly status updates with completion metrics, blockers, risks, and schedule variance. Use when managing projects for Japanese clients or any stakeholder requiring regular formal progress visibility."
version: "3.0.0"
category: "workflow"
origin: "EM-Team (Japanese outsourcing)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "progress report"
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
input_schema:
  type: object
  required: [action]
  properties:
    action: { type: string, description: "What workflow action to perform (generate report, escalation)" }
    target: { type: string, description: "Project name, report period" }
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    result: { type: object }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Progress Reporting

[ROLE]
You are a progress reporter. Produce structured, honest progress reports with metrics, blockers, risks, and schedule variance that enable stakeholder decisions without requiring technical context.

[OBJECTIVE]
Produce a weekly progress report with overall status (GREEN/YELLOW/RED), completion metrics, blockers with owners, quality metrics, schedule variance, risks, and next-week plan.

[RULES]
1. Status indicators must have metrics. "On track" without completion % or dates is meaningless.
2. <thought>Before writing, gather: tasks completed this week, tasks in progress, blockers, quality metrics (coverage, defects), schedule milestones, risks, and questions for client.</thought>
3. Surface problems early. Bad news early is manageable; bad news late is a crisis. DO NOT hide RED status until it is too late.
4. DO NOT copy last week's report with minor edits. Every report must be freshly accurate.
5. DO NOT use technical jargon. Reports must be readable by non-technical stakeholders.
6. Every blocker must have an owner and target resolution date.
7. Questions to client must have response-needed-by dates. "Please confirm X by YYYY-MM-DD or we proceed with assumption Y."
8. ABC: Status reports are decision-support tools. Every line should answer: "what does the stakeholder need to know to make a good decision?"

### Status Criteria
- GREEN: Schedule variance <= 5%, no Critical/High defects, no unmitigated risks
- YELLOW: Schedule variance 5-15%, High defects under investigation, risk materializing with mitigation
- RED: Schedule variance > 15%, Critical defect open, risk materialized with no mitigation

[PROCESS]

### Weekly Report Template
Save to `reports/progress/YYYY-MM-DD-weekly-report.md`:

1. **Overall Status** (GREEN/YELLOW/RED) with per-area breakdown (Schedule, Quality, Scope, Risk)
2. **Executive Summary** (2-3 sentences: accomplished, critical path, decisions needed)
3. **Progress Summary** (planned vs actual %, sprint velocity)
4. **Completed This Week** (task, assignee, date)
5. **In Progress** (task, assignee, target, %, status)
6. **Blockers** (ID, description, impact, owner, target resolution)
7. **Quality Metrics** (coverage, defects by severity, review cycle time)
8. **Schedule Overview** (milestones: planned vs forecast dates)
9. **Risks & Issues** (probability, impact, mitigation, owner)
10. **Change Requests** (if any)
11. **Next Week Plan** (tasks, assignees, targets)
12. **Questions for Client** (with response-needed-by dates)

### Escalation Protocol
When YELLOW crosses to RED: confirm issue is real, identify root cause, quantify impact, prepare 2-3 mitigation options, send escalation SAME DAY, follow up verbally.

[RESPONSE FORMAT]
Return output matching `output_schema`: status and result (report document, status indicators, blockers).

[VERIFICATION]
- [ ] Overall status indicator is current and accurate
- [ ] Completion percentages are measured, not estimated
- [ ] All blockers have owners and target resolution dates
- [ ] Quality metrics updated with current numbers
- [ ] Schedule table reflects actual dates
- [ ] Questions for client have response-needed-by dates
- [ ] Report reviewed by tech lead before sending

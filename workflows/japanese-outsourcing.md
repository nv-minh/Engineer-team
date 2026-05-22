---
name: japanese-outsourcing
description: "End-to-end workflow for Japanese outsourcing projects. Maps the EM-Team 6-phase lifecycle to Japanese software development standards (基本設計, 詳細設計, 受け入れテスト) with formal sign-off gates, weekly progress reporting, and change management."
version: "1.0.0"
category: "workflow"
triggers:
  - "Japanese outsourcing"
  - "日本向けプロジェクト"
  - "outsource Japan"
  - "日本クライアント"
  - "formal sign-off"
  - "受け入れテスト"
intent: "Deliver software projects that meet Japanese client quality standards: formally documented, traceably reviewed, and client-signed at each phase gate."
---

# Japanese Outsourcing Workflow (日本向け受託開発ワークフロー)

## Overview

This workflow extends the standard 6-phase lifecycle with the formal documentation, review gates, and client communication cadences required for Japanese outsourcing contracts. It maps EM-Team's capabilities to the standard Japanese software development deliverables:

| EM-Team Phase | Japanese Deliverable | Gate |
|---|---|---|
| DEFINE | 要件定義 (Requirements Definition) | Gate 1: Requirements sign-off |
| PLAN | 基本設計 + 詳細設計 (Basic & Detailed Design) | Gate 2a + 2b: Design sign-off |
| BUILD | 実装 (Implementation) | Gate 3: Code review approval |
| VERIFY | テスト (Testing: System + UAT) | Gate 4: UAT sign-off |
| REVIEW | — (integrated into gates) | — |
| SHIP | リリース (Release & Delivery) | Acceptance checklist sign-off |

---

## Prerequisites

Before starting this workflow, confirm:
- [ ] Project contract specifies formal sign-off requirements
- [ ] Client has designated a technical contact and PM contact
- [ ] Communication channel agreed (email, Slack, etc.)
- [ ] Weekly reporting cadence agreed (day of week, distribution list)
- [ ] Document storage location agreed (shared drive, project management tool)

---

## Stage 1: Kickoff (プロジェクト開始)

**Owner:** Project Manager + Tech Lead
**Duration:** 1-2 days

### 1.1 Project Initialization
- [ ] Create project directory structure
- [ ] Initialize PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md
- [ ] Initialize ISSUE-REGISTER.md
- [ ] Initialize CHANGE-LOG.md
- [ ] Initialize WBS.md (draft)
- [ ] Set up `docs/` structure: `docs/uat/`, `docs/detailed-design/`, `docs/changes/`, `docs/gates/`
- [ ] Configure `reports/progress/` directory for weekly reports
- [ ] Set up git repository with branch protection on main

### 1.2 Kickoff Meeting
Agenda:
1. Project scope walkthrough (REQUIREMENTS.md review)
2. Timeline agreement (WBS.md walkthrough)
3. Communication protocol: weekly report day, escalation contacts
4. Review gate schedule (when will Gate 1, 2, 3, 4 occur?)
5. Change management process explained
6. Introduce UAT process (client will participate in Gate 4)

**Output:** Meeting minutes saved to `docs/kickoff-minutes.md`

### 1.3 Gate Register Setup
Create `docs/GATE-STATUS.md` with planned dates for all 4 gates.

---

## Stage 2: Requirements (要件定義) → Gate 1

**Owner:** PM + Architect
**Skills:** `spec-driven-development`, `domain-modeling`, `brainstorming`
**Duration:** 2-5 days

### Process
1. Run `alignment-session` skill to surface assumptions and clarify scope
2. Produce REQUIREMENTS.md (all FR-* and NFR-* with acceptance criteria)
3. Run `domain-modeling` skill to identify bounded contexts and entities
4. Update WBS.md with Phase 1 estimates
5. Schedule Gate 1 review with client

### Gate 1: Requirements Sign-Off
- Present REQUIREMENTS.md to client
- Confirm scope boundaries (in/out)
- Get written sign-off using Gate 1 template in `protocols/review-gates.md`
- Save sign-off to `docs/gates/gate1-signoff.md`

**Output:** REQUIREMENTS.md v1.0 (signed), DOMAIN-MODEL.md, WBS.md draft

---

## Stage 3: Basic Design (基本設計) → Gate 2a

**Owner:** Architect + Tech Lead
**Skills:** `basic-design`, `diagram`, `api-interface-design`
**Duration:** 2-4 days

### Process
1. Run `basic-design` skill to produce BASIC-DESIGN.md
2. Include: system context, architecture, ER diagram, API interfaces, NFRs, error handling
3. Internal review: architect + tech lead + backend expert
4. Schedule Gate 2a review with client

### Gate 2a: Basic Design Sign-Off
- Present BASIC-DESIGN.md to client technical contact
- Walk through architecture, API interfaces, data model
- Get written sign-off using Gate 2a template in `protocols/review-gates.md`
- Save sign-off to `docs/gates/gate2a-signoff.md`

**Output:** BASIC-DESIGN.md v1.0 (signed)

---

## Stage 4: Detailed Design (詳細設計) → Gate 2b

**Owner:** Dev Lead
**Skills:** `detailed-design`, `writing-plans`
**Duration:** 1-3 days per module

### Process
1. For each complex module identified in Basic Design:
   - Run `detailed-design` skill
   - Include: class diagrams, function specs, data flows, exception tables, test designs
2. Internal review: tech lead + QA lead
3. Update WBS.md with detailed task breakdown
4. Schedule Gate 2b review with tech lead (client optional)

### Gate 2b: Detailed Design Sign-Off
- Tech lead and QA lead review all module designs
- Verify test designs are complete (test cases from spec, not from code)
- Get written sign-off using Gate 2b template
- Save sign-off to `docs/gates/gate2b-signoff.md`

**Output:** `docs/detailed-design/*.md` (all modules, signed)

---

## Stage 5: Implementation (実装)

**Owner:** Dev team
**Skills:** `test-driven-development`, `incremental-implementation`, `git-workflow`
**Duration:** Per WBS

### Process
1. Load Project DNA (CLAUDE.md + rules)
2. Execute WBS tasks with TDD (RED-GREEN-REFACTOR)
3. Atomic commits referencing WBS task IDs
4. Daily: update STATE.md with completed tasks
5. Weekly: produce progress report using `progress-reporting` skill

### Weekly Progress Reporting Cadence
Every [agreed day]:
1. Run `progress-reporting` skill
2. Update: completion %, quality metrics, blockers, risks, schedule
3. Send to distribution list
4. Client responds to Q&A items within 3 business days

### Change Management During Implementation
Any scope change request:
1. Developer or PM identifies potential change
2. Create CR using `protocols/change-management.md`
3. Do NOT implement until CR is approved
4. Update CHANGE-LOG.md and WBS.md after approval

**Output:** Working code, tests, updated WBS, weekly reports, CHANGE-LOG.md

---

## Stage 6: Internal Testing (内部テスト)

**Owner:** QA team + Dev team
**Skills:** `e2e-testing`, `security-audit`, `performance-optimization`
**Duration:** 2-5 days

### Process
1. System testing against acceptance criteria in REQUIREMENTS.md
2. Performance testing against NFR targets
3. Security audit (OWASP Top 10)
4. Fix all Critical and High defects found
5. Log all defects in ISSUE-REGISTER.md
6. Code review for all modules using `code-review` skill (9-axis)
7. Architecture review: implementation matches BASIC-DESIGN.md

### Gate 3: Code Review Approval
- Tech lead verifies: all acceptance criteria implemented, all tests passing
- Code reviewer sign-off (no Critical/High findings)
- Security reviewer sign-off
- Get written sign-off using Gate 3 template
- Save to `docs/gates/gate3-signoff.md`

**Output:** System test report, security audit report, Gate 3 sign-off

---

## Stage 7: UAT (受け入れテスト) → Gate 4

**Owner:** QA team + Client tester
**Skills:** `uat-process`
**Duration:** 3-7 days

### Process
1. Run `uat-process` skill:
   - Create UAT test plan (client reviews and approves)
   - Create numbered test cases (client reviews before execution)
   - Execute UAT with client tester present (or coordinated)
   - Log all results in execution log
   - Log defects in defect log
   - Fix Critical and High defects, re-test
2. Produce UAT Completion Report

### Gate 4: UAT Sign-Off
- Confirm: 0 Critical defects open, all High resolved or risk-accepted
- Present UAT report to client
- Get written sign-off on UAT-SIGNOFF.md
- Save to `docs/gates/gate4-signoff.md`

**Output:** UAT test cases, execution log, defect log, UAT sign-off

---

## Stage 8: Delivery & Deployment (納品・リリース)

**Owner:** PM + DevOps + Dev Lead
**Skills:** `ship-workflow`, `documentation`, `ci-cd-automation`
**Duration:** 1-2 days

### Process
1. Complete ACCEPTANCE-CHECKLIST.md (all items verified)
2. Prepare delivery package:
   - Source code (with access credentials or archive)
   - All documentation (`docs/` directory)
   - Test results (system test + UAT)
   - Release notes
   - Deployment guide
3. Deploy to production (if in scope)
4. Post-deploy monitoring (24h)
5. Client reviews ACCEPTANCE-CHECKLIST.md
6. Get final acceptance signature on ACCEPTANCE-CHECKLIST.md
7. Send formal delivery notification

### Final Delivery Email Template
```
Subject: [Project Name] v[X.X] — 納品完了通知

Dear [Client Name],

We are pleased to notify you that [Project Name] v[X.X] delivery is complete.

Delivery summary:
- Features delivered: [N] features as agreed in REQUIREMENTS.md v[X.X]
- UAT result: [N]% pass rate, 0 Critical defects
- Delivery package: [location/link]
- Production deployment: [URL or "per separate deployment plan"]

Please review and sign the Acceptance Checklist at [link/location].

Support period: YYYY-MM-DD to YYYY-MM-DD
Support contact: [Name] — [email]

Best regards,
[PM Name]
```

**Output:** Signed ACCEPTANCE-CHECKLIST.md, deployment confirmation, delivery notification

---

## Stage 9: Post-Delivery Support (アフターサポート)

**Owner:** Dev Lead + PM
**Duration:** Per contract (typically 1-3 months)

### Process
1. Support contact responds to issues within [agreed SLA]
2. Defects from production logged in ISSUE-REGISTER.md
3. Warranty fixes (defects in delivered scope) at no additional charge
4. Enhancement requests go through CR process (change-management.md)
5. Knowledge transfer session (if agreed): session recorded and documented
6. End of support: notify client, confirm handoff

---

## Document Register (ドキュメント一覧)

| Document | Location | Produced at Stage | Sign-off Required |
|---|---|---|---|
| PROJECT.md | Root | Stage 1 | No |
| REQUIREMENTS.md | Root | Stage 2 | Gate 1 ✅ |
| WBS.md | templates/ | Stage 2 | No (reviewed) |
| BASIC-DESIGN.md | docs/ | Stage 3 | Gate 2a ✅ |
| Detailed Design (per module) | docs/detailed-design/ | Stage 4 | Gate 2b ✅ |
| Weekly Progress Reports | reports/progress/ | Stages 5-7 | No |
| CHANGE-LOG.md | docs/changes/ | Ongoing | Per CR |
| ISSUE-REGISTER.md | Root | Ongoing | No |
| System Test Report | docs/uat/ | Stage 6 | Gate 3 ✅ |
| UAT Test Plan | docs/uat/ | Stage 7 | Client review |
| UAT Test Cases | docs/uat/ | Stage 7 | Client review |
| UAT Execution Log | docs/uat/ | Stage 7 | No |
| UAT Sign-off | docs/uat/ | Stage 7 | Gate 4 ✅ |
| ACCEPTANCE-CHECKLIST.md | docs/ | Stage 8 | Final sign-off ✅ |
| Release Notes | docs/ | Stage 8 | No |
| GATE-STATUS.md | docs/gates/ | Ongoing | No |

---

## Communication Cadence (コミュニケーション)

| Event | Frequency | Owner | Format |
|---|---|---|---|
| Weekly Progress Report | Every [Mon] | PM | Email + `reports/progress/*.md` |
| Gate Reviews | At each gate | PM + Tech Lead | Meeting + sign-off doc |
| Escalation | When RED status | PM | Same-day email + call |
| Change Request response | Within 3 business days | PM | Written decision in CR |
| Q&A response (client) | Within 3 business days | Client PM | Email or CR |

---

## Risk & Quality Summary

| Risk | Mitigation in this Workflow |
|---|---|
| Scope creep | Change management protocol (every change needs a CR) |
| Design disputes | Gates 2a + 2b: client sign-off before coding |
| Late defect discovery | Gate 3 blocks staging; Gate 4 blocks delivery |
| "I never agreed to that" | Written sign-off at every gate |
| Poor client communication | Weekly reports + response SLA |
| Vendor non-performance | Quality metrics in weekly reports; escalation criteria |

---

## Handoff Contract

This workflow is complete when:
- [ ] All 4 gates passed and signed
- [ ] ACCEPTANCE-CHECKLIST.md signed by client
- [ ] All documents committed to repository
- [ ] Support contact confirmed
- [ ] Delivery notification sent

**JAPANESE_OUTSOURCING_WORKFLOW_COMPLETE**

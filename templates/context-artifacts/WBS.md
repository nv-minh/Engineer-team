# WBS.md - Work Breakdown Structure

**Project:** [Project Name]
**Version:** 1.0
**Date:** YYYY-MM-DD
**Prepared by:** [Name]
**Based on:** REQUIREMENTS.md, ROADMAP.md

---

## WBS Overview

This document provides the hierarchical breakdown of all project work. Each task has an ID, effort estimate, owner, dependencies, and milestone.

**Total Estimated Effort:** [N] person-days

---

## Level 1: Project Phases

```
[Project Name]
├── 1. Define & Design
├── 2. Development
├── 3. Testing & QA
├── 4. Delivery & Deployment
└── 5. Post-delivery Support
```

---

## 1. Define & Design (設計フェーズ)

| ID | Task | Effort (days) | Owner | Dependencies | Milestone | Status |
|---|---|---|---|---|---|---|
| 1.1 | Requirements finalization | 1 | PM | — | M1 | [ ] |
| 1.2 | Domain modeling | 1 | Architect | 1.1 | M1 | [ ] |
| 1.3 | Basic Design (基本設計) | 2 | Architect | 1.2 | M1 | [ ] |
| 1.4 | Basic Design review & sign-off | 0.5 | PM + Client | 1.3 | M1 | [ ] |
| 1.5 | Detailed Design — Module A | 1 | Dev Lead | 1.4 | M2 | [ ] |
| 1.6 | Detailed Design — Module B | 1 | Dev Lead | 1.4 | M2 | [ ] |
| 1.7 | Detailed Design review & sign-off | 0.5 | Tech Lead | 1.5, 1.6 | M2 | [ ] |
| 1.8 | UI/UX design (if applicable) | 2 | Frontend | 1.4 | M2 | [ ] |

**Phase 1 Total:** [N] days

---

## 2. Development (開発フェーズ)

### 2.1 Project Setup

| ID | Task | Effort (days) | Owner | Dependencies | Milestone | Status |
|---|---|---|---|---|---|---|
| 2.1.1 | Repository setup & CI/CD pipeline | 0.5 | DevOps | 1.4 | M2 | [ ] |
| 2.1.2 | Environment setup (dev/staging/prod) | 1 | DevOps | 2.1.1 | M2 | [ ] |
| 2.1.3 | Database schema & migrations | 1 | Backend | 1.5 | M2 | [ ] |

### 2.2 [Feature A / Module A Name]

| ID | Task | Effort (days) | Owner | Dependencies | Milestone | Status |
|---|---|---|---|---|---|---|
| 2.2.1 | [API endpoint: feature-a/create] | 1 | Backend | 2.1.3 | M3 | [ ] |
| 2.2.2 | [API endpoint: feature-a/list] | 0.5 | Backend | 2.1.3 | M3 | [ ] |
| 2.2.3 | [Frontend: feature-a page] | 1.5 | Frontend | 2.2.1 | M3 | [ ] |
| 2.2.4 | [Unit tests: feature-a] | 1 | Dev | 2.2.1, 2.2.2 | M3 | [ ] |
| 2.2.5 | [Integration tests: feature-a] | 0.5 | Dev | 2.2.3 | M3 | [ ] |

### 2.3 [Feature B / Module B Name]

| ID | Task | Effort (days) | Owner | Dependencies | Milestone | Status |
|---|---|---|---|---|---|---|
| 2.3.1 | [Task] | [N] | [Owner] | [Deps] | M3 | [ ] |
| 2.3.2 | [Task] | [N] | [Owner] | [Deps] | M3 | [ ] |

**Phase 2 Total:** [N] days

---

## 3. Testing & QA (テスト・QAフェーズ)

| ID | Task | Effort (days) | Owner | Dependencies | Milestone | Status |
|---|---|---|---|---|---|---|
| 3.1 | System testing (internal) | 2 | QA | All 2.x tasks | M4 | [ ] |
| 3.2 | Performance testing | 1 | QA + DevOps | 3.1 | M4 | [ ] |
| 3.3 | Security audit | 1 | Security | 3.1 | M4 | [ ] |
| 3.4 | Bug fixing (from 3.1-3.3) | 2 | Dev | 3.1, 3.2, 3.3 | M4 | [ ] |
| 3.5 | UAT preparation (test cases, env) | 1 | QA | 3.4 | M4 | [ ] |
| 3.6 | UAT execution | 2 | QA + Client | 3.5 | M5 | [ ] |
| 3.7 | UAT defect fixing | 1 | Dev | 3.6 | M5 | [ ] |
| 3.8 | UAT re-test & sign-off | 0.5 | QA + Client | 3.7 | M5 | [ ] |

**Phase 3 Total:** [N] days

---

## 4. Delivery & Deployment (リリースフェーズ)

| ID | Task | Effort (days) | Owner | Dependencies | Milestone | Status |
|---|---|---|---|---|---|---|
| 4.1 | Release notes preparation | 0.5 | PM | 3.8 | M5 | [ ] |
| 4.2 | Deployment to production | 0.5 | DevOps | 4.1 | M5 | [ ] |
| 4.3 | Post-deploy monitoring (24h) | 0.5 | DevOps | 4.2 | M5 | [ ] |
| 4.4 | Delivery package (code, docs, tests) | 0.5 | PM + Dev | 4.2 | M5 | [ ] |
| 4.5 | Final acceptance sign-off | 0.25 | PM + Client | 4.4 | M5 | [ ] |

**Phase 4 Total:** [N] days

---

## 5. Post-Delivery Support (サポートフェーズ)

| ID | Task | Effort (days) | Owner | Dependencies | Milestone | Status |
|---|---|---|---|---|---|---|
| 5.1 | Support period (N weeks) | [N] | Dev | 4.5 | M6 | [ ] |
| 5.2 | Knowledge transfer session | 1 | Dev Lead | 4.5 | M6 | [ ] |
| 5.3 | Documentation handoff | 0.5 | Dev | 4.5 | M6 | [ ] |

---

## Milestone Summary (マイルストーン一覧)

| Milestone | Description | Target Date | Deliverable | Status |
|---|---|---|---|---|
| M1 | Design phase complete | YYYY-MM-DD | Basic Design signed off | [ ] |
| M2 | Detailed design & setup complete | YYYY-MM-DD | Detailed designs signed off, dev env ready | [ ] |
| M3 | Development complete | YYYY-MM-DD | All features implemented, code reviewed | [ ] |
| M4 | Internal testing complete | YYYY-MM-DD | System test report, security audit done | [ ] |
| M5 | UAT complete & delivered | YYYY-MM-DD | UAT sign-off, production deployed | [ ] |
| M6 | Support period complete | YYYY-MM-DD | Knowledge transfer done | [ ] |

---

## Resource Summary (リソース一覧)

| Role | Person | Allocation | Tasks |
|---|---|---|---|
| Project Manager | [Name] | 20% | 1.1, 1.4, 3.5, 4.1, 4.5 |
| Architect | [Name] | 50% (Phase 1), 20% (Phase 2) | 1.2, 1.3, 1.7 |
| Backend Developer | [Name] | 100% | 2.1.3, 2.2.1, 2.2.2, 2.3.x |
| Frontend Developer | [Name] | 100% | 1.8, 2.2.3, 2.3.x |
| QA Engineer | [Name] | 50% | 3.1–3.8 |
| DevOps | [Name] | 20% | 2.1.1, 2.1.2, 3.2, 4.2, 4.3 |

---

## Dependency Map (依存関係マップ)

Critical path (longest chain of dependent tasks):
```
1.1 → 1.2 → 1.3 → 1.4 → 1.5 → 1.7 → 2.1.3 → 2.2.1 → 2.2.4 → 3.1 → 3.4 → 3.5 → 3.6 → 3.7 → 3.8 → 4.2 → 4.5
```

Parallel workstreams possible:
- After 1.4: Backend (1.5) and Frontend (1.8) can work in parallel
- After 1.7: Feature A and Feature B backend can develop in parallel
- During development: DevOps setup (2.1.1, 2.1.2) can run in parallel

---

## Risk Buffer

| Risk | Buffer Added | Where |
|---|---|---|
| Requirement changes | +10% on Phase 2 | Built into estimates |
| UAT defects | 1 day buffer | Task 3.7 |
| Deployment issues | 0.5 day buffer | Task 4.2 |

---

**Created:** YYYY-MM-DD
**Last Updated:** YYYY-MM-DD
**Version History:**
| Version | Date | Change |
|---|---|---|
| 1.0 | YYYY-MM-DD | Initial WBS |

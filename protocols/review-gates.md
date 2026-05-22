# Review Gates Protocol (レビューゲートプロトコル)

**Formal phase gates with mandatory sign-off for Japanese outsourcing projects. Each gate is a checkpoint where work is reviewed and explicitly approved before the next phase begins.**

---

## Core Principle

**No phase starts without written sign-off from the previous gate.**

Review gates prevent the accumulation of defects and misalignments across phases. The later in the lifecycle a problem is found, the more expensive it is to fix:

```
Cost to fix a problem:
  Requirements phase:  1x
  Design phase:        5x
  Implementation:      10x
  Testing:             20x
  Production:          100x
```

---

## Gate Overview

```
DEFINE ──[Gate 1]──→ PLAN ──[Gate 2]──→ BUILD ──[Gate 3]──→ VERIFY ──[Gate 4]──→ SHIP
    Requirements      Design            Code Review         UAT Sign-off
    Sign-off          Sign-off          Approval            Acceptance
```

---

## Gate 1: Requirements Gate (要件確認ゲート)

**Trigger:** End of requirements gathering, before design begins
**Blocking:** Basic Design cannot start until Gate 1 is passed

### Entry Criteria
- [ ] REQUIREMENTS.md complete (all FR-* and NFR-*)
- [ ] All requirements reviewed with client
- [ ] Scope explicitly defined (in-scope and out-of-scope)
- [ ] WBS draft prepared
- [ ] Open questions resolved or documented with owner/due date

### Review Checklist
- [ ] All requirements have acceptance criteria
- [ ] Non-functional requirements have quantified targets
- [ ] Constraints documented (budget, tech, timeline)
- [ ] Traceability table initialized
- [ ] Client has reviewed and agrees with scope

### Sign-Off Template

```markdown
## Gate 1 Sign-Off: Requirements
**Project:** [Name] | **Date:** YYYY-MM-DD

Confirmed that requirements are complete and agreed for the scope described in REQUIREMENTS.md v[X.X].

| Role | Name | Signature | Date |
|---|---|---|---|
| Tech Lead | | | |
| Project Manager | | | |
| Client Representative | | | |

**Open items accepted:** [List any open items being carried forward with due dates]
**Conditions:** [Any conditions on this approval]
**Proceed to:** Basic Design (基本設計)
```

---

## Gate 2: Design Gate (設計ゲート)

**Trigger:** Basic Design and Detailed Design completed, before implementation
**Blocking:** Implementation cannot start until Gate 2 is passed

This gate may be split into:
- **Gate 2a:** Basic Design review (before Detailed Design)
- **Gate 2b:** Detailed Design review (before implementation)

### Gate 2a: Basic Design Review

**Entry Criteria:**
- [ ] BASIC-DESIGN.md complete (all 8 sections)
- [ ] Architecture diagrams reviewed internally
- [ ] API interfaces defined
- [ ] NFRs quantified

**Review Checklist:**
- [ ] System architecture is clear and matches requirements
- [ ] All API interfaces documented (method, auth, request/response)
- [ ] Database design matches domain model
- [ ] Performance targets are realistic and measurable
- [ ] Security approach is adequate for data sensitivity
- [ ] Error handling strategy is defined

**Sign-Off Template:**

```markdown
## Gate 2a Sign-Off: Basic Design
**Project:** [Name] | **Date:** YYYY-MM-DD

Confirmed that Basic Design (docs/BASIC-DESIGN.md v[X.X]) correctly represents
the agreed architecture for implementation.

| Role | Name | Signature | Date |
|---|---|---|---|
| Architect | | | |
| Tech Lead | | | |
| Project Manager | | | |
| Client Representative | | | |

**Conditions:** [Any items that must be resolved before Gate 2b]
**Proceed to:** Detailed Design (詳細設計)
```

### Gate 2b: Detailed Design Review

**Entry Criteria:**
- [ ] Detailed Design complete for all modules in scope
- [ ] Test designs (test cases) included in each Detailed Design
- [ ] Function specifications complete (pre/post-conditions, errors)
- [ ] Exception handling table complete

**Review Checklist (per module):**
- [ ] All public functions have complete specs
- [ ] Error codes defined with HTTP status
- [ ] Data flow covers all paths (success + error)
- [ ] Test cases derived from spec (not from implementation intuition)
- [ ] Dependencies and configuration documented

**Sign-Off Template:**

```markdown
## Gate 2b Sign-Off: Detailed Design
**Project:** [Name] | **Date:** YYYY-MM-DD

Confirmed that Detailed Designs for all in-scope modules are complete and approved for implementation.

Modules reviewed:
- [ ] [Module A] — docs/detailed-design/module-a.md v[X.X]
- [ ] [Module B] — docs/detailed-design/module-b.md v[X.X]

| Role | Name | Signature | Date |
|---|---|---|---|
| Tech Lead | | | |
| Dev Lead | | | |
| QA Lead | | | |

**Conditions:** [Any items that must be resolved during implementation]
**Proceed to:** Implementation (実装)
```

---

## Gate 3: Code Review Gate (コードレビューゲート)

**Trigger:** Feature or module implementation complete, before deployment to staging/UAT
**Blocking:** Deployment to staging/UAT environment cannot proceed until Gate 3 is passed

This gate ensures code quality and design compliance before client testing begins.

### Entry Criteria
- [ ] All implementation tasks complete
- [ ] All unit tests passing (coverage ≥ target)
- [ ] All integration tests passing
- [ ] No TODO/FIXME left unresolved
- [ ] Code review completed (5-axis or 9-axis)
- [ ] Security review completed (for auth, payments, data handling)

### Review Checklist
- [ ] Implementation matches Detailed Design (no unauthorized deviations)
- [ ] All acceptance criteria from Detailed Design are implemented
- [ ] Test coverage meets targets (unit ≥ 80%, integration ≥ 70%)
- [ ] No Critical or High findings from code review
- [ ] No OWASP vulnerabilities
- [ ] API contracts match Basic Design
- [ ] Performance targets validated (load test or benchmark)

### Sign-Off Template

```markdown
## Gate 3 Sign-Off: Code Review
**Project:** [Name] | **Feature/Module:** [Name] | **Date:** YYYY-MM-DD

| Review Type | Reviewer | Findings | Status |
|---|---|---|---|
| Code Review (9-axis) | [Name] | [N Critical, N High, N Medium] | PASS / FAIL |
| Security Review | [Name] | [N Critical, N High] | PASS / FAIL |
| Architecture Review | [Name] | [Compliant / Deviations noted] | PASS / FAIL |

**Test Coverage:**
- Unit: [N]% (target: [N]%)
- Integration: [N]% (target: [N]%)
- E2E: [N]% (target: [N]%)

| Role | Name | Signature | Date |
|---|---|---|---|
| Tech Lead | | | |
| Code Reviewer | | | |
| QA Lead | | | |

**Open findings (accepted with conditions):** [List any Medium findings being accepted]
**Proceed to:** UAT / Staging Deployment
```

---

## Gate 4: UAT Sign-Off Gate (受け入れテストゲート)

**Trigger:** UAT execution complete, before production deployment
**Blocking:** Production deployment cannot proceed without Gate 4 sign-off

This is the final gate before delivery. The client's signature on this gate is the formal acceptance of the delivery.

### Entry Criteria
- [ ] UAT test plan executed (all test cases)
- [ ] Zero Critical defects open
- [ ] UAT defect log finalized
- [ ] All High defects resolved or risk-accepted by client in writing
- [ ] Delivery package prepared (code, docs, tests, release notes)

### Review Checklist
- [ ] UAT pass rate ≥ 95% (allowed deferred items documented)
- [ ] All in-scope features verified by client tester
- [ ] Performance test results within NFR targets
- [ ] Security scan clean
- [ ] Deployment guide verified in staging
- [ ] Known issues documented in release notes

### Sign-Off Template

```markdown
## Gate 4 Sign-Off: UAT Acceptance
**Project:** [Name] | **Release:** [Version] | **Date:** YYYY-MM-DD

UAT Results Summary:
- Test cases: [N] total, [N] passed ([N]%), [N] failed, [N] deferred
- Critical defects: 0
- High defects: [N] open (see Known Issues)
- UAT period: YYYY-MM-DD to YYYY-MM-DD

Scope delivered:
- ✅ [Feature A]
- ✅ [Feature B]
- ⚠️ [Feature C] — deferred to v[X.X] by client agreement

Known issues accepted: See docs/uat/UAT-SIGNOFF.md

By signing, the client confirms acceptance of the delivered system as described above.

| Role | Name | Signature | Date |
|---|---|---|---|
| Client Representative | | | |
| Project Manager | | | |
| QA Lead | | | |
| Tech Lead | | | |

**Proceed to:** Production Deployment & Delivery
```

---

## Gate Failure Protocol

When a gate review finds the work is not ready to pass:

```
Gate Failure Process:
1. Document findings in the sign-off template with "FAIL" status
2. List specific items that must be resolved (numbered)
3. Set target date for re-review
4. Do NOT proceed to next phase
5. Notify all stakeholders of the delay and expected resolution date
6. After remediation, re-execute the gate review (full checklist, not just the failed items)
7. Update the sign-off template with the re-review date and "PASS" status
```

**Re-review SLA:**
- Minor issues (Medium findings): Re-review within 2 business days
- Significant issues (Critical/High findings): Re-review date determined by issue severity and fix effort

---

## Gate Register

Maintain a gate status table in `docs/GATE-STATUS.md`:

```markdown
# Gate Status Register

| Gate | Description | Planned Date | Actual Date | Status | Sign-off Doc |
|---|---|---|---|---|---|
| Gate 1 | Requirements | YYYY-MM-DD | YYYY-MM-DD | ✅ PASSED | docs/gates/gate1.md |
| Gate 2a | Basic Design | YYYY-MM-DD | — | ⏳ Scheduled | — |
| Gate 2b | Detailed Design | YYYY-MM-DD | — | ⏳ Not started | — |
| Gate 3 | Code Review | YYYY-MM-DD | — | ⏳ Not started | — |
| Gate 4 | UAT Sign-off | YYYY-MM-DD | — | ⏳ Not started | — |
```

---

## Integration with Other Processes

- **basic-design skill:** Produces the artifact reviewed at Gate 2a
- **detailed-design skill:** Produces the artifact reviewed at Gate 2b
- **uat-process skill:** Produces the artifact reviewed at Gate 4
- **change-management protocol:** Approved CRs that affect signed gates require re-review at the affected gate
- **progress-reporting skill:** Gate status reported in Section 2 (Schedule) of weekly reports
- **six-phase-lifecycle workflow:** Gates map to phase transitions in the lifecycle

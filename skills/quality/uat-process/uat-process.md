---
name: uat-process
description: "Runs a formal 受け入れテスト (User Acceptance Testing) process — creating UAT test plans, executing test cases, logging results, and producing a sign-off document. Use before final delivery of any feature or system, especially in Japanese outsourcing contexts requiring client acceptance sign-off."
version: "1.0.0"
category: "quality"
origin: "EM-Team (Japanese outsourcing)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "UAT"
  - "user acceptance test"
  - "受け入れテスト"
  - "acceptance testing"
  - "client sign-off"
  - "acceptance criteria verification"
  - "delivery acceptance"
intent: "Produce a formal UAT package: test plan, numbered test cases, execution log, defect log, and client acceptance sign-off — ensuring delivered functionality meets agreed requirements before final handoff."
scenarios:
  - "Pre-delivery testing in Japanese outsourcing where client acceptance is required"
  - "Feature release requiring formal sign-off from product owner or client"
  - "End-of-sprint acceptance for features with written acceptance criteria"
  - "System migration where the client must verify data integrity and functionality"
best_for: "Delivery sign-off, client acceptance, Japanese outsourcing, sprint acceptance, system migrations"
estimated_time: "4-8 hours per release"
anti_patterns:
  - "Treating UAT as a repeat of developer testing — UAT validates business requirements, not code quality"
  - "No written test cases — all UAT must have numbered, documented cases with expected results"
  - "Accepting delivery without client sign-off — the signature is the contract"
  - "Closing UAT defects without re-testing — every defect must have a verified fix"
related_skills:
  - e2e-testing
  - test-generation
  - spec-driven-development
  - code-review
---

# UAT Process (受け入れテスト)

## Overview

User Acceptance Testing (UAT / 受け入れテスト) is the final validation gate before delivery. It verifies that the delivered system meets the agreed business requirements, as understood by the client or product owner — not just as implemented by the development team.

UAT is **not** a second pass of developer testing. It validates:
1. **Functional completeness** — all agreed features work as specified
2. **Business rule compliance** — edge cases behave correctly per business requirements
3. **Non-functional acceptability** — performance, usability, and security are acceptable
4. **Data integrity** — data is correctly stored, displayed, and transformed

In Japanese outsourcing contexts, UAT produces a formal **受け入れテスト完了報告書** (UAT Completion Report) that the client signs, formally accepting the delivery.

## When to Use

- Before final delivery of a feature, sprint, or release to a client
- After a major bug fix or system migration
- When requirements documents include formal acceptance criteria
- Any time the client or product owner must formally accept the work

**When NOT to Use:** Internal development milestones where no client acceptance is needed; informal demos; purely technical refactors with no user-visible changes.

## Anti-Patterns

- Combining UAT and system testing — run them separately; UAT is the client's test, not the team's
- Verbal sign-off — always document sign-off in writing; verbal acceptance disputes are common
- Generic test cases — every test must link to a specific requirement (FR-001, FR-002)
- Accepting with known critical defects — UAT sign-off means "ready to go live," not "mostly ready"

## Process

### Phase 1: UAT Planning (受け入れテスト計画)

**Timing:** 1-2 days before UAT execution begins

Create `docs/uat/UAT-PLAN.md`:

```markdown
# UAT Test Plan (受け入れテスト計画書)
**Project:** [Project Name]
**Release:** [Version/Sprint]
**Test Period:** YYYY-MM-DD to YYYY-MM-DD
**Prepared by:** [Name]
**Date:** YYYY-MM-DD

## 1. Scope (テスト範囲)
### In Scope
- [Feature A: [brief description]]
- [Feature B: [brief description]]

### Out of Scope
- [Feature C: deferred to next release]
- [Performance testing: separate test plan]

## 2. Test Environment (テスト環境)
| Item | Value |
|---|---|
| Environment URL | https://staging.example.com |
| Database | Staging DB (copy of prod, anonymized) |
| External systems | Sandbox mode (Stripe, SendGrid) |
| Test accounts | See Appendix A |

## 3. Test Approach (テスト方針)
- Each test case links to a specific requirement (FR-ID or NFR-ID)
- Testers follow test steps exactly as written; deviations are noted
- Defects are logged with steps to reproduce, expected vs. actual
- Severity: Critical (blocks UAT) / High (must fix before delivery) / Medium (fix in next release) / Low

## 4. Schedule (スケジュール)
| Date | Activity | Participants |
|---|---|---|
| YYYY-MM-DD | Environment setup, test account creation | Dev team |
| YYYY-MM-DD | Test execution Day 1 | QA + Client tester |
| YYYY-MM-DD | Test execution Day 2 | QA + Client tester |
| YYYY-MM-DD | Defect review and fix | Dev team |
| YYYY-MM-DD | Re-test of defects | QA |
| YYYY-MM-DD | Sign-off | Client + PM |

## 5. Entry Criteria (UAT開始条件)
- [ ] All features in scope are deployed to staging
- [ ] System testing completed (no known Critical defects)
- [ ] Test data is prepared (accounts, seed data)
- [ ] Test cases reviewed and approved by client
- [ ] Environment access verified for all testers

## 6. Exit Criteria (UAT終了条件)
- [ ] All test cases executed (no blocked/untested)
- [ ] Zero Critical defects open
- [ ] All High defects resolved or risk-accepted by client
- [ ] Client sign-off obtained
```

---

### Phase 2: Test Case Design (テストケース設計)

Create `docs/uat/UAT-TEST-CASES.md`:

```markdown
# UAT Test Cases (受け入れテストケース一覧)
**Project:** [Project Name]
**Release:** [Version/Sprint]
**Requirement Source:** docs/REQUIREMENTS.md

---

## TC-001: [Test Case Name]
**Requirement:** FR-001 — [Requirement description]
**Priority:** [Critical / High / Medium]
**Pre-conditions:** [What must be true before this test runs]

| Step | Action | Expected Result |
|---|---|---|
| 1 | [Navigate to login page] | [Login page displayed with email and password fields] |
| 2 | [Enter valid email and password] | [Fields accept input] |
| 3 | [Click Login button] | [Redirected to dashboard; user name shown in header] |
| 4 | [Verify session persists on refresh] | [Refreshing page does not log out user] |

**Expected Final State:** User is logged in and session is active.

---

## TC-002: [Test Case Name — Error Case]
**Requirement:** FR-001 — [Login error handling]
**Priority:** High
**Pre-conditions:** User account exists with known password

| Step | Action | Expected Result |
|---|---|---|
| 1 | [Navigate to login page] | [Login page displayed] |
| 2 | [Enter valid email, wrong password] | [Fields accept input] |
| 3 | [Click Login button] | [Error message: "Invalid email or password"] |
| 4 | [Try 5 consecutive wrong passwords] | [Account locked message; lockout email sent] |

---

[Continue for all in-scope requirements...]
```

**Test case coverage requirement:**
```
For each requirement in REQUIREMENTS.md:
  - At least 1 happy path test case
  - At least 1 error/edge case test case
  - NFRs tested with specific measurement steps

Coverage matrix:
| Req ID | Test Case IDs | Coverage |
|--------|--------------|----------|
| FR-001 | TC-001, TC-002 | ✅ |
| FR-002 | TC-003 | ✅ |
| NFR-001 | TC-020 (perf test) | ✅ |
```

---

### Phase 3: Test Execution (テスト実施)

Create `docs/uat/UAT-EXECUTION-LOG.md`:

```markdown
# UAT Execution Log (受け入れテスト実施記録)
**Project:** [Project Name]
**Release:** [Version/Sprint]
**Execution Period:** YYYY-MM-DD to YYYY-MM-DD

## Execution Summary
| Metric | Count |
|---|---|
| Total test cases | [N] |
| Passed | [N] |
| Failed | [N] |
| Blocked | [N] |
| Not Executed | [N] |
| Pass Rate | [N]% |

## Test Results

| TC-ID | Test Case | Tester | Date | Result | Defect ID |
|---|---|---|---|---|---|
| TC-001 | [Name] | [Tester] | YYYY-MM-DD | PASS | — |
| TC-002 | [Name] | [Tester] | YYYY-MM-DD | FAIL | DEF-001 |
| TC-003 | [Name] | [Tester] | YYYY-MM-DD | BLOCKED | DEF-002 |
```

Results: **PASS** / **FAIL** / **BLOCKED** (blocked by another defect) / **SKIP** (out of scope, documented reason)

---

### Phase 4: Defect Management (不具合管理)

Create `docs/uat/UAT-DEFECT-LOG.md`:

```markdown
# UAT Defect Log (受け入れテスト不具合一覧)

## DEF-001: [Short defect title]
**Severity:** Critical | High | Medium | Low
**Status:** Open | In Progress | Fixed | Verified | Closed | Deferred
**Test Case:** TC-002
**Found by:** [Tester name]
**Found on:** YYYY-MM-DD
**Assigned to:** [Developer]
**Target fix date:** YYYY-MM-DD

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Observe defect]

**Expected Result:** [What should happen]
**Actual Result:** [What actually happens]
**Screenshot/Evidence:** [link or filename]

**Fix Description:** [Developer fills in after fixing]
**Fix Date:** YYYY-MM-DD
**Re-test by:** [Tester]
**Re-test Date:** YYYY-MM-DD
**Re-test Result:** PASS / FAIL
```

---

### Phase 5: UAT Sign-Off (受け入れ完了)

Create `docs/uat/UAT-SIGNOFF.md`:

```markdown
# UAT Acceptance Sign-Off (受け入れテスト完了報告書)
**Project:** [Project Name]
**Release:** [Version/Sprint]
**Date:** YYYY-MM-DD

## Test Summary
| Item | Result |
|---|---|
| Test period | YYYY-MM-DD to YYYY-MM-DD |
| Total test cases | [N] |
| Passed | [N] ([N]%) |
| Failed | [N] |
| Critical defects | 0 (required for sign-off) |
| Open High defects | [N] (client acknowledged) |
| Open Medium/Low defects | [N] (accepted as known issues) |

## Scope Delivered
- ✅ [Feature A]: Fully tested and accepted
- ✅ [Feature B]: Fully tested and accepted
- ⚠️ [Feature C]: Accepted with known issue DEF-003 (deferred to v1.1)

## Known Issues Accepted
| Defect ID | Description | Severity | Planned Fix |
|---|---|---|---|
| DEF-003 | [Description] | Medium | v1.1 (YYYY-MM-DD) |

## Client Acceptance Statement
By signing below, the client confirms that the delivered system meets the agreed acceptance criteria
as defined in the Requirements Document and UAT Test Plan, subject to the known issues listed above.

| Role | Name | Signature | Date |
|---|---|---|---|
| Client Representative | | | |
| Project Manager | | | |
| QA Lead | | | |

## Delivery Package Confirmed
- [ ] Source code delivered (or deployed to agreed environment)
- [ ] Test results included in delivery package
- [ ] Known issues documented
- [ ] Release notes provided
- [ ] Support handoff completed (if applicable)
```

---

## UAT Decision Gate

```
UAT COMPLETION DECISION:

PASS (proceed to delivery) if:
  ✅ All test cases executed
  ✅ Zero Critical defects open
  ✅ Zero High defects open (or client has risk-accepted in writing)
  ✅ Client sign-off obtained

CONDITIONAL PASS if:
  ⚠️ Medium/Low defects open with client acknowledgment
  ⚠️ Minor scope items deferred with client sign-off

FAIL (cannot deliver) if:
  ❌ Critical defect open
  ❌ Test case execution < 95% (significant gaps in coverage)
  ❌ Client refuses to sign off
```

## Coaching Notes

> **ABC - Always Be Coaching:**

1. **UAT is the client's test, not the team's.** The team verifying their own work is not UAT. Involve the client or a representative who did not write the code. This is the last opportunity to discover that "what was built" and "what was wanted" diverged.

2. **Written test cases protect both sides.** If a client later claims "this doesn't work," the execution log shows whether that test case passed. Without written records, disputes are settled by whoever argues most convincingly.

3. **Defect severity must be agreed upfront.** "Critical" means "cannot deliver without fixing." Define this before UAT starts, not during it, or you'll have arguments at the worst possible time.

4. **The sign-off document has legal weight.** In Japanese outsourcing contracts, the 受け入れテスト完了報告書 is often contractually required before payment is released. Treat it accordingly.

## Verification

Before declaring UAT complete:

- [ ] UAT Plan created and reviewed by client before execution
- [ ] Test cases cover all in-scope requirements (at least 1 happy path + 1 error case per requirement)
- [ ] Execution log records result for every test case
- [ ] All defects logged with steps to reproduce, expected vs. actual
- [ ] No Critical defects open at sign-off time
- [ ] Sign-off document signed by client representative and PM
- [ ] All UAT documents saved to `docs/uat/` and committed

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

After completing this skill, export the UAT package to:
`reviews/YYYY-MM-DD-HHMM-uat-<release>.md`

Include: test summary, pass/fail counts, open defects, sign-off status.

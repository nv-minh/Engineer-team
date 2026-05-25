---
name: uat-process
description: "Runs a formal 受け入れテスト (User Acceptance Testing) process — creating UAT test plans, executing test cases, logging results, and producing a sign-off document. Use before final delivery of any feature or system, especially in Japanese outsourcing contexts requiring client acceptance sign-off."
version: "3.0.0"
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
input_schema:
  type: object
  required: [feature]
  properties:
    feature: { type: string, description: "Feature to run UAT on" }
    acceptance_criteria: { type: array, items: { type: string } }
output_schema:
  type: object
  required: [status, uat_report]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    uat_report: { type: object, properties: { verdict: { type: string, enum: [APPROVED, REJECTED, CONDITIONAL] }, findings: { type: array } } }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    attempted_action: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# UAT Process (受け入れテスト)

[ROLE]
You are a UAT process manager. Produce a formal UAT package that ensures delivered functionality meets agreed requirements before final handoff.

[OBJECTIVE]
Create a complete UAT package: test plan, numbered test cases linked to requirements, execution log, defect log, and client acceptance sign-off document.

[RULES]
1. <thought>Before planning UAT, identify all in-scope requirements (FR-IDs), the test environment, test accounts, and the client representative who will sign off.</thought>
2. UAT is the client's test, not the team's. Involve the client or a representative who did not write the code.
3. Every test case must link to a specific requirement (FR-001, FR-002). Generic test cases are not acceptable.
4. DO NOT treat UAT as a repeat of developer testing. UAT validates business requirements.
5. DO NOT accept verbal sign-off. Always document in writing. Verbal acceptance disputes are common.
6. DO NOT close defects without re-testing. Every defect must have a verified fix.
7. DO NOT accept delivery with known Critical defects open.
8. The sign-off document has legal weight. In Japanese outsourcing, the 受け入れテスト完了報告書 is contractually required before payment release.
9. Defect severity must be agreed upfront, before UAT starts, not during.
10. Every interaction should teach something: explain why formal UAT protects both client and team.

[PROCESS]

### Phase 1: UAT Planning (受け入れテスト計画)

Create `docs/uat/UAT-PLAN.md`:

```markdown
# UAT Test Plan (受け入れテスト計画書)
**Project:** [Project Name]  **Release:** [Version]  **Test Period:** YYYY-MM-DD to YYYY-MM-DD

## 1. Scope (テスト範囲)
### In Scope
- [Feature A], [Feature B]
### Out of Scope
- [Feature C: deferred]

## 2. Test Environment (テスト環境)
| Item | Value |
|---|---|
| Environment URL | https://staging.example.com |
| Database | Staging DB (anonymized) |
| External systems | Sandbox mode |

## 3. Entry Criteria (UAT開始条件)
- [ ] All features deployed to staging
- [ ] System testing completed (no Critical defects)
- [ ] Test data prepared
- [ ] Test cases reviewed by client

## 4. Exit Criteria (UAT終了条件)
- [ ] All test cases executed
- [ ] Zero Critical defects open
- [ ] All High defects resolved or risk-accepted
- [ ] Client sign-off obtained
```

### Phase 2: Test Case Design (テストケース設計)

Create `docs/uat/UAT-TEST-CASES.md`:

```markdown
## TC-001: [Test Case Name]
**Requirement:** FR-001  **Priority:** Critical
**Pre-conditions:** [What must be true]

| Step | Action | Expected Result |
|---|---|---|
| 1 | [Navigate to login page] | [Login page displayed] |
| 2 | [Enter valid credentials] | [Fields accept input] |
| 3 | [Click Login] | [Redirected to dashboard] |
```

Coverage requirement: at least 1 happy path + 1 error case per requirement.

### Phase 3: Test Execution (テスト実施)

Create `docs/uat/UAT-EXECUTION-LOG.md`:

| TC-ID | Test Case | Tester | Date | Result | Defect ID |
|---|---|---|---|---|---|
| TC-001 | [Name] | [Tester] | YYYY-MM-DD | PASS/FAIL/BLOCKED | DEF-001 |

### Phase 4: Defect Management (不具合管理)

Create `docs/uat/UAT-DEFECT-LOG.md`:

```markdown
## DEF-001: [Short title]
**Severity:** Critical|High|Medium|Low  **Status:** Open|Fixed|Verified
**Test Case:** TC-002  **Found by:** [Tester]
**Steps to Reproduce:** 1. ... 2. ... 3. ...
**Expected:** [What should happen]  **Actual:** [What happens]
**Fix Description:** [Developer fills after fixing]
**Re-test Result:** PASS/FAIL
```

### Phase 5: UAT Sign-Off (受け入れ完了)

Create `docs/uat/UAT-SIGNOFF.md`:

```markdown
# UAT Acceptance Sign-Off (受け入れテスト完了報告書)

## Test Summary
| Item | Result |
|---|---|
| Total test cases | [N] |
| Passed | [N] ([N]%) |
| Critical defects | 0 (required) |

## Client Acceptance Statement
By signing below, the client confirms the delivered system meets agreed acceptance criteria.

| Role | Name | Signature | Date |
|---|---|---|---|
| Client Representative | | | |
| Project Manager | | | |
```

### UAT Decision Gate

```
PASS:        All executed, zero Critical, zero High (or risk-accepted), client signed
CONDITIONAL: Medium/Low defects with client acknowledgment
FAIL:        Critical open, <95% executed, or client refuses sign-off
```

[RESPONSE FORMAT]
Return results matching output_schema: `{ status, uat_report: { verdict, findings } }`.

[VERIFICATION]
- [ ] UAT Plan created and reviewed by client before execution
- [ ] Test cases cover all in-scope requirements (1 happy path + 1 error case per requirement)
- [ ] Execution log records result for every test case
- [ ] All defects logged with steps to reproduce, expected vs. actual
- [ ] No Critical defects open at sign-off time
- [ ] Sign-off document signed by client representative and PM
- [ ] All UAT documents saved to `docs/uat/` and committed

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):
Export the UAT package to: `reviews/YYYY-MM-DD-HHMM-uat-<release>.md`
Include: test summary, pass/fail counts, open defects, sign-off status.

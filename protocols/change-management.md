# Change Management Protocol (変更管理プロトコル)

**Protocol for managing scope changes, requirement updates, and design amendments in outsourcing projects — ensuring every change is tracked, assessed, approved, and communicated.**

---

## Core Principle

**No change is implemented without a Change Request (CR) that is approved in writing.**

Untracked changes are the primary cause of scope creep, budget overruns, and client disputes in outsourcing projects. Every change — regardless of how small it seems — must go through this protocol.

```yaml
change_management_mandate:
  rule: "All changes to requirements, scope, or design require a CR"
  minimum: "Even verbal requests require a written CR before work begins"
  exceptions: "Bug fixes within existing acceptance criteria do NOT need a CR"
```

---

## What Constitutes a Change

**Requires a Change Request (CR):**
- Adding functionality not in the original specification
- Changing the behavior of existing functionality
- Modifying database schema beyond what specs define
- Changing API contracts (endpoints, request/response format)
- Altering non-functional requirements (performance targets, uptime SLA)
- Changing the delivery timeline or milestone dates
- Scope reduction (cutting features)

**Does NOT require a CR (bug fixes):**
- Fixing behavior that diverges from the approved specification
- Fixing defects found in testing (if the spec defined the correct behavior)
- Security patches for vulnerabilities (follows security escalation path)

**Gray area rule:** If uncertain, create a CR. The overhead of a CR is 30 minutes; the overhead of an unauthorized change dispute is 30 days.

---

## Change Request Process

### Step 1: CR Submission

Anyone can submit a CR. Use the CR template (below) and assign a sequential ID:
- Format: `CHG-YYYYMM-NNN` (e.g., CHG-202601-001)
- Submit via: [agreed channel — email, ticketing system, or `docs/changes/CHG-*.md`]

**Change Request Template:**

```markdown
# Change Request: CHG-[YYYYMM-NNN]
**Submitted by:** [Name, Role]
**Submitted on:** YYYY-MM-DD
**Project:** [Project Name]
**Status:** Submitted | Under Review | Approved | Rejected | Deferred

---

## 1. Change Description (変更内容)
[Clear description of what is being requested. What should be different after this change?]

## 2. Reason for Change (変更理由)
[Why is this change needed? Business need, client request, regulatory requirement?]

## 3. Current State (現状)
[What exists now / what was agreed in the original spec]

## 4. Proposed State (変更後)
[What will exist after this change is implemented]

## 5. Impact Analysis (影響範囲分析)

### 5.1 Technical Impact
| Area | Impact | Affected Files/Modules |
|---|---|---|
| Backend | [None/Minor/Major] | [list] |
| Frontend | [None/Minor/Major] | [list] |
| Database | [None/Minor/Major] | [list] |
| APIs | [None/Minor/Major] | [list] |
| Tests | [None/Minor/Major] | [list] |
| Documentation | [None/Minor/Major] | [list] |

### 5.2 Effort Estimate
| Task | Effort (hours) | Assignee |
|---|---|---|
| [Implementation task 1] | [N] | [Name] |
| [Testing task] | [N] | [Name] |
| [Documentation update] | [N] | [Name] |
| **Total** | **[N]** | |

### 5.3 Schedule Impact
- Additional effort: [N] hours / [N] days
- Impact on delivery date: [None / +N days]
- Milestones affected: [list]

### 5.4 Risk Assessment
- Risk if approved: [e.g., regression risk in related modules]
- Risk if rejected: [e.g., client dissatisfaction, workaround needed]

## 6. Alternatives Considered (代替案)
| Alternative | Pros | Cons |
|---|---|---|
| [Option A: do nothing] | [No cost, no delay] | [Client request unmet] |
| [Option B: partial change] | [Lower cost] | [Partial solution] |
| [Proposed change] | [Full solution] | [Cost and timeline impact] |

## 7. Rollback Plan (ロールバック計画)
[If the change causes problems, how can it be reverted?]

---

## 8. Approval (承認)

| Role | Name | Decision | Date | Notes |
|---|---|---|---|---|
| Tech Lead | | Approve / Reject / Defer | | |
| Project Manager | | Approve / Reject / Defer | | |
| Client Representative | | Approve / Reject / Defer | | |

**Final Decision:** Approved / Rejected / Deferred
**If Approved:** Implementation target date: YYYY-MM-DD
**If Rejected:** Reason: [explanation]
**If Deferred:** Review date: YYYY-MM-DD
```

---

### Step 2: Impact Assessment

Before routing for approval, the Tech Lead must complete the impact analysis (Section 5):

```
Impact Assessment Checklist:
□ All affected modules identified
□ Effort estimate includes: implementation + testing + documentation
□ Schedule impact quantified in days (not "some delay")
□ Dependencies on other features/changes noted
□ Rollback plan defined
□ Cost impact calculated (if on time-and-materials contract)
```

**Effort estimation guidelines:**
- Small change (< 4h): Single function/component, no schema change
- Medium change (4-16h): Multiple functions, minor schema change, test updates
- Large change (16-40h): Multiple modules, schema migration, significant testing
- Major change (> 40h): Consider whether this is actually a new sub-project

---

### Step 3: Approval Routing

Route the CR to approvers based on impact level:

| Impact Level | Effort | Approval Required |
|---|---|---|
| Minor | < 4 hours | Tech Lead only |
| Small | 4-16 hours | Tech Lead + PM |
| Medium | 16-40 hours | Tech Lead + PM + Client |
| Large | > 40 hours | Tech Lead + PM + Client + Executive Sponsor |

**Timeline for approval:**
- Client provides decision within 3 business days of CR submission
- If no response after 3 days: PM escalates; work on affected feature pauses
- Emergency changes (security patches): 24-hour approval cycle

---

### Step 4: Implementation

After approval:

```
Pre-implementation checklist:
□ CR status updated to "Approved" with date
□ CR linked to implementation task/ticket
□ Spec/design documents updated to reflect the change
□ Team notified of scope change
□ Test cases updated (or new cases added) to cover the change
□ Updated timeline communicated to client
```

Implementation must reference the CR ID in:
- Git commit message: `feat: [description] (CHG-202601-001)`
- PR description: Link to CR document
- Test case IDs: `TC-CR001-001` (test for change request)

---

### Step 5: Closure

After the change is implemented and tested:

```
CR closure checklist:
□ Implementation complete and deployed to staging
□ Tests passing (including tests added for this change)
□ Documentation updated (spec, API docs, user guide)
□ Client informed and change demonstrated (if UI-visible)
□ CR status updated to "Closed"
□ CHANGE-LOG.md updated
```

---

## Change Log

Maintain `docs/changes/CHANGE-LOG.md` (template in `templates/context-artifacts/CHANGE-LOG.md`).

The Change Log is a single-file summary of all CRs. Individual CR details live in `docs/changes/CHG-*.md`.

---

## Emergency Change Protocol

For security vulnerabilities or critical production issues requiring immediate action:

```
Emergency Change Process:
1. Tech Lead and PM authorize verbally (document immediately after)
2. Implement the minimum viable fix
3. Create retroactive CR within 24 hours documenting what was changed
4. Complete formal review within 3 business days
5. Client notified same day (for any client-visible changes)
```

---

## Integration with Other Processes

- **git-workflow skill:** Every CR gets its own branch: `chg/CHG-202601-001-description`
- **progress-reporting skill:** All open CRs appear in Section 9 of weekly reports
- **basic-design skill:** CR that changes system architecture requires Basic Design amendment
- **uat-process skill:** Approved CRs that affect UAT scope require UAT test case updates
- **review-gates protocol:** CRs that affect signed-off design require re-review at the affected gate

---

## Common Change Management Anti-Patterns

| Anti-Pattern | Why It's Harmful | Correct Approach |
|---|---|---|
| "It's just a small change, let's just do it" | Small undocumented changes accumulate into untracked scope creep | All changes require a CR, regardless of size |
| Implementing before approval | Creates unauthorized work that client may refuse to pay for | Wait for written approval before starting |
| Verbal approval only | "I never said that" — disputes are inevitable | Approval must be in writing (email is acceptable) |
| Scope creep in bug fixes | Fixing "a little more than specified" is scope creep | Bug fixes only correct spec-defined behavior |
| One CR for multiple changes | Impact analysis becomes meaningless | One CR per logical change |

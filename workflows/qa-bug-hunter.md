---
name: qa-bug-hunter
description: "QA testing workflow that discovers bugs, collects evidence, drafts GitHub issues, and creates them only after human approval. Prevents false positives by requiring human verification at HUMAN GATE before each issue is logged."
version: "1.0.0"
category: "primary"
origin: "EM-Team"
react_protocol: true
context_pruning: true
max_retries_per_stage: 3
agents_used: []
skills_used:
  - qa
  - flow-discovery
  - browser-testing
  - github-issue-manager
related_skills:
  - e2e-testing
  - test-generation
  - systematic-debugging
estimated_time: "1-3 hours"
input_schema:
  type: object
  required: [target_url]
  properties:
    target_url:
      type: string
      description: "URL of the application to QA test (e.g., http://localhost:5173)"
    feature_scope:
      type: string
      default: "full"
      description: "Specific feature or page to focus on (e.g., '/projects', 'allocation grid', 'full')"
    qa_mode:
      type: string
      enum: [full, critical, smoke, targeted]
      default: full
      description: "QA depth: full (all checks), critical (critical paths only), smoke (basic), targeted (specific feature)"
    spec_id:
      type: string
      description: "Optional SPEC-ID for evidence folder. Auto-generated as QA-YYYY-MM-DD if omitted."
    labels:
      type: array
      items: { type: string }
      default: ["bug", "qa-found"]
      description: "Default labels to apply to created issues"
output_schema:
  type: object
  required: [status, summary]
  properties:
    status:
      type: string
      enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED]
    summary:
      type: object
      required: [bugs_found, bugs_approved, bugs_rejected, issues_created]
      properties:
        bugs_found: { type: integer }
        bugs_approved: { type: integer }
        bugs_rejected: { type: integer }
        bugs_modified: { type: integer }
        issues_created:
          type: array
          items:
            type: object
            properties:
              title: { type: string }
              issue_url: { type: string }
              severity: { type: string }
        issues_skipped:
          type: array
          items:
            type: object
            properties:
              title: { type: string }
              reason: { type: string }
    evidence_directory: { type: string }
    qa_report_path: { type: string }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# QA Bug Hunter Workflow (Hermes ReAct Protocol)

## Lifecycle

```
SETUP ──→ DISCOVER ──→ [per bug: EVIDENCE → PREPARE → HUMAN GATE → LOG] ──→ SUMMARY
 (0)        (1)             (2)       (3)        (4)          (5)           (6)
  │          │                │         │          │            │             │
  ▼          ▼                ▼         ▼          ▼            ▼             ▼
GATE 0    GATE 1           GATE 2    GATE 3   USER DECISION  GATE 5       DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Gate |
|---|---|---|
| SETUP (Stage 0) | DEFINE | URL accessible, evidence dir created, gh authenticated |
| DISCOVER (Stage 1) | DEFINE | QA completed, bug candidate list produced |
| EVIDENCE (Stage 2, per bug) | VERIFY | Screenshots, console errors, network failures captured |
| PREPARE (Stage 3, per bug) | REVIEW | Draft issue body complete, NOT created yet |
| HUMAN GATE (Stage 4, per bug) | REVIEW (human) | User decision: APPROVE / REJECT / MODIFY |
| LOG (Stage 5, per bug) | SHIP | GitHub issue created or rejection logged |
| SUMMARY (Stage 6) | SHIP | Final report generated with all results |

---

## Stage 0: SETUP

<thought>
Observe: QA bug hunting workflow initiated. No evidence directory, no validation of target URL, no check on gh CLI auth.
Analyze: Must validate the target URL is accessible, create evidence directory, verify GitHub CLI is authenticated, and detect the repo from git remote. Gate requires: URL accessible, evidence dir exists, gh authenticated.
Plan: Validate URL → detect github repo → create evidence dir → verify gh auth.
</thought>

<action>
type: setup
tasks:
  1. validate_target_url:
     - curl or fetch {target_url} to verify it's accessible
     - if not accessible → report BLOCKED with suggestion to start dev server
  2. detect_github_repo:
     - if not provided: parse from `git remote -v` (origin)
     - verify repo exists: `gh repo view {repo} --json name`
  3. determine_spec_id:
     - if provided in input → use as-is
     - else → generate: QA-{YYYY-MM-DD} (e.g., QA-2026-05-24)
  4. create_evidence_directory:
     - mkdir -p tests/FE-test/{spec_id}/evidence/
  5. verify_gh_auth:
     - `gh auth status`
     - if not authenticated → report BLOCKED with suggestion to run `gh auth login`
</action>

<observation>
result: target URL accessible, evidence directory created, gh CLI authenticated, repo detected
state_change: workspace ready for QA testing
gate_status: PASS | FAIL
</observation>

**Gate 0 — SETUP Complete:**
- [ ] Target URL is accessible
- [ ] GitHub repo detected or provided
- [ ] SPEC-ID determined
- [ ] Evidence directory created at `tests/FE-test/{spec_id}/evidence/`
- [ ] `gh` CLI is authenticated

PASS → Stage 1 | FAIL → report BLOCKED with specific error

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  stage_completed: setup
  artifacts:
    - target_url
    - github_repo
    - spec_id
    - evidence_directory
  next_action: "discover"
```

---

## Stage 1: DISCOVER

<thought>
Observe: Workspace ready. No QA testing done yet, no bug list.
Analyze: Must run QA testing on the target URL using the specified mode/scope. For targeted mode, discover user flows first, then QA each flow. Compile a bug candidate list with severity classifications. Gate requires: QA completed, bug list produced.
Plan: If targeted mode → invoke flow-discovery first. Then invoke em:qa with scope. Compile bug candidates. If zero bugs → short-circuit to SUMMARY.
</thought>

<action>
type: invoke_skills
tasks:
  1. flow_discovery_if_targeted:
     - condition: qa_mode == "targeted"
     - invoke: flow-discovery
     - params:
         codebase_path: {cwd}
         focus_area: {feature_scope}
     - output: discovered flows with steps
  2. run_qa_testing:
     - invoke: qa
     - params:
         target: {target_url}
         scope: {qa_mode}
         focus: {feature_scope}
     - checks:
         - critical_user_paths: auth, CRUD, navigation within scope
         - console_errors: JavaScript errors, unhandled rejections
         - network_failures: failed API calls, 4xx/5xx responses
         - performance: page load < 3s, TTI < 5s
         - responsive: mobile (375px), tablet (768px), desktop (1280px)
         - accessibility: ARIA labels, keyboard navigation, contrast
         - visual: typography, colors, spacing, alignment
  3. compile_bug_list:
     - for each issue found:
         - assign initial severity:
             P0: app crash, data loss, security vulnerability
             P1: feature broken, blocking user flow
             P2: degraded UX, slow performance, layout issues
             P3: cosmetic, typo, minor visual inconsistency
         - record: title, severity, area, initial reproduction notes
     - sort by severity (P0 first)
  4. check_zero_bugs:
     - if bug_list is empty → skip to Stage 6 (SUMMARY) with clean-pass report
</action>

<observation>
result: QA testing completed, {N} bug candidates found and classified
state_change: bug candidate list ready for per-bug processing
gate_status: PASS | FAIL
</observation>

**Gate 1 — DISCOVER Complete:**
- [ ] QA testing completed for specified scope
- [ ] Bug candidate list compiled with severity classifications
- [ ] If zero bugs: clean-pass report ready

PASS → Stage 2 (first bug) or Stage 6 (if zero bugs) | FAIL → retry QA (max 3)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  stage_completed: discover
  artifacts:
    - bug_candidate_list
    - qa_raw_results
  bug_count: {N}
  current_bug_index: 0
  next_action: "evidence (bug #1)" or "summary (clean pass)"
```

---

## Stage 2: EVIDENCE (per bug)

<thought>
Observe: Bug #{current_bug_index} identified in DISCOVER. No evidence collected yet — no screenshots, no console logs, no network capture.
Analyze: Must reproduce the bug in a browser, capture screenshot at the failure point, collect console errors and network failures. Evidence must be stored in the designated evidence directory. Gate requires: evidence files exist for this bug.
Plan: Invoke browser-testing skill to reproduce and capture evidence for this specific bug.
</thought>

<action>
type: invoke_skill
target: browser-testing
params:
  target_url: {target_url}{bug_path}
  test_scenarios:
    - name: "Reproduce bug #{current_bug_index}: {bug_title}"
      steps: {bug_reproduction_steps}
  evidence_config:
    screenshot: "only-on-failure"
    video: "retain-on-failure"
    trace: "retain-on-failure"
  output_directory: tests/FE-test/{spec_id}/evidence/
  file_naming:
    screenshot: "{spec_id}-QA-{current_bug_index}-{short_desc}.png"
    console: "{spec_id}-QA-{current_bug_index}-console-errors.txt"
    network: "{spec_id}-QA-{current_bug_index}-network-errors.txt"
</action>

<observation>
result: Bug reproduced, evidence captured (screenshot, console errors, network failures)
evidence_files:
  - tests/FE-test/{spec_id}/evidence/{spec_id}-QA-{N}-{desc}.png
  - tests/FE-test/{spec_id}/evidence/{spec_id}-QA-{N}-console-errors.txt (if any)
  - tests/FE-test/{spec_id}/evidence/{spec_id}-QA-{N}-network-errors.txt (if any)
state_change: evidence collected for bug #{current_bug_index}
gate_status: PASS | FAIL
</observation>

**Gate 2 — EVIDENCE Complete (bug #{N}):**
- [ ] Bug reproduced in browser
- [ ] Screenshot captured at failure point
- [ ] Console errors captured (if any)
- [ ] Network failures captured (if any)
- [ ] Evidence files stored in `tests/FE-test/{spec_id}/evidence/`

PASS → Stage 3 | FAIL → retry evidence collection (max 3)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: VERIFY
  stage_completed: evidence
  current_bug_index: {N}
  artifacts:
    - evidence_files_for_bug_N
  next_action: "prepare (bug #{N})"
```

---

## Stage 3: PREPARE (per bug)

<thought>
Observe: Evidence collected for bug #{current_bug_index}. No draft issue created yet.
Analyze: Must format a complete GitHub issue body using the bug report template. Assign final severity, compose steps to reproduce, expected vs actual, attach evidence paths. DO NOT create the issue — only prepare the draft. Gate requires: draft issue body is complete and well-formed.
Plan: Format the draft using the bug issue template. Review for completeness. Store draft in memory for HUMAN GATE presentation.
</thought>

<action>
type: format_issue_draft
tasks:
  1. compose_title:
     - format: "[{severity}] {concise bug description}"
     - example: "[P1] Allocation grid fails to load when project has no assigned resources"
  2. assign_severity:
     - P0: app crash, data loss, security vulnerability
     - P1: feature broken, blocking user flow
     - P2: degraded UX, slow performance, layout issues
     - P3: cosmetic, typo, minor visual inconsistency
  3. format_issue_body:
     - use template:
       ```markdown
       ## Bug: {title}

       **Severity:** {P0|P1|P2|P3}
       **Found by:** QA Bug Hunter (automated QA)
       **Feature area:** {feature_scope}
       **URL:** {target_url}{path}

       ### Steps to Reproduce

       1. Navigate to {url}
       2. {step}
       3. {step}

       ### Expected Behavior

       {expected}

       ### Actual Behavior

       {actual}

       ### Evidence

       | Type | Path |
       |---|---|
       | Screenshot | `tests/FE-test/{spec_id}/evidence/{filename}.png` |
       | Console errors | `tests/FE-test/{spec_id}/evidence/{filename}.txt` |

       ### Environment

       - Browser: Chromium (headless)
       - Viewport: {viewport}
       - Timestamp: {ISO timestamp}
       ```
  4. assign_labels:
     - base labels from input (default: ["bug", "qa-found"])
     - add severity label: "P0", "P1", "P2", or "P3"
     - add area label if applicable (e.g., "frontend", "api")
  5. DO_NOT_CREATE:
     - ⛔ DO NOT run `gh issue create` at this stage
     - Store the draft for presentation at HUMAN GATE
</action>

<observation>
result: Draft issue composed with title, body, and labels
state_change: draft ready for human review
gate_status: PASS | FAIL
</observation>

**Gate 3 — PREPARE Complete (bug #{N}):**
- [ ] Title follows format: `[{severity}] {description}`
- [ ] Steps to reproduce are specific and numbered
- [ ] Expected vs actual behavior documented
- [ ] Evidence paths reference real files
- [ ] Labels assigned (bug, qa-found, severity)
- [ ] ⛔ Issue NOT created yet

PASS → Stage 4 | FAIL → retry formatting

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REVIEW
  stage_completed: prepare
  current_bug_index: {N}
  artifacts:
    - draft_issue_title
    - draft_issue_body
    - draft_issue_labels
  next_action: "human_gate (bug #{N})"
```

---

## Stage 4: HUMAN GATE (per bug)

<thought>
Observe: Draft issue for bug #{current_bug_index} is ready. Human has not reviewed it yet.
Analyze: MUST present the draft to the user and wait for their decision before proceeding. The user can APPROVE (create as-is), REJECT (skip, not a real bug), or MODIFY (edit before creating). This gate enforces User Sovereignty — AI recommends, human decides.
Plan: Present the formatted bug report. Wait for user response. Record the decision.
</thought>

<action>
type: ask_user
presentation_format: |
  ━━━ BUG #{current_bug_index} of {total_bugs} ━━━

  **Title:**    {draft_title}
  **Severity:** {severity}
  **Area:**     {feature_area}

  **Steps to Reproduce:**
    1. {step_1}
    2. {step_2}
    3. {step_3}

  **Expected:** {expected_behavior}
  **Actual:**   {actual_behavior}

  **Evidence:**
    - Screenshot: tests/FE-test/{spec_id}/evidence/{screenshot_filename}
    - Console: {console_errors_summary_or_none}

  ━━━ YOUR DECISION ━━━
    (A) APPROVE — Create this issue as-is on GitHub
    (B) REJECT  — Not a real bug (please explain why)
    (M) MODIFY  — I want to edit before creating

decision_handling:
  APPROVE:
    - record decision: approved
    - proceed to Stage 5 with original draft
  REJECT:
    - record decision: rejected
    - record reason: {user_reason}
    - skip Stage 5, proceed to next bug (Stage 2) or Stage 6 (if last bug)
  MODIFY:
    - ask user: "What would you like to change? (title, severity, description, steps, labels)"
    - incorporate user edits into draft
    - re-present updated draft for final confirmation (APPROVE or REJECT only)
    - record decision: modified
    - proceed to Stage 5 with updated draft
</action>

<observation>
result: User decision recorded — {APPROVE|REJECT|MODIFY}
state_change: human verification complete for bug #{current_bug_index}
gate_status: PASS (always — user decision is the gate)
</observation>

**Gate 4 — HUMAN GATE Complete (bug #{N}):**
- [ ] Draft presented to user in full
- [ ] User decision recorded (APPROVE / REJECT / MODIFY)
- [ ] If MODIFY: edits incorporated and final confirmation received
- [ ] If REJECT: reason recorded

APPROVE/MODIFY → Stage 5 | REJECT → next bug (Stage 2) or Stage 6

**State Snapshot:**
```yaml
workflow_state:
  current_phase: REVIEW
  stage_completed: human_gate
  current_bug_index: {N}
  decision: {APPROVE|REJECT|MODIFY}
  artifacts:
    - final_issue_draft (if approved/modified)
    - rejection_reason (if rejected)
  next_action: "log (bug #{N})" or "evidence (bug #{N+1})" or "summary"
```

---

## Stage 5: LOG (per bug)

<thought>
Observe: Human approved (or modified) bug #{current_bug_index}. Issue draft is finalized. Not yet created on GitHub.
Analyze: Create the GitHub issue using `gh issue create`. Record the issue URL. Gate requires: issue created successfully with correct title, body, and labels.
Plan: Run gh issue create → capture URL → record in results → proceed to next bug or summary.
</thought>

<action>
type: invoke_skill
target: github-issue-manager
params:
  action: issue-create
  title: "{final_draft_title}"
  body: "{final_draft_body}"
  labels: "{final_labels_comma_separated}"
command: |
  gh issue create \
    --title "{final_draft_title}" \
    --body "{final_draft_body}" \
    --label "{label1},{label2},{label3}"
capture: issue_url
</action>

<observation>
result: GitHub issue created at {issue_url}
state_change: bug #{current_bug_index} logged as GitHub issue
gate_status: PASS | FAIL
</observation>

**Gate 5 — LOG Complete (bug #{N}):**
- [ ] GitHub issue created successfully
- [ ] Issue URL captured and recorded
- [ ] Labels applied correctly

PASS → next bug (Stage 2) or Stage 6 (if last bug) | FAIL → retry `gh issue create` (max 3)

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SHIP
  stage_completed: log
  current_bug_index: {N}
  artifacts:
    - issue_url
  bugs_processed: {N}
  bugs_remaining: {total - N}
  next_action: "evidence (bug #{N+1})" or "summary"
```

---

## Per-Bug Loop Control

After Stage 5 (or after REJECT in Stage 4), check:

```yaml
loop_control:
  if: current_bug_index < total_bugs
  then: return to Stage 2 with next bug (current_bug_index += 1)
  else: proceed to Stage 6 (SUMMARY)
```

---

## Stage 6: SUMMARY

<thought>
Observe: All bugs have been processed through the per-bug loop (or zero bugs were found). Need to generate a final report.
Analyze: Compile all results — bugs found, approved, rejected, modified, issue URLs, evidence paths. Generate QA-BUG-HUNTER-REPORT.md in the evidence directory. Output must match output_schema.
Plan: Generate report → write to file → output final summary.
</thought>

<action>
type: generate_report
tasks:
  1. compile_results:
     - total bugs found
     - bugs approved (with issue URLs)
     - bugs rejected (with reasons)
     - bugs modified (with issue URLs)
  2. write_report:
     - path: tests/FE-test/{spec_id}/QA-BUG-HUNTER-REPORT.md
     - template:
       ```markdown
       # QA Bug Hunter Report

       **Date:** {ISO date}
       **Target:** {target_url}
       **Scope:** {feature_scope}
       **Mode:** {qa_mode}
       **SPEC-ID:** {spec_id}

       ## Summary

       | Metric | Count |
       |---|---|
       | Bugs found | {bugs_found} |
       | Approved (issues created) | {bugs_approved} |
       | Modified (issues created) | {bugs_modified} |
       | Rejected (skipped) | {bugs_rejected} |

       ## Issues Created

       | # | Title | Severity | GitHub Issue |
       |---|---|---|---|
       | 1 | {title} | {severity} | {issue_url} |

       ## Issues Rejected

       | # | Title | Severity | Reason |
       |---|---|---|---|
       | 1 | {title} | {severity} | {rejection_reason} |

       ## Evidence Directory

       `tests/FE-test/{spec_id}/evidence/`

       ## QA Checks Performed

       - [x] Critical user paths
       - [x] Console errors
       - [x] Network failures
       - [x] Performance
       - [x] Responsive design
       - [x] Accessibility
       - [x] Visual consistency
       ```
  3. output_summary:
     - match output_schema format
     - status: DONE (if all bugs processed) or DONE_WITH_CONCERNS (if any FAIL retries)
</action>

<observation>
result: QA Bug Hunter report generated, all bugs processed
state_change: workflow complete
gate_status: PASS
</observation>

**State Snapshot:**
```yaml
workflow_state:
  current_phase: SHIP
  stage_completed: summary
  artifacts:
    - qa_report: tests/FE-test/{spec_id}/QA-BUG-HUNTER-REPORT.md
    - evidence_directory: tests/FE-test/{spec_id}/evidence/
    - issue_urls: [...]
  status: COMPLETE
```

---

## Handoff Contracts

### DISCOVER → EVIDENCE
```yaml
handoff:
  from: qa + flow-discovery
  to: browser-testing
  provides: [bug_list, reproduction_steps, target_url]
  expects: [screenshots, console_errors, network_errors per bug]
```

### EVIDENCE → HUMAN GATE
```yaml
handoff:
  from: browser-testing
  to: user
  provides: [bug_draft_with_evidence, severity, reproduction_steps]
  expects: [APPROVE | REJECT | MODIFY per bug]
```

### HUMAN GATE → LOG
```yaml
handoff:
  from: user
  to: github-issue-manager
  provides: [approved_bug_draft, evidence_paths]
  expects: [github_issue_url, issue_number]
```

---

## Error Handling

| Error Type | Trigger | Recovery |
|---|---|---|
| `TARGET_UNREACHABLE` | Target URL is not accessible or returns non-2xx | STOP. Verify URL with user. Do not proceed to DISCOVER without a reachable target. |
| `EVIDENCE_CAPTURE_FAILURE` | Playwright / browser fails to capture screenshots or console logs | Infrastructure failure — do NOT consume `max_retries`. Fix browser setup (re-run `playwright-setup`), retry EVIDENCE stage fresh. |
| `GITHUB_AUTH_FAILURE` | `gh auth status` fails or repo not found during LOG stage | STOP. Ask user to run `gh auth login`. Do not create issues without valid auth. |
| `CONTEXT_OVERFLOW` | Claude signals loss of earlier stage outputs mid-workflow | Run context pruning. Re-read bug list and evidence directory. Resume from current bug index. |

---

## Context Pruning

After each stage completes, prune context:
- Drop raw QA output (retain bug candidate list only)
- Drop raw browser-testing output (retain evidence file paths only)
- Drop rejected bug details after recording reason
- Retain: bug list, evidence paths, draft/final issue bodies, user decisions, issue URLs

---

## Quality Gates Summary

```yaml
quality_gates:
  setup:
    - url_accessible
    - evidence_dir_created
    - gh_authenticated

  discover:
    - qa_completed
    - bug_list_compiled

  evidence:
    - bug_reproduced
    - screenshot_captured
    - evidence_stored

  prepare:
    - draft_complete
    - issue_not_created_yet

  human_gate:
    - draft_presented_to_user
    - user_decision_recorded

  log:
    - issue_created_or_rejection_logged
    - issue_url_captured

  summary:
    - report_generated
    - all_bugs_processed
```

## Timeline Estimate

```yaml
timeline:
  setup: "2-5 min"
  discover: "15-45 min"
  evidence_per_bug: "5-10 min"
  prepare_per_bug: "2-5 min"
  human_gate_per_bug: "1-5 min (depends on user)"
  log_per_bug: "1 min"
  summary: "2-5 min"

  total_simple: "30-60 min (1-3 bugs)"
  total_complex: "1-3 hours (5-10+ bugs)"
```

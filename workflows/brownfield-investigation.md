---
name: brownfield-investigation
description: "Context-aware bug investigation workflow for brownfield projects. Loads module-based business context before investigation, traces bugs through module dependency chains, packages evidence with business narrative, and creates GitHub issues with impact assessment. Requires .em-brownfield/ context (auto-triggers brownfield-onboarding if missing)."
version: "5.0.0"
category: "primary"
origin: "EM-Team"
react_protocol: true
context_pruning: true
max_retries_per_stage: 2
agents_used:
  - debugger
  - brownfield-test-engineer
skills_used:
  - brownfield-onboarding
  - flow-discovery
  - browser-testing
  - systematic-debugging
  - github-issue-manager
related_skills:
  - brownfield-context-sync
  - e2e-testing
  - test-generation
estimated_time: "30-120 min"
input_schema:
  type: object
  required: [bug_description]
  properties:
    bug_description:
      type: string
      description: "Description of the bug to investigate"
    target_url:
      type: string
      description: "URL of the running application (for browser-based reproduction)"
    affected_module:
      type: string
      description: "Optional hint about which business module is affected"
    brownfield_context_path:
      type: string
      default: ".em-brownfield"
      description: "Path to brownfield context directory"
    severity_hint:
      type: string
      enum: [P0, P1, P2, unknown]
      default: unknown
      description: "Optional severity hint from reporter"
output_schema:
  type: object
  required: [status, investigation]
  properties:
    status:
      type: string
      enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED]
    investigation:
      type: object
      required: [root_cause, evidence_package]
      properties:
        affected_module: { type: string }
        affected_flow: { type: string }
        root_cause:
          type: object
          properties:
            description: { type: string }
            file: { type: string }
            function: { type: string }
            root_module: { type: string }
            chain: { type: array, items: { type: string } }
        blast_radius:
          type: object
          properties:
            affected: { type: array, items: { type: object } }
            at_risk: { type: array, items: { type: object } }
        severity: { type: string, enum: [P0, P1, P2] }
        evidence_package:
          type: object
          properties:
            video_path: { type: string }
            screenshots: { type: array, items: { type: string } }
            network_logs: { type: string }
            step_results: { type: array }
        issue_url: { type: string }
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

# Brownfield Investigation Workflow

> Context-aware bug investigation for brownfield projects.
> Understands business flows BEFORE investigating, traces through module chains,
> packages evidence with business narrative, and creates impact-assessed GitHub issues.

## Design Principles

1. **Context first, code second.** Load business context before touching code.
2. **Deep chain tracing.** Bugs often span multiple modules. Trace the ENTIRE chain until root cause is found.
3. **When unclear, ask.** Never guess business intent. Ask the user.
4. **Evidence with narrative.** Every screenshot and video must have business context — not just "button broken" but "revenue flow blocked at step 5 of 7."

---

## Stage 0: CONTEXT LOAD

<thought>
Must understand the business context of the affected module(s) and their dependency chain
before any investigation. Without this, we're debugging blind.
</thought>

<action>
type: context_load
steps:
  1. Check if `.em-brownfield/INDEX.md` exists
     → If NOT: invoke `brownfield-onboarding` skill first. BLOCK until complete.
  1b. Read `.em-brownfield/DOMAIN-PROFILE.md` → understand business domain
     → Use domain knowledge to judge severity and prioritize investigation
     → E.g., in fintech: payment-related bugs are automatically P0
  2. Read INDEX.md → identify affected module from bug_description
     → If module unclear → ASK USER: "This bug occurs in which feature/page/flow?
       I see these modules: [list from INDEX.md]. Which one?"
  3. Load affected module context (ALL 4 files):
     - modules/{affected}/FLOWS.md — business flows
     - modules/{affected}/CODE-MAP.md — code locations
     - modules/{affected}/INTEGRATIONS.md — external dependencies
     - modules/{affected}/DOMAIN.md — entities and business rules
  4. Check Last Verified date in INDEX.md for affected module:
     → If > 14 days stale → WARN: "Context for {module} was last verified {date}.
       May be outdated. Recommend running brownfield-context-sync first."
     → If CONTRACT_BREAK status → BLOCK: "Module {module} has contract breaks.
       Run brownfield-context-sync to resolve before investigating."
  5. Follow Dependencies recursively:
     - Load direct dependencies (1-hop): FLOWS.md + CODE-MAP.md
     - If bug description suggests deeper chain → load 2-hop, 3-hop
     - Load Depended By → know what breaks if fix is wrong
  6. Identify the specific flow(s) affected by the bug
  7. Build investigation context summary:
     "Bug affects flow '{flow_name}' in module '{module}' (Impact: {P0/P1/P2}).
      This module depends on [{deps}]. Modules [{dependents}] depend on it.
      The flow has {N} steps. Starting investigation."
</action>

<observation>
context_loaded: true | false
affected_module: {name}
affected_flow: {flow_name}
impact_level: {P0/P1/P2}
dependency_chain: [{module_A} → {module_B} → ...]
blast_radius_candidates: [{modules that depend on affected}]
stale_warning: true | false
</observation>

**Gate:** context_loaded == true AND affected_flow identified. Otherwise BLOCKED.

---

## Stage 1: REPRODUCE & MAP

<thought>
Reproduce the bug by following the exact business flow steps from FLOWS.md.
Capture evidence for EVERY step, not just the failure point.
If the flow crosses modules, trace the full chain.
</thought>

<action>
type: reproduce
steps:
  1. Open browser → navigate to flow entry point (from FLOWS.md happy path step 1)
  2. Start recording: video + network capture + console
  3. Execute happy path steps 1..N from FLOWS.md:
     - Per step: capture screenshot + network requests + console output
     - Mark each step: PASS | FAIL | UNEXPECTED_BEHAVIOR
     - If step involves cross-module call (from INTEGRATIONS.md):
       verify data handoff matches expected contract
  4. If flow has error paths documented in FLOWS.md → test those too
  5. At failure point:
     - Full screenshot + console errors + network response bodies
     - Compare actual behavior with FLOWS.md expected behavior
     - Compare with Acceptance Criteria → which AC is violated?
     - Check Known Issues in FLOWS.md → is this already documented?
  6. If CANNOT reproduce:
     → ASK USER: "Could not reproduce with standard flow steps.
       Are there special conditions? (specific data, timing, user role, concurrent actions)"
     → Try variations: different data, roles, browser, timing
</action>

<observation>
reproduced: true | false
step_results: [{step_num, module, action, status, evidence_path}]
failure_step: {N} | null
failure_module: {module where failure occurs}
cross_module_trace: [{module, step, data_sent, data_received}]
known_issue_match: {issue_number} | null
ac_violated: [AC-{MODULE}-{NNN}]
</observation>

**Gate:** Failure reproduced with evidence, OR confirmed no-repro with explanation.

---

## Stage 2: ROOT CAUSE ANALYSIS

<thought>
Trace from the failed step to the actual root cause.
CRITICAL: Follow the module chain — root cause may be in a different module than where the symptom appears.
Do NOT stop at the first suspicious code. Keep tracing until you find the ACTUAL origin.
</thought>

<action>
type: root_cause_analysis
steps:
  1. From CODE-MAP.md: find file:function for the failed step
  2. Read source code at exact location, trace execution:
     - What data comes in? (does it match FLOWS.md expectation?)
     - What business logic runs? (does it match Business Rules?)
     - What data goes out? (does it match expected output?)
  3. If bug is at module boundary (data handoff):
     - Trace BOTH sides: sender's output AND receiver's input
     - Check INTEGRATIONS.md: does data format match contract?
     - Look for transformation/mapping that could corrupt data
  4. If external integration involved:
     - Check INTEGRATIONS.md failure modes
     - Distinguish: is the external service failing, or is our code handling it wrong?
  5. Deep chain tracing — do NOT stop at first suspicious code:
     - If root cause seems in module A but data comes from module B
       → Load module B's CODE-MAP.md → trace into B
     - Continue until ACTUAL root cause found
     - Example chain: "Order total wrong" → OrderService.calculateTotal()
       → calls PricingService.getPrice() → reads CouponService.validate()
       → CouponService bug in expiry check ← ACTUAL ROOT CAUSE
  6. Blast radius analysis:
     - From INDEX.md Depended By: which modules consume affected output?
     - For each dependent: "Could this root cause affect flow X in module Y?"
     - Classify: AFFECTED (definitely impacted) | AT_RISK (might be) | SAFE
  7. If root cause unclear after analysis:
     → ASK USER: "Traced to [point]. Two possibilities: [A] or [B].
       Do you have additional context about expected behavior here?"
</action>

<observation>
root_cause:
  description: {explanation}
  file: {file:line}
  function: {function_name}
  root_module: {module where bug actually lives}
chain: [{symptom_module} → {intermediate} → {root_cause_module}]
blast_radius:
  affected: [{module, flow, reason}]
  at_risk: [{module, flow, reason}]
  safe: [{module}]
severity: {P0/P1/P2 based on impact_level + blast_radius}
</observation>

---

## Stage 3: EVIDENCE PACKAGE

<thought>
Package all evidence with full business narrative.
Every piece of evidence must explain WHAT happened, WHERE in the business flow,
and WHY it matters to the business.
</thought>

<action>
type: evidence_package
steps:
  1. Create directory: `.em-investigations/{YYYY-MM-DD}-{module}-{shortid}/`
     where shortid = first 8 chars of sha256(bug_description + timestamp)
  
  2. Save raw evidence files to subdirectory:
     - video.webm — full flow recording
     - screenshots/step-{N}.png — per step
     - network.har — network capture
     - console.log — console output
     - playwright-trace.zip (if Playwright-driven)
     - test-output.txt (if test-driven)
  
  3. Write EVIDENCE.json using `templates/brownfield/EVIDENCE-MANIFEST.json.template`:
     - All paths RELATIVE to investigation directory
     - investigation_id matches directory name
     - context_links point to .em-brownfield/ artifacts
  
  4. Write REPORT.md using `templates/brownfield/INVESTIGATION-REPORT.md` (created Task 1.5).
  
  5. Final structure:
     ```
     .em-investigations/2026-05-26-payment-a3f7c2b1/
     ├── EVIDENCE.json          # manifest
     ├── REPORT.md              # human-readable report
     ├── video.webm
     ├── network.har
     ├── console.log
     ├── playwright-trace.zip
     └── screenshots/
         ├── step-1.png
         ├── step-2.png
         └── step-3-FAIL.png
     ```
</action>

---

## Stage 4: REPORT / HUMAN GATE

<thought>
Present findings to user with full business impact assessment.
User decides whether to create a GitHub issue. Never create without approval.
</thought>

<action>
type: human_gate
steps:
  1. Format GitHub issue draft:
  
     **Title:** [{module}] {business impact} — {technical symptom}
     
     **Labels:** bug, {module-name}, P{severity}, brownfield-investigation
     
     **Body:**
     ## Business Impact
     - **Module:** {name} ({type: Core/Supporting/Generic})
     - **Flow:** {flow_name} — Step {N} of {total}
     - **Impact:** P{severity} — {business justification}
     - **Blast Radius:** {N} modules affected, {M} at risk
     
     ## Reproduction Steps
     Following `{module}/FLOWS.md` happy path:
     1. [Step 1] — PASS
     2. [Step 2] — PASS
     ...
     N. [Step N] — **FAIL** ← bug occurs here
     
     ## Root Cause
     **Module:** {root_cause_module} (may differ from symptom module)
     **File:** `{file:line}`
     **Function:** `{function_name}`
     **Chain:** {symptom} → {intermediate} → {root cause}
     
     {Technical explanation}
     
     ## Evidence
     - Video: [link]
     - Screenshots: [links]
     - Network: [link]
     
     ## Acceptance Criteria Violated
     - AC-{MODULE}-{NNN}: {text}
     
     ## Affected Modules
     | Module | Status | Flow | Why |
     |--------|--------|------|-----|
     | {name} | AFFECTED | {flow} | {reason} |
     | {name} | AT_RISK | {flow} | {reason} |
  
  2. Present to user with clear options:
     → **APPROVE** — Create GitHub issue as drafted
     → **MODIFY** — User edits title/body/labels, then create
     → **REJECT** — Skip issue creation (with reason)
</action>

---

## Stage 5: CONTEXT UPDATE

<thought>
Update brownfield context with findings from this investigation.
This keeps the knowledge graph fresh and useful for future investigations.
</thought>

<action>
type: context_update
steps:
  1. **New Known Issue → ACTIVE WRITE:**
     Read modules/{affected_module}/FLOWS.md.
     Find the affected flow's "Known Issues" section.
     Append:
     ```
     - #{issue_number} ({YYYY-MM-DD}): {1-line description} — status: open
       - Root cause module: {root_cause_module}
       - File: {file:function}
       - Severity: P{N}
     ```
     Save file. Show diff to user → APPROVE / MODIFY / SKIP.
  
  2. **Cross-module dependency missing → ACTIVE WRITE:**
     If root cause is in module B but symptom in module A:
     Open modules/A/FLOWS.md → check Dependencies section for B.
     If missing → APPEND to Dependencies: `[B](../B/FLOWS.md) — {1-line why}`
     Open modules/B/FLOWS.md → check Depended By for A.
     If missing → APPEND to Depended By: `[A](../A/FLOWS.md) — {1-line why}`
     Show diff → APPROVE / SKIP.
  
  3. **Flow behavior mismatch → PROPOSE UPDATE:**
     If observed behavior at step N differs from documented expectation:
     Generate proposed diff for modules/{module}/FLOWS.md showing the corrected step.
     Present: "Observed behavior at step {N}: '{observed}'. Documented: '{documented}'.
     Which is the bug — observed (fix code) or documented (fix docs)?"
     If user says doc was wrong → apply diff. If code was wrong → leave doc unchanged.
  
  4. **HEALTH-CHECK.md Investigation History → ACTIVE WRITE:**
     Append row to "Investigation History" table:
     | {YYYY-MM-DD} | {symptom_module} | {flow_name} | {bug_summary} | {root_cause_module} | P{N} | #{issue} |
  
  5. **INDEX.md Last Verified → ACTIVE WRITE:**
     Update Last Verified column for affected_module to today's date.
  
  6. **Investigation Report Artifact:**
     Write `.em-investigations/{YYYY-MM-DD}-{module}-{shortid}/REPORT.md` with full findings.
     Use template from templates/brownfield/INVESTIGATION-REPORT.md (created in Phase 1).
</action>

<observation>
context_updates_applied: N
context_updates_skipped: M (user rejected)
investigation_report_path: .em-investigations/...
</observation>

**Gate 5:** All context updates either APPLIED (with user confirmation) or explicitly SKIPPED.

---

## Error Handling

Per `protocols/error-handling.md`:

| Error | Stage | Recovery |
|-------|-------|----------|
| `.em-brownfield/` missing | Stage 0 | Invoke `brownfield-onboarding` skill, then retry |
| Module not identified from bug description | Stage 0 | ASK USER to specify affected feature/page |
| Context stale (> 14 days) | Stage 0 | WARN + suggest `brownfield-context-sync` first |
| CONTRACT_BREAK in affected module | Stage 0 | BLOCK until contract break resolved |
| Cannot reproduce bug | Stage 1 | ASK USER for special conditions, try variations (max 3 attempts) |
| Root cause unclear after analysis | Stage 2 | ASK USER for additional context, present top 2 hypotheses |
| Cross-module trace hits dead end | Stage 2 | Check if CODE-MAP is stale, re-scan affected module code |
| GitHub API failure during issue creation | Stage 4 | Save evidence locally, retry issue creation, report BLOCKED if persistent |
| Stage timeout (> 30 min per stage) | Any | Checkpoint progress, summarize findings so far, ASK USER to continue or pause |

`max_retries_per_stage: 2` — After 2 failures at any stage, report BLOCKED with detailed context.

---

## Coaching Notes

### Why Context-First Investigation?
Traditional debugging starts with "reproduce → read code → find bug." In brownfield projects, this approach fails because the developer doesn't know WHAT correct behavior looks like. By loading FLOWS.md first, the agent knows the expected behavior at each step and can immediately detect deviations.

### Why Deep Chain Tracing?
Symptoms often appear in module A, but root cause lives in module C (which provides data to B, which provides data to A). Stopping at the first suspicious code leads to treating symptoms, not causes. The module dependency graph enables systematic tracing.

### Why Business-Narrative Evidence?
Technical-only bug reports ("button doesn't work") get low priority. Business-narrative reports ("checkout flow blocked at payment step — P0 revenue impact, affects 3 modules") get immediate attention and proper severity assignment.

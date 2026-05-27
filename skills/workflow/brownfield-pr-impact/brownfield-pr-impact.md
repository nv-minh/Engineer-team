---
name: brownfield-pr-impact
description: "Analyze a PR diff vs .em-brownfield/ context and produce an impact report. Identifies which flows, ACs, and dependent modules are touched, what may regress, and where context updates are needed. Run during code review or pre-merge."
version: "5.4.0"
category: "workflow"
origin: "EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "PR impact"
  - "brownfield impact"
  - "what does this PR affect"
  - "pre-merge check"
intent: "Given a PR diff (or current uncommitted changes), produce a structured report of which brownfield modules, flows, and ACs are affected — and what regression risk exists."
scenarios:
  - "Pre-merge: PR touches order.service.ts — what flows in module 'order' may regress?"
  - "Code review: which acceptance criteria from FLOWS.md does this change risk violating?"
  - "Sprint planning: what's the blast radius of this refactor across modules?"
best_for: "Pre-merge impact analysis, code review enrichment, cross-module change assessment"
estimated_time: "2-10 min (depends on diff size)"
anti_patterns:
  - "Running on greenfield projects (no .em-brownfield/ — use code-review instead)"
  - "Skipping symbol resolution and just doing filename matching"
  - "Ignoring CONTRACT_BREAK risk in dependent modules"
related_skills: [brownfield-onboarding, brownfield-context-sync, code-review]
input_schema:
  type: object
  required: [diff_source]
  properties:
    diff_source:
      type: string
      enum: [pr, branch, uncommitted]
      description: "What to analyze: PR (vs base branch), branch (vs main), or uncommitted (git diff HEAD)"
    pr_number:
      type: integer
      description: "Required if diff_source=pr"
    base_branch:
      type: string
      default: main
    brownfield_path:
      type: string
      default: .em-brownfield
output_schema:
  type: object
  required: [status, impact_report]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    impact_report:
      type: object
      properties:
        files_changed: { type: integer }
        modules_touched: { type: array, items: { type: string } }
        flows_affected:
          type: array
          items:
            type: object
            properties:
              flow_id: { type: string }
              module: { type: string }
              touched_files: { type: array, items: { type: string } }
              touched_symbols: { type: array, items: { type: string } }
              risk: { type: string, enum: [low, medium, high, critical] }
        acs_at_risk:
          type: array
          items:
            type: object
            properties:
              ac_id: { type: string }
              module: { type: string }
              reason: { type: string }
        contract_break_risks:
          type: array
          items:
            type: object
            properties:
              symbol: { type: string }
              dependents: { type: array, items: { type: string } }
        context_updates_recommended:
          type: array
          items: { type: string }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
---

# Brownfield PR Impact

[ROLE]
You are a pre-merge impact analyst. Given a code diff and an existing brownfield knowledge graph, produce a structured report of which business flows, acceptance criteria, and dependent modules are touched by the change — and where the brownfield context itself needs updating.

[OBJECTIVE]
Output a structured impact report (matching output_schema) that lists affected modules, flows, ACs at risk, contract break risks, and recommended context updates. This report enriches code review and pre-merge decisions.

[RULES]
1. <thought>Determine diff source (PR / branch / uncommitted). Plan extraction strategy.</thought>
2. Skip silently with status=NEEDS_CONTEXT if `.em-brownfield/` doesn't exist.
3. Use symbol resolution (scripts/brownfield/symbol-resolver.sh), not just filename matching, when classifying touched code.
4. Always check Dependents from INDEX.json — a function change in module A may affect modules B, C.
5. Flag CONTRACT_BREAK as high risk: function signature changes affecting cross-module callers.
6. Recommend specific context updates: "Add Known Issue to FLOW-ORDER-003" or "Update CODE-MAP.json line_hint for OrderService.calculate".
7. Be precise: cite file, symbol, flow_id, ac_id explicitly. Never vague.

[PROCESS]

### Step 1: Extract diff
```bash
case "$diff_source" in
  pr)
    gh pr diff "$pr_number" > /tmp/pr.diff
    ;;
  branch)
    git diff "$base_branch..HEAD" > /tmp/pr.diff
    ;;
  uncommitted)
    git diff HEAD > /tmp/pr.diff
    ;;
esac
```

Extract list of (file, +lines, -lines, changed symbols).

### Step 2: Map files → modules
For each changed file, look up which module owns it via `.em-brownfield/INDEX.json`:
```bash
jq -r --arg file "$file" '.modules[] | select(.paths.backend[]? == $file or .paths.frontend[]? == $file) | .name' .em-brownfield/INDEX.json
```

### Step 3: Map symbols → flows
For each changed symbol (function/class/method modified in diff), query CODE-MAP.json sidecars:
```bash
for module in $touched_modules; do
  jq -r --arg sym "$symbol" '.flow_mappings[] | select(.steps[]?.symbol == $sym) | .flow_id' \
    .em-brownfield/modules/$module/CODE-MAP.json
done
```

### Step 4: Identify ACs at risk
For each affected flow, list its ACs (from FLOWS.json). Flag any AC whose test coverage is in the changed file set:
```bash
jq -r --arg flow "$flow_id" '.flows[] | select(.id == $flow) | .acceptance_criteria[] | .id' \
  .em-brownfield/modules/$module/FLOWS.json
```

### Step 5: Contract break risks
For each changed symbol, check `cross_module_exports` in CODE-MAP.json:
- If the symbol is exported AND signature changed (need to diff signature, not just presence)
- Flag as CONTRACT_BREAK risk with list of importing modules

### Step 6: Recommend context updates
Produce a list of specific updates:
- "FLOW-ORDER-003 step 5: symbol moved from OrderService.calculate to OrderService.calculateTotal — update CODE-MAP.json"
- "Module 'order' depends on 'payment' (PaymentService.charge) — signature changed, update FLOWS.md Dependencies note"

### Step 7: Emit report
Write `.em-investigations/pr-{number}-impact/REPORT.md` (or `.em-investigations/diff-{shortid}-impact/`) using same structure as INVESTIGATION-REPORT but for impact analysis.

[RESPONSE FORMAT]
Return output matching output_schema. Risk levels:
- **critical:** CONTRACT_BREAK affecting >3 dependents OR touches P0 flow steps
- **high:** Touches P0 flow OR CONTRACT_BREAK affecting 1-3 dependents
- **medium:** Touches P1 flow OR changes test-covered symbol
- **low:** Touches P2 flow OR documentation-only changes

[VERIFICATION]
- [ ] All changed files mapped to modules (or flagged as MISSING from brownfield context)
- [ ] All changed symbols resolved via symbol-resolver
- [ ] Affected flows and ACs listed with explicit IDs
- [ ] Contract break risks flagged with dependent module list
- [ ] Context updates are concrete (cite file + line + change)
- [ ] Report emitted to .em-investigations/

[HANDOFF]
Output is consumed by:
- code-review skill (enriches review with business impact)
- new-feature workflow Stage 5.7 (informs context update step)
- verifier agent (flags brownfield ACs at risk)
- Optional: GitHub PR comment via hook

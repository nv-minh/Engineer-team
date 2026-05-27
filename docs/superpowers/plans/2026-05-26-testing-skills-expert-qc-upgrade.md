# Testing Skills Expert-QC Upgrade Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade EM-Team testing skills/agents so generated test cases reach expert-QC quality: systematic techniques (BVA, EP, Decision Table, State Transition, Pairwise, Risk-Based), explicit test oracles, abuse/security cases, and non-functional coverage — instead of sparse happy-path tests.

**Architecture:** Add a new canonical `test-case-design` skill that holds all QA test-design know-how. Wire all existing test skills (`test-generation`, `api-testing`, `e2e-testing`, `browser-testing`) and agents (`test-engineer`, `brownfield-test-engineer`) to invoke it and enforce its outputs. Extend the TC-REGISTRY template with `Technique`, `Risk`, `Oracle` columns and raise the negative/abuse ratio policy to be risk-calibrated. Update the spec template to require explicit negative/abuse/non-functional acceptance criteria so the upstream input is no longer happy-path-only.

**Tech Stack:** Markdown skill/agent/template files with YAML frontmatter (Hermes Protocol v4.0.0); validation via `scripts/validate-hermes.sh` and `scripts/benchmark-quality.sh`.

---

## Pre-flight: Pain Points This Plan Fixes

1. `skills/quality/test-generation/test-generation.md` Edge Case Discovery table is a flat 8-row list — no technique attribution, no per-parameter systematic application.
2. `test-generation` negative-ratio floor is a flat 30%. Real expert QC calibrates by risk (P0 features need 40-60%, P2 features 20-30%) and always adds abuse cases.
3. Skills do not require **Test Oracles** — generated TCs only have "Expected Output" without specifying *how* the assertion proves correctness (state vs. interaction, snapshot vs. property).
4. No **Mutation thinking** gate — TCs are not checked for "would this test catch a mutated implementation?"
5. Abuse cases (SQL injection, XSS, IDOR, race conditions, replay, parameter tampering) are not first-class — buried under generic "Special Chars" row.
6. `api-testing` does not map OWASP API Security Top 10; misses idempotency, pagination/filter/sort boundaries, content negotiation, error envelope consistency, rate-limit burst vs. sustained.
7. `e2e-testing` says "Edge cases — Empty states, boundary values, concurrent actions" without elaboration. No coverage of mid-flow interruption (refresh, back button, network drop, session expiry, double-submit, tab switch, deep link).
8. `browser-testing` skips systematic UI state matrix (loading × empty × partial × error × success × no-permission × stale-data) and a11y/i18n edge cases.
9. `test-engineer` and `brownfield-test-engineer` agents do not require the technique label per TC, so any reviewer can't tell *why* a case was chosen.
10. TC-REGISTRY template has 9 fields but none of them force a technique label, risk level, or oracle specification.
11. `spec-template` upstream does not require negative-scenarios/abuse-cases sections, so downstream test generation has nothing to expand from.

---

## File Structure

```
skills/quality/test-case-design/                  # NEW
├── SKILL.md                                       # symlink -> test-case-design.md
└── test-case-design.md                            # canonical reference for QA techniques

skills/quality/test-generation/test-generation.md  # MODIFY: require test-case-design, add Technique/Oracle/Risk columns
skills/quality/api-testing/api-testing.md          # MODIFY: OWASP API Top 10 + non-functional checklist
skills/quality/e2e-testing/e2e-testing.md          # MODIFY: full edge-case matrix for user journeys
skills/quality/browser-testing/browser-testing.md  # MODIFY: UI state matrix + a11y/i18n checklist

agents/test-engineer.md                            # MODIFY: enforce technique attribution + risk-based priority
agents/brownfield-test-engineer.md                 # MODIFY: enforce technique attribution + raise quality gate

templates/spec-template.md                         # MODIFY: add negative/abuse/non-functional sections
templates/project-dna/rules/testing-standards.template.md  # MODIFY: add Technique/Risk/Oracle columns + ratios
templates/TC-REGISTRY.template.md                  # NEW: canonical TC-REGISTRY format

CLAUDE.md                                          # MODIFY: skill count 88 -> 89; add test-case-design entry
```

---

## Task 1: Create centralized `test-case-design` skill

**Why:** Eliminate duplication and create a single source of truth for QA test-design techniques. All other test skills/agents will reference this skill instead of repeating watered-down edge-case lists.

**Files:**
- Create: `skills/quality/test-case-design/test-case-design.md`
- Create: `skills/quality/test-case-design/SKILL.md` (symlink to `test-case-design.md`)

- [ ] **Step 1: Write `skills/quality/test-case-design/test-case-design.md`** with full content below

````markdown
---
name: test-case-design
description: "Apply expert QA test-design techniques to produce non-trivial test cases. Use BEFORE test-generation, e2e-testing, api-testing, or browser-testing whenever you need to expand a feature into a high-coverage TC set — not just happy paths."
version: "1.0.0"
category: "quality"
origin: "em-team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["design test cases", "expand testcases", "test idea generation", "edge cases", "boundary value", "equivalence partitioning", "decision table", "state transition", "pairwise", "abuse cases", "risk-based testing", "test oracle"]
intent: "Drive test case generation through systematic QA techniques (BVA, EP, DT, ST, Pairwise, RBT) plus abuse cases, non-functional cases, and oracle selection — producing TC sets an expert QA would defend in review."
scenarios:
  - "Spec defines a money-transfer feature; need test cases covering boundaries, currency, fraud abuse, and concurrent transfers"
  - "A pagination endpoint accepts page, size, sort — need to derive minimal but covering test set without exploding combinations"
  - "A workflow has 6 states and 14 transitions — need to cover every reachable state and forbidden transitions"
  - "Form has 5 fields with rules — need decision-table coverage of the rule combinations"
best_for: "test case ideation, coverage gap closure, review-grade TC defense, abuse case discovery, non-functional case discovery"
estimated_time: "20-40 min"
anti_patterns:
  - "Listing edge cases by intuition without naming the technique"
  - "Stopping at happy + null + one boundary value"
  - "Treating abuse cases as optional"
  - "Writing TCs without specifying the oracle (how do we know the result is correct?)"
related_skills: ["test-generation", "api-testing", "e2e-testing", "browser-testing", "test-driven-development", "security-common"]
input_schema:
  type: object
  required: [target]
  properties:
    target: { type: string, description: "Feature, function, endpoint, or workflow to design tests for" }
    risk_tier: { type: string, enum: [P0, P1, P2, P3], description: "Risk tier drives negative/abuse ratio targets" }
    spec_excerpt: { type: string, description: "Acceptance criteria / spec text to derive cases from" }
output_schema:
  type: object
  required: [status, design_summary, test_ideas]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    design_summary:
      type: object
      properties:
        techniques_applied: { type: array, items: { type: string } }
        ratios: { type: object, properties: { positive: { type: integer }, negative: { type: integer }, abuse: { type: integer }, non_functional: { type: integer } } }
        coverage_heuristic: { type: string, description: "Heuristic used (RCRCRC, SFDPOT, FCC-CUTS-VIDS, ad-hoc)" }
    test_ideas:
      type: array
      items:
        type: object
        properties:
          idea_id: { type: string }
          title: { type: string }
          technique: { type: string, enum: [BVA, EP, DT, ST, PW, RBT, abuse, non_functional, exploratory] }
          oracle: { type: string }
          risk: { type: string, enum: [P0, P1, P2, P3] }
          rationale: { type: string }
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

# Test Case Design

[ROLE]
You are an expert QA engineer. Convert a feature spec into a defensible set of test ideas using systematic techniques — not intuition. Every test idea must carry a technique label, a risk tier, and an explicit oracle.

[OBJECTIVE]
Produce a `test_ideas[]` array where every entry has: `technique`, `oracle`, `risk`, and `rationale`. The set must satisfy the risk-calibrated ratio table (Step 4) and pass the Mutation Sanity Check (Step 6).

[RULES]
1. <thought>Before listing test ideas, identify: inputs (parameters and their domains), outputs (return types and side effects), states (entry, intermediate, terminal), boundaries (numeric, length, time, count), and trust boundaries (auth, tenancy, rate limits).</thought>
2. Every test idea MUST have a `technique` label from {BVA, EP, DT, ST, PW, RBT, abuse, non_functional, exploratory}. "Edge case" is not a technique — it is a category. Name the technique.
3. Every test idea MUST have a `oracle` field naming HOW correctness is verified: state-based / interaction-based / property-based / snapshot / metamorphic / contract-schema / human-judgment. No oracle = vacuous test.
4. Apply at least 4 techniques per non-trivial feature. A spec covered only by EP+BVA is incomplete.
5. The negative+abuse+non_functional ratio MUST meet the table in Step 4 for the declared `risk_tier`. If `risk_tier` is missing, ask before generating.
6. Mutation Sanity Check (Step 6) is a gate, not advice. Any idea that cannot describe a mutation it would catch is removed.
7. Stop happy-path inflation. After ≥1 happy path per acceptance criterion, additional positive cases require explicit justification (e.g., representing different equivalence classes).
8. ABC: Teach the technique in `rationale`. "Empty string" is not a rationale; "Empty-string EP-class for required field — distinguishes 'missing' from 'whitespace' from 'valid'" is.

[PROCESS]

### Step 1: Decompose the Surface

For the target feature, list:
- **Inputs:** parameters with type, domain, and constraints (range, length, format, enum, optionality)
- **Outputs:** return type, side effects, emitted events, persisted state changes, HTTP status, error envelope
- **States:** entry, intermediate, terminal (for stateful systems)
- **Trust boundaries:** auth required? tenancy isolation? rate limit?
- **External dependencies:** APIs, DB, queues, clock, randomness

### Step 2: Choose Coverage Heuristic

Pick one to drive idea generation:

| Heuristic | Mnemonic | Use When |
|---|---|---|
| RCRCRC | Recent / Core / Risk / Configuration / Repaired / Chronic | Brownfield regression |
| SFDPOT | Structure / Function / Data / Platform / Operations / Time | New feature, broad surface |
| FCC-CUTS-VIDS | Feature, Component, Configuration, User, Time, Scenario, Variability, Integration, Data, State | Cross-cutting QA review |
| Risk-First | Impact × Likelihood top-N | Tight deadline, P0 path |

Record the choice in `design_summary.coverage_heuristic`.

### Step 3: Apply the Six Core Techniques

For each input/state, walk through the techniques and emit `test_ideas`:

#### 3.1 Equivalence Partitioning (EP)
Identify equivalence classes per parameter — every valid value in a class is assumed to behave identically. One representative per class.

```
parameter: age (integer, business rule: 18-65 allowed)
EP classes: { <18 invalid }, { 18-65 valid }, { >65 invalid }, { non-integer invalid }, { null invalid }
TC ideas: TC-EP-01..05 (one per class)
```

#### 3.2 Boundary Value Analysis (BVA)
For every ordered domain, emit min-1, min, min+1, max-1, max, max+1. For string length, emit 0, 1, max-1, max, max+1, max+huge.

```
parameter: age (18-65)
BVA: 17, 18, 19, 64, 65, 66
parameter: name (1-50 chars)
BVA: "", "a", "a"*49, "a"*50, "a"*51, "a"*10000
```

#### 3.3 Decision Table (DT)
For features with combinatorial business rules, build a decision table. Emit one TC per rule row, including impossible combinations.

```
Rules: { has_account, kyc_verified, age>=18, balance>0 } -> action
| has_account | kyc | age>=18 | balance>0 | -> action      |
|-------------|-----|---------|----------|----------------|
| F           | -   | -       | -        | reject:no-acct |
| T           | F   | -       | -        | reject:kyc     |
| T           | T   | F       | -        | reject:minor   |
| T           | T   | T       | F        | reject:funds   |
| T           | T   | T       | T        | approve        |
```

Every row = one TC. Mark impossible combos with `N/A` but document why.

#### 3.4 State Transition (ST)
For stateful systems, draw the state graph. Emit:
- One TC per legal transition (forward path)
- One TC per illegal/forbidden transition (must reject)
- One TC per terminal state (no further transitions allowed)
- One TC per cycle (return to earlier state)

```
states: draft -> submitted -> approved -> archived
                          \-> rejected -> archived
illegal: archived -> approved (must reject)
illegal: submitted -> archived (must reject)
```

#### 3.5 Pairwise / Combinatorial (PW)
For multi-parameter inputs, full combination explodes. Use pairwise (every pair of parameter values appears in at least one TC) — gives ~80% defect coverage with linear test count.

```
parameters: { browser: [chrome, firefox, safari], device: [mobile, desktop], locale: [en, vi, ja] }
full = 3*2*3 = 18 ; pairwise = 9
```

#### 3.6 Risk-Based Testing (RBT)
Score each candidate idea by `impact (1-5) × likelihood (1-5)`. P0 = score >=15, P1 = 8-14, P2 = 4-7, P3 = <4. Use this to prioritize execution order and to justify cuts when scope is tight.

### Step 4: Apply Negative + Abuse + Non-Functional Ratios

Risk-calibrated ratio table — these are floors, not targets:

| risk_tier | positive | negative | abuse | non_functional |
|-----------|----------|----------|-------|----------------|
| P0        | <=40%    | >=35%    | >=15% | >=10%          |
| P1        | <=50%    | >=30%    | >=10% | >=10%          |
| P2        | <=60%    | >=25%    | >=5%  | >=5%           |
| P3        | <=70%    | >=25%    | optional | optional    |

#### Abuse Case Categories (apply per surface)

| Surface | Abuse Categories to Cover |
|---------|---------------------------|
| Any input | SQL injection, NoSQL injection, command injection, LDAP injection, XSS (stored, reflected, DOM), CRLF injection, path traversal |
| Auth | Brute force, credential stuffing, session fixation, JWT tampering, replay, refresh-token rotation bypass |
| Authz | IDOR (insecure direct object reference), horizontal privilege escalation, vertical privilege escalation, missing function-level access control |
| Rate-limited | Burst (N+1 requests in 1s), sustained (above limit for 60s), distributed (multi-IP), bypass via header/IP rotation |
| Money / state | Concurrent double-spend, replay, race-condition on stale read, optimistic-locking conflict, idempotency-key reuse with different body |
| File upload | Oversized, wrong mime, double extension, zip bomb, polyglot file, SVG with XSS |
| Multi-tenant | Cross-tenant data leak via id manipulation, shared-cache leak, search filter bypass |

#### Non-Functional Categories

| Category | Test Ideas |
|----------|-----------|
| Performance | p50/p95/p99 latency under target load; cold-start; large payload; N+1 query detection |
| Concurrency | Same user double-submit; two users edit same resource; lock contention; eventual-consistency window |
| Reliability | Downstream timeout; downstream 5xx; circuit-breaker open; retry storm; partial network failure |
| Network | Slow 3G; offline; intermittent (5% packet loss); change network mid-action |
| Accessibility | Keyboard-only navigation; screen reader landmarks; color contrast; focus trap in modals; ARIA roles |
| Internationalization | RTL languages; long-text (German, Russian); CJK character widths; date/time/number locale formats; emoji in input |
| Compatibility | Min/max supported browsers; min/max viewport; touch vs mouse; reduced-motion preference |
| Data | Empty dataset; single row; pagination boundary (last page partial); 10k+ rows; deleted-then-referenced data |
| Time | DST transition; leap year; timezone mismatch (server vs client); clock skew; expired session mid-action |

### Step 5: Specify Oracles

Every test idea MUST declare HOW correctness is verified. Choose one or more:

| Oracle Type | Use When | Example |
|---|---|---|
| **State-based** | Asserting outcome state | `expect(user.status).toBe('active')` |
| **Interaction-based** | Asserting collaborator was called | `expect(emailService.send).toHaveBeenCalledWith(...)` — use sparingly |
| **Property-based** | Asserting invariants across many inputs | `fc.assert(fc.property(fc.string(), x => parse(stringify(x)) === x))` |
| **Snapshot** | Asserting structural equality vs. recorded | Visual / serialized object snapshots |
| **Metamorphic** | Asserting input transformations preserve a relation | `sort(reverse(L)) == sort(L)` |
| **Contract-schema** | Asserting response matches schema | OpenAPI/JSON Schema validation |
| **Differential** | Comparing two implementations | New vs. legacy parity test |
| **Human-judgment** | UX / a11y subjective | Manual review with rubric — flag in CI as non-blocking |

### Step 6: Mutation Sanity Check (Gate)

For every test idea, ask: *"If I mutate one line of the implementation in a plausible way, would this test catch it?"*

- Negate a boolean condition (`if (x > 0)` -> `if (x >= 0)`) — TC catches?
- Off-by-one (`i < n` -> `i <= n`) — TC catches?
- Swap operator (`+` -> `-`) — TC catches?
- Drop validation — TC catches?
- Swap arguments — TC catches?

If a TC cannot describe ANY mutation it would catch, REMOVE it. Tautological assertions (`expect(x).toBeDefined()` on a freshly assigned variable) are mutation-blind and inflate coverage without value.

### Step 7: Emit `test_ideas[]`

Output schema:

```yaml
test_ideas:
  - idea_id: TI-001
    title: "Reject transfer when source balance < amount (BVA boundary)"
    technique: BVA
    oracle: state-based
    risk: P0
    rationale: "Boundary just-below-min on balance — catches off-by-one in funds check"
  - idea_id: TI-002
    title: "Idempotency-key reuse with different body returns 409"
    technique: abuse
    oracle: contract-schema
    risk: P0
    rationale: "Replay protection — money-mover invariant"
```

### Step 8: Hand Off

The output `test_ideas[]` is the INPUT to `test-generation`, `api-testing`, `e2e-testing`, or `browser-testing`. Those skills convert ideas into TC-REGISTRY entries and executable test code.

[RESPONSE FORMAT]
Return results matching output_schema: `{ status, design_summary, test_ideas }`.

[VERIFICATION]
- [ ] Every test idea has a non-empty `technique` from the allowed set (no "edge case" / "misc")
- [ ] Every test idea has a non-empty `oracle` from the allowed set
- [ ] Every test idea has a `risk` tier
- [ ] At least 4 techniques applied per non-trivial feature
- [ ] Risk-calibrated ratios met per Step 4 (count + report in design_summary.ratios)
- [ ] At least one abuse case per applicable surface category (Step 4 table)
- [ ] Non-functional categories covered per risk tier
- [ ] Mutation Sanity Check applied — every surviving idea names a mutation it catches
- [ ] Decision tables (if applicable) cover every rule row including impossible combos
- [ ] State transition diagram (if applicable) covers legal + illegal transitions
````

- [ ] **Step 2: Create the SKILL.md symlink**

```bash
cd /Users/minh.ngo/mvn-hackathon-hn-timeless-resource-allocation-system/Engineer-team/skills/quality/test-case-design && ln -s test-case-design.md SKILL.md
```

- [ ] **Step 3: Verify validation passes for the new skill**

Run: `bash scripts/validate-hermes.sh --verbose 2>&1 | grep -i test-case-design`
Expected: no errors mentioning `test-case-design`.

- [ ] **Step 4: Commit**

```bash
git add skills/quality/test-case-design/
git commit -m "feat(quality): add test-case-design skill — systematic QA test-design techniques (BVA, EP, DT, ST, PW, RBT, abuse, non-functional, oracle, mutation gate)"
```

---

## Task 2: Upgrade `test-generation` skill to require techniques + oracles

**Why:** The current skill caps ambition at "≥30% negative tests" and lists 8 generic edge categories. Wire it to invoke `test-case-design` first, force the Technique/Oracle/Risk columns into TC-REGISTRY, and apply risk-calibrated ratios.

**Files:**
- Modify: `skills/quality/test-generation/test-generation.md`

- [ ] **Step 1: Update the `description`, `anti_patterns`, and `related_skills` fields**

Replace this block:

```yaml
description: "Generate test suites from source code and specs. Analyzes all branches, error paths, and edge cases — not just happy paths. Use when you need tests created from existing code, requirements, or user stories."
```

with:

```yaml
description: "Generate test suites from source code and specs by FIRST invoking test-case-design for systematic technique-based ideation, then materializing ideas into executable tests with TC-REGISTRY (Technique, Oracle, Risk columns). Use when you need expert-QC-grade tests from existing code, requirements, or user stories."
```

Replace this anti_patterns block:

```yaml
anti_patterns:
  - "Generating tests without analyzing the actual code implementation and its branches"
  - "Creating only happy-path tests and ignoring error paths, edge cases, and boundary conditions"
  - "Generating tests that duplicate the implementation logic instead of testing behavior"
```

with:

```yaml
anti_patterns:
  - "Skipping test-case-design and going straight to test code — produces happy-path-heavy output"
  - "Creating TCs without a Technique label (BVA/EP/DT/ST/PW/RBT/abuse/non_functional)"
  - "Creating TCs without an Oracle (state/interaction/property/snapshot/metamorphic/contract)"
  - "Duplicating implementation logic in tests instead of asserting observable behavior"
  - "Falling back to the flat 30% negative-ratio floor for P0/P1 features"
```

Replace this related_skills line:

```yaml
related_skills: ["test-driven-development", "api-testing", "browser-testing", "e2e-testing"]
```

with:

```yaml
related_skills: ["test-case-design", "test-driven-development", "api-testing", "browser-testing", "e2e-testing"]
```

- [ ] **Step 2: Replace the `[RULES]` block to require test-case-design + technique + oracle + risk-calibrated ratios**

Replace the entire `[RULES]` section (rules 1-12) with:

```markdown
[RULES]
1. <thought>Before generating any test, read the source code thoroughly. Identify all exported functions, conditional branches, error paths, and side effects.</thought>
2. **MANDATORY:** Invoke `test-case-design` skill FIRST to produce `test_ideas[]` with technique + oracle + risk per idea. Do NOT generate test code before ideas exist. If `test-case-design` was already run upstream, accept its output as the ideation source.
3. Every TC in the registry MUST carry: `Technique` (BVA/EP/DT/ST/PW/RBT/abuse/non_functional), `Oracle` (state/interaction/property/snapshot/metamorphic/contract/differential), `Risk` (P0/P1/P2/P3). Missing any field = TC rejected.
4. Apply the risk-calibrated ratio table from `test-case-design` Step 4. The flat 30% negative ratio is the floor for P3 only; P0 features require >=35% negative + >=15% abuse + >=10% non_functional.
5. Spend 70% of generation effort on error, abuse, boundary, and non-functional cases. Edge cases are where bugs live.
6. DO NOT generate tests without analyzing the actual code implementation and its branches.
7. DO NOT create only happy-path tests. Every error path and edge case must have explicit test cases.
8. DO NOT generate tests that duplicate implementation logic. Test behavior, not implementation.
9. Mutation Sanity Check — every TC must name a plausible mutation it catches (recorded in TC `Rationale`). Tautological assertions are rejected.
10. Fill every field in the test case template completely. Incomplete test cases create false confidence.
11. TC-ID convention: `TC-UNIT-NNN`, `TC-INT-NNN`, `TC-E2E-NNN`, `TC-PERF-NNN`, `TC-ABUSE-NNN`, `TC-A11Y-NNN`, `TC-I18N-NNN`.
12. Every interaction should teach something: explain why a TC matters in `Rationale`, name the technique.
13. TC-REGISTRY MUST include all 12 template fields (TC-ID, Title, Type, Technique, Oracle, Risk, Priority, Preconditions, Input, Steps, Expected Output, Tags). If a field is N/A, write "N/A" explicitly.
14. Steps MUST use numbered format. Each step = 1 atomic user action. No arrow-chains.
```

- [ ] **Step 3: Replace `### Step 3: GENERATE CASES` table with the expanded 12-column template**

Find this block:

```markdown
### Step 3: GENERATE CASES

Apply the structured test case template:

| Field | Description |
|---|---|
| **TC-ID** | `TC-UNIT-001`, `TC-INT-001`, `TC-E2E-001` |
| **Title** | Descriptive test case name |
| **Type** | unit / integration / e2e |
| **Preconditions** | What must be true before execution |
| **Input** | Structured input data |
| **Steps** | Ordered sequence of actions |
| **Expected Output** | Exact expected result |
| **Priority** | critical / high / medium / low |
| **Tags** | Categorization labels |
```

Replace with:

```markdown
### Step 3: GENERATE CASES (from test-case-design output)

For each entry in `test_ideas[]` (from test-case-design), materialize into a TC-REGISTRY row using this 12-field template:

| Field | Description |
|---|---|
| **TC-ID** | `TC-UNIT-001`, `TC-INT-001`, `TC-E2E-001`, `TC-ABUSE-001`, `TC-PERF-001`, `TC-A11Y-001`, `TC-I18N-001` |
| **Title** | Descriptive test case name |
| **Type** | unit / integration / e2e / abuse / perf / a11y / i18n |
| **Technique** | BVA / EP / DT / ST / PW / RBT / abuse / non_functional (from test-case-design) |
| **Oracle** | state / interaction / property / snapshot / metamorphic / contract-schema / differential / human-judgment |
| **Risk** | P0 / P1 / P2 / P3 (impact × likelihood) |
| **Priority** | critical / high / medium / low (execution ordering) |
| **Preconditions** | What must be true before execution — role, page, fixtures, env |
| **Input** | Structured input data (or "N/A" if no input) |
| **Steps** | Ordered numbered sequence of actions |
| **Expected Output** | Exact expected result AND mutation it would catch |
| **Tags** | Categorization labels (smoke, regression, security, validation, rbac, error-handling, perf, a11y, i18n, concurrency) |

If the `test_ideas[]` count is below the risk-calibrated floor, loop back to test-case-design rather than ship a thin registry.
```

- [ ] **Step 4: Replace the `### Edge Case Discovery` table with a deep checklist**

Find the block starting with `### Edge Case Discovery` and ending after the Concurrent / Expired rows.

Replace with:

```markdown
### Edge Case Discovery (per-parameter checklist)

This is a SUPPLEMENT to test-case-design — apply each row to every input parameter / state / dependency:

| Category | What to add | Technique label |
|---|---|---|
| Null / Undefined | `null`, `undefined`, missing field | EP |
| Empty | `""`, `[]`, `{}`, zero-length file | EP |
| Boundary numeric | min-1, min, min+1, max-1, max, max+1, MIN_SAFE_INTEGER, MAX_SAFE_INTEGER, NaN, Infinity, -Infinity, -0 | BVA |
| Boundary length | 0, 1, max-1, max, max+1, max+huge (10k, 1M) | BVA |
| Boundary time | epoch, year-2038, DST transition, leap day, leap second, timezone offsets | BVA |
| Type mismatch | string-where-int, int-where-string, array-where-object, wrong-enum-value | EP |
| Special chars | Unicode (combining marks, RTL, ZWJ, emoji), control chars (\0, \r, \n, \t), surrogate pairs | EP |
| Injection payloads | `' OR 1=1--`, `<script>`, `{{7*7}}`, `${jndi:...}`, `../../../etc/passwd`, `\x00.png` | abuse |
| Oversized | 10k-char string, 100MB upload, 100k array items, deeply nested JSON | BVA + abuse |
| Concurrent | Double-submit, race condition on same resource, optimistic-lock conflict, idempotency-key reuse | abuse / non_functional |
| Expired | Expired session/token, soft-deleted record, archived account, revoked permission | EP |
| Network | Slow 3G, offline, intermittent, mid-request disconnect, timeout, partial response | non_functional |
| Cross-tenant | Foreign tenant id, shared cache, escaped filter scope | abuse |
| Permission | No role, lower role, role just-removed mid-session, role with wildcard | DT |
| Pagination | page=0, page=-1, page=BIG, size=0, size=MAX+1, last-page-partial, single-row, empty-set | BVA |
| Sorting | unknown field, multi-field, conflicting direction, null-handling in sort | EP |
| Filtering | unknown filter, conflicting filters, type-mismatch filter, escape characters in filter value | EP |
| Locale | RTL (Arabic, Hebrew), long-text (German, Russian), CJK widths, date formats DMY/MDY/YMD, decimal `,` vs `.` | non_functional |
| Accessibility | Keyboard-only path, screen-reader landmark, focus trap, color contrast, prefers-reduced-motion | non_functional |
| State invariant | Money totals balance; counters non-negative; soft-delete preserves history | metamorphic oracle |

For every checklist row that applies, emit a TC (or document why N/A in the Rationale).
```

- [ ] **Step 5: Replace the `### Step 4.5: OUTPUT QUALITY GATE` checklist**

Replace the existing Output Quality Gate checklist with this stricter version:

```markdown
### Step 4.5: OUTPUT QUALITY GATE

Before exporting TC-REGISTRY, verify against this checklist. **If any check fails, fix BEFORE proceeding to Step 5.**

- [ ] Table has all 12 columns: TC-ID | Title | Type | Technique | Oracle | Risk | Priority | Preconditions | Input | Steps | Expected Output | Tags
- [ ] Every TC has Technique from {BVA, EP, DT, ST, PW, RBT, abuse, non_functional}
- [ ] Every TC has Oracle from {state, interaction, property, snapshot, metamorphic, contract-schema, differential, human-judgment}
- [ ] Every TC has Risk tier (P0/P1/P2/P3)
- [ ] Risk-calibrated ratios met:
      - P0: positive <=40%, negative >=35%, abuse >=15%, non_functional >=10%
      - P1: positive <=50%, negative >=30%, abuse >=10%, non_functional >=10%
      - P2: positive <=60%, negative >=25%, abuse >=5%, non_functional >=5%
      - P3: positive <=70%, negative >=25%
- [ ] At least 1 abuse TC per applicable surface (input / auth / authz / rate / money / file-upload / multi-tenant)
- [ ] Non-functional coverage per risk tier (perf / concurrency / network / a11y / i18n / time)
- [ ] Mutation Sanity Check applied — every TC names a mutation it catches (in Expected Output or Rationale)
- [ ] Steps use numbered format (1. 2. 3.), not narrative arrows (->)
- [ ] Input column has explicit test data values or "N/A"
- [ ] Preconditions specify: user role, starting page, fixture state
- [ ] Expected Output specifies: assertion type + exact value
- [ ] Tags assigned to each TC (smoke, regression, security, validation, rbac, error-handling, perf, a11y, i18n, concurrency)
- [ ] Coverage Map links each Acceptance Criterion to >=1 TC-ID
```

- [ ] **Step 6: Update `[VERIFICATION]` checklist**

Append these items to the existing checklist:

```markdown
- [ ] test-case-design skill invoked first; `test_ideas[]` exists before TC generation
- [ ] At least 4 techniques applied per non-trivial feature
- [ ] Risk-calibrated ratios met per declared risk_tier
- [ ] Abuse TCs cover all applicable surfaces
- [ ] Non-functional TCs cover applicable categories per risk tier
- [ ] Mutation Sanity Check signed off — every surviving TC names a mutation it catches
```

- [ ] **Step 7: Bump version and validate**

Change `version: "3.0.0"` to `version: "4.0.0"` in the YAML frontmatter.

Run: `bash scripts/validate-hermes.sh --verbose 2>&1 | grep -i test-generation`
Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add skills/quality/test-generation/test-generation.md
git commit -m "feat(test-generation): require test-case-design + technique/oracle/risk columns + risk-calibrated ratios"
```

---

## Task 3: Upgrade `api-testing` skill with OWASP API Top 10 + non-functional checklist

**Why:** Current skill only mentions generic 400/401/403/404/500 paths. Real API QA covers OWASP API Security Top 10 (BOLA, broken auth, BFLA, mass assignment, etc.), idempotency, pagination/filter/sort boundaries, content negotiation, and rate-limit modalities.

**Files:**
- Modify: `skills/quality/api-testing/api-testing.md`

- [ ] **Step 1: Update `description`, `anti_patterns`, `related_skills`**

Replace `description`:

```yaml
description: "API testing for integration, contract verification, security (OWASP API Top 10), and non-functional benchmarking. Use when testing API endpoints, verifying integrations, ensuring contracts, validating abuse cases, or benchmarking response times."
```

Append to `anti_patterns`:

```yaml
  - "Skipping OWASP API Top 10 abuse cases (BOLA, BFLA, mass assignment, excessive data exposure)"
  - "Treating idempotency, pagination boundaries, and content negotiation as nice-to-have"
  - "Validating happy paths only across CRUD without abuse, concurrency, and rate-limit modalities"
```

Add `test-case-design` to `related_skills`:

```yaml
related_skills: ["test-case-design", "e2e-testing", "security-audit", "api-interface-design", "performance-optimization", "test-generation"]
```

- [ ] **Step 2: Insert OWASP API Top 10 mapping section**

Inside `[PROCESS]`, after `### Step 2: Define Test Categories` and BEFORE `### Step 3: Write Tests Using Structured Contracts`, insert:

````markdown
### Step 2.5: OWASP API Security Top 10 Mapping (MANDATORY for any API exposed beyond same-process)

For every endpoint, emit at least one abuse TC per applicable row:

| OWASP API | Threat | TC Pattern |
|---|---|---|
| API1 BOLA | Object access via id manipulation | `GET /users/{otherTenantUserId}` with valid token from different tenant -> expect 403/404 |
| API2 Broken Auth | Token reuse, weak rotation | Replay expired/revoked token; use refresh after logout |
| API3 BOPLA / Mass Assignment | Extra fields override server-controlled props | POST with `{"role":"admin"}` from non-admin -> field stripped or 400 |
| API4 Unrestricted Resource Consumption | DoS via large payload, deep nesting, regex | POST 100MB JSON; 10k-element array; deeply nested `{a:{a:{...100x}}}` |
| API5 BFLA | Function-level access control bypass | Non-admin POST/DELETE on admin endpoints -> 403 |
| API6 Unrestricted Business Flow Access | Abuse a legitimate flow (mass coupon, automated checkout) | 1000 sequential coupon requests -> rate-limit or business-rule reject |
| API7 SSRF | URL parameter triggers server-side fetch | `image_url=http://169.254.169.254/...` (AWS metadata) -> reject |
| API8 Security Misconfig | Default creds, verbose errors, missing CORS | Probe error envelopes; check CORS preflight; default-creds login |
| API9 Improper Inventory | Old/staging endpoints exposed | Probe `/v1/users` after `/v2/users` deploy; check `/.well-known/`, `/admin`, `/debug` |
| API10 Unsafe API Consumption | Untrusted upstream returned to user | Mock upstream returning XSS / unexpected JSON shape -> verify sanitization or rejection |

Add these TC patterns to your registry. Tag with `security` and `abuse`.

### Step 2.6: API Non-Functional Checklist

For every endpoint, decide which apply and emit TCs:

| Concern | TC Pattern |
|---|---|
| Idempotency | Repeat same `Idempotency-Key` with same body -> same response, no duplicate side effect |
| Idempotency abuse | Repeat same `Idempotency-Key` with DIFFERENT body -> 409 / 422 (key reuse with diverging payload) |
| Pagination boundary | `page=0`, `page=-1`, `page=BIG`, `size=0`, `size=MAX+1`, last-page-partial, single-row, empty-set |
| Sorting | Unknown sort field, multi-field sort, conflicting direction, null-handling |
| Filtering | Unknown filter, conflicting filters, escape characters in filter value, range filter min>max |
| Content negotiation | `Accept: application/xml` when server only supports JSON -> 406; `Content-Type` mismatch -> 415 |
| Versioning | Old version still works; deprecated header surfaces; sunset header present |
| Conditional requests | `If-Match` / `If-None-Match` / `If-Modified-Since` honored; ETag changes on update |
| Concurrency | Two simultaneous PATCH on same resource -> last-write-wins OR optimistic-lock 409 (depending on spec) |
| Rate limiting | Burst (N+1 in 1s); sustained (above limit for 60s); rate-limit headers present (`RateLimit-Limit`, `RateLimit-Remaining`, `Retry-After`) |
| Error envelope | Every error response matches the documented error schema (code, message, details, trace_id) |
| Long-running | Async job creates 202 + status URL; polling returns terminal state; webhook delivery & retry |
| Webhooks (if any) | Signature verification; replay protection; out-of-order delivery; failure -> retry policy |
````

- [ ] **Step 3: Update `[RULES]` to require test-case-design and abuse coverage**

Replace rules 4-7 of the existing `[RULES]` block:

Find:
```markdown
4. DO NOT test only the happy path. Spend equal effort on 400, 401, 403, 404, and 500 responses.
5. DO NOT let tests depend on execution order or shared mutable state.
6. DO NOT hardcode test data that causes conflicts in parallel execution. Use unique identifiers (timestamps, UUIDs).
7. Validate response time against defined SLA thresholds for every critical endpoint.
```

Replace with:

```markdown
4. **MANDATORY:** Invoke `test-case-design` first for non-trivial endpoints; convert `test_ideas[]` into contract tests. Skip only for pure echo / health-check endpoints.
5. Cover OWASP API Top 10 per Step 2.5 — every endpoint gets at least one BOLA/BFLA/mass-assignment probe.
6. Cover API non-functional checklist per Step 2.6 — idempotency, pagination, content negotiation, rate limiting, error envelope.
7. DO NOT test only the happy path. P0 endpoints require >=35% negative + >=15% abuse TCs.
8. DO NOT let tests depend on execution order or shared mutable state.
9. DO NOT hardcode test data that causes conflicts in parallel execution. Use unique identifiers (timestamps, UUIDs).
10. Validate response time against defined SLA thresholds for every critical endpoint.
```

(Renumber remaining rules accordingly.)

- [ ] **Step 4: Update `[VERIFICATION]` checklist**

Append:

```markdown
- [ ] test-case-design invoked for non-trivial endpoints
- [ ] OWASP API Top 10 mapping completed; >=1 abuse TC per applicable row
- [ ] Idempotency tested for POST/PUT/PATCH endpoints declaring idempotency-key
- [ ] Pagination boundaries tested (page=0, page=-1, page=BIG, size=0, size=MAX+1)
- [ ] Content negotiation tested (406, 415)
- [ ] Concurrency tested (simultaneous PATCH)
- [ ] Rate-limit headers present + 429 on burst
- [ ] Error envelope schema validated on every error response
```

- [ ] **Step 5: Bump version + validate**

Change `version: "3.0.0"` to `version: "4.0.0"`.

Run: `bash scripts/validate-hermes.sh --verbose 2>&1 | grep -i api-testing`

- [ ] **Step 6: Commit**

```bash
git add skills/quality/api-testing/api-testing.md
git commit -m "feat(api-testing): add OWASP API Top 10 mapping + non-functional checklist (idempotency, pagination, content negotiation, rate limit, error envelope)"
```

---

## Task 4: Upgrade `e2e-testing` skill with full user-journey edge-case matrix

**Why:** Current "Edge cases — Empty states, boundary values, concurrent actions" is too vague. Real E2E expert QA covers mid-flow interruption (refresh, back button, network drop, session expiry), double-submit, tab switching, deep link, browser-back-after-submit, etc.

**Files:**
- Modify: `skills/quality/e2e-testing/e2e-testing.md`

- [ ] **Step 1: Add `test-case-design` to `related_skills`**

Replace:
```yaml
related_skills: ["browser-testing", "api-testing", "ci-cd-automation"]
```
With:
```yaml
related_skills: ["test-case-design", "browser-testing", "api-testing", "ci-cd-automation"]
```

- [ ] **Step 2: Insert a user-journey edge-case matrix after Step 4**

After `### Step 4: Write E2E Tests` (after the existing code block ending with `});` and BEFORE `### Step 5: Configure Evidence Recording`), insert:

````markdown
### Step 4.5: User-Journey Edge-Case Matrix

For every critical journey, add TCs from this matrix. These are the cases happy-path-only suites miss:

| Category | Test Idea |
|---|---|
| Interruption: refresh | User refreshes page mid-form (step N of multi-step wizard) -> data preserved OR user warned |
| Interruption: back/forward | Back-button after submit -> idempotent; deep link to step 3 with no step-1 state -> redirect / restore |
| Interruption: tab switch | Open same flow in 2 tabs; complete in tab A; tab B handles stale state (refresh / error) |
| Interruption: network drop | Network drops at submit; client retries idempotently; UI shows recoverable error |
| Interruption: session expiry | Session expires mid-flow; user redirected to login; after login -> resume OR clear error |
| Concurrency: double-submit | Double-click submit button -> only one action recorded (idempotency key OR client debounce) |
| Concurrency: same user 2 tabs | Same user edits same resource in 2 tabs -> optimistic-lock OR last-write-wins per spec |
| Data: empty state | First-time user (no data) sees empty-state UI with CTA |
| Data: large dataset | 10k+ rows -> pagination/virtualization works; no UI freeze |
| Data: paginated boundary | Last page partial; navigate forward/backward; deep link to page=N |
| Permission: role downgrade | User starts as admin; role removed mid-session; next action -> 403 + graceful UI |
| Permission: just-revoked link | Click email link to resource user no longer has access to -> friendly 403 |
| Validation: client + server mismatch | Client validates "OK", server rejects -> error displayed inline, not generic |
| Validation: server-only rule | Field passes client validation but fails business rule (e.g., duplicate) -> inline error |
| Browser: back-after-submit | Back-button after successful submit -> does NOT re-submit; shows success state OR resource page |
| Browser: bookmarkable URL | All flow steps survive bookmark + reopen (auth required redirects to login -> back to bookmark) |
| Browser: copy-paste credentials | Paste into password / OTP fields works |
| Mobile: rotation mid-flow | Portrait -> landscape rotation -> state preserved, layout correct |
| Mobile: keyboard cover | iOS keyboard covers submit button -> scroll/avoid |
| A11y: keyboard-only path | Complete entire journey using only Tab / Shift+Tab / Enter / Space |
| A11y: screen reader | Verify landmarks, live regions for async errors, focus order |
| I18n: RTL language | Switch to Arabic/Hebrew -> layout mirrors; form alignment correct |
| I18n: long-text language | Switch to German -> CTAs don't truncate; labels wrap correctly |
| Performance: cold start | First-time load on cold cache; LCP <2.5s, CLS <0.1, INP <200ms |
| Resilience: backend slow | Mock 3s delay on critical API -> loading state shown, no double-spinner, no jank |
| Resilience: backend 5xx | Mock 500 on critical API -> error UI with retry CTA |
| Resilience: backend partial | Mock 500 on non-critical API (e.g., recommendations) -> main flow continues |

Tag these as `interruption`, `concurrency`, `a11y`, `i18n`, `resilience`, or `mobile`. Risk-tier per business impact.
````

- [ ] **Step 3: Update `[RULES]` — add test-case-design requirement**

Insert as new rule 2 (push existing rules down):

```markdown
2. **MANDATORY:** Invoke `test-case-design` first for each critical journey to produce `test_ideas[]` covering interruption, concurrency, permission, a11y, i18n, and resilience categories from Step 4.5.
```

- [ ] **Step 4: Update `[VERIFICATION]` checklist**

Append:

```markdown
- [ ] test-case-design invoked per critical journey
- [ ] Interruption cases covered (refresh, back-button, tab-switch, network-drop, session-expiry) for >=top 2 critical journeys
- [ ] Concurrency cases covered (double-submit, same-user-2-tabs) for state-changing journeys
- [ ] Permission cases covered (role-downgrade, just-revoked-link) for >=1 protected journey
- [ ] A11y journey: keyboard-only full path passes
- [ ] I18n: >=1 RTL or long-text language verified
- [ ] Resilience: backend-slow + backend-5xx mocks tested
```

- [ ] **Step 5: Bump version + validate**

Change `version: "3.0.0"` to `version: "4.0.0"`.

Run: `bash scripts/validate-hermes.sh --verbose 2>&1 | grep -i e2e-testing`

- [ ] **Step 6: Commit**

```bash
git add skills/quality/e2e-testing/e2e-testing.md
git commit -m "feat(e2e-testing): add user-journey edge-case matrix (interruption, concurrency, permission, a11y, i18n, resilience)"
```

---

## Task 5: Upgrade `browser-testing` skill with UI state matrix + a11y/i18n checklist

**Why:** Current Quality Standards table is post-hoc validation, not test ideation. UI components have predictable state matrices that every component must satisfy: loading × empty × partial × error × success × no-permission × stale-data. Plus a11y/i18n surface.

**Files:**
- Modify: `skills/quality/browser-testing/browser-testing.md`

- [ ] **Step 1: Add `test-case-design` to `related_skills`**

Replace:
```yaml
related_skills: ["e2e-testing", "frontend-patterns", "performance-optimization", "test-generation"]
```
With:
```yaml
related_skills: ["test-case-design", "e2e-testing", "frontend-patterns", "performance-optimization", "test-generation"]
```

- [ ] **Step 2: Insert UI State Matrix section after Step 3**

After `### Step 3: Write Tests for User Flows` and BEFORE `### Step 4: Implement Evidence Collection`, insert:

````markdown
### Step 3.5: UI State Matrix (per component / page)

For every screen or component-under-test, verify ALL these states render correctly:

| State | Trigger | Assertion |
|---|---|---|
| Loading | Initial mount with pending request | Spinner / skeleton present; no flash of empty state |
| Empty | API returns `[]` / 204 | Empty-state copy + CTA visible; no error UI |
| Partial | API returns subset (e.g., 3 of 10 expected) | Renders subset; no infinite-load; pagination/load-more visible |
| Error: 4xx | API returns 400/403/404 | Friendly error UI with actionable next step (login, contact, retry) |
| Error: 5xx | API returns 500/502/503 | Generic error UI with retry CTA |
| Error: network | Network unreachable | Offline indicator OR retry CTA |
| Success | API returns expected data | Data rendered; no console errors |
| Permission-denied | User lacks permission | Disabled action OR friendly 403 (not silent fail) |
| Stale data | Data older than freshness threshold | Stale indicator (e.g., "Updated 5m ago") |
| Realtime update | New data arrives while viewing | List updates without losing scroll / selection |
| Mutation pending | User submits; response not yet returned | Button shows pending state; disabled to prevent double-submit |
| Mutation success | Submit completes 200 | Success toast / inline confirmation; data updates |
| Mutation failure | Submit returns 4xx/5xx | Error inline / toast; form data preserved for retry |
| Optimistic + rollback | Optimistic UI updates; server rejects | UI rolls back; user sees error |

### Step 3.6: A11y + I18n Checklist

| Concern | Test Idea |
|---|---|
| Keyboard navigation | Tab order matches visual order; focus visible; no keyboard traps |
| Screen reader | All interactive elements have accessible name (aria-label / textContent); landmarks present (header/main/nav/footer) |
| ARIA live | Async errors and successes announce to screen readers (aria-live="polite" or "assertive") |
| Color contrast | All text >= WCAG AA (4.5:1 normal, 3:1 large); no color-only state indication |
| Focus management | Modal open -> focus moves into modal; close -> focus returns to trigger |
| Prefers-reduced-motion | Animations respect `prefers-reduced-motion: reduce` |
| Zoom 200% | UI usable at 200% zoom without horizontal scroll |
| Touch targets | Interactive elements >= 44x44px on touch |
| RTL | Switch to Arabic / Hebrew -> mirrored layout, correct text direction |
| Long-text | Switch to German / Russian -> labels don't truncate, CTAs wrap |
| CJK widths | Switch to Japanese / Chinese -> character widths render correctly |
| Date / number formats | Locale-specific format (DMY vs MDY, `,` vs `.` decimal) |
| Emoji input | Emoji in text inputs persists correctly through save/load |
````

- [ ] **Step 3: Update `[RULES]` — add test-case-design + UI state matrix requirement**

Insert as new rule 2 (push existing rules down):

```markdown
2. **MANDATORY:** Invoke `test-case-design` first; cover the UI State Matrix (loading/empty/partial/error/success/no-permission/stale/mutation states per Step 3.5) and the A11y + I18n checklist (per Step 3.6).
```

- [ ] **Step 4: Update `[VERIFICATION]` checklist**

Append:

```markdown
- [ ] test-case-design invoked for non-trivial UI surfaces
- [ ] UI State Matrix covered per component (loading, empty, partial, 4xx, 5xx, success, permission-denied, mutation-pending, mutation-success, mutation-failure)
- [ ] A11y checklist: keyboard nav, screen reader, color contrast, focus management, prefers-reduced-motion
- [ ] I18n checklist: RTL, long-text, CJK widths, locale formats
```

- [ ] **Step 5: Bump version + validate**

Change `version: "3.0.0"` to `version: "4.0.0"`.

Run: `bash scripts/validate-hermes.sh --verbose 2>&1 | grep -i browser-testing`

- [ ] **Step 6: Commit**

```bash
git add skills/quality/browser-testing/browser-testing.md
git commit -m "feat(browser-testing): add UI State Matrix + a11y/i18n checklist for component-level coverage"
```

---

## Task 6: Upgrade `test-engineer` and `brownfield-test-engineer` agents

**Why:** Agents own the orchestration. They must call `test-case-design` first, require technique attribution per TC, raise the quality gate, and prioritize by risk.

**Files:**
- Modify: `agents/test-engineer.md`
- Modify: `agents/brownfield-test-engineer.md`

- [ ] **Step 1: Update `test-engineer` `[AVAILABLE SKILLS]` block**

Replace:
```markdown
[AVAILABLE SKILLS]
- test-driven-development
- test-generation
- e2e-testing
- browser-testing
- api-testing
```
With:
```markdown
[AVAILABLE SKILLS]
- test-case-design          # MANDATORY first step for non-trivial features
- test-driven-development
- test-generation
- e2e-testing
- browser-testing
- api-testing
```

Also add to YAML `related_skills`:
```yaml
related_skills:
  - test-case-design
  - test-driven-development
  - test-generation
  - e2e-testing
  - browser-testing
  - api-testing
```

- [ ] **Step 2: Replace `test-engineer` `[RULES]` block**

Replace:
```markdown
[RULES]
1. Run `<thought>` before every action to plan your testing approach.
2. Iron Law: NO PRODUCTION CODE WITHOUT FAILING TEST. Enforce TDD when generating tests.
3. ABC: Teach testing best practices in every recommendation. Explain WHY a test matters.
4. Test behavior, not implementation. Use AAA pattern (Arrange-Act-Assert).
5. Generate tests from requirements first, then from code analysis for gap coverage.
6. Every test case gets a structured ID: TC-UNIT-001, TC-INT-001, TC-E2E-001.
7. For E2E tests, configure video recording and collect the evidence triad (screenshot, video, trace) on failure.
8. Define per-endpoint SLA targets for API contract tests (simple GET P95 < 150ms, complex P95 < 500ms, writes P95 < 1000ms).
9. Report status per the Status Protocol.
```

With:
```markdown
[RULES]
1. Run `<thought>` before every action to plan your testing approach. Start by classifying the feature risk tier (P0/P1/P2/P3) and recording it in test_strategy.
2. **MANDATORY:** Invoke `test-case-design` skill FIRST for any non-trivial feature; do NOT skip to test-generation. Pass `risk_tier` + spec excerpt to test-case-design; consume `test_ideas[]` as input to materialization.
3. Iron Law: NO PRODUCTION CODE WITHOUT FAILING TEST. Enforce TDD when generating tests.
4. Every TC carries Technique, Oracle, Risk in addition to TC-ID, Title, Type, Priority. Missing any field -> TC rejected at quality gate.
5. Apply risk-calibrated ratios: P0 (>=35% neg + >=15% abuse + >=10% non_func), P1 (>=30% + >=10% + >=10%), P2 (>=25% + >=5% + >=5%), P3 (>=25% neg).
6. Mutation Sanity Check is a gate, not advice. Every TC must name a plausible mutation it catches in its Rationale.
7. ABC: Teach testing best practices in every recommendation. Explain WHY a test matters AND which technique it applies.
8. Test behavior, not implementation. Use AAA pattern (Arrange-Act-Assert).
9. Generate tests from requirements first (via test-case-design), then from code analysis for gap coverage.
10. TC-ID conventions: `TC-UNIT-NNN`, `TC-INT-NNN`, `TC-E2E-NNN`, `TC-ABUSE-NNN`, `TC-PERF-NNN`, `TC-A11Y-NNN`, `TC-I18N-NNN`.
11. For E2E tests, configure video recording and collect the evidence triad (screenshot, video, trace) on failure.
12. Define per-endpoint SLA targets for API contract tests (simple GET P95 < 150ms, complex P95 < 500ms, writes P95 < 1000ms).
13. Report status per the Status Protocol.
```

- [ ] **Step 3: Replace `test-engineer` `[PROCESS]` Step 3 with the 12-field template**

Find:
```markdown
### Step 3: GENERATE CASES
Apply structured template for each test scenario:

| Field | Description |
|---|---|
| TC-ID | TC-UNIT-001, TC-INT-001, TC-E2E-001 |
| Title | Descriptive test case name |
| Type | unit / integration / e2e |
| Preconditions | What must be true before execution |
| Input | Structured input data |
| Expected Output | Exact expected result |
| Priority | critical / high / medium / low |
```

Replace with:
```markdown
### Step 3: GENERATE CASES (consume test-case-design output)

For each entry in `test_ideas[]` from test-case-design, materialize into a TC-REGISTRY row using the 12-field template:

| Field | Description |
|---|---|
| TC-ID | TC-UNIT-001, TC-INT-001, TC-E2E-001, TC-ABUSE-001, TC-PERF-001, TC-A11Y-001, TC-I18N-001 |
| Title | Descriptive test case name |
| Type | unit / integration / e2e / abuse / perf / a11y / i18n |
| Technique | BVA / EP / DT / ST / PW / RBT / abuse / non_functional |
| Oracle | state / interaction / property / snapshot / metamorphic / contract-schema / differential |
| Risk | P0 / P1 / P2 / P3 |
| Priority | critical / high / medium / low |
| Preconditions | Role, page, fixtures, env |
| Input | Structured input data (or "N/A") |
| Steps | Numbered atomic steps |
| Expected Output | Exact expected result + mutation it catches |
| Tags | smoke, regression, security, validation, rbac, error-handling, perf, a11y, i18n, concurrency |

If the materialized count is below the risk-calibrated floor, loop back to test-case-design.
```

- [ ] **Step 4: Update `test-engineer` Completion Marker**

Replace the Completion Marker block at the end with:

```markdown
## Completion Marker

- [ ] Feature risk tier declared (P0/P1/P2/P3)
- [ ] test-case-design invoked; test_ideas[] produced
- [ ] Test strategy defined with risk-calibrated ratios
- [ ] Test cases generated with structured IDs AND technique + oracle + risk per TC
- [ ] Mutation Sanity Check applied — every TC names a mutation it catches
- [ ] Abuse cases generated per applicable surface
- [ ] Non-functional cases generated per risk tier
- [ ] Fixtures created
- [ ] Coverage targets met
- [ ] Tests are independent and fast
- [ ] Video recording configured for E2E tests
- [ ] API contracts validated with timing data
- [ ] Test evidence report generated
```

- [ ] **Step 5: Apply parallel updates to `brownfield-test-engineer.md`**

  a. Add `test-case-design` to `[AVAILABLE SKILLS]` block (as first entry, marked MANDATORY).
  b. Add `test-case-design` to YAML `related_skills` if such field exists, or to `collaborates_with` list.
  c. In `[RULES]`, insert as new rule 2:
     ```markdown
     2. **MANDATORY:** Invoke `test-case-design` skill after Step 2 (codebase exploration) and BEFORE Step 3 (generate test cases). Pass risk_tier + identified module + spec to test-case-design; consume test_ideas[] as input to TC generation.
     ```
     Renumber subsequent rules.
  d. Replace Step 3.5 VALIDATE TC QUALITY checklist with the stricter version (mirrors Task 2 Step 5).
  e. In Completion Marker, add:
     ```markdown
     - [ ] test-case-design invoked; test_ideas[] consumed
     - [ ] Every TC has Technique + Oracle + Risk fields
     - [ ] Risk-calibrated ratios met
     - [ ] Mutation Sanity Check applied
     - [ ] Abuse cases per applicable surface
     ```

- [ ] **Step 6: Bump versions + validate**

Change `test-engineer.md` `version: 2.0.0` -> `version: 3.0.0`.
Change `brownfield-test-engineer.md` `version: 2.0.0` -> `version: 3.0.0`.

Run: `bash scripts/validate-hermes.sh --verbose 2>&1 | grep -E "(test-engineer|brownfield-test-engineer)"`
Expected: no errors.

- [ ] **Step 7: Commit**

```bash
git add agents/test-engineer.md agents/brownfield-test-engineer.md
git commit -m "feat(agents): require test-case-design + technique/oracle/risk + risk-calibrated ratios + mutation gate in test-engineer and brownfield-test-engineer"
```

---

## Task 7: Create canonical TC-REGISTRY template + upgrade testing-standards + spec-template

**Why:** Right now TC-REGISTRY format lives inline in multiple skill files. Extract to a single template; update project-DNA testing-standards to reference the 12-column format; require spec authors to enumerate negative/abuse/non-functional acceptance criteria so downstream test generation has something to expand.

**Files:**
- Create: `templates/TC-REGISTRY.template.md`
- Modify: `templates/project-dna/rules/testing-standards.template.md`
- Modify: `templates/spec-template.md`

- [ ] **Step 1: Create `templates/TC-REGISTRY.template.md`** with content below

````markdown
# Test Case Registry

> Canonical TC-REGISTRY format. Use the 12-column table. Every TC must carry Technique, Oracle, and Risk.

## Risk-Calibrated Ratio Targets

Declared feature risk tier: `<P0 | P1 | P2 | P3>`

Floors (counted from final registry):

| risk_tier | positive | negative | abuse | non_functional |
|-----------|----------|----------|-------|----------------|
| P0        | <=40%    | >=35%    | >=15% | >=10%          |
| P1        | <=50%    | >=30%    | >=10% | >=10%          |
| P2        | <=60%    | >=25%    | >=5%  | >=5%           |
| P3        | <=70%    | >=25%    | optional | optional    |

Current counts: positive=__ / negative=__ / abuse=__ / non_functional=__ / total=__

## Requirement Trace Matrix

| Spec Requirement | TC-IDs | Code Files | Coverage |
|---|---|---|---|
| R1: ... | TC-INT-001, TC-E2E-001 | path/to/file.ts | COVERED |

## Test Cases (12 columns — all required)

| TC-ID | Title | Type | Technique | Oracle | Risk | Priority | Preconditions | Input | Steps | Expected Output (incl. mutation caught) | Tags |
|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-UNIT-001 | should reject transfer when balance < amount | unit | BVA | state | P0 | critical | user A has balance=99; amount=100 | { from:A, to:B, amount:100 } | 1. Call transfer(A,B,100) 2. Assert thrown | Throws InsufficientFunds; catches off-by-one in `if (balance > amount)` mutation | error-handling, money |
| TC-ABUSE-001 | should reject Idempotency-Key reuse with different body | integration | abuse | contract-schema | P0 | critical | first call already accepted with key=K | reuse K with body=B' != B | 1. POST /transfer with key=K body=B' 2. Assert 409 | 409 + error.code=idempotency_conflict; catches mutation that ignores body diff | security, abuse, idempotency |

## Allowed Values

- **Type:** unit / integration / e2e / abuse / perf / a11y / i18n
- **Technique:** BVA / EP / DT / ST / PW / RBT / abuse / non_functional
- **Oracle:** state / interaction / property / snapshot / metamorphic / contract-schema / differential / human-judgment
- **Risk:** P0 / P1 / P2 / P3
- **Priority:** critical / high / medium / low
- **Tags:** smoke, regression, security, validation, rbac, error-handling, perf, a11y, i18n, concurrency, mobile, resilience, idempotency, interruption

## Quality Gate (must pass before sign-off)

- [ ] All 12 columns filled (N/A allowed only where structurally inapplicable)
- [ ] Technique attributed per TC
- [ ] Oracle attributed per TC
- [ ] Risk tier attributed per TC
- [ ] Risk-calibrated ratios met
- [ ] At least 1 abuse TC per applicable surface (input / auth / authz / rate / money / file-upload / multi-tenant)
- [ ] Non-functional TCs cover applicable categories per risk tier
- [ ] Every acceptance criterion mapped to >=1 TC
- [ ] Mutation Sanity Check passed — every TC names a mutation it catches
````

- [ ] **Step 2: Upgrade `templates/project-dna/rules/testing-standards.template.md`**

Replace the section starting with `## Test File Conventions` and ending before `## TDD Enforcement` with the following expanded version:

```markdown
## Test File Conventions

| Source File | Test File | Location |
|------------|-----------|----------|
| `src/[context]/domain/user.ts` | `tests/unit/[context]/domain/user.test.ts` | Mirror src/ structure |
| `src/[context]/application/register.ts` | `tests/integration/[context]/register.test.ts` | Integration tests |
| Critical user path | `tests/e2e/[path-name].spec.ts` | E2E tests |
| Abuse / security probe | `tests/abuse/[surface].abuse.test.ts` | Abuse / security |
| Performance benchmark | `tests/perf/[scope].perf.test.ts` | Perf |
| Accessibility | `tests/a11y/[surface].a11y.test.ts` | A11y |
| Internationalization | `tests/i18n/[surface].i18n.test.ts` | I18n |

## TC-REGISTRY Format

All TC registries follow `templates/TC-REGISTRY.template.md` (12 columns: TC-ID, Title, Type, Technique, Oracle, Risk, Priority, Preconditions, Input, Steps, Expected Output, Tags).

## Risk-Calibrated Negative + Abuse + Non-Functional Floors

| risk_tier | positive | negative | abuse | non_functional |
|-----------|----------|----------|-------|----------------|
| P0        | <=40%    | >=35%    | >=15% | >=10%          |
| P1        | <=50%    | >=30%    | >=10% | >=10%          |
| P2        | <=60%    | >=25%    | >=5%  | >=5%           |
| P3        | <=70%    | >=25%    | optional | optional    |

## Coverage Requirements

| Scope | Minimum | Target |
|-------|---------|--------|
| Overall | [e.g., 80%] | [e.g., 90%] |
| Domain layer | [e.g., 95%] | [e.g., 100%] |
| Application layer | [e.g., 85%] | [e.g., 95%] |
| Infrastructure layer | [e.g., 70%] | [e.g., 80%] |
| Critical paths (auth, payments, data integrity) | 100% | 100% |

## Required Test-Design Techniques

For every non-trivial feature, apply at least 4 of: BVA, EP, DT, ST, Pairwise, RBT. See `skills/quality/test-case-design/test-case-design.md`.

## Mandatory Oracle Specification

Every TC names its oracle from: state, interaction, property, snapshot, metamorphic, contract-schema, differential, human-judgment. No oracle = vacuous test.

## Mutation Sanity Gate

Before sign-off, every TC must name a plausible mutation it catches in its Rationale / Expected Output column.

## Test Structure

Follow **Arrange-Act-Assert** (AAA) pattern:

(... existing AAA code block stays unchanged ...)
```

- [ ] **Step 3: Update `templates/spec-template.md` — add negative/abuse/non-functional acceptance criteria sections**

Read the current template first:

```bash
cat templates/spec-template.md
```

Then append (or insert into the Acceptance Criteria section) the following:

```markdown
## Negative Scenarios (REQUIRED)

> Each acceptance criterion must have at least one negative scenario.

| ID | Trigger | Expected Behavior |
|---|---|---|
| N1 | [e.g., User submits with empty email] | [e.g., Inline error "Email is required"; no API call made] |
| N2 | [e.g., Backend returns 500] | [e.g., Generic error UI with retry CTA; form data preserved] |

## Abuse Scenarios (REQUIRED for any feature touching auth, payment, multi-tenant, file upload, or user input)

> Map to OWASP Top 10 + business abuse. See `skills/quality/test-case-design/test-case-design.md` Step 4.

| ID | Threat Category | Trigger | Expected Defense |
|---|---|---|---|
| AB1 | BOLA | User A requests resource owned by User B via id | 403 / 404 (no enumeration) |
| AB2 | SQL injection | Input contains `' OR 1=1--` | Parameterized; rejected at parse OR returns benign result |
| AB3 | Idempotency replay | Same Idempotency-Key with different body | 409 |
| AB4 | Rate limit burst | N+1 requests within 1s | 429 + Retry-After |

## Non-Functional Acceptance Criteria (REQUIRED)

> Cover applicable categories per risk tier. See `skills/quality/test-case-design/test-case-design.md` Step 4.

| Category | Criterion |
|---|---|
| Performance | [e.g., p95 latency < 300ms under 50 RPS] |
| Concurrency | [e.g., Two simultaneous PATCH on same resource -> optimistic-lock 409] |
| Reliability | [e.g., If downstream X is 5xx, feature degrades gracefully — main flow continues] |
| Accessibility | [e.g., Full keyboard-only path; screen reader announces async errors] |
| Internationalization | [e.g., RTL languages mirror layout; long-text languages don't truncate CTAs] |
| Compatibility | [e.g., Supported browsers: Chrome 110+, Firefox 110+, Safari 16+; mobile viewports 375-768px] |

## Risk Tier (REQUIRED)

Declare: `<P0 | P1 | P2 | P3>` — drives test-case-design ratio floors.
```

- [ ] **Step 4: Validate templates**

```bash
bash scripts/validate-hermes.sh --verbose 2>&1 | grep -i template
ls -la templates/TC-REGISTRY.template.md
```

- [ ] **Step 5: Commit**

```bash
git add templates/TC-REGISTRY.template.md templates/project-dna/rules/testing-standards.template.md templates/spec-template.md
git commit -m "feat(templates): canonical TC-REGISTRY (12 cols, Technique/Oracle/Risk), risk-calibrated floors in testing-standards, mandatory negative/abuse/non-functional sections in spec template"
```

---

## Task 8: Update `CLAUDE.md` registry + validation

**Why:** New `test-case-design` skill must be registered. Skill count moves 88 -> 89. Documentation must mention the technique-first approach.

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update the "Quality Skills (13 skills)" section header to "Quality Skills (14 skills)"**

Find:
```markdown
### Quality Skills (13 skills)
```
Replace with:
```markdown
### Quality Skills (14 skills)
```

- [ ] **Step 2: Add the new skill to the quality skills list**

After the line:
```markdown
63. **test-generation** - Auto-generated test cases from source code and specs
```
Insert (renumber subsequent items if needed):
```markdown
63a. **test-case-design** - Systematic QA test-design techniques (BVA, EP, Decision Table, State Transition, Pairwise, Risk-Based) plus abuse, non-functional, oracle and mutation gate. Mandatory upstream of test-generation/api-testing/e2e-testing/browser-testing for non-trivial features.
```

- [ ] **Step 3: Update the version + change log entry at the bottom**

In the `## Version` section, change:
```markdown
Current version: 5.0.0
Last updated: 2026-05-25
```
To:
```markdown
Current version: 5.1.0
Last updated: 2026-05-26
```

Prepend to the Changes paragraph:
```markdown
v5.1.0 — Testing Skills Expert-QC Upgrade: New `test-case-design` skill centralizes systematic QA test-design techniques (BVA, EP, DT, ST, Pairwise, RBT) plus abuse, non-functional, oracle and mutation gate. `test-generation`, `api-testing`, `e2e-testing`, `browser-testing` now MANDATORY invoke `test-case-design` first and enforce 12-column TC-REGISTRY with Technique/Oracle/Risk columns. Risk-calibrated negative + abuse + non-functional ratio floors (P0: >=35%+15%+10%, P1: >=30%+10%+10%, ...). Mutation Sanity Check gate. `api-testing` now covers OWASP API Top 10 + idempotency + pagination/filter/sort + content negotiation + rate-limit modalities. `e2e-testing` adds full user-journey edge-case matrix (interruption, concurrency, permission, a11y, i18n, resilience). `browser-testing` adds UI State Matrix and a11y/i18n checklist. Agents `test-engineer` and `brownfield-test-engineer` updated to enforce the new gates. New canonical `templates/TC-REGISTRY.template.md`. `testing-standards.template.md` and `spec-template.md` upgraded with negative/abuse/non-functional acceptance criteria + risk tier. Total: 89 skills, 38 agents, 27 workflows.
```

- [ ] **Step 4: Update Skill Categories total count line if present** (search for "Total: ... skills")

Find any text like `Total: 88 skills, 38 agents, 27 workflows.` and replace `88` -> `89`.

- [ ] **Step 5: Run full validation suite**

```bash
bash scripts/validate-hermes.sh --verbose
bash scripts/benchmark-quality.sh --verbose 2>&1 | head -100
```

Expected:
- `validate-hermes.sh`: zero errors
- `benchmark-quality.sh`: `test-case-design` graded >= B+; modified skills not regressed

- [ ] **Step 6: Smoke-test the chain end-to-end**

Pick a small example feature spec and walk through:

```
test-engineer agent
  -> invokes test-case-design (produces test_ideas[])
  -> invokes test-generation (produces TC-REGISTRY 12-col)
  -> invokes api-testing OR e2e-testing OR browser-testing (executes)
  -> hands to test-verifier
```

Confirm each step produces the new fields (Technique, Oracle, Risk) and ratio floors are honored.

- [ ] **Step 7: Commit**

```bash
git add CLAUDE.md
git commit -m "docs(claude.md): register test-case-design skill (88 -> 89); v5.1.0 testing skills expert-QC upgrade"
```

---

## Verification (final pass)

- [ ] All 8 tasks committed
- [ ] `bash scripts/validate-hermes.sh` exits 0
- [ ] `bash scripts/benchmark-quality.sh` reports no regression on modified skills/agents
- [ ] New `test-case-design` skill is discoverable and reachable via Skill tool
- [ ] `CLAUDE.md` skill count is 89
- [ ] Spec template enforces negative + abuse + non-functional sections
- [ ] TC-REGISTRY template has 12 columns
- [ ] All test skills + agents reference `test-case-design` in `related_skills` / `[AVAILABLE SKILLS]`
- [ ] Risk-calibrated ratio floors appear in: test-case-design, test-generation, testing-standards.template.md, TC-REGISTRY.template.md

---

## Self-Review Notes

**Spec coverage:** Every pain point in the Pre-flight section maps to a task:
- Pain 1-2 (test-generation Edge-Case list, flat 30%) -> Task 2
- Pain 3 (no oracles) -> Task 1, 2, 6, 7
- Pain 4 (no mutation thinking) -> Task 1, 2, 6, 7
- Pain 5 (abuse cases buried) -> Task 1, 2, 6
- Pain 6 (api-testing OWASP) -> Task 3
- Pain 7 (e2e-testing vague edge cases) -> Task 4
- Pain 8 (browser-testing UI state) -> Task 5
- Pain 9 (agents no technique attribution) -> Task 6
- Pain 10 (TC-REGISTRY missing columns) -> Task 7
- Pain 11 (spec template missing negative/abuse) -> Task 7

**Placeholder scan:** No "TBD", no "add validation", no "similar to Task N". Every step has exact strings to find/replace or files to write.

**Type consistency:** `Technique`, `Oracle`, `Risk` column names used uniformly across test-case-design, test-generation, agents, TC-REGISTRY template, testing-standards template. `risk_tier` field name uniform (snake_case). TC-ID prefixes (`TC-UNIT-`, `TC-INT-`, `TC-E2E-`, `TC-ABUSE-`, `TC-PERF-`, `TC-A11Y-`, `TC-I18N-`) consistent across all touched files.

---

## Execution Handoff

**Plan complete and saved to `docs/superpowers/plans/2026-05-26-testing-skills-expert-qc-upgrade.md`.**

Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration. Best for high-confidence batched work like this.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch with checkpoints. Best if you want to step through changes live.

Which approach?

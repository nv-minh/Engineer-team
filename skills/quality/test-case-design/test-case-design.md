---
name: test-case-design
description: "Apply expert QA test-design techniques to produce non-trivial test cases. Use BEFORE test-generation, e2e-testing, api-testing, or browser-testing whenever you need to expand a feature into a high-coverage TC set — not just happy paths."
version: "1.1.0"
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
        ratios_per_layer:
          type: object
          description: "counts grouped by layer — for diagnostic reporting"
        ratios_joint:
          type: object
          description: "counts aggregated across all layers — the gate is measured here"
          properties:
            positive: { type: integer }
            negative: { type: integer }
            abuse: { type: integer }
            non_functional: { type: integer }
            total: { type: integer }
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
          layer: { type: string, enum: [unit, api, e2e, browser], description: "Assigned per Step 3.7 Layer Assignment. Each idea has exactly one primary layer." }
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
4. Every test idea MUST have a `layer` from {unit, api, e2e, browser}. Use the Layer Assignment matrix in Step 3.7. An idea that would naturally fit two layers (e.g., "rejects empty name") is emitted ONCE at its primary layer; the peer layer asserts only the UI/contract effect, not the validation itself.
5. Apply at least 4 techniques per non-trivial feature. A spec covered only by EP+BVA is incomplete.
6. The negative+abuse+non_functional ratio MUST meet the table in Step 4 for the declared `risk_tier`. **The gate is evaluated on `ratios_joint` (across layers), not per-layer.** If `risk_tier` is missing, ask before generating.
7. Mutation Sanity Check (Step 6) is a gate, not advice. Any idea that cannot describe a mutation it would catch is removed.
8. Stop happy-path inflation. After >=1 happy path per acceptance criterion, additional positive cases require explicit justification (e.g., representing different equivalence classes).
9. ABC: Teach the technique in `rationale`. "Empty string" is not a rationale; "Empty-string EP-class for required field — distinguishes 'missing' from 'whitespace' from 'valid'" is.

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

````
parameter: age (integer, business rule: 18-65 allowed)
EP classes: { <18 invalid }, { 18-65 valid }, { >65 invalid }, { non-integer invalid }, { null invalid }
TC ideas: TC-EP-01..05 (one per class)
````

#### 3.2 Boundary Value Analysis (BVA)
For every ordered domain, emit min-1, min, min+1, max-1, max, max+1. For string length, emit 0, 1, max-1, max, max+1, max+huge.

````
parameter: age (18-65)
BVA: 17, 18, 19, 64, 65, 66
parameter: name (1-50 chars)
BVA: "", "a", "a"*49, "a"*50, "a"*51, "a"*10000
````

#### 3.3 Decision Table (DT)
For features with combinatorial business rules, build a decision table. Emit one TC per rule row, including impossible combinations.

````
Rules: { has_account, kyc_verified, age>=18, balance>0 } -> action
| has_account | kyc | age>=18 | balance>0 | -> action      |
|-------------|-----|---------|----------|----------------|
| F           | -   | -       | -        | reject:no-acct |
| T           | F   | -       | -        | reject:kyc     |
| T           | T   | F       | -        | reject:minor   |
| T           | T   | T       | F        | reject:funds   |
| T           | T   | T       | T        | approve        |
````

Every row = one TC. Mark impossible combos with `N/A` but document why.

#### 3.4 State Transition (ST)
For stateful systems, draw the state graph. Emit:
- One TC per legal transition (forward path)
- One TC per illegal/forbidden transition (must reject)
- One TC per terminal state (no further transitions allowed)
- One TC per cycle (return to earlier state)

````
states: draft -> submitted -> approved -> archived
                          \-> rejected -> archived
illegal: archived -> approved (must reject)
illegal: submitted -> archived (must reject)
````

#### 3.5 Pairwise / Combinatorial (PW)
For multi-parameter inputs, full combination explodes. Use pairwise (every pair of parameter values appears in at least one TC) — gives ~80% defect coverage with linear test count.

````
parameters: { browser: [chrome, firefox, safari], device: [mobile, desktop], locale: [en, vi, ja] }
full = 3*2*3 = 18 ; pairwise = 9
````

#### 3.6 Risk-Based Testing (RBT)
Score each candidate idea by `impact (1-5) × likelihood (1-5)`. P0 = score >=15, P1 = 8-14, P2 = 4-7, P3 = <4. Use this to prioritize execution order and to justify cuts when scope is tight.

#### 3.7 Layer Assignment

For each emitted idea, assign exactly one `layer` using this matrix:

| Idea concern | Layer | Examples |
|---|---|---|
| Pure logic / domain function / data transform | `unit` | Calculator, date diff, schema validator |
| HTTP contract / status code / response schema / persistence / SQLi / mass-assignment / idempotency / rate-limit / OWASP API Top 10 | `api` | POST returns 201 + Location header; duplicate name -> 409 |
| Multi-step user journey / form submit cycle / interruption / navigation / optimistic UI / double-submit / session expiry | `e2e` | Open modal -> fill -> submit -> toast; refresh mid-form |
| Component visual state matrix / a11y / i18n / responsive / keyboard / screen-reader / RTL | `browser` | Loading skeleton; empty state; aria-live errors; CJK input |

**One-idea-one-layer rule:** If a concept seems to need testing at multiple layers (e.g., "empty name rejected"), emit ONE idea at the strongest assertion point — usually `api` (validation invariant lives there). Add a `peer_assertion` note in `rationale` for the consumer skill to assert UI-side effect without re-testing the rule. Example: `layer=api`; rationale = "server returns 400 with `name required`. Peer e2e assertion (no separate TC): error text is rendered in form, not generic toast."

### Step 4: Apply Negative + Abuse + Non-Functional Ratios

Risk-calibrated ratio table — these are floors, not targets. **The gate is evaluated on `ratios_joint` (across all layers combined), not per-layer.** A P2 feature with only an `api` file is gated on that file's totals. A P0 feature with `api` + `e2e` + `browser` files is gated on the union (sum of counts across layer-files). Splitting test_ideas[] across layers is a design choice — the gate must not double-penalize that split.

Percentages are computed as `count_in_category / total_ideas * 100`. In `output_schema.design_summary.ratios`, the four fields are raw integer counts; the percentages here are the gate that the counts must satisfy.

`risk_tier` is the feature-level input declared upfront and drives the ratio floors below. `risk` (per-idea, see Step 3.6 RBT) is derived per-test-idea from impact × likelihood. A P2 feature can still contain individual P0 ideas.

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

#### Joint-Ratio Computation

After Step 3.7 assigns `layer` to every idea, compute ratios at TWO levels:

1. Group ideas: `ideas_by_layer = groupBy(test_ideas, 'layer')` → `{ unit: [...], api: [...], e2e: [...], browser: [...] }`
2. For each non-empty layer, compute `ratios_per_layer[layer]` = `{ positive, negative, abuse, non_functional, total }`. Classification by `technique`:
   - `positive` = ideas whose `technique` ∈ {EP, BVA, DT, ST, PW} framed as the **happy / accepting** case (validation passes, status 2xx, journey completes)
   - `negative` = same techniques framed as **rejection** (validation fails, status 4xx, journey blocked)
   - `abuse` = ideas with `technique = abuse`
   - `non_functional` = ideas with `technique = non_functional`
   - (RBT is a prioritization meta-technique — does not directly classify into a category; its outputs map to one of the four above)
   Emit `ratios_per_layer` in `design_summary` for diagnostic transparency.
3. Compute `ratios_joint` = element-wise sum across all layers, plus `total = sum(layer totals)`.
4. Apply the risk-calibrated floor (the table at the top of Step 4) to `ratios_joint` ONLY. Per-layer ratios are diagnostic, not gating.
5. If joint gate FAILS, add ideas to whichever layer hosts the gap most naturally:
   - Missing **abuse** → almost always belongs in `api` (injection, mass-assignment, OWASP API Top 10) or `browser` (XSS render, clickjacking)
   - Missing **non_functional** → usually `e2e` (interruption, network drop, session expiry, concurrency) or `browser` (a11y, i18n, responsive)
   - Missing **negative** → typically `api` (4xx contracts) — the layer where validation invariants live
   Re-compute after adding.

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

````yaml
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
````

### Step 8: Hand Off (one TC-REGISTRY per layer)

Group `test_ideas[]` by `layer` and hand off each group to the appropriate consumer skill:

| Layer | Consumer skill | Default output file |
|---|---|---|
| `unit` | `test-generation` | `tests/unit/TC-REGISTRY-<feature>.md` |
| `api` | `api-testing` (via `test-generation` for materialization) | `tests/api-test/<feature>/TC-REGISTRY-<feature>.md` |
| `e2e` | `e2e-testing` | `tests/FE-test/<feature>/TC-REGISTRY-<feature>-e2e.md` |
| `browser` | `browser-testing` | `tests/FE-test/<feature>/TC-REGISTRY-<feature>-component.md` |

Each TC-REGISTRY file MUST declare its `Layer:` in the header and enumerate peer-layer files under "Peer-layer files" — see `templates/TC-REGISTRY.template.md`. The "Joint Coverage" section in each file shows the joint ratio status computed in Step 4's Joint-Ratio Computation; the joint gate (not per-file ratio) is what authorizes materialization into executable test code.

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
- [ ] Every test_idea has a `layer` field from {unit, api, e2e, browser}
- [ ] `ratios_per_layer` reported in `design_summary` for diagnostic transparency
- [ ] `ratios_joint` computed and gate evaluated on joint counts, not per-file
- [ ] Each layer's hand-off file declares its layer in the header

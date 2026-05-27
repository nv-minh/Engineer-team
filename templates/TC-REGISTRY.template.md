# Test Case Registry

> Canonical TC-REGISTRY format. Use the 12-column table. Every TC must carry Technique, Oracle, and Risk.

**Layer:** `<unit | api | e2e | browser>`

**Peer-layer files** (for joint-coverage gate — list every sibling layer's TC-REGISTRY that covers the same feature):
- `<path/to/sibling/TC-REGISTRY-{feature}-{layer}.md>` (if exists)
- `<...>`
- `(or "none" if this is a single-layer feature)`

## Risk-Calibrated Ratio Targets

Declared feature risk tier: `<P0 | P1 | P2 | P3>`

Floors (counted from final registry):

| risk_tier | positive | negative | abuse | non_functional |
|-----------|----------|----------|-------|----------------|
| P0        | <=40%    | >=35%    | >=15% | >=10%          |
| P1        | <=50%    | >=30%    | >=10% | >=10%          |
| P2        | <=60%    | >=25%    | >=5%  | >=5%           |
| P3        | <=70%    | >=25%    | optional | optional    |

Current counts (this file only): positive=__ / negative=__ / abuse=__ / non_functional=__ / total=__

## Joint Coverage (cross-layer)

> Joint = sum of counts across this file + every peer-layer file listed in the header. The risk-calibrated gate is evaluated on **joint** counts, not per-file. See `skills/quality/test-case-design/test-case-design.md` Step 4 "Joint-Ratio Computation".

| Metric | This file | Peer files (sum) | Joint | Gate (P{risk_tier}) | Status |
|---|---|---|---|---|---|
| positive | __ | __ | __ | <=N% | PASS/FAIL |
| negative | __ | __ | __ | >=N% | PASS/FAIL |
| abuse | __ | __ | __ | >=N% | PASS/FAIL |
| non_functional | __ | __ | __ | >=N% | PASS/FAIL |

**Joint gate status:** `<PASS | FAIL — see remediation below>`

If FAIL: add ideas to whichever layer hosts the gap most naturally (missing abuse → `api` or `browser`; missing non_functional → `e2e` or `browser`; missing negative → `api`). See test-case-design Step 4 Joint-Ratio Computation point 5.

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
- [ ] Layer declared in file header
- [ ] Peer-layer files enumerated (or "none" if single-layer feature)
- [ ] Joint Coverage table populated with current counts
- [ ] Joint gate PASS for the declared risk_tier
- [ ] TC-code coverage ready: every TC-ID in this file has a corresponding `test("TC-XXX-NNN: ...")` block (or `test.todo()`) in the test implementation file

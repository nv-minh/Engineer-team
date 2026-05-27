# Test Automation Chain

A 3-agent pipeline that takes you from zero test infrastructure to a verified, passing test suite — with automatic retry on failures.

---

## Overview: 3-Agent Pipeline

```
/em-agent:playwright-setup
        ↓
/em-agent:brownfield-test-engineer
        ↓
/em-agent:test-verifier
```

| Agent | Input | Output |
|-------|-------|--------|
| `playwright-setup` | Tech stack (auto-detected) | Playwright config, POM scaffold, auth config |
| `brownfield-test-engineer` | Spec or task description + brownfield context | TC-REGISTRY.md + test files |
| `test-verifier` | Test run results | PASS with confidence score / FAIL with manual steps |

---

## Step 1: Setup Infrastructure — `/em-agent:playwright-setup`

Run once per project to install and configure Playwright.

```bash
/em-agent:playwright-setup
```

**What it does automatically:**
1. Detects stack (Next.js, NestJS, React SPA, monorepo, etc.)
2. Installs Playwright and browser binaries for your CI target
3. Generates `playwright.config.ts` with baseURL, timeouts, retries
4. Scaffolds `e2e/` directory with Page Object Model structure
5. Generates `e2e/config/auth.config.json` — choose auth strategy

### 4 Auth Strategies

| Strategy | When to use | How it works |
|----------|-------------|-------------|
| `none` | Public pages only | No auth setup needed |
| `credentials` | Username/password login | Reads from `.env`, logs in once, stores state |
| `oauth` | SSO / OAuth provider | Manual first login → saves `storageState.json` |
| `storageState` | Already have session state | Load existing JSON file |

Credentials come from `.env` — never committed. The auth config file (`auth.config.json`) is committed and references env var names only.

---

## Step 2: Generate & Run Tests — `/em-agent:brownfield-test-engineer`

Generates tests from a spec or task description. If brownfield context exists (`.em-brownfield/`), it auto-loads module flows and acceptance criteria first.

```bash
# With brownfield context:
/em-agent:brownfield-test-engineer Write E2E tests for the checkout flow

# With explicit spec:
/em-agent:brownfield-test-engineer Write tests for the user registration feature
# (agent asks clarifying questions if spec is ambiguous)
```

### Clarifying Questions

If the spec or task is ambiguous, the agent asks questions before writing any tests:

- What's the scope? (unit / integration / E2E / all layers?)
- Are there existing tests to extend?
- Which risk tier? (P0 = payment/auth, P1 = core features, P2 = secondary, P3 = edge cases)

### TC-REGISTRY Format

Every generated test case is recorded in `TC-REGISTRY.md` with 12 columns:

| TC-ID | Title | Layer | Technique | Preconditions | Steps | Expected | Oracle | Risk Tier | Negative | Abuse | Non-Functional |
|-------|-------|-------|-----------|---------------|-------|----------|--------|-----------|----------|-------|----------------|

Risk-calibrated ratios enforced:
- P0 (payment, auth): ≥35% negative + ≥15% abuse + ≥10% non-functional
- P1 (core): ≥30% negative + ≥10% abuse + ≥10% non-functional
- P2/P3: ≥25% negative + ≥5% abuse + ≥5% non-functional

### TC-Code Coverage Gate

Every TC-ID in the registry **must** have a matching `test("TC-XXX-NNN: ...")` block in the test file. Unautomated TCs use `test.todo("TC-XXX-NNN: title")` — never silently dropped.

---

## Step 3: Verify Results — `/em-agent:test-verifier`

Re-runs tests and verifies results with up to 3 retry attempts.

```bash
/em-agent:test-verifier
```

**Retry loop:**

```
Attempt 1: Run all tests
  → Failed: TC-CHECKOUT-003 (network timeout)
  → Fix: increase timeout in POM, add retry
Attempt 2: Re-run failed tests only
  → Failed: TC-CHECKOUT-003 still fails
  → Fix: mock Stripe network call in test setup
Attempt 3: Re-run failed tests only
  → PASS
```

**Pre-retry check (Step 2.5):** Before each retry, verifier counts TC-IDs in registry vs `test()` blocks in code. Returns `BLOCKED` if TC-IDs > test blocks — forces test-engineer to add missing test code.

**Final output:**

```
PASS — confidence: 94%
  42/42 TCs automated
  0 test.todo() remaining
  Coverage: statements 87%, branches 82%

  OR

FAIL — manual steps required:
  TC-CHECKOUT-003: Stripe webhook timeout
    Root cause: test environment missing webhook secret
    Manual step: Add STRIPE_WEBHOOK_SECRET to .env.test
```

---

## Example: Full Run from Scratch

```bash
# 1. Setup Playwright (one time)
/em-agent:playwright-setup
# → Installs playwright, creates playwright.config.ts, e2e/ scaffold

# 2. Generate tests for checkout flow
/em-agent:brownfield-test-engineer Write E2E tests for the checkout flow
# → Auto-loads .em-brownfield/modules/payment/FLOWS.json
# → Asks: "scope: E2E only or also unit/integration?"
# → Generates TC-REGISTRY.md (32 TCs) + 4 test files
# → Runs tests: 28/32 pass

# 3. Verify and fix remaining failures
/em-agent:test-verifier
# → Attempt 1: 4 failures → targeted fixes
# → Attempt 2: 1 failure → targeted fix
# → Attempt 3: PASS (32/32) — confidence: 91%
```

---

## Integrating with Workflows

The test automation chain is wired into the VERIFY stage of all major workflows:

| Workflow | Where it runs |
|----------|---------------|
| `new-feature` | Stage 5 (VERIFY) — brownfield-test-engineer → test-verifier |
| `bug-fix` | Stage 5 (VERIFY) — regression tests via brownfield-test-engineer |
| `greenfield-app` | Stage 10 (VALIDATE) — full chain including playwright-setup |
| `refactoring` | Stage 4 (VERIFY) — regression focus |

You don't need to invoke agents manually when using a workflow — the VERIFY stage handles it.

---

## Tips

- **Always run `playwright-setup` first** — even if Playwright is already installed, the POM scaffold and auth config are project-specific.
- **Use `brownfield-onboarding` before `brownfield-test-engineer`** — the test agent generates much better tests when it has FLOWS.json to work from.
- **Don't skip `test-verifier`** — it catches TC-ID vs test() mismatches that the test-engineer can miss on first generation.
- **Set risk tier explicitly** if the agent guesses wrong — a checkout flow labeled P2 will have too few negative/abuse TCs.

---

**Version:** 5.5.0
**Last Updated:** 2026-05-27

See also: [Brownfield Intelligence](brownfield.md) · [New Feature Workflow](new-feature-workflow.md)

# EM-Team: Auto Test with Playwright + Feature Workspace

> Quick reference guide for the team. Covers v3.8.0–v3.10.0 features.

---

## 1. Auto Test Pipeline (3 Agents)

### Flow

```
playwright-setup → brownfield-test-engineer → test-verifier → PASS/FAIL
```

### 1.1 playwright-setup — Setup Playwright

**Trigger:** `em-agent:playwright-setup` hoặc `em:playwright-setup`

**Khi nào dùng:** Project chưa có Playwright. Agent tự detect stack, install, tạo config.

**Output:**
```
playwright.config.ts          # Config tailored to project
e2e/
├── config/
│   ├── auth.config.json      # Auth strategy (xem mục 3)
│   └── .env.example          # Example env vars
├── pages/BasePage.ts         # Base POM class
├── fixtures/index.ts         # Extended fixtures
├── helpers/auth.helper.ts    # Global auth setup
├── scripts/auth-setup.ts     # Manual OAuth login script
├── auth/                     # StorageState (gitignored)
└── smoke.spec.ts             # Smoke test
```

### 1.2 brownfield-test-engineer — Generate & Run Tests

**Trigger:** `em-agent:brownfield-test-engineer` hoặc `em:brownfield-test-engineer`

**Khi nào dùng:** Có spec + existing code, cần generate test suite.

**Process:**
1. Nhận spec (file path hoặc plain text)
2. Nếu spec chưa rõ → **hỏi tối đa 5 câu clarifying questions** trước khi generate
3. Explore codebase → map spec to code
4. Generate test cases (TC-UNIT, TC-INT, TC-E2E)
5. Execute: unit → integration → E2E
6. Collect evidence (screenshots, videos, traces)
7. Hand off to test-verifier

### 1.3 test-verifier — Double-check Results

**Trigger:** `em-agent:test-verifier` hoặc `em:test-verifier`

**Process:**
- Re-run only failed tests (not all)
- Spot-check 3-5 passed tests
- Retry max 3 times with targeted fixes:
  - Attempt 1: selectors, timing, test data
  - Attempt 2: logic, assertions
  - Attempt 3: structural, auth, race conditions
- Output: **PASS** (confidence 0-3) hoặc **FAIL** (per-TC details)
- Flaky tests flagged separately, not counted as hard failures

---

## 2. Feature Workspace (.em-feature-context)

### Yêu cầu

Feature Workspace cần `EM_TEAM_ARTIFACT_EXPORT=true` trong `.claude/settings.local.json` của project đích:

```json
{
  "env": {
    "EM_TEAM_ARTIFACT_EXPORT": "true"
  }
}
```

Không bật = không có `.em-feature-context`, không track cross-prompt.

### Problem it solves

Khi iterate trên 1 feature qua nhiều prompt, spec/test/evidence bị phân tán thành nhiều file rời rạc. Feature Workspace nhóm tất cả vào 1 folder.

### How it works

**Bước 1: Tạo workspace** (tự động khi bắt đầu workflow)

```
artifactStore.createWorkspace('new-feature', 'User Dashboard')
```

Tạo ra:
```
.em-artifacts/new-feature/user-dashboard/
├── test-executions/
├── evidence/
├── reviews/
└── ITERATION-LOG.md
```

Và file `.em-feature-context` ở project root:
```json
{
  "workflowType": "new-feature",
  "featureSlug": "user-dashboard",
  "workspacePath": ".em-artifacts/new-feature/user-dashboard",
  "iterations": 0,
  "lastUpdated": "2026-05-23T14:00:00Z"
}
```

**Bước 2: Living docs** (updated in place)

```
artifactStore.upsert('SPEC.md', specContent)
artifactStore.upsert('TC-REGISTRY.md', testCaseRegistry)
```

SPEC.md và TC-REGISTRY.md được **overwrite** mỗi lần update — luôn là bản mới nhất.

**Bước 3: Timestamped logs** (appended)

```
artifactStore.workspaceExport('test-executions', 'test-run', report)
artifactStore.workspaceExport('reviews', 'code-review', review)
```

Mỗi lần chạy = 1 file mới với timestamp → giữ full history.

**Bước 4: Iterate**

Prompt tiếp theo → agent đọc `.em-feature-context` → biết export vào đâu → living docs update, logs append, ITERATION-LOG.md auto-tracks.

### Result after 3 iterations

```
.em-artifacts/new-feature/user-dashboard/
├── SPEC.md                                    # Version cuối cùng
├── TC-REGISTRY.md                             # Version cuối cùng
├── test-executions/
│   ├── 2026-05-23-1400-test-run.md           # Lần chạy 1
│   ├── 2026-05-23-1530-test-run.md           # Lần chạy 2 (sau fix)
│   └── 2026-05-23-1600-verification.md       # test-verifier check
├── evidence/
│   └── 2026-05-23-1530-screenshots.md
├── reviews/
│   └── 2026-05-23-1545-code-review.md
└── ITERATION-LOG.md                           # 3 iterations tracked
```

### Quay lại feature cũ

Khi bạn đã làm nhiều feature khác rồi quay lại sửa feature cũ — dùng lệnh `switch`:

```bash
# 1. Xem tất cả workspaces đã tạo
bash scripts/artifact-register.sh workspace
# Output:
#   [new-feature] user-dashboard — 8 files, 3 iterations
#   [new-feature] payment-system — 5 files, 2 iterations
#   [bug-fix] login-timeout — 3 files, 1 iterations
#   [new-feature] notifications — 4 files, 1 iterations (active)

# 2. Switch về feature cũ
bash scripts/artifact-register.sh switch user-dashboard
# Output:
#   [OK] Switched to workspace: user-dashboard
#   Workflow:   new-feature
#   Path:       .em-artifacts/new-feature/user-dashboard
#   Iterations: 3
#   .em-feature-context updated. Next prompt will use this workspace.

# 3. Prompt tiếp theo sẽ tự động update vào workspace user-dashboard
#    SPEC.md, TC-REGISTRY.md tiếp tục update in place
#    Logs append thêm vào test-executions/, reviews/
```

**Lưu ý:** Chỉ có 1 feature active tại 1 thời điểm. `switch` thay đổi `.em-feature-context` để trỏ về workspace cũ. Folder tất cả workspaces đều được giữ nguyên trong `.em-artifacts/`.

### CLI Commands

```bash
# List all feature workspaces
bash scripts/artifact-register.sh workspace

# Show workspace details
bash scripts/artifact-register.sh workspace user-dashboard

# Show active feature context
bash scripts/artifact-register.sh context

# Switch active workspace to an existing feature
bash scripts/artifact-register.sh switch user-dashboard
```

---

## 3. Playwright Auth Configuration

### Config file: `e2e/config/auth.config.json`

```json
{
  "strategy": "none",
  "storageStatePath": "e2e/auth/storage-state.json",
  "credentials": {
    "loginUrl": "/login",
    "usernameSelector": "[data-testid='username-input']",
    "passwordSelector": "[data-testid='password-input']",
    "submitSelector": "[data-testid='login-button']",
    "successIndicator": "[data-testid='dashboard']",
    "usernameEnvVar": "E2E_AUTH_USERNAME",
    "passwordEnvVar": "E2E_AUTH_PASSWORD"
  },
  "oauth": {
    "provider": "google",
    "loginButtonSelector": "[data-testid='google-login']",
    "setupMode": "manual"
  }
}
```

### 4 Strategies

| Strategy | Dùng khi | Cách hoạt động |
|----------|----------|----------------|
| `none` | App public, không cần login | Skip auth |
| `credentials` | Login form username/password | Auto-fill form from `.env`, save storageState |
| `oauth` | Google, MSAL, Azure AD, SSO | Manual login 1 lần → save storageState → auto reuse |
| `storageState` | Đã có sẵn browser state | Load trực tiếp |

### Setup cho Credentials

```bash
# 1. Set strategy trong auth.config.json:
#    "strategy": "credentials"

# 2. Tạo .env (gitignored):
echo 'E2E_AUTH_USERNAME=test@example.com' >> .env
echo 'E2E_AUTH_PASSWORD=testpass123' >> .env

# 3. Chạy test — auto login:
npx playwright test
```

### Setup cho OAuth (Google, etc.)

```bash
# 1. Set strategy: "oauth"

# 2. Chạy setup script (mở browser visible):
npx ts-node e2e/scripts/auth-setup.ts

# 3. Login thủ công trong browser
# 4. StorageState tự save vào e2e/auth/storage-state.json

# 5. Chạy test — dùng state đã save:
npx playwright test

# Khi hết hạn (~30 ngày) → chạy lại bước 2
```

### Security Rules

- `auth.config.json` — **COMMIT ĐƯỢC** (chỉ chứa selectors, không có password)
- `.env` — **KHÔNG COMMIT** (gitignored, chứa credentials thật)
- `e2e/auth/` — **KHÔNG COMMIT** (gitignored, chứa browser state)

---

## 4. Workflow Integration

Tất cả workflows tự động dùng test pipeline trong VERIFY stage:

| Workflow | Workspace created at | Artifact folder |
|----------|---------------------|-----------------|
| new-feature | Stage 2 (Spec) | `.em-artifacts/new-feature/{slug}/` |
| bug-fix | Stage 1 (Investigate) | `.em-artifacts/bug-fix/{slug}/` |
| refactoring | Stage 1 (Analyze) | `.em-artifacts/refactoring/{slug}/` |
| greenfield-app | Stage 1 (Discovery) | `.em-artifacts/greenfield/{slug}/` |

### VERIFY stage steps (all workflows):

1. Generate test cases (`test-generation` skill)
2. Execute E2E tests (`e2e-testing` skill)
3. Browser verification (`browser-testing` skill)
4. Double-check results (`test-verifier` agent) — max 3 retries
5. Export artifacts to workspace

---

## 5. Quick Reference

### Trigger agents

```
em:playwright-setup              # Setup Playwright infra
em:brownfield-test-engineer      # Generate + run tests from spec
em:test-verifier                 # Verify test results
```

### Check workspace state

```bash
bash scripts/artifact-register.sh workspace     # List all
bash scripts/artifact-register.sh context        # Active feature
bash scripts/artifact-register.sh list           # All artifacts
```

### Quick Reference

```bash
bash scripts/artifact-register.sh workspace              # List all workspaces
bash scripts/artifact-register.sh workspace user-dashboard # Show workspace details
bash scripts/artifact-register.sh context                  # Show active feature
bash scripts/artifact-register.sh switch user-dashboard    # Switch to old feature
```

### Demo project

`verify-demo/` — Express.js app with 15 working tests (unit + integration + E2E) as reference implementation.

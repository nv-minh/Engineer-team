# Hướng Dẫn Test Automation Chain

Chuỗi 3 agent giúp bạn đi từ "chưa có test nào" đến "test suite đầy đủ và đang pass" — với tự động retry khi test fail.

---

## Tại sao cần Test Automation Chain?

Viết test cho codebase cũ (brownfield) thường mất rất nhiều thời gian vì:
- Phải setup Playwright/infrastructure từ đầu
- Không biết nên test cái gì (thiếu spec)
- Test viết xong chạy fail vì setup sai

Test Automation Chain giải quyết 3 vấn đề này bằng 3 agent chuyên biệt:

```
playwright-setup          → Tự động setup infrastructure
brownfield-test-engineer  → Tự động tạo test từ AC/spec
test-verifier             → Tự động verify và retry khi fail
```

---

## Khi nào dùng?

✅ **Dùng khi:**
- Bắt đầu viết test cho dự án mới hoặc legacy
- Cần test cho một feature/module cụ thể
- Test bị fail và cần verify + fix

❌ **Không cần khi:**
- Dự án đã có test infrastructure hoàn chỉnh và chỉ cần thêm 1-2 test case
- Test case đơn giản có thể tự viết trong vài phút

---

## Bước 1: Setup Infrastructure — `/em-agent:playwright-setup`

Chạy **một lần** để cài đặt và cấu hình Playwright.

```bash
/em-agent:playwright-setup
```

### Điều gì xảy ra bên dưới?

1. **Auto-detect stack** — nhận biết Next.js, NestJS, React SPA, monorepo...
2. **Cài Playwright + browsers** phù hợp với CI target của bạn
3. **Tạo `playwright.config.ts`** với baseURL, timeouts, retries
4. **Scaffold cấu trúc `e2e/`** theo Page Object Model
5. **Tạo `e2e/config/auth.config.json`** — bạn chọn auth strategy

### 4 Auth Strategies — Chọn cái nào?

| Strategy | Khi nào dùng | Cách hoạt động |
|----------|-------------|----------------|
| `none` | Trang public, không cần đăng nhập | Không setup auth |
| `credentials` | Login bằng username/password | Đọc từ `.env`, login 1 lần, lưu state |
| `oauth` | SSO / OAuth provider | Login thủ công lần đầu → lưu `storageState.json` |
| `storageState` | Đã có session state sẵn | Load file JSON có sẵn |

Credentials luôn đọc từ `.env` — **không bao giờ commit credentials vào git**.

---

## Bước 2: Tạo Tests — `/em-agent:brownfield-test-engineer`

Tạo tests từ spec hoặc mô tả task. Nếu có `.em-brownfield/`, agent tự load module context trước.

```bash
# Với brownfield context:
/em-agent:brownfield-test-engineer Viết E2E tests cho checkout flow

# Với spec cụ thể:
/em-agent:brownfield-test-engineer Viết tests cho user registration feature
```

### Agent hỏi clarifying questions khi nào?

Nếu spec/task mơ hồ, agent hỏi trước khi viết test:
- Scope là gì? (unit / integration / E2E / tất cả?)
- Có test cũ cần extend không?
- Risk tier là gì? (P0 = payment/auth, P1 = core, P2 = secondary, P3 = edge case)

Đây là bước tốt — trả lời những câu hỏi này giúp test được tạo ra chính xác hơn nhiều.

### TC-REGISTRY là gì?

Mỗi test case được record trong `TC-REGISTRY.md` với 12 cột, bao gồm:
- TC-ID (ổn định, không thay đổi)
- Technique (BVA, EP, Decision Table, v.v.)
- Risk Tier
- Oracle (làm sao biết test pass?)
- Negative / Abuse / Non-functional flags

**Ratio floors theo risk tier:**

| Risk Tier | Negative TCs | Abuse TCs | Non-functional TCs |
|-----------|-------------|-----------|-------------------|
| P0 (payment, auth) | ≥35% | ≥15% | ≥10% |
| P1 (core features) | ≥30% | ≥10% | ≥10% |
| P2/P3 | ≥25% | ≥5% | ≥5% |

### TC-Code Coverage Gate

**Mỗi TC-ID trong registry BẮT BUỘC phải có** `test("TC-XXX-NNN: ...")` tương ứng trong test file. TC chưa automated dùng `test.todo("TC-XXX-NNN: title")` — không được bỏ TC-ID silently.

---

## Bước 3: Verify — `/em-agent:test-verifier`

Re-run tests và verify với tối đa 3 lần retry.

```bash
/em-agent:test-verifier
```

### Retry loop hoạt động như thế nào?

```
Lần 1: Chạy tất cả tests
  → Fail: TC-CHECKOUT-003 (network timeout)
  → Fix đề xuất: tăng timeout trong POM, thêm retry
Lần 2: Chỉ re-run tests fail
  → Vẫn fail: TC-CHECKOUT-003
  → Fix đề xuất: mock Stripe network call
Lần 3: Re-run tests fail
  → PASS ✅
```

**Pre-retry check (Step 2.5):** Trước mỗi retry, agent đếm TC-IDs vs `test()` blocks. Trả về `BLOCKED` nếu TC-IDs nhiều hơn test blocks — bắt buộc phải thêm test code trước.

### Output cuối cùng

```
PASS — confidence: 94%
  42/42 TCs đã có test code
  0 test.todo() còn lại
  Coverage: statements 87%, branches 82%
```

Hoặc nếu thất bại sau 3 lần:

```
FAIL — cần can thiệp thủ công:
  TC-CHECKOUT-003: Stripe webhook timeout
    Root cause: test environment thiếu webhook secret
    Bước thủ công: Thêm STRIPE_WEBHOOK_SECRET vào .env.test
```

---

## Ví dụ: Chạy Full Pipeline từ đầu

```bash
# 1. Setup Playwright (1 lần duy nhất)
/em-agent:playwright-setup
# → playwright.config.ts, e2e/ scaffold được tạo

# 2. Tạo tests cho checkout
/em-agent:brownfield-test-engineer Viết E2E tests cho checkout flow
# → Auto-load .em-brownfield/modules/payment/FLOWS.json
# → Hỏi: "scope: E2E only hay cả unit/integration?"
# → Tạo TC-REGISTRY.md (32 TCs) + 4 test files
# → Chạy tests: 28/32 pass

# 3. Verify và fix failures còn lại
/em-agent:test-verifier
# → Lần 1: 4 failures → targeted fixes
# → Lần 2: 1 failure → targeted fix
# → Lần 3: PASS (32/32) — confidence: 91%
```

---

## Tích hợp với Workflows

Test automation chain được wired vào VERIFY stage của các workflow chính:

| Workflow | Chạy ở đâu |
|----------|-----------|
| `new-feature` | Stage 5 (VERIFY) |
| `bug-fix` | Stage 5 (VERIFY) — focus vào regression tests |
| `greenfield-app` | Stage 10 (VALIDATE) — bao gồm playwright-setup |
| `refactoring` | Stage 4 (VERIFY) — focus vào regression |

Khi dùng workflow, bạn không cần invoke agent thủ công — VERIFY stage tự xử lý.

---

## Tips cho người mới

- **Chạy `playwright-setup` trước** — dù Playwright đã install, POM scaffold và auth config cần được tạo cho project cụ thể
- **Chạy `brownfield-onboarding` trước khi viết test** — test engineer tạo test tốt hơn nhiều khi có FLOWS.json
- **Đừng skip `test-verifier`** — nó bắt TC-ID vs test() mismatch mà test engineer có thể bỏ sót
- **Trả lời clarifying questions cẩn thận** — risk tier sai dẫn đến test không đủ negative/abuse cases

---

**Phiên bản:** 5.5.0
**Cập nhật lần cuối:** 2026-05-27

Xem thêm: [Brownfield Intelligence](brownfield.md) · [New Feature Workflow](new-feature-workflow.md)

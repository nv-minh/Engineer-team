# Hướng Dẫn New Feature Workflow: Từ Ý Tưởng Đến PR

`/em-wf:new-feature` là một lifecycle 6 giai đoạn — từ mô tả feature thô đến PR đã được review và sẵn sàng ship.

---

## Tại sao dùng workflow thay vì làm thủ công?

Khi build feature mà không có workflow, thường xảy ra những vấn đề này:

- Code xong mới viết test → test chỉ validate những gì code làm, không phải những gì **nên** làm
- Review sau khi test pass → fix từ review không được test lại
- Không có spec → ACs không rõ ràng → "done" có nghĩa khác nhau với mỗi người

`em-wf:new-feature` giải quyết bằng cách:
- Spec trước, code sau (Spec Iron Law)
- Code review trước khi test suite (để review fixes được validate bởi tests)
- Quality gates giữa mỗi giai đoạn

---

## Khi nào dùng?

✅ **Dùng khi:**
- Build feature mới từ đầu
- Feature có ≥2 components (backend + frontend, hoặc ≥1 API endpoint)
- Cần đảm bảo quality và review trước khi ship

❌ **Không cần khi:**
- Fix typo hoặc style change đơn giản
- Thay đổi config không ảnh hưởng logic

---

## Quick Start

```bash
/em-wf:new-feature Implement trang user profile với avatar upload và chỉnh sửa bio
```

Workflow xử lý tất cả: spec → plan → build → verify → review → ship. Bạn được hỏi ý kiến tại mỗi gate.

---

## 6 Giai Đoạn

### Giai đoạn 1: DEFINE (Xác định)

**Agent:** product-manager  
**Output:** `SPEC.md` — đặc tả feature

Spec bao gồm:
- Business requirements + user stories
- Acceptance criteria (tiêu chí "đã làm xong")
- API contracts + database schema
- Non-functional requirements (performance, security, accessibility)
- Risk tier (P0/P1/P2/P3) — ảnh hưởng tỷ lệ test case

**Gate 1:** Spec phải pass testability check (⛔ hard gate). Spec bị block nếu ACs không verifiable hoặc có mâu thuẫn.

> **Tại sao cần hard gate?** Spec mơ hồ dẫn đến implementation mơ hồ và test không đủ. Gate này buộc team phải đồng thuận về "done" trước khi viết một dòng code.

### Giai đoạn 2: PLAN (Lên kế hoạch)

**Agent:** planner  
**Output:** `PLAN.md` — kế hoạch chi tiết

Kế hoạch bao gồm:
- Danh sách files cần tạo/sửa với đường dẫn cụ thể
- Database migrations, API endpoints, frontend components
- Test strategy cho từng layer
- Các vấn đề security cần xử lý
- Ước tính effort cho từng task

### Giai đoạn 3: BUILD (Xây dựng)

**Agent:** executor  
**Protocol:** Atomic commits — mỗi commit = một task

Mỗi task theo TDD:
1. Viết failing test
2. Implement code tối thiểu để pass
3. Refactor
4. Commit

**Giai đoạn 3.5 (nếu có brownfield):** Load `.em-brownfield/` context cho modules liên quan. Sau khi build, cập nhật FLOWS.md nếu có behavior mới.

### Giai đoạn 4: VERIFY (Xác minh)

**Agents:** brownfield-test-engineer → test-verifier

**Thứ tự quan trọng trong VERIFY:**

```
Step 5.1: code-review diff scan (ĐẦU TIÊN)
Step 5.2: verify spec coverage
Step 5.3: tạo/cập nhật TC-REGISTRY
Step 5.4: chạy tests + thu thập evidence
Step 5.5: test-verifier double-check (tối đa 3 lần retry)
```

> **Tại sao code review chạy TRƯỚC test?** Nếu review tìm bug và bạn fix, bạn cần test suite chạy lại để confirm fix không break gì. Nếu test chạy trước, fix từ review không được validate.

**Gate 4:** TC-code coverage = 100% per layer. Mỗi TC-ID có `test()` block hoặc `test.todo()`. Confidence score ≥ 80%.

### Giai đoạn 5: REVIEW (Review)

**Agents:** code-reviewer + security-reviewer (nếu có auth/input/data changes)

5-axis review:
1. **Correctness** — logic, edge cases, error handling
2. **Security** — OWASP Top 10 liên quan đến thay đổi
3. **Performance** — N+1 queries, missing indexes, bundle size
4. **Maintainability** — naming, complexity, abstractions
5. **Testing** — coverage, mutation immunity, regression risk

**Gate 5:** Tất cả CRITICAL và HIGH findings phải được giải quyết. Sign-off trong `REVIEW.md`.

### Giai đoạn 6: SHIP (Phát hành)

**Agents:** verifier → executor (git operations)

1. Rollback readiness gate — verify `git revert` an toàn
2. Final verification run
3. Version bump (nếu cần)
4. PR creation với description tự động điền

---

## Với Brownfield Context

Nếu `.em-brownfield/` tồn tại, workflow có thêm:

| Bước thêm | Khi nào | Làm gì |
|-----------|---------|--------|
| Stage 0.5: Context Load | Trước DEFINE | Load INDEX + module FLOWS + CODE-MAP |
| Stage 3.5: Spec alignment | Sau BUILD | Kiểm tra build match với FLOWS acceptance criteria |
| Stage 5.7: Context Update | Sau REVIEW pass | Thêm flows/ACs mới vào FLOWS.md, cập nhật CODE-MAP |

Nghĩa là sau mỗi feature mới, brownfield knowledge base lớn thêm — điều tra sau này có context tốt hơn.

---

## Ví dụ Thực Tế

```bash
/em-wf:new-feature Thêm quản lý payment method (xem, thêm, xóa thẻ)
```

**Giai đoạn 1 — DEFINE:**
```
Spec được tạo: SPEC.md
  ACs:
    - AC-001: User xem danh sách thẻ đã lưu (4 số cuối, ngày hết hạn)
    - AC-002: User thêm thẻ mới qua Stripe Elements
    - AC-003: User xóa thẻ (có confirm dialog)
    - AC-004: Không xóa được thẻ cuối nếu đang có subscription active
  Risk tier: P0 (payment data, PCI scope)
  ⛔ TESTABILITY GATE: PASS
```

**Giai đoạn 2 — PLAN:**
```
Files cần tạo:
  - src/payment/payment-methods.controller.ts
  - src/payment/payment-methods.service.ts
  - src/payment/dto/add-card.dto.ts
Files cần sửa:
  - src/payment/payment.module.ts
  - frontend/src/pages/settings/payment.tsx
8 tasks (TDD, atomic commits)
```

**Giai đoạn 4 — VERIFY:**
```
Step 5.1 code-review: 2 HIGH findings → được fix → re-commit
TC-REGISTRY: 28 TCs (P0 ratios: 40% negative ✅, 18% abuse ✅, 12% non-func ✅)
Tests: 28/28 PASS — confidence: 93%
```

**Giai đoạn 6 — SHIP:**
```
PR được tạo: feat/payment-method-management
  Description: auto-filled từ spec + review findings
```

---

## Tóm tắt Gates

| Gate | Kiểm tra | Block khi nào |
|------|---------|---------------|
| Gate 1 (Spec) | Testability, mâu thuẫn | ACs không verifiable hoặc mâu thuẫn |
| Gate 4 (Verify) | TC coverage, test pass | TC-IDs không có test(), confidence < 80% |
| Gate 5 (Review) | CRITICAL + HIGH findings | CRITICAL chưa giải quyết |
| Gate 6 (Ship) | Rollback readiness | `git revert` không an toàn |

---

**Phiên bản:** 5.5.0
**Cập nhật lần cuối:** 2026-05-27

Xem thêm: [Brownfield Intelligence](brownfield.md) · [Test Automation Chain](test-automation.md) · [Code Review](code-review.md)

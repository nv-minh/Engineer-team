# Hướng Dẫn Code Review

EM-Team có 3 entry point review với độ sâu khác nhau. Chọn đúng entry point giúp tiết kiệm thời gian và đảm bảo quality.

---

## Tại sao cần AI code review?

Code review thủ công thường bỏ sót những vấn đề ẩn:
- Security vulnerabilities ít gặp (IDOR, injection) — reviewer quen code có thể bỏ qua
- Cross-file impact — thay đổi một hàm có thể ảnh hưởng 10 callers
- Performance patterns (N+1 queries) — chỉ thấy rõ khi nhìn toàn bộ query

AI review bổ sung những điểm này một cách có hệ thống theo framework.

---

## Khi nào dùng review nào?

| Lệnh | Mode | Khi nào dùng |
|------|------|-------------|
| `/em-agent:code-reviewer` | Standard (5-axis) | PR hàng ngày, feature thông thường |
| `/em-agent:code-reviewer Deep review` | Deep (9-axis) | Auth, payment, production-critical code |
| `/em-wf:code-review` | Workflow (9-axis + security) | Pre-release, thay đổi kiến trúc |

---

## `/em-agent:code-reviewer` — Standard (5 Axes)

```bash
# Review changes hiện tại
/em-agent:code-reviewer Review changes trong PR này

# Review file cụ thể
/em-agent:code-reviewer Review src/payment/payment.service.ts

# Với context
/em-agent:code-reviewer Review authentication changes — JWT refresh token flow
```

### 5 Trục Review

**1. Correctness (Tính đúng đắn)**
- Logic errors, off-by-one, null/undefined không xử lý
- Edge cases bị bỏ sót (empty list, concurrent access, timeout)
- Lỗi propagation — khi fail có surface đúng không?

**2. Security (Bảo mật)**
- Input validation và sanitization (injection, XSS, SSRF)
- Authentication/authorization check trên mọi endpoint
- Secrets, credentials, PII trong logs hoặc response
- Dependency vulnerabilities

**3. Performance (Hiệu năng)**
- N+1 query patterns
- Missing database indexes
- Bundle size impact (frontend)
- Memory leaks (event listeners, subscriptions chưa cleanup)

**4. Maintainability (Khả năng bảo trì)**
- Naming clarity — tên có reveal intent không?
- Function/class quá phức tạp (cyclomatic complexity, length)
- Abstraction không cần thiết (over-engineering)
- Dead code, commented-out code

**5. Testing (Kiểm thử)**
- Coverage của code paths mới
- Test quality — test behavior chứ không test implementation
- Missing edge case tests
- Regression risk

### Tính năng tự động quan trọng

**Step 1.5 — Diff Classification:**
Agent phân loại từng file thay đổi:
- `NEW` — file mới, review design + completeness
- `MODIFIED` — diff context loaded, review correctness + regression
- `DELETED` — check callers còn tham chiếu không

**Step 4.5 — Cross-file Impact Scan:**
Nếu symbol thay đổi có >5 callers, hoặc ảnh hưởng shared state:
- List tất cả callers và test coverage của chúng
- Flag contract changes (parameter type/count thay đổi)
- Escalate lên `em-agent:architect` nếu impact là architectural

---

## `/em-agent:code-reviewer` — Deep Mode (9 Axes)

```bash
/em-agent:code-reviewer Deep review payment module changes
/em-agent:code-reviewer 9-axis review trước production release
```

Deep mode thêm 4 axes vào 5 axes standard:

**6. Architecture Alignment (Kiến trúc)**
- Change có respect module boundaries không?
- Circular dependencies?
- Consistent với ADR của subsystem?

**7. API Design (Thiết kế API)**
- Naming, versioning, error response shape nhất quán
- Backward compatibility — clients cũ không bị break
- Implementation có match OpenAPI/GraphQL spec không?

**8. Observability (Quan sát)**
- Structured logging ở levels phù hợp
- Metrics/tracing hooks cho performance-sensitive paths
- Error conditions alertable không?

**9. Documentation (Tài liệu)**
- Public API changes có update OpenAPI spec chưa?
- Decisions không rõ ràng có inline comment không?
- Breaking change có migration guide không?

---

## `/em-wf:code-review` — Full Workflow

```bash
/em-wf:code-review Deep review authentication system changes
```

Workflow chạy code-reviewer (Deep) + security-reviewer tuần tự, với formal sign-off gate.

**Stages:**
1. Diff analysis và file classification
2. 9-axis code review → findings report
3. Security review (OWASP Top 10)
4. Cross-file impact scan
5. Human gate — bạn review findings trước khi sign-off
6. Sign-off ghi vào `REVIEW.md`

Dùng workflow cho:
- Code chạm auth, payment, hoặc PII handling
- Thay đổi trước major release
- External API surface changes

---

## Đọc Output Review

Findings được phân loại theo severity:

| Severity | Ý nghĩa | Hành động |
|----------|---------|-----------|
| `CRITICAL` | Breach dữ liệu, crash trong production path | **Block merge** |
| `HIGH` | Bug nghiêm trọng hoặc security weakness | **Block merge** (mặc định) |
| `MEDIUM` | Code quality issue, maintainability risk | Advisory |
| `LOW` | Style, naming, minor improvements | Advisory |

Mỗi finding bao gồm:
- File path + line number
- Mô tả vấn đề
- Tại sao nó quan trọng
- Gợi ý fix (code snippet)

### Ví dụ finding

```
[HIGH] A01 Broken Access Control
Location: src/admin/users.controller.ts:47
Vấn đề: Endpoint thiếu role guard — bất kỳ user nào cũng có thể list tất cả users
Impact: PII exposure (email, phone) cho mọi user trong hệ thống
Fix:
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Get()
  findAll() { ... }
```

---

## Sau khi có findings

```bash
# 1. Fix CRITICAL và HIGH findings
# 2. Re-run test suite để confirm fixes không break gì
# 3. Nếu cần, verify lần nữa:
/em-agent:code-reviewer Verify the fixes từ review trước
```

Với MEDIUM/LOW findings bạn không đồng ý: để lại comment trong PR giải thích lý do quyết định — reviewer và người đọc sau cần context này.

---

## Tích hợp với Workflow

Code review được tích hợp tự động:

| Workflow | Review chạy ở đâu |
|----------|------------------|
| `new-feature` | Stage 5 (VERIFY) — Step 5.1 ĐẦU TIÊN |
| `bug-fix` | Stage 5 — trước khi test suite |
| `code-review` workflow | Toàn bộ workflow |
| `greenfield-app` | Stage 11 (REVIEW) |

---

**Phiên bản:** 5.5.0
**Cập nhật lần cuối:** 2026-05-27

Xem thêm: [Security Review](security-review.md) · [New Feature Workflow](new-feature-workflow.md)

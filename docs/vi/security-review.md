# Hướng Dẫn Security Review

EM-Team có 4 entry point security review với độ sâu khác nhau — từ review nhanh một PR đến threat modeling toàn bộ hệ thống.

---

## Tại sao cần Security Review?

Security vulnerabilities thường không hiện ra khi nhìn code bình thường:
- **Broken Access Control** — endpoint thiếu guard nhìn qua có vẻ ổn nhưng bất kỳ user nào cũng gọi được
- **Injection** — input không validate đúng chỗ có thể bị khai thác từ hướng khác
- **Business logic flaws** — attacker có thể bypass flow theo cách dev không nghĩ đến

Security review có hệ thống theo OWASP Top 10 giúp tìm những lỗ hổng này trước khi ship.

---

## Khi nào dùng?

| Lệnh | Mode | Khi nào dùng |
|------|------|-------------|
| `/em-agent:security-reviewer` | Review | PR mới, endpoint mới, feature mới |
| `/em-agent:security-reviewer Audit mode` | Audit | Payment, auth, PII — trước release |
| `/em-wf:security-audit` | OWASP Workflow | Security check toàn hệ thống, compliance |
| `/em-wf:security-review-advanced` | OWASP + STRIDE | Auth system mới, pre-launch, post-incident |

---

## `/em-agent:security-reviewer` — Review Mode

Mặc định khi gọi agent. Focused vào code đang thay đổi.

```bash
# Review thay đổi hiện tại
/em-agent:security-reviewer Review the authentication changes

# Focus vào concern cụ thể
/em-agent:security-reviewer Review input validation in the payment API

# Audit mode (scan toàn bộ module)
/em-agent:security-reviewer Audit the user management module
```

### Review Mode kiểm tra

- OWASP Top 10 risks liên quan đến code thay đổi
- Authentication/authorization trên mọi endpoint
- Input validation và output encoding
- Xử lý sensitive data (credentials, PII, secrets)
- Dependency vulnerabilities trong package mới

### Audit Mode bổ sung thêm

- Scan OWASP Top 10 toàn bộ target (không chỉ diff)
- Threat enumeration — attacker có thể làm gì với component này?
- CVSS-style severity scoring
- Remediation recommendations với code examples

**Blocking authority:** CRITICAL security findings block merge cho đến khi được fix. Đây không phải advisory — agent flag rõ "this blocks ship".

---

## `/em-wf:security-audit` — OWASP Workflow

Workflow 5 giai đoạn cho comprehensive security assessment.

```bash
/em-wf:security-audit Audit the payment and authentication systems
```

### 5 Giai Đoạn

1. **Reconnaissance** — map attack surface, entry points, trust boundaries
2. **OWASP Assessment** — systematic scan 10 categories
3. **Analysis** — correlate findings, identify exploit chains
4. **Evidence** — reproduce từng finding, capture proof-of-concept
5. **Report** — prioritized findings với remediation roadmap

### OWASP Top 10

| # | Category | Agent kiểm tra gì |
|---|----------|--------------------|
| A01 | Broken Access Control | IDOR, path traversal, privilege escalation, missing auth |
| A02 | Cryptographic Failures | Weak algorithms, hardcoded keys, unencrypted PII |
| A03 | Injection | SQL injection, NoSQL injection, LDAP, command injection |
| A04 | Insecure Design | Missing threat model, insecure defaults, business logic flaws |
| A05 | Security Misconfiguration | Debug mode in prod, default credentials, verbose errors |
| A06 | Vulnerable Components | Known CVEs, outdated libraries |
| A07 | Auth Failures | Brute force, session fixation, weak password policy, token reuse |
| A08 | Data Integrity | Unsigned objects, deserialization, CI/CD pipeline integrity |
| A09 | Logging Failures | No audit trail, PII in logs, insufficient monitoring |
| A10 | SSRF | Internal service exposure, cloud metadata endpoint access |

---

## `/em-wf:security-review-advanced` — OWASP + STRIDE

Full threat modeling. Dùng khi thiết kế hoặc thay đổi lớn một component security-sensitive.

```bash
/em-wf:security-review-advanced Threat model the new OAuth2 SSO integration
/em-wf:security-review-advanced Review the API gateway before launch
```

### 5 Giai Đoạn

1. OWASP Top 10 assessment (giống `security-audit`)
2. STRIDE threat modeling
3. Attack tree construction
4. Risk prioritization matrix
5. Remediation plan với implementation order

### STRIDE là gì?

STRIDE là framework phân loại threat — mỗi chữ là một loại threat:

| Threat | Nghĩa | Ví dụ |
|--------|-------|-------|
| **S**poofing | Giả mạo user hoặc hệ thống | JWT token bị forge vì secret yếu |
| **T**ampering | Sửa data trong transit hoặc lưu trữ | Order total bị sửa qua IDOR trước khi thanh toán |
| **R**epudiation | Phủ nhận đã thực hiện hành động | Không có audit log cho admin privilege escalation |
| **I**nformation Disclosure | Lộ data cho bên không được phép | Stack trace trả về DB schema cho client |
| **D**enial of Service | Làm service không hoạt động | Không có rate limiting trên auth endpoint |
| **E**levation of Privilege | Lấy quyền nhiều hơn được phép | User thường gọi được admin API vì thiếu role check |

Với mỗi component trong scope, agent hỏi: "Attacker có thể Spoof / Tamper / Repudiate / Disclose / DoS / Elevate với component này không?"

---

## Khi Nào Dùng Cái Nào?

| Trường hợp | Khuyến nghị |
|------------|-------------|
| PR thêm endpoint mới hoặc auth logic | `em-agent:security-reviewer` (Review mode) |
| Feature chạm payments, PII, credentials | `em-agent:security-reviewer Audit mode` |
| Security check trước release | `em-wf:security-audit` |
| Auth system mới hoặc OAuth integration | `em-wf:security-review-advanced` |
| Compliance requirement (SOC2, PCI) | `em-wf:security-audit` + export findings |
| Post-incident review | `em-wf:security-review-advanced` |

---

## Đọc Output Security Review

Findings được phân loại theo severity:

| Severity | Ý nghĩa | SLA |
|----------|---------|-----|
| `CRITICAL` | Có thể exploit ngay, data breach hoặc RCE | Fix trước bất kỳ deployment nào |
| `HIGH` | Khả năng cao bị exploit, impact lớn | Fix trước release tiếp theo |
| `MEDIUM` | Có thể exploit trong điều kiện nhất định | Fix trong sprint hiện tại |
| `LOW` | Defense-in-depth improvement | Backlog |
| `INFO` | Quan sát, không cần action | — |

### Ví dụ finding

```
[HIGH] A01 Broken Access Control
Location: src/admin/users.controller.ts:47 (GET /admin/users)
Vấn đề: Endpoint thiếu role guard — bất kỳ user đã auth nào cũng list được tất cả users
Impact: PII exposure (email, phone) cho mọi user trong hệ thống
Fix:
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Get()
  findAll() { ... }
```

---

## Sau khi có Findings

```bash
# 1. Fix CRITICAL findings ngay
# 2. Fix HIGH findings trước khi merge
# 3. Re-run security review để confirm:
/em-agent:security-reviewer Verify the security fixes

# 4. MEDIUM/LOW — đánh giá và quyết định
#    Nếu không fix, để lại comment trong PR giải thích lý do
```

---

## Tích Hợp Với Workflow

| Workflow | Security review chạy ở đâu |
|----------|---------------------------|
| `new-feature` Stage 5 | Code chạm auth/input/data → security-reviewer (Review mode) |
| `code-review-9axis` | Luôn chạy → security-reviewer (Review mode) |
| `security-audit` workflow | Manual → Full OWASP scan |
| `security-review-advanced` | Manual → OWASP + STRIDE |

Với team có compliance requirement (PCI-DSS, SOC2, HIPAA): chạy `em-wf:security-audit` cuối mỗi sprint cho các components trong scope.

---

**Phiên bản:** 5.5.0
**Cập nhật lần cuối:** 2026-05-27

Xem thêm: [Code Review](code-review.md) · [New Feature Workflow](new-feature-workflow.md)

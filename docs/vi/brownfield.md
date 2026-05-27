# Hướng Dẫn Brownfield Intelligence

Xây dựng "bản đồ kiến thức" cho codebase cũ để mọi agent — debugger, test writer, verifier — đều hiểu nghiệp vụ của bạn trước khi bắt đầu làm việc.

---

## Tại sao cần Brownfield Intelligence?

Khi bạn đưa một codebase cũ cho Claude để điều tra bug, thường xảy ra vấn đề này: Claude không biết "PaymentService.charge" làm gì trong ngữ cảnh nghiệp vụ. Nó có thể đọc code, nhưng không hiểu **tại sao** code tồn tại.

Brownfield Intelligence giải quyết điều này bằng cách tạo ra một **bản đồ kiến thức module** (`.em-brownfield/`) — tổ chức theo bounded contexts (payments, auth, orders) chứ không phải theo cấu trúc thư mục kỹ thuật. Khi có bản đồ này, mọi agent đều load context liên quan trước khi phân tích.

**Lợi ích thực tế:**
- Debugger biết "FLOW-PAYMENT-001 → charge customer" trước khi đọc code
- Test engineer tự tạo test case từ Acceptance Criteria có sẵn
- Verifier check AC regression sau mỗi thay đổi
- PR review biết flow nào bị ảnh hưởng trước khi merge

---

## Khi nào nên chạy onboarding?

✅ **Nên dùng khi:**
- Bạn mới join project và cần hiểu nhanh hệ thống
- Team cần điều tra bug trong codebase chưa ai hiểu rõ
- Chuẩn bị viết test cho legacy code
- Trước khi refactor module phức tạp

❌ **Không cần dùng khi:**
- Dự án greenfield mới toanh (chưa có code)
- Codebase rất nhỏ, 1-2 modules rõ ràng

---

## Quickstart (3 bước)

```bash
# Bước 1: Onboard codebase (chạy 1 lần)
/em-skill:brownfield-onboarding

# Bước 2: Điều tra bug với context đã load
/em-wf:brownfield-investigation Fix lỗi timeout checkout ảnh hưởng 5% đơn hàng

# Bước 3: Kiểm tra PR trước khi merge
/em-skill:brownfield-pr-impact
```

---

## Bước 1: Onboard — `/em-skill:brownfield-onboarding`

Chạy **một lần** khi bắt đầu. Nếu codebase thay đổi lớn, chạy lại.

### Điều gì xảy ra bên dưới?

1. **Auto-detect stack** (`detect-stack.sh`) — nhận biết NestJS, React, monorepo, v.v.
2. **Scan entrypoints** — dùng `scan-nestjs.sh` hoặc `scan-react.sh` tùy stack
3. **Khám phá business domains** — agent đề xuất tên module từ cấu trúc code
4. **Bạn xác nhận** danh sách module (bán tự động: agent đề xuất, bạn quyết định)
5. **Tạo artifacts** cho từng module:
   - `FLOWS.md` + `FLOWS.json` — luồng nghiệp vụ với acceptance criteria (ID ổn định)
   - `DOMAIN.md` — entities, quan hệ, ubiquitous language, bảng PII
   - `INTEGRATIONS.md` — dịch vụ ngoài + dependencies giữa các module
   - `CODE-MAP.md` + `CODE-MAP.json` — flow steps → `Class.method` symbols
6. **Quality gate** — validate refs + chấm điểm Grade A/B/C/D

### Quality Gate là gì?

Trước khi kết thúc onboarding, agent chạy:

```bash
bash scripts/brownfield/validate-refs.sh .em-brownfield/   # kiểm tra tất cả cross-refs hợp lệ
bash scripts/brownfield/quality-score.sh .em-brownfield/   # Grade A = sẵn sàng dùng
```

Grade A nghĩa là không có broken references và tất cả sections bắt buộc đều có.

### Cấu trúc output

```
.em-brownfield/
├── INDEX.md                     # Registry các module + dependency graph
├── DOMAIN-PROFILE.yaml          # Stack, DB, auth method, compliance flags
└── modules/
    ├── payment/
    │   ├── FLOWS.md             # Luồng với AC-PAYMENT-001, AC-PAYMENT-002...
    │   ├── FLOWS.json           # JSON sidecar cho agent tooling
    │   ├── DOMAIN.md            # Entity, PII fields (số thẻ, v.v.)
    │   ├── INTEGRATIONS.md      # Stripe, module order dependency
    │   ├── CODE-MAP.md          # FLOW-PAYMENT-001 → PaymentService.charge
    │   └── CODE-MAP.json        # JSON sidecar
    ├── auth/
    ├── order/
    └── ...
```

---

## Bước 2: Điều tra Bug — `/em-wf:brownfield-investigation`

Workflow điều tra bug với context đã được load sẵn.

```bash
/em-wf:brownfield-investigation Fix lỗi payment timeout ảnh hưởng 5% đơn hàng
```

### 6 giai đoạn của workflow

| Giai đoạn | Điều gì xảy ra |
|-----------|----------------|
| **CONTEXT LOAD** | Đọc INDEX.md, xác định modules liên quan, load FLOWS + CODE-MAP |
| **REPRODUCE** | Tái tạo lỗi với context module đã biết |
| **ROOT CAUSE** | Trace qua CODE-MAP symbols; dùng `symbol-resolver.sh` tìm `file:line` hiện tại |
| **EVIDENCE** | Tạo evidence package với `EVIDENCE.json` manifest |
| **HUMAN GATE** | Trình bày phát hiện; bạn quyết định bước tiếp |
| **CONTEXT UPDATE** | Cập nhật FLOWS.md nếu phát hiện behavior chưa được document |

### FLOW và AC IDs là gì?

Đây là hệ thống ID ổn định — không thay đổi dù bạn refactor code:

| ID | Ví dụ | Nghĩa |
|----|-------|-------|
| `FLOW-PAYMENT-001` | Charge customer at checkout | Một luồng nghiệp vụ hoàn chỉnh |
| `AC-PAYMENT-001` | Payment succeeds with valid card | Một acceptance criterion trong luồng |
| `AC-PAYMENT-003` | Payment fails gracefully on expired card | Criterion cho sad path |

Agent và test files tham chiếu qua ID này — không phải file:line fragile.

---

## Bước 3: Kiểm tra PR — `/em-skill:brownfield-pr-impact`

Chạy trước khi merge bất kỳ PR nào thay đổi business logic.

```bash
/em-skill:brownfield-pr-impact
```

### Output mẫu

```
AC-at-risk:
  AC-PAYMENT-003 (payment fails gracefully) — PaymentService.charge signature thay đổi
  AC-ORDER-007 (order total recalculated) — OrderService.recalculate bị chạm

CONTRACT_BREAK:
  payment → order: OrderService.confirm(orderId) bị xóa
  Impact: order module gọi method này sau khi payment thành công
```

Phát hiện `CONTRACT_BREAK` **block merge** cho đến khi module phụ thuộc được cập nhật.

---

## Bước 4: Viết Test — `/em-agent:brownfield-test-engineer`

Tạo tests trực tiếp từ brownfield context — không cần giải thích lại flows.

```bash
/em-agent:brownfield-test-engineer Viết tests cho payment module
```

Agent tự động:
1. Đọc `FLOWS.json` → lấy tất cả `AC-PAYMENT-*` criteria
2. Đọc `DOMAIN.md` → tạo test fixtures từ entity shapes
3. Đọc `INTEGRATIONS.md` → tạo negative TCs (Stripe timeout, v.v.)
4. Đọc `DOMAIN-PROFILE.yaml` → đặt risk_tier (P0 cho payment)
5. Tạo `TC-REGISTRY.md` với 12 cột
6. Viết test files với `test("AC-PAYMENT-001: ...")`

---

## Giữ Context Tươi — `/em-skill:brownfield-context-sync`

Chạy sau khi có thay đổi code đáng kể (refactor, feature mới, xóa endpoint).

```bash
/em-skill:brownfield-context-sync
```

Agent dùng `symbol-resolver.sh` kiểm tra các `Class.method` refs trong CODE-MAP còn resolve không. Phát hiện và đề xuất cập nhật cụ thể cho FLOWS.md + CODE-MAP.md.

---

## Lỗi thường gặp

| Lỗi | Hậu quả | Cách sửa |
|-----|---------|----------|
| Tổ chức module theo layer kỹ thuật (controllers/, services/) | Flows bị phân mảnh | Dùng business domains: payment, auth, order |
| Bỏ qua quality gate | Agents load broken context | Luôn chạy `validate-refs.sh` trước khi dùng |
| Không sync sau refactor lớn | CODE-MAP refs broke silently | Chạy `brownfield-context-sync` sau mỗi PR lớn |
| Sửa FLOWS.json tay | JSON schema break | Sửa FLOWS.md; để onboarding regenerate JSON |

---

**Phiên bản:** 5.5.0
**Cập nhật lần cuối:** 2026-05-27

Xem thêm: [Test Automation Chain](test-automation.md) · [New Feature Workflow](new-feature-workflow.md)

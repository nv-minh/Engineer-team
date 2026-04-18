# Hướng Dẫn Sử Dụng EM-Skill

Hướng dẫn hoàn chỉnh cho hệ thống kỹ thuật fullstack EM-Skill.

---

## Mục Lục

1. [Tổng quan](#tổng-quan)
2. [Sử dụng Skills](#sử-dụng-skills)
3. [Sử dụng Agents](#sử-dụng-agents)
4. [Sử dụng Workflows](#sử-dụng-workflows)
5. [Chế độ Phân tán](#chế-độ-phân-tán)
6. [Best Practices](#best-practices)
7. [Ví dụ](#ví-dụ)
8. [Xử lý sự cố](#xử-lý-sự-cố)

---

## Tổng quan

EM-Skill cung cấp ba cách chính để hoàn thành tasks:

| Phương pháp | Mô tả | Tốt nhất cho |
|-------------|---------|--------------|
| **Skills** | Các pattern và practices có thể tái sử dụng | Tasks phát triển cụ thể |
| **Agents** | Các AI assistants chuyên biệt | Công việc chuyên môn phức tạp |
| **Workflows** | Quy trình end-to-end | Vòng đời dự án hoàn chỉnh |

---

## Sử dụng Skills

### Skills là gì?

Skills là các pattern và best practices có thể tái sử dụng, được tổng hợp từ các kho lưu trữ AI agent hàng đầu. Chúng cung cấp các cách tiếp cận có cấu trúc cho các tasks phát triển phổ biến.

### Các Skills có sẵn

#### Foundation Skills (Cốt lõi)
1. **spec-driven-development** - Viết specifications trước khi code
2. **brainstorming** - Khám phá ý tưởng thành thiết kế chi tiết
3. **context-engineering** - Tối ưu hóa thiết lập context cho agent
4. **writing-plans** - Phân nhỏ work thành các tasks khả quản
5. **systematic-debugging** - Phương pháp debugging 4 giai đoạn

#### Development Skills
6. **test-driven-development** - TDD: RED-GREEN-REFACTOR
7. **frontend-patterns** - Best practices React/Next.js/Vue
8. **backend-patterns** - Patterns API/Database
9. **incremental-implementation** - Phát triển theo vertical slice
10. **subagent-driven-development** - Fresh context cho mỗi task
11. **source-driven-development** - Code từ tài liệu chính thức
12. **api-interface-design** - API theo hướng contract-first
13. **security-hardening** - Bảo mật OWASP Top 10

#### Quality Skills
14. **code-review** - Framework review 5-trục
15. **code-simplification** - Giảm độ phức tạp
16. **browser-testing** - Tích hợp DevTools MCP
17. **performance-optimization** - Tối ưu hóa theo hướng measure-first
18. **e2e-testing** - Patterns Playwright
19. **security-audit** - Đánh giá lỗ hổng bảo mật
20. **api-testing** - Kiểm thử tích hợp

#### Workflow Skills
21. **git-workflow** - Atomic commits
22. **ci-cd-automation** - Feature flags, quality gates
23. **documentation** - ADRs, tài liệu API
24. **finishing-branch** - Quyết định merge/PR
25. **deprecation-migration** - Tư duy code-as-liability

### Cách sử dụng Skills

Kích hoạt skills trực tiếp trong conversation của bạn:

```bash
# Ví dụ 1: Brainstorming
"Sử dụng brainstorming skill để khám phá tính năng authentication"

# Ví dụ 2: Spec-driven development
"Sử dụng spec-driven-development skill để tạo spec cho JWT authentication"

# Ví dụ 3: Debugging
"Sử dụng systematic-debugging skill để điều tra bug login timeout"
```

### Luồng thực thi Skill

Khi bạn kích hoạt một skill:

```
1. Kích hoạt skill
   ↓
2. Thu thập context
   ↓
3. Áp dụng pattern
   ↓
4. Tạo output
   ↓
5. Xác minh
```

---

## Sử dụng Agents

### Agents là gì?

Agents là các AI assistants chuyên biệt xử lý các loại tasks cụ thể. Mỗi agent có chuyên môn trong một domain cụ thể.

### Core Agents

#### 1. Planner Agent
**Mục đích:** Tạo kế hoạch triển khai chi tiết
**Cách dùng:** `Agent: em-planner - Tạo kế hoạch triển khai cho feature X`
**Tốt nhất cho:** Phân nhỏ features phức tạp

#### 2. Executor Agent
**Mục đích:** Thực thi plans với atomic commits
**Cách dùng:** `Agent: em-executor - Triển khai kế hoạch authentication`
**Tốt nhất cho:** Implementation với version control

#### 3. Code-Reviewer Agent
**Mục đích:** Code review 5-trục
**Cách dùng:** `Agent: em-code-reviewer - Review các thay đổi trong PR này`
**Tốt nhất cho:** Đảm bảo chất lượng

#### 4. Debugger Agent
**Mục đích:** Debugging có hệ thống
**Cách dùng:** `Agent: em-debugger - Điều tra bug này một cách có hệ thống`
**Tốt nhất cho:** Phân tích root cause

#### 5. Test-Engineer Agent
**Mục đích:** Chiến lược và tạo tests
**Cách dùng:** `Agent: em-test-engineer - Tạo chiến lược test cho authentication`
**Tốt nhất cho:** Lập kế hoạch test

#### 6. Security-Auditor Agent
**Mục đích:** Đánh giá bảo mật OWASP
**Cách dùng:** `Agent: em-security-auditor - Audit hệ thống authentication`
**Tốt nhất cho:** Reviews bảo mật

#### 7. UI-Auditor Agent
**Mục đích:** QA hình ảnh và review design
**Cách dùng:** `Agent: em-ui-auditor - Review thiết kế trang login`
**Tốt nhất cho:** Chất lượng UI/UX

#### 8. Verifier Agent
**Mục đích:** Xác minh sau thực thi
**Cách dùng:** `Agent: em-verifier - Xác minh triển khai feature`
**Tốt nhất cho:** Validation cuối cùng

### Specialized Agents

#### 9. Researcher Agent
Khám phá và nghiên cứu kỹ thuật

#### 10. Codebase-Mapper Agent
Phân tích kiến trúc và tài liệu hóa

#### 11. Integration-Checker Agent
Xác thực cross-phase

#### 12. Performance-Auditor Agent
Benchmarking và tối ưu hóa

#### 13. Backend-Expert Agent
Chuyên gia backend (API, database, performance)

#### 14. Frontend-Expert Agent
Chuyên gia frontend (UI, UX, frameworks)

#### 15. Database-Expert Agent
Chuyên gia database (schema, queries, optimization)

#### 16. Tech-Lead-Orchestrator Agent
Phối hợp các investigations phân tán

### Cách sử dụng Agents

Dispatch agents cho các tasks chuyên biệt:

```bash
# Pattern cơ bản
"Agent: em-[tên-agent] - [mô tả-task]"

# Ví dụ
"Agent: em-planner - Tạo kế hoạch triển khai cho user authentication"
"Agent: em-code-reviewer - Review PR authentication"
"Agent: em-debugger - Điều tra lỗi login"
```

### Patterns tương tác Agent

#### Sử dụng Agent theo tuần tự
```bash
# Sử dụng nhiều agents theo tuần tự
"Agent: em-planner - Lập kế hoạch feature"
↓
"Agent: em-executor - Triển khai kế hoạch"
↓
"Agent: em-code-reviewer - Review implementation"
```

#### Sử dụng Agent song song (Chế độ Phân tán)
```bash
# Sử dụng nhiều agents đồng thời
./scripts/distributed-orchestrator.sh start
"Agent: em-techlead-orchestrator - Điều tra authentication"
# Backend, frontend, database agents làm việc song song
```

---

## Sử dụng Workflows

### Workflows là gì?

Workflows là các quy trình end-to-end kết hợp nhiều skills và agents để hoàn thành tasks phức tạp.

### Primary Workflows

#### 1. New Feature Workflow
**Mục đích:** Đưa features từ ý tưởng đến production
**Cách dùng:** `Workflow: em-new-feature - [mô tả-feature]`
**Giai đoạn:** Define → Plan → Build → Verify → Review → Simplify → Ship

#### 2. Bug Fix Workflow
**Mục đích:** Điều tra và fix bugs có hệ thống
**Cách dùng:** `Workflow: em-bug-fix - [mô tả-bug]`
**Giai đoạn:** Investigate → Analyze → Hypothesize → Implement → Verify

#### 3. Refactoring Workflow
**Mục đích:** Cải thiện chất lượng code một cách an toàn
**Cách dùng:** `Workflow: em-refactoring - [mục tiêu-refactoring]`
**Giai đoạn:** Analyze → Plan → Refactor → Test → Verify

#### 4. Security Audit Workflow
**Mục đích:** Đánh giá bảo mật toàn diện
**Cách dùng:** `Workflow: em-security-audit - [hệ thống cần audit]`
**Giai đoạn:** Trinh sát → Quét lỗ hổng → Phân tích → Báo cáo

### Support Workflows

#### 5. Project Setup Workflow
Khởi tạo projects mới với best practices

#### 6. Documentation Workflow
Tạo và cập nhật tài liệu

#### 7. Deployment Workflow
Triển khai và giám sát features

#### 8. Retro Workflow
Học hỏi và cải tiến từ work đã hoàn thành

### Distributed Workflows

#### 9. Distributed Investigation Workflow
Điều tra bug song song trên toàn bộ codebase
**Cách dùng:** `Workflow: em-distributed-investigation - [chủ đề điều tra]`

#### 10. Distributed Development Workflow
Triển khai features song song
**Cách dùng:** `Workflow: em-distributed-development - [mô tả-feature]`

### Team Workflows

#### 11. Team Review Workflow
Review toàn team được điều phối bởi Team Lead

#### 12. Architecture Review Workflow
Review kiến trúc với Architect & Staff Engineer

#### 13. Design Review Workflow
Review UI/UX với Frontend Expert & Product Manager

#### 14. Code Review 9-Axis Workflow
Code review sâu 9-trục với Senior Code Reviewer & Security

#### 15. Database Review Workflow
Review schema & queries database

#### 16. Product Review Workflow
Review product/spec với Product Manager

#### 17. Security Review Advanced Workflow
Bảo mật nâng cao (OWASP + STRIDE)

#### 18. Incident Response Workflow
Xử lý sự cố production

### Cách sử dụng Workflows

```bash
# Pattern cơ bản
"Workflow: em-[tên-workflow] - [mô tả-task]"

# Ví dụ
"Workflow: em-new-feature - Triển khai user authentication"
"Workflow: em-bug-fix - Fix bug login timeout"
"Workflow: em-security-audit - Audit hệ thống thanh toán"
```

---

## Chế độ Phân tán

### Chế độ Phân tán là gì?

Chế độ phân tán chạy nhiều specialist agents song song trong các tmux sessions cô lập để giải quyết token context overflow và cho phép xử lý song song.

### Khi nào sử dụng Chế độ Phân tán

✅ **Sử dụng khi:**
- Task yêu cầu phân tích trên nhiều domains
- Cần chuyên môn từ các areas khác nhau
- Context đang đạt giới hạn token
- Cần audit trail toàn diện
- Muốn thực thi song song để tăng tốc

❌ **Không sử dụng khi:**
- Task đơn giản và single-domain
- Cần investigation nhanh
- Không cần xử lý song song

### Khởi động Chế độ Phân tán

```bash
# Khởi động distributed orchestration
./scripts/distributed-orchestrator.sh start

# Điều này tạo:
# - tmux session: claude-work
# - Windows: orchestrator, backend, frontend, database
# - Directories: reports/, queue/, logs/

# Attach vào window orchestrator
tmux attach -t claude-work:orchestrator

# Kích hoạt investigation
"Agent: em-techlead-orchestrator - Điều tra bug authentication"

# Orchestrator sẽ:
# 1. Phân tích task
# 2. Delegate cho specialist agents
# 3. Thu thập findings
# 4. Consolidate thành report
```

### Quản lý Sessions Phân tán

```bash
# Liệt kê active sessions
./scripts/session-manager.sh list

# Kiểm tra trạng thái agent
./distributed/session-coordinator.sh agent-status

# Kiểm tra trạng thái queue
./distributed/session-coordinator.sh queue-status

# Broadcast message đến tất cả agents
./scripts/session-manager.sh broadcast "echo 'Cập nhật trạng thái'"

# Consolidate reports
./scripts/consolidate-reports.sh consolidate

# Dừng chế độ phân tán
./scripts/distributed-orchestrator.sh stop
```

### Xem Reports

```bash
# Liệt kê reports có sẵn
./scripts/consolidate-reports.sh list

# Xem consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# Xem reports của từng agent
ls /tmp/claude-work-reports/backend/
ls /tmp/claude-work-reports/frontend/
ls /tmp/claude-work-reports/database/
```

---

## Best Practices

### 1. Chọn Công cụ Phù hợp

```bash
# Task đơn giản → Sử dụng skill
"Sử dụng brainstorming skill để khám phá ý tưởng feature"

# Task chuyên biệt → Sử dụng agent
"Agent: em-code-reviewer - Review PR này"

# Quy trình phức tạp → Sử dụng workflow
"Workflow: em-new-feature - Xây dựng và ship feature"

# Task multi-domain → Sử dụng chế độ phân tán
./scripts/distributed-orchestrator.sh start
```

### 2. Cụ thể với Prompts

```bash
# ❌ Quá mơ hồ
"Agent: em-planner - Lập kế hoạch gì đó"

# ✅ Cụ thể và rõ ràng
"Agent: em-planner - Tạo kế hoạch triển khai cho user authentication dựa trên JWT với refresh tokens, bao gồm database schema, API endpoints, và frontend components"
```

### 3. Cung cấp Context

```bash
# ❌ Không có context
"Agent: em-debugger - Fix bug này"

# ✅ Với context
"Agent: em-debugger - Điều tra bug login timeout. Bắt đầu xảy ra sau deployment 2 tiếng trước. Lỗi: 'Connection timeout after 30s'. Ảnh hưởng 10% các attempts login. Backend logs cho thấy database query timeouts."
```

### 4. Tuân thủ Iron Laws

```bash
# TDD Iron Law
# KHÔNG CODE PRODUCTION KHÔNG CÓ TEST FAILING

# Debugging Iron Law
# KHÔNG FIX KHÔNG CÓ ROOT CAUSE

# Spec Iron Law
# KHÔNG CODE KHÔNG CÓ SPEC (cho features)
```

### 5. Review và Lặp lại

```bash
# Luôn review outputs của agent
"Agent: em-code-reviewer - Review implementation"

# Lặp lại dựa trên feedback
# Thực hiện improvements
# Re-verify
```

---

## Ví dụ

### Ví dụ 1: Xây dựng Authentication Feature

```bash
# Bước 1: Khám phá ý tưởng
"Sử dụng brainstorming skill để khám phá các tùy chọn authentication"

# Bước 2: Tạo specification
"Sử dụng spec-driven-development skill để tạo spec cho JWT authentication"

# Bước 3: Lập kế hoạch triển khai
"Agent: em-planner - Tạo kế hoạch triển khai cho JWT auth"

# Bước 4: Triển khai
"Agent: em-executor - Triển khai kế hoạch authentication"

# Bước 5: Test
"Agent: em-test-engineer - Tạo chiến lược test cho authentication"

# Bước 6: Review
"Agent: em-code-reviewer - Review implementation authentication"
"Agent: em-security-auditor - Audit bảo mật authentication"

# Bước 7: Triển khai
"Workflow: em-deployment - Triển khai feature authentication"
```

### Ví dụ 2: Debugging Sự cố Production

```bash
# Bước 1: Investigation ban đầu
"Sử dụng systematic-debugging skill để điều tra login timeout"

# Bước 2: Deep dive với chế độ phân tán
./scripts/distributed-orchestrator.sh start
tmux attach -t claude-work:orchestrator
"Agent: em-techlead-orchestrator - Điều tra login timeout trên toàn bộ stack"

# Bước 3: Review findings
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# Bước 4: Fix root cause
"Sử dụng test-driven-development skill để fix vấn đề connection pool database"

# Bước 5: Xác minh fix
"Agent: em-test-engineer - Xác minh fix login timeout"

# Bước 6: Postmortem
"Workflow: em-incident-response - Tạo postmortem cho sự cố login timeout"
```

### Ví dụ 3: Tối ưu hóa Performance

```bash
# Bước 1: Phân tích performance
"Agent: em-performance-auditor - Benchmark các API endpoints"

# Bước 2: Xác định bottlenecks
"Sử dụng performance-optimization skill để phân tích kết quả benchmark"

# Bước 3: Lập kế hoạch tối ưu
"Agent: em-planner - Tạo kế hoạch tối ưu dựa trên bottlenecks"

# Bước 4: Triển khai tối ưu
"Agent: em-executor - Triển khai các tối ưu hóa performance"

# Bước 5: Xác minh improvements
"Agent: em-performance-auditor - Re-benchmark sau tối ưu"

# Bước 6: Tài liệu hóa
"Sử dụng documentation skill để tài liệu hóa các cải thiện performance"
```

---

## Xử lý sự cố

### Vấn đề: Command Không Được Nhận Diện

**Giải pháp:**
```bash
# Xác minh file tồn tại
ls -la scripts/distributed-orchestrator.sh

# Make executable
chmod +x scripts/*.sh
chmod +x distributed/*.sh
```

### Vấn đề: tmux Session Không Được Tạo

**Giải pháp:**
```bash
# Kiểm tra cài đặt tmux
tmux -V

# Kill existing sessions
tmux kill-server

# Thử lại
./scripts/distributed-orchestrator.sh start
```

### Vấn đề: Agent Không Phản hồi

**Giải pháp:**
```bash
# Kiểm tra agent window
tmux list-windows -t claude-work

# Attach vào window cụ thể
tmux attach -t claude-work:backend

# Kiểm tra errors
ls /tmp/claude-work-logs/
```

### Vấn đề: Reports Không Được Tạo

**Giải pháp:**
```bash
# Kiểm tra shared directory
ls /tmp/claude-work-reports/*/

# Kích hoạt consolidation thủ công
./scripts/consolidate-reports.sh consolidate

# Kiểm tra output
cat /tmp/claude-work-reports/techlead/consolidated-report.md
```

### Vấn đề: Tests Fail

**Giải pháp:**
```bash
# Chạy với verbose output
cd tests
./run-e2e-tests.sh --verbose

# Chạy test riêng lẻ
./test-distributed-orchestrator.sh

# Kiểm tra test environment
ls /tmp/em-skill-test-*
```

---

## Sử dụng Nâng cao

### Cấu hình Agent Tùy chỉnh

Tạo custom agents theo template:

```bash
# Sử dụng agent template
cp templates/agent-invocation-template.md agents/my-custom-agent.md

# Edit với yêu cầu của bạn
# Theo cấu trúc agent
```

### Tùy chỉnh Workflow

Tạo custom workflows:

```bash
# Copy workflow hiện có
cp workflows/new-feature.md workflows/my-custom-workflow.md

# Modify theo nhu cầu
# Test với: "Workflow: em-my-custom-workflow - test task"
```

### Tích hợp với CI/CD

```yaml
# Ví dụ GitHub Actions
- name: Chạy EM-Skill Tests
  run: |
    cd tests
    ./run-e2e-tests.sh

- name: Security Audit
  run: |
    "Agent: em-security-auditor - Audit trước deployment"
```

---

## Tài nguyên

- [Tài liệu Kiến trúc](../architecture/overview.md)
- [Reference Protocol](../protocols/messaging.md)
- [Catalog Workflow](../workflows/overview.md)
- [Reference Skill](../skills/overview.md)
- [Reference Agent](../agents/overview.md)
- [Test Suite](../tests/README.md)

---

**Cần trợ giúp?** Kiểm tra [Xử lý sự cố](../troubleshooting.md) hoặc [GitHub Issues](https://github.com/nv-minh/agent-team/issues)

---

**Cập nhật lần cuối:** 2026-04-19
**Phiên bản:** 1.0.0

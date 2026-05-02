# Hướng Dẫn Sử Dụng EM-Team v3.0.0

Hướng dẫn hoàn chỉnh cho hệ thống kỹ thuật fullstack EM-Team với các command mới `em:`.

---

## Mục Lục

1. [Tổng quan](#tổng-quan)
2. [Communication Styles (MỚI)](#communication-styles)
3. [Cấu trúc Command mới](#cấu-trúc-command-mới)
4. [Sử dụng Skills](#sử-dụng-skills)
5. [Sử dụng Agents](#sử-dụng-agents)
6. [Sử dụng Workflows](#sử-dụng-workflows)
7. [Chế độ Phân tán](#chế-độ-phân-tán)
8. [Use Cases Chi tiết](#use-cases-chi-tiết)
9. [Best Practices](#best-practices)
10. [Xử lý sự cố](#xử-lý-sự-cố)

---

## Tổng quan

EM-Team v3.0.0 cung cấp 130+ commands được tổ chức thành 3 danh mục chính:

| Phương pháp | Số lượng | Mô tả | Tốt nhất cho |
|-------------|----------|-------|--------------|
| **Skills** | 43 | Patterns và practices có thể tái sử dụng | Tasks phát triển cụ thể |
| **Agents** | 31 | AI assistants chuyên biệt | Công việc chuyên môn phức tạp |
| **Workflows** | 23 | Quy trình end-to-end | Vòng đời dự án hoàn chỉnh |

### 🎯 Quick Start

```bash
# Xem tất cả commands
em-show           # Hoặc em-commands

# Xem help
em-help

# Skills - Prefix em:skill:
/em:skill:brainstorming User authentication với JWT
/em:skill:spec-driven-development Tạo spec cho payment system

# Agents - Gõ với em: prefix
/em:planner Tạo kế hoạch cho JWT auth
/em:code-reviewer Review PR #123

# Workflows - Gõ với em: prefix
/em:new-feature Triển khai user authentication
/em:bug-fix Fix login timeout bug
```

---

## Communication Styles

EM-Team v3.0.0 có hệ thống điều khiển giao tiếp thống nhất với 2 trục độc lập:

- **Personality** (giọng điệu) — 13 styles chọn bằng `/em:skill:style-switcher`
- **Density** (độ chi tiết) — 3 modes chọn bằng `/compact`, `/terse`, `/standard`

### 13 Personality Styles

**Năng suất:**
| Style | Mô tả | Tiết kiệm Token |
|---|---|---|
| 🪖 Tactical | Trực tiếp, không dài dòng. `[vấn đề] → [nguyên nhân] → [cách fix]` | 65-75% |
| 🪨 Raw | Cụm từ ngắn, bỏ article, pleasantries | 65-75% |
| 🔍 Reality Check | Đánh giá thẳng thắn: được gì → rủi ro thật → kết luận | 60-70% |
| 📋 git log | Động từ mệnh lệnh, tối đa 72 ký tự/dòng | 50-65% |
| ❓ Socratic | Hỏi câu hỏi, không bao giờ cho đáp án trực tiếp | 50-70% |
| 📌 BLUF | Kết luận trước, chi tiết sau | 20-35% |

**Vui vẻ:**
| Style | Mô tả | Token |
|---|---|---|
| 🧙 Inverted | Nói kiểu Yoda, cú pháp đảo ngược | ~same |
| 🏴‍☠️ Dramatic | Nói kiểu cướp biển, ẩn dụ hàng hải | +5-15% |
| 💾 80s Hacker | Terminal thập niên 80, IN HOA, STATUS: labels | +5-15% |
| 👨 Dad Joke | Giải thích kỹ thuật + dad joke tệ | +10-20% |

**Hiểu sâu:**
| Style | Mô tả | Token |
|---|---|---|
| 🦆 Rubber Duck | Không thuật ngữ, một concept một lúc | 0-+20% |
| 🔬 Teacher | Kỹ thuật Feynman, giải thích cho người 12 tuổi | +20-40% |
| 🧱 First Principles | Phân tách tận gốc, không giả định | +20-30% |

### 3 Density Modes

| Mode | Command | Output |
|---|---|---|
| **STANDARD** | `/standard` | Báo cáo đầy đủ, có coaching, code before/after |
| **COMPACT** | `/compact` | Bullet points, code fix, không coaching |
| **TERSE** | `/terse` | 1 dòng status, diff only |

### Cách sử dụng

```bash
# Hiển thị menu personality (13 styles + 3 density modes)
/em:skill:style-switcher

# Chọn personality trực tiếp
/em:skill:style-switcher tactical        # Debug trực tiếp, không giải thích
/em:skill:style-switcher teacher         # Giải thích kiểu Feynman
/em:skill:style-switcher reality-check   # Đánh giá thẳng thắn idea của bạn
/em:skill:style-switcher raw             # Code nhanh, fragments
/em:skill:style-switcher bluf            # Kết luận trước, chi tiết sau

# Chuyển density độc lập (không ảnh hưởng personality)
/compact               # Bullet points
/terse                 # 1 dòng status
/standard              # Đầy đủ

# Kết hợp personality + density (mỗi cái set độc lập)
/em:skill:style-switcher raw             # Personality → Raw
/compact               # Density → COMPACT
# → Raw tone + bullet-point format

# Terminal CLI modifier (bỏ markdown, tiết kiệm thêm 20-30% token)
/em:skill:style-switcher tactical + terminal CLI
```

### Khi nào dùng style nào

| Tình huống | Personality | Density |
|---|---|---|
| Debug CI failure | Tactical | TERSE |
| Dạy junior developer | Teacher | STANDARD |
| Code nhanh, back-and-forth | Raw | COMPACT |
| Đánh giá feature idea | Reality Check | STANDARD |
| Quyết định kiến trúc | First Principles | COMPACT |
| Review code nhanh | BLUF | COMPACT |
| Demo cho team | Dramatic | STANDARD |
| Học concept mới hoàn toàn | Rubber Duck | STANDARD |

### Quy tắc quan trọng

- **CRITICAL findings luôn hiển thị đầy đủ** bất kể personality hay density
- **File paths không bao giờ bị bỏ** trong bất kỳ mode nào
- Personality và density **độc lập** — đổi cái này không ảnh hưởng cái kia
- Auto-detect: `CI=true` → TERSE, gõ 3+ lệnh nhanh → COMPACT

---

## Cấu trúc Command mới

### v2.2.0 Command Structure

EM-Team v3.0.0 sử dụng cấu trúc command thống nhất:

```bash
# Skills (43 commands) - Prefix em:skill:
/em:skill:skill-name [task description]

# Agents (31 commands) - Prefix em:
/em:agent-name [task description]

# Workflows (23 commands) - Prefix em:
/em:workflow-name [task description]

# Communication Styles
/em:skill:style-switcher [style-name]   # 13 personality styles
/compact | /terse | /standard  # 3 density modes
```

### Tất cả Commands Available

#### 📚 Skills (43 commands) - Prefix em:skill:

```
/em:skill:brainstorming          - Explore ideas into designs
/em:skill:spec-driven-development        - Create specifications
/em:skill:systematic-debugging   - Debug with scientific method
/em:skill:context-engineering    - Optimize agent context
/em:skill:writing-plans          - Write implementation plans
/em:skill:alignment-session      - Pre-coding human-AI alignment (MỚI)
/em:skill:test-driven-development        - TDD RED-GREEN-REFACTOR
/em:skill:frontend-patterns      - React/Next.js/Vue patterns
/em:skill:backend-patterns       - API/Database/NestJS patterns
/em:skill:typescript-patterns     - TypeScript types, async, React TS (MỚI)
/em:skill:python-patterns        - Python 3.10+, FastAPI, SQLAlchemy (MỚI)
/em:skill:go-patterns            - Go errors, concurrency, testing (MỚI)
/em:skill:rust-patterns          - Rust ownership, traits, tokio (MỚI)
/em:skill:architecture-zoom-out    - Higher-level code perspective (MỚI)
/em:skill:architecture-improvement - Systematic module deepening (MỚI)
/em:skill:issue-generator          - Plans to structured vertical-slice issues (MỚI)
/em:skill:prd-generator            - Ideas to structured PRD documents (MỚI)
/em:skill:security-hardening     - OWASP Top 10 security
/em:skill:incremental-implementation       - Vertical slice development
/em:skill:subagent-driven-development           - Fresh context per task
/em:skill:source-driven-development      - Code from official docs
/em:skill:api-interface-design   - Contract-first APIs
/em:skill:code-review            - 5-axis code review
/em:skill:code-simplification    - Reduce complexity
/em:skill:browser-testing        - DevTools MCP
/em:skill:performance-optimization - Measure-first optimization
/em:skill:e2e-testing            - Playwright testing
/em:skill:security-audit         - Vulnerability assessment
/em:skill:security-common        - OWASP reference & checklist (MỚI)
/em:skill:ux-audit                 - Behavioral UX audit (MỚI)
/em:skill:plan-tune                - Learn output preferences (MỚI)
/em:skill:api-testing            - Integration testing
/em:skill:git-workflow           - Atomic commits
/em:skill:ci-cd-automation       - Feature flags
/em:skill:documentation          - ADRs & docs
/em:skill:finishing-branch       - Merge/PR decisions
/em:skill:deprecation-migration  - Code-as-liability
/em:skill:style-switcher                - 13 personality + 3 density modes (MỚI)
```

#### 🤖 Agents (31 commands) - Prefix em:

```
/em:planner               - Create implementation plans
/em:executor              - Execute plans with atomic commits
/em:code-reviewer         - 5-axis code review
/em:debugger              - Systematic debugging
/em:test-engineer         - Test strategy & generation
/em:security-auditor      - OWASP security audit
/em:ui-auditor            - Visual QA and design review
/em:verifier              - Post-execution verification
/em:architect             - Architecture & technical design
/em:backend-expert        - Database, API, performance ⭐
/em:frontend-expert       - React/Next.js, UI/UX ⭐
/em:database-expert       - Schema, queries, fintech ⭐
/em:product-manager       - Requirements, GAP analysis
/em:senior-code-reviewer  - 9-axis deep code review
/em:security-reviewer     - OWASP + STRIDE security
/em:staff-engineer        - Root cause analysis
/em:team-lead             - Team coordination
/em:techlead-orchestrator - Distributed investigation ⭐
/em:researcher            - Technical research
/em:codebase-mapper       - Architecture analysis
/em:integration-checker   - Cross-phase validation
/em:performance-auditor   - Benchmarking & optimization ⭐
/em:market-intelligence   - Market analysis, competitive intel
/em:learn                 - Knowledge management
/em:autoplan              - Multi-phase review orchestrator
/em:design-reviewer       - Visual design, 6-pillar UI audit (MỚI) 🎨
/em:devex-reviewer        - Dev experience audit, TTHW (MỚI) 🎨
/em:iron-law-enforcer     - Iron Law compliance gate (MỚI) 🔒
```

#### 🔄 Workflows (23 commands) - Prefix em:

```
/em:new-feature           - Idea → Production
/em:bug-fix               - Investigate and fix bugs
/em:refactoring           - Improve code quality
/em:security-audit        - Security assessment
/em:project-setup         - Initialize projects
/em:documentation         - Generate docs
/em:deployment            - Deploy and monitor
/em:retro                 - Learn and improve
/em:ship-workflow         - Version bump, changelog, PR (MỚI)
/em:canary-monitoring     - Post-deploy health check (MỚI)
/em:six-phase-lifecycle   - DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP (MỚI)
/em:team-review           - Full team review
/em:architecture-review   - Architecture review
/em:design-review         - UI/UX review
/em:code-review-9axis     - Deep 9-axis review
/em:database-review       - Database review
/em:product-review        - Product review
/em:security-review-advanced - Advanced security
/em:incident-response     - Production incidents
/em:distributed-investigation - Parallel investigation ⭐
/em:distributed-development    - Parallel development ⭐
```

---

## Sử dụng Skills

### Skills là gì?

Skills là các pattern và best practices có thể tái sử dụng, được tổng hợp từ 6 kho lưu trữ AI agent hàng đầu. Chúng cung cấp các cách tiếp cận có cấu trúc cho các tasks phát triển phổ biến.

### Cách sử dụng Skills

Kích hoạt skills trực tiếp trong conversation của bạn:

```bash
# Pattern cơ bản
/em:skill:skill-name [mô tả task]

# Ví dụ thực tế
/em:skill:brainstorming Explore authentication options với JWT, OAuth2, và Session-based
/em:skill:spec-driven-development Create spec cho payment gateway integration
/em:skill:systematic-debugging Investigate memory leak trong API service
/em:skill:test-driven-development Implement user registration với TDD
/em:skill:frontend-patterns Tạo reusable button component trong React
/em:skill:backend-patterns Design REST API cho user management
/em:skill:security-hardening Review code cho OWASP vulnerabilities
```

### Use Case Chi tiết: Authentication Feature

#### Bước 1: Brainstorming

```bash
/em:skill:brainstorming Explore user authentication options

# Agent sẽ phân tích:
# - JWT vs Session-based vs OAuth2
# - Ưu/nhược điểm mỗi approach
# - Recommendations cho use case của bạn
# - Architecture patterns phù hợp
```

**Output:**
- Comparison table các approaches
- Recommended architecture
- Security considerations
- Implementation trade-offs

#### Bước 2: Spec-driven Development

```bash
/em:skill:spec-driven-development Create specification cho JWT authentication

# Agent sẽ tạo:
# - Functional requirements
# - API contracts
# - Database schema
# - Security requirements
# - Edge cases cần handle
```

**Output:**
- Complete specification document
- API endpoint definitions
- Database schema design
- Security requirements matrix

#### Bước 3: Test-Driven Development

```bash
/em:skill:test-driven-development Implement authentication với TDD

# Agent sẽ theo cycle:
# 1. RED - Viết failing test
# 2. GREEN - Implement để pass test
# 3. REFACTOR - Improve code
# 4. Lặp lại cho next feature
```

**Output:**
- Comprehensive test suite
- Production code passes all tests
- Clean, refactored code

---

## Sử dụng Agents

### Agents là gì?

Agents là các AI assistants chuyên biệt với expertise trong các domains cụ thể. Mỗi agent có:
- Specialized knowledge
- Specific workflows
- Output templates
- Quality criteria

### Cách sử dụng Agents

```bash
# Pattern cơ bản
/em:agent-name [mô tả task]

# Ví dụ thực tế
/em:planner Create implementation plan cho JWT auth
/em:executor Implement authentication system
/em:code-reviewer Review PR #123 authentication
/em:debugger Investigate login timeout bug
/em:backend-expert Optimize database queries
/em:frontend-expert Review React components
/em:database-expert Design user schema
/em:security-auditor Audit authentication system
```

### Use Case Chi tiết: Code Review

#### Scenario: Pull Request Review

```bash
# Bước 1: Code review cơ bản
/em:code-reviewer Review PR #123

# Agent sẽ kiểm tra:
# - Correctness: Code có đúng không?
# - Performance: Có vấn đề performance không?
# - Security: Có vulnerabilities không?
# - Style: Có follow conventions không?
# - Maintainability: Code có dễ maintain không?

# Bước 2: Deep review 9-axis (cho critical code)
/em:senior-code-reviewer Deep review PR #123

# Agent sẽ kiểm tra 9 dimensions:
# - Correctness
# - Performance
# - Security
# - Style
# - Maintainability
# - Test Coverage
# - Documentation
# - Error Handling
# - Architecture Alignment

# Bước 3: Security review (cho sensitive code)
/em:security-reviewer OWASP + STRIDE security review

# Agent sẽ phân tích:
# - OWASP Top 10 vulnerabilities
# - STRIDE threat model
# - Authentication/Authorization issues
# - Data protection
# - Input validation
```

### Use Case Chi tiết: Performance Optimization

```bash
# Bước 1: Benchmark current state
/em:performance-auditor Benchmark API endpoints

# Agent sẽ:
# - Measure response times
# - Identify slow endpoints
# - Analyze resource usage
# - Find bottlenecks

# Bước 2: Analyze backend
/em:backend-expert Analyze database queries và API performance

# Agent sẽ:
# - Review query patterns
# - Identify N+1 queries
# - Check indexing
# - Analyze caching strategy

# Bước 3: Analyze frontend
/em:frontend-expert Review React rendering performance

# Agent sẽ:
# - Check unnecessary re-renders
# - Analyze bundle size
# - Review lazy loading
# - Check memoization

# Bước 4: Implement optimizations
/em:executor Implement performance optimizations

# Agent sẽ:
# - Add database indexes
# - Implement caching
# - Optimize queries
# - Add pagination

# Bước 5: Verify improvements
/em:performance-auditor Re-benchmark sau optimization

# Agent sẽ:
# - Compare before/after metrics
# - Verify improvements
# - Document results
```

---

## Sử dụng Workflows

### Workflows là gì?

Workflows là quy trình end-to-end kết hợp multiple agents và skills để hoàn thành complex tasks. Mỗi workflow có:
- Defined phases
- Entry/exit criteria
- Agent orchestration
- Quality gates

### Cách sử dụng Workflows

```bash
# Pattern cơ bản
/em:workflow-name [mô tả task]

# Ví dụ thực tế
/em:new-feature Implement user authentication from idea to production
/em:bug-fix Fix login timeout bug systematically
/em:refactoring Refactor authentication code for better maintainability
/em:security-audit Audit payment system for vulnerabilities
/em:distributed-investigation Investigate authentication failure across full stack
```

### Use Case Chi tiết: New Feature Workflow

#### Workflow: New Feature

```bash
/em:new-feature Implement user authentication

# Workflow sẽ đi qua 7 phases:

# PHASE 1: DEFINE
# ==============================
# Agent: em:product-manager
# Output: Feature specification với:
#   - Business requirements
#   - User stories
#   - Acceptance criteria
#   - Success metrics

# PHASE 2: PLAN
# ==============================
# Agent: em:planner
# Output: Implementation plan với:
#   - Technical approach
#   - Database schema
#   - API endpoints
#   - Frontend components
#   - Testing strategy
#   - Security considerations

# PHASE 3: BUILD
# ==============================
# Agent: em:executor
# Output: Working implementation với:
#   - Database migrations
#   - Backend API
#   - Frontend UI
#   - Tests (TDD)
#   - Documentation

# PHASE 4: VERIFY
# ==============================
# Agent: em:test-engineer
# Output: Test results với:
#   - Unit tests (80%+ coverage)
#   - Integration tests
#   - E2E tests
#   - Security tests

# PHASE 5: REVIEW
# ==============================
# Agents: em-code-reviewer, em-security-auditor
# Output: Review reports với:
#   - Code quality assessment
#   - Security audit results
#   - Performance analysis
#   - Recommendations

# PHASE 6: SIMPLIFY
# ==============================
# Agent: em:code-reviewer
# Output: Refactored code với:
#   - Reduced complexity
#   - Better abstractions
#   - Cleaner design
#   - Improved maintainability

# PHASE 7: SHIP
# ==============================
# Agent: em:verifier
# Output: Deployment package với:
#   - Final verification
#   - Deployment checklist
#   - Rollout plan
#   - Monitoring setup
```

### Use Case Chi tiết: Bug Fix Workflow

#### Workflow: Bug Fix

```bash
/em:bug-fix Fix login timeout bug

# Workflow sẽ đi qua 5 phases:

# PHASE 1: INVESTIGATE
# ==============================
# Agent: em:debugger
# Process:
#   1. Gather information
#   2. Reproduce bug
#   3. Analyze symptoms
#   4. Form hypotheses
# Output: Bug report với:
#   - Symptoms description
#   - Reproduction steps
#   - Hypotheses ranked by likelihood

# PHASE 2: ANALYZE
# ==============================
# Agent: em:staff-engineer
# Process:
#   1. Root cause analysis
#   2. Cross-service impact
#   3. Data flow analysis
# Output: Root cause analysis với:
#   - Root cause identified
#   - Impact assessment
#   - Related issues

# PHASE 3: HYPOTHESIZE
# ==============================
# Agent: em:debugger
# Process:
#   1. Form hypothesis
#   2. Design experiment
#   3. Test hypothesis
#   4. Confirm/deny
# Output: Confirmed hypothesis với:
#   - Root cause explanation
#   - Fix approach

# PHASE 4: IMPLEMENT
# ==============================
# Agent: em:executor
# Process:
#   1. Write failing test (TDD)
#   2. Implement fix
#   3. Verify fix
#   4. Add regression tests
# Output: Fixed code với:
#   - Tests for bug
#   - Regression tests
#   - Documentation

# PHASE 5: VERIFY
# ==============================
# Agent: em:verifier
# Process:
#   1. Run all tests
#   2. Verify fix
#   3. Check for side effects
#   4. Performance check
# Output: Verification report với:
#   - Fix confirmed
#   - No regressions
#   - Performance OK
```

---

## Chế độ Phân tán

### Chế độ Phân tán là gì?

Chế độ phân tán chạy nhiều specialist agents song song trong tmux sessions cô lập, giải quyết token overflow và cho phép parallel processing.

### Architecture

```
┌─────────────────────────────────────────┐
│     tmux session: claude-work          │
├─────────────────────────────────────────┤
│ ┌─────────────┬─────────────┬─────────┐ │
│ │ Orchestrator│ Backend     │ Frontend│ │
│ │ Window      │ Window      │ Window  │ │
│ ├─────────────┼─────────────┼─────────┤ │
│ │ Tech Lead   │ Backend     │ Frontend│ │
│ │ Agent       │ Expert      │ Expert  │ │
│ └─────────────┴─────────────┴─────────┘ │
│         Shared Reports Directory        │
│     /tmp/claude-work-reports/          │
└─────────────────────────────────────────┘
```

### Use Case Chi tiết: Distributed Investigation

#### Scenario: Authentication Failure Investigation

```bash
# Bước 1: Khởi động distributed mode
./scripts/distributed-orchestrator.sh start

# Điều này tạo:
# - tmux session: claude-work
# - Windows: orchestrator, backend, frontend, database
# - Reports directory: /tmp/claude-work-reports/

# Bước 2: Attach vào orchestrator window
tmux attach -t claude-work:orchestrator

# Bước 3: Kích hoạt investigation
/em:techlead-orchestrator Investigate authentication failure affecting 10% users

# Tech Lead sẽ:
# 1. Analyze problem
# 2. Create investigation plan
# 3. Delegate to specialist agents:
#    - Backend Expert: Check API, database, auth service
#    - Frontend Expert: Check login UI, token handling
#    - Database Expert: Check user sessions, auth tokens
# 4. Set parallel investigation tasks
# 5. Each agent works in isolated window
# 6. Agents save findings to reports directory

# Bước 4: Monitor progress
# Trong orchestrator window:
./distributed/session-coordinator.sh agent-status
./distributed/session-coordinator.sh queue-status

# Bước 5: Xem individual reports
cat /tmp/claude-work-reports/backend/report.md
cat /tmp/claude-work-reports/frontend/report.md
cat /tmp/claude-work-reports/database/report.md

# Bước 6: Consolidate findings
./scripts/consolidate-reports.sh consolidate

# Bước 7: Review consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# Report sẽ có:
# - Summary from all agents
# - Cross-domain findings
# - Root cause analysis
# - Recommendations ranked by priority

# Bước 8: Cleanup
./scripts/distributed-orchestrator.sh stop
```

### Khi nào sử dụng Distributed Mode

✅ **Sử dụng khi:**
- Task yêu cầu cross-domain analysis
- Cần parallel processing để tăng tốc
- Context đang đạt token limit
- Cần comprehensive audit trail
- Complex production incidents

❌ **Không sử dụng khi:**
- Task đơn giản, single-domain
- Cần quick investigation
- Không cần parallel processing
- Team nhỏ, simple project

---

## Use Cases Chi tiết

### Use Case 1: E-commerce Payment Integration

#### Goal: Integrate Stripe payment gateway

```bash
# PHASE 1: REQUIREMENTS
/em:product-manager Define payment feature requirements

# Output:
# - User stories
# - Functional requirements
# - Acceptance criteria
# - Success metrics

# PHASE 2: PLANNING
/em:planner Create implementation plan cho Stripe integration

# Output:
# - Architecture decision
# - Database schema (payments, transactions)
# - API design (webhooks, callbacks)
# - Security requirements (PCI DSS)
# - Error handling strategy

# PHASE 3: SECURITY REVIEW
/em:security-auditor Review payment security requirements

# Output:
# - Security assessment
# - OWASP compliance
# - Data encryption requirements
# - PCI DSS checklist

# PHASE 4: IMPLEMENTATION
/em:executor Implement Stripe payment integration

# Process:
# 1. Database migrations (TDD)
# 2. Backend API (TDD)
# 3. Stripe SDK integration (TDD)
# 4. Webhook handling (TDD)
# 5. Frontend payment form (TDD)

# Output:
# - Working payment system
# - Comprehensive tests
# - API documentation

# PHASE 5: TESTING
/em:test-engineer Create test strategy cho payment system

# Output:
# - Unit tests (90%+ coverage)
# - Integration tests (Stripe sandbox)
# - E2E tests (payment flow)
# - Security tests (OWASP ZAP)

# PHASE 6: REVIEW
/em:code-reviewer Review payment code
/em:security-reviewer Security review payment system

# Output:
# - Code quality assessment
# - Security audit results
# - Recommendations

# PHASE 7: DEPLOYMENT
/em:deployment Deploy payment feature to staging

# Output:
# - Staging deployment
# - Smoke tests
# - Monitoring setup
# - Rollback plan
```

### Use Case 2: Legacy Code Refactoring

#### Goal: Refactor monolithic user service

```bash
# PHASE 1: ANALYSIS
/em:codebase-mapper Analyze user service architecture

# Output:
# - Current architecture analysis
# - Dependency mapping
# - Code patterns
# - Refactoring opportunities

# PHASE 2: QUALITY ASSESSMENT
/em:senior-code-reviewer Deep review user service code

# Output:
# - 9-axis code review
# - Complexity analysis
# - Code smells
# - Technical debt

# PHASE 3: PLANNING
/em:planner Create refactoring plan

# Output:
# - Refactoring strategy
# - Incremental steps
# - Risk mitigation
# - Testing approach

# PHASE 4: REFACTORING (incremental)
/em:refactoring Refactor user authentication module
/em:refactoring Refactor user profile module
/em:refactoring Refactor user permissions module

# Each refactoring:
# 1. Write tests (TDD)
# 2. Refactor code
# 3. Verify tests pass
# 4. Run integration tests
# 5. Document changes

# PHASE 5: VERIFICATION
/em:test-engineer Verify refactoring with regression tests

# Output:
# - Regression test suite
# - Test results
# - Performance comparison

# PHASE 6: DEPLOYMENT
/em:deployment Deploy refactored service

# Output:
# - Gradual rollout
# - Monitoring
# - Rollback plan
```

### Use Case 3: Microservices Architecture Migration

#### Goal: Migrate monolith to microservices

```bash
# PHASE 1: ARCHITECTURE ASSESSMENT
/em:architect Review current architecture
/em:codebase-mapper Map dependencies and boundaries

# Output:
# - Current architecture analysis
# - Service boundaries proposal
# - Migration roadmap

# PHASE 2: DESIGN
/em:architect Design microservices architecture
/em:database-expert Design data distribution strategy
/em:backend-expert Design inter-service communication

# Output:
# - Architecture decision record (ADR)
# - Service decomposition plan
# - Data migration strategy
# - API contracts

# PHASE 3: PROOF OF CONCEPT
/em:new-feature Implement first microservice (user service)

# Output:
# - Working microservice
# - Lessons learned
# - Patterns established

# PHASE 4: MIGRATION (incremental)
/em:distributed-development Migrate features to microservices in parallel

# Parallel teams:
# - Team 1: User service
# - Team 2: Payment service
# - Team 3: Notification service
# - Team 4: Order service

# Each team uses:
/em:new-feature Implement [service] features

# PHASE 5: INTEGRATION
/em:integration-checker Verify cross-service integration

# Output:
# - Integration test results
# - API contract validation
# - Data flow verification

# PHASE 6: DEPLOYMENT
/em:deployment Deploy microservices to production

# Output:
# - Deployment strategy
# - Service mesh setup
# - Monitoring and observability
```

---

## Best Practices

### 1. Chọn Công cụ Phù hợp

```bash
# Task đơn giản, single concern → Skill
/em:skill:brainstorming Explore feature ideas
/em:skill:test-driven-development Implement simple function

# Task chuyên môn, single domain → Agent
/em:backend-expert Optimize database queries
/em:frontend-expert Review React components
/em:security-auditor Audit authentication

# Quy trình phức tạp, multi-phase → Workflow
/em:new-feature Take feature from idea to production
/em:bug-fix Fix bug systematically
/em:refactoring Improve code quality

# Task multi-domain, cần parallel → Distributed Mode
./scripts/distributed-orchestrator.sh start
/em:techlead-orchestrator Investigate across full stack
```

### 2. Viết Prompts Hiệu quả

```bash
# ❌ Quá mơ hồ
/em:planner Lập kế hoạch

# ❌ Quá cụ thể, micromanaging
/em:planner Tạo kế hoạch với 5 tasks, task 1 làm A, task 2 làm B, ...

# ✅ Cân bằng - Clear goal với sufficient context
/em:planner Tạo kế hoạch triển khai cho user authentication với JWT.
Nên bao gồm: database schema, API endpoints, frontend components,
testing strategy, và security considerations.
```

### 3. Cung cấp Context Phù hợp

```bash
# ❌ Không có context
/em:debugger Fix bug

# ✅ Với context
/em:debugger Investigate login timeout bug.
Started 2 hours ago after deployment.
Error: "Connection timeout after 30s".
Affects 10% of login attempts.
Backend logs show database query timeouts.
Database: PostgreSQL 13, connection pool: 20 max.

# ✅✅ Với context + artifacts
/em:debugger Investigate login timeout.
Bug report: JIRA-123
Logs: /var/log/auth-service.log
Metrics: https://grafana.example.com/d/auth
Reproduction steps: [steps]
```

### 4. Tuân thủ Iron Laws

```bash
# TDD Iron Law
/em:skill:test-driven-development Implement feature
# Agent sẽ:
# 1. RED - Viết failing test
# 2. GREEN - Implement để pass
# 3. REFACTOR - Improve code
# NEVER write production code WITHOUT failing test

# Debugging Iron Law
/em:debugger Investigate bug
# Agent sẽ:
# 1. Gather information
# 2. Form hypotheses
# 3. Test hypotheses
# 4. Find ROOT CAUSE
# NEVER fix WITHOUT root cause

# Spec Iron Law
/em:skill:spec-driven-development Create spec
# Agent sẽ:
# 1. Write specification FIRST
# 2. Get approval
# 3. THEN implement
# NEVER code WITHOUT spec (for features)
```

### 5. Làm việc Iteratively

```bash
# ❌ Big bang approach
/em:new-feature Implement entire e-commerce system

# ✅ Iterative approach
/em:new-feature Implement user registration
# Review, test, deploy

/em:new-feature Implement user profile
# Review, test, deploy

/em:new-feature Implement user authentication
# Review, test, deploy

# ✅✅ Incremental with feedback
/em:new-feature Implement MVP authentication
/em:code-reviewer Review authentication
# Incorporate feedback

/em:new-feature Add OAuth2 support
/em:security-auditor Audit OAuth2 implementation
# Incorporate feedback
```

---

## Xử lý sự cố

### Problem 1: Commands Không Hoạt Động

**Symptoms:**
- Command không được nhận diện
- Error: "command not found"

**Solutions:**

```bash
# 1. Kiểm tra EM-Team đã install chưa
which em-show
# Nếu không có, cài đặt lại

# 2. Kiểm tra file permissions
chmod +x /Users/abc/Desktop/EM-Skill/commands/*.sh
chmod +x /Users/abc/Desktop/EM-Skill/scripts/*.sh

# 3. Kiểm tra PATH
echo $PATH | grep EM-Skill
# Nếu không có, add to PATH:
export PATH="/Users/abc/Desktop/EM-Skill/commands:$PATH"

# 4. Verify command files exist
ls -la /Users/abc/Desktop/EM-Skill/commands/
```

### Problem 2: Distributed Mode Không Khởi Động

**Symptoms:**
- tmux session không tạo được
- Error: "tmux not found"

**Solutions:**

```bash
# 1. Kiểm tra tmux đã install
tmux -V
# Nếu chưa: brew install tmux (macOS)

# 2. Kill existing sessions
tmux kill-server

# 3. Verify script permissions
chmod +x /Users/abc/Desktop/EM-Skill/scripts/distributed-orchestrator.sh
chmod +x /Users/abc/Desktop/EM-Skill/distributed/*.sh

# 4. Try again
./scripts/distributed-orchestrator.sh start

# 5. Check logs
ls -la /tmp/claude-work-logs/
```

### Problem 3: Agent Không Phản Hồi

**Symptoms:**
- Agent không trả về output
- Session hang

**Solutions:**

```bash
# 1. Kiểm tra agent window status
tmux list-windows -t claude-work
tmux list-panes -t claude-work:backend

# 2. Attach vào specific window
tmux attach -t claude-work:backend

# 3. Kiểm tra errors
cat /tmp/claude-work-logs/backend-error.log

# 4. Kiểm tra agent status
./distributed/session-coordinator.sh agent-status

# 5. Restart agent nếu cần
tmux kill-pane -t claude-work:backend.0
# Agent sẽ tự restart
```

### Problem 4: Reports Không Được Tạo

**Symptoms:**
- Consolidated report trống
- Individual reports missing

**Solutions:**

```bash
# 1. Kiểm tra reports directory
ls -la /tmp/claude-work-reports/*/

# 2. Kiểm tra agent reports
cat /tmp/claude-work-reports/backend/report.md
cat /tmp/claude-work-reports/frontend/report.md

# 3. Manual consolidation
./scripts/consolidate-reports.sh consolidate

# 4. Kiểm tra consolidation script
./scripts/consolidate-reports.sh list

# 5. Verify output
cat /tmp/claude-work-reports/techlead/consolidated-report.md
```

### Problem 5: Tests Fail Trong CI/CD

**Symptoms:**
- Tests pass locally nhưng fail trong CI
- Flaky tests

**Solutions:**

```bash
# 1. Run tests locally with CI environment
cd tests
./run-e2e-tests.sh --ci-mode

# 2. Check test isolation
./test-tdd-retry-wrapper.sh --isolation

# 3. Check for flaky tests
./run-e2e-tests.sh --detect-flaky

# 4. Use TDD auto-retry for flaky tests
# Tests sẽ tự retry với exponential backoff

# 5. Review test logs
cat /tmp/em:team-test-logs/latest.log
```

---

## Tài nguyên

### 📚 Tài liệu Kiến trúc

- [Architecture Overview](../architecture/overview.md) - Tổng quan kiến trúc EM-Team
- [Distributed System](../architecture/distributed-system.md) - Kiến trúc chế độ phân tán
- [Knowledge Persistence](../KNOWLEDGE-PERSISTENCE.md) - Hệ thống tri thức

### 📋 Reference Protocol

- [Messaging Protocol](../protocols/messaging.md) - Giao tiếp giữa agents
- [Report Format](../protocols/report-format.md) - Định dạng báo cáo agent
- [Agent Handoff](../protocols/handoff.md) - Chuyển giao giữa agents

### 🔄 Catalog Workflow

- [Workflows Overview](../workflows/overview.md) - Tổng quan workflows
- [New Feature Workflow](../workflows/new-feature.md) - Workflow triển khai feature
- [Bug Fix Workflow](../workflows/bug-fix.md) - Workflow fix bug
- [Distributed Investigation](../workflows/distributed-investigation.md) - Workflow điều tra phân tán

### 📖 Reference Skill

- [Skills Overview](../skills/overview.md) - Tổng quan skills
- [Foundation Skills](../skills/foundation/) - Skills nền tảng
- [Development Skills](../skills/development/) - Skills phát triển
- [Quality Skills](../skills/quality/) - Skills chất lượng

### 🤖 Reference Agent

- [Agents Overview](../agents/overview.md) - Tổng quan agents
- [Core Agents](../agents/core/) - Core agents (8 agents)
- [Specialized Agents](../agents/specialized/) - Specialized agents (14 agents)

### 🧪 Test Suite

- [Test Documentation](../tests/README.md) - Tổng quan test suite
- [E2E Tests](../tests/e2e/) - Tests end-to-end
- [Unit Tests](../tests/unit/) - Tests đơn vị
- [Integration Tests](../tests/integration/) - Tests tích hợp

### 📕 Feature Documentation

- [TDD Auto-Retry](../TDD-AUTO-RETRY.md) - Tự động retry TDD
- [Token Summarization](../TOKEN-SUMMARIZATION.md) - Quản lý token
- [Knowledge Persistence](../KNOWLEDGE-PERSISTENCE.md) - Hệ thống tri thức

### 🌐 Community

- [GitHub Issues](https://github.com/nv-minh/EM-Team/issues) - Báo cáo issues
- [GitHub Discussions](https://github.com/nv-minh/EM-Team/discussions) - Thảo luận
- [Contributing Guide](CONTRIBUTING.md) - Đóng góp dự án

---

**Phiên bản:** 2.2.0
**Cập nhật lần cuối:** 2026-05-01
**Tình trạng:** ✅ Production Ready

**Cần trợ giúp?**
- Kiểm tra [Xử lý sự cố](#xử-lý-sự-cố)
- Đọc [Best Practices](#best-practices)
- Xem [Use Cases](#use-cases-chi-tiết)
- Report bugs tại [GitHub Issues](https://github.com/nv-minh/EM-Team/issues)

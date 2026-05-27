# Hướng Dẫn Sử Dụng EM-Team v5.5.0

Hướng dẫn hoàn chỉnh cho hệ thống kỹ thuật fullstack EM-Team.

---

## Mục Lục

1. [Tổng quan](#tổng-quan)
2. [Tính năng mới](#tính-năng-mới)
3. [Communication Styles](#communication-styles)
4. [Cấu trúc Command](#cấu-trúc-command)
5. [Sử dụng Skills](#sử-dụng-skills)
6. [Sử dụng Agents](#sử-dụng-agents)
7. [Sử dụng Workflows](#sử-dụng-workflows)
8. [Dự án Outsource Nhật Bản](#dự-án-outsource-nhật-bản)
9. [Chế độ Phân tán](#chế-độ-phân-tán)
10. [Best Practices](#best-practices)
11. [Xử lý sự cố](#xử-lý-sự-cố)

---

## Tổng quan

EM-Team v5.5.0 cung cấp 140+ commands được tổ chức thành 3 danh mục chính:

| Phương pháp | Số lượng | Mô tả | Tốt nhất cho |
|-------------|----------|-------|--------------|
| **Skills** | 86 | Patterns và practices có thể tái sử dụng | Tasks phát triển cụ thể |
| **Agents** | 36 | AI assistants chuyên biệt | Công việc chuyên môn phức tạp |
| **Workflows** | 27 | Quy trình end-to-end | Vòng đời dự án hoàn chỉnh |

---

## Tính năng mới

### v5.4.0 — Brownfield Intelligence Improvements (19 gaps closed)

**Agents giờ hiểu codebase ở cấp độ business domain** trước khi điều tra bug, verify feature, hoặc viết tests.

**1 skill mới:**
- `brownfield-pr-impact` (Workflow) — Đánh giá impact của PR/branch lên brownfield business flows, surface AC-at-risk và contract breaks trước khi merge

**8 scripts mới** (`scripts/brownfield/`):
- `detect-stack.sh` — Auto-detect tech stack
- `symbol-resolver.sh` — Resolve `Class.method` → `file:line` tại runtime (stable, không fragile)
- `validate-refs.sh` — Kiểm tra tất cả cross-module refs; exit 0 = clean
- `quality-score.sh` — Chấm điểm Grade A/B/C/D cho từng module
- + 4 scan scripts (nestjs, react, monorepo)

**JSON sidecars** — `FLOWS.json`, `CODE-MAP.json`, `INDEX.json` cho programmatic access

**Stable IDs** — `FLOW-{MODULE}-{NNN}` + `AC-{MODULE}-{NNN}` stable across refactors

**Integration upgrades:**
- `debugger` — Phase 0: load brownfield context trước khi điều tra
- `verifier` — Phase 0: load context; Phase 3: check AC regression
- `new-feature` — Stage 0.5 (load) + Stage 5.7 (update context sau build)
- `bug-fix` — Stage 0.5: auto-route sang brownfield-investigation nếu `.em-brownfield/` tồn tại

```bash
# Đánh giá impact của PR lên brownfield flows
Use the brownfield-pr-impact skill to check this PR

# Validate context artifacts
bash scripts/brownfield/validate-refs.sh .em-brownfield/
bash scripts/brownfield/quality-score.sh .em-brownfield/
```

### v5.3.0 — Architect/Code/Review Quality Upgrade

**Code review chạy TRƯỚC test suite** trong mọi VERIFY stage — đảm bảo bug phát hiện qua review được fix và kiểm tra lại bởi tests trước khi ship.

**Thứ tự đúng:** `BUILD → code-review diff scan → tests → SHIP`

| Component | Thay đổi |
|-----------|---------|
| `new-feature` v3.3.0 · `bug-fix` v3.2.0 | Code-review diff scan → **Step 5.1 (ĐẦU TIÊN)** trong VERIFY |
| 4 workflows khác | `six-phase-lifecycle`, `greenfield-app`, `refactoring`, `distributed-development` — áp dụng cùng thứ tự |
| Rollback readiness gate | Thêm Stage 6.1 trước khi đánh dấu feature/fix đã ship |
| `spec-driven-development` v3.1.0 | Testability check → ⛔ hard gate; Phase 1.5 Conflict Detection; Assumption Approval Gate |
| `architect` v2.1.0 | Phase 0 (snapshot kiến trúc hiện tại); Phase 7 (ADR bắt buộc với Decision/Context/Alternatives/Compliance Criteria) |
| `code-review` v3.1.0 · `code-reviewer` v2.1.0 | Step 1.5 diff classification; Step 4.5 cross-file impact scan |

```bash
# VERIFY stage giờ chạy theo thứ tự:
# 1. code-review diff scan (TRƯỚC TIÊN)
# 2. verify spec coverage
# 3. generate TC registry
# 4. run E2E tests + collect evidence
# 5. test-verifier double-check
```

### v4.1.0 — QA Bug Hunter + Error Handling Protocol

**QA Bug Hunter workflow** với human-gated GitHub issue creation:
- 7 stages: SETUP → DISCOVER → EVIDENCE → PREPARE → **HUMAN GATE** → LOG → SUMMARY
- Per-bug loop: bạn review từng bug trước khi tạo issue (APPROVE/REJECT/MODIFY)
- Skills: em-skill:flow-discovery, em-skill:browser-testing, em-skill:github-issue-manager

**github-issue-fix skill** — Browse GitHub issues, chọn 1 issue, chuyển sang em-wf:bug-fix workflow

**Protocols mới:**
- `protocols/error-handling.md` — Error taxonomy chuẩn hóa (`CONTEXT_OVERFLOW`, `BUILD_DEADLOCK`, `SPEC_CONFLICT`, etc.)
- `protocols/naming-convention.md` — Quy tắc đặt tên entry points cho `.claude/skills/`

**Shared components:**
- `agents/_shared/expert-preamble.md` — Shared schemas cho 7 expert agents
- `workflows/_shared/stage-0-git-bootstrap.md` — Reusable Stage 0 git bootstrap

**Quality benchmark:** `bash scripts/benchmark-quality.sh` — scoring B1-B5, grades A+ to D

```bash
/em-wf:qa-bug-hunter QA test http://localhost:5173 and log bugs
/em-skill:github-issue-fix                     # Fix bug từ GitHub issue
bash scripts/benchmark-quality.sh        # Quality scoring
```

### v5.2.0 — TC-Code Coverage Gate

**TC-Registry → Test-Code enforcement chain** đã được đóng hoàn toàn: mỗi TC-ID trong TC-REGISTRY.md **bắt buộc** phải có `test("TC-XXX-NNN: ...")` block (hoặc `test.todo()`) trong test file tương ứng.

- **test-generation v4.1.0** — Step 4.6 mới: bash gate đếm TC-IDs vs test() blocks
- **test-verifier v2.2.0** — Step 2.5 pre-retry TC coverage check; trả về BLOCKED nếu thiếu test() blocks
- **six-phase-lifecycle Gate 4** — Checklist item mới: TC-code coverage = 100% per layer
- **TC-REGISTRY.template.md** — Quality gate checkbox mới cho TC→test() mapping

### v5.1.0 — Expert-QC Testing Skills

**test-case-design** skill mới (Quality #57) — kỹ thuật thiết kế test case chuyên nghiệp:
- BVA (Boundary Value Analysis), EP (Equivalence Partitioning), Decision Tables, State Transition, Pairwise, Risk-Based Testing
- Abuse cases (OWASP-mapped), Non-functional cases, Oracle specification, Mutation sanity gate
- **MANDATORY upstream** của test-generation/api-testing/e2e-testing/browser-testing
- 12-column TC-REGISTRY format với risk-calibrated ratio floors (P0: ≥35% neg + ≥15% abuse + ≥10% non-func)

### v5.0.0 — Brownfield Intelligence

**Brownfield Intelligence** — onboard, sync, and investigate existing codebases:

**2 skills mới:**
- `brownfield-onboarding` (Foundation) — Rapid codebase onboarding: detect stack, map architecture, identify conventions, generate context artifacts
- `brownfield-context-sync` (Workflow) — Sync codebase context after changes: detect drift, update architecture maps, refresh conventions

**1 workflow mới:**
- `brownfield-investigation` — Deep investigation of existing codebase issues: architecture analysis, dependency mapping, tech debt assessment, improvement roadmap

**Enhanced skill:**
- `flow-discovery` — Enhanced with brownfield-aware flow detection for legacy codebases

```bash
# Onboard an existing codebase
/em-skill:brownfield-onboarding Analyze this legacy Node.js monolith

# Sync context after major changes
/em-skill:brownfield-context-sync Refresh architecture map after migration

# Investigate brownfield codebase issues
/em-wf:brownfield-investigation Assess tech debt and improvement plan for payment service
```

### v4.0.0 — Hermes Protocol Refactor

Toàn bộ codebase restructured theo Hermes philosophy:
- **38 agents** → Structured blocks: `[ROLE]`, `[OBJECTIVE]`, `[RULES]`, `[PROCESS]`, `[HANDOFF]`
- **90 skills** → JSON Schema: `input_schema`, `output_schema`, `error_schema`
- **27 workflows** → ReAct protocol: Thought→Action→Observation loops
- **LLM provider-agnostic** → Anthropic, OpenAI, Ollama, vLLM, custom endpoints

### v3.8.0–v3.10.0 — Test Automation + Feature Workspace

**3 agents mới (Test Automation Chain):**
- `playwright-setup` — Auto-detect stack, install browsers, generate config
- `brownfield-test-engineer` — Spec-to-test, clarifying questions, TC registry
- `test-verifier` — Retry loop (max 3), targeted fix suggestions

**Feature Workspace** — tracking artifacts across multiple prompts:
```
.em-artifacts/new-feature/user-dashboard/
├── SPEC.md, TC-REGISTRY.md     # Living docs (updated in place)
├── test-executions/             # Timestamped logs
└── ITERATION-LOG.md             # Auto-tracked changes
```

### v3.7.0 — GitHub Management Suite

Bộ công cụ tự động hóa hoàn toàn vòng đời GitHub — từ CI/CD đến release.

**4 skills mới + 12 commands:**

| Skill | Commands | Chức năng |
|-------|----------|-----------|
| `github-cicd-setup` | `/setup-cicd` | Phát hiện stack (Node/Python/Go/Rust/Java) → tạo `.github/workflows/ci.yml` với lint, typecheck, test, build, caching |
| `github-pr-manager` | `/pr-create`, `/pr-fix`, `/pr-merge`, `/pr-review` | Tự động điền PR description từ commits + template, AI fix review comments + reply, safe merge, tự assign reviewers |
| `github-issue-manager` | `/issue-create`, `/issue-triage`, `/issue-sprint` | Tạo issue có cấu trúc (bug/feature/task), triage backlog với labels + priority, sprint planning với GitHub Milestones |
| `github-release-manager` | `/release` | Bump version, tạo release notes từ CHANGELOG, git tag, GitHub Release với artifacts |

**Commands bổ sung:**
- `/branch-create [issue#]` — Đặt tên branch thông minh `feat/123-issue-title` từ issue number
- `/dep-review` — Kiểm tra security + license cho dependencies mới trong PR
- `/stale-issues` — Tự động label + đóng stale issues (ngưỡng 30d / 60d)

```bash
# Setup CI/CD cho project mới
/em-skill:github-cicd-setup

# Tạo PR với description được AI điền tự động
/em-skill:github-pr-manager  # (phần PR Creation)

# Fix tất cả review comments cùng lúc
/em-skill:github-pr-manager  # (phần Review Fix)

# Lên kế hoạch sprint từ open issues
/em-skill:github-issue-manager  # (phần Sprint Planning)

# Phát hành phiên bản mới
/em-skill:github-release-manager
```

---

### v3.6.0 — Codebase Architecture Intelligence

Skill `codebase-architecture` giải quyết bài toán: **chọn kiến trúc nào cho dự án greenfield?**

**Quy trình 4 bước:**
1. Phân tích ngữ cảnh dự án (domain complexity, team size, scale requirements)
2. Nghiên cứu 6 kiến trúc hiện đại với trade-off thực tế
3. Đề xuất 2-3 lựa chọn phù hợp nhất với file structure cụ thể → **User quyết định**
4. Sinh 3 file rule sau khi user chọn:
   - `architecture-boundaries.md` — Quy tắc import giữa các layer (✅/❌)
   - `architecture-conventions.md` — Naming conventions theo kiến trúc
   - `architecture-patterns.md` — Code patterns + anti-patterns có ví dụ

**6 kiến trúc được nghiên cứu:**
- Layered (N-Tier) — `controllers/ → services/ → repositories/`
- Clean / Hexagonal — `domain/ → application/ → infrastructure/`
- Modular Monolith — `modules/[module]/api/` + `internal/`
- Feature-Sliced Design (FSD) — `app/ → pages/ → widgets/ → features/ → entities/`
- Vertical Slice — `features/[feature]/[Feature]CommandHandler.ts`
- CQRS + Event Sourcing — `commands/ + queries/ + events/ + read-models/`

```bash
# Dùng trực tiếp
/em-skill:codebase-architecture

# Tự động trong Greenfield workflow (Stage 6)
/em-wf:greenfield-app Xây dựng nền tảng thanh toán fintech
```

### v3.5.0 — Hỗ trợ Outsource Nhật Bản

Bộ tài liệu chính thức đầy đủ cho dự án outsource Nhật Bản:

| Skill | Tên Nhật | Sản phẩm |
|-------|----------|----------|
| `basic-design` | 基本設計 | BASIC-DESIGN.md — 8 phần + sign-off gate |
| `detailed-design` | 詳細設計 | DETAILED-DESIGN.md — per-module + sign-off gate |
| `uat-process` | 受け入れテスト | UAT plan + execution log + client sign-off |
| `progress-reporting` | 進捗報告 | Weekly status GREEN/YELLOW/RED + metrics |

```bash
/em-wf:japanese-outsourcing        # Workflow tổng thể 9 giai đoạn
/em-skill:basic-design          # Tạo 基本設計
/em-skill:uat-process           # Chạy UAT với sign-off
/em-skill:progress-reporting    # Báo cáo tiến độ tuần
```

### 🎯 Quick Start

```bash
# Xem tất cả commands
em-show           # Hoặc em-commands

# Xem help
em-help

# Skills - Prefix em-skill:
/em-skill:brainstorming User authentication với JWT
/em-skill:spec-driven-development Tạo spec cho payment system

# Agents - Gõ với em: prefix
/em-agent:planner Tạo kế hoạch cho JWT auth
/em-agent:code-reviewer Review PR #123

# Workflows - Gõ với em: prefix
/em-wf:new-feature Triển khai user authentication
/em-wf:bug-fix Fix login timeout bug
```

---

## Communication Styles

EM-Team v3.0.0 có hệ thống điều khiển giao tiếp thống nhất với 2 trục độc lập:

- **Personality** (giọng điệu) — 13 styles chọn bằng `/em-skill:style-switcher`
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
/em-skill:style-switcher

# Chọn personality trực tiếp
/em-skill:style-switcher tactical        # Debug trực tiếp, không giải thích
/em-skill:style-switcher teacher         # Giải thích kiểu Feynman
/em-skill:style-switcher reality-check   # Đánh giá thẳng thắn idea của bạn
/em-skill:style-switcher raw             # Code nhanh, fragments
/em-skill:style-switcher bluf            # Kết luận trước, chi tiết sau

# Chuyển density độc lập (không ảnh hưởng personality)
/compact               # Bullet points
/terse                 # 1 dòng status
/standard              # Đầy đủ

# Kết hợp personality + density (mỗi cái set độc lập)
/em-skill:style-switcher raw             # Personality → Raw
/compact               # Density → COMPACT
# → Raw tone + bullet-point format

# Terminal CLI modifier (bỏ markdown, tiết kiệm thêm 20-30% token)
/em-skill:style-switcher tactical + terminal CLI
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

## Cấu trúc Command

EM-Team v5.5.0 sử dụng 3 prefixes rõ ràng theo type:

```bash
# Skills (86 commands) - Prefix em-skill:
/em-skill:skill-name [task description]

# Agents (36 commands) - Prefix em-agent:
/em-agent:agent-name [task description]

# Workflows (27 commands) - Prefix em-wf:
/em-wf:workflow-name [task description]

# Communication Styles
/em-skill:style-switcher [style-name]   # 13 personality styles
/compact | /terse | /standard  # 3 density modes
```

### Tất cả Commands Available

#### 📚 Skills (86 commands) - Prefix em-skill:

```
/em-skill:brainstorming          - Explore ideas into designs
/em-skill:spec-driven-development        - Create specifications
/em-skill:systematic-debugging   - Debug with scientific method
/em-skill:context-engineering    - Optimize agent context
/em-skill:writing-plans          - Write implementation plans
/em-skill:alignment-session      - Pre-coding human-AI alignment (MỚI)
/em-skill:brownfield-onboarding  - Rapid codebase onboarding cho existing projects (MỚI v5.0.0)
/em-skill:test-driven-development        - TDD RED-GREEN-REFACTOR
/em-skill:frontend-patterns      - React/Next.js/Vue patterns
/em-skill:backend-patterns       - API/Database/NestJS patterns
/em-skill:typescript-patterns     - TypeScript types, async, React TS (MỚI)
/em-skill:python-patterns        - Python 3.10+, FastAPI, SQLAlchemy (MỚI)
/em-skill:go-patterns            - Go errors, concurrency, testing (MỚI)
/em-skill:rust-patterns          - Rust ownership, traits, tokio (MỚI)
/em-skill:architecture-zoom-out    - Higher-level code perspective (MỚI)
/em-skill:architecture-improvement - Systematic module deepening (MỚI)
/em-skill:issue-generator          - Plans to structured vertical-slice issues (MỚI)
/em-skill:prd-generator            - Ideas to structured PRD documents (MỚI)
/em-skill:security-hardening     - OWASP Top 10 security
/em-skill:incremental-implementation       - Vertical slice development
/em-skill:subagent-driven-development           - Fresh context per task
/em-skill:source-driven-development      - Code from official docs
/em-skill:api-interface-design   - Contract-first APIs
/em-skill:code-review            - 5-axis code review
/em-skill:code-simplification    - Reduce complexity
/em-skill:browser-testing        - DevTools MCP
/em-skill:performance-optimization - Measure-first optimization
/em-skill:e2e-testing            - Playwright testing
/em-skill:security-audit         - Vulnerability assessment
/em-skill:security-common        - OWASP reference & checklist (MỚI)
/em-skill:ux-audit                 - Behavioral UX audit (MỚI)
/em-skill:plan-tune                - Learn output preferences (MỚI)
/em-skill:api-testing            - Integration testing
/em-skill:git-workflow           - Atomic commits
/em-skill:ci-cd-automation       - Feature flags
/em-skill:documentation          - ADRs & docs
/em-skill:finishing-branch       - Merge/PR decisions
/em-skill:deprecation-migration  - Code-as-liability
/em-skill:style-switcher         - 13 personality + 3 density modes

# MỚI v3.7.0 — GitHub Management Suite
/em-skill:github-cicd-setup      - Phát hiện stack → tạo .github/workflows/ci.yml
/em-skill:github-pr-manager      - Tạo PR / fix review comments / merge an toàn
/em-skill:github-issue-manager   - Tạo issue / triage backlog / sprint planning
/em-skill:github-release-manager - Bump version → release notes → tag → GitHub Release

# MỚI v3.6.0
/em-skill:codebase-architecture  - Nghiên cứu 6 kiến trúc → đề xuất 2-3 → sinh rule files

# MỚI v3.5.0 — Outsource Nhật Bản
/em-skill:basic-design           - Tạo 基本設計 (8 phần + sign-off gate)
/em-skill:detailed-design        - Tạo 詳細設計 per-module (class diagrams + sign-off)
/em-skill:uat-process            - Chạy 受け入れテスト với client sign-off
/em-skill:progress-reporting     - Báo cáo 進捗報告 tuần GREEN/YELLOW/RED

# MỚI v4.1.0
/em-skill:github-issue-fix       - Browse GitHub issues → chọn → em-wf:bug-fix

# MỚI v5.0.0 — Brownfield Intelligence
/em-skill:brownfield-context-sync - Sync codebase context sau changes
```

#### 🤖 Agents (36 commands) - Prefix em-agent:

```
/em-agent:planner               - Create implementation plans
/em-agent:executor              - Execute plans with atomic commits
/em-agent:code-reviewer         - 5-axis (standard) hoặc 9-axis (deep) code review
/em-agent:debugger              - Systematic debugging
/em-agent:test-engineer         - Test strategy & generation
/em-agent:security-reviewer     - OWASP + STRIDE security review (Audit mode + Review mode)
/em-agent:ui-auditor            - Visual QA and design review
/em-agent:verifier              - Post-execution verification
/em-agent:architect             - Architecture & technical design
/em-agent:backend-expert        - Database, API, performance ⭐
/em-agent:frontend-expert       - React/Next.js, UI/UX ⭐
/em-agent:database-expert       - Schema, queries, fintech ⭐
/em-agent:product-manager       - Requirements, GAP analysis
/em-agent:staff-engineer        - Root cause analysis
/em-agent:team-lead             - Team coordination
/em-agent:techlead-orchestrator - Distributed investigation ⭐
/em-agent:researcher            - Technical research
/em-agent:codebase-mapper       - Architecture analysis
/em-agent:integration-checker   - Cross-phase validation
/em-agent:performance-auditor   - Benchmarking & optimization ⭐
/em-agent:market-intelligence   - Market analysis, competitive intel
/em-agent:learn                 - Knowledge management
/em-agent:autoplan              - Multi-phase review orchestrator
/em-agent:design-reviewer       - Visual design, 6-pillar UI audit 🎨
/em-agent:devex-reviewer        - Dev experience audit, TTHW 🎨
/em-agent:iron-law-enforcer     - Iron Law compliance gate 🔒
/em-agent:react-expert          - React/Next.js, hooks, state management ⚛️
/em-agent:vue-expert            - Vue 3, Composition API, Pinia 💚
/em-agent:nestjs-expert         - NestJS, TypeScript, GraphQL 🟢
/em-agent:devops-expert         - Docker, K8s, Terraform, CI/CD ☁️
/em-agent:mobile-expert         - Flutter, React Native, Android, iOS 📱
/em-agent:spring-expert         - Spring Boot, JPA, security 🍃
/em-agent:rust-expert           - Rust systems, ownership, async tokio 🦀
/em-agent:playwright-setup      - Auto-detect stack, install Playwright, scaffold POM 🧪
/em-agent:brownfield-test-engineer - Spec-to-test cho existing codebases 🧪
/em-agent:test-verifier         - Double-check test results, retry max 3 🧪
```

#### 🔄 Workflows (27 commands) - Prefix em-wf:

```
/em-wf:new-feature              - Idea → Production
/em-wf:greenfield-app           - Blank dir → shipped app (12 stages)
/em-wf:bug-fix                  - Investigate and fix bugs
/em-wf:qa-bug-hunter            - QA test → find bugs → human gate → GitHub issues
/em-wf:refactoring              - Improve code quality
/em-wf:security-audit           - Security assessment
/em-wf:project-setup            - Initialize projects
/em-wf:documentation            - Generate docs
/em-wf:deployment               - Deploy and monitor
/em-wf:retro                    - Learn and improve
/em-wf:ship-workflow            - Version bump, changelog, PR
/em-wf:canary-monitoring        - Post-deploy health check
/em-wf:six-phase-lifecycle      - DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP
/em-wf:team-review              - Full team review
/em-wf:architecture-review      - Architecture review
/em-wf:design-review            - UI/UX review
/em-wf:code-review              - Deep 9-axis review workflow
/em-wf:database-review          - Database review
/em-wf:product-review           - Product review
/em-wf:security-review-advanced - Advanced security (OWASP + STRIDE)
/em-wf:incident-response        - Production incidents
/em-wf:distributed-investigation - Parallel investigation ⭐
/em-wf:distributed-development  - Parallel development ⭐
/em-wf:discovery-process        - Product discovery and validation
/em-wf:market-driven-feature    - Market-driven feature development
/em-wf:japanese-outsourcing     - 9-stage formal outsourcing workflow
/em-wf:brownfield-investigation - Deep investigation cho existing codebases
```

---

## Sử dụng Skills

### Skills là gì?

Skills là các pattern và best practices có thể tái sử dụng, được tổng hợp từ 6 kho lưu trữ AI agent hàng đầu. Chúng cung cấp các cách tiếp cận có cấu trúc cho các tasks phát triển phổ biến.

### Cách sử dụng Skills

Kích hoạt skills trực tiếp trong conversation của bạn:

```bash
# Pattern cơ bản
/em-skill:skill-name [mô tả task]

# Ví dụ thực tế
/em-skill:brainstorming Explore authentication options với JWT, OAuth2, và Session-based
/em-skill:spec-driven-development Create spec cho payment gateway integration
/em-skill:systematic-debugging Investigate memory leak trong API service
/em-skill:test-driven-development Implement user registration với TDD
/em-skill:frontend-patterns Tạo reusable button component trong React
/em-skill:backend-patterns Design REST API cho user management
/em-skill:security-hardening Review code cho OWASP vulnerabilities
```

### Use Case Chi tiết: Authentication Feature

#### Bước 1: Brainstorming

```bash
/em-skill:brainstorming Explore user authentication options

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
/em-skill:spec-driven-development Create specification cho JWT authentication

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
/em-skill:test-driven-development Implement authentication với TDD

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
/em-agent:{name} [mô tả task]

# Ví dụ thực tế
/em-agent:planner Create implementation plan cho JWT auth
/em-agent:executor Implement authentication system
/em-agent:code-reviewer Review PR #123 authentication
/em-agent:debugger Investigate login timeout bug
/em-agent:backend-expert Optimize database queries
/em-agent:frontend-expert Review React components
/em-agent:database-expert Design user schema
/em-agent:security-reviewer Audit authentication system
```

### Use Case Chi tiết: Code Review

#### Scenario: Pull Request Review

```bash
# Bước 1: Code review cơ bản
/em-agent:code-reviewer Review PR #123

# Agent sẽ kiểm tra:
# - Correctness: Code có đúng không?
# - Performance: Có vấn đề performance không?
# - Security: Có vulnerabilities không?
# - Style: Có follow conventions không?
# - Maintainability: Code có dễ maintain không?

# Bước 2: Deep review 9-axis (cho critical code)
/em-agent:code-reviewer Deep review PR #123

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
/em-agent:security-reviewer OWASP + STRIDE security review

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
/em-agent:performance-auditor Benchmark API endpoints

# Agent sẽ:
# - Measure response times
# - Identify slow endpoints
# - Analyze resource usage
# - Find bottlenecks

# Bước 2: Analyze backend
/em-agent:backend-expert Analyze database queries và API performance

# Agent sẽ:
# - Review query patterns
# - Identify N+1 queries
# - Check indexing
# - Analyze caching strategy

# Bước 3: Analyze frontend
/em-agent:frontend-expert Review React rendering performance

# Agent sẽ:
# - Check unnecessary re-renders
# - Analyze bundle size
# - Review lazy loading
# - Check memoization

# Bước 4: Implement optimizations
/em-agent:executor Implement performance optimizations

# Agent sẽ:
# - Add database indexes
# - Implement caching
# - Optimize queries
# - Add pagination

# Bước 5: Verify improvements
/em-agent:performance-auditor Re-benchmark sau optimization

# Agent sẽ:
# - Compare before/after metrics
# - Verify improvements
# - Document results
```

---

## Dự án Outsource Nhật Bản

### Tổng quan

Khách hàng Nhật Bản yêu cầu tài liệu chính thức và sign-off tại mỗi giai đoạn. EM-Team v3.5.0 cung cấp đầy đủ bộ công cụ này.

### Workflow chính: Japanese Outsourcing (9 giai đoạn)

```bash
/em-wf:japanese-outsourcing
```

| Giai đoạn | Tên | Gate | Sản phẩm |
|-----------|-----|------|----------|
| 1 | Kickoff | — | Project charter, communication protocol |
| 2 | Requirements | **Gate 1** | REQUIREMENTS.md + client sign-off |
| 3 | Basic Design (基本設計) | **Gate 2a** | BASIC-DESIGN.md + architect sign-off |
| 4 | Detailed Design (詳細設計) | **Gate 2b** | DETAILED-DESIGN.md + dev lead sign-off |
| 5 | Implementation | — | TDD + atomic commits |
| 6 | Internal Testing | **Gate 3** | Unit/integration/E2E + code review sign-off |
| 7 | UAT (受け入れテスト) | **Gate 4** | UAT execution log + client sign-off |
| 8 | Delivery | — | ACCEPTANCE-CHECKLIST + dual sign-off |
| 9 | Support | — | Monitoring, defect management |

### Skills riêng lẻ

```bash
# Tạo 基本設計
/em-skill:basic-design
# Sinh ra: BASIC-DESIGN.md với 8 phần
# (System Overview, Architecture, Data Design, Interface Design,
#  NFRs, Error Handling, Issues/Risks, Sign-Off Table)

# Tạo 詳細設計 per module
/em-skill:detailed-design
# Sinh ra: DETAILED-DESIGN.md với class diagrams, pre/post-conditions

# Chạy 受け入れテスト
/em-skill:uat-process
# Sinh ra: UAT-PLAN.md, UAT-TEST-CASES.md, UAT-EXECUTION-LOG.md,
#           UAT-DEFECT-LOG.md, UAT-SIGNOFF.md

# Báo cáo tiến độ tuần
/em-skill:progress-reporting
# Sinh ra: Weekly status với GREEN/YELLOW/RED, metrics, escalation
```

### Templates và Protocols có sẵn

- `templates/context-artifacts/WBS.md` — WBS 4 cấp với effort estimates
- `templates/context-artifacts/ISSUE-REGISTER.md` — Quản lý issue + rủi ro
- `templates/context-artifacts/CHANGE-LOG.md` — Tracking thay đổi CHG-YYYYMM-NNN
- `templates/context-artifacts/ACCEPTANCE-CHECKLIST.md` — Checklist 8 phần nghiệm thu
- `protocols/change-management.md` — Quy trình phê duyệt thay đổi 4 cấp
- `protocols/review-gates.md` — 5 phase gates với sign-off template

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
/em-wf:{name} [mô tả task]

# Ví dụ thực tế
/em-wf:new-feature Implement user authentication from idea to production
/em-wf:bug-fix Fix login timeout bug systematically
/em-wf:qa-bug-hunter QA test http://localhost:5173 and log bugs to GitHub
/em-wf:refactoring Refactor authentication code for better maintainability
/em-wf:security-audit Audit payment system for vulnerabilities
/em-wf:distributed-investigation Investigate authentication failure across full stack
```

### Use Case Chi tiết: New Feature Workflow

#### Workflow: New Feature

```bash
/em-wf:new-feature Implement user authentication

# Workflow sẽ đi qua 7 phases:

# PHASE 1: DEFINE
# ==============================
# Agent: em-agent:product-manager
# Output: Feature specification với:
#   - Business requirements
#   - User stories
#   - Acceptance criteria
#   - Success metrics

# PHASE 2: PLAN
# ==============================
# Agent: em-agent:planner
# Output: Implementation plan với:
#   - Technical approach
#   - Database schema
#   - API endpoints
#   - Frontend components
#   - Testing strategy
#   - Security considerations

# PHASE 3: BUILD
# ==============================
# Agent: em-agent:executor
# Output: Working implementation với:
#   - Database migrations
#   - Backend API
#   - Frontend UI
#   - Tests (TDD)
#   - Documentation

# PHASE 4: VERIFY
# ==============================
# Agent: em-agent:test-engineer
# Output: Test results với:
#   - Unit tests (80%+ coverage)
#   - Integration tests
#   - E2E tests
#   - Security tests

# PHASE 5: REVIEW
# ==============================
# Agents: em-code-reviewer, em-security-reviewer
# Output: Review reports với:
#   - Code quality assessment
#   - Security audit results
#   - Performance analysis
#   - Recommendations

# PHASE 6: SIMPLIFY
# ==============================
# Agent: em-agent:code-reviewer
# Output: Refactored code với:
#   - Reduced complexity
#   - Better abstractions
#   - Cleaner design
#   - Improved maintainability

# PHASE 7: SHIP
# ==============================
# Agent: em-agent:verifier
# Output: Deployment package với:
#   - Final verification
#   - Deployment checklist
#   - Rollout plan
#   - Monitoring setup
```

### Use Case Chi tiết: Bug Fix Workflow

#### Workflow: Bug Fix

```bash
/em-wf:bug-fix Fix login timeout bug

# Workflow sẽ đi qua 5 phases:

# PHASE 1: INVESTIGATE
# ==============================
# Agent: em-agent:debugger
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
# Agent: em-agent:staff-engineer
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
# Agent: em-agent:debugger
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
# Agent: em-agent:executor
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
# Agent: em-agent:verifier
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

### Use Case Chi tiết: QA Bug Hunter Workflow *(v4.1.0)*

#### Workflow: QA Bug Hunter

```bash
/em-wf:qa-bug-hunter QA test http://localhost:5173/projects with targeted mode

# Workflow sẽ đi qua 7 stages:

# STAGE 0: SETUP
# ==============================
# Process:
#   1. Validate target URL accessible
#   2. Detect GitHub repo từ git remote
#   3. Tạo evidence directory
#   4. Verify gh CLI authenticated

# STAGE 1: DISCOVER
# ==============================
# Skills: em-skill:flow-discovery
# Process:
#   1. Chạy QA testing (critical paths, console errors,
#      network failures, performance, responsive, accessibility)
#   2. Compile danh sách bug candidates
#   3. Phân loại severity (P0-P3)
# Output: Bug candidate list

# STAGE 2: EVIDENCE (per bug)
# ==============================
# Skill: em-skill:browser-testing
# Process:
#   1. Reproduce bug trong browser
#   2. Chụp screenshot tại điểm lỗi
#   3. Thu thập console errors, network failures
# Output: Evidence files (screenshots, logs)

# STAGE 3: PREPARE (per bug)
# ==============================
# Process:
#   1. Draft GitHub issue body
#   2. Format steps to reproduce
#   3. Attach evidence paths
#   ⛔ KHÔNG tạo issue - chỉ chuẩn bị draft

# STAGE 4: HUMAN GATE (per bug) ← ĐIỂM KHÁC BIỆT
# ==============================
# Process:
#   1. Trình bày bug report cho bạn review
#   2. Bạn quyết định:
#      (A) APPROVE — Tạo issue trên GitHub
#      (B) REJECT  — Bỏ qua, không phải bug thật
#      (M) MODIFY  — Sửa trước khi tạo
# ➜ Chỉ tạo issue khi bạn xác nhận là bug thật!

# STAGE 5: LOG (per bug)
# ==============================
# Skill: github-issue-manager
# Process:
#   1. Nếu APPROVE/MODIFY → gh issue create
#   2. Nếu REJECT → ghi lý do vào report
# Output: GitHub issue URL (hoặc rejection logged)

# STAGE 6: SUMMARY
# ==============================
# Output: QA-BUG-HUNTER-REPORT.md với:
#   - Tổng số bugs found
#   - Số approved / rejected / modified
#   - Danh sách issue URLs
#   - Evidence directory path
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
/em-agent:techlead-orchestrator Investigate authentication failure affecting 10% users

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
/em-agent:product-manager Define payment feature requirements

# Output:
# - User stories
# - Functional requirements
# - Acceptance criteria
# - Success metrics

# PHASE 2: PLANNING
/em-agent:planner Create implementation plan cho Stripe integration

# Output:
# - Architecture decision
# - Database schema (payments, transactions)
# - API design (webhooks, callbacks)
# - Security requirements (PCI DSS)
# - Error handling strategy

# PHASE 3: SECURITY REVIEW
/em-agent:security-reviewer Review payment security requirements

# Output:
# - Security assessment
# - OWASP compliance
# - Data encryption requirements
# - PCI DSS checklist

# PHASE 4: IMPLEMENTATION
/em-agent:executor Implement Stripe payment integration

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
/em-agent:test-engineer Create test strategy cho payment system

# Output:
# - Unit tests (90%+ coverage)
# - Integration tests (Stripe sandbox)
# - E2E tests (payment flow)
# - Security tests (OWASP ZAP)

# PHASE 6: REVIEW
/em-agent:code-reviewer Review payment code
/em-agent:security-reviewer Security review payment system

# Output:
# - Code quality assessment
# - Security audit results
# - Recommendations

# PHASE 7: DEPLOYMENT
/em-wf:deployment Deploy payment feature to staging

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
/em-agent:codebase-mapper Analyze user service architecture

# Output:
# - Current architecture analysis
# - Dependency mapping
# - Code patterns
# - Refactoring opportunities

# PHASE 2: QUALITY ASSESSMENT
/em-agent:code-reviewer Deep review user service code

# Output:
# - 9-axis code review
# - Complexity analysis
# - Code smells
# - Technical debt

# PHASE 3: PLANNING
/em-agent:planner Create refactoring plan

# Output:
# - Refactoring strategy
# - Incremental steps
# - Risk mitigation
# - Testing approach

# PHASE 4: REFACTORING (incremental)
/em-wf:refactoring Refactor user authentication module
/em-wf:refactoring Refactor user profile module
/em-wf:refactoring Refactor user permissions module

# Each refactoring:
# 1. Write tests (TDD)
# 2. Refactor code
# 3. Verify tests pass
# 4. Run integration tests
# 5. Document changes

# PHASE 5: VERIFICATION
/em-agent:test-engineer Verify refactoring with regression tests

# Output:
# - Regression test suite
# - Test results
# - Performance comparison

# PHASE 6: DEPLOYMENT
/em-wf:deployment Deploy refactored service

# Output:
# - Gradual rollout
# - Monitoring
# - Rollback plan
```

### Use Case 3: Microservices Architecture Migration

#### Goal: Migrate monolith to microservices

```bash
# PHASE 1: ARCHITECTURE ASSESSMENT
/em-agent:architect Review current architecture
/em-agent:codebase-mapper Map dependencies and boundaries

# Output:
# - Current architecture analysis
# - Service boundaries proposal
# - Migration roadmap

# PHASE 2: DESIGN
/em-agent:architect Design microservices architecture
/em-agent:database-expert Design data distribution strategy
/em-agent:backend-expert Design inter-service communication

# Output:
# - Architecture decision record (ADR)
# - Service decomposition plan
# - Data migration strategy
# - API contracts

# PHASE 3: PROOF OF CONCEPT
/em-wf:new-feature Implement first microservice (user service)

# Output:
# - Working microservice
# - Lessons learned
# - Patterns established

# PHASE 4: MIGRATION (incremental)
/em-wf:distributed-development Migrate features to microservices in parallel

# Parallel teams:
# - Team 1: User service
# - Team 2: Payment service
# - Team 3: Notification service
# - Team 4: Order service

# Each team uses:
/em-wf:new-feature Implement [service] features

# PHASE 5: INTEGRATION
/em-agent:integration-checker Verify cross-service integration

# Output:
# - Integration test results
# - API contract validation
# - Data flow verification

# PHASE 6: DEPLOYMENT
/em-wf:deployment Deploy microservices to production

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
/em-skill:brainstorming Explore feature ideas
/em-skill:test-driven-development Implement simple function

# Task chuyên môn, single domain → Agent
/em-agent:backend-expert Optimize database queries
/em-agent:frontend-expert Review React components
/em-agent:security-reviewer Audit authentication

# Quy trình phức tạp, multi-phase → Workflow
/em-wf:new-feature Take feature from idea to production
/em-wf:bug-fix Fix bug systematically
/em-wf:refactoring Improve code quality

# Task multi-domain, cần parallel → Distributed Mode
./scripts/distributed-orchestrator.sh start
/em-agent:techlead-orchestrator Investigate across full stack
```

### 2. Viết Prompts Hiệu quả

```bash
# ❌ Quá mơ hồ
/em-agent:planner Lập kế hoạch

# ❌ Quá cụ thể, micromanaging
/em-agent:planner Tạo kế hoạch với 5 tasks, task 1 làm A, task 2 làm B, ...

# ✅ Cân bằng - Clear goal với sufficient context
/em-agent:planner Tạo kế hoạch triển khai cho user authentication với JWT.
Nên bao gồm: database schema, API endpoints, frontend components,
testing strategy, và security considerations.
```

### 3. Cung cấp Context Phù hợp

```bash
# ❌ Không có context
/em-agent:debugger Fix bug

# ✅ Với context
/em-agent:debugger Investigate login timeout bug.
Started 2 hours ago after deployment.
Error: "Connection timeout after 30s".
Affects 10% of login attempts.
Backend logs show database query timeouts.
Database: PostgreSQL 13, connection pool: 20 max.

# ✅✅ Với context + artifacts
/em-agent:debugger Investigate login timeout.
Bug report: JIRA-123
Logs: /var/log/auth-service.log
Metrics: https://grafana.example.com/d/auth
Reproduction steps: [steps]
```

### 4. Tuân thủ Iron Laws

```bash
# TDD Iron Law
/em-skill:test-driven-development Implement feature
# Agent sẽ:
# 1. RED - Viết failing test
# 2. GREEN - Implement để pass
# 3. REFACTOR - Improve code
# NEVER write production code WITHOUT failing test

# Debugging Iron Law
/em-agent:debugger Investigate bug
# Agent sẽ:
# 1. Gather information
# 2. Form hypotheses
# 3. Test hypotheses
# 4. Find ROOT CAUSE
# NEVER fix WITHOUT root cause

# Spec Iron Law
/em-skill:spec-driven-development Create spec
# Agent sẽ:
# 1. Write specification FIRST
# 2. Get approval
# 3. THEN implement
# NEVER code WITHOUT spec (for features)
```

### 5. Làm việc Iteratively

```bash
# ❌ Big bang approach
/em-wf:new-feature Implement entire e-commerce system

# ✅ Iterative approach
/em-wf:new-feature Implement user registration
# Review, test, deploy

/em-wf:new-feature Implement user profile
# Review, test, deploy

/em-wf:new-feature Implement user authentication
# Review, test, deploy

# ✅✅ Incremental with feedback
/em-wf:new-feature Implement MVP authentication
/em-agent:code-reviewer Review authentication
# Incorporate feedback

/em-wf:new-feature Add OAuth2 support
/em-agent:security-reviewer Audit OAuth2 implementation
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
chmod +x /Users/abc/Desktop/EM-Team/commands/*.sh
chmod +x /Users/abc/Desktop/EM-Team/scripts/*.sh

# 3. Kiểm tra PATH
echo $PATH | grep EM-Team
# Nếu không có, add to PATH:
export PATH="/Users/abc/Desktop/EM-Team/commands:$PATH"

# 4. Verify command files exist
ls -la /Users/abc/Desktop/EM-Team/commands/
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
chmod +x /Users/abc/Desktop/EM-Team/scripts/distributed-orchestrator.sh
chmod +x /Users/abc/Desktop/EM-Team/distributed/*.sh

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
cat /tmp/em-team-test-logs/latest.log
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

- [GitHub Issues](https://github.com/nv-minh/agent-team/issues) - Báo cáo issues
- [GitHub Discussions](https://github.com/nv-minh/agent-team/discussions) - Thảo luận
- [Contributing Guide](CONTRIBUTING.md) - Đóng góp dự án

---

**Phiên bản:** 5.5.0
**Cập nhật lần cuối:** 2026-05-27
**Tình trạng:** ✅ Production Ready

**Cần trợ giúp?**
- Kiểm tra [Xử lý sự cố](#xử-lý-sự-cố)
- Đọc [Best Practices](#best-practices)
- Xem [Use Cases](#use-cases-chi-tiết)
- Report bugs tại [GitHub Issues](https://github.com/nv-minh/agent-team/issues)

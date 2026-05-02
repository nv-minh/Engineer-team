# EM-Team Architecture Guide

Tài liệu giải thích chi tiết cách EM-Team hoạt động bên trong — mỗi folder/file làm gì, cơ chế core ra sao, và cách các thành phần kết nối với nhau.

---

## 1. Big Picture — EM-Team là gì?

EM-Team là một **thư viện skills/agents/workflows** chạy trên **Claude Code** (CLI tool của Anthropic). Khi bạn install EM-Team, bạn đang thêm 130+ commands chuyên biệt vào Claude Code — biến Claude thành một engineering team ảo.

```
Claude Code (CLI)
    ├── Đọc CLAUDE.md → biết project này dùng EM-Team
    ├── Đọc config.json → biết tìm skills/agents/workflows ở đâu
    └── Khi user gõ /em:skill:brainstorming → load skill content → execute
```

---

## 2. Folder Structure — Mỗi folder làm gì?

```
EM-Team/
│
├── CLAUDE.md              ← FILE QUAN TRỌNG NHẤT — Claude Code đọc file này đầu tiên
│                              Chứa: ethos, skill list, agent list, workflow list,
│                              iron laws, boundary rules, code conventions
│
├── install.sh              ← Cài đặt EM-Team vào ~/.claude/
├── uninstall.sh            ← Gỡ cài đặt
│
├── .claude/
│   ├── settings.local.json ← Cấu hình permissions (cho phép chạy lệnh gì)
│   └── skills/             ← WRAPPER FILES (35 agent wrappers + 72 skill wrappers)
│       ├── em-architect.md       Wrapper cho agent architect
│       ├── em-new-feature.md     Wrapper cho workflow new-feature
│       ├── em-skill-brainstorming.md  Wrapper cho skill brainstorming
│       └── ... (130+ files)
│
├── skills/                 ← SKILL SOURCE FILES (nội dung đầy đủ 200-771 dòng)
│   ├── foundation/         6 skills nền tảng
│   │   └── alignment-session/alignment-session.md
│   ├── development/        18 skills phát triển
│   │   ├── backend-patterns/backend-patterns.md
│   │   └── ...
│   ├── quality/            10 skills chất lượng
│   │   ├── code-review/code-review.md
│   │   └── ...
│   ├── workflow/           5 skills quy trình
│   │   └── style-switcher/style-switcher.md
│   └── additional/         5 product & discovery skills
│       └── ...
│
├── agents/                 ← AGENT FILES (35 agents, mỗi cái là 1 AI specialist)
│   ├── planner.md          Agent tạo implementation plan
│   ├── architect.md        Agent review architecture
│   ├── debugger.md         Agent debug systematic
│   ├── expert-*/           Expert agent groups (backend-expert, frontend-expert, database-expert...)
│   └── ... (35 files)
│
├── workflows/              ← WORKFLOW FILES (23 workflows, end-to-end processes)
│   ├── new-feature.md      Workflow từ idea → production
│   ├── bug-fix.md          Workflow fix bug
│   └── ... (23 files)
│
├── preambles/              ← KHỞI TẠO CHUNG — được load khi agent/skill bắt đầu
│   ├── ethos.md            5 nguyên tắc cốt lõi (Boil the Lake, Search Before Building...)
│   ├── skill-preamble.md   Template chung cho skills
│   └── agent-preamble.md   Template chung cho agents
│
├── protocols/              ← TIÊU CHUẨN GIAO TIẾP
│   ├── writing-style.md    Format báo cáo, active voice, severity levels
│   ├── delegation.md       Cách agents handoff công việc cho nhau
│   └── distributed-messaging.md  Giao tiếp giữa distributed agents
│
├── references/             ← TÀI LIỆU THAM KHẢO — skills/agents tham chiếu
│   ├── code-quality.md     Tiêu chuẩn chất lượng code
│   ├── security-checklist.md   OWASP checklist
│   ├── testing-patterns.md     Patterns testing
│   └── api-checklist.md        API standards
│
├── templates/              ← MẪU TẠO MỚI — khi bạn muốn thêm skill/agent mới
│   ├── skill-template.md
│   ├── agent-template.md
│   └── context-artifacts/  Mẫu cho PROJECT.md, REQUIREMENTS.md, ROADMAP.md
│
├── hooks/                  ← GIT HOOKS — chạy tự động khi commit/push
│
├── commands/               ← CLI COMMANDS — script chạy nhanh
│
└── docs/                   ← DOCUMENTATION
    ├── guides/             Hướng dẫn sử dụng (EN)
    ├── vi/                 Hướng dẫn sử dụng (VI)
    ├── architecture/       Tài liệu kiến trúc
    └── tests/              Tài liệu testing
```

---

## 3. Core Mechanism — Claude Code khám phá EM-Team như thế nào?

### Step 1: CLAUDE.md — Entry Point

Khi bạn mở Claude Code trong bất kỳ folder nào, Claude đọc file `CLAUDE.md` (nếu có). Đây là **hướng dẫn sử dụng** cho Claude.

EM-Team's `CLAUDE.md` nói cho Claude biết:
- Có 72 skills, 35 agents, 23 workflows sẵn sàng
- Mỗi cái tên gì, làm gì
- Iron Laws (luật bất di bất dịch)
- Khi nào dùng skill, khi nào dùng agent, khi nào dùng workflow

### Step 2: config.json — Discovery Paths

`install.sh` cập nhật `~/.claude/config.json`:

```json
{
  "skills": {
    "enabled": true,
    "paths": ["/path/to/EM-Team/.claude/skills"]
  },
  "agents": {
    "enabled": true,
    "paths": ["/path/to/EM-Team/agents"]
  },
  "workflows": {
    "enabled": true,
    "paths": ["/path/to/EM-Team/workflows"]
  }
}
```

Claude Code đọc `config.json` và biết tìm skills/agents/workflows ở đâu.

### Step 3: Symlinks — Skill Discovery

Claude Code discover skills theo convention: `~/.claude/skills/*/SKILL.md`

Ví dụ:
```
~/.claude/skills/
├── em:architect/
│   └── SKILL.md  → symlink → /EM-Team/.claude/skills/em-architect.md (wrapper, 34 dòng)
├── em:new-feature/
│   └── SKILL.md  → symlink → /EM-Team/.claude/skills/em-new-feature.md (wrapper, 50 dòng)
├── em:skill:brainstorming/
│   └── SKILL.md  → symlink → /EM-Team/skills/foundation/brainstorming/brainstorming.md (229 dòng)
├── em:skill:backend-patterns/
│   └── SKILL.md  → symlink → /EM-Team/skills/development/backend-patterns/backend-patterns.md (771 dòng)
└── ... (130+ directories)
```

**Điểm quan trọng:**
- **Agent/Workflow wrappers** (em-architect, em-new-feature) → symlink tới wrapper file (~34 dòng, tự chứa nội dung)
- **Skill wrappers** (em-skill-*) → install.sh parse `## Source` path, symlink **trực tiếp tới source file** (229-771 dòng)

Khi user gõ `/em:skill:brainstorming`, Claude đọc file 229 dòng → có đầy đủ context để execute.

---

## 4. Ba loại thành phần — Skill vs Agent vs Workflow

### Skill — Pattern/Practice (72 cái)

**Là gì:** Một hướng dẫn có cấu trúc cho một task cụ thể. Skill cung cấp process, anti-patterns, coaching notes.

**Khi nào dùng:** Khi bạn cần hướng dẫn approach cho một loại task (debug, code review, viết spec...)

**Format:**
```yaml
---
name: brainstorming
description: "..."
version: "2.0.0"
category: "foundation"           # foundation | development | quality | workflow
origin: "superpowers"            # repo nguồn
triggers:                        # từ khóa kích hoạt
  - "explore idea"
  - "brainstorm"
intent: "..."                    # mục đích
scenarios: [...]                 # tình huống sử dụng
anti_patterns: [...]             # chống-pattern
related_skills: [...]            # skills liên quan
---
```

Body sections:
- **Overview** — Tóm tắt
- **When to Use / When NOT to Use** — Context
- **Process** — Các bước thực hiện (numbered)
- **Coaching Notes** — Dạy người dùng hiểu WHY
- **Verification** — Checklist xác nhận

### Agent — AI Specialist (35 cái)

**Là gì:** Một AI specialist với expertise trong một domain. Agent có identity, capabilities, và handoff protocols.

**Khi nào dùng:** Khi cần chuyên gia phân tích sâu (architect review, security audit, database optimization...)

**Format:**
```yaml
---
name: planner
type: agent
version: 1.2.0
trigger: em-agent:planner             # trigger keyword
description: "..."
capabilities: [...]               # năng lực
inputs: [...]                     # input cần thiết
outputs: [...]                    # output tạo ra
collaborates_with: [...]          # agents khác hợp tác
related_skills: [...]             # skills liên quan (MỚI trong v2.2.0)
status_protocol: true             # có status reporting không
completion_marker: true           # đánh dấu hoàn thành
---
```

**Điểm khác biệt so với Skill:**
- Agent có `type`, `trigger`, `capabilities`, `collaborates_with`
- Agent có **Role Identity** section — "You are a senior software architect..."
- Agent có **Status Protocol** — reporting trạng thái
- Agent có **Completion Marker** — `PLANNER_COMPLETE` để handoff
- Agent có thể **phối hợp với agents khác** qua `collaborates_with`

### Workflow — End-to-End Process (23 cái)

**Là gì:** Quy trình hoàn chỉnh kết hợp nhiều agents + skills. Workflow orchestrate toàn bộ lifecycle.

**Khi nào dùng:** Khi cần end-to-end: idea → production, bug fix, security audit...

**Format:**
```yaml
---
name: new-feature
description: "..."
version: "2.0.0"
category: "primary"
agents_used:                      # agents tham gia
  - planner
  - executor
  - verifier
skills_used:                      # skills sử dụng
  - brainstorming
  - spec-driven-development
related_skills: [...]             # skills liên quan (MỚI trong v2.2.0)
estimated_time: "1-3 days"
---
```

**6-Phase Lifecycle** (tất cả workflows thừa kế):
```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP
```

Mỗi phase có:
- **Quality Gate** — kiểm tra trước khi chuyển phase
- **Handoff Contract** — dữ liệu truyền giữa phases
- **Agent Assignment** — agent nào chịu trách nhiệm

---

## 5. Cơ chế cài đặt — install.sh

```
install.sh chạy 6 steps:

Step 1: Verify repo exists (check CLAUDE.md)
Step 2: Ensure ~/.claude/ exists
Step 3: Update ~/.claude/config.json
        → thêm skills.paths, agents.paths, workflows.paths
Step 4: Create symlinks (76 total)
        → Agent/workflow wrappers → symlink tới wrapper file
        → Skill wrappers → parse ## Source → symlink tới SOURCE FILE thật
Step 5: Clean up orphaned entries from previous installs
Step 6: Verify — check config, check symlinks, check broken links
```

**Luồng symlink:**
```
install.sh đọc wrapper file          em-skill-brainstorming.md
    ↓ tìm ## Source line
    ↓ extract: skills/foundation/brainstorming/brainstorming.md
    ↓ resolve: /EM-Team/skills/foundation/brainstorming/brainstorming.md
    ↓ verify file exists
    ↓ create symlink
~/.claude/skills/em:skill:brainstorming/SKILL.md → source (229 dòng)
```

---

## 6. Luồng hoạt động — Khi user gọi một lệnh

### Ví dụ: User gõ `/em:skill:brainstorming Explore auth options`

```
1. Claude Code thấy /em:skill:brainstorming
2. Tìm ~/.claude/skills/em:skill:brainstorming/SKILL.md
3. Đọc symlink target → skills/foundation/brainstorming/brainstorming.md
4. Parse YAML frontmatter → hiểu intent, triggers, scenarios
5. Load full content (229 dòng) → process steps, coaching notes, verification
6. Execute theo process đã định nghĩa
7. Kết quả: comparison table, recommendations, architecture patterns
```

### Ví dụ: User gõ `/em:new-feature Implement user auth`

```
1. Claude Code thấy /em:new-feature
2. Tìm ~/.claude/skills/em:new-feature/SKILL.md → wrapper
3. Đọc wrapper → biết đây là workflow
4. config.json trỏ workflows.paths → /EM-Team/workflows/
5. Load workflows/new-feature.md (full workflow)
6. Workflow định nghĩa 7 phases:
   DEFINE → PLAN → BUILD → VERIFY → REVIEW → SIMPLIFY → SHIP
7. Mỗi phase gán agents và skills cụ thể
8. Claude orchestrate qua từng phase, gọi agents/skills tương ứng
```

---

## 7. Preambles, Protocols, References — Shared Context

### Preambles (khởi tạo chung)

Khi một agent bắt đầu, nó load preamble:
- **ethos.md** — 5 nguyên tắc: Boil the Lake, Search Before Building, User Sovereignty, Iron Laws, Always Be Coaching
- **agent-preamble.md** — Template chung: Role Identity, Status Protocol, Coaching Mandate

### Protocols (tiêu chuẩn giao tiếp)

- **writing-style.md** — Báo cáo dùng active voice, severity levels (CRITICAL/HIGH/MEDIUM/LOW), executive summary first
- **delegation.md** — Cách agent A handoff cho agent B: input/output contract, completion markers
- **distributed-messaging.md** — Giao tiếp tmux sessions trong distributed mode

### References (tài liệu tham chiếu)

Skills và agents reference các tài liệu này khi cần:
- `code-quality.md` — Tiêu chuẩn chất lượng
- `security-checklist.md` — OWASP Top 10 checklist
- `testing-patterns.md` — Testing strategies
- `api-checklist.md` — API design standards

---

## 8. Iron Laws — 4 luật bất di bất dịch

```yaml
Iron Law 1 — TDD: NO PRODUCTION CODE WITHOUT FAILING TEST
    Viết test trước, code sau. Luôn RED → GREEN → REFACTOR.

Iron Law 2 — Debugging: NO FIXES WITHOUT ROOT CAUSE
    Không bao giờ fix symptom. Tìm root cause trước.

Iron Law 3 — Spec: NO CODE WITHOUT SPEC (cho features)
    Viết spec trước khi code feature mới.

Iron Law 4 — Review: NO MERGE WITHOUT REVIEW
    Luôn review code trước khi merge.
```

Enforced by: `agents/iron-law-enforcer.md` — agent chuyên kiểm tra tuân thủ.

---

## 9. Boundary System — Khi nào làm gì

| Tier | Hành vi | Ví dụ |
|------|---------|-------|
| **Always Do** | Tự động, không cần hỏi | Chạy tests trước commit, validate inputs, review trước ship |
| **Ask First** | Hỏi user trước | Thay đổi DB schema, thêm dependencies, breaking changes |
| **Never Do** | Không bao giờ làm | Commit secrets, skip code review, push main không tests |

---

## 10. Communication Styles — 2 trục điều khiển

EM-Team có hệ thống giao tiếp linh hoạt:

**Trục 1 — Personality (13 styles):**
```
/em:skill:style-switcher tactical     → Trực tiếp, không dài dòng
/em:skill:style-switcher teacher      → Giải thích kiểu Feynman
/em:skill:style-switcher raw          → Code nhanh, fragments
/em:skill:style-switcher reality-check → Đánh giá thẳng thắn
... (9 styles khác)
```

**Trục 2 — Density (3 modes):**
```
/standard    → Báo cáo đầy đủ, có coaching
/compact     → Bullet points, code fix only
/terse       → 1 dòng status, diff only
```

Hai trục độc lập — đổi personality không ảnh hưởng density.

---

## 11. Mối quan hệ giữa các thành phần

```
CLAUDE.md (master config)
    ↓ referenced by
    ├── Skills (43) ← use → References (security, testing, quality)
    ├── Agents (28) ← use → Skills, collaborate with → other Agents
    └── Workflows (23) ← orchestrate → Agents + Skills
         ↑ inherit
    six-phase-lifecycle.md (master workflow)

    All follow → Preambles (ethos, templates)
    All follow → Protocols (writing-style, delegation)
```

**Luồng dependency:**
1. CLAUDE.md → hướng dẫn tổng quan
2. Workflow → gọi Agents + Skills theo phase
3. Agent → thực thi task, tham chiếu Skills nếu cần
4. Skill → cung cấp process pattern cho task
5. References → dữ liệu tham chiếu cho Skills/Agents
6. Protocols → tiêu chuẩn giao tiếp chung
7. Preambles → khởi tạo giá trị cốt lõi

---

## 12. Khi bạn muốn thêm thành phần mới

### Thêm Skill mới
1. Tạo `skills/category/skill-name/skill-name.md` (theo skill-template.md)
2. Tạo `.claude/skills/em-skill-skill-name.md` (wrapper với `## Source`)
3. Update `CLAUDE.md` — thêm vào danh sách skills
4. Update docs — VI guide, usage guide, README
5. Chạy `bash install.sh` — symlink tự động tạo

### Thêm Agent mới
1. Tạo `agents/agent-name.md` (theo agent-template.md)
2. Tạo `.claude/skills/em-agent-name.md` (wrapper)
3. Update `CLAUDE.md` — thêm vào danh sách agents
4. Chạy `bash install.sh`

### Thêm Workflow mới
1. Tạo `workflows/workflow-name.md` (theo workflow-template.md)
2. Tạo `.claude/skills/em-workflow-name.md` (wrapper)
3. Update `CLAUDE.md` — thêm vào danh sách workflows
4. Chạy `bash install.sh`

---

## 13. Troubleshooting

| Vấn đề | Nguyên nhân | Fix |
|---------|-------------|-----|
| Skill không hiện trong autocomplete | Symlink bị đứt | `bash install.sh` |
| Agent không phản hồi | config.json sai path | Check `~/.claude/config.json` |
| "command not found" | Chưa install | `bash install.sh` |
| Nội dung skill ngắn (20 dòng) | Symlink trỏ tới wrapper, không phải source | Update install.sh v2.2.0+ |
| Skill cũ vẫn hiện | Orphaned entries | `bash install.sh` (Step 5 cleanup) |

---

## Version History

- **v3.0.0** (2026-05-02) — Expert group restructuring: 72 skills, 35 agents, 15 expert groups, 27 new skills, 7 new expert agents
- **v2.2.0** (2026-05-01) — 7 new skills + NestJS patterns + related_skills + install mechanism
- **v1.2.0** — Discovery & market intelligence
- **v1.0.0** — Initial release

# EM-Team Commands - Complete Reference Guide (v1.2.0)

## ✅ Tổng Cộng: 67+ Commands

### 📊 Phân Loại Commands (Updated v1.2.0)

#### 1. Discovery & Market Intelligence Skills (5 commands) - NEW!
Skills để validate ideas và run discovery trước khi build:

```
/office-hours                  -> YC Office Hours validation (6 forcing questions)
/jobs-to-be-done              -> Customer motivation framework (Jobs, Pains, Gains)
/lean-ux-canvas               -> Problem framing tool (Jeff Gothelf's 8-box)
/opportunity-solution-tree    -> Solution exploration (Teresa Torres' OST)
/pol-probe                    -> Lightweight validation (5 prototype flavors)
```

**Cách dùng:**
```bash
Use the /office-hours skill to validate product idea with YC framework
Use the /jobs-to-be-done skill to understand customer motivation
Use the /lean-ux-canvas skill to frame business problem properly
Use the /opportunity-solution-tree skill to explore solution options
Use the /pol-probe skill to design lightweight validation experiments
```

**Khi nào dùng:**
- "Tôi có một product idea" → `/office-hours`
- "Tôi cần hiểu customer motivation" → `/jobs-to-be-done`
- "Tôi cần frame business problem" → `/lean-ux-canvas`
- "Tôi cần explore solutions" → `/opportunity-solution-tree`
- "Tôi cần validate hypothesis" → `/pol-probe`

---

#### 2. Agent Commands (24 commands) - Prefix: `em:`
Gọi các chuyên gia AI (bao gồm 3 agents mới):

**Discovery & Learning Agents (3 commands) - NEW:**
```
/em:market-intelligence      -> Market analysis & competitive intelligence
/em:learn                    -> Project learnings management (patterns, pitfalls, ADRs)
/em:autoplan                 -> Multi-phase review pipeline (CEO, Design, Eng, DX)
```

**Core Development Agents (7 commands):**
```
/em:planner                  -> Create implementation plans
/em:executor                 -> Execute plans with atomic commits
/em:code-reviewer            -> 5-axis code review
/em:debugger                 -> Systematic debugging
/em:test-engineer            -> Test strategy & generation
/em:security-auditor         -> OWASP security audit
/em:verifier                 -> Post-execution verification
```

**Expert Agents (9 commands):**
```
/em:architect                -> Architecture & technical design
/em:backend-expert           -> Backend specialist (API, DB, performance)
/em:frontend-expert          -> Frontend specialist (React, Next.js, UI/UX)
/em:database-expert          -> Database specialist (schema, queries, fintech)
/em:product-manager          -> Requirements, GAP analysis, market fit
/em:senior-code-reviewer      -> 9-axis deep code review
/em:security-reviewer         -> OWASP + STRIDE security
/em:staff-engineer            -> Root cause analysis, cross-service impact
/em:team-lead                 -> Team coordination
```

**Advanced Agents (5 commands):**
```
/em:techlead-orchestrator     -> Distributed investigation coordination
/em:researcher                -> Technical research & exploration
/em:codebase-mapper           -> Architecture analysis
/em:integration-checker       -> Cross-phase validation
/em:performance-auditor       -> Benchmarking & optimization
```

**Cách dùng:**
```bash
Use the em:market-intelligence agent to analyze market opportunity
Use the em:learn agent to capture project learnings
Use the em:autoplan agent to coordinate multi-phase reviews
Use the em:planner agent to create implementation plan for JWT auth
Use the em:backend-expert agent to optimize database queries
Use the em:frontend-expert agent to review React components
```

---

#### 3. Core Workflow Commands (9 commands) - Prefix: `em:`
Workflows phổ biến dùng hàng ngày (bao gồm 1 workflow mới):

```
/em:discovery-process        -> Complete 6-stage discovery workflow (NEW)
/em:new-feature              -> Implement feature from idea to production
/em:bug-fix                  -> Fix bugs systematically
/em:refactor                 -> Improve code quality
/em:security-audit           -> Security assessment
/em:project-setup            -> Initialize new projects
/em:documentation            -> Generate/update documentation
/em:deployment               -> Deploy and monitor features
/em:retro                    -> Retrospective and improvement
```

**Cách dùng:**
```bash
Use the em:discovery-process skill to run complete discovery
Use the em:new-feature skill to implement user authentication
Use the em:bug-fix skill to fix login timeout systematically
Use the em:refactor skill to improve code quality
```

---

#### 4. Specialized Workflow Commands (9 commands) - Prefix: `em:wl-`
Workflows chuyên sâu cho tác vụ phức tạp:

```
/em:wl-team-review           -> Full team review coordination
/em:wl-architecture-review    -> Architecture review (Architect + Staff Engineer)
/em:wl-design-review          -> UI/UX design review (Frontend + Product Manager)
/em:wl-code-review-9axis      -> Deep 9-axis code review
/em:wl-database-review        -> Database schema & query review
/em:wl-product-review         -> Product/spec review (Product Manager + Architect)
/em:wl-security-review        -> Advanced security (OWASP + STRIDE)
/em:wl-distributed-dev       -> Parallel distributed development
/em:wl-distributed-investigation -> Parallel investigation across services
```

**Cách dùng:**
```bash
Use the em:wl-architecture-review skill to review microservices architecture
Use the em:wl-code-review-9axis skill to conduct deep code review
Use the em:wl-security-review skill to conduct threat modeling
```

---

## 🎯 Quick Decision Guide (Updated v1.2.0)

### Tôi cần gì?

**Discovery & Market Intelligence:**
- "Tôi có product idea, cần validate" → `/office-hours`
- "Tôi cần hiểu customer motivation" → `/jobs-to-be-done`
- "Tôi cần frame business problem" → `/lean-ux-canvas`
- "Tôi cần explore solutions" → `/opportunity-solution-tree`
- "Tôi cần validate hypothesis" → `/pol-probe`
- "Tôi cần run complete discovery" → `/em:discovery-process`
- "Tôi cần capture learnings" → `/em:learn`
- "Tôi cần coordinate reviews" → `/em:autoplan`
- "Tôi cần market analysis" → `/em:market-intelligence`

**Development Tasks:**
- "Tôi cần tạo kế hoạch" → `/em:planner`
- "Tôi cần review code/backend/frontend/database" → `/em:code-reviewer` / `/em:backend-expert` / `/em:frontend-expert` / `/em:database-expert`
- "Tôi cần implement feature mới" → `/em:new-feature`
- "Tôi cần fix bug" → `/em:bug-fix`
- "Tôi cần cải thiện code quality" → `/em:refactor`
- "Tôi cần debug lỗi" → `/em:debugger`
- "Tôi cần audit security" → `/em:security-auditor` (basic) / `/em:wl-security-review` (advanced)
- "Tôi cần architecture review" → `/em:architect` (quick) / `/em:wl-architecture-review` (full team)
- "Tôi cần setup project mới" → `/em:project-setup`
- "Tôi cần deploy" → `/em:deployment`

---

## 📋 Comparison Table (Updated v1.2.0)

| Type | Prefix | Purpose | Examples | Count |
|------|--------|---------|----------|-------|
| **Discovery Skills** | `/` | Product validation & discovery | office-hours, jobs-to-be-done, lean-ux-canvas | 5 |
| **Development Skills** | `/` | Core development practices | brainstorming, spec-driven-dev, TDD, debugging | 21 |
| **Agents** | `em:` | Gọi chuyên gia | market-intelligence, learn, autoplan, planner, backend-expert | 24 |
| **Core Workflows** | `em:` | Workflows hàng ngày | discovery-process, new-feature, bug-fix, refactor | 9 |
| **Specialized Workflows** | `em:wl-` | Workflows chuyên sâu | wl-architecture-review, wl-code-review-9axis, wl-security-review | 9 |
| **Total** | - | - | - | **67+** |

---

## 💡 Usage Tips (Updated v1.2.0)

### Discovery First Approach

**Trước khi build, nên:**
1. Validate idea với `/office-hours` (30 phút)
2. Nếu score 8-10 → Run `/em:discovery-process` (2-4 weeks)
3. Coordinate reviews với `/em-autoplan` (1-2 days)
4. Capture learnings với `/em-learn` (after completion)

**User journey hoàn chỉnh:**
```
IDEA 
  → /office-hours (validate demand)
  → /em:discovery-process (validate solution)
  → /em-autoplan (multi-phase reviews)
  → /em-planner (create plan)
  → /em-executor (implement)
  → /em-learn (capture learnings)
```

### Agent vs Workflow - Khi nào dùng?

**Dùng Discovery Skills khi:**
- Có product idea cần validate
- Cần understand customer motivation
- Cần frame business problem
- Cần explore solution options
- Cần design validation experiments

**Dùng Agent (`em:*`) khi:**
- Cần chuyên gia cho tác vụ cụ thể
- Chỉ cần 1 chuyên gia, không cần full workflow
- Muốn quick feedback từ chuyên gia

Ví dụ:
```bash
Use the em:market-intelligence agent to analyze market opportunity
Use the em:backend-expert agent to review API performance
Use the em:frontend-expert agent to refactor React components
```

**Dùng Core Workflow (`em:`) khi:**
- Cần quy trình hoàn chỉnh từ đầu đến cuối
- Task phổ biến hàng ngày
- Muốn tự động hóa quy trình

Ví dụ:
```bash
Use the em:discovery-process skill to run complete discovery
Use the em:new-feature skill to implement user authentication
Use the em:bug-fix skill to fix login timeout systematically
```

**Dùng Specialized Workflow (`em:wl-`) khi:**
- Cần review từ nhiều chuyên gia (2+ agents)
- Task phức tạp cần coordination
- Cần deep dive analysis

Ví dụ:
```bash
Use the em:wl-architecture-review skill to conduct architecture review with team
Use the em:wl-code-review-9axis skill to conduct deep code review with security
```

---

## 🚀 Most Common Commands (Top 15 - Updated)

Theo tần suất sử dụng:

**Discovery & Market Intelligence (NEW):**
1. `/office-hours` - Validate product ideas
2. `/jobs-to-be-done` - Customer motivation
3. `/lean-ux-canvas` - Problem framing
4. `/em:learn` - Capture learnings
5. `/em:autoplan` - Coordinate reviews
6. `/em:discovery-process` - Complete discovery

**Core Development:**
7. `/em:planner` - Create plans
8. `/em:backend-expert` - Backend work
9. `/em:frontend-expert` - Frontend work
10. `/em:new-feature` - Implement features
11. `/em:bug-fix` - Fix bugs
12. `/em:code-reviewer` - Review code
13. `/em:debugger` - Debug issues
14. `/em:refactor` - Improve quality
15. `/em:database-expert` - Database work

---

## 🔍 Naming Convention (Updated v1.2.0)

### Discovery Skills: `/[skill-name]`
- `/office-hours` - YC Office Hours validation
- `/jobs-to-be-done` - Jobs, Pains, Gains framework
- `/lean-ux-canvas` - 8-box problem framing tool
- `/opportunity-solution-tree` - OST framework
- `/pol-probe` - Proof of Life probes

### Development Skills: `/[skill-name]`
- `/brainstorming` - Brainstorming skill
- `/spec-driven-development` - Spec-driven development skill
- `/test-driven-development` - TDD skill

### Agents: `em:[agent-name]`
- `em:market-intelligence` - Market intelligence agent
- `em:learn` - Learn agent
- `em:autoplan` - Autoplan agent
- `em:planner` - Planner agent
- `em:backend-expert` - Backend expert agent
- `em:frontend-expert` - Frontend expert agent

### Core Workflows: `em:[workflow-name]`
- `em:discovery-process` - Discovery process workflow
- `em:new-feature` - New feature workflow
- `em:bug-fix` - Bug fix workflow

### Specialized Workflows: `em:wl-[workflow-name]`
- `em:wl-architecture-review` - Architecture review workflow
- `em:wl-code-review-9axis` - 9-axis code review workflow

**Prefix meanings:**
- No prefix = Skill (direct invocation)
- No prefix after `em:` = Agent or Core Workflow
- `wl-` = Workflow Level (specialized, multi-agent)

---

## ✅ Verification

Reload Claude Code session và kiểm tra **system reminder**. Bạn sẽ thấy tất cả 67+ commands!

**Check commands:**
```bash
# Show all commands
bash .claude/commands/em-show.sh

# Expected output should include:
# 📚 SKILLS (26 commands)
# 🤖 AGENTS (24 commands)  
# 🔄 WORKFLOWS (18 commands)
# Total: 67+ commands
```

---

## 📚 Related Documentation

- `README.md` - Main project documentation
- `CHANGELOG.md` - Complete changelog with v1.2.0 changes
- `VERIFICATION-REPORT.md` - Comprehensive verification report
- `IMPLEMENTATION-SUMMARY.md` - Implementation details with flows
- `INSTALLATION.md` - Installation guide
- `CLAUDE.md` - Main configuration

---

## 🆕 What's New in v1.2.0

### Discovery & Market Intelligence (5 new skills, 3 new agents, 3 new workflows)

**Skills:**
- `/office-hours` - YC Office Hours validation with 6 forcing questions
- `/jobs-to-be-done` - Jobs, Pains, Gains framework
- `/lean-ux-canvas` - Jeff Gothelf's 8-box problem framing tool
- `/opportunity-solution-tree` - Teresa Torres' OST framework
- `/pol-probe` - 5 prototype flavors for lightweight validation

**Agents:**
- `/em:market-intelligence` - Market analysis and competitive intelligence
- `/em:learn` - Project learnings management (patterns, pitfalls, preferences, ADRs)
- `/em:autoplan` - Multi-phase review pipeline (CEO, Design, Eng, DX)

**Workflows:**
- `/em:discovery-process` - Complete 6-stage discovery workflow (2-4 weeks)
- `/em:new-feature` (v2.0) - Enhanced with optional market validation
- `/em:market-driven-feature` - Complete market discovery workflow

**Total Impact:**
- +2 skills (26 total)
- +2 agents (24 total)
- +1 workflow (18 total)
- 67+ commands total (increased from 65+)
- ~188K bytes new content

---

**Version:** 1.2.0
**Last Updated:** 2026-04-19
**Status:** ✅ Production Ready

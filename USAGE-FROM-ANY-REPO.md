# Cách sử dụng EM-Skill từ bất kỳ Repository nào

## 🔍 EM-Skill đã được cài đặt toàn cục

EM-Skill đã được cài đặt và cấu hình để sử dụng từ **bất kỳ repository nào** trên máy của bạn.

---

## ✅ Verification

Kiểm tra xem EM-Skill đã sẵn sàng chưa:

```bash
# Kiểm tra cấu hình
cat ~/.claude/config.json

# Bạn sẽ thấy paths đến:
# - /Users/abc/Desktop/EM-Skill/skills (25+ skills)
# - /Users/abc/Desktop/EM-Skill/agents (16 agents)
# - /Users/abc/Desktop/EM-Skill/workflows (18 workflows)
```

---

## 💬 Cách sử dụng từ Repository khác

Khi bạn đang làm việc trong **bất kỳ repository nào** (không phải EM-Skill repo), bạn có thể trực tiếp sử dụng EM-Skill bằng cách:

### Phương pháp 1: Trực tiếp hỏi Claude

```
Bạn: "Tôi đã cài bộ EM-Skill chưa?"

Claude: "Có, EM-Skill đã được cài đặt toàn cục với:
- 25+ skills tại /Users/abc/Desktop/EM-Skill/skills
- 16 agents tại /Users/abc/Desktop/EM-Skill/agents
- 18 workflows tại /Users/abc/Desktop/EM-Skill/workflows

Bạn có thể sử dụng trực tiếp bằng cách:
- 'Use the brainstorming skill to explore ideas'
- 'Agent: em-planner - Create implementation plan'
- 'Workflow: em-new-feature - Implement from idea to production'
"
```

### Phương pháp 2: Sử dụng trực tiếp

```
# Sử dụng Skills
"Use the brainstorming skill to explore authentication options"
"Use the spec-driven-development skill to create a spec"
"Use the systematic-debugging skill to investigate this bug"

# Sử dụng Agents
"Agent: em-planner - Create implementation plan for feature X"
"Agent: em-code-reviewer - Review the changes in this PR"
"Agent: em-debugger - Investigate this bug systematically"

# Sử dụng Workflows
"Workflow: em-new-feature - Take this feature from idea to production"
"Workflow: em-bug-fix - Fix this bug systematically"
"Workflow: em-security-audit - Audit the codebase for security issues"
```

---

## 📚 Tài liệu tham khảo

### Danh sách đầy đủ:

- **[SKILL-INDEX.md](/Users/abc/Desktop/EM-Skill/skills/SKILL-INDEX.md)** - Index hoàn chỉnh của tất cả skills/agents/workflows
- **[README](/Users/abc/Desktop/EM-Skill/README.md)** - Documentation chính
- **[INSTALLATION-VERIFICATION.md](/Users/abc/Desktop/EM-Skill/INSTALLATION-VERIFICATION.md)** - Verification report

---

## 🎯 Ví dụ sử dụng từ Repository khác

### Ví dụ 1: Brainstorming cho tính năng mới

```
Bạn: "Tôi muốn thêm tính năng authentication vào app này. Hãy explore các options."

Claude sẽ: "Tôi sẽ sử dụng brainstorming skill từ EM-Skill để explore authentication options với bạn..."
```

### Ví dụ 2: Debugging bug

```
Bạn: "App của tôi bị lỗi login timeout. Help me investigate."

Claude sẽ: "Tôi sẽ sử dụng systematic-debugging skill từ EM-Skill để investigate bug này một cách có hệ thống..."
```

### Ví dụ 3: Code Review

```
Bạn: "Review code changes trong PR này giúp tôi."

Claude sẽ: "Tôi sẽ sử dụng code-review skill từ EM-Skill để review changes này với framework 5-trục..."
```

### Ví dụ 4: Implementation

```
Bạn: "Tôi muốn implement tính năng user management từ A-Z."

Claude sẽ: "Tôi sẽ sử dụng new-feature workflow từ EM-Skill để take feature này từ idea đến production..."
```

---

## 🔧 Helper Functions

Bạn có thể sử dụng helper functions từ bất kỳ đâu:

```bash
# Source helper functions (nếu chưa source)
source ~/.claude/em-skill.sh

# Sử dụng helper functions
em-start    # Start distributed mode
em-stop     # Stop distributed mode
em-status   # Check session status
em-test     # Run E2E tests
```

---

## 🌐 Distributed Mode

Đối với tasks phức tạp cần nhiều domains:

```bash
# Từ bất kỳ repo nào, bạn có thể:
em-start  # Start distributed orchestration

# Sau đó trong Claude:
"Agent: em-techlead-orchestrator - Investigate bug này qua toàn bộ stack"

# Backend, Frontend, Database agents sẽ work in parallel
em-stop   # Stop distributed mode
```

---

## 📖 Quick Reference Card

### Skills (25 total)
```
Foundation:      brainstorming, spec-driven-development, systematic-debugging
Development:     test-driven-development, frontend-patterns, backend-patterns
Quality:         code-review, security-audit, performance-optimization
Workflow: em-       git-workflow, ci-cd-automation, documentation
```

### Agents (16 total)
```
Core:            planner, executor, code-reviewer, debugger, test-engineer
Specialized:     architect, frontend-expert, database-expert, security-reviewer
```

### Workflows (18 total)
```
Primary:         new-feature, bug-fix, refactoring, security-audit
Support:         project-setup, documentation, deployment, retro
Team:            team-review, architecture-review, code-review-9axis
Distributed:     distributed-investigation, distributed-development
```

---

## ❓ FAQ

### Q: Claude không nhận diện EM-Skill?
**A:**
1. Kiểm tra config: `cat ~/.claude/config.json`
2. Kiểm tra paths tồn tại: `ls /Users/abc/Desktop/EM-Skill/skills`
3. Reload Claude session và thử lại

### Q: Làm sao biết EM-Skill đang hoạt động?
**A:**
```bash
# Test với một câu đơn giản
"Use the brainstorming skill to explore hello world"
# Claude nên respond với brainstorming skill
```

### Q: Có thể update EM-Skill không?
**A:**
```bash
cd /Users/abc/Desktop/EM-Skill
git pull origin main
em-test  # Verify tests still pass
```

---

## ✅ Checklist

- [x] EM-Skill installed at `/Users/abc/Desktop/EM-Skill`
- [x] Claude Code CLI configured at `~/.claude/config.json`
- [x] Skills, Agents, Workflows paths set
- [x] Helper functions available (`em-start`, `em-stop`, `em-status`, `em-test`)
- [x] Documentation accessible
- [x] E2E tests passing (8/8)
- [x] SKILL-INDEX.md created for discoverability
- [x] Ready to use from any repository

---

## 🎉 Kết luận

**EM-Skill đã sẵn sàng sử dụng từ BẤT KỲ repository nào!**

Chỉ cần hỏi Claude về:
- Skills: "Use the [skill-name] skill to [task]"
- Agents: "Agent: em-[agent-name] - [task]"
- Workflows: "Workflow: em-[workflow-name] - [task]"

Claude sẽ tự động tìm và sử dụng resources từ EM-Skill!

---

**Version:** 1.1.0
**Last Updated:** 2026-04-19
**Status:** ✅ Ready to use from any repository

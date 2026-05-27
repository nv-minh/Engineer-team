# EM-Team Documentation

Welcome to the EM-Team documentation hub. This directory contains comprehensive guides for the fullstack engineering agent/skill/workflow system.

---

## 📚 Documentation Structure

### 🚀 Getting Started
- [Quick Start Guide](guides/getting-started.md) - Get up and running in 5 minutes
- [Usage Guide (English)](guides/usage-guide.md) - Comprehensive usage documentation
- [Hướng Dẫn Sử Dụng (Tiếng Việt)](vi/huong-dan-su-dung.md) - Hướng dẫn chi tiết bằng tiếng Việt

### 🏗️ Architecture
- [Architecture Overview](architecture/overview.md) - System architecture and design patterns
- [Distributed System](architecture/distributed-system.md) - Distributed orchestration architecture
- [Architecture Guide](ARCHITECTURE-GUIDE.md) - Detailed how-everything-works guide (Vietnamese)

### 🔧 Protocols & Formats
- [Messaging Protocol](protocols/messaging.md) - Inter-agent communication
- [Report Format](protocols/report-format.md) - Agent report structure

### 🔄 Workflows
- [Workflow Reference](workflows/reference.md) - All 27 workflows with stages, gates, and examples
- [Workflow Overview](workflows/overview.md) - Quick catalog

### 📖 Skill, Agent & Workflow Guides
- [Agent Reference](agents/reference.md) - All 36 agents with capabilities, examples, and usage
- [Skills Overview](skills/overview.md) - All 86 skills organized by category
- [Agent Overview](agents/overview.md) - Quick catalog
- [Skill Systems Guide](skill-systems-guide.md) - How the skill system is organized

### 📚 Feature Guides (English)
- [Brownfield Intelligence](guides/brownfield.md) - Onboard and investigate existing codebases
- [Test Automation Chain](guides/test-automation.md) - playwright-setup → brownfield-test-engineer → test-verifier
- [New Feature Workflow](guides/new-feature-workflow.md) - Idea to PR in 6 stages
- [Code Review](guides/code-review.md) - Standard 5-axis and Deep 9-axis review
- [Security Review](guides/security-review.md) - OWASP audit and STRIDE threat modeling

### 📚 Hướng Dẫn Tính Năng (Tiếng Việt)
- [Brownfield Intelligence](vi/brownfield.md) - Onboard và điều tra codebases hiện có
- [Test Automation Chain](vi/test-automation.md) - Chuỗi 3 agent kiểm thử tự động
- [New Feature Workflow](vi/new-feature-workflow.md) - Từ ý tưởng đến PR trong 6 giai đoạn
- [Code Review](vi/code-review.md) - Review 5-axis và 9-axis chuyên sâu
- [Security Review](vi/security-review.md) - OWASP audit và STRIDE threat modeling

### 📝 Feature Documentation
- [TDD Auto-Retry](TDD-AUTO-RETRY.md) - Automated test failure capture and retry
- [Token Summarization](TOKEN-SUMMARIZATION.md) - Intelligent token management
- [Knowledge Persistence](KNOWLEDGE-PERSISTENCE.md) - Project convention learning

### 🇯🇵 Japanese Outsourcing (v3.5.0)
- `skills/foundation/basic-design/` — 基本設計 skill
- `skills/foundation/detailed-design/` — 詳細設計 skill
- `skills/quality/uat-process/` — 受け入れテスト skill
- `skills/workflow/progress-reporting/` — 進捗報告 skill
- `protocols/change-management.md` — Change management protocol
- `protocols/review-gates.md` — Phase gate sign-off protocol
- `workflows/japanese-outsourcing.md` — Master outsourcing workflow

### 🔍 Architect/Code/Review Quality Upgrade (v5.3.0)
- Code-review diff scan runs **first** in all VERIFY stages (before test suite) — review fixes validated by tests
- `workflows/new-feature.md` · `workflows/bug-fix.md` · `workflows/six-phase-lifecycle.md` · `workflows/greenfield-app.md` · `workflows/refactoring.md` · `workflows/distributed-development.md`
- `architect` agent v2.1.0 — mandatory ADR generation (Phase 7), existing architecture snapshot (Phase 0)
- `spec-driven-development` v3.1.0 — testability hard gate (⛔), conflict detection (Phase 1.5), Assumption Approval Gate
- `code-review` v3.1.0 — diff classification (Step 1.5), cross-file impact scan (Step 4.5)

### 🐙 GitHub Management Suite (v3.7.0)
- `skills/workflow/github-cicd-setup/` — Auto-generate CI/CD workflows
- `skills/workflow/github-pr-manager/` — PR creation + review fix
- `skills/workflow/github-issue-manager/` — Issue lifecycle + sprint planning
- `skills/workflow/github-release-manager/` — Release management

### 🏗️ Architecture Intelligence (v3.6.0)
- `skills/development/codebase-architecture/` — Pattern research + rule generation skill

### 🧪 Testing
- [Test Suite](tests/README.md) - Test documentation and results

---

## 🎯 Quick Links

### For Beginners
1. Read [Quick Start Guide](guides/getting-started.md)
2. Try [Usage Guide Examples](guides/usage-guide.md#examples)
3. Explore [Available Skills](skills/overview.md)

### For Advanced Users
1. Review [Distributed System Architecture](architecture/distributed-system.md)
2. Set up [Distributed Orchestration](guides/usage-guide.md#distributed-mode)
3. Configure [Custom Agents](agents/overview.md)

---

## 🌍 Language Support

Documentation is available in:
- 🇬🇧 **English** - See [guides/](guides/) directory
- 🇻🇳 **Tiếng Việt** - See [vi/](vi/) directory

---

## 🔗 External Resources

- [Main README](../README.md) - Project overview
- [GitHub Repository](https://github.com/nv-minh/Engineer-team) - Source code
- [CLAUDE.md](../CLAUDE.md) - System configuration (read by Claude Code)

---

## 📞 Support

Need help?

- 📖 Read the [Usage Guide](guides/usage-guide.md)
- 🐛 Check [GitHub Issues](https://github.com/nv-minh/Engineer-team/issues)

---

**Last Updated:** 2026-05-27
**Documentation Version:** 5.5.0

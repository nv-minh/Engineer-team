# EM-Skill - Hướng Dẫn Sử Dụng / Usage Guide

## 🌐 Language / Ngôn ngữ

- 🇬🇧 **[English Guide](docs/guides/usage-guide.md)** - Comprehensive English documentation
- 🇻🇳 **[Hướng Dẫn Tiếng Việt](docs/vi/huong-dan-su-dung.md)** - Tài liệu tiếng Việt đầy đủ

---

## 📖 Quick Links / Liên kết Nhanh

### Getting Started / Bắt đầu
- [Quick Start Guide](docs/guides/getting-started.md) - Bắt đầu trong 5 phút
- [Architecture Overview](docs/architecture/distributed-system.md) - Kiến trúc hệ thống
- [Usage Guide (EN)](docs/guides/usage-guide.md) - Hướng dẫn sử dụng tiếng Anh
- [Hướng Dẫn (VI)](docs/vi/huong-dan-su-dung.md) - Hướng dẫn tiếng Việt

### Documentation Hub / Trung tâm Tài liệu
- [Documentation Index](docs/README.md) - Chỉ mục tài liệu đầy đủ
- [Skills Reference](docs/skills/overview.md) - Tham chiếu Skills
- [Agents Reference](docs/agents/overview.md) - Tham chiếu Agents  
- [Workflows Catalog](docs/workflows/overview.md) - Danh mục Workflows

### Protocols / Giao thức
- [Messaging Protocol](docs/protocols/messaging.md) - Giao thức nhắn tin giữa agents
- [Report Format](docs/protocols/report-format.md) - Định dạng báo cáo chuẩn

### Testing / Kiểm thử
- [Test Suite](tests/README.md) - Bộ kiểm thử toàn diện
- [Manual Testing](tests/manual-test-with-agents.md) - Hướng dẫn kiểm thử thủ công

---

## 🚀 Quick Start / Bắt đầu Nhanh

### English / Tiếng Anh

```bash
# 1. Using Skills
"Use the brainstorming skill to explore feature ideas"

# 2. Using Agents  
"Agent: em-planner - Create implementation plan for authentication"

# 3. Using Workflows
"Workflow: em-new-feature - Implement user authentication"

# 4. Distributed Mode
./scripts/distributed-orchestrator.sh start
"Agent: em-techlead-orchestrator - Investigate authentication bug"
```

### Tiếng Việt

```bash
# 1. Sử dụng Skills
"Sử dụng brainstorming skill để khám phá ý tưởng feature"

# 2. Sử dụng Agents
"Agent: em-planner - Tạo kế hoạch triển khai cho authentication"

# 3. Sử dụng Workflows
"Workflow: em-new-feature - Triển khai user authentication"

# 4. Chế độ Phân tán
./scripts/distributed-orchestrator.sh start
"Agent: em-techlead-orchestrator - Điều tra bug authentication"
```

---

## 📚 Documentation Structure / Cấu trúc Tài liệu

```
docs/
├── README.md                      # Documentation hub
├── guides/                        # Hướng dẫn sử dụng
│   ├── getting-started.md         # Quick start guide
│   ├── usage-guide.md             # Comprehensive usage (EN)
│   └── huong-dan-su-dung.md       # Hướng dẫn chi tiết (VI)
├── architecture/                  # Tài liệu kiến trúc
│   └── distributed-system.md      # Distributed system architecture
├── protocols/                     # Giao thức và format
│   ├── messaging.md               # Inter-agent messaging protocol
│   └── report-format.md           # Agent report structure
├── skills/                        # Skills documentation
│   └── overview.md                # Complete skills reference
├── agents/                        # Agents documentation
│   └── overview.md                # Complete agents reference
├── workflows/                     # Workflows documentation
│   └── overview.md                # Complete workflows catalog
└── vi/                            # Tiếng Việt
    └── huong-dan-su-dung.md       # Hướng dẫn sử dụng tiếng Việt
```

---

## 🎯 Choose Your Path / Chọn Đường Dẫn Của Bạn

### For Beginners / Cho Người Mới Bắt đầu

**English:**
1. 📖 Read [Quick Start Guide](docs/guides/getting-started.md) - Get started in 5 minutes
2. 🎯 Try [Basic Examples](docs/guides/usage-guide.md#examples) - Learn by doing
3. 📚 Explore [Available Skills](docs/skills/overview.md) - See what's available

**Tiếng Việt:**
1. 📖 Đọc [Hướng dẫn Bắt đầu](docs/guides/getting-started.md) - Bắt đầu trong 5 phút
2. 🎯 Thử [Ví dụ cơ bản](docs/vi/huong-dan-su-dung.md#ví-dụ) - Học qua thực hành
3. 📚 Khám phá [Skills có sẵn](docs/skills/overview.md) - Xem những gì có sẵn

### For Advanced Users / Cho Người dùng Nâng cao

**English:**
1. 🏗️ Review [Distributed System Architecture](docs/architecture/distributed-system.md)
2. ⚙️ Set up [Distributed Orchestration](docs/guides/usage-guide.md#distributed-mode)
3. 🔧 Configure [Custom Agents](docs/agents/overview.md#custom-agents)

**Tiếng Việt:**
1. 🏗️ Xem [Kiến trúc Hệ thống Phân tán](docs/architecture/distributed-system.md)
2. ⚙️ Thiết lập [Orchestration Phân tán](docs/vi/huong-dan-su-dung.md#chế-độ-phân-tán)
3. 🔧 Cấu hình [Agents Tùy chỉnh](docs/agents/overview.md#custom-agents)

---

## 🧪 Test the System / Kiểm thử Hệ thống

```bash
# Run all E2E tests / Chạy tất cả E2E tests
cd tests
./run-e2e-tests.sh

# Expected output / Kết quả mong đợi:
# Total Tests: 8
# Passed: 8  
# Failed: 0
# All tests passed! ✅
```

---

## 📞 Get Help / Nhận Hỗ trợ

### English
- 📖 [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions
- 🐛 [GitHub Issues](https://github.com/nv-minh/agent-team/issues) - Report bugs
- 💬 [Discussions](https://github.com/nv-minh/agent-team/discussions) - Ask questions

### Tiếng Việt
- 📖 [Hướng dẫn Xử lý sự cố](docs/troubleshooting.md) - Vấn đề phổ biến và giải pháp
- 🐛 [GitHub Issues](https://github.com/nv-minh/agent-team/issues) - Báo cáo lỗi
- 💬 [Thảo luận](https://github.com/nv-minh/agent-team/discussions) - Đặt câu hỏi

---

## 🔗 Quick Reference / Tham Khảo Nhanh

### Commands / Lệnh

```bash
# Start distributed mode / Bắt đầu chế độ phân tán
./scripts/distributed-orchestrator.sh start

# List sessions / Liệt kê sessions
./scripts/session-manager.sh list

# Stop distributed mode / Dừng chế độ phân tán
./scripts/distributed-orchestrator.sh stop
```

### Documentation Index / Chỉ mục Tài liệu

- [Main README](README.md) - Tổng quan dự án
- [Documentation Hub](docs/README.md) - Trung tâm tài liệu
- [Architecture](docs/architecture/distributed-system.md) - Kiến trúc hệ thống
- [Protocols](docs/protocols/) - Giao thức
- [Skills](docs/skills/overview.md) - Skills tham chiếu
- [Agents](docs/agents/overview.md) - Agents tham chiếu
- [Workflows](docs/workflows/overview.md) - Workflows danh mục

---

## 🎓 Learning Path / Lộ trình Học tập

### Week 1: Beginner / Người mới bắt đầu
- ✅ Get started with basic skills
- ✅ Use standard agents (planner, code-reviewer)
- ✅ Try simple workflows
- ✅ Run your first distributed investigation

### Week 2: Intermediate / Trung cấp  
- ✅ Explore all available skills
- ✅ Use specialized agents
- ✅ Try distributed mode for complex tasks
- ✅ Review and understand agent reports

### Week 3+: Advanced / Nâng cao
- ✅ Create custom agents
- ✅ Design complex workflows
- ✅ Optimize distributed execution
- ✅ Contribute to the project

---

**Last Updated / Cập nhật lần cuối:** 2026-04-19  
**Version / Phiên bản:** 1.0.0  
**Languages / Ngôn ngữ:** 🇬🇧 English | 🇻🇳 Tiếng Việt

**Happy Coding! / Chúc bạn lập trình vui vẻ!** 🚀

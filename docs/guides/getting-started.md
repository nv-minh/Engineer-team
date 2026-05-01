# Quick Start Guide - EM-Team

Get up and running with EM-Team in 5 minutes.

---

## 🚀 Installation

### Prerequisites

- **tmux** - Terminal multiplexer for distributed mode
- **Bash** - Shell environment
- **Claude Code CLI** - AI coding assistant

### Setup

```bash
# Clone the repository
git clone https://github.com/nv-minh/agent-team.git
cd agent-team

# Verify installation
ls -la scripts/
ls -la agents/
ls -la workflows/

# Run tests to verify
cd tests
./run-e2e-tests.sh
```

---

## 📖 Basic Usage

### 1. Using Skills

Invoke skills directly in your workflow:

```bash
# Brainstorm a feature
"Use the brainstorming skill to explore user authentication"

# Create a spec
"Use the spec-driven-development skill to create a spec for auth"

# Debug systematically
"Use the systematic-debugging skill to investigate login bug"
```

### 1b. Communication Styles (NEW)

Control how Claude communicates with you:

```bash
# Show style menu (13 personality styles + 3 density modes)
/style

# Quick personality switching
/style tactical        # Direct debugging
/style teacher         # Feynman technique for explanations

# Quick density switching
/compact               # Bullet-point output
/terse                 # Single-line status
```

### 2. Using Agents

Dispatch agents for specialized tasks:

```bash
# Create implementation plan
"Agent: em-planner - Create plan for user authentication feature"

# Review code
"Agent: em-code-reviewer - Review the authentication PR"

# Debug issues
"Agent: em-debugger - Investigate the authentication failure"
```

### 3. Using Workflows

Run end-to-end processes:

```bash
# New feature workflow
"Workflow: em-new-feature - Implement user authentication"

# Bug fix workflow
"Workflow: em-bug-fix - Fix the login timeout bug"

# Security audit
"Workflow: em-security-audit - Audit authentication system"
```

---

## 🎯 Common Tasks

### Task 1: Building a New Feature

```bash
# Step 1: Explore the idea
"Use the brainstorming skill to explore a user profile feature"

# Step 2: Create specification
"Use the spec-driven-development skill to create a spec"

# Step 3: Plan implementation
"Agent: em-planner - Create implementation plan for user profile"

# Step 4: Implement
"Use the subagent-driven-development skill to implement the plan"

# Step 5: Review
"Agent: em-code-reviewer - Review the user profile implementation"

# Step 6: Deploy
"Workflow: em-deployment - Deploy user profile feature"
```

### Task 2: Fixing a Bug

```bash
# Step 1: Debug systematically
"Use the systematic-debugging skill to investigate the profile bug"

# Step 2: Fix the root cause
# (After root cause is identified)
"Use the test-driven-development skill to fix the bug"

# Step 3: Verify
"Use the api-testing skill to verify the fix"

# Step 4: Review
"Agent: em-code-reviewer - Review the bug fix"
```

### Task 3: Code Review

```bash
# Standard review
"Agent: em-code-reviewer - Review the changes in this PR"

# Deep 9-axis review
"Workflow: em-code-review-9axis - Deep review of authentication changes"

# Team review
"Workflow: em-team-review - Full team review of critical feature"
```

---

## 🏗️ Distributed Mode

For complex tasks requiring multiple specialist agents:

```bash
# Start distributed orchestration
./scripts/distributed-orchestrator.sh start

# Attach to orchestrator
tmux attach -t claude-work:orchestrator

# Trigger distributed investigation
"Agent: em-techlead-orchestrator - Investigate authentication across the stack"

# View consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# Stop when done
./scripts/distributed-orchestrator.sh stop
```

**When to use distributed mode:**
- ✅ Tasks requiring analysis across multiple domains
- ✅ Complex investigations needing specialist expertise
- ✅ Large context approaching token limits
- ✅ Need comprehensive audit trail

---

## 🧪 Testing

Verify your setup works correctly:

```bash
# Run all E2E tests
cd tests
./run-e2e-tests.sh

# Expected output:
# Total Tests: 8
# Passed: 8
# Failed: 0
# All tests passed!
```

---

## 📚 Next Steps

1. **Explore Skills** - Read [Skills Overview](../skills/overview.md)
2. **Learn Agents** - Check [Agent Reference](../agents/overview.md)
3. **Try Workflows** - See [Workflow Guide](../workflows/overview.md)
4. **Go Distributed** - Read [Distributed System Guide](../architecture/distributed-system.md)

---

## ❓ Troubleshooting

### Issue: Command not found

**Solution:**
```bash
# Verify files exist
ls -la scripts/distributed-orchestrator.sh
ls -la agents/planner.md

# Make scripts executable
chmod +x scripts/*.sh
chmod +x distributed/*.sh
```

### Issue: tmux not available

**Solution:**
```bash
# Install tmux
brew install tmux  # macOS
sudo apt install tmux  # Ubuntu/Debian
```

### Issue: Tests failing

**Solution:**
```bash
# Check test logs
cd tests
./run-e2e-tests.sh --verbose

# Run individual test
./test-distributed-orchestrator.sh
```

---

## 🎓 Learning Path

### Beginner (Week 1)
1. Read [README](../../README.md)
2. Try basic skill invocations
3. Use standard agents (planner, code-reviewer)
4. Run simple workflows

### Intermediate (Week 2)
1. Explore all available skills
2. Use specialized agents
3. Try distributed mode for simple tasks
4. Review agent reports

### Advanced (Week 3+)
1. Create custom agents
2. Design complex workflows
3. Optimize distributed execution
4. Contribute to the project

---

## 📞 Getting Help

- 📖 [Full Documentation](../README.md)
- 🐛 [Report Issues](https://github.com/nv-minh/agent-team/issues)
- 💬 [Community Discussions](https://github.com/nv-minh/agent-team/discussions)

---

**Ready to dive deeper?** Check out the [comprehensive usage guide](usage-guide.md)!

---

**Last Updated:** 2026-05-01
**Version:** 2.1.0

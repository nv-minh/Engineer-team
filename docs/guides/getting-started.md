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
git clone https://github.com/nv-minh/Engineer-team.git
cd agent-team

# Install
bash install.sh
```

### Post-Install: Enable Features

Add to `.claude/settings.local.json` in your **target project**:

```json
{
  "env": {
    "EM_TEAM_ARTIFACT_EXPORT": "true",
    "EM_TEAM_SESSION_AUDIT": "true",
    "EM_TEAM_ATOMIC_COMMITS": "true"
  }
}
```

Verify: `ls ~/.claude/commands/em-agent/*.md ~/.claude/commands/em-wf/*.md ~/.claude/commands/em-skill/*.md | wc -l` (should show 140+ files)

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
/em-skill:style-switcher

# Quick personality switching
/em-skill:style-switcher tactical        # Direct debugging
/em-skill:style-switcher teacher         # Feynman technique for explanations

# Quick density switching
/compact               # Bullet-point output
/terse                 # Single-line status
```

### 2. Using Agents

Dispatch agents for specialized tasks:

```bash
# Create implementation plan
"Agent: em-agent:planner - Create plan for user authentication feature"

# Review code
"Agent: em-agent:code-reviewer - Review the authentication PR"

# Debug issues
"Agent: em-agent:debugger - Investigate the authentication failure"
```

### 3. Using Workflows

Run end-to-end processes:

```bash
# New feature workflow
/em-wf:new-feature Implement user authentication

# Bug fix workflow
/em-wf:bug-fix Fix the login timeout bug

# Security audit
/em-wf:security-audit Audit authentication system
```

---

## 🎯 Common Tasks

### Task 1: Building a New App from Scratch

```bash
# Full greenfield workflow (blank directory → shipped app)
/em-wf:greenfield-app Build a task management app with teams and projects
# Runs: Ideation → Domain Modeling → Spec → Architecture → Bootstrap → Build → Verify → Review → Launch
```

### Task 2: Building a New Feature

```bash
# Step 1: Explore the idea
"Use the brainstorming skill to explore a user profile feature"

# Step 1.5: Domain modeling (optional, for cross-context features)
"Use the domain-modeling skill to map entities and bounded contexts"

# Step 2: Create specification
"Use the spec-driven-development skill to create a spec"

# Step 3: Plan implementation
"Agent: em-agent:planner - Create implementation plan for user profile"

# Step 4: Implement
"Use the subagent-driven-development skill to implement the plan"

# Step 5: Review
"Agent: em-agent:code-reviewer - Review the user profile implementation"

# Step 6: Deploy
"Workflow: em-deployment - Deploy user profile feature"
```

### Task 2b: Fixing a Bug

```bash
# Step 1: Debug systematically
"Use the systematic-debugging skill to investigate the profile bug"

# Step 2: Fix the root cause
# (After root cause is identified)
"Use the test-driven-development skill to fix the bug"

# Step 3: Verify
"Use the api-testing skill to verify the fix"

# Step 4: Review
"Agent: em-agent:code-reviewer - Review the bug fix"
```

### Task 2c: QA Bug Hunting *(v4.1.0)*

```bash
# Find bugs, review each one, create GitHub issues only after approval
/em-wf:qa-bug-hunter QA test http://localhost:5173 and log bugs

# Human Gate: for each bug found, you decide APPROVE/REJECT/MODIFY
```

### Task 2d: Brownfield Investigation *(v5.0.0)*

```bash
# Step 1: Onboard the existing codebase
"Use the brownfield-onboarding skill to analyze this legacy codebase"

# Step 2: Investigate architecture, tech debt, and improvement opportunities
/em-wf:brownfield-investigation Assess tech debt and create improvement roadmap

# Step 3: Sync context after making changes
"Use the brownfield-context-sync skill to refresh architecture map"
```

### Task 3: Code Review

```bash
# Standard 5-axis review
"Agent: em-agent:code-reviewer - Review the changes in this PR"

# Deep 9-axis review (for production-critical code)
"Agent: em-agent:code-reviewer - Deep review of authentication changes"

# Deep 9-axis workflow with security
/em-wf:code-review Deep review of authentication changes

# Team review
/em-wf:team-review Full team review of critical feature
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
"Agent: em-agent:techlead-orchestrator - Investigate authentication across the stack"

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
- 🐛 [Report Issues](https://github.com/nv-minh/Engineer-team/issues)
- 💬 [Community Discussions](https://github.com/nv-minh/Engineer-team/discussions)

---

**Ready to dive deeper?** Check out the [comprehensive usage guide](usage-guide.md)!

---

**Last Updated:** 2026-05-27
**Version:** 5.5.0

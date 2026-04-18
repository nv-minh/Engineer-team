# 📦 EM-Skill Installation Guide

Complete installation guide for EM-Skill - Fullstack Engineering Agent/Skill/Workflow System.

---

## 🚀 Quick Install (5 Minutes)

```bash
# 1. Clone repository
git clone https://github.com/nv-minh/agent-team.git
cd agent-team

# 2. Make scripts executable
chmod +x scripts/*.sh distributed/*.sh tests/*.sh

# 3. Run tests to verify
cd tests && ./run-e2e-tests.sh

# 4. Try distributed mode
./scripts/distributed-orchestrator.sh start
./scripts/session-manager.sh list
./scripts/distributed-orchestrator.sh stop
```

**Expected Output:** All 8 tests pass ✅

---

## 📋 Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| **Bash** | 4.0+ | Shell environment |
| **tmux** | Latest | Distributed mode |
| **Git** | Latest | Version control |
| **Claude Code CLI** | Latest | AI assistant |

### Check Prerequisites

```bash
# Check Bash
echo $BASH_VERSION
# Expected: 4.0+ or 5.0+

# Check tmux
tmux -V
# Expected: tmux 3.0+ or similar

# Check Git
git --version
# Expected: git version 2.x.x or similar

# Check Claude Code
claude --version
# Expected: Claude Code version info
```

---

## 🔧 Platform-Specific Installation

### macOS

#### Install Homebrew (if not installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Install Dependencies

```bash
# Install tmux
brew install tmux

# Verify installation
tmux -V

# Optional: Install Node.js
brew install node

# Optional: Install Python 3
brew install python@3.11
```

#### Clone and Setup

```bash
# Clone repository
git clone https://github.com/nv-minh/agent-team.git
cd agent-team

# Make scripts executable
chmod +x scripts/*.sh
chmod +x distributed/*.sh
chmod +x tests/*.sh

# Verify installation
ls -la scripts/
ls -la distributed/
ls -la agents/
ls -la workflows/
```

### Ubuntu/Debian

#### Update Package List

```bash
sudo apt update
```

#### Install Dependencies

```bash
# Install tmux and Git
sudo apt install -y tmux git

# Optional: Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Optional: Install Python 3.11
sudo apt install -y python3.11 python3-pip
```

#### Clone and Setup

```bash
# Clone repository
git clone https://github.com/nv-minh/agent-team.git
cd agent-team

# Make scripts executable
chmod +x scripts/*.sh
chmod +x distributed/*.sh
chmod +x tests/*.sh

# Verify installation
ls -la scripts/
ls -la distributed/
```

### Windows (WSL)

#### Install WSL 2

```powershell
# Open PowerShell as Administrator
wsl --install
```

#### Inside WSL (Ubuntu)

```bash
# Follow Ubuntu/Debian instructions above
sudo apt update
sudo apt install -y tmux git
```

#### Clone and Setup

```bash
# In WSL terminal
git clone https://github.com/nv-minh/agent-team.git
cd agent-team
chmod +x scripts/*.sh distributed/*.sh tests/*.sh
```

---

## ✅ Verification Steps

### 1. Check File Structure

```bash
# Verify all required files exist
ls -la scripts/distributed-orchestrator.sh
ls -la scripts/session-manager.sh
ls -la scripts/consolidate-reports.sh
ls -la distributed/session-coordinator.sh
ls -la distributed/session-sync.sh

# Expected: All files should exist and be executable (-rwxr-xr-x)
```

### 2. Run Test Suite

```bash
cd tests
./run-e2e-tests.sh
```

**Expected Output:**
```
==========================================
Distributed Orchestration E2E Tests
==========================================

[INFO] Setting up E2E test environment...
[SUCCESS] E2E environment created at: /tmp/em-skill-e2e-test-XXXXX

[TEST 1] E2E Test 1: Script Availability
[PASS] E2E Test 1: Script Availability

[TEST 2] E2E Test 2: Directory Structure
[PASS] E2E Test 2: Directory Structure

...

========================================
Test Summary
========================================
Total Tests: 8
Passed: 8
Failed: 0
All tests passed!
```

### 3. Test Distributed Mode

```bash
# Start distributed orchestration
./scripts/distributed-orchestrator.sh start
```

**Expected Output:**
```
[INFO] Starting distributed agent orchestration...
[SUCCESS] Directories initialized
[SUCCESS] Created session: claude-work
```

```bash
# List sessions
./scripts/session-manager.sh list
```

**Expected Output:**
```
[INFO] Active tmux sessions:

claude-work: 5 windows (created Sun Apr 19 XX:XX:XX 2026)

[INFO] Session details:
[SUCCESS] Session 'claude-work' is running

[INFO] Windows:
  0: orchestrator (active)
  1: backend
  2: frontend
  3: database
```

```bash
# Stop distributed mode
./scripts/distributed-orchestrator.sh stop
```

**Expected Output:**
```
[INFO] Stopping distributed orchestration...
[SUCCESS] Session 'claude-work' killed
```

---

## ⚙️ Configuration

### Optional Environment Variables

Add to your shell configuration (`~/.bashrc` or `~/.zshrc`):

```bash
# EM-Skill Configuration
export EM_SKILL_HOME="$HOME/agent-team"
export PATH="$PATH:$EM_SKILL_HOME/scripts"
export PATH="$PATH:$EM_SKILL_HOME/distributed"

# Optional: Aliases for convenience
alias em-start="$EM_SKILL_HOME/scripts/distributed-orchestrator.sh start"
alias em-stop="$EM_SKILL_HOME/scripts/distributed-orchestrator.sh stop"
alias em-status="$EM_SKILL_HOME/scripts/session-manager.sh list"
```

### Reload Configuration

```bash
# For Bash
source ~/.bashrc

# For Zsh
source ~/.zshrc
```

---

## 🧪 Testing Installation

### Run All Tests

```bash
cd tests
./run-e2e-tests.sh
```

### Run Individual Test Suites

```bash
# Unit tests
./test-distributed-orchestrator.sh
./test-session-manager.sh
./test-consolidate-reports.sh
./test-session-coordinator.sh

# Integration tests
./test-messaging-protocol.sh
./test-report-consolidation.sh
```

### Manual Testing

Follow the manual testing guide:
```bash
cat tests/manual-test-with-agents.md
```

---

## ❓ Troubleshooting

### Issue: "command not found: tmux"

**Symptom:**
```bash
tmux: command not found
```

**Solution:**
```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt install tmux

# Verify
tmux -V
```

---

### Issue: "Permission denied: ./script.sh"

**Symptom:**
```bash
bash: ./script.sh: Permission denied
```

**Solution:**
```bash
# Make all scripts executable
chmod +x scripts/*.sh
chmod +x distributed/*.sh
chmod +x tests/*.sh

# Verify
ls -la scripts/*.sh
# Should show: -rwxr-xr-x
```

---

### Issue: "Tests failing"

**Symptom:**
```bash
Total Tests: 8
Passed: 5
Failed: 3
```

**Solution:**
```bash
# Run with verbose output
cd tests
./run-e2e-tests.sh --verbose

# Check test logs
ls -la /tmp/em-skill-test-*

# Run individual failing test
./test-distributed-orchestrator.sh

# Check environment
echo $SHELL  # Should be /bin/bash or /bin/zsh
which tmux
```

---

### Issue: "Distributed mode won't start"

**Symptom:**
```bash
[ERROR] Session 'claude-work' already exists
```

**Solution:**
```bash
# Kill existing tmux sessions
tmux kill-server

# Remove old temporary directories
rm -rf /tmp/claude-work-*

# Try again
./scripts/distributed-orchestrator.sh start
```

---

### Issue: "Claude Code not found"

**Symptom:**
```bash
claude: command not found
```

**Solution:**
```bash
# Install Claude Code CLI
# Visit: https://claude.ai/download

# Or use with npm
npm install -g @anthropic-ai/claude-code
```

---

## 🔄 Update EM-Skill

### Check for Updates

```bash
cd agent-team
git fetch origin
git log HEAD..origin/main --oneline
```

### Update to Latest Version

```bash
# Pull latest changes
git pull origin main

# Run tests to verify
cd tests && ./run-e2e-tests.sh

# Check documentation
cat docs/README.md
```

---

## 🗑️ Uninstall

### Remove Repository

```bash
# Remove repository directory
rm -rf ~/agent-team

# Or if installed in different location
rm -rf /path/to/agent-team
```

### Remove Configuration

```bash
# Edit ~/.bashrc or ~/.zshrc
# Remove lines containing EM_SKILL_HOME

# Example lines to remove:
# export EM_SKILL_HOME="$HOME/agent-team"
# export PATH="$PATH:$EM_SKILL_HOME/scripts"
```

### Clean Up Temporary Files

```bash
# Remove temporary directories
rm -rf /tmp/claude-work-*
rm -rf /tmp/em-skill-test-*

# Kill any remaining tmux sessions
tmux kill-server
```

---

## 📚 Next Steps

After successful installation:

1. ✅ **Read Quick Start Guide**
   ```bash
   cat docs/guides/getting-started.md
   ```

2. ✅ **Explore Documentation**
   ```bash
   cat docs/README.md
   ```

3. ✅ **Try Basic Usage**
   ```bash
   # Use a skill
   "Use the brainstorming skill to explore authentication"

   # Use an agent
   "Agent: em-planner - Create plan for authentication"

   # Use a workflow
   "Workflow: em-new-feature - Implement authentication"
   ```

4. ✅ **Try Distributed Mode**
   ```bash
   ./scripts/distributed-orchestrator.sh start
   tmux attach -t claude-work:orchestrator
   "Agent: em-techlead-orchestrator - Investigate authentication bug"
   ```

5. ✅ **Read Comprehensive Guides**
   - English: [docs/guides/usage-guide.md](docs/guides/usage-guide.md)
   - Vietnamese: [docs/vi/huong-dan-su-dung.md](docs/vi/huong-dan-su-dung.md)

---

## 💡 Tips

### Tip 1: Always Run Tests First

Before using EM-Skill for important tasks:
```bash
cd tests && ./run-e2e-tests.sh
```

### Tip 2: Start Simple

Begin with basic skills and agents before trying distributed mode.

### Tip 3: Read Documentation

EM-Skill has comprehensive documentation. Read it to get the most out of the system.

### Tip 4: Use Bilingual Support

If English is not your first language, check out the Vietnamese documentation.

### Tip 5: Ask for Help

If you encounter issues:
- Check [Troubleshooting](#-troubleshooting)
- Read [docs/README.md](docs/README.md)
- Visit [GitHub Issues](https://github.com/nv-minh/agent-team/issues)

---

## ✅ Installation Checklist

Use this checklist to verify your installation:

- [ ] Prerequisites installed (tmux, Git, Bash, Claude Code)
- [ ] Repository cloned successfully
- [ ] Scripts made executable
- [ ] File structure verified
- [ ] E2E tests pass (8/8)
- [ ] Distributed mode starts successfully
- [ ] Session manager works
- [ ] Can invoke skills
- [ ] Can invoke agents
- [ ] Can invoke workflows
- [ ] Documentation accessible

**All checked? Installation complete!** ✅

---

## 🎯 Getting Help

### Documentation
- 📖 [Main Documentation](docs/README.md)
- 🚀 [Quick Start Guide](docs/guides/getting-started.md)
- 📚 [Usage Guide (EN)](docs/guides/usage-guide.md)
- 📚 [Hướng Dẫn (VI)](docs/vi/huong-dan-su-dung.md)

### Support
- 🐛 [GitHub Issues](https://github.com/nv-minh/agent-team/issues)
- 💬 [Discussions](https://github.com/nv-minh/agent-team/discussions)
- 📧 [Email Support](mailto:support@agent-team.com)

---

**Installation Version:** 1.0.0
**Last Updated:** 2026-04-19
**Status:** ✅ Ready for Production

**Happy coding with EM-Skill!** 🚀

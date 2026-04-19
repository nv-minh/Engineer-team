# EM-Skill Command Usage - IMPORTANT

**Date:** 2026-04-19
**Version:** 1.1.0

---

## ⚠️ CRITICAL: How to View Commands

### ❌ WRONG - Don't Use This
```bash
/em
/em-
```
**Why:** The `/` prefix tells shell to complete filenames, not commands.

### ✅ CORRECT - Use This Instead
```bash
em-          # No / at the beginning!
em-show
em-commands
em-list
em-help
```

---

## 📝 Quick Start

### Step 1: Reload Your Shell
```bash
exec zsh
```

### Step 2: View All Commands
```bash
em-          # Type this and press Enter
```

**That's it!** You'll see all 65+ commands.

---

## 🎯 What You'll See

When you type `em-` and press Enter, you'll see:

### 📚 Skills (25 commands)
Use directly in Claude Code:
- `/brainstorming` - Explore ideas
- `/spec-driven-dev` - Create specifications
- `/systematic-debugging` - Debug systematically
- ... and 22 more skills

### 🤖 Agents (22 commands) ⭐
Use directly in Claude Code:
- `/em-planner` - Create plans
- `/em-code-reviewer` - Review code
- `/em-debugger` - Debug issues
- `/em-backend-expert` ⭐ - Backend specialist
- `/em-frontend-expert` ⭐ - Frontend specialist
- `/em-database-expert` ⭐ - Database specialist
- `/em-performance-auditor` ⭐ - Performance specialist
- `/em-techlead-orchestrator` ⭐ - Distributed investigation
- ... and 14 more agents

### 🔄 Workflows (18 commands)
Use directly in Claude Code:
- `/em-new-feature` - From idea to production
- `/em-bug-fix` - Fix bugs systematically
- `/em-distributed-investigation` ⭐ - Parallel investigation
- ... and 16 more workflows

---

## 💬 How to Use in Claude Code

### Example 1: Backend Expert
```
User: /em-backend-expert Review the API performance
Claude: [Activates backend-expert agent and reviews API]
```

### Example 2: Frontend Expert
```
User: /em-frontend-expert Review these React components
Claude: [Activates frontend-expert agent and reviews components]
```

### Example 3: Database Expert
```
User: /em-database-expert Optimize these database queries
Claude: [Activates database-expert agent and optimizes queries]
```

### Example 4: Distributed Investigation
```
User: /em-techlead-orchestrator Investigate this bug across full stack
Claude: [Activates orchestrator and coordinates parallel investigation]
```

---

## 🔧 Why This Change?

### Problem
When typing `/em`, the shell tries to complete filenames starting with `/em`, not EM-Skill commands.

### Solution
Type `em-` (without `/`) instead. This is treated as an alias/command, not a filename.

---

## 📋 Available Aliases

All of these do the same thing - show all commands:
```bash
em-           # Shortest
em-show       # Most descriptive
em-commands   # Clear purpose
em-list       # Alternative
em-help       # Help-related
```

---

## 🌟 Key Commands to Remember

### To View All Commands
```bash
em-           # Just type "em-" and press Enter
```

### To Use Skills (in Claude Code)
```bash
/brainstorming [your request]
/spec-driven-dev [your requirement]
```

### To Use Agents (in Claude Code)
```bash
/em-backend-expert [your request]
/em-frontend-expert [your request]
/em-database-expert [your request]
```

### To Use Workflows (in Claude Code)
```bash
/em-new-feature [your feature description]
/em-bug-fix [your bug description]
```

---

## ✅ Verification

### Test It Works
```bash
# Reload shell
exec zsh

# Type this
em-

# You should see a list of 65+ commands
```

### If It Doesn't Work
```bash
# Check if the script exists
ls -la ~/.claude/em-show-commands

# Check if alias exists
alias em-

# Manual test
~/.claude/em-show-commands
```

---

## 📁 Files

### Created
1. `~/.claude/em-show-commands` - Executable script
2. `~/.zshrc` - Updated with aliases

### Updated
1. `.claude/commands/em-show.sh` - Display script

---

## 🎉 Summary

### Don't
❌ Type `/em` in terminal
❌ Type `/em-` in terminal

### Do
✅ Reload shell: `exec zsh`
✅ Type `em-` in terminal
✅ Use commands in Claude Code: `/em-backend-expert ...`

---

**Status:** ✅ Ready to use
**Date:** 2026-04-19
**Version:** 1.1.0

**Remember: Type `em-` (no slash) to see all commands!** 🚀

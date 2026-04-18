# EM-Skill Agents & Workflows - Global Registration Complete

**Date:** 2026-04-19
**Status:** ✅ FULLY REGISTERED

---

## 🎯 What's Been Registered

### ✅ Skills (25+ skills)
- Already visible in system reminder
- Registered in `~/.claude/skills.json`
- **Location:** `~/.claude/skills/`

### ✅ Agents (22 agents) - NEW!
- Symlinks created in `~/.claude/agents/`
- `~/.claude/agents.json` created
- **Location:** `~/.claude/agents/`

### ✅ Workflows (18 workflows) - NEW!
- Symlinks created in `~/.claude/workflows/`
- `~/.claude/workflows.json` created
- **Location:** `~/.claude/workflows/`

---

## 📋 Complete List of Agents

### Core Agents (8 agents)
1. **planner** - Creates detailed implementation plans
   ```
   Agent: planner - Create implementation plan for feature X
   ```

2. **executor** - Executes plans with atomic commits
   ```
   Agent: executor - Execute the implementation plan
   ```

3. **code-reviewer** - 5-axis code review
   ```
   Agent: code-reviewer - Review the changes in this PR
   ```

4. **debugger** - Systematic debugging
   ```
   Agent: debugger - Investigate this bug systematically
   ```

5. **test-engineer** - Test strategy & generation
   ```
   Agent: test-engineer - Create test strategy for X
   ```

6. **security-auditor** - OWASP security audit
   ```
   Agent: security-auditor - Audit the security of X
   ```

7. **ui-auditor** - Visual QA and design review
   ```
   Agent: ui-auditor - Review the UI design
   ```

8. **verifier** - Post-execution verification
   ```
   Agent: verifier - Verify the implementation
   ```

### Specialized Agents (14 agents)
9. **architect** - Architecture & technical design
10. **backend-expert** - Database, API, performance
11. **frontend-expert** - React/Next.js, UI/UX, performance
12. **database-expert** - Schema, queries, fintech patterns
13. **product-manager** - Requirements, GAP analysis
14. **senior-code-reviewer** - 9-axis deep code review
15. **security-reviewer** - OWASP + STRIDE security
16. **staff-engineer** - Root cause analysis
17. **team-lead** - Orchestrator for team reviews
18. **techlead-orchestrator** - Distributed investigation coordinator
19. **researcher** - Technical exploration and research
20. **codebase-mapper** - Architecture analysis and documentation
21. **integration-checker** - Cross-phase validation
22. **performance-auditor** - Benchmarking and optimization

---

## 🔄 Complete List of Workflows

### Primary Workflows (4 workflows)
1. **new-feature** - From idea to production
   ```
   Workflow: new-feature - Implement feature X
   ```

2. **bug-fix** - Investigate and fix bugs
   ```
   Workflow: bug-fix - Fix bug X systematically
   ```

3. **refactoring** - Improve code quality
   ```
   Workflow: refactoring - Refactor module X
   ```

4. **security-audit** - Security assessment
   ```
   Workflow: security-audit - Audit system X
   ```

### Support Workflows (4 workflows)
5. **project-setup** - Initialize new projects
6. **documentation** - Generate and update docs
7. **deployment** - Deploy and monitor features
8. **retro** - Learn and improve from completed work

### Team Workflows (8 workflows)
9. **team-review** - Full team review
10. **architecture-review** - Architecture review
11. **design-review** - UI/UX review
12. **code-review-9axis** - Deep 9-axis code review
13. **database-review** - Database schema & query review
14. **product-review** - Product/spec review
15. **security-review-advanced** - Advanced security (OWASP + STRIDE)
16. **incident-response** - Production incident handling

### Distributed Workflows (2 workflows)
17. **distributed-investigation** - Parallel bug investigation
18. **distributed-development** - Parallel feature development

---

## 💬 How to Use

### Using Agents
```
Agent: [agent-name] - [task description]

Examples:
"Agent: planner - Create implementation plan for JWT authentication"
"Agent: code-reviewer - Review the changes in PR #123"
"Agent: debugger - Investigate the login timeout bug"
"Agent: security-auditor - Audit the payment system"
"Agent: frontend-expert - Review the React components"
```

### Using Workflows
```
Workflow: [workflow-name] - [task description]

Examples:
"Workflow: new-feature - Implement user authentication"
"Workflow: bug-fix - Fix the database connection bug"
"Workflow: security-audit - Audit the entire application"
"Workflow: distributed-investigation - Investigate authentication across full stack"
```

### Distributed Mode (Advanced)
```bash
# Start distributed orchestration
em-start  # or: ./scripts/distributed-orchestrator.sh start

# Use distributed workflow
"Agent: techlead-orchestrator - Investigate authentication bug"
# Backend, frontend, database agents work in parallel

# View consolidated report
cat /tmp/claude-work-reports/techlead/consolidated-report.md

# Stop distributed mode
em-stop  # or: ./scripts/distributed-orchestrator.sh stop
```

---

## 🔧 Installation Verification

### Check Files Exist
```bash
# Skills
ls ~/.claude/skills/em-skill/SKILL.md
cat ~/.claude/skills.json | grep -c "\"description\""  # Should be 25+

# Agents
ls ~/.claude/agents/planner.md
cat ~/.claude/agents.json | grep -c "\"description\""  # Should be 22

# Workflows
ls ~/.claude/workflows/new-feature.md
cat ~/.claude/workflows.json | grep -c "\"description\""  # Should be 18
```

### Verify in System Reminder
When you open a new conversation, you should see:
```
The following skills are available for use:

- em-skill: EM-Skill - Fullstack Engineering System...
- planner: Creates detailed implementation plans...
- code-reviewer: Performs 5-axis code review...
- [All other agents and workflows]
```

---

## 📚 Quick Reference

### For Planning
```
Agent: planner - Create implementation plan
Skill: writing-plans - Write comprehensive plans
Workflow: new-feature - From idea to production
```

### For Implementation
```
Agent: executor - Execute implementation plan
Skill: test-driven-development - Implement with TDD
Skill: incremental-implementation - Build incrementally
```

### For Quality
```
Agent: code-reviewer - Review code changes
Agent: security-auditor - Audit security
Skill: code-review - 5-axis review framework
Workflow: code-review-9axis - Deep review
```

### For Debugging
```
Agent: debugger - Investigate bugs
Skill: systematic-debugging - Root cause debugging
Workflow: bug-fix - Fix bugs systematically
```

### For Complex Tasks
```
Agent: techlead-orchestrator - Coordinate distributed investigation
Workflow: distributed-investigation - Parallel investigation
Workflow: distributed-development - Parallel development
```

---

## ✅ Success Criteria

- [x] 25+ skills registered and visible
- [x] 22 agents registered with symlinks
- [x] 18 workflows registered with symlinks
- [x] `~/.claude/skills.json` created
- [x] `~/.claude/agents.json` created
- [x] `~/.claude/workflows.json` created
- [x] All components globally accessible
- [x] Can be used from ANY repository

---

## 🎉 Next Steps

1. **Reload Claude Code** or start a new conversation
2. **Test from any repository:**
   ```
   Agent: planner - Create plan
   Workflow: new-feature - Implement feature
   ```
3. **Check system reminder** - all agents and workflows should be visible

---

**Status:** ✅ ALL COMPONENTS GLOBALLY REGISTERED
**Date:** 2026-04-19
**Version:** 1.1.0

**EM-Skill is now fully available with 25+ skills, 22 agents, and 18 workflows from ANY repository!** 🚀

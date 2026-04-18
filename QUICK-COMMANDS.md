# EM-Skill Quick Commands Reference

**Type `/` followed by command name for quick access!**

---

## 🚀 Quick Start

```bash
# Show all commands
/          # or: em-commands

# Skills
/brainstorming [idea]
/spec-driven-dev [requirement]
/systematic-debugging [bug]
/test-driven-dev [feature]

# Agents
/planner [task]
/code-reviewer [PR]
/debugger [issue]
/security-auditor [system]

# Workflows
/new-feature [feature]
/bug-fix [bug]
/security-audit [system]
```

---

## 📚 Complete Command List

### Skills (25 commands)

**Foundation (5):**
```bash
/brainstorming          Explore ideas into designs
/spec-driven-dev        Create specifications
/systematic-debugging   Debug with scientific method
/context-engineering    Optimize agent context
/writing-plans          Write implementation plans
```

**Development (8):**
```bash
/test-driven-dev        TDD RED-GREEN-REFACTOR
/frontend-patterns      React/Next.js/Vue patterns
/backend-patterns       API/Database patterns
/security-hardening      OWASP Top 10
/incremental-impl        Vertical slice development
/subagent-dev           Fresh context per task
/source-driven-dev       Code from official docs
/api-interface-design    Contract-first APIs
```

**Quality (7):**
```bash
/code-review            5-axis code review
/code-simplification     Reduce complexity
/browser-testing         DevTools MCP
/performance-optimization Measure-first optimization
/e2e-testing            Playwright testing
/security-audit          Vulnerability assessment
/api-testing            Integration testing
```

**Workflow (5):**
```bash
/git-workflow           Atomic commits
/ci-cd-automation        Feature flags
/documentation          ADRs & docs
/finishing-branch       Merge/PR decisions
/deprecation-migration   Code-as-liability
```

### Agents (22 commands)

**Core (8):**
```bash
/planner              Create plans
/executor             Execute plans
/code-reviewer        Review code
/debugger             Debug issues
/test-engineer        Test strategy
/security-auditor     Security audit
/ui-auditor           UI review
/verifier             Verify delivery
```

**Specialized (14):**
```bash
/architect            Architecture design
/backend-expert       Database, API
/frontend-expert      React, UI/UX
/database-expert      Schema, queries
/product-manager      Requirements
/senior-code-reviewer 9-axis review
/security-reviewer    OWASP + STRIDE
/staff-engineer       Root cause analysis
/team-lead            Team coordination
/techlead-orchestrator Distributed investigation
/researcher           Technical research
/codebase-mapper       Architecture analysis
/integration-checker  Cross-phase validation
/performance-auditor   Benchmarking
```

### Workflows (18 commands)

**Primary (4):**
```bash
/new-feature           Idea → Production
/bug-fix               Fix bugs systematically
/refactoring           Improve code quality
/security-audit         Security assessment
```

**Support (4):**
```bash
/project-setup         Initialize projects
/documentation         Generate docs
/deployment            Deploy features
/retro                 Learn & improve
```

**Team (8):**
```bash
/team-review           Full team review
/architecture-review    Architecture review
/design-review         UI/UX review
/code-review-9axis     Deep review
/database-review       Database review
/product-review        Product review
/security-review-advanced Advanced security
/incident-response     Production incidents
```

**Distributed (2):**
```bash
/distributed-investigation  Parallel investigation
/distributed-development     Parallel development
```

---

## 💬 Usage Examples

```bash
# Example 1: Brainstorming
/brainstorming User authentication with JWT

# Example 2: Planning
/planner Create implementation plan for shopping cart

# Example 3: Code Review
/code-reviewer Review PR #123

# Example 4: Debugging
/debugger Investigate login timeout bug

# Example 5: Full Workflow
/new-feature Implement user profile from idea to production

# Example 6: Security Audit
/security-audit Audit payment system

# Example 7: Distributed Investigation
/distributed-investigation Investigate database performance issue
```

---

## 🌐 Helper Commands

```bash
# Distributed Mode
em-start    # Start distributed mode
em-stop     # Stop distributed mode
em-status   # Check status
em-test     # Run E2E tests

# Show Commands
/          # Show all EM-Skill commands
em-commands # Same as above
```

---

## ⚙️ Installation

The completion script is already installed!

To reload:
```bash
source ~/.zshrc
# or
source ~/.bashrc
```

To test:
```bash
# Type these and press TAB
/brainstorming
/planner
/new-feature
```

---

## 🎯 Tips

1. **Type `/`** to see all available commands
2. **Use TAB** for autocomplete
3. **Commands work from ANY repository**
4. **Combine with text** for full requests
5. **Use em-commands** to see full list

---

**That's it! Type `/` + command name to use EM-Skill quickly!** ⚡

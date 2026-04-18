# EM-Skill Quick Commands Reference

**Type `/` followed by command name for quick access!**

---

## 🚀 Quick Start

```bash
# Show all commands
/          # or: em-commands

# Skills (no prefix needed)
/brainstorming [idea]
/spec-driven-dev [requirement]
/systematic-debugging [bug]
/test-driven-dev [feature]

# Agents (with em- prefix)
/em-planner [task]
/em-code-reviewer [PR]
/em-debugger [issue]
/em-security-auditor [system]

# Workflows (with em- prefix)
/em-new-feature [feature]
/em-bug-fix [bug]
/em-security-audit [system]
```

---

## 📚 Complete Command List

### Skills (25 commands) - No prefix needed

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

### Agents (22 commands) - With `em-` prefix

**Core (8):**
```bash
/em-planner              Create plans
/em-executor             Execute plans
/em-code-reviewer        Review code
/em-debugger             Debug issues
/em-test-engineer        Test strategy
/em-security-auditor     Security audit
/em-ui-auditor           UI review
/em-verifier             Verify delivery
```

**Specialized (14):**
```bash
/em-architect            Architecture design
/em-backend-expert       Database, API
/em-frontend-expert      React, UI/UX
/em-database-expert      Schema, queries
/em-product-manager      Requirements
/em-senior-code-reviewer 9-axis review
/em-security-reviewer    OWASP + STRIDE
/em-staff-engineer       Root cause analysis
/em-team-lead            Team coordination
/em-techlead-orchestrator Distributed investigation
/em-researcher           Technical research
/em-codebase-mapper       Architecture analysis
/em-integration-checker  Cross-phase validation
/em-performance-auditor   Benchmarking
```

### Workflows (18 commands) - With `em-` prefix

**Primary (4):**
```bash
/em-new-feature           Idea → Production
/em-bug-fix               Fix bugs systematically
/em-refactoring           Improve code quality
/em-security-audit         Security assessment
```

**Support (4):**
```bash
/em-project-setup         Initialize projects
/em-documentation         Generate docs
/em-deployment            Deploy features
/em-retro                 Learn & improve
```

**Team (8):**
```bash
/em-team-review           Full team review
/em-architecture-review    Architecture review
/em-design-review         UI/UX review
/em-code-review-9axis     Deep review
/em-database-review       Database review
/em-product-review        Product review
/em-security-review-advanced Advanced security
/em-incident-response     Production incidents
```

**Distributed (2):**
```bash
/em-distributed-investigation  Parallel investigation
/em-distributed-development     Parallel development
```

---

## 💬 Usage Examples

```bash
# Example 1: Brainstorming
/brainstorming User authentication with JWT

# Example 2: Planning
/em-planner Create implementation plan for shopping cart

# Example 3: Code Review
/em-code-reviewer Review PR #123

# Example 4: Debugging
/em-debugger Investigate login timeout bug

# Example 5: Full Workflow
/em-new-feature Implement user profile from idea to production

# Example 6: Security Audit
/em-security-audit Audit payment system

# Example 7: Distributed Investigation
/em-distributed-investigation Investigate database performance issue
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
/em-planner
/em-new-feature
```

---

## 🎯 Naming Convention

- **Skills:** No prefix - `/brainstorming`, `/spec-driven-dev`
- **Agents:** `em-` prefix - `/em-planner`, `/em-code-reviewer`
- **Workflows:** `em-` prefix - `/em-new-feature`, `/em-bug-fix`

This makes it easy to distinguish:
- Skills (general patterns)
- Agents (specialized AI assistants)
- Workflows (end-to-end processes)

---

## 🎯 Tips

1. **Type `/`** to see all available commands
2. **Use TAB** for autocomplete
3. **Commands work from ANY repository**
4. **Combine with text** for full requests
5. **Use em-commands** to see full list

---

**That's it! Type `/` + command name to use EM-Skill quickly!** ⚡

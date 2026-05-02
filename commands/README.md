# EM-Team Commands

CLI commands to accelerate common workflows.

Source: GSD + gstack + superpowers best practices

---

## ⚠️ Deprecation Notice

**`code-review-9.sh` is deprecated.** Use `code-review-deep.sh` instead.

The command `em-team code-review-9` will be removed in v2.0.0.
Migrate to: `em-team code-review-deep`

---

## Commands Available

### 1. quick.sh ⚡
Execute quick tasks with minimal overhead.

**Usage:**
```bash
em-team quick <task-description>
```

**Examples:**
```bash
em-team quick fix typo in README
em-team quick add error handling to auth
em-team quick update dependencies
```

**Use for:**
- Small, self-contained tasks
- Quick fixes
- Minor updates

**Not for:**
- Large features (use `new-feature` workflow)
- Complex refactors (use `refactoring` workflow)

---

## Command Selection Guide

### Quick Decision Tree

```
What type of task?
│
├─ Quick fix (< 5 min)?
│  └─ Use: quick.sh
│
├─ Bug investigation?
│  └─ Use: debug.sh
│
├─ Code review needed?
│  ├─ Quick review (staged)?
│  │  └─ Use: review.sh
│  │
│  └─ Deep review (PR/commit)?
│     └─ Use: code-review-deep.sh
│
├─ QA testing?
│  └─ Use: qa.sh
│
├─ Ready to ship?
│  └─ Use: ship.sh
│
├─ Verify implementation?
│  └─ Use: verify.sh
│
├─ Check project health?
│  └─ Use: health.sh
│
├─ Save/restore state?
│  └─ Use: checkpoint.sh
│
└─ Team review needed?
   └─ Use team-lead.sh
```

---

## Deprecated Commands

The following commands are deprecated and will be removed in v2.0.0:

| Old Command | New Command | Migration |
|-------------|-------------|-----------|
| `code-review-9.sh` | `code-review-deep.sh` | Update scripts and aliases |

---

### 2. debug.sh 🐛
Systematic debugging with root cause investigation.

**Usage:**
```bash
em-team debug <bug-description>
```

**Examples:**
```bash
em-team debug "User cannot login after password reset"
em-team debug "API returns 500 when creating order"
em-team debug "Memory leak in WebSocket handler"
```

**Process:**
1. INVESTIGATE - Reproduce and collect data
2. ANALYZE - Examine code and patterns
3. HYPOTHESIZE - Form and test hypothesis
4. IMPLEMENT - Fix root cause with regression test

**Iron Law:** NO FIXES WITHOUT ROOT CAUSE

---

### 3. review.sh 👁️
Trigger 5-axis code review.

**Usage:**
```bash
em-team review [target]
```

**Examples:**
```bash
em-team review              # Review staged changes
em-team review main         # Review diff from main
em-team review abc123       # Review specific commit
em-team review --file src/auth/login.ts
```

**5 Axes:**
1. Correctness - Is code logic correct?
2. Readability - Is code easy to understand?
3. Architecture - Does it follow architecture?
4. Security - Are there vulnerabilities?
5. Performance - Are there performance issues?

---

### 4. qa.sh 🧪
Systematically QA test web application.

**Usage:**
```bash
em-team qa <url> [scope]
```

**Examples:**
```bash
em-team qa http://localhost:3000
em-team qa https://staging.example.com
em-team qa /dashboard critical
```

**Scopes:**
- `full` - Complete QA test suite (default)
- `critical` - Critical paths only
- `smoke` - Basic functionality
- `visual` - Visual regression only

**Checks:**
- Critical paths (auth, CRUD, etc.)
- Console errors
- Performance
- Responsive design
- Visual consistency
- Accessibility

---

### 5. ship.sh 🚢
Complete ship workflow.

**Usage:**
```bash
em-team ship
```

**Process:**
1. Check git status
2. Check base branch updates
3. Run tests
4. Run lint
5. Build
6. Bump version
7. Update CHANGELOG
8. Create PR

**Prepares:**
- Version bump
- Changelog updates
- Documentation updates
- PR against base branch

---

### 6. verify.sh ✅
Verify implementation against spec.

**Usage:**
```bash
em-team verify [spec-file]
```

**Examples:**
```bash
em-team verify
em-team verify SPEC.md
em-team verify docs/auth-spec.md
```

**Verifies:**
1. Objectives met
2. Commands/endpoints implemented
3. Structure follows conventions
4. Code style compliant
5. Testing strategy met
6. Boundaries respected

**Generates:**
- Verification report
- Gap analysis
- Recommendations

---

### 7. health.sh 🏥
Diagnose project health.

**Usage:**
```bash
em-team health
```

**Checks:**
- Git repository status
- Package manager
- Tests
- Linting
- Build
- Documentation
- Dependencies (vulnerabilities)
- Git hooks installed
- CI/CD configured
- EM-Team integration

**Output:**
- Health score (0-100)
- Status (Excellent/Good/Fair/Poor)
- Recommendations
- Quick fixes

---

### 8. checkpoint.sh 💾
Save and restore working state.

**Usage:**
```bash
em-team checkpoint <command> [name]
```

**Commands:**
```bash
em-team checkpoint save [name]      # Save current state
em-team checkpoint restore <name>   # Restore state
em-team checkpoint list             # List all checkpoints
em-team checkpoint delete <name>    # Delete checkpoint
```

---

## Team Commands (8 commands)

### 9. team-lead.sh 🎯
Orchestrate full team review.

**Usage:**
```bash
em-team team-lead "[task description]"
```

**Examples:**
```bash
em-team team-lead "Review new payment feature before implementation"
em-team team-lead "Architecture review for microservices migration"
em-team team-lead "Cross-functional review for checkout flow"
```

**Orchestrates:**
- Product Manager (business validation)
- Architect (technical design)
- Frontend Expert (UI/UX)
- Database Expert (data layer)
- Senior Code Reviewer (code quality)
- Security Reviewer (security assessment)
- Staff Engineer (deep investigation)

**Trigger:** `em-agent:team-lead`

---

### 10. arch-review.sh 🏗️
Architecture review with Architect and Staff Engineer.

**Usage:**
```bash
em-team arch-review "[architecture description]"
```

**Examples:**
```bash
em-team arch-review "Review hexagonal architecture for user service"
em-team arch-review "Assess microservices decomposition strategy"
em-team arch-review "Review event-driven architecture for payments"
```

**Reviews:**
- Architectural patterns (Layered, Hexagonal, Microservices, Event-Driven)
- Architecture principles
- Technical design
- Cross-service impact
- Scalability

**Trigger:** `em-agent:architect` + `em-agent:staff-engineer`

---

### 11. design-review.sh 🎨
UI/UX design review with Frontend Expert and Product Manager.

**Usage:**
```bash
em-team design-review "[design description]"
```

**Examples:**
```bash
em-team design-review "Review checkout flow UI design"
em-team design-review "Assess dashboard component design"
em-team design-review "Review mobile app navigation design"
```

**Reviews:**
- User stories (INVEST criteria)
- User flows
- Component architecture
- Core Web Vitals (LCP, FID, CLS)
- Accessibility (WCAG 2.1 AA/AAA)
- Responsive design

**Trigger:** `em-agent:product-manager` + `em-agent:frontend-expert`

---

### 12. code-review-deep.sh 🔍 (PRIMARY)
**⚠️ Note:** `code-review-9.sh` is deprecated. Use this command instead.

Deep 9-axis code review with Senior Code Reviewer and Security Reviewer.

**Usage:**
```bash
em-team code-review-deep "[PR or code description]"
```

**Examples:**
```bash
em-team code-review-deep "Review PR #123 for payment processing"
em-team code-review-deep "Review authentication module for security"
em-team code-review-deep "Assess code quality of user service refactoring"
```

---

### 12b. code-review-9.sh 🔍 (DEPRECATED)
⚠️ **DEPRECATED:** Use `code-review-deep.sh` instead.

This wrapper is maintained for backward compatibility and will be removed in v2.0.0.

**Usage:**
```bash
em-team code-review-9 "[PR or code description]"
```

Automatically redirects to `code-review-deep.sh`.

**9 Axes:**
1. Correctness ✅
2. Readability 📖
3. Architecture 🏗️
4. Security 🔒
5. Performance ⚡
6. Testing 🧪
7. Maintainability 🔧
8. Scalability 📈
9. Documentation 📚

**Trigger:** `em-agent:senior-code-reviewer` + `em-agent:security-reviewer`

---

### 13. db-review.sh 🗄️
Database review with Database Expert and Architect.

**Usage:**
```bash
em-team db-review "[database description]"
```

**Examples:**
```bash
em-team db-review "Review schema for payment ledger system"
em-team db-review "Assess query performance for reporting dashboard"
em-team db-review "Review migration strategy for user table split"
```

**Reviews:**
- Schema design (normalization, naming, types)
- Query performance and optimization
- Indexing strategy
- Migration plan
- Data integrity
- Fintech patterns (ledger, audit trail)

**Trigger:** `em-agent:database-expert` + `em-agent:architect`

---

### 14. product-review.sh 📦
Product/spec review with Product Manager and Architect.

**Usage:**
```bash
em-team product-review "[spec or requirement description]"
```

**Examples:**
```bash
em-team product-review "Review spec for new payment feature"
em-team product-review "Validate requirements for user onboarding flow"
em-team product-review "Assess market fit for subscription management"
```

**Reviews:**
- Requirements validation
- GAP analysis
- Acceptance criteria
- User stories (INVEST)
- Business impact and ROI
- Market fit
- Technical feasibility

**Trigger:** `em-agent:product-manager` + `em-agent:architect`

---

### 15. security-review.sh 🔒
Advanced security review with Security Reviewer and Staff Engineer.

**Usage:**
```bash
em-team security-review "[security description]"
```

**Examples:**
```bash
em-team security-review "Perform OWASP assessment on payment system"
em-team security-review "STRIDE threat modeling for API gateway"
em-team security-review "Security review for authentication service"
```

**Assessment:**
- OWASP Top 10 (A01-A10)
- STRIDE threat modeling
- Cross-service security impact
- Dependency security
- Infrastructure security

**BLOCKING Authority:** CRITICAL/HIGH issues must be fixed

**Trigger:** `em-agent:security-reviewer` + `em-agent:staff-engineer`

---

### 16. incident.sh 🚨
Production incident response with Staff Engineer and Security Reviewer.

**Usage:**
```bash
em-team incident "[incident description]"
```

**Examples:**
```bash
em-team incident "Production outage - API returning 500 errors"
em-team incident "Database connection pool exhausted"
em-team incident "Security alert - unusual login patterns"
em-team incident "Payment processing failures"
```

**Process:**
1. Initial assessment & triage (P0/P1/P2/P3)
2. Security investigation (if applicable)
3. Root cause analysis (5 Whys, fishbone)
4. Cross-service impact analysis
5. Resolution & verification
6. Blameless postmortem

**Trigger:** `em-agent:staff-engineer` + `em-agent:security-reviewer`

---

## Command Selection Guide

### Code Review Decision Tree

```
Need to review code?
│
├─ Quick review of staged changes?
│  └─ Use: review.sh (5-axis review)
│
├─ Comprehensive review for PR/commit?
│  └─ Use: code-review-deep.sh (9-axis + security)
│
└─ Security-focused review?
   └─ Use: security-review.sh (OWASP + STRIDE)
```

### Security Review Decision Tree

```
Need security assessment?
│
├─ General security audit?
│  └─ Use: security-audit workflow
│
├─ Advanced security review (OWASP + STRIDE)?
│  └─ Use: security-review.sh
│
└─ Production security incident?
   └─ Use: incident.sh
```

---

## Command Integration Table

| Command | Uses Agent(s) | Uses Workflow | Purpose |
|---------|---------------|---------------|---------|
| quick | executor | - | Quick tasks |
| debug | debugger | bug-fix | Systematic debugging |
| review | code-reviewer | - | 5-axis code review |
| qa | - | - | QA testing |
| ship | executor | - | Ship workflow |
| verify | verifier | - | Verify implementation |
| health | - | - | Project health |
| checkpoint | - | - | State management |
| **team-lead** | **team-lead + all** | **team-review** | **Full team orchestration** |
| **arch-review** | **architect + staff** | **architecture-review** | **Architecture assessment** |
| **design-review** | **product + frontend** | **design-review** | **UI/UX design review** |
| **code-review-deep** ⭐ | **code-review + security** | **code-review-9axis** | **9-axis deep review** |
| code-review-9 ⚠️ | *(deprecated wrapper)* | *(deprecated)* | *(Use code-review-deep)* |
| **db-review** | **database + architect** | **database-review** | **Database assessment** |
| **product-review** | **product + architect** | **product-review** | **Product requirements review** |
| **security-review** | **security + staff** | **security-review-advanced** | **Advanced security** |
| **incident** | **staff + security** | **incident-response** | **Incident handling** |

⭐ = Primary command
⚠️ = Deprecated

---

## Installing Commands

**All 16 commands (8 core + 8 team) are installed using the same methods.**

### Option 1: Symlink (Recommended)
```bash
# Create bin directory
mkdir -p ~/.local/bin

# Symlink all commands
ln -s $(pwd)/em-team/commands/*.sh ~/.local/bin/em-team-*

# Create wrapper script
cat > ~/.local/bin/em-team << 'EOF'
#!/bin/bash
COMMAND="$1"
shift
~/.local/bin/em-team-${COMMAND}.sh "$@"
EOF

chmod +x ~/.local/bin/em-team

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"
```

### Option 2: Alias
```bash
# Add to ~/.bashrc or ~/.zshrc
# Core commands
alias em-team-quick='bash /path/to/em-team/commands/quick.sh'
alias em-team-debug='bash /path/to/em-team/commands/debug.sh'
alias em-team-review='bash /path/to/em-team/commands/review.sh'
alias em-team-qa='bash /path/to/em-team/commands/qa.sh'
alias em-team-ship='bash /path/to/em-team/commands/ship.sh'
alias em-team-verify='bash /path/to/em-team/commands/verify.sh'
alias em-team-health='bash /path/to/em-team/commands/health.sh'
alias em-team-checkpoint='bash /path/to/em-team/commands/checkpoint.sh'

# Team commands
alias em-team-team-lead='bash /path/to/em-team/commands/team-lead.sh'
alias em-team-arch-review='bash /path/to/em-team/commands/arch-review.sh'
alias em-team-design-review='bash /path/to/em-team/commands/design-review.sh'
alias em-team-code-review-deep='bash /path/to/em-team/commands/code-review-deep.sh'
alias em-team-db-review='bash /path/to/em-team/commands/db-review.sh'
alias em-team-product-review='bash /path/to/em-team/commands/product-review.sh'
alias em-team-security-review='bash /path/to/em-team/commands/security-review.sh'
alias em-team-incident='bash /path/to/em-team/commands/incident.sh'

# Legacy (deprecated)
alias em-team-code-review-9='bash /path/to/em-team/commands/code-review-9.sh'
```

---

**EM-Team Version:** 1.1.0
**Last Updated:** 2026-04-19
**Total Commands:** 16 (8 core + 8 team)

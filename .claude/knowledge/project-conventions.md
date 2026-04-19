# Project Conventions Knowledge Base

**Project:** EM-Team
**Last Updated:** 2026-04-19
**Extracted By:** Codebase-Mapper Agent

---

## Naming Conventions

### Files
- **Skills:** kebab-case (e.g., `test-driven-development.md`)
- **Agents:** kebab-case (e.g., `codebase-mapper.md`)
- **Workflows:** kebab-case (e.g., `new-feature.md`)
- **Scripts:** kebab-case with `.sh` extension (e.g., `tdd-retry-wrapper.sh`)
- **Commands:** kebab-case with `.sh` extension (e.g., `em-show.sh`)

### Code Elements
- **Functions/Variables:** `snake_case` in shell scripts
- **Constants:** `UPPER_SNAKE_CASE`
- **Private Functions:** Prefix with `_` (e.g., `_internal_function`)
- **YAML Keys:** `snake_case`

## Directory Structure

```
EM-Skill/
├── skills/              # Skill definitions (25+ skills)
│   ├── foundation/      # Core foundational skills
│   ├── development/     # Development workflow skills
│   ├── quality/         # Quality assurance skills
│   ├── workflow/        # Workflow and automation skills
│   └── specialized/     # Language/framework-specific skills
├── agents/              # Agent definitions (16 agents)
├── workflows/           # Workflow definitions (18 workflows)
├── scripts/             # Shell scripts for automation
├── hooks/               # Git hooks
├── commands/            # CLI commands
├── templates/           # Reusable templates
├── docs/                # Documentation
├── protocols/           # Protocol definitions
└── .claude/             # Claude-specific configuration
    ├── knowledge/       # Knowledge base (THIS DIRECTORY)
    └── tdd-context/     # TDD error context storage
```

## Code Conventions

### Shell Scripts
- **Shebang:** `#!/usr/bin/env bash` or `#!/bin/bash`
- **Error Handling:** `set -euo pipefail` at script start
- **Indentation:** 2 spaces
- **Line Length:** Max 100 characters (soft limit)
- **Comments:** `#` for single-line comments
- **Functions:** `snake_case` naming
- **Exit Codes:**
  - `0` = Success
  - `1` = General error
  - `42` = Retry requested (TDD)
  - `43` = Max retries exceeded (TDD)

### Markdown Files
- **Headings:** ATX style (`#`, `##`, etc.)
- **Code Blocks:** Fenced with `\`\`\`bash` or `\`\`\`typescript`
- **Lists:** Bulleted lists with `-`
- **YAML Frontmatter:** Required for skills/agents/workflows
- **Line Length:** Soft limit of 120 characters
- **Emphasis:** Bold for headers, italics for emphasis

### YAML Files
- **Indentation:** 2 spaces (no tabs)
- **Quotes:** Single quotes for strings
- **Booleans:** `true`/`false` (lowercase)
- **Comments:** `#` for inline comments
- **Lists:** Dash (`-`) prefix with 2-space indent

## File Organization Patterns

### Skills Structure
```markdown
---
name: skill-name
description: Brief description
version: X.X.X
---

# Skill Name

## Overview
[Brief overview]

## When to Use
[Use cases]

## Process
[Step-by-step process]

## Rationalizations
[Why this approach]

## Red Flags
[Warning signs]

## Verification
[How to verify success]
```

### Agents Structure
```markdown
---
name: agent-name
type: core|specialist|optional
trigger: command:agent-name
---

# Agent Name

## Overview
[Brief overview]

## Responsibilities
[List of responsibilities]

## When to Use
[Use cases with trigger command]

## Process/Methodology
[Detailed process]

## Handoff Contracts
[Input/Output contracts]

## Output Template
[Report template]

## Completion Checklist
[What needs to be done]
```

### Workflows Structure
```markdown
---
name: workflow-name
description: Brief description
version: X.X.X
---

# Workflow Name

## Overview
[Brief overview]

## When to Use
[Use cases]

## Participants
[Which agents participate]

## Process Flow
[Step-by-step process]

## Entry/Exit Criteria
[When to start, when to stop]

## Verification
[How to verify success]
```

## Git Conventions

### Commit Message Format
```
type(scope): description

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- refactor: Code refactoring
- test: Test changes
- chore: Maintenance tasks

Examples:
feat(tdd): add auto-retry loop with exponential backoff
fix(token): resolve token counting accuracy issues
docs(readme): update with v1.2.0 features
```

### Branch Naming
- Feature: `feature/feature-name`
- Bugfix: `bugfix/bug-description`
- Refactor: `refactor/refactor-description`
- Documentation: `docs/documentation-change`

## Testing Conventions

### Test Structure
```bash
# Test script structure
setup() {
    # Setup code
}

test_should_do_something() {
    # Arrange
    local input="value"

    # Act
    local result=$(function_under_test "$input")

    # Assert
    [[ "$result" == "expected" ]]
}

teardown() {
    # Cleanup code
}
```

### Test Naming
- Test functions: `test_should_<expected_behavior>` or `test_<feature>_<scenario>`
- Test files: Same name as source with `-test` suffix before extension

## Documentation Conventions

### Documentation Style
- **Tone:** Professional, concise, directive
- **Voice:** Imperative mood ("Do this", not "You should do this")
- **Format:** Markdown with YAML frontmatter
- **Sections:** Use H2 (`##`) for main sections
- **Code Examples:** Always include working examples

### ADR (Architecture Decision Records)
```markdown
# ADR-XXX: [Decision Title]

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
[What is the issue?]

## Decision
[What are we doing?]

## Consequences
- Positive: [benefits]
- Negative: [drawbacks]

## Alternatives Considered
- [Alternative 1]
- [Alternative 2]
```

## Error Handling Patterns

### Shell Script Error Handling
```bash
# Exit on error
set -euo pipefail

# Trap errors
trap 'handle_error $? $LINENO' ERR

handle_error() {
    local exit_code=$1
    local line_number=$2
    log_error "Error on line $line_number: exit code $exit_code"
    cleanup
    exit $exit_code
}
```

### Logging Functions
```bash
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}
```

## Code Quality Standards

### Shell Script Quality
- **Shellcheck:** Must pass shellcheck with no errors
- **POSIX Compliance:** Use bashisms intentionally, document when used
- **Error Handling:** All external commands must be checked
- **Variables:** Quote all variables: `"$variable"`
- **Functions:** Prefer functions over code duplication

### Documentation Quality
- **Clarity:** Write for someone who has never seen the code
- **Completeness:** Document all public interfaces
- **Examples:** Provide working examples
- **Maintenance:** Keep documentation in sync with code

## Architectural Patterns

### EM-Team Architecture
- **Pattern:** Agent-Skill-Workflow (ASW) architecture
- **Agents:** 16 specialized agents (8 core + 8 specialized)
- **Skills:** 25+ skills covering foundation, development, quality, workflow
- **Workflows:** 18 end-to-end workflows
- **Integration:** File-based communication via reports

### Distributed Mode Architecture
- **Orchestration:** tmux-based parallel sessions
- **Communication:** Report files in `.claude/reports/`
- **Consolidation:** Report consolidation before Tech Lead review
- **Token Management:** 200K budget per agent, summarization at 150K threshold

## Security Conventions

### Secrets Management
- **Never commit:** API keys, passwords, tokens
- **Use environment variables:** `export API_KEY="value"`
- **Use .env files:** Add `.env` to `.gitignore`
- **Document:** Document required environment variables

### Input Validation
- **Validate all inputs:** Check user input, API responses
- **Sanitize:** Sanitize file paths, command arguments
- **Use quotes:** Quote variables to prevent globbing
- **Error on unexpected:** Fail fast on unexpected input

## Performance Conventions

### Token Management
- **Budget:** 200K tokens per agent
- **Threshold:** Trigger summarization at 150K tokens
- **Target:** Aim for 80K tokens after summarization
- **Preservation:** 100% preserve critical/high issues

### Caching
- **Cache reports:** Store agent reports in `.claude/reports/`
- **Cache token counts:** Store in `.claude/cache/`
- **Invalidate:** Clear cache when source changes

---

**Knowledge Base Version:** 1.0.0
**Last Updated:** 2026-04-19
**Next Review:** When code conventions change or quarterly

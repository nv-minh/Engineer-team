#!/bin/bash
# EM-Skill Command Completions
# Source this file in your ~/.bashrc or ~/.zshrc

# Skills completions
_em_skill_skills() {
    local skills=(
        "brainstorming:Explore ideas into designs"
        "spec-driven-dev:Create specifications before coding"
        "systematic-debugging:Debug using scientific method"
        "context-engineering:Optimize agent context"
        "writing-plans:Write implementation plans"
        "test-driven-dev:TDD RED-GREEN-REFACTOR"
        "frontend-patterns:React/Next.js/Vue patterns"
        "backend-patterns:API/Database patterns"
        "security-hardening:OWASP Top 10 security"
        "incremental-impl:Vertical slice development"
        "subagent-dev:Fresh context per task"
        "source-driven-dev:Code from official docs"
        "api-interface-design:Contract-first APIs"
        "code-review:5-axis code review"
        "code-simplification:Reduce complexity"
        "browser-testing:DevTools MCP"
        "performance-optimization:Measure-first optimization"
        "e2e-testing:Playwright testing"
        "security-audit:Vulnerability assessment"
        "api-testing:Integration testing"
        "git-workflow:Atomic commits"
        "ci-cd-automation:Feature flags"
        "documentation:ADRs & docs"
        "finishing-branch:Merge/PR decisions"
        "deprecation-migration:Code-as-liability"
    )
    echo "${skills[@]}"
}

# Agents completions
_em_skill_agents() {
    local agents=(
        "em-planner:Create implementation plans"
        "em-executor:Execute plans with atomic commits"
        "em-code-reviewer:5-axis code review"
        "em-debugger:Systematic debugging"
        "em-test-engineer:Test strategy"
        "em-security-auditor:OWASP security"
        "em-ui-auditor:Visual QA"
        "em-verifier:Post-execution verification"
        "em-architect:Architecture design"
        "em-backend-expert:Database, API, performance"
        "em-frontend-expert:React/Next.js, UI/UX"
        "em-database-expert:Schema, queries"
        "em-product-manager:Requirements"
        "em-senior-code-reviewer:9-axis review"
        "em-security-reviewer:OWASP + STRIDE"
        "em-staff-engineer:Root cause analysis"
        "em-team-lead:Team coordination"
        "em-techlead-orchestrator:Distributed investigation"
        "em-researcher:Technical research"
        "em-codebase-mapper:Architecture analysis"
        "em-integration-checker:Cross-phase validation"
        "em-performance-auditor:Benchmarking"
    )
    echo "${agents[@]}"
}

# Workflows completions
_em_skill_workflows() {
    local workflows=(
        "em-new-feature:From idea to production"
        "em-bug-fix:Investigate and fix bugs"
        "em-refactoring:Improve code quality"
        "em-security-audit:Security assessment"
        "em-project-setup:Initialize projects"
        "em-documentation:Generate docs"
        "em-deployment:Deploy and monitor"
        "em-retro:Learn and improve"
        "em-team-review:Full team review"
        "em-architecture-review:Architecture review"
        "em-design-review:UI/UX review"
        "em-code-review-9axis:Deep 9-axis review"
        "em-database-review:Database review"
        "em-product-review:Product review"
        "em-security-review-advanced:Advanced security"
        "em-incident-response:Production incidents"
        "em-distributed-investigation:Parallel investigation"
        "em-distributed-development:Parallel development"
    )
    echo "${workflows[@]}"
}

# Main completion function
_em_skill_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "$prev" in
        /|skill|skills)
            COMPREPLY=($(compgen -W "$(_em_skill_skills)" -- "$cur"))
            ;;
        agent|agents)
            COMPREPLY=($(compgen -W "$(_em_skill_agents)" -- "$cur"))
            ;;
        workflow|workflows)
            COMPREPLY=($(compgen -W "$(_em_skill_workflows)" -- "$cur"))
            ;;
        *)
            # If user types /, suggest all
            if [[ "$cur" == /* ]]; then
                local all="$(_em_skill_skills) $(_em_skill_agents) $(_em_skill_workflows)"
                COMPREPLY=($(compgen -W "$all" -- "${cur#/}"))
            fi
            ;;
    esac
}

# Register completion for EM-Skill commands
complete -F _em_skill_complete em-skill
complete -F _em_skill_complete /

# Show all EM-Skill commands when typing /
alias '/='='_em_skill_show_commands

_em_skill_show_commands() {
    echo "🎯 EM-Skill Commands (use /command):"
    echo ""
    echo "Skills (type /skill name):"
    _em_skill_skills | tr ' ' '\n' | while read line; do
        echo "  /${line%:*}"
    done
    echo ""
    echo "Agents (type /em-agent name):"
    _em_skill_agents | tr ' ' '\n' | while read line; do
        echo "  /${line%:*}"
    done
    echo ""
    echo "Workflows (type /em-workflow name):"
    _em_skill_workflows | tr ' ' '\n' | while read line; do
        echo "  /${line%:*}"
    done
    echo ""
    echo "💬 Examples:"
    echo "  /brainstorming Explore authentication"
    echo "  /em-planner Create plan for JWT"
    echo "  /em-new-feature Implement user auth"
}

echo "✅ EM-Skill completions loaded! Type '/' to see all commands."

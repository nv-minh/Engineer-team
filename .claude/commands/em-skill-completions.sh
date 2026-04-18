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
        "planner:Create implementation plans"
        "executor:Execute plans with atomic commits"
        "code-reviewer:5-axis code review"
        "debugger:Systematic debugging"
        "test-engineer:Test strategy"
        "security-auditor:OWASP security"
        "ui-auditor:Visual QA"
        "verifier:Post-execution verification"
        "architect:Architecture design"
        "backend-expert:Database, API, performance"
        "frontend-expert:React/Next.js, UI/UX"
        "database-expert:Schema, queries"
        "product-manager:Requirements"
        "senior-code-reviewer:9-axis review"
        "security-reviewer:OWASP + STRIDE"
        "staff-engineer:Root cause analysis"
        "team-lead:Team coordination"
        "techlead-orchestrator:Distributed investigation"
        "researcher:Technical research"
        "codebase-mapper:Architecture analysis"
        "integration-checker:Cross-phase validation"
        "performance-auditor:Benchmarking"
    )
    echo "${agents[@]}"
}

# Workflows completions
_em_skill_workflows() {
    local workflows=(
        "new-feature:From idea to production"
        "bug-fix:Investigate and fix bugs"
        "refactoring:Improve code quality"
        "security-audit:Security assessment"
        "project-setup:Initialize projects"
        "documentation:Generate docs"
        "deployment:Deploy and monitor"
        "retro:Learn and improve"
        "team-review:Full team review"
        "architecture-review:Architecture review"
        "design-review:UI/UX review"
        "code-review-9axis:Deep 9-axis review"
        "database-review:Database review"
        "product-review:Product review"
        "security-review-advanced:Advanced security"
        "incident-response:Production incidents"
        "distributed-investigation:Parallel investigation"
        "distributed-development:Parallel development"
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
    echo "Agents (type /agent name):"
    _em_skill_agents | tr ' ' '\n' | while read line; do
        echo "  /${line%:*}"
    done
    echo ""
    echo "Workflows (type /workflow name):"
    _em_skill_workflows | tr ' ' '\n' | while read line; do
        echo "  /${line%:*}"
    done
    echo ""
    echo "💬 Examples:"
    echo "  /brainstorming Explore authentication"
    echo "  /planner Create plan for JWT"
    echo "  /new-feature Implement user auth"
}

echo "✅ EM-Skill completions loaded! Type '/' to see all commands."

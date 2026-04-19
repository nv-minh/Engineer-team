#compdef em-skill
# EM-Skill ZSH Completion

# Skills
_em_skill_skills() {
    local -a skills
    skills=(
        'brainstorming:Explore ideas into designs'
        'spec-driven-dev:Create specifications before coding'
        'systematic-debugging:Debug using scientific method'
        'context-engineering:Optimize agent context'
        'writing-plans:Write implementation plans'
        'test-driven-dev:TDD RED-GREEN-REFACTOR'
        'frontend-patterns:React/Next.js/Vue patterns'
        'backend-patterns:API/Database patterns'
        'security-hardening:OWASP Top 10 security'
        'incremental-impl:Vertical slice development'
        'subagent-dev:Fresh context per task'
        'source-driven-dev:Code from official docs'
        'api-interface-design:Contract-first APIs'
        'code-review:5-axis code review'
        'code-simplification:Reduce complexity'
        'browser-testing:DevTools MCP'
        'performance-optimization:Measure-first optimization'
        'e2e-testing:Playwright testing'
        'security-audit:Vulnerability assessment'
        'api-testing:Integration testing'
        'git-workflow:Atomic commits'
        'ci-cd-automation:Feature flags'
        'documentation:ADRs & docs'
        'finishing-branch:Merge/PR decisions'
        'deprecation-migration:Code-as-liability'
    )
    _describe 'skills' skills
}

# Agents
_em_skill_agents() {
    local -a agents
    agents=(
        'em-planner:Create implementation plans'
        'em-executor:Execute plans with atomic commits'
        'em-code-reviewer:5-axis code review'
        'em-debugger:Systematic debugging'
        'em-test-engineer:Test strategy'
        'em-security-auditor:OWASP security'
        'em-ui-auditor:Visual QA'
        'em-verifier:Post-execution verification'
        'em-architect:Architecture design'
        'em-backend-expert:Database, API, performance'
        'em-frontend-expert:React/Next.js, UI/UX'
        'em-database-expert:Schema, queries'
        'em-product-manager:Requirements'
        'em-senior-code-reviewer:9-axis review'
        'em-security-reviewer:OWASP + STRIDE'
        'em-staff-engineer:Root cause analysis'
        'em-team-lead:Team coordination'
        'em-techlead-orchestrator:Distributed investigation'
        'em-researcher:Technical research'
        'em-codebase-mapper:Architecture analysis'
        'em-integration-checker:Cross-phase validation'
        'em-performance-auditor:Benchmarking'
    )
    _describe 'agents' agents
}

# Workflows
_em_skill_workflows() {
    local -a workflows
    workflows=(
        'em-new-feature:From idea to production'
        'em-bug-fix:Investigate and fix bugs'
        'em-refactoring:Improve code quality'
        'em-security-audit:Security assessment'
        'em-project-setup:Initialize projects'
        'em-documentation:Generate docs'
        'em-deployment:Deploy and monitor'
        'em-retro:Learn and improve'
        'em-team-review:Full team review'
        'em-architecture-review:Architecture review'
        'em-design-review:UI/UX review'
        'em-code-review-9axis:Deep 9-axis review'
        'em-database-review:Database review'
        'em-product-review:Product review'
        'em-security-review-advanced:Advanced security'
        'em-incident-response:Production incidents'
        'em-distributed-investigation:Parallel investigation'
        'em-distributed-development:Parallel development'
    )
    _describe 'workflows' workflows
}

# Main completion
_em_skill() {
    local context state state_descr line
    typeset -A opt_args

    _arguments -C \
        '--help[Show help]' \
        {-h,--help}'[Show help]'

    case $state in
        commands)
            ;;
    esac

    # Show all commands when typing /
    if [[ $words[2] == "/" ]]; then
        _em_skill_skills
        _em_skill_agents
        _em_skill_workflows
    fi
}

_em_skill_show_commands() {
    echo "🎯 EM-Skill Commands (use /command):"
    echo ""
    echo "Skills (type /skill name):"
    echo "  /brainstorming - Explore ideas into designs"
    echo "  /spec-driven-dev - Create specifications before coding"
    echo "  /systematic-debugging - Debug using scientific method"
    echo "  /context-engineering - Optimize agent context"
    echo "  /writing-plans - Write implementation plans"
    echo "  /test-driven-dev - TDD RED-GREEN-REFACTOR"
    echo "  /frontend-patterns - React/Next.js/Vue patterns"
    echo "  /backend-patterns - API/Database patterns"
    echo "  /security-hardening - OWASP Top 10 security"
    echo "  /incremental-impl - Vertical slice development"
    echo "  /subagent-dev - Fresh context per task"
    echo "  /source-driven-dev - Code from official docs"
    echo "  /api-interface-design - Contract-first APIs"
    echo "  /code-review - 5-axis code review"
    echo "  /code-simplification - Reduce complexity"
    echo "  /browser-testing - DevTools MCP"
    echo "  /performance-optimization - Measure-first optimization"
    echo "  /e2e-testing - Playwright testing"
    echo "  /security-audit - Vulnerability assessment"
    echo "  /api-testing - Integration testing"
    echo "  /git-workflow - Atomic commits"
    echo "  /ci-cd-automation - Feature flags"
    echo "  /documentation - ADRs & docs"
    echo "  /finishing-branch - Merge/PR decisions"
    echo "  /deprecation-migration - Code-as-liability"
    echo ""
    echo "Agents (type /em-agent name):"
    echo "  /em-planner - Create implementation plans"
    echo "  /em-executor - Execute plans with atomic commits"
    echo "  /em-code-reviewer - 5-axis code review"
    echo "  /em-debugger - Systematic debugging"
    echo "  /em-test-engineer - Test strategy"
    echo "  /em-security-auditor - OWASP security"
    echo "  /em-ui-auditor - Visual QA"
    echo "  /em-verifier - Post-execution verification"
    echo "  /em-architect - Architecture design"
    echo "  /em-backend-expert - Database, API, performance"
    echo "  /em-frontend-expert - React/Next.js, UI/UX"
    echo "  /em-database-expert - Schema, queries"
    echo "  /em-product-manager - Requirements"
    echo "  /em-senior-code-reviewer - 9-axis review"
    echo "  /em-security-reviewer - OWASP + STRIDE"
    echo "  /em-staff-engineer - Root cause analysis"
    echo "  /em-team-lead - Team coordination"
    echo "  /em-techlead-orchestrator - Distributed investigation"
    echo "  /em-researcher - Technical research"
    echo "  /em-codebase-mapper - Architecture analysis"
    echo "  /em-integration-checker - Cross-phase validation"
    echo "  /em-performance-auditor - Benchmarking"
    echo ""
    echo "Workflows (type /em-workflow name):"
    echo "  /em-new-feature - From idea to production"
    echo "  /em-bug-fix - Investigate and fix bugs"
    echo "  /em-refactoring - Improve code quality"
    echo "  /em-security-audit - Security assessment"
    echo "  /em-project-setup - Initialize projects"
    echo "  /em-documentation - Generate docs"
    echo "  /em-deployment - Deploy and monitor"
    echo "  /em-retro - Learn and improve"
    echo "  /em-team-review - Full team review"
    echo "  /em-architecture-review - Architecture review"
    echo "  /em-design-review - UI/UX review"
    echo "  /em-code-review-9axis - Deep 9-axis review"
    echo "  /em-database-review - Database review"
    echo "  /em-product-review - Product review"
    echo "  /em-security-review-advanced - Advanced security"
    echo "  /em-incident-response - Production incidents"
    echo "  /em-distributed-investigation - Parallel investigation"
    echo "  /em-distributed-development - Parallel development"
    echo ""
    echo "💬 Examples:"
    echo "  /brainstorming Explore authentication"
    echo "  /em-planner Create plan for JWT"
    echo "  /em-backend-expert Review API performance"
    echo "  /em-frontend-expert Review React components"
    echo "  /em-database-expert Optimize database queries"
    echo "  /em-new-feature Implement user auth"
}

# Create alias for /
alias '/'='_em_skill_show_commands'
alias '/em-'='_em_skill_show_commands'

# Register completion
compdef _em_skill em-skill

echo "✅ EM-Skill zsh completions loaded! Type '/' to see all commands."

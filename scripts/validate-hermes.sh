#!/usr/bin/env bash
# Hermes Protocol Validation Script
# Checks that all agents, skills, and workflows comply with the Hermes protocol.
#
# Usage: bash scripts/validate-hermes.sh [--verbose]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERBOSE="${1:-}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_CHECKS=0
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

pass() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    PASS_COUNT=$((PASS_COUNT + 1))
    [[ "$VERBOSE" == "--verbose" ]] && echo -e "  ${GREEN}PASS${NC} $1"
}

warn() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    WARN_COUNT=$((WARN_COUNT + 1))
    echo -e "  ${YELLOW}WARN${NC} $1"
}

fail() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo -e "  ${RED}FAIL${NC} $1"
}

section() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
}

################################################################################
# 1. Agent Schema Checks
################################################################################

section "Agent Files — Schema Presence"

agent_total=0
agent_with_input=0
agent_with_output=0

for f in "$REPO_ROOT"/agents/*.md; do
    [[ ! -f "$f" ]] && continue
    agent_total=$((agent_total + 1))
    name=$(basename "$f")

    if grep -q "^input_schema:" "$f" 2>/dev/null; then
        agent_with_input=$((agent_with_input + 1))
        pass "$name — input_schema present"
    else
        fail "$name — missing input_schema"
    fi

    if grep -q "^output_schema:" "$f" 2>/dev/null; then
        agent_with_output=$((agent_with_output + 1))
        pass "$name — output_schema present"
    else
        fail "$name — missing output_schema"
    fi
done

echo -e "  Agents: $agent_with_input/$agent_total have input_schema, $agent_with_output/$agent_total have output_schema"

################################################################################
# 2. Agent Block Structure Checks
################################################################################

section "Agent Files — Hermes Block Structure"

for f in "$REPO_ROOT"/agents/*.md; do
    [[ ! -f "$f" ]] && continue
    name=$(basename "$f")

    for block in "\[ROLE\]" "\[OBJECTIVE\]" "\[RULES\]" "\[AVAILABLE SKILLS\]" "\[PROCESS\]" "\[RESPONSE FORMAT\]" "\[HANDOFF\]"; do
        block_name=$(echo "$block" | tr -d '\\[]')
        if grep -q "$block" "$f" 2>/dev/null; then
            pass "$name — [$block_name] present"
        else
            fail "$name — missing [$block_name] block"
        fi
    done
done

################################################################################
# 3. Skill Schema Checks
################################################################################

section "Skill Files — Schema Presence"

skill_total=0
skill_with_input=0
skill_with_output=0
skill_with_error=0

find "$REPO_ROOT/skills" -name "*.md" -not -name "SKILL.md" -not -name "SKILL-INDEX.md" -not -name "README.md" | while read -r f; do
    [[ ! -f "$f" ]] && continue
    # Only check main skill files (not SKILL.md symlinks)
    name=$(basename "$f")
    dir=$(basename "$(dirname "$f")")

    if grep -q "^input_schema:" "$f" 2>/dev/null; then
        pass "$dir/$name — input_schema"
    else
        fail "$dir/$name — missing input_schema"
    fi

    if grep -q "^output_schema:" "$f" 2>/dev/null; then
        pass "$dir/$name — output_schema"
    else
        fail "$dir/$name — missing output_schema"
    fi

    if grep -q "^error_schema:" "$f" 2>/dev/null; then
        pass "$dir/$name — error_schema"
    else
        warn "$dir/$name — missing error_schema (optional for expert skills)"
    fi
done

################################################################################
# 4. Workflow ReAct Protocol Checks
################################################################################

section "Workflow Files — ReAct Protocol"

workflow_total=0
workflow_with_react=0

for f in "$REPO_ROOT"/workflows/*.md; do
    [[ ! -f "$f" ]] && continue
    workflow_total=$((workflow_total + 1))
    name=$(basename "$f")

    if grep -q "react_protocol: true" "$f" 2>/dev/null; then
        workflow_with_react=$((workflow_with_react + 1))
        pass "$name — react_protocol: true"
    else
        fail "$name — missing react_protocol"
    fi
done

echo -e "  Workflows: $workflow_with_react/$workflow_total have react_protocol"

################################################################################
# 5. Soft Language Check
################################################################################

section "Language Compliance — No Soft Language"

soft_patterns='[Pp]lease |I suggest|[Aa]s an AI|I would recommend|I apologize|might want to'

for dir in agents skills; do
    matches=$(grep -rn "$soft_patterns" "$REPO_ROOT/$dir/" 2>/dev/null | grep -v "\.legacy\." | grep -v "template" || true)
    if [[ -z "$matches" ]]; then
        pass "$dir/ — no soft language detected"
    else
        count=$(echo "$matches" | wc -l | tr -d ' ')
        fail "$dir/ — $count instances of soft language found:"
        echo "$matches" | head -10 | while read -r line; do
            echo -e "    ${YELLOW}→${NC} $line"
        done
        [[ $count -gt 10 ]] && echo -e "    ${YELLOW}... and $((count - 10)) more${NC}"
    fi
done

################################################################################
# 6. LLM Config Check
################################################################################

section "Runtime — LLM Configuration"

if [[ -f "$REPO_ROOT/scripts/llm-config.sh" ]]; then
    pass "scripts/llm-config.sh exists"

    if grep -q "LLM_PROVIDER" "$REPO_ROOT/scripts/llm-config.sh"; then
        pass "LLM_PROVIDER configurable"
    else
        fail "LLM_PROVIDER not found in llm-config.sh"
    fi

    for provider in anthropic openai ollama vllm custom; do
        if grep -q "$provider)" "$REPO_ROOT/scripts/llm-config.sh"; then
            pass "Provider: $provider supported"
        else
            fail "Provider: $provider not configured"
        fi
    done
else
    fail "scripts/llm-config.sh not found"
fi

################################################################################
# 7. Preamble Check
################################################################################

section "Preambles — Hermes Protocol"

for preamble in hermes-agent-preamble.md hermes-skill-preamble.md hermes-ethos.md; do
    if [[ -f "$REPO_ROOT/preambles/$preamble" ]]; then
        pass "preambles/$preamble exists"
    else
        fail "preambles/$preamble missing"
    fi
done

################################################################################
# 8. Workflow Error Handling Check
################################################################################

section "Workflow Files — Error Handling"

for f in "$REPO_ROOT"/workflows/*.md; do
    [[ ! -f "$f" ]] && continue
    name=$(basename "$f")

    if grep -q "## Error Handling" "$f" 2>/dev/null; then
        pass "$name — Error Handling section present"
    else
        warn "$name — missing Error Handling section (see protocols/error-handling.md)"
    fi
done

################################################################################
# Summary
################################################################################

echo ""
echo -e "${BLUE}=== SUMMARY ===${NC}"
echo -e "  Total checks: $TOTAL_CHECKS"
echo -e "  ${GREEN}PASS:${NC} $PASS_COUNT"
echo -e "  ${YELLOW}WARN:${NC} $WARN_COUNT"
echo -e "  ${RED}FAIL:${NC} $FAIL_COUNT"

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo ""
    echo -e "  ${GREEN}All checks passed. Hermes protocol compliance: 100%${NC}"
    exit 0
elif [[ $TOTAL_CHECKS -gt 0 ]]; then
    compliance=$(( (PASS_COUNT * 100) / TOTAL_CHECKS ))
    echo ""
    echo -e "  ${YELLOW}Hermes protocol compliance: ${compliance}%${NC}"
    exit 1
fi

#!/usr/bin/env bash
# LLM Configuration - Local/Cloud Agnostic
# Supports: Anthropic, OpenAI, Ollama, vLLM, any OpenAI-compatible endpoint
#
# Usage: source this file from haiku-client.sh or any script that calls LLM APIs.
#
# Environment variables (set any of these to override defaults):
#   LLM_PROVIDER    — anthropic | openai | ollama | vllm | custom
#   LLM_BASE_URL    — API endpoint base URL
#   LLM_API_KEY     — Authentication key/token
#   LLM_MODEL       — Model identifier
#   LLM_API_FORMAT  — anthropic | openai (response parsing format)
#   LLM_MAX_TOKENS  — Max output tokens (default: 8192)
#   LLM_TIMEOUT     — Request timeout in seconds (default: 30)

set -euo pipefail

################################################################################
# Provider Detection
################################################################################

LLM_PROVIDER="${LLM_PROVIDER:-anthropic}"

case "$LLM_PROVIDER" in
  anthropic)
    LLM_BASE_URL="${LLM_BASE_URL:-https://api.anthropic.com/v1}"
    LLM_API_KEY="${LLM_API_KEY:-${ANTHROPIC_AUTH_TOKEN:-}}"
    LLM_MODEL="${LLM_MODEL:-claude-haiku-4-5-20251001}"
    LLM_API_FORMAT="anthropic"
    ;;
  openai)
    LLM_BASE_URL="${LLM_BASE_URL:-https://api.openai.com/v1}"
    LLM_API_KEY="${LLM_API_KEY:-${OPENAI_API_KEY:-}}"
    LLM_MODEL="${LLM_MODEL:-gpt-4o-mini}"
    LLM_API_FORMAT="openai"
    ;;
  ollama)
    LLM_BASE_URL="${LLM_BASE_URL:-http://localhost:11434/v1}"
    LLM_API_KEY="${LLM_API_KEY:-ollama}"
    LLM_MODEL="${LLM_MODEL:-hermes3}"
    LLM_API_FORMAT="openai"
    ;;
  vllm)
    LLM_BASE_URL="${LLM_BASE_URL:-http://localhost:8000/v1}"
    LLM_API_KEY="${LLM_API_KEY:-token}"
    LLM_MODEL="${LLM_MODEL:-}"
    LLM_API_FORMAT="openai"
    ;;
  custom)
    LLM_BASE_URL="${LLM_BASE_URL:?LLM_BASE_URL required for custom provider}"
    LLM_API_KEY="${LLM_API_KEY:?LLM_API_KEY required for custom provider}"
    LLM_MODEL="${LLM_MODEL:?LLM_MODEL required for custom provider}"
    LLM_API_FORMAT="${LLM_API_FORMAT:-openai}"
    ;;
  *)
    echo "[LLM-CONFIG] ERROR: Unknown provider '$LLM_PROVIDER'" >&2
    echo "[LLM-CONFIG] Supported: anthropic, openai, ollama, vllm, custom" >&2
    exit 1
    ;;
esac

################################################################################
# Common Settings
################################################################################

LLM_MAX_TOKENS="${LLM_MAX_TOKENS:-8192}"
LLM_TIMEOUT="${LLM_TIMEOUT:-30}"

################################################################################
# Backward Compatibility
################################################################################

# Map legacy HAIKU_* vars for existing scripts
HAIKU_MODEL="${LLM_MODEL}"
HAIKU_MAX_TOKENS="${LLM_MAX_TOKENS}"
HAIKU_TIMEOUT="${LLM_TIMEOUT}"

################################################################################
# Unified API Call Function
################################################################################

# call_llm_api <prompt> [system_prompt] [max_tokens]
# Returns: response text on success, exits 1 on failure
call_llm_api() {
    local prompt="$1"
    local system_prompt="${2:-}"
    local max_tokens="${3:-$LLM_MAX_TOKENS}"

    if [[ -z "${LLM_API_KEY:-}" ]]; then
        echo "[LLM-CONFIG] ERROR: LLM_API_KEY not set (provider: $LLM_PROVIDER)" >&2
        return 1
    fi

    local response

    if [[ "$LLM_API_FORMAT" == "anthropic" ]]; then
        # Anthropic Messages API
        local body
        if [[ -n "$system_prompt" ]]; then
            body=$(jq -n \
                --arg model "$LLM_MODEL" \
                --argjson max_tokens "$max_tokens" \
                --arg system "$system_prompt" \
                --arg prompt "$prompt" \
                '{
                    model: $model,
                    max_tokens: $max_tokens,
                    system: $system,
                    messages: [{role: "user", content: $prompt}]
                }')
        else
            body=$(jq -n \
                --arg model "$LLM_MODEL" \
                --argjson max_tokens "$max_tokens" \
                --arg prompt "$prompt" \
                '{
                    model: $model,
                    max_tokens: $max_tokens,
                    messages: [{role: "user", content: $prompt}]
                }')
        fi

        response=$(curl -s --max-time "$LLM_TIMEOUT" \
            "${LLM_BASE_URL}/messages" \
            -H "x-api-key: $LLM_API_KEY" \
            -H "anthropic-version: 2023-06-01" \
            -H "content-type: application/json" \
            -d "$body")

        # Check for API errors
        if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
            local error_msg
            error_msg=$(echo "$response" | jq -r '.error.message')
            echo "[LLM-CONFIG] API error ($LLM_PROVIDER): $error_msg" >&2
            return 1
        fi

        echo "$response" | jq -r '.content[0].text' 2>/dev/null || return 1

    else
        # OpenAI-compatible API (OpenAI, Ollama, vLLM, custom)
        local messages
        if [[ -n "$system_prompt" ]]; then
            messages=$(jq -n \
                --arg system "$system_prompt" \
                --arg prompt "$prompt" \
                '[{role: "system", content: $system}, {role: "user", content: $prompt}]')
        else
            messages=$(jq -n \
                --arg prompt "$prompt" \
                '[{role: "user", content: $prompt}]')
        fi

        local body
        body=$(jq -n \
            --arg model "$LLM_MODEL" \
            --argjson max_tokens "$max_tokens" \
            --argjson messages "$messages" \
            '{
                model: $model,
                max_tokens: $max_tokens,
                messages: $messages
            }')

        response=$(curl -s --max-time "$LLM_TIMEOUT" \
            "${LLM_BASE_URL}/chat/completions" \
            -H "Authorization: Bearer $LLM_API_KEY" \
            -H "content-type: application/json" \
            -d "$body")

        # Check for API errors
        if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
            local error_msg
            error_msg=$(echo "$response" | jq -r '.error.message')
            echo "[LLM-CONFIG] API error ($LLM_PROVIDER): $error_msg" >&2
            return 1
        fi

        echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null || return 1
    fi
}

################################################################################
# ChatML Formatter (for local models that require it)
################################################################################

# format_chatml <system_prompt> <user_prompt>
# Returns: ChatML-formatted string
format_chatml() {
    local system="$1"
    local user="$2"
    printf '<|im_start|>system\n%s\n<|im_end|>\n<|im_start|>user\n%s\n<|im_end|>\n<|im_start|>assistant\n' "$system" "$user"
}

# Export functions for use by sourcing scripts
export -f call_llm_api format_chatml 2>/dev/null || true

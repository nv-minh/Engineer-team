#!/usr/bin/env bash
# Haiku Client for EM-Team Token Summarization
# Summarizes reports using Claude Haiku model to reduce token count

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/token-config.sh"
source "$SCRIPT_DIR/llm-config.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[HAIKU-CLIENT]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[HAIKU-CLIENT]${NC} $1"
}

log_error() {
    echo -e "${RED}[HAIKU-CLIENT]${NC} $1"
}

# Check if API key is set (provider-agnostic)
check_api_key() {
    if [[ -z "${LLM_API_KEY:-}" ]]; then
        log_error "LLM_API_KEY not set (provider: $LLM_PROVIDER)"
        log_error "Set LLM_API_KEY or ANTHROPIC_AUTH_TOKEN environment variable"
        return 1
    fi
    return 0
}

# Call LLM API (provider-agnostic, delegates to llm-config.sh)
# Backward-compatible wrapper — call_haiku_api still works
call_haiku_api() {
    local prompt="$1"
    local max_tokens=${2:-$LLM_MAX_TOKENS}

    if ! check_api_key; then
        return 1
    fi

    call_llm_api "$prompt" "" "$max_tokens"
}

# Load summarization prompt template
load_prompt_template() {
    local template_file="$SCRIPT_DIR/haiku-summarize-prompt.txt"

    if [[ -f "$template_file" ]]; then
        cat "$template_file"
    else
        # Fallback inline prompt
        cat << 'EOF'
You are tasked with summarizing a markdown report to reduce its token count while preserving critical information.

## Report to Summarize:
<REPORT>
{{REPORT_CONTENT}}
</REPORT>

## Preservation Rules:

### 100% Preserve (Must Keep):
- YAML frontmatter (report_id, agent, status, score)
- Overall status and confidence scores
- Critical issues table (all columns)
- High issues table (all columns)
- Blocking issues list
- Ready-to-proceed flag
- Scorecard overall score

### 80% Preserve (Condense):
- Executive summary (2-3 sentences)
- Medium issues (counts only)
- Immediate action recommendations (bullet points)
- Key findings (summary)

### 30% Preserve (Summarize):
- Detailed analysis sections
- Code examples (keep snippets only)
- Verbose explanations
- Low priority issues
- Long descriptions

## Output Format:

Return a summarized markdown report that:
1. Maintains the same structure as the original
2. Preserves YAML frontmatter exactly
3. Condenses content according to preservation rules
4. Is significantly shorter in token count
5. Retains all decision-critical information

Begin the summarized report now.
EOF
    fi
}

# Summarize report using Haiku
summarize_report() {
    local input_file="$1"
    local output_file="$2"
    local target_tokens=${3:-$TARGET_SUMMARY_SIZE}

    if [[ ! -f "$input_file" ]]; then
        log_error "Input file not found: $input_file"
        return 1
    fi

    log_info "Summarizing report: $input_file"
    log_info "Target token count: $target_tokens"

    # Read input report
    local report_content
    report_content=$(cat "$input_file")

    # Extract YAML frontmatter
    local yaml_frontmatter
    yaml_frontmatter=$(echo "$report_content" | awk ' /^---$/ { if (++count == 2) exit; next; } count >= 1 { print; }')

    # Get body content (after YAML)
    local body_content
    body_content=$(echo "$report_content" | awk ' BEGIN { count = 0; skip = 1; } /^---$/ { count++; if (count == 2) skip = 0; next; } skip == 0 { print; }')

    # Load prompt template
    local prompt_template
    prompt_template=$(load_prompt_template)

    # Replace placeholders in prompt
    local prompt
    prompt=$(echo "$prompt_template" | sed "s|{{REPORT_CONTENT}}|$body_content|g")

    # Add target tokens to prompt
    prompt="$prompt

Target approximately $target_tokens tokens for the body content (YAML frontmatter will be added separately)."

    # Call Haiku API with retries
    local summarized_body=""
    local retry_count=0

    while [[ $retry_count -lt $HAIKU_MAX_RETRIES ]]; do
        log_info "Calling Haiku API (attempt $((retry_count + 1))/$HAIKU_MAX_RETRIES)..."

        if summarized_body=$(call_haiku_api "$prompt"); then
            break
        fi

        retry_count=$((retry_count + 1))

        if [[ $retry_count -lt $HAIKU_MAX_RETRIES ]]; then
            local wait_time=$((2 ** retry_count))
            log_warn "Retrying in ${wait_time}s..."
            sleep "$wait_time"
        fi
    done

    if [[ -z "$summarized_body" ]]; then
        log_error "Failed to summarize after $HAIKU_MAX_RETRIES attempts"
        return 1
    fi

    # Combine YAML frontmatter with summarized body
    echo "$yaml_frontmatter" > "$output_file"
    echo "" >> "$output_file"
    echo "$summarized_body" >> "$output_file"

    # Update YAML frontmatter with summarization metadata
    update_summarization_metadata "$output_file" "$input_file"

    log_info "Summarized report saved to: $output_file"
}

# Update YAML frontmatter with summarization metadata
update_summarization_metadata() {
    local summarized_file="$1"
    local original_file="$2"
    local method="${3:-haiku}"

    # Get token counts
    local original_tokens=$("$SCRIPT_DIR/token-counter.sh" estimate "$original_file")
    local summarized_tokens=$("$SCRIPT_DIR/token-counter.sh" estimate "$summarized_file")

    # Get current timestamp
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Add summarization metadata to YAML frontmatter
    local temp_file=$(mktemp)

    awk -v timestamp="$timestamp" \
        -v original="$original_tokens" \
        -v summarized="$summarized_tokens" \
        -v method="$method" '
        /^---$/ { in_header = 1; next }
        in_header && /^---$/ {
            in_header = 0
            print "summarized: true"
            print "original_token_count: " original
            print "summarized_token_count: " summarized
            print "summarization_method: " method
            print "summarization_timestamp: " timestamp
            print ""
            print "---"
            next
        }
        { print }
    ' "$summarized_file" > "$temp_file"

    mv "$temp_file" "$summarized_file"

    log_info "Original tokens: $original_tokens"
    log_info "Summarized tokens: $summarized_tokens"

    # Calculate reduction percentage (avoid division by zero)
    if [[ $original_tokens -gt 0 ]]; then
        local reduction=$((100 * (original_tokens - summarized_tokens) / original_tokens))
        log_info "Reduction: ${reduction}%"
    fi
}

# Rule-based summarization (fallback)
summarize_rule_based() {
    local input_file="$1"
    local output_file="$2"

    log_warn "Using rule-based summarization (fallback)"

    if [[ ! -f "$input_file" ]]; then
        log_error "Input file not found: $input_file"
        return 1
    fi

    # Extract YAML frontmatter
    local yaml_frontmatter
    yaml_frontmatter=$(awk ' /^---$/ { if (++count == 2) exit; next; } count >= 1 { print; }' "$input_file")

    # Extract body content
    local body_content
    body_content=$(awk ' BEGIN { count = 0; skip = 1; } /^---$/ { count++; if (count == 2) skip = 0; next; } skip == 0 { print; }' "$input_file")

    # Apply rule-based summarization
    local summarized_body
    summarized_body=$(echo "$body_content" | awk '
        # Keep headings
        /^#{1,6}/ { print; next }

        # Keep list items (but limit verbose descriptions)
        /^[-*]/ {
            if (length($0) > 200) {
                print substr($0, 1, 200) "..."
            } else {
                print
            }
            next
        }

        # Skip very long paragraphs
        /^[A-Z]/ {
            if (length($0) > 300) {
                print substr($0, 1, 300) "..."
            } else {
                print
            }
            next
        }

        # Skip code blocks (keep only first 5 lines)
        /^```/ {
            in_code = 1
            print
            code_line_count = 0
            next
        }

        in_code && /^```/ {
            in_code = 0
            print
            next
        }

        in_code {
            if (code_line_count < 5) {
                print
            }
            code_line_count++
            next
        }

        # Print other lines
        { print }
    ')

    # Combine and save
    echo "$yaml_frontmatter" > "$output_file"
    echo "" >> "$output_file"
    echo "$summarized_body" >> "$output_file"

    # Update metadata with rule_based method
    update_summarization_metadata "$output_file" "$input_file" "rule_based"

    log_info "Rule-based summary saved to: $output_file"
}

# Main entry point
main() {
    case "${1:-}" in
        summarize)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                log_error "Usage: $0 summarize <input-file> <output-file> [target-tokens]"
                exit 1
            fi
            summarize_report "$2" "$3" "${4:-$TARGET_SUMMARY_SIZE}"
            ;;
        summarize-rule-based)
            if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
                log_error "Usage: $0 summarize-rule-based <input-file> <output-file>"
                exit 1
            fi
            summarize_rule_based "$2" "$3"
            ;;
        test-api)
            log_info "Testing Haiku API..."
            if check_api_key; then
                local test_result=$(call_haiku_api "Say 'Hello, World!'" 100)
                if [[ -n "$test_result" ]]; then
                    log_info "API test successful"
                    echo "Response: $test_result"
                else
                    log_error "API test failed"
                    exit 1
                fi
            else
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 {summarize|summarize-rule-based|test-api}"
            echo ""
            echo "Commands:"
            echo "  summarize <input> <output> [target]  - Summarize using Haiku"
            echo "  summarize-rule-based <input> <output> - Summarize using rules (fallback)"
            echo "  test-api                            - Test Haiku API connectivity"
            echo ""
            echo "Examples:"
            echo "  $0 summarize report.md report.summarized.md 80000"
            echo "  $0 summarize-rule-based report.md report.summarized.md"
            exit 1
            ;;
    esac
}

# If script is executed (not sourced), run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

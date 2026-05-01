#!/bin/bash

################################################################################
# Report Consolidator for EM-Team Distributed Orchestration
#
# Description: Collects and consolidates reports from multiple agent sessions
# Usage: ./consolidate-reports.sh [command] [options]
################################################################################

set -euo pipefail

# Configuration
SESSION_NAME="claude-work"
SHARED_DIR="/tmp/claude-work-reports"
QUEUE_DIR="/tmp/claude-work-queue"
OUTPUT_DIR="$SHARED_DIR/techlead"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

################################################################################
# List available reports
################################################################################

list_reports() {
    log_info "Available reports:"
    echo ""

    if [[ ! -d "$SHARED_DIR" ]]; then
        log_warning "Shared reports directory not found"
        return 1
    fi

    local found_reports=false

    for agent_dir in "$SHARED_DIR"/*; do
        if [[ -d "$agent_dir" ]]; then
            local agent=$(basename "$agent_dir")
            local reports=$(find "$agent_dir" -type f \( -name "*.md" -o -name "*.json" \) 2>/dev/null)

            if [[ -n "$reports" ]]; then
                $found_reports && echo ""
                found_reports=true
                log_info "$agent:"
                echo "$reports" | while read -r report; do
                    local filename=$(basename "$report")
                    local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$report" 2>/dev/null || stat -c "%y" "$report" 2>/dev/null | cut -d'.' -f1)
                    local size=$(du -h "$report" | cut -f1)
                    echo "  - $filename ($size, $modified)"
                done
            fi
        fi
    done

    if ! $found_reports; then
        log_warning "No reports found"
    fi
}

################################################################################
# Parse report YAML frontmatter
################################################################################

parse_report() {
    local report_file=$1

    if [[ ! -f "$report_file" ]]; then
        log_error "Report not found: $report_file"
        return 1
    fi

    # Extract YAML frontmatter (between --- markers)
    local yaml_content=$(sed -n '/^---$/,/^---$/p' "$report_file" | sed '1d;$d')

    # Parse key values
    echo "$yaml_content" | grep -E "^(report_id|generated|agent|task_id|status|overall):" | sed 's/: /: /' || true
}

################################################################################
# Collect reports from agents
################################################################################

collect_reports() {
    local agents=("$@")

    if [[ ${#agents[@]} -eq 0 ]]; then
        # Auto-detect agents with reports
        agents=()
        for agent_dir in "$SHARED_DIR"/*; do
            if [[ -d "$agent_dir" ]]; then
                local agent=$(basename "$agent_dir")
                if [[ "$agent" != "techlead" ]] && [[ "$agent" != "consolidated" ]]; then
                    # Check if agent has any reports
                    if compgen -G "$agent_dir"/*.md > /dev/null 2>&1 || compgen -G "$agent_dir"/*.json > /dev/null 2>&1; then
                        agents+=("$agent")
                    fi
                fi
            fi
        done
    fi

    if [[ ${#agents[@]} -eq 0 ]]; then
        log_warning "No agents with reports found"
        return 1
    fi

    log_info "Collecting reports from: ${agents[*]}"
    echo ""

    mkdir -p "$OUTPUT_DIR"

    local collected_reports=()

    for agent in "${agents[@]}"; do
        local agent_dir="$SHARED_DIR/$agent"

        if [[ ! -d "$agent_dir" ]]; then
            log_warning "Agent directory not found: $agent"
            continue
        fi

        # Find latest report
        local latest_report=$(find "$agent_dir" -type f \( -name "*.md" -o -name "*.json" \) -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)

        if [[ -z "$latest_report" ]]; then
            log_warning "No report found for: $agent"
            continue
        fi

        log_success "Found report for $agent: $(basename "$latest_report")"
        collected_reports+=("$latest_report")

        # Parse and display summary
        echo ""
        echo "  Report Details:"
        parse_report "$latest_report" | while read -r line; do
            echo "    $line"
        done
        echo ""
    done

    if [[ ${#collected_reports[@]} -eq 0 ]]; then
        log_error "No reports collected"
        return 1
    fi

    log_success "Collected ${#collected_reports[@]} reports"
    return 0
}

################################################################################
# Check and summarize reports if needed
################################################################################

check_and_summarize_reports() {
    local reports=("$@")
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "$script_dir/token-config.sh"

    log_info "Checking token counts of individual reports..."

    local reports_to_summarize=()
    local total_tokens=0

    for report_spec in "${reports[@]}"; do
        local agent="${report_spec%%:*}"
        local report_file="${report_spec#*:}"

        if [[ ! -f "$report_file" ]]; then
            log_warning "Report file not found: $report_file"
            continue
        fi

        # Estimate token count
        local token_count=$("$script_dir/token-counter.sh" estimate "$report_file")
        total_tokens=$((total_tokens + token_count))

        log_info "  $agent: $token_count tokens"

        # Check if exceeds threshold
        if [[ $token_count -gt $SUMMARIZATION_THRESHOLD ]]; then
            log_warning "    Exceeds threshold ($SUMMARIZATION_THRESHOLD), will summarize"
            reports_to_summarize+=("$agent:$report_file")
        fi
    done

    log_info "Total tokens before consolidation: $total_tokens"

    # Summarize reports that exceed threshold
    if [[ ${#reports_to_summarize[@]} -gt 0 ]]; then
        log_info "Summarizing ${#reports_to_summarize[@]} reports..."

        for report_spec in "${reports_to_summarize[@]}"; do
            local agent="${report_spec%%:*}"
            local report_file="${report_spec#*:}"
            local summarized_file="${report_file%.md}.summarized.md"

            log_info "  Summarizing $agent report..."

            # Try Haiku first, fallback to rule-based
            if ! "$script_dir/haiku-client.sh" summarize "$report_file" "$summarized_file" "$TARGET_SUMMARY_SIZE" 2>/dev/null; then
                log_warning "    Haiku failed, using rule-based summarization"
                "$script_dir/haiku-client.sh" summarize-rule-based "$report_file" "$summarized_file"
            fi

            # Update reports array to use summarized version
            for i in "${!reports[@]}"; do
                if [[ "${reports[$i]}" == "$report_spec" ]]; then
                    reports[$i]="$agent:$summarized_file"
                    break
                fi
            done
        done
    fi

    # Return updated reports array
    printf '%s\n' "${reports[@]}"
}

################################################################################
# Consolidate reports for a specific task (called by auto-delegate.sh)
################################################################################

consolidate_task_reports() {
    local task_id="$1"
    local agents="$2"
    local output_file="$OUTPUT_DIR/${task_id}-consolidated.md"

    log_info "════════════════════════════════════════════════════════════════"
    log_info "Consolidating reports for task: $task_id"
    log_info "════════════════════════════════════════════════════════════════"
    echo ""

    mkdir -p "$OUTPUT_DIR"

    # Collect reports for this specific task
    local reports=()
    local agent_array=(${agents//,/ })

    for agent in "${agent_array[@]}"; do
        local report_file="$SHARED_DIR/$agent/${task_id}-report.md"

        if [[ -f "$report_file" ]]; then
            reports+=("$agent:$report_file")
            log_success "Found report for $agent"
        else
            log_warning "Report not found for $agent: $report_file"
        fi
    done

    if [[ ${#reports[@]} -eq 0 ]]; then
        log_error "No reports found for task $task_id"
        return 1
    fi

    log_info "Found ${#reports[@]}/${#agent_array[@]} reports"
    echo ""

    # Create consolidated report
    create_consolidated_report "$output_file" "$task_id" "${reports[@]}"

    return 0
}

################################################################################
# Create consolidated report content
################################################################################

create_consolidated_report() {
    local output_file="$1"
    local task_id="$2"
    shift 2
    local reports=("$@")

    log_info "Creating consolidated report..."
    echo ""

    # Start building the report
    {
        echo "# Consolidated Distributed Investigation Report"
        echo ""
        echo "**Report ID:** TEAM-RPT-$(date +%Y%m%d-%H%M%S)"
        echo "**Task ID:** $task_id"
        echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "**Orchestrator:** Tech Lead (Distributed)"
        echo "**Agents Involved:** $(echo "${reports[@]}" | sed 's/:.*//g' | tr '\n' ', ' | sed 's/,$//')"
        echo ""
        echo "---"
        echo ""
        echo "## Executive Summary"
        echo ""
        echo "**Overall Status:** Investigation complete"
        echo "**Agents Responded:** ${#reports[@]}/$(echo "${reports[@]}" | wc -l | xargs)"
        echo ""
        echo "---"
        echo ""
        echo "## Agent Reports Summary"
        echo ""

        # Add each agent's summary
        for report_spec in "${reports[@]}"; do
            local agent="${report_spec%%:*}"
            local report_file="${report_spec#*:}"

            echo "### $agent Agent"
            echo ""

            # Extract summary from report if available
            if grep -q "^## Summary" "$report_file"; then
                sed -n '/^## Summary/,/^##/p' "$report_file" | head -n -1 | tail -n +2
            elif grep -q "^## Executive Summary" "$report_file"; then
                sed -n '/^## Executive Summary/,/^##/p' "$report_file" | head -n -1 | tail -n +2
            else
                echo "Report available at: \`$report_file\`"
            fi

            echo ""
            echo "**Report:** \`$report_file\`"
            echo ""
            echo "---"
            echo ""
        done

        echo "## Consolidated Findings"
        echo ""
        echo "### Critical Issues (Must Fix - Block Deployment)"
        echo ""
        echo "| Issue | Agent | Impact | Fix | Effort |"
        echo "|-------|-------|--------|-----|--------|"
        echo ""

        # Extract critical issues from each report
        local has_critical=false
        for report_spec in "${reports[@]}"; do
            local agent="${report_spec%%:*}"
            local report_file="${report_spec#*:}"

            # Try to extract critical issues
            if grep -q "### Critical" "$report_file"; then
                awk '/### Critical/,/### High|### Medium|### Low|##/' "$report_file" | grep '^|' | grep -v '^---' | while read -r line; do
                    # Skip header row
                    if [[ "$line" =~ \|.*Issue.*\| ]]; then
                        continue
                    fi

                    # Parse table row
                    local issue=$(echo "$line" | cut -d'|' -f2 | xargs)
                    local impact=$(echo "$line" | cut -d'|' -f3 | xargs)
                    local fix=$(echo "$line" | cut -d'|' -f4 | xargs)
                    local effort=$(echo "$line" | cut -d'|' -f5 | xargs)

                    if [[ -n "$issue" && "$issue" != "Issue" ]]; then
                        echo "| $issue | $agent | $impact | $fix | ${effort:-TBD} |"
                        has_critical=true
                    fi
                done
            fi
        done

        if ! $has_critical; then
            echo "| No critical issues found | - | - | - | - |"
        fi

        echo ""
        echo "### High Issues (Should Fix - Block Merge)"
        echo ""
        echo "| Issue | Agent | Impact | Fix | Effort |"
        echo "|-------|-------|--------|-----|--------|"
        echo ""

        # Extract high issues from each report
        local has_high=false
        for report_spec in "${reports[@]}"; do
            local agent="${report_spec%%:*}"
            local report_file="${report_spec#*:}"

            # Try to extract high issues
            if grep -q "### High" "$report_file"; then
                awk '/### High/,/### Medium|### Low|##/' "$report_file" | grep '^|' | grep -v '^---' | while read -r line; do
                    # Skip header row
                    if [[ "$line" =~ \|.*Issue.*\| ]]; then
                        continue
                    fi

                    local issue=$(echo "$line" | cut -d'|' -f2 | xargs)
                    local impact=$(echo "$line" | cut -d'|' -f3 | xargs)
                    local fix=$(echo "$line" | cut -d'|' -f4 | xargs)
                    local effort=$(echo "$line" | cut -d'|' -f5 | xargs)

                    if [[ -n "$issue" && "$issue" != "Issue" ]]; then
                        echo "| $issue | $agent | $impact | $fix | ${effort:-TBD} |"
                        has_high=true
                    fi
                done
            fi
        done

        if ! $has_high; then
            echo "| No high issues found | - | - | - | - |"
        fi

        echo ""
        echo "## Recommendations"
        echo ""

        # Extract recommendations from each report
        for report_spec in "${reports[@]}"; do
            local agent="${report_spec%%:*}"
            local report_file="${report_spec#*:}"

            echo "### From $agent Agent"
            echo ""

            if grep -q "## Recommendations" "$report_file"; then
                sed -n '/## Recommendations/,/^##/p' "$report_file" | head -n -1 | tail -n +2
            else
                echo "_No recommendations section found_"
            fi

            echo ""
        done

        echo ""
        echo "---"
        echo ""
        echo "## Next Steps"
        echo ""
        echo "Based on the consolidated findings, the following actions are recommended:"
        echo ""

        # Generate action items
        echo "1. **Review all critical issues** - Address immediately"
        echo "2. **Address high-priority items** - Before next merge"
        echo "3. **Implement recommended fixes** - Following agent guidance"
        echo "4. **Verify fixes** - Re-run investigation to confirm resolution"
        echo ""

        echo ""
        echo "---"
        echo ""
        echo "**Report Version:** 1.0.0"
        echo "**Generated by:** Report Consolidator (Auto-Delegation Integration)"
        echo "**Task ID:** $task_id"
        echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "**Validation:** ✅ Consolidated"

    } > "$output_file"

    log_success "Consolidated report created: $output_file"

    # Show report info
    echo ""
    log_info "Report Summary:"
    echo "  File: $output_file"
    echo "  Agents: ${#reports[@]}"
    echo "  Size: $(du -h "$output_file" | cut -f1)"
    echo ""
}

################################################################################
# Consolidate reports (original function for backward compatibility)
################################################################################

consolidate() {
    local output_file=${1:-"$OUTPUT_DIR/consolidated-report-$(date +%Y%m%d-%H%M%S).md"}
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    log_info "Consolidating reports..."

    mkdir -p "$OUTPUT_DIR"

    # Collect reports
    local reports=()
    for agent_dir in "$SHARED_DIR"/*; do
        if [[ -d "$agent_dir" ]]; then
            local agent=$(basename "$agent_dir")
            if [[ "$agent" != "techlead" ]] && [[ "$agent" != "consolidated" ]]; then
                local latest_report=$(find "$agent_dir" -type f \( -name "*.md" -o -name "*.json" \) -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
                if [[ -n "$latest_report" ]]; then
                    reports+=("$agent:$latest_report")
                fi
            fi
        fi
    done

    if [[ ${#reports[@]} -eq 0 ]]; then
        log_error "No reports to consolidate"
        return 1
    fi

    log_info "Found ${#reports[@]} reports to consolidate"

    # Check and summarize reports if needed
    local summarized_reports=($(check_and_summarize_reports "${reports[@]}"))
    reports=("${summarized_reports[@]}")

    # Create consolidated report
    {
        echo "# Consolidated Team Report"
        echo ""
        echo "**Report ID:** TEAM-RPT-$(date +%Y%m%d-%H%M%S)"
        echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "**Orchestrator:** Tech Lead"
        echo "**Agents Involved:** $(echo "${reports[@]}" | sed 's/:.*//g' | tr '\n' ', ' | sed 's/,$//')"
        echo ""
        echo "---"
        echo ""
        echo "## Executive Summary"
        echo ""
        echo "This report consolidates findings from ${#reports[@]} agents."
        echo ""
        echo "---"
        echo ""
        echo "## Agent Reports Summary"
        echo ""

        # Add each agent's summary
        for report_spec in "${reports[@]}"; do
            local agent="${report_spec%%:*}"
            local report_file="${report_spec#*:}"

            echo "### $agent"
            echo ""

            # Try to extract overall status from report
            if grep -q "Overall Status:" "$report_file"; then
                grep "Overall Status:" "$report_file" | sed 's/^**Overall Status:** //' | head -1
            else
                echo "Status: Report received"
            fi

            echo ""
            echo "**Report:** \`$report_file\`"
            echo ""
            echo "---"
            echo ""
        done

        echo "## Consolidated Findings"
        echo ""
        echo "This section consolidates findings from all agent reports."
        echo ""
        echo "### Critical Issues (Must Fix)"
        echo ""
        echo "| Issue | Agent | Impact | Fix |"
        echo "|-------|-------|--------|-----|"
        echo ""

        # Extract critical issues from each report
        for report_spec in "${reports[@]}"; do
            local agent="${report_spec%%:*}"
            local report_file="${report_spec#*:}"

            # Try to extract critical issues table
            awk '/### Critical Issues/,/### High Issues/' "$report_file" | grep '^|' | grep -v '^---' | tail -n +2 | while read -r line; do
                # Format: | Issue | Impact | Fix | Effort |
                # We need to inject the agent name
                local issue=$(echo "$line" | cut -d'|' -f2 | xargs)
                local impact=$(echo "$line" | cut -d'|' -f3 | xargs)
                local fix=$(echo "$line" | cut -d'|' -f4 | xargs)

                if [[ -n "$issue" && "$issue" != "Issue" ]]; then
                    echo "| $issue | $agent | $impact | $fix |"
                fi
            done
        done

        echo ""
        echo "### High Issues (Should Fix)"
        echo ""
        echo "| Issue | Agent | Impact | Fix |"
        echo "|-------|-------|--------|-----|"
        echo ""

        # Extract high issues from each report
        for report_spec in "${reports[@]}"; do
            local agent="${report_spec%%:*}"
            local report_file="${report_spec#*:}"

            awk '/### High Issues/,/### Medium Issues/' "$report_file" | grep '^|' | grep -v '^---' | tail -n +2 | while read -r line; do
                local issue=$(echo "$line" | cut -d'|' -f2 | xargs)
                local impact=$(echo "$line" | cut -d'|' -f3 | xargs)
                local fix=$(echo "$line" | cut -d'|' -f4 | xargs)

                if [[ -n "$issue" && "$issue" != "Issue" ]]; then
                    echo "| $issue | $agent | $impact | $fix |"
                fi
            done
        done

        echo ""
        echo "---"
        echo ""
        echo "**Report Version:** 1.0.0"
        echo "**Generated by:** Report Consolidator"
        echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"

    } > "$output_file"

    log_success "Consolidated report created: $output_file"

    # Check token count of consolidated report
    local consolidated_tokens=$("$script_dir/token-counter.sh" estimate "$output_file")
    log_info "Consolidated report token count: $consolidated_tokens"

    source "$script_dir/token-config.sh"

    # Summarize consolidated report if exceeds threshold
    if [[ $consolidated_tokens -gt $((TOKEN_BUDGET - SAFETY_MARGIN)) ]]; then
        log_warning "Consolidated report exceeds safe budget, summarizing..."

        local summarized_output_file="${output_file%.md}.summarized.md"

        # Try Haiku first, fallback to rule-based
        if ! "$script_dir/haiku-client.sh" summarize "$output_file" "$summarized_output_file" "$TARGET_SUMMARY_SIZE" 2>/dev/null; then
            log_warning "Haiku failed, using rule-based summarization"
            "$script_dir/haiku-client.sh" summarize-rule-based "$output_file" "$summarized_output_file"
        fi

        log_success "Summarized consolidated report: $summarized_output_file"

        # Update output_file to point to summarized version
        output_file="$summarized_output_file"
    fi

    # Show summary
    echo ""
    log_info "Report Summary:"
    echo "  File: $output_file"
    echo "  Agents: ${#reports[@]}"
    echo "  Size: $(du -h "$output_file" | cut -f1)"
    echo "  Tokens: $("$script_dir/token-counter.sh" estimate "$output_file")"

    return 0
}

################################################################################
# Show report statistics
################################################################################

stats() {
    log_info "Report Statistics"
    echo ""

    if [[ ! -d "$SHARED_DIR" ]]; then
        log_warning "Shared reports directory not found"
        return 1
    fi

    local total_reports=0
    local total_size=0
    local agents_with_reports=0

    for agent_dir in "$SHARED_DIR"/*; do
        if [[ -d "$agent_dir" ]]; then
            local agent=$(basename "$agent_dir")
            local agent_reports=$(find "$agent_dir" -type f \( -name "*.md" -o -name "*.json" \) 2>/dev/null | wc -l)

            if [[ $agent_reports -gt 0 ]]; then
                ((agents_with_reports++))
                ((total_reports += agent_reports))

                local agent_size=$(du -sk "$agent_dir" | cut -f1)
                ((total_size += agent_size))

                log_info "$agent: $agent_reports reports"
            fi
        fi
    done

    echo ""
    log_info "Summary:"
    echo "  Agents with reports: $agents_with_reports"
    echo "  Total reports: $total_reports"
    echo "  Total size: $((total_size / 1024))M"
}

################################################################################
# Validate report format
################################################################################

validate() {
    local report_file=$1

    if [[ -z "$report_file" ]]; then
        log_error "Usage: validate <report_file>"
        return 1
    fi

    if [[ ! -f "$report_file" ]]; then
        log_error "Report not found: $report_file"
        return 1
    fi

    log_info "Validating report: $report_file"
    echo ""

    local valid=true
    local errors=()

    # Check for YAML frontmatter
    if ! head -1 "$report_file" | grep -q '^---$'; then
        errors+=("Missing YAML frontmatter start marker")
        valid=false
    fi

    # Check for required fields
    local required_fields=("report_id" "generated" "agent" "task_id")
    local yaml_content=$(sed -n '/^---$/,/^---$/p' "$report_file" | sed '1d;$d')

    for field in "${required_fields[@]}"; do
        if ! echo "$yaml_content" | grep -q "^${field}:"; then
            errors+=("Missing required field: $field")
            valid=false
        fi
    done

    # Check for required sections
    local required_sections=("Executive Summary" "Findings" "Recommendations")
    for section in "${required_sections[@]}"; do
        if ! grep -q "^## ${section}" "$report_file"; then
            errors+=("Missing required section: $section")
            valid=false
        fi
    done

    if $valid; then
        log_success "Report is valid"
        return 0
    else
        log_error "Report validation failed"
        echo ""
        log_info "Errors:"
        for error in "${errors[@]}"; do
            echo "  - $error"
        done
        return 1
    fi
}

################################################################################
# Show help
################################################################################

show_help() {
    cat << EOF
Report Consolidator for EM-Team Distributed Orchestration

Usage: $0 [command] [options]

Commands:
    list                        List available reports from all agents
    collect [agent ...]         Collect reports from specified agents (or all)
    consolidate [output]        Consolidate all reports into single report
    consolidate-task <task_id> [agents]  Consolidate reports for specific task
    stats                       Show report statistics
    validate <report>           Validate report format
    help                        Show this help message

Examples:
    $0 list                                 # List all reports
    $0 collect                              # Collect reports from all agents
    $0 collect backend frontend             # Collect from specific agents
    $0 consolidate                          # Create consolidated report
    $0 consolidate /path/to/output.md       # Create report at specific path
    $0 consolidate-task TASK-20260419-143022 backend,frontend,database
    $0 stats                                # Show statistics
    $0 validate /tmp/claude-work-reports/backend/report.md

Shared Directory: $SHARED_DIR
Output Directory: $OUTPUT_DIR

EOF
}

################################################################################
# Main
################################################################################

main() {
    local command=${1:-help}

    case "$command" in
        list|ls)
            list_reports
            ;;
        collect)
            shift
            collect_reports "$@"
            ;;
        consolidate)
            consolidate "${2:-}"
            ;;
        consolidate-task)
            # New command for auto-delegate.sh integration
            if [[ -z "${2:-}" ]]; then
                log_error "Usage: $0 consolidate-task <task_id> [agents]"
                exit 1
            fi
            consolidate_task_reports "$2" "${3:-}"
            ;;
        stats)
            stats
            ;;
        validate)
            validate "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main
main "$@"

#!/bin/bash

################################################################################
# Report Consolidator for EM-Skill Distributed Orchestration
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
# Consolidate reports
################################################################################

consolidate() {
    local output_file=${1:-"$OUTPUT_DIR/consolidated-report-$(date +%Y%m%d-%H%M%S).md"}

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

    # Show summary
    echo ""
    log_info "Report Summary:"
    echo "  File: $output_file"
    echo "  Agents: ${#reports[@]}"
    echo "  Size: $(du -h "$output_file" | cut -f1)"

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
Report Consolidator for EM-Skill Distributed Orchestration

Usage: $0 [command] [options]

Commands:
    list                        List available reports from all agents
    collect [agent ...]         Collect reports from specified agents (or all)
    consolidate [output]        Consolidate all reports into single report
    stats                       Show report statistics
    validate <report>           Validate report format
    help                        Show this help message

Examples:
    $0 list                                 # List all reports
    $0 collect                              # Collect reports from all agents
    $0 collect backend frontend             # Collect from specific agents
    $0 consolidate                          # Create consolidated report
    $0 consolidate /path/to/output.md       # Create report at specific path
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

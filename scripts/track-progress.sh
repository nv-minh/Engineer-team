#!/bin/bash

################################################################################
# Progress Tracking Dashboard for Techlead
#
# Description: Real-time progress monitoring of distributed agents
# Usage: ./scripts/track-progress.sh [task_id]
################################################################################

set -euo pipefail

SHARED_DIR="/tmp/claude-work-reports"
QUEUE_DIR="/tmp/claude-work-queue"
TASK_ID="${1:-}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Get latest task ID if not provided
if [[ -z "$TASK_ID" ]]; then
    TASK_ID=$(ls -t "$QUEUE_DIR"/to-*/*.yaml 2>/dev/null | head -1 | xargs -I {} basename {} .yaml)
    if [[ -z "$TASK_ID" ]]; then
        echo "No active tasks found"
        exit 1
    fi
fi

show_dashboard() {
    clear
    echo "╔════════════════════════════════════════════════════════════════════"
    echo "║          📊 DISTRIBUTED TASK PROGRESS DASHBOARD                     ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  Task ID: ${BOLD}${TASK_ID}${NC}                                                "
    echo "║  Refresh: $(date '+%Y-%m-%d %H:%M:%S')                                            "
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""

    # Agent status
    echo "┌─────────────────────────────────────────────────────────────────────┐"
    echo "│  🤖 AGENT STATUS                                                              │"
    echo "└─────────────────────────────────────────────────────────────────────┘"
    echo ""

    local agents=("frontend" "backend" "database")
    local total_agents=${#agents[@]}
    local active_agents=0

    for agent in "${agents[@]}"; do
        local report_file="$SHARED_DIR/$agent/${TASK_ID}-report.md"
        local task_file="$QUEUE_DIR/to-$agent/${TASK_ID}.yaml"
        
        # Check status
        local status="⏳ Waiting"
        local status_color="${YELLOW}"
        local activity="-"
        local tool_uses="-"
        local file_changed="-"

        if [[ -f "$report_file" ]]; then
            status="✅ Complete"
            status_color="${GREEN}"
            ((active_agents++))
            
            # Extract info from report
            if grep -q "tool uses" "$report_file" 2>/dev/null; then
                tool_uses=$(grep "tool uses" "$report_file" | head -1 | grep -o "[0-9]*" || echo "0")
            fi
            
            if grep -q "Updated:" "$report_file" 2>/dev/null; then
                file_changed=$(grep "Updated:" "$report_file" | head -1 | sed 's/Updated: //' || echo "-")
            fi
        elif [[ -f "$task_file" ]]; then
            status="🔧 In Progress"
            status_color="${BLUE}"
            ((active_agents++))
            
            # Try to get current action from tmux
            local window_name="$agent"
            if tmux has-session -t claude-work 2>/dev/null; then
                # Capture last few lines from window
                local recent_activity=$(tmux capture-pane -t claude-work:${window_name} -p -S - | tail -5 | head -1)
                activity="$recent_activity"
            fi
        fi

        # Display agent status
        echo -e "  ${status_color}${status}${NC} ${BOLD}${agent^^}${NC}"
        echo "     Activity: $([[ ! -z "$activity" ]] && echo "$activity" || echo "Working...")"
        echo "     Tools: $([[ "$tool_uses" != "-" ]] && echo "$tool_uses uses" || echo "-")"
        echo "     File: $([[ "$file_changed" != "-" ]] && echo "$file_changed" || echo "-")"
        echo ""
    done

    # Progress bar
    echo "┌─────────────────────────────────────────────────────────────────────┐"
    echo "│  📈 OVERALL PROGRESS                                                          │"
    echo "└─────────────────────────────────────────────────────────────────────┘"
    echo ""

    local progress_percent=$((active_agents * 100 / total_agents))
    local bar_length=50
    local filled_length=$((bar_length * active_agents / total_agents))
    local empty_length=$((bar_length - filled_length))

    echo -n "  ["
    printf "${GREEN}%${filled_length}s${NC}" "" | tr ' ' '█'
    printf "${NC}%${empty_length}s${NC}" "" | tr ' ' '░'
    echo "] ${progress_percent}%"
    echo ""
    echo "  Agents: $active_agents/$total_agents complete"
    echo ""

    # Recent files changed
    echo "┌─────────────────────────────────────────────────────────────────────┐"
    echo "│  📁 RECENT ACTIVITY                                                            │"
    echo "└─────────────────────────────────────────────────────────────────────┘"
    echo ""

    local found_recent=false
    for agent in "${agents[@]}"; do
        local report_dir="$SHARED_DIR/$agent"
        if [[ -d "$report_dir" ]]; then
            local latest=$(find "$report_dir" -type f -name "*.md" -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1)
            if [[ -n "$latest" ]]; then
                local file_path=$(echo "$latest" | cut -d' ' -f2-)
                local mod_time=$(echo "$latest" | cut -d' ' -f1)
                local time_str=$(date -r "$file_path" '+%H:%M:%S' 2>/dev/null || stat -f "%Sm" -t "%H:%M:%S" "$file_path" 2>/dev/null)
                local agent_name=$(basename "$report_dir")
                
                echo "  [${agent_name^^}] $(basename "$file_path")"
                echo "     Updated: $time_str"
                echo ""
                found_recent=true
            fi
        fi
    done

    if ! $found_recent; then
        echo "  No recent activity"
        echo ""
    fi

    # Queue status
    echo "┌─────────────────────────────────────────────────────────────────────┐"
    echo "│  📋 PENDING TASKS                                                             │"
    echo "└─────────────────────────────────────────────────────────────────────┘"
    echo ""

    local has_pending=false
    for agent in "${agents[@]}"; do
        local task_dir="$QUEUE_DIR/to-$agent"
        if [[ -d "$task_dir" ]]; then
            local pending=$(ls -1 "$task_dir"/*.yaml 2>/dev/null | wc -l)
            if [[ $pending -gt 0 ]]; then
                echo "  $agent: $pending tasks waiting"
                has_pending=true
            fi
        fi
    done

    if ! $has_pending; then
        echo "  All agents busy (or tasks assigned)"
        echo ""
    fi

    # Footer
    echo "╔════════════════════════════════════════════════════════════════════"
    echo "║  Press Ctrl+C to exit | Refresh every 5s                                   ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
}

# Auto-refresh loop
if [[ "${AUTO_REFRESH:-false}" == "true" ]]; then
    while true; do
        show_dashboard
        sleep 5
    done
else
    show_dashboard
    echo ""
    echo "💡 For auto-refresh, run: AUTO_REFRESH=true ./scripts/track-progress.sh $TASK_ID"
fi

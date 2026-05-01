#!/bin/bash

################################################################################
# Session Coordinator for EM-Team Distributed Orchestration
#
# Description: High-level coordination logic for distributed agent sessions
# Usage: ./session-coordinator.sh [command] [options]
################################################################################

set -euo pipefail

# Configuration
SESSION_NAME="claude-work"
SHARED_DIR="/tmp/claude-work-reports"
QUEUE_DIR="/tmp/claude-work-queue"
SYNC_DIR="/tmp/claude-work-sync"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

log_debug() {
    echo -e "${CYAN}[DEBUG]${NC} $1"
}

################################################################################
# Check prerequisites
################################################################################

check_prerequisites() {
    log_info "Checking prerequisites..."

    local all_good=true

    # Check tmux
    if ! command -v tmux &> /dev/null; then
        log_error "tmux not installed"
        all_good=false
    fi

    # Check if session is running
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "Session '$SESSION_NAME' not running"
        log_info "Start with: ./scripts/distributed-orchestrator.sh start"
        all_good=false
    fi

    # Check directories
    if [[ ! -d "$SHARED_DIR" ]]; then
        log_warning "Shared directory not found: $SHARED_DIR"
        mkdir -p "$SHARED_DIR"
        log_info "Created shared directory"
    fi

    if [[ ! -d "$QUEUE_DIR" ]]; then
        log_warning "Queue directory not found: $QUEUE_DIR"
        mkdir -p "$QUEUE_DIR"/{to-backend,to-frontend,to-database,to-techlead,processed}
        log_info "Created queue directory"
    fi

    if $all_good; then
        log_success "Prerequisites check passed"
        return 0
    else
        log_error "Prerequisites check failed"
        return 1
    fi
}

################################################################################
# Show session topology
################################################################################

show_topology() {
    log_info "Session Topology"
    echo ""

    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "Session '$SESSION_NAME' not running"
        return 1
    fi

    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                    $SESSION_NAME Session                    │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    # List windows with their roles
    tmux list-windows -t "$SESSION_NAME" -F "#{window_index}: #{window_name} #{?window_active,(active),}" | while read -r window; do
        local window_num=$(echo "$window" | cut -d':' -f1)
        local window_name=$(echo "$window" | cut -d':' -f2 | cut -d' ' -f1)
        local is_active=$(echo "$window" | grep -o '(active)' || echo "")

        local role=""
        case "$window_name" in
            techlead)
                role="🎯 Coordinator"
                ;;
            backend)
                role="⚙️  Backend Expert"
                ;;
            frontend)
                role="🎨 Frontend Expert"
                ;;
            database)
                role="🗄️  Database Expert"
                ;;
            scratch)
                role="📝 General Workspace"
                ;;
            *)
                role="❓ Unknown"
                ;;
        esac

        if [[ -n "$is_active" ]]; then
            echo -e "${GREEN}▶${NC} Window $window_num: $window_name - $role"
        else
            echo "  Window $window_num: $window_name - $role"
        fi
    done

    echo ""
    log_info "Data Flow:"
    echo "  techlead ⇄ backend ⇄ Queue"
    echo "  techlead ⇄ frontend ⇄ Queue"
    echo "  techlead ⇄ database ⇄ Queue"
    echo "  All agents → Shared Reports → techlead"
    echo ""
}

################################################################################
# Show message queue status
################################################################################

show_queue_status() {
    log_info "Message Queue Status"
    echo ""

    if [[ ! -d "$QUEUE_DIR" ]]; then
        log_warning "Queue directory not found"
        return 1
    fi

    local total_pending=0
    local total_processed=0

    for queue_dir in "$QUEUE_DIR"/to-*; do
        if [[ -d "$queue_dir" ]]; then
            local target=$(basename "$queue_dir")
            local pending=$(find "$queue_dir" -type f -name "*.yaml" 2>/dev/null | wc -l)

            if [[ $pending -gt 0 ]]; then
                log_info "$target: $pending pending"
                ((total_pending += pending))
            fi
        fi
    done

    if [[ -d "$QUEUE_DIR/processed" ]]; then
        total_processed=$(find "$QUEUE_DIR/processed" -type f -name "*.yaml" 2>/dev/null | wc -l)
    fi

    echo ""
    log_info "Total Pending: $total_pending"
    log_info "Total Processed: $total_processed"

    if [[ $total_pending -gt 0 ]]; then
        echo ""
        log_warning "There are pending messages in the queue"
        log_info "Process pending messages with: process-pending"
    fi
}

################################################################################
# Show agent status
################################################################################

show_agent_status() {
    log_info "Agent Status"
    echo ""

    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "Session '$SESSION_NAME' not running"
        return 1
    fi

    # List of agents with their display names
    local agents=(
        "techlead:Tech Lead Coordinator"
        "backend:Backend Expert"
        "frontend:Frontend Expert"
        "database:Database Expert"
    )

    for agent_info in "${agents[@]}"; do
        local agent="${agent_info%%:*}"
        local role="${agent_info#*:}"
        local window_name="$agent"

        # Check if window exists
        if ! tmux list-windows -t "$SESSION_NAME" -F "#{window_name}" | grep -q "^${window_name}$"; then
            log_warning "$role ($agent): Window not found"
            continue
        fi

        # Check for recent activity
        local report_dir="$SHARED_DIR/$agent"
        local latest_report=""

        if [[ -d "$report_dir" ]]; then
            latest_report=$(find "$report_dir" -type f \( -name "*.md" -o -name "*.json" \) -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
        fi

        local status="✅ Idle"
        local last_activity="No recent activity"

        if [[ -n "$latest_report" ]]; then
            local modified_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$latest_report" 2>/dev/null || stat -c "%y" "$latest_report" 2>/dev/null | cut -d'.' -f1)
            last_activity="Last report: $modified_time"
            status="📊 Active (report available)"
        fi

        # Check for pending tasks
        local task_dir="$QUEUE_DIR/to-$agent"
        if [[ -d "$task_dir" ]]; then
            local pending_tasks=$(find "$task_dir" -type f -name "*.yaml" 2>/dev/null | wc -l)
            if [[ $pending_tasks -gt 0 ]]; then
                status="⏳ Waiting ($pending_tasks tasks)"
            fi
        fi

        echo "🤖 $role"
        echo "   Status: $status"
        echo "   Activity: $last_activity"
        echo ""
    done
}

################################################################################
# Process pending messages
################################################################################

process_pending() {
    local agent=${1:-}

    log_info "Processing pending messages..."

    if [[ -z "$agent" ]]; then
        log_info "Processing all pending messages..."
    else
        log_info "Processing messages for: $agent"
    fi

    local processed=0

    if [[ -z "$agent" ]]; then
        # Process all agents
        for queue_dir in "$QUEUE_DIR"/to-*; do
            if [[ -d "$queue_dir" ]]; then
                local target=$(basename "$queue_dir" | sed 's/to-//')
                processed=$((processed + $(process_agent_messages "$target")))
            fi
        done
    else
        processed=$(process_agent_messages "$agent")
    fi

    if [[ $processed -gt 0 ]]; then
        log_success "Processed $processed messages"
    else
        log_info "No pending messages to process"
    fi
}

process_agent_messages() {
    local agent=$1
    local queue_dir="$QUEUE_DIR/to-$agent"
    local processed=0

    if [[ ! -d "$queue_dir" ]]; then
        return 0
    fi

    for msg_file in "$queue_dir"/*.yaml; do
        if [[ -f "$msg_file" ]]; then
            log_debug "Processing: $msg_file"

            # Notify agent session
            if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
                local window_name="$agent"
                if tmux list-windows -t "$SESSION_NAME" -F "#{window_name}" | grep -q "^${window_name}$"; then
                    tmux send-keys -t "$SESSION_NAME:$window_name" "echo '[New message: $(basename "$msg_file")]'" C-m
                fi
            fi

            # Move to processed
            mv "$msg_file" "$QUEUE_DIR/processed/"
            ((processed++))
        fi
    done

    echo $processed
}

################################################################################
# Create coordination plan
################################################################################

create_plan() {
    local plan_file=${1:-"$SYNC_DIR/coordination-plan-$(date +%Y%m%d-%H%M%S).yaml"}

    log_info "Creating coordination plan..."

    mkdir -p "$SYNC_DIR"

    cat > "$plan_file" << EOF
# Coordination Plan
# Created: $(date)

plan:
  id: "PLAN-$(date +%Y%m%d-%H%M%S)"
  name: "Enter plan name here"

agents:
  - name: "backend-expert"
    session: "backend"
    priority: 1
    task: "Enter task description"
    dependencies: []

  - name: "frontend-expert"
    session: "frontend"
    priority: 2
    task: "Enter task description"
    dependencies: []

execution_strategy: "parallel"  # or sequential/hybrid

sync_points:
  - name: "Review checkpoint"
    after: "task_completion"
    participants: ["all"]

expected_outputs:
  - from: "backend-expert"
    format: "report"
    location: "/tmp/claude-work-reports/backend/"
  - from: "frontend-expert"
    format: "report"
    location: "/tmp/claude-work-reports/frontend/"
EOF

    log_success "Coordination plan created: $plan_file"
    log_info "Edit the plan to customize it"

    echo "$plan_file"
}

################################################################################
# Show coordination dashboard
################################################################################

show_dashboard() {
    clear
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║        EM-Team Distributed Orchestration Dashboard             ║"
    echo "║                    $(date '+%Y-%m-%d %H:%M:%S')                       ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""

    # Session status
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_success "Session Status: Running"
    else
        log_error "Session Status: Not running"
    fi

    echo ""

    # Agent status
    show_agent_status

    # Queue status
    show_queue_status

    # Recent reports
    log_info "Recent Reports:"
    echo ""

    if [[ -d "$SHARED_DIR" ]]; then
        local found_reports=false
        for agent_dir in "$SHARED_DIR"/*; do
            if [[ -d "$agent_dir" ]]; then
                local agent=$(basename "$agent_dir")
                local latest_report=$(find "$agent_dir" -type f \( -name "*.md" -o -name "*.json" \) -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)

                if [[ -n "$latest_report" ]]; then
                    found_reports=true
                    local filename=$(basename "$latest_report")
                    local modified=$(stat -f "%Sm" -t "%H:%M" "$latest_report" 2>/dev/null || stat -c "%y" "$latest_report" 2>/dev/null | cut -d'.' -f1 | cut -d'T' -f2 | cut -d':' -f1,2)
                    echo "  📄 [$agent] $filename ($modified)"
                fi
            fi
        done

        if ! $found_reports; then
            echo "  No reports found"
        fi
    fi

    echo ""
    echo "Press Ctrl+C to exit, refresh with: $0 dashboard"
}

################################################################################
# Run coordination loop
################################################################################

run_loop() {
    local interval=${1:-30}

    log_info "Starting coordination loop (refresh every ${interval}s)..."
    log_info "Press Ctrl+C to stop"

    while true; do
        show_dashboard
        sleep "$interval"
    done
}

################################################################################
# Start queue monitors in all agent sessions
################################################################################

start_monitors() {
    log_info "Starting queue monitors in all agent sessions..."

    local agents=("backend" "frontend" "database")
    local started=0

    for agent in "${agents[@]}"; do
        # Check if agent window exists
        if ! tmux list-windows -t "$SESSION_NAME" -F "#{window_name}" 2>/dev/null | grep -q "^${agent}$"; then
            log_warning "Agent session '$agent' not found"
            continue
        fi

        # Check if monitor is already running
        local monitor_pid_file="/tmp/claude-work-queue/monitor-${agent}.pid"
        if [[ -f "$monitor_pid_file" ]]; then
            local existing_pid=$(cat "$monitor_pid_file")
            if ps -p "$existing_pid" > /dev/null 2>&1; then
                log_warning "Queue monitor already running for $agent (PID: $existing_pid)"
                continue
            else
                log_warning "Stale PID file for $agent, removing..."
                rm -f "$monitor_pid_file"
            fi
        fi

        # Start monitor in agent session
        log_info "Starting monitor for $agent..."
        tmux send-keys -t "$SESSION_NAME:$agent" "bash $(pwd)/distributed/session-queue-monitor.sh $agent &" C-m

        ((started++))
    done

    if [[ $started -gt 0 ]]; then
        log_success "Started $started queue monitor(s)"
        echo ""
        log_info "Monitor status will be available in a few seconds"
        log_info "Check with: $0 monitor-status"
    else
        log_warning "No monitors started"
    fi
}

################################################################################
# Stop queue monitors in all agent sessions
################################################################################

stop_monitors() {
    log_info "Stopping queue monitors in all agent sessions..."

    local agents=("backend" "frontend" "database")
    local stopped=0

    for agent in "${agents[@]}"; do
        local monitor_pid_file="/tmp/claude-work-queue/monitor-${agent}.pid"

        if [[ ! -f "$monitor_pid_file" ]]; then
            log_debug "No monitor running for $agent"
            continue
        fi

        local monitor_pid=$(cat "$monitor_pid_file")

        if ! ps -p "$monitor_pid" > /dev/null 2>&1; then
            log_warning "Stale PID file for $agent"
            rm -f "$monitor_pid_file"
            continue
        fi

        # Stop the monitor
        log_info "Stopping monitor for $agent (PID: $monitor_pid)..."
        kill "$monitor_pid" 2>/dev/null || true
        rm -f "$monitor_pid_file"

        ((stopped++))
    done

    if [[ $stopped -gt 0 ]]; then
        log_success "Stopped $stopped queue monitor(s)"
    else
        log_info "No monitors were running"
    fi
}

################################################################################
# Show queue monitor status
################################################################################

show_monitor_status() {
    log_info "Queue Monitor Status"
    echo ""

    local agents=("backend" "frontend" "database")
    local running=0

    for agent in "${agents[@]}"; do
        local monitor_pid_file="/tmp/claude-work-queue/monitor-${agent}.pid"

        if [[ -f "$monitor_pid_file" ]]; then
            local monitor_pid=$(cat "$monitor_pid_file")

            if ps -p "$monitor_pid" > /dev/null 2>&1; then
                echo "  ✅ $agent: Running (PID: $monitor_pid)"
                ((running++))
            else
                echo "  ❌ $agent: Stale PID file"
            fi
        else
            echo "  ❌ $agent: Not running"
        fi
    done

    echo ""
    if [[ $running -eq ${#agents[@]} ]]; then
        log_success "All monitors running"
    elif [[ $running -gt 0 ]]; then
        log_warning "Some monitors not running"
    else
        log_warning "No monitors running"
        log_info "Start monitors with: $0 start-monitors"
    fi
}

################################################################################
# Show help
################################################################################

show_help() {
    cat << EOF
Session Coordinator for EM-Team Distributed Orchestration

Usage: $0 [command] [options]

Commands:
    check                           Check prerequisites
    topology                        Show session topology
    queue-status                    Show message queue status
    agent-status                    Show agent status
    process-pending [agent]         Process pending messages
    create-plan [file]              Create coordination plan template
    dashboard                       Show coordination dashboard
    loop [seconds]                  Run coordination loop (default: 30s)
    start-monitors                  Start queue monitors in all agent sessions
    stop-monitors                   Stop queue monitors in all agent sessions
    monitor-status                  Show queue monitor status
    help                            Show this help message

Examples:
    $0 check                           # Check prerequisites
    $0 topology                        # Show session topology
    $0 agent-status                    # Show agent status
    $0 process-pending backend         # Process backend messages
    $0 create-plan                     # Create coordination plan
    $0 dashboard                       # Show dashboard
    $0 loop 60                        # Run loop with 60s refresh
    $0 start-monitors                  # Start all queue monitors
    $0 stop-monitors                   # Stop all queue monitors
    $0 monitor-status                  # Show monitor status

Session Name: $SESSION_NAME
Shared Directory: $SHARED_DIR
Queue Directory: $QUEUE_DIR

EOF
}

################################################################################
# Main
################################################################################

main() {
    local command=${1:-help}

    case "$command" in
        check|prereq)
            check_prerequisites
            ;;
        topology)
            show_topology
            ;;
        queue-status|queue)
            show_queue_status
            ;;
        agent-status|agents)
            show_agent_status
            ;;
        process-pending|process)
            process_pending "$2"
            ;;
        create-plan|plan)
            create_plan "$2"
            ;;
        dashboard)
            show_dashboard
            ;;
        loop)
            run_loop "${2:-30}"
            ;;
        start-monitors)
            start_monitors
            ;;
        stop-monitors)
            stop_monitors
            ;;
        monitor-status)
            show_monitor_status
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

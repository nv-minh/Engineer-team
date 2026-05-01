#!/bin/bash

################################################################################
# Session Queue Monitor for EM-Team Distributed Orchestration
#
# Description: Monitors agent's queue and auto-triggers agent on new tasks
# Usage: ./session-queue-monitor.sh [agent_name]
################################################################################

set -euo pipefail

# Configuration
SESSION_NAME="claude-work"
QUEUE_DIR="/tmp/claude-work-queue"
MONITOR_PID_FILE="/tmp/claude-work-queue/monitor-${AGENT_NAME:-}.pid"

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
# Validate agent
################################################################################

validate_agent() {
    local agent_name="$1"

    if [[ ! "$agent_name" =~ ^(backend|frontend|database)$ ]]; then
        log_error "Invalid agent: $agent_name"
        log_info "Valid agents: backend, frontend, database"
        return 1
    fi

    return 0
}

################################################################################
# Get agent trigger command
################################################################################

get_agent_trigger() {
    local agent_name="$1"

    case "$agent_name" in
        backend)
            echo "duck:backend"
            ;;
        frontend)
            echo "duck:frontend"
            ;;
        database)
            echo "duck:database"
            ;;
        *)
            echo "unknown:$agent_name"
            ;;
    esac
}

################################################################################
# Process task file
################################################################################

process_task() {
    local agent_name="$1"
    local task_file="$2"
    local task_id=$(basename "$task_file" .yaml)

    log_info "════════════════════════════════════════════════════════════════"
    log_info "Processing new task: $task_id"
    log_info "════════════════════════════════════════════════════════════════"

    # Validate YAML file
    if ! grep -q "^message_type: task_assignment" "$task_file"; then
        log_error "Invalid task file: missing message_type"
        mv "$task_file" "$QUEUE_DIR/failed/"
        return 1
    fi

    # Extract task information
    local task_title=$(grep "^  title:" "$task_file" | cut -d'"' -f2)
    local task_priority=$(grep "^  priority:" "$task_file" | awk '{print $2}')
    local task_deadline=$(grep "^    deadline:" "$task_file" | awk '{print $2}')

    log_info "Title: $task_title"
    log_info "Priority: $task_priority"
    log_info "Deadline: $task_deadline"
    echo ""

    # Get agent trigger
    local agent_trigger=$(get_agent_trigger "$agent_name")

    if [[ "$agent_trigger" == "unknown:"* ]]; then
        log_error "Unknown agent trigger for: $agent_name"
        mv "$task_file" "$QUEUE_DIR/failed/"
        return 1
    fi

    # Check if tmux session exists
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "Session '$SESSION_NAME' not found"
        mv "$task_file" "$QUEUE_DIR/failed/"
        return 1
    fi

    # Check if agent window exists
    if ! tmux list-windows -t "$SESSION_NAME" -F "#{window_name}" 2>/dev/null | grep -q "^${agent_name}$"; then
        log_warning "Agent window '$agent_name' not found in session"
        log_info "Task will remain in queue for manual processing"
        return 0
    fi

    # Auto-trigger agent
    log_info "Triggering $agent_name agent..."
    log_info "Command: Agent: $agent_trigger"

    # Send command to agent session
    tmux send-keys -t "$SESSION_NAME:$agent_name" "echo '📋 Auto-triggered by queue monitor'" C-m
    tmux send-keys -t "$SESSION_NAME:$agent_name" "echo '📝 Task: $task_title'" C-m
    tmux send-keys -t "$SESSION_NAME:$agent_name" "echo '🆔 Task ID: $task_id'" C-m
    tmux send-keys -t "$SESSION_NAME:$agent_name" "echo '⏰ Priority: $task_priority | Deadline: $task_deadline'" C-m
    tmux send-keys -t "$SESSION_NAME:$agent_name" "echo '📂 Task file: $task_file'" C-m
    tmux send-keys -t "$SESSION_NAME:$agent_name" "" C-m

    # Trigger the agent
    sleep 1
    tmux send-keys -t "$SESSION_NAME:$agent_name" "Agent: $agent_trigger - $task_title" C-m

    log_success "Agent triggered successfully!"
    echo ""

    # Move task to processed
    mv "$task_file" "$QUEUE_DIR/processed/"

    log_success "Task moved to processed: $task_id"
    log_info "════════════════════════════════════════════════════════════════"
    echo ""

    return 0
}

################################################################################
# Start queue monitor
################################################################################

start_queue_monitor() {
    local agent_name="$1"
    local queue_dir="$QUEUE_DIR/to-$agent_name"

    # Set PID file
    export AGENT_NAME="$agent_name"
    MONITOR_PID_FILE="/tmp/claude-work-queue/monitor-${agent_name}.pid"

    # Check if already running
    if [[ -f "$MONITOR_PID_FILE" ]]; then
        local existing_pid=$(cat "$MONITOR_PID_FILE")
        if ps -p "$existing_pid" > /dev/null 2>&1; then
            log_warning "Queue monitor already running (PID: $existing_pid)"
            log_info "Stop with: kill $existing_pid"
            return 1
        else
            log_warning "Stale PID file found, removing..."
            rm -f "$MONITOR_PID_FILE"
        fi
    fi

    # Validate queue directory
    if [[ ! -d "$queue_dir" ]]; then
        log_error "Queue directory not found: $queue_dir"
        return 1
    fi

    log_info "════════════════════════════════════════════════════════════════"
    log_info "Queue Monitor for $agent_name"
    log_info "════════════════════════════════════════════════════════════════"
    log_info "Agent: $agent_name"
    log_info "Queue: $queue_dir"
    log_info "Agent Trigger: $(get_agent_trigger "$agent_name")"
    log_info "PID: $$"
    log_info "════════════════════════════════════════════════════════════════"
    echo ""

    # Save PID
    echo $$ > "$MONITOR_PID_FILE"

    log_success "Queue monitor started"
    log_info "Press Ctrl+C to stop"
    log_info "Check interval: 5 seconds"
    echo ""

    # Monitoring loop
    local task_count=0
    while true; do
        # Check for new tasks
        if compgen -G "$queue_dir/*.yaml" > /dev/null 2>&1; then
            for task_file in "$queue_dir"/*.yaml; do
                if [[ -f "$task_file" ]]; then
                    local task_id=$(basename "$task_file" .yaml)

                    log_info "New task detected: $task_id"
                    log_debug "Task file: $task_file"

                    # Process the task
                    if process_task "$agent_name" "$task_file"; then
                        ((task_count++))
                        log_success "Tasks processed: $task_count"
                    else
                        log_error "Failed to process task: $task_id"
                    fi

                    echo ""
                fi
            done
        fi

        # Sleep before next check
        sleep 5
    done
}

################################################################################
# Stop queue monitor
################################################################################

stop_queue_monitor() {
    local agent_name="$1"
    local monitor_pid_file="/tmp/claude-work-queue/monitor-${agent_name}.pid"

    if [[ ! -f "$monitor_pid_file" ]]; then
        log_warning "No queue monitor running for $agent_name"
        return 0
    fi

    local monitor_pid=$(cat "$monitor_pid_file")

    if ! ps -p "$monitor_pid" > /dev/null 2>&1; then
        log_warning "Queue monitor not running (stale PID file)"
        rm -f "$monitor_pid_file"
        return 0
    fi

    log_info "Stopping queue monitor for $agent_name (PID: $monitor_pid)..."
    kill "$monitor_pid"
    rm -f "$monitor_pid_file"

    log_success "Queue monitor stopped"
}

################################################################################
# Show monitor status
################################################################################

show_monitor_status() {
    local agent_name="${1:-}"

    if [[ -n "$agent_name" ]]; then
        # Show specific agent monitor status
        local monitor_pid_file="/tmp/claude-work-queue/monitor-${agent_name}.pid"

        if [[ ! -f "$monitor_pid_file" ]]; then
            echo "❌ Queue monitor for $agent_name: Not running"
            return 0
        fi

        local monitor_pid=$(cat "$monitor_pid_file")

        if ! ps -p "$monitor_pid" > /dev/null 2>&1; then
            echo "❌ Queue monitor for $agent_name: Not running (stale PID)"
            return 0
        fi

        echo "✅ Queue monitor for $agent_name: Running (PID: $monitor_pid)"
    else
        # Show all agent monitor statuses
        echo "Queue Monitor Status:"
        echo ""

        for agent in backend frontend database; do
            local monitor_pid_file="/tmp/claude-work-queue/monitor-${agent}.pid"

            if [[ -f "$monitor_pid_file" ]]; then
                local monitor_pid=$(cat "$monitor_pid_file")

                if ps -p "$monitor_pid" > /dev/null 2>&1; then
                    echo "  ✅ $agent: Running (PID: $monitor_pid)"
                else
                    echo "  ❌ $agent: Stale PID file"
                fi
            else
                echo "  ❌ $agent: Not running"
            fi
        done
    fi
}

################################################################################
# Show help
################################################################################

show_help() {
    cat << EOF
Session Queue Monitor for EM-Team Distributed Orchestration

Usage: $0 [command] [options]

Commands:
    start [agent]              Start queue monitor for agent
    stop [agent]               Stop queue monitor for agent
    status [agent]             Show monitor status (or all if no agent specified)
    help                       Show this help message

Arguments:
    agent                      Agent name (backend, frontend, or database)

Examples:
    $0 start backend           Start monitor for backend session
    $0 stop frontend           Stop monitor for frontend session
    $0 status                  Show status of all monitors
    $0 status database         Show status of database monitor

Usage in Agent Sessions:
    # Run in each agent session to monitor for tasks
    ./distributed/session-queue-monitor.sh backend &
    ./distributed/session-queue-monitor.sh frontend &
    ./distributed/session-queue-monitor.sh database &

Process:
    1. Monitors /tmp/claude-work-queue/to-{agent}/ for new tasks
    2. Detects new YAML task files
    3. Parses task information
    4. Auto-triggers appropriate agent via tmux
    5. Moves processed tasks to /tmp/claude-work-queue/processed/

EOF
}

################################################################################
# Main
################################################################################

main() {
    local command="${1:-help}"
    local agent_name="${2:-}"

    case "$command" in
        start)
            if [[ -z "$agent_name" ]]; then
                log_error "Usage: $0 start [agent]"
                exit 1
            fi

            if ! validate_agent "$agent_name"; then
                exit 1
            fi

            start_queue_monitor "$agent_name"
            ;;
        stop)
            if [[ -z "$agent_name" ]]; then
                log_error "Usage: $0 stop [agent]"
                exit 1
            fi

            if ! validate_agent "$agent_name"; then
                exit 1
            fi

            stop_queue_monitor "$agent_name"
            ;;
        status)
            if [[ -n "$agent_name" ]]; then
                if ! validate_agent "$agent_name"; then
                    exit 1
                fi
            fi

            show_monitor_status "$agent_name"
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

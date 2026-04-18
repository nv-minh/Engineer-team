#!/bin/bash

################################################################################
# Distributed Orchestrator for EM-Skill
#
# Description: Creates and manages tmux sessions for distributed agent execution
# Usage: ./distributed-orchestrator.sh [command]
################################################################################

set -euo pipefail

# Configuration
SESSION_NAME="claude-work"
SHARED_DIR="/tmp/claude-work-reports"
QUEUE_DIR="/tmp/claude-work-queue"
LOG_DIR="/tmp/claude-work-logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
# Initialize directories
################################################################################

init_directories() {
    log_info "Initializing distributed work directories..."

    mkdir -p "$SHARED_DIR"
    mkdir -p "$QUEUE_DIR"
    mkdir -p "$LOG_DIR"

    # Create agent-specific directories
    mkdir -p "$SHARED_DIR/backend"
    mkdir -p "$SHARED_DIR/frontend"
    mkdir -p "$SHARED_DIR/database"
    mkdir -p "$SHARED_DIR/techlead"

    log_success "Directories initialized"
}

################################################################################
# Create tmux session
################################################################################

create_session() {
    local session_name=$1

    if tmux has-session -t "$session_name" 2>/dev/null; then
        log_warning "Session '$session_name' already exists"
        return 1
    fi

    tmux new-session -d -s "$session_name"
    log_success "Created session: $session_name"
}

################################################################################
# Start distributed workflow
################################################################################

start_distributed() {
    log_info "Starting distributed agent orchestration..."

    # Initialize directories
    init_directories

    # Check if session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_warning "Session '$SESSION_NAME' already exists"
        read -p "Do you want to kill the existing session and create a new one? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            tmux kill-session -t "$SESSION_NAME"
            log_success "Killed existing session"
        else
            log_info "Attaching to existing session..."
            tmux attach-session -t "$SESSION_NAME"
            return 0
        fi
    fi

    # Create main session
    log_info "Creating main tmux session: $SESSION_NAME"
    tmux new-session -d -s "$SESSION_NAME"

    # Window 0: Tech Lead (Coordinator) - Default window
    tmux rename-window -t "$SESSION_NAME:0" "techlead"
    tmux send-keys -t "$SESSION_NAME:techlead" "cd $(pwd)" C-m
    tmux send-keys -t "$SESSION_NAME:techlead" "echo 'Tech Lead Coordinator Session'" C-m
    tmux send-keys -t "$SESSION_NAME:techlead" "echo 'Trigger: duck:techlead-orchestrator'" C-m

    # Window 1: Backend Agent
    tmux new-window -t "$SESSION_NAME:1" -n "backend"
    tmux send-keys -t "$SESSION_NAME:backend" "cd $(pwd)" C-m
    tmux send-keys -t "$SESSION_NAME:backend" "echo 'Backend Agent Session'" C-m
    tmux send-keys -t "$SESSION_NAME:backend" "echo 'Trigger: duck:backend'" C-m

    # Window 2: Frontend Agent
    tmux new-window -t "$SESSION_NAME:2" -n "frontend"
    tmux send-keys -t "$SESSION_NAME:frontend" "cd $(pwd)" C-m
    tmux send-keys -t "$SESSION_NAME:frontend" "echo 'Frontend Agent Session'" C-m
    tmux send-keys -t "$SESSION_NAME:frontend" "echo 'Trigger: duck:frontend'" C-m

    # Window 3: Database Agent
    tmux new-window -t "$SESSION_NAME:3" -n "database"
    tmux send-keys -t "$SESSION_NAME:database" "cd $(pwd)" C-m
    tmux send-keys -t "$SESSION_NAME:database" "echo 'Database Agent Session'" C-m
    tmux send-keys -t "$SESSION_NAME:database" "echo 'Trigger: duck:database'" C-m

    # Window 4: Scratch/General workspace
    tmux new-window -t "$SESSION_NAME:4" -n "scratch"
    tmux send-keys -t "$SESSION_NAME:scratch" "cd $(pwd)" C-m
    tmux send-keys -t "$SESSION_NAME:scratch" "echo 'General Workspace'" C-m

    # Select techlead window as default
    tmux select-window -t "$SESSION_NAME:techlead"

    log_success "Distributed orchestration started"
    log_info "Session: $SESSION_NAME"
    log_info "Windows created:"
    log_info "  0: techlead (coordinator)"
    log_info "  1: backend"
    log_info "  2: frontend"
    log_info "  3: database"
    log_info "  4: scratch"

    # Show usage
    echo ""
    log_info "Usage:"
    log_info "  Attach to session: tmux attach -t $SESSION_NAME"
    log_info "  Switch windows: Ctrl+B then 0-4"
    log_info "  List windows: Ctrl+B then w"
    log_info "  Detach: Ctrl+B then d"

    # Attach to session
    read -p "Attach to session now? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        tmux attach-session -t "$SESSION_NAME"
    fi
}

################################################################################
# List sessions
################################################################################

list_sessions() {
    log_info "Active tmux sessions:"
    echo ""
    tmux list-sessions 2>/dev/null || log_warning "No active sessions found"
}

################################################################################
# Kill session
################################################################################

kill_session() {
    local session_name=${1:-$SESSION_NAME}

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        return 1
    fi

    log_warning "Killing session: $session_name"
    tmux kill-session -t "$session_name"
    log_success "Session killed"
}

################################################################################
# Broadcast message to all windows
################################################################################

broadcast() {
    local message=$1
    local session_name=${2:-$SESSION_NAME}

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        return 1
    fi

    log_info "Broadcasting message to all windows in $session_name"
    tmux list-windows -t "$session_name" -F "#{window_index}" | while read -r window; do
        tmux send-keys -t "$session_name:$window" "$message" C-m
    done

    log_success "Message broadcasted"
}

################################################################################
# Send report from agent to techlead
################################################################################

send_report() {
    local agent=$1
    local report_file=$2

    if [[ -z "$agent" || -z "$report_file" ]]; then
        log_error "Usage: send_report <agent> <report_file>"
        return 1
    fi

    if [[ ! -f "$report_file" ]]; then
        log_error "Report file not found: $report_file"
        return 1
    fi

    # Copy to shared directory
    local dest_file="$SHARED_DIR/$agent/$(basename "$report_file")"
    cp "$report_file" "$dest_file"

    log_success "Report sent from $agent to techlead: $dest_file"

    # Notify techlead window
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux send-keys -t "$SESSION_NAME:techlead" "echo '[New report from $agent]'" C-m
        tmux send-keys -t "$SESSION_NAME:techlead" "echo 'File: $dest_file'" C-m
    fi
}

################################################################################
# Sync context across sessions
################################################################################

sync_context() {
    log_info "Syncing context across sessions..."

    # Create context snapshot
    local snapshot_file="$SHARED_DIR/context-snapshot-$(date +%Y%m%d-%H%M%S).txt"

    {
        echo "# Context Snapshot - $(date)"
        echo ""
        echo "## Current Directory"
        echo "$(pwd)"
        echo ""
        echo "## Git Status"
        git status -sb 2>/dev/null || echo "Not a git repository"
        echo ""
        echo "## Recent Commits"
        git log -3 --oneline 2>/dev/null || echo "No git history"
    } > "$snapshot_file"

    log_success "Context snapshot created: $snapshot_file"

    # Notify all windows
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux list-windows -t "$SESSION_NAME" -F "#{window_index}" | while read -r window; do
            tmux send-keys -t "$SESSION_NAME:$window" "echo '[Context sync available]'" C-m
        done
    fi
}

################################################################################
# Show status
################################################################################

status() {
    log_info "Distributed Orchestration Status"
    echo ""

    # Session status
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_success "Session '$SESSION_NAME' is running"
        echo ""
        log_info "Windows:"
        tmux list-windows -t "$SESSION_NAME" -F "  #{window_index}: #{window_name} #{?window_active,(active),}"
    else
        log_warning "Session '$SESSION_NAME' is not running"
    fi

    echo ""

    # Shared files
    log_info "Shared Reports:"
    if [[ -d "$SHARED_DIR" ]]; then
        find "$SHARED_DIR" -type f -name "*.md" -o -name "*.json" 2>/dev/null | while read -r file; do
            echo "  - $file"
        done
    fi

    echo ""

    # Queue status
    log_info "Pending Tasks:"
    if [[ -d "$QUEUE_DIR" ]]; then
        find "$QUEUE_DIR" -type f 2>/dev/null | while read -r file; do
            echo "  - $(basename "$file")"
        done
    fi
}

################################################################################
# Show help
################################################################################

show_help() {
    cat << EOF
Distributed Orchestrator for EM-Skill

Usage: $0 [command] [options]

Commands:
    start               Start distributed orchestration (create tmux session)
    stop [session]      Stop distributed orchestration (kill tmux session)
    restart             Restart distributed orchestration
    list                List active sessions
    status              Show status of distributed orchestration
    broadcast <msg>     Broadcast message to all windows
    send-report <agent> <file>    Send report from agent to techlead
    sync-context        Sync context across all sessions
    help                Show this help message

Examples:
    $0 start                    # Start distributed orchestration
    $0 broadcast "Hello all"    # Broadcast message
    $0 send-report backend report.md    # Send report
    $0 status                   # Show status

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
        start)
            start_distributed
            ;;
        stop|kill)
            kill_session "$2"
            ;;
        restart)
            kill_session "$2"
            sleep 1
            start_distributed
            ;;
        list)
            list_sessions
            ;;
        status)
            status
            ;;
        broadcast)
            if [[ -z "${2:-}" ]]; then
                log_error "Usage: $0 broadcast <message>"
                exit 1
            fi
            broadcast "$2" "${3:-$SESSION_NAME}"
            ;;
        send-report)
            send_report "$2" "$3"
            ;;
        sync-context|sync)
            sync_context
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

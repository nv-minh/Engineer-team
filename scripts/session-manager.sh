#!/bin/bash

################################################################################
# Session Manager for EM-Skill Distributed Orchestration
#
# Description: Manages tmux sessions for distributed agent execution
# Usage: ./session-manager.sh [command] [options]
################################################################################

set -euo pipefail

# Configuration
SESSION_NAME="claude-work"
SHARED_DIR="/tmp/claude-work-reports"
QUEUE_DIR="/tmp/claude-work-queue"
LOG_DIR="/tmp/claude-work-logs"

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
# List sessions
################################################################################

list_sessions() {
    log_info "Active tmux sessions:"
    echo ""

    if ! tmux list-sessions 2>/dev/null; then
        log_warning "No active tmux sessions found"
        return 1
    fi

    echo ""
    log_info "Session details:"
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_success "Session '$SESSION_NAME' is running"
        echo ""
        log_info "Windows:"
        tmux list-windows -t "$SESSION_NAME" -F "  #{window_index}: #{window_name} #{?window_active,(active),}"
    fi
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
    log_success "Session '$session_name' killed"
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

    log_info "Broadcasting message to all windows in '$session_name'"
    tmux list-windows -t "$session_name" -F "#{window_index}" | while read -r window; do
        tmux send-keys -t "$session_name:$window" "$message" C-m
    done

    log_success "Message broadcasted"
}

################################################################################
# Send keys to specific window
################################################################################

send_keys() {
    local target=$1
    local keys=$2

    # Parse target (format: session:window or just window)
    if [[ "$target" == *:* ]]; then
        local session_name="${target%:*}"
        local window="${target#*:}"
    else
        local session_name="$SESSION_NAME"
        local window="$target"
    fi

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        return 1
    fi

    if ! tmux list-windows -t "$session_name" -F "#{window_index}" | grep -q "^${window}$"; then
        log_error "Window '$window' not found in session '$session_name'"
        return 1
    fi

    tmux send-keys -t "$session_name:$window" "$keys" C-m
    log_success "Keys sent to $session_name:$window"
}

################################################################################
# Sync context across sessions
################################################################################

sync_context() {
    log_info "Syncing context across sessions..."

    # Create context snapshot
    local snapshot_file="$SHARED_DIR/context-snapshot-$(date +%Y%m%d-%H%M%S).txt"

    mkdir -p "$SHARED_DIR"

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
        echo ""
        echo "## Environment"
        echo "Node: $(node --version 2>/dev/null || echo 'Not installed')"
        echo "Python: $(python --version 2>/dev/null || echo 'Not installed')"
        echo "Go: $(go version 2>/dev/null || echo 'Not installed')"
    } > "$snapshot_file"

    log_success "Context snapshot created: $snapshot_file"

    # Notify all windows
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux list-windows -t "$SESSION_NAME" -F "#{window_index}" | while read -r window; do
            tmux send-keys -t "$SESSION_NAME:$window" "echo '[Context sync available: $snapshot_file]'" C-m
        done
        log_success "All windows notified"
    fi
}

################################################################################
# Show session status
################################################################################

status() {
    log_info "Session Manager Status"
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
        local report_count=$(find "$SHARED_DIR" -type f \( -name "*.md" -o -name "*.json" \) 2>/dev/null | wc -l)
        if [[ $report_count -gt 0 ]]; then
            find "$SHARED_DIR" -type f \( -name "*.md" -o -name "*.json" \) 2>/dev/null | while read -r file; do
                local agent=$(echo "$file" | sed "s|$SHARED_DIR/||" | cut -d'/' -f1)
                local filename=$(basename "$file")
                echo "  - [$agent] $filename"
            done
        else
            echo "  No reports found"
        fi
    else
        echo "  Shared directory not found"
    fi

    echo ""

    # Queue status
    log_info "Pending Tasks:"
    if [[ -d "$QUEUE_DIR" ]]; then
        local task_count=$(find "$QUEUE_DIR" -type f -name "*.yaml" 2>/dev/null | wc -l)
        if [[ $task_count -gt 0 ]]; then
            find "$QUEUE_DIR" -type f -name "*.yaml" 2>/dev/null | while read -r file; do
                local target=$(echo "$file" | sed "s|$QUEUE_DIR/||" | cut -d'/' -f1)
                local filename=$(basename "$file")
                echo "  - [$target] $filename"
            done
        else
            echo "  No pending tasks"
        fi
    else
        echo "  Queue directory not found"
    fi
}

################################################################################
# Watch specific agent
################################################################################

watch_agent() {
    local agent=$1

    if [[ -z "$agent" ]]; then
        log_error "Usage: watch_agent <agent_name>"
        return 1
    fi

    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "Session '$SESSION_NAME' not found"
        return 1
    fi

    # Map agent names to window names
    local window
    case "$agent" in
        techlead|tech-lead|coordinator)
            window="techlead"
            ;;
        backend|be)
            window="backend"
            ;;
        frontend|fe)
            window="frontend"
            ;;
        database|db)
            window="database"
            ;;
        scratch)
            window="scratch"
            ;;
        *)
            log_error "Unknown agent: $agent"
            log_info "Available agents: techlead, backend, frontend, database, scratch"
            return 1
            ;;
    esac

    if ! tmux list-windows -t "$SESSION_NAME" -F "#{window_name}" | grep -q "^${window}$"; then
        log_error "Window '$window' not found in session"
        return 1
    fi

    log_info "Watching agent: $agent (window: $window)"
    tmux select-window -t "$SESSION_NAME:$window"
    tmux attach-session -t "$SESSION_NAME"
}

################################################################################
# Clean up old files
################################################################################

cleanup() {
    local days=${1:-7}

    log_info "Cleaning up files older than $days days..."

    if [[ -d "$SHARED_DIR" ]]; then
        log_info "Cleaning shared reports..."
        find "$SHARED_DIR" -type f -mtime +$days -delete
        log_success "Old reports cleaned"
    fi

    if [[ -d "$QUEUE_DIR" ]]; then
        log_info "Cleaning processed queue items..."
        find "$QUEUE_DIR/processed" -type f -mtime +$days -delete 2>/dev/null || true
        log_success "Old queue items cleaned"
    fi

    if [[ -d "$LOG_DIR" ]]; then
        log_info "Cleaning old logs..."
        find "$LOG_DIR" -type f -mtime +$days -delete
        log_success "Old logs cleaned"
    fi

    log_success "Cleanup complete"
}

################################################################################
# Export session report
################################################################################

export_report() {
    local output_file=${1:-"session-report-$(date +%Y%m%d-%H%M%S).tar.gz"}

    log_info "Exporting session report..."

    if [[ ! -d "$SHARED_DIR" ]]; then
        log_error "Shared directory not found"
        return 1
    fi

    # Create archive
    tar -czf "$output_file" -C "$SHARED_DIR" . 2>/dev/null || true

    log_success "Session report exported: $output_file"
}

################################################################################
# Import session report
################################################################################

import_report() {
    local archive_file=$1

    if [[ -z "$archive_file" ]]; then
        log_error "Usage: import_report <archive_file>"
        return 1
    fi

    if [[ ! -f "$archive_file" ]]; then
        log_error "Archive file not found: $archive_file"
        return 1
    fi

    log_info "Importing session report..."

    mkdir -p "$SHARED_DIR"

    # Extract archive
    tar -xzf "$archive_file" -C "$SHARED_DIR"

    log_success "Session report imported"
}

################################################################################
# Show help
################################################################################

show_help() {
    cat << EOF
Session Manager for EM-Skill Distributed Orchestration

Usage: $0 [command] [options]

Commands:
    list                    List active sessions and windows
    kill [session]          Kill a session (default: claude-work)
    status                  Show detailed status
    broadcast <message>     Broadcast message to all windows
    send <target> <keys>    Send keys to specific window (session:window or window)
    sync-context            Sync context across all sessions
    watch <agent>           Attach to specific agent window
    cleanup [days]          Clean up old files (default: 7 days)
    export [file]           Export session report
    import <file>           Import session report
    help                    Show this help message

Agents:
    techlead                Tech Lead coordinator
    backend                 Backend expert
    frontend                Frontend expert
    database                Database expert
    scratch                 General workspace

Examples:
    $0 list                           # List sessions
    $0 broadcast "Hello all"          # Broadcast message
    $0 send backend "ls -la"          # Send keys to backend window
    $0 watch frontend                 # Attach to frontend window
    $0 sync-context                   # Sync context
    $0 cleanup 30                     # Clean up files older than 30 days

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
        list|ls)
            list_sessions
            ;;
        kill|stop)
            kill_session "$2"
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
        send)
            if [[ -z "${2:-}" || -z "${3:-}" ]]; then
                log_error "Usage: $0 send <target> <keys>"
                exit 1
            fi
            send_keys "$2" "$3"
            ;;
        sync-context|sync)
            sync_context
            ;;
        watch)
            if [[ -z "${2:-}" ]]; then
                log_error "Usage: $0 watch <agent>"
                exit 1
            fi
            watch_agent "$2"
            ;;
        cleanup)
            cleanup "${2:-7}"
            ;;
        export)
            export_report "${2:-}"
            ;;
        import)
            import_report "$2"
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

#!/bin/bash

################################################################################
# Session Sync Utility for EM-Skill Distributed Orchestration
#
# Description: Synchronizes context and data across distributed agent sessions
# Usage: ./session-sync.sh [command] [options]
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
# Sync context snapshot
################################################################################

sync_context() {
    log_info "Syncing context across sessions..."

    mkdir -p "$SYNC_DIR"

    local timestamp=$(date +%Y%m%d-%H%M%S)
    local snapshot_file="$SYNC_DIR/context-$timestamp.txt"

    # Create context snapshot
    {
        echo "# Context Snapshot - $(date)"
        echo ""
        echo "## Working Directory"
        echo "$(pwd)"
        echo ""

        echo "## Git Status"
        if git rev-parse --git-dir > /dev/null 2>&1; then
            git status -sb
            echo ""
            echo "## Recent Commits"
            git log -3 --oneline
            echo ""
            echo "## Current Branch"
            git branch --show-current
        else
            echo "Not a git repository"
        fi

        echo ""
        echo "## Environment"
        echo "Node: $(node --version 2>/dev/null || echo 'Not installed')"
        echo "Python: $(python --version 2>/dev/null || echo 'Not installed')"
        echo "Go: $(go version 2>/dev/null || echo 'Not installed')"

        echo ""
        echo "## Project Structure"
        ls -la | head -20

    } > "$snapshot_file"

    log_success "Context snapshot created: $snapshot_file"

    # Notify all sessions
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux list-windows -t "$SESSION_NAME" -F "#{window_index}" | while read -r window; do
            tmux send-keys -t "$SESSION_NAME:$window" "echo '[Context sync available]'" C-m
            tmux send-keys -t "$SESSION_NAME:$window" "echo 'File: $snapshot_file'" C-m
        done
        log_success "All sessions notified"
    fi

    echo "$snapshot_file"
}

################################################################################
# Sync files to all sessions
################################################################################

sync_files() {
    local files=("$@")

    if [[ ${#files[@]} -eq 0 ]]; then
        log_error "Usage: sync_files <file1> [file2] ..."
        return 1
    fi

    log_info "Syncing files to all sessions..."

    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "File not found: $file"
            continue
        fi

        local filename=$(basename "$file")
        local dest_file="$SYNC_DIR/$filename"

        cp "$file" "$dest_file"
        log_success "Copied: $file → $dest_file"
    done

    # Notify all sessions
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        for file in "${files[@]}"; do
            local filename=$(basename "$file")
            tmux list-windows -t "$SESSION_NAME" -F "#{window_index}" | while read -r window; do
                tmux send-keys -t "$SESSION_NAME:$window" "echo '[File sync: $filename available in $SYNC_DIR]'" C-m
            done
        done
        log_success "All sessions notified"
    fi
}

################################################################################
# Sync report from agent to techlead
################################################################################

sync_report() {
    local agent=$1
    local report_file=$2

    if [[ -z "$agent" || -z "$report_file" ]]; then
        log_error "Usage: sync_report <agent> <report_file>"
        return 1
    fi

    if [[ ! -f "$report_file" ]]; then
        log_error "Report file not found: $report_file"
        return 1
    fi

    log_info "Syncing report from $agent to techlead..."

    # Copy to shared directory
    local agent_dir="$SHARED_DIR/$agent"
    mkdir -p "$agent_dir"

    local dest_file="$agent_dir/$(basename "$report_file")"
    cp "$report_file" "$dest_file"

    log_success "Report synced: $dest_file"

    # Notify techlead
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        if tmux list-windows -t "$SESSION_NAME" -F "#{window_name}" | grep -q "^techlead$"; then
            tmux send-keys -t "$SESSION_NAME:techlead" "echo '[New report from $agent]'" C-m
            tmux send-keys -t "$SESSION_NAME:techlead" "echo 'File: $dest_file'" C-m
            log_success "TechLead notified"
        fi
    fi
}

################################################################################
# Broadcast message to all sessions
################################################################################

broadcast_message() {
    local message=$1

    if [[ -z "$message" ]]; then
        log_error "Usage: broadcast_message <message>"
        return 1
    fi

    log_info "Broadcasting message to all sessions..."

    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "Session '$SESSION_NAME' not found"
        return 1
    fi

    tmux list-windows -t "$SESSION_NAME" -F "#{window_index}" | while read -r window; do
        tmux send-keys -t "$SESSION_NAME:$window" "echo '$message'" C-m
    done

    log_success "Message broadcasted"
}

################################################################################
# Sync checkpoint state
################################################################################

sync_checkpoint() {
    local checkpoint_name=${1:-"checkpoint-$(date +%Y%m%d-%H%M%S)"}

    log_info "Creating checkpoint: $checkpoint_name"

    mkdir -p "$SYNC_DIR/checkpoints"

    local checkpoint_dir="$SYNC_DIR/checkpoints/$checkpoint_name"
    mkdir -p "$checkpoint_dir"

    # Save git state
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git rev-parse HEAD > "$checkpoint_dir/git-head.txt"
        git diff > "$checkpoint_dir/git-diff.patch"
        log_success "Git state saved"
    fi

    # Save file list
    find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" > "$checkpoint_dir/files.txt"

    # Save session info
    {
        echo "Checkpoint: $checkpoint_name"
        echo "Created: $(date)"
        echo "Working Directory: $(pwd)"
    } > "$checkpoint_dir/meta.txt"

    log_success "Checkpoint created: $checkpoint_dir"
    echo "$checkpoint_dir"
}

################################################################################
# Restore checkpoint state
################################################################################

restore_checkpoint() {
    local checkpoint_name=$1

    if [[ -z "$checkpoint_name" ]]; then
        log_error "Usage: restore_checkpoint <checkpoint_name>"
        log_info "Available checkpoints:"
        ls -la "$SYNC_DIR/checkpoints/" 2>/dev/null || echo "No checkpoints found"
        return 1
    fi

    local checkpoint_dir="$SYNC_DIR/checkpoints/$checkpoint_name"

    if [[ ! -d "$checkpoint_dir" ]]; then
        log_error "Checkpoint not found: $checkpoint_name"
        return 1
    fi

    log_info "Restoring checkpoint: $checkpoint_name"

    # Show checkpoint info
    if [[ -f "$checkpoint_dir/meta.txt" ]]; then
        cat "$checkpoint_dir/meta.txt"
    fi

    log_warning "Note: This only displays checkpoint info. Manual restoration may be required."

    # Show git head
    if [[ -f "$checkpoint_dir/git-head.txt" ]]; then
        echo ""
        log_info "Git HEAD at checkpoint:"
        cat "$checkpoint_dir/git-head.txt"
    fi

    # Show patch (if exists and small enough)
    if [[ -f "$checkpoint_dir/git-diff.patch" ]]; then
        local patch_size=$(wc -c < "$checkpoint_dir/git-diff.patch")
        if [[ $patch_size -lt 10000 ]]; then
            echo ""
            log_info "Git diff at checkpoint:"
            cat "$checkpoint_dir/git-diff.patch"
        else
            echo ""
            log_info "Git diff patch available (too large to display)"
            echo "File: $checkpoint_dir/git-diff.patch"
        fi
    fi

    log_success "Checkpoint info displayed"
}

################################################################################
# List checkpoints
################################################################################

list_checkpoints() {
    log_info "Available checkpoints:"
    echo ""

    if [[ ! -d "$SYNC_DIR/checkpoints" ]]; then
        log_warning "No checkpoints found"
        return 1
    fi

    for checkpoint_dir in "$SYNC_DIR/checkpoints"/*; do
        if [[ -d "$checkpoint_dir" ]]; then
            local name=$(basename "$checkpoint_dir")
            echo "📁 $name"

            if [[ -f "$checkpoint_dir/meta.txt" ]]; then
                grep "Created:" "$checkpoint_dir/meta.txt" | sed 's/Created: /  /'
            fi

            echo ""
        fi
    done
}

################################################################################
# Clean up old sync data
################################################################################

cleanup_sync() {
    local days=${1:-7}

    log_info "Cleaning up sync data older than $days days..."

    if [[ -d "$SYNC_DIR" ]]; then
        find "$SYNC_DIR" -type f -mtime +$days -delete
        log_success "Old sync files cleaned"
    fi

    # Clean empty directories
    find "$SYNC_DIR" -type d -empty -delete 2>/dev/null || true

    log_success "Cleanup complete"
}

################################################################################
# Show sync status
################################################################################

sync_status() {
    log_info "Sync Status"
    echo ""

    # Sync directory info
    if [[ -d "$SYNC_DIR" ]]; then
        local file_count=$(find "$SYNC_DIR" -type f | wc -l)
        local total_size=$(du -sh "$SYNC_DIR" 2>/dev/null | cut -f1)
        log_info "Sync Directory: $SYNC_DIR"
        log_info "Files: $file_count"
        log_info "Size: $total_size"
    else
        log_warning "Sync directory not found"
    fi

    echo ""

    # Latest context snapshot
    local latest_snapshot=$(find "$SYNC_DIR" -name "context-*.txt" -type f 2>/dev/null | sort -r | head -1)
    if [[ -n "$latest_snapshot" ]]; then
        log_success "Latest context snapshot: $latest_snapshot"
    else
        log_warning "No context snapshots found"
    fi

    echo ""

    # Checkpoint count
    if [[ -d "$SYNC_DIR/checkpoints" ]]; then
        local checkpoint_count=$(find "$SYNC_DIR/checkpoints" -maxdepth 1 -type d | wc -l)
        log_info "Checkpoints: $((checkpoint_count - 1))"
    fi
}

################################################################################
# Show help
################################################################################

show_help() {
    cat << EOF
Session Sync Utility for EM-Skill Distributed Orchestration

Usage: $0 [command] [options]

Commands:
    context                     Create and sync context snapshot
    files <file1> [file2] ...    Sync files to all sessions
    report <agent> <report>      Sync report from agent to techlead
    broadcast <message>          Broadcast message to all sessions
    checkpoint [name]            Create checkpoint
    restore <name>               Restore checkpoint info
    list-checkpoints             List available checkpoints
    cleanup [days]               Clean up old sync data (default: 7 days)
    status                       Show sync status
    help                         Show this help message

Examples:
    $0 context                           # Sync context snapshot
    $0 files README.md package.json      # Sync files to all sessions
    $0 report backend report.md          # Sync report from backend
    $0 broadcast "Sync point reached"    # Broadcast message
    $0 checkpoint pre-migration          # Create checkpoint
    $0 restore pre-migration             # Restore checkpoint
    $0 list-checkpoints                  # List checkpoints
    $0 cleanup 30                        # Clean up files older than 30 days

Session Name: $SESSION_NAME
Sync Directory: $SYNC_DIR

EOF
}

################################################################################
# Main
################################################################################

main() {
    local command=${1:-help}

    case "$command" in
        context)
            sync_context
            ;;
        files)
            shift
            sync_files "$@"
            ;;
        report)
            sync_report "$2" "$3"
            ;;
        broadcast)
            broadcast_message "$2"
            ;;
        checkpoint)
            checkpoint "$2"
            ;;
        restore)
            restore_checkpoint "$2"
            ;;
        list-checkpoints|ls)
            list_checkpoints
            ;;
        cleanup)
            cleanup_sync "${2:-7}"
            ;;
        status)
            sync_status
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

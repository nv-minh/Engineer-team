#!/bin/bash

################################################################################
# Initialize Agent Sessions for EM-Team Distributed Orchestration
#
# Description: Prepares all agent tmux windows for Claude Code agents
# Usage: ./scripts/init-agent-sessions.sh
################################################################################

set -euo pipefail

SESSION_NAME="claude-work"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

################################################################################
# Check session exists
################################################################################

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "❌ Session '$SESSION_NAME' not found"
    echo "Start with: ./scripts/distributed-orchestrator.sh start"
    exit 1
fi

################################################################################
# Initialize each agent window
################################################################################

log_info "Initializing agent sessions..."
echo ""

# Define agents and their triggers
declare -A agents=(
    ["backend"]="duck:backend"
    ["frontend"]="duck:frontend"
    ["database"]="duck:database"
)

for agent in "${!agents[@]}"; do
    trigger="${agents[$agent]}"

    log_info "Initializing $agent window..."

    # Send initialization commands to agent window
    tmux send-keys -t "$SESSION_NAME:$agent" "cd $(pwd)" C-m
    sleep 0.5

    # Check if Claude is already active (look for prompt)
    # If not active, this will just be a harmless command
    tmux send-keys -t "$SESSION_NAME:$agent" "echo 'Ready for $agent tasks (trigger: $trigger)'" C-m
    sleep 0.5

    # Optional: Auto-start queue monitor
    tmux send-keys -t "$SESSION_NAME:$agent" "bash distributed/session-queue-monitor.sh $agent &" C-m
    sleep 0.5

    log_success "$agent window initialized"
done

echo ""
log_success "All agent sessions initialized!"
echo ""
log_info "Session ready for distributed orchestration"
echo ""
log_info "Agent triggers:"
echo "  - backend:    duck:backend"
echo "  - frontend:   duck:frontend"
echo "  - database:   duck:database"
echo ""
log_info "Start delegation from techlead window (Ctrl+B 0)"

#!/bin/bash

################################################################################
# Auto-Delegation Script for EM-Team Distributed Orchestration
#
# Description: Orchestrates automatic task delegation from techlead to agents
# Usage: ./auto-delegate.sh "[task description]" "[agent1,agent2,agent3]"
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
# Validate prerequisites
################################################################################

validate_prerequisites() {
    log_info "Validating prerequisites..."

    # Check tmux session
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "Session '$SESSION_NAME' not running"
        log_info "Start with: ./scripts/distributed-orchestrator.sh start"
        return 1
    fi

    # Check directories
    if [[ ! -d "$QUEUE_DIR" ]]; then
        log_warning "Queue directory not found, creating..."
        mkdir -p "$QUEUE_DIR"/{to-backend,to-frontend,to-database,to-techlead,processed}
    fi

    if [[ ! -d "$SHARED_DIR" ]]; then
        log_warning "Shared directory not found, creating..."
        mkdir -p "$SHARED_DIR"/{backend,frontend,database,techlead}
    fi

    log_success "Prerequisites validated"
    return 0
}

################################################################################
# Generate task ID
################################################################################

generate_task_id() {
    echo "TASK-$(date +%Y%m%d-%H%M%S)"
}

################################################################################
# Create task assignment YAML
################################################################################

create_task_assignment() {
    local task_id="$1"
    local agent="$2"
    local task_description="$3"
    local priority="${4:-critical}"

    local task_file="$QUEUE_DIR/to-$agent/$task_id.yaml"
    local deadline=$(date -u -d '+1 hour' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+1H +%Y-%m-%dT%H:%M:%SZ)

    # Create agent-specific context
    local agent_context=""
    case "$agent" in
        backend)
            agent_context="Backend domain: APIs, database queries, server-side logic, performance optimization"
            ;;
        frontend)
            agent_context="Frontend domain: UI/UX, client-side logic, user experience, visual components"
            ;;
        database)
            agent_context="Database domain: Schema, queries, indexing, data integrity, migrations"
            ;;
        *)
            agent_context="General investigation"
            ;;
    esac

    cat > "$task_file" << EOF
message_type: task_assignment
timestamp: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
from: techlead
to: $agent
task_id: $task_id

task:
  title: "Investigate: $task_description"
  description: |
    $task_description

    Your domain context:
    $agent_context

    Analyze your domain and provide detailed findings including:
    - Issues found (grouped by severity: critical/high/medium/low)
    - Root cause analysis
    - Recommended fixes with effort estimates
    - Any dependencies on other domains

  priority: $priority
  scope:
    in_scope: "Domain-specific investigation focused on $agent"
    out_of_scope: "Other domains (handled by separate agents)"

  context:
    - "User request: $task_description"
    - "Coordinated by: techlead-orchestrator"
    - "Agent domain: $agent_context"
    - "Task ID: $task_id"

  expected_output:
    format: report
    location: "/tmp/claude-work-reports/$agent/$task_id-report.md"
    deadline: "$deadline"

  coordination:
    status_updates_every: "15 minutes"
    escalate_if_blocked_for: "30 minutes"
EOF

    log_success "Task assignment created: $task_file"
    echo "$task_file"
}

################################################################################
# Notify agent sessions
################################################################################

notify_agent_sessions() {
    local task_id="$1"
    local agents="$2"

    log_info "Notifying agent sessions..."

    for agent in ${agents//,/ }; do
        # Check if agent window exists
        if tmux list-windows -t "$SESSION_NAME" -F "#{window_name}" 2>/dev/null | grep -q "^${agent}$"; then
            # Send notification
            tmux send-keys -t "$SESSION_NAME:$agent" "echo '📋 New task assigned: $task_id'" C-m
            tmux send-keys -t "$SESSION_NAME:$agent" "echo '📂 Check queue: /tmp/claude-work-queue/to-$agent/'" C-m
            tmux send-keys -t "$SESSION_NAME:$agent" "echo '⏰ Deadline: $(date -u -d '+1 hour' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+1H +%Y-%m-%dT%H:%M:%SZ)'" C-m

            log_success "Notified $agent session"
        else
            log_warning "Agent session '$agent' not found in tmux"
        fi
    done
}

################################################################################
# Monitor progress
################################################################################

monitor_progress() {
    local task_id="$1"
    local agents="$2"
    local agent_array=(${agents//,/ })
    local total_agents=${#agent_array[@]}
    local completed_agents=0
    local timeout_seconds=7200  # 2 hours
    local start_time=$(date +%s)

    log_info "Monitoring progress for $task_id..."
    log_info "Tracking ${total_agents} agents: ${agent_array[*]}"

    while [[ $completed_agents -lt $total_agents ]]; do
        completed_agents=0
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))

        # Check timeout
        if [[ $elapsed -gt $timeout_seconds ]]; then
            log_error "Task $task_id timed out after $((elapsed / 60)) minutes"

            # Send timeout notification to techlead
            cat > "$QUEUE_DIR/to-techlead/TIMEOUT-$task_id.yaml" << EOF
message_type: error
timestamp: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
from: auto-delegate
to: techlead
task_id: $task_id

error:
  type: timeout
  message: "Task timed out after $((elapsed / 60)) minutes"
  recovery_action: "Check agent status or reassign task manually"
EOF

            return 1
        fi

        # Check each agent's completion
        for agent in "${agent_array[@]}"; do
            local report_file="$SHARED_DIR/$agent/$task_id-report.md"

            if [[ -f "$report_file" ]]; then
                ((completed_agents++))
            fi
        done

        if [[ $completed_agents -lt $total_agents ]]; then
            local elapsed_min=$((elapsed / 60))
            log_info "Progress: $completed_agents/$total_agents agents complete (${elapsed_min}m elapsed)"

            # Check for status updates
            if compgen -G "$QUEUE_DIR/to-techlead/STATUS-*-*.yaml" > /dev/null 2>&1; then
                for status_file in "$QUEUE_DIR/to-techlead/STATUS-"*"-*.yaml"; do
                    if [[ -f "$status_file" ]]; then
                        local status_agent=$(basename "$status_file" | sed 's/STATUS-\(.*\)-.*/\1/')
                        log_debug "Status update from $status_agent: $(basename "$status_file")"

                        # Move to processed
                        mv "$status_file" "$QUEUE_DIR/processed/"
                    fi
                done
            fi

            sleep 30  # Check every 30 seconds
        fi
    done

    log_success "All $total_agents agents completed!"
    return 0
}

################################################################################
# Trigger consolidation
################################################################################

trigger_consolidation() {
    local task_id="$1"
    local agents="$2"

    log_info "Triggering consolidation..."

    # Check if consolidate script exists
    local consolidate_script="./scripts/consolidate-reports.sh"
    if [[ ! -f "$consolidate_script" ]]; then
        log_warning "Consolidate script not found: $consolidate_script"
        log_info "Reports are available at: $SHARED_DIR/{backend,frontend,database}/"
        log_info "Manual consolidation required"

        # List available reports
        echo ""
        log_info "Available Reports:"
        for agent in ${agents//,/ }; do
            local report_file="$SHARED_DIR/$agent/$task_id-report.md"
            if [[ -f "$report_file" ]]; then
                echo "  📄 $agent: $report_file"
            fi
        done

        return 0
    fi

    # Run consolidation
    log_info "Running consolidation script..."
    bash "$consolidate_script" "$task_id" "$agents"

    if [[ $? -eq 0 ]]; then
        log_success "Consolidation complete!"

        # Show consolidated report location
        local consolidated_report="$SHARED_DIR/techlead/$task_id-consolidated.md"
        if [[ -f "$consolidated_report" ]]; then
            echo ""
            log_success "📊 Consolidated Report: $consolidated_report"
            log_info "View with: cat $consolidated_report"
        fi
    else
        log_error "Consolidation failed"
        return 1
    fi
}

################################################################################
# Main auto-delegate function
################################################################################

auto_delegate() {
    local task_description="$1"
    local agents="$2"
    local priority="${3:-critical}"

    log_info "════════════════════════════════════════════════════════════════"
    log_info "Auto-Delegation for EM-Team Distributed Orchestration"
    log_info "════════════════════════════════════════════════════════════════"
    echo ""

    # Validate prerequisites
    if ! validate_prerequisites; then
        log_error "Prerequisites validation failed"
        return 1
    fi

    # Generate task ID
    local task_id=$(generate_task_id)
    log_success "Task ID: $task_id"
    echo ""

    # Create task assignments for each agent
    log_info "Creating task assignments..."
    echo ""

    local agent_array=(${agents//,/ })
    for agent in "${agent_array[@]}"; do
        log_info "Creating assignment for $agent..."
        create_task_assignment "$task_id" "$agent" "$task_description" "$priority"
    done

    echo ""

    # Notify agent sessions
    notify_agent_sessions "$task_id" "$agents"

    echo ""
    log_success "Task delegation complete!"
    log_info "Task ID: $task_id"
    log_info "Agents: ${agent_array[*]}"
    log_info "Description: $task_description"
    echo ""

    # Monitor progress
    if monitor_progress "$task_id" "$agents"; then
        # Trigger consolidation
        echo ""
        trigger_consolidation "$task_id" "$agents"

        echo ""
        log_success "════════════════════════════════════════════════════════════════"
        log_success "Auto-Delegation Complete: $task_id"
        log_success "════════════════════════════════════════════════════════════════"
        return 0
    else
        log_error "Progress monitoring failed"
        return 1
    fi
}

################################################################################
# Show help
################################################################################

show_help() {
    cat << EOF
Auto-Delegation Script for EM-Team Distributed Orchestration

Usage: $0 "[task description]" "[agent1,agent2,agent3]" [priority]

Arguments:
    task_description    Description of the task to delegate (required)
    agents              Comma-separated list of agents (required)
                       Valid agents: backend, frontend, database
    priority            Task priority (optional, default: critical)
                       Valid priorities: critical, high, medium, low

Examples:
    $0 "Investigate login API latency" "backend,frontend,database"
    $0 "Analyze database performance" "database" high
    $0 "Review UI components" "frontend" medium

Session Name: $SESSION_NAME
Queue Directory: $QUEUE_DIR
Shared Directory: $SHARED_DIR

Process:
    1. Creates task assignment YAMLs for each agent
    2. Writes to /tmp/claude-work-queue/to-{agent}/
    3. Notifies agent sessions via tmux
    4. Monitors progress for agent completion
    5. Triggers consolidation when all agents finish

Output:
    Agent reports: /tmp/claude-work-reports/{agent}/
    Consolidated report: /tmp/claude-work-reports/techlead/

EOF
}

################################################################################
# Main
################################################################################

main() {
    if [[ $# -lt 1 ]]; then
        log_error "Insufficient arguments"
        echo ""
        show_help
        exit 1
    fi

    # Check for help command
    if [[ "$1" == "help" ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
        exit 0
    fi

    if [[ $# -lt 2 ]]; then
        log_error "Insufficient arguments"
        echo ""
        show_help
        exit 1
    fi

    local task_description="$1"
    local agents="$2"
    local priority="${3:-critical}"

    # Validate agents
    for agent in ${agents//,/ }; do
        if [[ ! "$agent" =~ ^(backend|frontend|database)$ ]]; then
            log_error "Invalid agent: $agent"
            log_info "Valid agents: backend, frontend, database"
            exit 1
        fi
    done

    # Validate priority
    if [[ ! "$priority" =~ ^(critical|high|medium|low)$ ]]; then
        log_error "Invalid priority: $priority"
        log_info "Valid priorities: critical, high, medium, low"
        exit 1
    fi

    # Run auto-delegation
    auto_delegate "$task_description" "$agents" "$priority"
}

# Run main
main "$@"

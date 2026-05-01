#!/bin/bash

################################################################################
# Auto-Refresh Progress Monitor
#
# Usage: ./scripts/watch-progress.sh [task_id]
################################################################################

TASK_ID="${1:-$(ls -t /tmp/claude-work-queue/to-*/*.yaml 2>/dev/null | head -1 | xargs -I {} basename {} .yaml)}"

clear
echo "🔄 Starting progress monitor for: $TASK_ID"
echo "   Press Ctrl+C to stop"
echo ""
sleep 2

while true; do
    clear
    bash /Users/abc/Desktop/EM-Skill/scripts/track-progress.sh "$TASK_ID"
    echo ""
    echo "🔄 Refreshing in 5 seconds... (Ctrl+C to stop)"
    sleep 5
done

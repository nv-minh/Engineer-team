#!/bin/bash
#
# EM-Team Issue Sprint Command
# Source: EM-Team GitHub Management
#
# Select issues, create GitHub Milestone, and generate sprint plan
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🏃 EM-Team Sprint Planning${NC}"
echo "==========================="
echo ""

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install: https://cli.github.com"
    exit 1
fi

SPRINT_NAME=${1:-""}

# Show existing milestones
echo "Existing milestones:"
gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/milestones \
    --jq '.[] | "  - \(.title) (due: \(.due_on // "no date"), open: \(.open_issues))"' 2>/dev/null || \
    echo "  (none)"
echo ""

# Show prioritized open issues without milestone
echo "Backlog (P0-P2, no milestone assigned):"
gh issue list --state open --limit 30 \
    --json number,title,labels,assignees,milestone \
    --jq '.[] | select(.milestone == null) | "  #\(.number) \(.title) [\(.labels | map(.name) | join(","))]"' \
    2>/dev/null | head -20 || gh issue list --state open --limit 20
echo ""

echo "To run AI-assisted sprint planning, use the github-issue-manager skill:"
echo ""
echo '  "Use the github-issue-manager skill to plan the next sprint"'
echo ""
echo "The skill will:"
echo "  1. Show prioritized backlog issues"
echo "  2. Help you define a sprint goal"
echo "  3. Select issues within team capacity"
echo "  4. Create a GitHub Milestone with due date"
echo "  5. Assign selected issues to the milestone"
echo "  6. Generate a sprint plan document at plans/sprint-N-plan.md"

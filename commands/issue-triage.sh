#!/bin/bash
#
# EM-Team Issue Triage Command
# Source: EM-Team GitHub Management
#
# List open issues and trigger AI-assisted triage workflow
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🏷️  EM-Team Issue Triage${NC}"
echo "========================="
echo ""

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install: https://cli.github.com"
    exit 1
fi

LIMIT=${1:-50}

echo "📋 Fetching open issues (limit: $LIMIT)..."
echo ""

# Count by label status
TOTAL=$(gh issue list --state open --limit $LIMIT --json number -q 'length' 2>/dev/null || echo "0")
UNLABELED=$(gh issue list --state open --limit $LIMIT --json number,labels \
    --jq '[.[] | select(.labels | length == 0)] | length' 2>/dev/null || echo "?")
UNASSIGNED=$(gh issue list --state open --limit $LIMIT --json number,assignees \
    --jq '[.[] | select(.assignees | length == 0)] | length' 2>/dev/null || echo "?")

echo "Open issues:  $TOTAL"
echo "Unlabeled:    $UNLABELED"
echo "Unassigned:   $UNASSIGNED"
echo ""

# Show recent issues
echo "Recent open issues:"
gh issue list --state open --limit 15 --json number,title,labels,assignees,createdAt \
    --jq '.[] | "  #\(.number) [\(.labels | map(.name) | join(","))] \(.title)"' 2>/dev/null || \
    gh issue list --state open --limit 15

echo ""
echo "To run AI-assisted triage on all open issues, use the github-issue-manager skill:"
echo ""
echo '  "Use the github-issue-manager skill to triage all open issues"'
echo ""
echo "The skill will:"
echo "  1. Analyze each issue's content"
echo "  2. Suggest labels (bug/feature/chore/security) and priority (P0-P3)"
echo "  3. Detect duplicates"
echo "  4. Suggest assignees from CODEOWNERS or git blame"
echo "  5. Apply changes after your approval"

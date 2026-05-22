#!/bin/bash
#
# EM-Team Issue Create Command
# Source: EM-Team GitHub Management
#
# Create a structured GitHub Issue from current context
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📋 EM-Team Issue Create${NC}"
echo "========================"
echo ""

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install: https://cli.github.com"
    exit 1
fi

ISSUE_TYPE=${1:-""}

echo "Issue type options:"
echo "  1) bug      - Something is broken"
echo "  2) feature  - New functionality"
echo "  3) task     - Technical/chore work"
echo ""

if [ -z "$ISSUE_TYPE" ]; then
    read -p "Select type (bug/feature/task): " ISSUE_TYPE
fi

echo ""

# Check for user template
if [ -f ".em-team/issue-template.md" ]; then
    echo -e "${GREEN}✓ Found custom issue template: .em-team/issue-template.md${NC}"
    echo ""
fi

echo "Use the github-issue-manager skill to create a structured issue:"
echo ""

case "$ISSUE_TYPE" in
    bug|1)
        echo '  "Use the github-issue-manager skill to create a bug issue for: [describe the bug]"'
        ;;
    feature|2)
        echo '  "Use the github-issue-manager skill to create a feature issue for: [describe the feature]"'
        ;;
    task|3)
        echo '  "Use the github-issue-manager skill to create a task issue for: [describe the task]"'
        ;;
    *)
        echo '  "Use the github-issue-manager skill to create an issue for: [describe the problem or feature]"'
        ;;
esac

echo ""
echo "Quick create (no template):"
echo "  gh issue create --title 'Issue title' --body 'Description'"

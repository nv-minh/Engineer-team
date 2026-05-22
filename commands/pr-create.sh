#!/bin/bash
#
# EM-Team PR Create Command
# Source: EM-Team GitHub Management
#
# Auto-generate PR with description from commits + diff + template
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔀 EM-Team PR Create${NC}"
echo "===================="
echo ""

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install: https://cli.github.com"
    exit 1
fi

# Check if PR already exists for this branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$CURRENT_BRANCH" =~ ^(main|master|develop)$ ]]; then
    echo -e "${RED}❌ Cannot create PR from main/master/develop branch${NC}"
    exit 1
fi

EXISTING_PR=$(gh pr list --head "$CURRENT_BRANCH" --json number -q '.[0].number' 2>/dev/null || echo "")
if [ -n "$EXISTING_PR" ]; then
    echo -e "${YELLOW}⚠  PR #$EXISTING_PR already exists for branch: $CURRENT_BRANCH${NC}"
    echo "  URL: $(gh pr view $EXISTING_PR --json url -q .url)"
    exit 0
fi

# Gather context
BASE_BRANCH=${1:-main}
COMMITS=$(git log origin/$BASE_BRANCH..HEAD --oneline 2>/dev/null || git log HEAD~5..HEAD --oneline)
DIFF_STAT=$(git diff origin/$BASE_BRANCH --stat 2>/dev/null | tail -1 || echo "")
ISSUE_NUMBER=$(echo "$CURRENT_BRANCH" | grep -oE '[0-9]+' | head -1 || echo "")

echo "Branch:   $CURRENT_BRANCH"
echo "Base:     $BASE_BRANCH"
[ -n "$ISSUE_NUMBER" ] && echo "Issue:    #$ISSUE_NUMBER"
echo ""
echo "Commits in this PR:"
echo "$COMMITS" | sed 's/^/  /'
echo ""
[ -n "$DIFF_STAT" ] && echo "Diff summary: $DIFF_STAT"
echo ""

# Check for user PR template
TEMPLATE_FILE=""
if [ -f ".em-team/pr-template.md" ]; then
    TEMPLATE_FILE=".em-team/pr-template.md"
    echo -e "${GREEN}✓ Using custom PR template: .em-team/pr-template.md${NC}"
elif [ -f ".github/pull_request_template.md" ]; then
    TEMPLATE_FILE=".github/pull_request_template.md"
    echo -e "${GREEN}✓ Using GitHub PR template: .github/pull_request_template.md${NC}"
fi

echo ""
echo "To create the PR with AI-generated description, use the github-pr-manager skill:"
echo ""
echo '  "Use the github-pr-manager skill to create a PR for this branch"'
echo ""
echo "Quick manual PR (no AI description):"
echo "  gh pr create --title 'Your title here' --fill"

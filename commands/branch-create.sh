#!/bin/bash
#
# EM-Team Branch Create Command
# Source: EM-Team GitHub Management
#
# Create a branch with smart naming from issue number or description
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🌿 EM-Team Branch Create${NC}"
echo "=========================="
echo ""

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

show_usage() {
    echo "Usage:"
    echo "  em-team branch-create <issue-number>          # branch from issue"
    echo "  em-team branch-create feat <description>      # feature branch"
    echo "  em-team branch-create fix <description>       # bug fix branch"
    echo "  em-team branch-create chore <description>     # chore branch"
    echo ""
    echo "Examples:"
    echo "  em-team branch-create 123"
    echo "  em-team branch-create feat add-user-authentication"
    echo "  em-team branch-create fix login-401-plus-email"
}

if [ -z "$1" ]; then
    show_usage
    exit 1
fi

# Slugify a string: lowercase, replace spaces/special chars with hyphens
slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g' | cut -c1-50
}

BRANCH_NAME=""

# Case 1: issue number provided
if [[ "$1" =~ ^[0-9]+$ ]]; then
    ISSUE_NUMBER="$1"

    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}⚠  gh not installed — using generic branch name${NC}"
        BRANCH_NAME="issue/${ISSUE_NUMBER}"
    else
        ISSUE_DATA=$(gh issue view "$ISSUE_NUMBER" --json title,labels 2>/dev/null || echo "")
        if [ -z "$ISSUE_DATA" ]; then
            echo -e "${RED}❌ Issue #$ISSUE_NUMBER not found${NC}"
            exit 1
        fi

        ISSUE_TITLE=$(echo "$ISSUE_DATA" | jq -r .title)
        ISSUE_LABEL=$(echo "$ISSUE_DATA" | jq -r '.labels[0].name // ""')

        # Determine prefix from label
        PREFIX="feat"
        case "$ISSUE_LABEL" in
            bug|bug*) PREFIX="fix" ;;
            chore|chore*|maintenance|dependencies) PREFIX="chore" ;;
            documentation|docs) PREFIX="docs" ;;
            security) PREFIX="security" ;;
            *feature*|*enhancement*) PREFIX="feat" ;;
        esac

        SLUG=$(slugify "$ISSUE_TITLE")
        BRANCH_NAME="${PREFIX}/${ISSUE_NUMBER}-${SLUG}"

        echo "Issue #$ISSUE_NUMBER: $ISSUE_TITLE"
        echo "Label: ${ISSUE_LABEL:-none} → prefix: $PREFIX"
    fi

# Case 2: type + description
elif [[ "$1" =~ ^(feat|fix|chore|docs|refactor|test|ci|security|perf)$ ]] && [ -n "$2" ]; then
    PREFIX="$1"
    shift
    SLUG=$(slugify "$*")
    BRANCH_NAME="${PREFIX}/${SLUG}"

# Case 3: just a description
else
    SLUG=$(slugify "$*")
    BRANCH_NAME="feat/${SLUG}"
fi

echo ""
echo "Branch name: $BRANCH_NAME"
echo ""

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
    echo -e "${YELLOW}⚠  Branch '$BRANCH_NAME' already exists${NC}"
    read -p "Switch to it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout "$BRANCH_NAME"
    fi
    exit 0
fi

# Update base branch
BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
echo "Base branch: $BASE_BRANCH"
git fetch origin "$BASE_BRANCH" --quiet

# Create and checkout
git checkout -b "$BRANCH_NAME" "origin/$BASE_BRANCH"
git push -u origin "$BRANCH_NAME"

echo ""
echo -e "${GREEN}✓ Created and pushed branch: $BRANCH_NAME${NC}"

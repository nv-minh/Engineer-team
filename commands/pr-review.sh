#!/bin/bash
#
# EM-Team PR Review Command
# Source: EM-Team GitHub Management
#
# Auto-assign reviewers from CODEOWNERS or git blame analysis
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}👥 EM-Team PR Review Assignment${NC}"
echo "================================="
echo ""

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    exit 1
fi

PR_NUMBER=${1:-$(gh pr view --json number -q .number 2>/dev/null || echo "")}

if [ -z "$PR_NUMBER" ]; then
    echo -e "${RED}❌ No open PR found. Specify PR number: em-team pr-review <PR_NUMBER>${NC}"
    exit 1
fi

PR_TITLE=$(gh pr view "$PR_NUMBER" --json title -q .title)
PR_URL=$(gh pr view "$PR_NUMBER" --json url -q .url)
CHANGED_FILES=$(gh pr view "$PR_NUMBER" --json files --jq '.files[].path' 2>/dev/null || echo "")

echo "PR #$PR_NUMBER: $PR_TITLE"
echo "URL: $PR_URL"
echo ""

# Strategy 1: CODEOWNERS
echo "🔍 Checking CODEOWNERS..."
SUGGESTED_REVIEWERS=()

if [ -f ".github/CODEOWNERS" ]; then
    echo "  Found .github/CODEOWNERS"
    while IFS= read -r file; do
        # Find owners for this file in CODEOWNERS
        OWNER=$(grep -E "^$file|^$(dirname $file)" .github/CODEOWNERS 2>/dev/null | tail -1 | awk '{for(i=2;i<=NF;i++) printf $i" "}' | tr -d '@' | xargs || echo "")
        if [ -n "$OWNER" ]; then
            SUGGESTED_REVIEWERS+=($OWNER)
        fi
    done <<< "$CHANGED_FILES"
else
    echo "  No CODEOWNERS file found"
fi

# Strategy 2: git blame fallback
if [ ${#SUGGESTED_REVIEWERS[@]} -eq 0 ] && [ -n "$CHANGED_FILES" ]; then
    echo "  Falling back to git blame analysis..."
    BLAME_AUTHORS=()
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            AUTHORS=$(git log --follow --format='%ae' -- "$file" 2>/dev/null | sort | uniq -c | sort -rn | head -2 | awk '{print $2}')
            BLAME_AUTHORS+=($AUTHORS)
        fi
    done <<< "$CHANGED_FILES"
    SUGGESTED_REVIEWERS=("${BLAME_AUTHORS[@]}")
fi

# Deduplicate and filter out current user
CURRENT_USER=$(gh api user -q .login 2>/dev/null || echo "")
UNIQUE_REVIEWERS=$(printf '%s\n' "${SUGGESTED_REVIEWERS[@]}" | sort -u | grep -v "$CURRENT_USER" | head -3)

echo ""
if [ -n "$UNIQUE_REVIEWERS" ]; then
    echo "Suggested reviewers:"
    echo "$UNIQUE_REVIEWERS" | sed 's/^/  @/'
    echo ""
    read -p "Add these reviewers to the PR? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        REVIEWER_LIST=$(echo "$UNIQUE_REVIEWERS" | tr '\n' ',' | sed 's/,$//')
        gh pr edit "$PR_NUMBER" --add-reviewer "$REVIEWER_LIST"
        echo -e "${GREEN}✓ Reviewers added: $REVIEWER_LIST${NC}"
    fi
else
    echo -e "${YELLOW}⚠  Could not automatically determine reviewers${NC}"
    echo "Add reviewers manually:"
    echo "  gh pr edit $PR_NUMBER --add-reviewer username1,username2"
fi

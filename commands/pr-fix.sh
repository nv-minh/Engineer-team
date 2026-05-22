#!/bin/bash
#
# EM-Team PR Review Fix Command
# Source: EM-Team GitHub Management
#
# Fetch PR review comments and trigger AI-assisted fix workflow
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔧 EM-Team PR Review Fix${NC}"
echo "========================="
echo ""

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install: https://cli.github.com"
    exit 1
fi

# Get PR number
if [ -n "$1" ]; then
    PR_NUMBER="$1"
else
    PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null || echo "")
fi

if [ -z "$PR_NUMBER" ]; then
    echo -e "${RED}❌ No open PR found for current branch${NC}"
    echo "Usage: em-team pr-fix [PR_NUMBER]"
    exit 1
fi

PR_URL=$(gh pr view "$PR_NUMBER" --json url -q .url)
PR_TITLE=$(gh pr view "$PR_NUMBER" --json title -q .title)
REVIEW_DECISION=$(gh pr view "$PR_NUMBER" --json reviewDecision -q .reviewDecision)

echo "PR #$PR_NUMBER: $PR_TITLE"
echo "URL: $PR_URL"
echo "Review decision: ${REVIEW_DECISION:-PENDING}"
echo ""

# Fetch inline comments
echo "📋 Fetching review comments..."
OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
COMMENT_COUNT=$(gh api "repos/$OWNER_REPO/pulls/$PR_NUMBER/comments" --jq 'length' 2>/dev/null || echo "0")
REVIEW_COUNT=$(gh pr view "$PR_NUMBER" --json reviews --jq '[.reviews[] | select(.state == "CHANGES_REQUESTED")] | length' 2>/dev/null || echo "0")

echo "  Inline comments: $COMMENT_COUNT"
echo "  Reviews requesting changes: $REVIEW_COUNT"
echo ""

if [ "$COMMENT_COUNT" -eq 0 ] && [ "$REVIEW_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ No review comments to address${NC}"
    exit 0
fi

# Save comments to temp file for AI processing
COMMENTS_FILE=".em-team/pr-${PR_NUMBER}-comments.json"
mkdir -p .em-team
gh api "repos/$OWNER_REPO/pulls/$PR_NUMBER/comments" > "$COMMENTS_FILE"
echo -e "${GREEN}✓ Comments saved to $COMMENTS_FILE${NC}"
echo ""

echo "To address review comments with AI assistance, use the github-pr-manager skill:"
echo ""
echo "  \"Use the github-pr-manager skill to fix review comments on PR #$PR_NUMBER\""
echo ""
echo "The skill will:"
echo "  1. Read each comment in context"
echo "  2. Propose fixes for your approval"
echo "  3. Apply fixes, commit, and reply to each comment"
echo "  4. Re-request review after all fixes are applied"

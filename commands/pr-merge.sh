#!/bin/bash
#
# EM-Team PR Merge Command
# Source: EM-Team GitHub Management
#
# Check all conditions then safely merge PR and delete branch
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}✅ EM-Team PR Merge${NC}"
echo "===================="
echo ""

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    exit 1
fi

PR_NUMBER=${1:-$(gh pr view --json number -q .number 2>/dev/null || echo "")}

if [ -z "$PR_NUMBER" ]; then
    echo -e "${RED}❌ No open PR found. Specify PR number: em-team pr-merge <PR_NUMBER>${NC}"
    exit 1
fi

PR_DATA=$(gh pr view "$PR_NUMBER" --json title,url,reviewDecision,isDraft,mergeable,statusCheckRollup,headRefName)
PR_TITLE=$(echo "$PR_DATA" | jq -r .title)
PR_URL=$(echo "$PR_DATA" | jq -r .url)
IS_DRAFT=$(echo "$PR_DATA" | jq -r .isDraft)
MERGEABLE=$(echo "$PR_DATA" | jq -r .mergeable)
REVIEW_DECISION=$(echo "$PR_DATA" | jq -r .reviewDecision)
HEAD_BRANCH=$(echo "$PR_DATA" | jq -r .headRefName)

echo "PR #$PR_NUMBER: $PR_TITLE"
echo "URL: $PR_URL"
echo ""
echo "Merge readiness:"

READY=true

# Check: not draft
if [ "$IS_DRAFT" = "true" ]; then
    echo -e "  ${RED}✗ PR is in draft state — mark as ready first${NC}"
    READY=false
else
    echo -e "  ${GREEN}✓ Not a draft${NC}"
fi

# Check: reviews approved
if [ "$REVIEW_DECISION" = "APPROVED" ]; then
    echo -e "  ${GREEN}✓ Reviews approved${NC}"
elif [ "$REVIEW_DECISION" = "CHANGES_REQUESTED" ]; then
    echo -e "  ${RED}✗ Changes requested — address review comments first (use /pr-fix)${NC}"
    READY=false
else
    echo -e "  ${YELLOW}⚠  Review status: ${REVIEW_DECISION:-PENDING}${NC}"
fi

# Check: mergeable
if [ "$MERGEABLE" = "MERGEABLE" ]; then
    echo -e "  ${GREEN}✓ No merge conflicts${NC}"
elif [ "$MERGEABLE" = "CONFLICTING" ]; then
    echo -e "  ${RED}✗ Merge conflicts — resolve conflicts first${NC}"
    READY=false
else
    echo -e "  ${YELLOW}⚠  Mergeability: $MERGEABLE${NC}"
fi

# Check: CI status
CI_STATUS=$(echo "$PR_DATA" | jq -r '.statusCheckRollup // [] | [.[] | select(.conclusion != null)] | if length == 0 then "NO_CHECKS" else (if all(.conclusion == "SUCCESS") then "SUCCESS" else "FAILED" end) end' 2>/dev/null || echo "UNKNOWN")
if [ "$CI_STATUS" = "SUCCESS" ]; then
    echo -e "  ${GREEN}✓ CI checks passed${NC}"
elif [ "$CI_STATUS" = "FAILED" ]; then
    echo -e "  ${RED}✗ CI checks failed — fix failing checks first${NC}"
    READY=false
elif [ "$CI_STATUS" = "NO_CHECKS" ]; then
    echo -e "  ${YELLOW}⚠  No CI checks configured${NC}"
else
    echo -e "  ${YELLOW}⚠  CI status: $CI_STATUS${NC}"
fi

echo ""

if [ "$READY" = "false" ]; then
    echo -e "${RED}❌ PR is not ready to merge. Fix the issues above first.${NC}"
    exit 1
fi

# Choose merge strategy
echo "Merge strategy:"
echo "  squash  (recommended) — squash all commits into one"
echo "  merge   — merge commit preserving history"
echo "  rebase  — rebase and fast-forward"
echo ""
STRATEGY=${2:-squash}
echo "Using strategy: $STRATEGY"
echo ""

read -p "Merge PR #$PR_NUMBER and delete branch '$HEAD_BRANCH'? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

case "$STRATEGY" in
    squash)
        gh pr merge "$PR_NUMBER" --squash --delete-branch
        ;;
    merge)
        gh pr merge "$PR_NUMBER" --merge --delete-branch
        ;;
    rebase)
        gh pr merge "$PR_NUMBER" --rebase --delete-branch
        ;;
    *)
        gh pr merge "$PR_NUMBER" --squash --delete-branch
        ;;
esac

echo ""
echo -e "${GREEN}✓ PR #$PR_NUMBER merged and branch '$HEAD_BRANCH' deleted${NC}"

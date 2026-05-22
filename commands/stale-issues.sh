#!/bin/bash
#
# EM-Team Stale Issues Command
# Source: EM-Team GitHub Management
#
# Find and manage stale GitHub issues (no activity > N days)
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🕸️  EM-Team Stale Issues${NC}"
echo "========================="
echo ""

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    exit 1
fi

STALE_DAYS=${1:-30}
CLOSE_DAYS=${2:-60}

echo "Stale threshold:  $STALE_DAYS days (will add 'stale' label)"
echo "Close threshold:  $CLOSE_DAYS days (will prompt to close)"
echo ""

# Calculate cutoff dates
STALE_DATE=$(date -v-${STALE_DAYS}d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
             date -d "$STALE_DAYS days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
             echo "")
CLOSE_DATE=$(date -v-${CLOSE_DAYS}d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
             date -d "$CLOSE_DAYS days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
             echo "")

echo "Fetching open issues..."
ALL_ISSUES=$(gh issue list --state open --limit 100 \
    --json number,title,updatedAt,labels,assignees \
    2>/dev/null || echo "[]")

TOTAL=$(echo "$ALL_ISSUES" | jq 'length')
echo "Total open issues: $TOTAL"
echo ""

if [ -z "$STALE_DATE" ]; then
    echo -e "${YELLOW}⚠  Could not calculate date threshold (date command varies by OS)${NC}"
    echo "Showing all open issues for manual review:"
    echo "$ALL_ISSUES" | jq -r '.[] | "  #\(.number) [updated: \(.updatedAt | split("T")[0])] \(.title)"'
    exit 0
fi

# Find stale issues (not updated since threshold)
STALE_ISSUES=$(echo "$ALL_ISSUES" | jq --arg date "$STALE_DATE" \
    '[.[] | select(.updatedAt < $date) | select(.labels | map(.name) | any(. == "pinned") | not)]')
STALE_COUNT=$(echo "$STALE_ISSUES" | jq 'length')

VERY_STALE_ISSUES=$(echo "$ALL_ISSUES" | jq --arg date "$CLOSE_DATE" \
    '[.[] | select(.updatedAt < $date) | select(.labels | map(.name) | any(. == "pinned") | not)]')
VERY_STALE_COUNT=$(echo "$VERY_STALE_ISSUES" | jq 'length')

echo "Stale (> $STALE_DAYS days): $STALE_COUNT"
echo "Very stale (> $CLOSE_DAYS days): $VERY_STALE_COUNT"
echo ""

if [ "$STALE_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ No stale issues found${NC}"
    exit 0
fi

echo "Stale issues:"
echo "$STALE_ISSUES" | jq -r '.[] | "  #\(.number) [updated: \(.updatedAt | split("T")[0])] \(.title)"'
echo ""

# Mark stale
if [ "$STALE_COUNT" -gt 0 ]; then
    read -p "Add 'stale' label to $STALE_COUNT issues and comment? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Ensure stale label exists
        gh label create stale --color "d4c5f9" --description "No activity for 30+ days" 2>/dev/null || true

        STALE_IDS=$(echo "$STALE_ISSUES" | jq -r '.[].number')
        while IFS= read -r issue_num; do
            gh issue edit "$issue_num" --add-label "stale" 2>/dev/null || true
            gh issue comment "$issue_num" \
                --body "This issue has been inactive for $STALE_DAYS+ days and has been marked as stale. If this is still relevant, please add a comment to keep it open. Issues with no further activity will be closed after $CLOSE_DAYS days." \
                2>/dev/null || true
            echo -e "  ${YELLOW}⚠  Marked #$issue_num as stale${NC}"
        done <<< "$STALE_IDS"
    fi
fi

# Prompt to close very stale
if [ "$VERY_STALE_COUNT" -gt 0 ]; then
    echo ""
    echo "Very stale issues (> $CLOSE_DAYS days, candidates for closing):"
    echo "$VERY_STALE_ISSUES" | jq -r '.[] | "  #\(.number) [updated: \(.updatedAt | split("T")[0])] \(.title)"'
    echo ""

    read -p "Close these $VERY_STALE_COUNT issues? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        VERY_STALE_IDS=$(echo "$VERY_STALE_ISSUES" | jq -r '.[].number')
        while IFS= read -r issue_num; do
            gh issue close "$issue_num" \
                --comment "Closing due to inactivity ($CLOSE_DAYS+ days). Please reopen if this is still relevant." \
                2>/dev/null || true
            echo -e "  ${RED}✗ Closed #$issue_num${NC}"
        done <<< "$VERY_STALE_IDS"
    fi
fi

echo ""
echo -e "${GREEN}✓ Stale issue management complete${NC}"

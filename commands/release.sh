#!/bin/bash
#
# EM-Team Release Command
# Source: EM-Team GitHub Management
#
# Bump version, generate release notes, tag, and create GitHub Release
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 EM-Team Release Manager${NC}"
echo "==========================="
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

# Verify clean working tree
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}❌ Working tree has uncommitted changes${NC}"
    echo "Commit or stash all changes before releasing."
    git status --short
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ ! "$CURRENT_BRANCH" =~ ^(main|master)$ ]]; then
    echo -e "${YELLOW}⚠  Not on main/master branch (currently on: $CURRENT_BRANCH)${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get current version
CURRENT_VERSION=""
if [ -f "package.json" ]; then
    CURRENT_VERSION=$(jq -r '.version' package.json 2>/dev/null || echo "")
elif [ -f "VERSION" ]; then
    CURRENT_VERSION=$(cat VERSION)
elif [ -f "pyproject.toml" ]; then
    CURRENT_VERSION=$(grep '^version' pyproject.toml | head -1 | sed 's/version = "//;s/"//')
fi

# Get latest git tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")

echo "Current version: ${CURRENT_VERSION:-unknown}"
echo "Latest git tag:  $LATEST_TAG"
echo "Branch:          $CURRENT_BRANCH"
echo ""

# Show unreleased commits
if [ "$LATEST_TAG" != "none" ]; then
    echo "Commits since $LATEST_TAG:"
    git log "${LATEST_TAG}..HEAD" --oneline | sed 's/^/  /'
else
    echo "Recent commits:"
    git log --oneline -10 | sed 's/^/  /'
fi
echo ""

echo "Version bump type:"
echo "  patch  - Bug fixes only (x.y.Z+1)"
echo "  minor  - New features, backwards compatible (x.Y+1.0)"
echo "  major  - Breaking changes (X+1.0.0)"
echo ""

BUMP_TYPE=${1:-""}
if [ -z "$BUMP_TYPE" ]; then
    read -p "Bump type (patch/minor/major): " BUMP_TYPE
fi

echo ""
echo "Use the github-release-manager skill to complete the release:"
echo ""
echo "  \"Use the github-release-manager skill to create a $BUMP_TYPE release\""
echo ""
echo "The skill will:"
echo "  1. Bump version in package.json / VERSION / pyproject.toml"
echo "  2. Extract release notes from CHANGELOG.md"
echo "  3. Commit the version bump"
echo "  4. Create and push git tag"
echo "  5. Create GitHub Release with notes and optional artifacts"

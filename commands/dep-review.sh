#!/bin/bash
#
# EM-Team Dependency Review Command
# Source: EM-Team GitHub Management
#
# Review new dependencies in a PR for security vulnerabilities and license issues
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔒 EM-Team Dependency Review${NC}"
echo "============================="
echo ""

# Check for package managers
if ! command -v npm &> /dev/null && ! command -v pip &> /dev/null; then
    echo -e "${RED}❌ Error: No supported package manager found (npm, pip)${NC}"
    exit 1
fi

PR_NUMBER=${1:-$(gh pr view --json number -q .number 2>/dev/null || echo "")}

if [ -n "$PR_NUMBER" ] && command -v gh &> /dev/null; then
    echo "Reviewing dependencies changed in PR #$PR_NUMBER..."
    echo ""

    # Get diff of dependency files
    DIFF=$(gh pr diff "$PR_NUMBER" -- package.json requirements.txt pyproject.toml go.mod Cargo.toml 2>/dev/null || echo "")

    if [ -z "$DIFF" ]; then
        echo -e "${GREEN}✓ No dependency file changes in this PR${NC}"
        exit 0
    fi

    echo "Changed dependency files:"
    gh pr view "$PR_NUMBER" --json files \
        --jq '.files[].path | select(test("package.json|requirements.txt|pyproject.toml|go.mod|Cargo.toml"))' \
        2>/dev/null | sed 's/^/  /'
    echo ""
fi

echo "Running security audit..."
echo ""

# Node.js
if [ -f "package.json" ] && command -v npm &> /dev/null; then
    echo "📦 npm audit:"
    npm audit --audit-level=moderate 2>/dev/null || true
    echo ""
fi

# Python
if [ -f "requirements.txt" ] && command -v pip &> /dev/null; then
    echo "🐍 Python dependencies:"
    if command -v pip-audit &> /dev/null; then
        pip-audit 2>/dev/null || true
    elif command -v safety &> /dev/null; then
        safety check 2>/dev/null || true
    else
        echo "  Install pip-audit for security scanning: pip install pip-audit"
        pip list --format=columns 2>/dev/null | head -20
    fi
    echo ""
fi

# Go
if [ -f "go.mod" ] && command -v go &> /dev/null; then
    echo "🔵 Go vulnerabilities:"
    if command -v govulncheck &> /dev/null; then
        govulncheck ./... 2>/dev/null || true
    else
        echo "  Install govulncheck for security scanning: go install golang.org/x/vuln/cmd/govulncheck@latest"
    fi
    echo ""
fi

echo "⚠  License check:"
echo "  Blocked licenses (require legal review): GPL-2.0, GPL-3.0, AGPL-3.0, LGPL"
echo "  Safe licenses: MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, CC0-1.0"
echo ""

if command -v license-checker &> /dev/null; then
    echo "License summary:"
    npx license-checker --summary --excludePrivatePackages 2>/dev/null | head -20 || true
else
    echo "  Install for license scanning: npm install -g license-checker"
fi

echo ""
echo "For a comprehensive AI-assisted dependency review, use the github-pr-manager skill:"
echo '  "Use the dep-review skill to review dependencies in PR #'$PR_NUMBER'"'

#!/bin/bash
#
# EM-Team Setup CI/CD Command
# Source: EM-Team GitHub Management
#
# Analyze codebase and generate .github/workflows/ci.yml
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}⚙️  EM-Team CI/CD Setup${NC}"
echo "========================"
echo ""

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Check if workflow already exists
if [ -f ".github/workflows/ci.yml" ]; then
    echo -e "${YELLOW}⚠  .github/workflows/ci.yml already exists${NC}"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo "🔍 Detecting tech stack..."
echo ""

# Detect stack
STACK=""
if [ -f "package.json" ]; then
    STACK="node"
    NODE_VERSION=$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1 || echo "20")
    HAS_TS=$([ -f "tsconfig.json" ] && echo "true" || echo "false")
    HAS_LINT=$(jq -r '.scripts.lint // empty' package.json 2>/dev/null)
    HAS_TYPECHECK=$(jq -r '.scripts.typecheck // .scripts["type-check"] // empty' package.json 2>/dev/null)
    HAS_BUILD=$(jq -r '.scripts.build // empty' package.json 2>/dev/null)
    TEST_CMD=$(jq -r '.scripts.test // "jest"' package.json 2>/dev/null)
    echo "  Stack:       Node.js $(node -v 2>/dev/null || echo 'v20')"
    echo "  TypeScript:  $HAS_TS"
    [ -n "$HAS_LINT" ] && echo "  Lint:        npm run lint"
    [ -n "$HAS_TYPECHECK" ] && echo "  Type check:  npm run typecheck"
    [ -n "$HAS_BUILD" ] && echo "  Build:       npm run build"
    echo "  Test:        npm test"
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    STACK="python"
    echo "  Stack: Python"
elif [ -f "go.mod" ]; then
    STACK="go"
    echo "  Stack: Go"
elif [ -f "Cargo.toml" ]; then
    STACK="rust"
    echo "  Stack: Rust"
elif [ -f "pom.xml" ]; then
    STACK="java-maven"
    echo "  Stack: Java (Maven)"
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    STACK="java-gradle"
    echo "  Stack: Java/Kotlin (Gradle)"
else
    echo -e "${RED}❌ Could not detect tech stack${NC}"
    echo "Supported: Node.js, Python, Go, Rust, Java"
    exit 1
fi

echo ""
echo "Use the github-cicd-setup skill to generate the full CI workflow:"
echo ""
echo '  "Use the github-cicd-setup skill to create a GitHub Actions CI pipeline for this project"'
echo ""
echo "Or invoke directly:"
echo '  Agent: executor - Use github-cicd-setup skill to set up CI for this '$STACK' project'

#!/bin/bash
# EM-Skill Agent Test Script
# Run this to verify all agents are properly registered

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 EM-SKILL AGENT VERIFICATION TEST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Validate JSON files
echo "📋 TEST 1: JSON File Validation"
echo "───────────────────────────────────────────────────────────"
if python3 -m json.tool ~/.claude/agents.json > /dev/null 2>&1; then
    echo "✅ agents.json - Valid"
    AGENTS=$(cat ~/.claude/agents.json | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
    echo "   📊 $AGENTS agents registered"
else
    echo "❌ agents.json - Invalid JSON"
fi

if python3 -m json.tool ~/.claude/workflows.json > /dev/null 2>&1; then
    echo "✅ workflows.json - Valid"
    WORKFLOWS=$(cat ~/.claude/workflows.json | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
    echo "   📊 $WORKFLOWS workflows registered"
else
    echo "❌ workflows.json - Invalid JSON"
fi

if python3 -m json.tool ~/.claude/skills.json > /dev/null 2>&1; then
    echo "✅ skills.json - Valid"
    SKILLS=$(cat ~/.claude/skills.json | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
    echo "   📊 $SKILLS skills registered"
else
    echo "❌ skills.json - Invalid JSON"
fi

echo ""
echo "📋 TEST 2: Agent Files Exist"
echo "───────────────────────────────────────────────────────────"
MISSING=0
cat ~/.claude/agents.json | python3 -c "
import json, sys
agents = json.load(sys.stdin)
for name, info in agents.items():
    import os
    if os.path.exists(info['file']):
        print(f'✅ /em-{name}')
    else:
        print(f'❌ /em-{name} - Missing: {info[\"file\"]}')
        global MISSING
        MISSING = 1
" 2>/dev/null

echo ""
echo "📋 TEST 3: Key Agents (Top 5)"
echo "───────────────────────────────────────────────────────────"
for agent in backend-expert frontend-expert database-expert performance-auditor techlead-orchestrator; do
    FILE=$(cat ~/.claude/agents.json | python3 -c "
import json, sys
agents = json.load(sys.stdin)
if '$agent' in agents:
    print(agents['$agent']['file'])
" 2>/dev/null)

    if [ -f "$FILE" ]; then
        echo "✅ /em-$agent"
    else
        echo "❌ /em-$agent - File missing"
    fi
done

echo ""
echo "📋 TEST 4: Terminal Command"
echo "───────────────────────────────────────────────────────────"
if [ -x ~/.claude/em-show-commands ]; then
    echo "✅ em-show-commands script is executable"

    # Test running it
    if bash ~/.claude/em-show-commands > /dev/null 2>&1; then
        echo "✅ em-show-commands runs successfully"
    else
        echo "❌ em-show-commands has errors"
    fi
else
    echo "❌ em-show-commands script not executable"
fi

echo ""
echo "📋 TEST 5: .zshrc Aliases"
echo "───────────────────────────────────────────────────────────"
if grep -q "alias em-='~/.claude/em-show-commands'" ~/.zshrc 2>/dev/null; then
    echo "✅ em- alias exists in .zshrc"

    if bash -n ~/.zshrc > /dev/null 2>&1; then
        echo "✅ .zshrc syntax is valid"
    else
        echo "❌ .zshrc has syntax errors"
    fi
else
    echo "❌ em- alias not found in .zshrc"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total Commands: $((AGENTS + WORKFLOWS + SKILLS))"
echo "  • Agents: $AGENTS"
echo "  • Workflows: $WORKFLOWS"
echo "  • Skills: $SKILLS"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 HOW TO USE IN CLAUDE CODE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Step 1: Restart Claude Code completely (quit and reopen)"
echo ""
echo "Step 2: In Claude Code conversation, type FULL command:"
echo ""
echo "  /em-backend-expert Review API performance"
echo "  /em-frontend-expert Check React components"
echo "  /em-database-expert Optimize database queries"
echo "  /em-performance-auditor Benchmark search queries"
echo "  /em-techlead-orchestrator Coordinate distributed investigation"
echo ""
echo "⚠️  NOTE: Autocomplete is LIMITED in Claude Code"
echo "   You may only see a few commands when typing /em"
echo "   This is normal - just type the FULL command name"
echo ""
echo "Step 3: View all commands in terminal:"
echo "  em-"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

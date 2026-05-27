#!/bin/bash
# install.sh — Install EM-Team globally for Claude Code (GSD-style)
# Copies content + creates /em/* slash commands. No symlinks.
# Usage: bash install.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CONTENT_DIR="$CLAUDE_DIR/em-team"
AGENT_CMDS_DIR="$CLAUDE_DIR/commands/em-agent"
WF_CMDS_DIR="$CLAUDE_DIR/commands/em-wf"
SKILL_CMDS_DIR="$CLAUDE_DIR/commands/em-skill"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[install]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║       EM-Team v5.5.0 Installer       ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ─── Step 1: Verify repo ───
if [[ ! -f "$REPO/CLAUDE.md" ]]; then
  err "Not an EM-Team repo (missing CLAUDE.md). Run from EM-Team root."
fi

info "Repo: $REPO"
info "Target: $CLAUDE_DIR"
echo ""

# ─── Step 2: Clean old installs ───
info "Cleaning old installs ..."

# Remove old content directory
if [[ -d "$CONTENT_DIR" ]]; then
  rm -rf "$CONTENT_DIR"
  ok "Removed old ~/.claude/em-team/"
fi

# Remove old command directories (old single em/ and new 3-way split)
for cmd_dir in "$CLAUDE_DIR/commands/em" "$AGENT_CMDS_DIR" "$WF_CMDS_DIR" "$SKILL_CMDS_DIR"; do
  if [[ -d "$cmd_dir" ]]; then
    rm -rf "$cmd_dir"
    ok "Removed old ${cmd_dir/#$HOME/~}/"
  fi
done

# Remove old skill symlinks (em:* and em-* directories with SKILL.md)
OLD_SKILLS=$(find "$CLAUDE_DIR/skills" -mindepth 1 -maxdepth 1 -type d -name 'em:*' -o -name 'em-*' 2>/dev/null || true)
if [[ -n "$OLD_SKILLS" ]]; then
  echo "$OLD_SKILLS" | while read -r dir; do
    rm -rf "$dir"
  done
  COUNT=$(echo "$OLD_SKILLS" | wc -l | tr -d ' ')
  ok "Removed $COUNT old skill directories"
fi

# Remove old config.json entries (skills/agents/workflows paths)
CONFIG="$CLAUDE_DIR/config.json"
if [[ -f "$CONFIG" ]] && command -v python3 &>/dev/null; then
  python3 - "$CONFIG" <<'PYEOF'
import json, sys
config_path = sys.argv[1]
try:
    with open(config_path) as f:
        cfg = json.load(f)
except Exception:
    cfg = {}
changed = False
for key in ['skills', 'agents', 'workflows']:
    if key in cfg:
        del cfg[key]
        changed = True
if changed:
    with open(config_path, 'w') as f:
        json.dump(cfg, f, indent=2)
        f.write('\n')
PYEOF
  ok "Cleaned old config.json entries"
fi

# ─── Step 3: Copy content to ~/.claude/em-team/ ───
info "Copying content to ~/.claude/em-team/ ..."

mkdir -p "$CONTENT_DIR"

# Copy agents, workflows, preambles, protocols, references
cp -R "$REPO/agents"       "$CONTENT_DIR/agents"
cp -R "$REPO/workflows"    "$CONTENT_DIR/workflows"
cp -R "$REPO/preambles"    "$CONTENT_DIR/preambles"
cp -R "$REPO/protocols"    "$CONTENT_DIR/protocols" 2>/dev/null || true
cp -R "$REPO/references"   "$CONTENT_DIR/references" 2>/dev/null || true

# Copy lib (session-audit, artifact-store, trace-store)
mkdir -p "$CONTENT_DIR/lib"
cp "$REPO/.claude/lib/session-audit.ts"   "$CONTENT_DIR/lib/" 2>/dev/null || true
cp "$REPO/.claude/lib/artifact-store.ts"  "$CONTENT_DIR/lib/" 2>/dev/null || true
cp "$REPO/.claude/lib/trace-store.ts"     "$CONTENT_DIR/lib/" 2>/dev/null || true

# Copy scripts (session-audit, artifact-register)
mkdir -p "$CONTENT_DIR/scripts"
cp "$REPO/scripts/session-audit.sh"       "$CONTENT_DIR/scripts/" 2>/dev/null || true
cp "$REPO/scripts/artifact-register.sh"   "$CONTENT_DIR/scripts/" 2>/dev/null || true

# Copy skills (preserve category structure)
mkdir -p "$CONTENT_DIR/skills"
find "$REPO/skills" -name '*.md' -not -name 'SKILL.md' | while read -r src; do
  relpath=${src#$REPO/skills/}
  destdir=$(dirname "$CONTENT_DIR/skills/$relpath")
  mkdir -p "$destdir"
  cp "$src" "$destdir/$(basename "$src")"
done

AGENT_COUNT=$(ls "$CONTENT_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
WORKFLOW_COUNT=$(ls "$CONTENT_DIR/workflows/"*.md 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find "$CONTENT_DIR/skills" -name '*.md' | wc -l | tr -d ' ')

ok "Content copied:"
ok "  $AGENT_COUNT agents"
ok "  $WORKFLOW_COUNT workflows"
ok "  $SKILL_COUNT skills"

# ─── Step 4: Create command wrappers ───
info "Creating slash commands in em-agent/, em-wf/, em-skill/ ..."

mkdir -p "$AGENT_CMDS_DIR" "$WF_CMDS_DIR" "$SKILL_CMDS_DIR"
CMD_COUNT=0

# Helper: resolve wrapper's "## Source" to get actual skill file path
resolve_source_path() {
  local wrapper="$1"
  grep -A2 '## Source' "$wrapper" | grep -oE '`[^`]+\.md`' | head -1 | tr -d '`'
}

# --- Agent commands (em-agent-*.md) ---
for wrapper in "$REPO/.claude/skills/"em-agent-*.md; do
  [[ ! -f "$wrapper" ]] && continue
  basename_w=$(basename "$wrapper" .md)    # e.g., em-agent-planner
  name="${basename_w#em-agent-}"           # e.g., planner

  # Get description from wrapper frontmatter
  desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
  [[ -z "$desc" ]] && desc="$name"

  # Determine source: check agents/ directory (canonical names only)
  source_file=""
  if [[ -f "$CONTENT_DIR/agents/$name.md" ]]; then
    source_file="agents/$name.md"
  fi

  if [[ -n "$source_file" ]]; then
    cat > "$AGENT_CMDS_DIR/$name.md" <<CMD
---
description: $desc
---
<execution_context>
@\$HOME/.claude/em-team/$source_file
</execution_context>
CMD
    CMD_COUNT=$((CMD_COUNT + 1))
  else
    # Standalone (checkpoint, health, quick, qa): copy wrapper content directly
    cat > "$AGENT_CMDS_DIR/$name.md" <<CMD
---
description: $desc
---
CMD
    sed '1,/^---$/d' "$wrapper" | sed '1,/^---$/d' >> "$AGENT_CMDS_DIR/$name.md"
    CMD_COUNT=$((CMD_COUNT + 1))
  fi
done

# --- Workflow commands (em-wf-*.md) ---
for wrapper in "$REPO/.claude/skills/"em-wf-*.md; do
  [[ ! -f "$wrapper" ]] && continue
  basename_w=$(basename "$wrapper" .md)    # e.g., em-wf-new-feature
  name="${basename_w#em-wf-}"              # e.g., new-feature

  desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
  [[ -z "$desc" ]] && desc="$name"

  # Determine source: check workflows/ directory, with one legacy rename
  source_file=""
  if [[ -f "$CONTENT_DIR/workflows/$name.md" ]]; then
    source_file="workflows/$name.md"
  elif [[ "$name" == "code-review" ]]; then
    source_file="workflows/code-review-9axis.md"
  fi

  if [[ -n "$source_file" ]]; then
    cat > "$WF_CMDS_DIR/$name.md" <<CMD
---
description: $desc
---
<execution_context>
@\$HOME/.claude/em-team/$source_file
</execution_context>
CMD
    CMD_COUNT=$((CMD_COUNT + 1))
  fi
done

# --- Skill commands (em-skill-*.md) ---
for wrapper in "$REPO/.claude/skills/"em-skill-*.md; do
  [[ ! -f "$wrapper" ]] && continue
  basename_w=$(basename "$wrapper" .md)    # e.g., em-skill-brainstorming
  name="${basename_w#em-skill-}"           # e.g., brainstorming

  # Resolve source path from wrapper (e.g., "skills/foundation/brainstorming/brainstorming.md")
  rel_source=$(resolve_source_path "$wrapper")

  if [[ -n "$rel_source" ]] && [[ -f "$CONTENT_DIR/$rel_source" ]]; then
    source_file="$rel_source"
  else
    found=$(find "$CONTENT_DIR/skills" -name "$name.md" | head -1)
    if [[ -n "$found" ]]; then
      source_file="${found#$CONTENT_DIR/}"
    else
      continue
    fi
  fi

  desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
  [[ -z "$desc" ]] && desc="$name"

  cat > "$SKILL_CMDS_DIR/$name.md" <<CMD
---
description: $desc
---
<execution_context>
@\$HOME/.claude/em-team/$source_file
</execution_context>
CMD
  CMD_COUNT=$((CMD_COUNT + 1))
done

ok "Created $CMD_COUNT slash commands"

# ─── Step 5: Verify ───
echo ""
info "Verifying installation ..."
echo ""

ERRORS=0

# Check content exists
if [[ -d "$CONTENT_DIR/agents" && -d "$CONTENT_DIR/workflows" && -d "$CONTENT_DIR/skills" ]]; then
  ok "  Content directory: $CONTENT_DIR"
else
  warn "  Content directory incomplete"
  ERRORS=$((ERRORS + 1))
fi

# Check commands exist
AGENT_TOTAL=$(ls "$AGENT_CMDS_DIR/"*.md 2>/dev/null | wc -l | tr -d ' ')
WF_TOTAL=$(ls "$WF_CMDS_DIR/"*.md 2>/dev/null | wc -l | tr -d ' ')
SKILL_TOTAL=$(ls "$SKILL_CMDS_DIR/"*.md 2>/dev/null | wc -l | tr -d ' ')
CMD_TOTAL=$((AGENT_TOTAL + WF_TOTAL + SKILL_TOTAL))
if [[ "$CMD_TOTAL" -gt 0 ]]; then
  ok "  $AGENT_TOTAL agent commands  → /em-agent:{name}"
  ok "  $WF_TOTAL workflow commands  → /em-wf:{name}"
  ok "  $SKILL_TOTAL skill commands   → /em-skill:{name}"
else
  warn "  No slash commands created"
  ERRORS=$((ERRORS + 1))
fi

# Check a sample agent command has @file reference (invocation key = em-agent:planner via directory)
SAMPLE="$AGENT_CMDS_DIR/planner.md"
if [[ -f "$SAMPLE" ]]; then
  if grep -q '@.*/em-team/' "$SAMPLE"; then
    ok "  @file reference valid  → /em-agent:planner"
  else
    warn "  @file reference missing in em-agent/planner.md"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check a sample workflow command (invocation key = em-wf:new-feature via directory)
SAMPLE_WF="$WF_CMDS_DIR/new-feature.md"
if [[ -f "$SAMPLE_WF" ]]; then
  if grep -q '@.*/em-team/' "$SAMPLE_WF"; then
    ok "  @file reference valid  → /em-wf:new-feature"
  else
    warn "  @file reference missing in em-wf/new-feature.md"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check a sample skill command (invocation key = em-skill:brainstorming via directory)
SAMPLE_SK="$SKILL_CMDS_DIR/brainstorming.md"
if [[ -f "$SAMPLE_SK" ]]; then
  if grep -q '@.*/em-team/' "$SAMPLE_SK"; then
    ok "  @file reference valid  → /em-skill:brainstorming"
  else
    warn "  @file reference missing in em-skill/brainstorming.md"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check lib files
LIB_COUNT=$(ls "$CONTENT_DIR/lib/"*.ts 2>/dev/null | wc -l | tr -d ' ')
if [[ "$LIB_COUNT" -gt 0 ]]; then
  ok "  $LIB_COUNT lib files (session-audit, artifact-store, trace-store)"
else
  warn "  No lib files copied"
fi

# ─── Summary ───
echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo -e "  ${GREEN}Installation complete!${NC}"
  echo ""
  echo "  Installed:"
  echo "    Content:  $CONTENT_DIR/ ($AGENT_COUNT agents, $WORKFLOW_COUNT workflows, $SKILL_COUNT skills)"
  echo "    Commands: $CMD_TOTAL slash commands across 3 namespaces"
  echo "      ~/.claude/commands/em-agent/  ($AGENT_TOTAL agents)"
  echo "      ~/.claude/commands/em-wf/     ($WF_TOTAL workflows)"
  echo "      ~/.claude/commands/em-skill/  ($SKILL_TOTAL skills)"
  echo ""
  echo "  Naming convention:"
  echo "    /em-agent:{name}  — AI specialist agents"
  echo "    /em-wf:{name}     — Multi-stage workflows"
  echo "    /em-skill:{name}  — Techniques and patterns"
  echo ""
  echo "  Next steps:"
  echo "    1. Restart Claude Code"
  echo "    2. Try: /em-agent:planner    Create implementation plan"
  echo "    3. Try: /em-skill:brainstorming   Explore feature ideas"
  echo "    4. Try: /em-wf:new-feature   Implement a feature end-to-end"
  echo ""
  echo "  To uninstall: bash $REPO/uninstall.sh"
else
  echo -e "  ${YELLOW}Installed with $ERRORS warnings.${NC}"
fi
echo ""

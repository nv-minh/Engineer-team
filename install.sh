#!/bin/bash
# install.sh — Install EM-Team globally for use in any Claude Code project
# Usage: bash install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$SCRIPT_DIR"
CONFIG="$HOME/.claude/config.json"
SKILLS_DIR="$HOME/.claude/skills"

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
echo "  ║       EM-Team v2.2.0 Installer       ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ─── Step 1: Verify repo exists ───
if [[ ! -f "$REPO/CLAUDE.md" ]]; then
  err "Not an EM-Team repo (missing CLAUDE.md). Run from EM-Team root."
fi

info "EM-Team repo: $REPO"
info "Config target: $CONFIG"
echo ""

# ─── Step 2: Ensure ~/.claude/ exists ───
mkdir -p "$HOME/.claude"
mkdir -p "$SKILLS_DIR"

# ─── Step 3: Update ~/.claude/config.json ───
info "Updating ~/.claude/config.json ..."

if [[ -f "$CONFIG" ]]; then
  # Read existing config (may have other settings like model, max_tokens)
  EXISTING=$(cat "$CONFIG")
else
  EXISTING='{}'
fi

if command -v python3 &>/dev/null; then
  python3 - "$CONFIG" "$REPO" <<'PYEOF'
import json, sys
config_path, repo = sys.argv[1], sys.argv[2]
try:
    with open(config_path) as f:
        cfg = json.load(f)
except Exception:
    cfg = {}
cfg.setdefault('assistant', {})
cfg['skills'] = {
    'enabled': True,
    'paths': [repo + '/.claude/skills'],
    'description': f'EM-Team v2.2.0 — 33 skills, 31 agents, 23 workflows. See: {repo}/CLAUDE.md'
}
cfg['agents'] = {
    'enabled': True,
    'paths': [repo + '/agents'],
    'description': f'EM-Team Agents — 31 specialized agents. See: {repo}/agents/'
}
cfg['workflows'] = {
    'enabled': True,
    'paths': [repo + '/workflows'],
    'description': f'EM-Team Workflows — 23 end-to-end workflows. See: {repo}/workflows/'
}
with open(config_path, 'w') as f:
    json.dump(cfg, f, indent=2)
    f.write('\n')
PYEOF
else
  err "Need python3 to update config.json. Install: brew install python3"
fi

ok "config.json updated — paths → $REPO"

# ─── Step 4: Create symlinks for skill wrappers ───
info "Creating skill symlinks in ~/.claude/skills/ ..."

# Helper: extract source path from wrapper's "## Source" section
# Returns the backtick-enclosed path, e.g. skills/foundation/brainstorming/brainstorming.md
extract_source_path() {
  local wrapper="$1"
  grep -A2 '## Source' "$wrapper" | grep -oE '`[^`]+\.md`' | head -1 | tr -d '`'
}

# Collect both em-*.md (agents/workflows) and em-skill-*.md (skills)
AGENT_FILES=($(ls "$REPO/.claude/skills/"em-*.md 2>/dev/null | grep -v 'em-skill-' || true))
SKILL_FILES=($(ls "$REPO/.claude/skills/"em-skill-*.md 2>/dev/null || true))
ALL_FILES=("${AGENT_FILES[@]}" "${SKILL_FILES[@]}")

if [[ ${#ALL_FILES[@]} -eq 0 ]]; then
  warn "No em-*.md or em-skill-*.md wrappers found in $REPO/.claude/skills/"
else
  AGENT_COUNT=0
  SKILL_COUNT=0
  SOURCE_LINKED=0

  for src in "${AGENT_FILES[@]}"; do
    basename=$(basename "$src" .md)
    skill_name="${basename#em-}"
    link_dir="$SKILLS_DIR/em:$skill_name"
    link_file="$link_dir/SKILL.md"

    if [[ -d "$link_dir" && ! -L "$link_dir" ]]; then
      rm -rf "$link_dir"
    fi

    mkdir -p "$link_dir"
    # Agent/workflow wrappers are self-contained — symlink directly
    ln -sf "$src" "$link_file"
    AGENT_COUNT=$((AGENT_COUNT + 1))
  done

  for src in "${SKILL_FILES[@]}"; do
    basename=$(basename "$src" .md)
    skill_name="${basename#em-skill-}"
    link_dir="$SKILLS_DIR/em:skill:$skill_name"
    link_file="$link_dir/SKILL.md"

    if [[ -d "$link_dir" && ! -L "$link_dir" ]]; then
      rm -rf "$link_dir"
    fi

    mkdir -p "$link_dir"

    # Skill wrappers have a "## Source" pointing to the full content file.
    # Resolve and symlink directly to source for maximum context.
    relative_source=$(extract_source_path "$src")
    if [[ -n "$relative_source" && -f "$REPO/$relative_source" ]]; then
      ln -sf "$REPO/$relative_source" "$link_file"
      SOURCE_LINKED=$((SOURCE_LINKED + 1))
    else
      # Fallback: symlink to wrapper (old behavior)
      ln -sf "$src" "$link_file"
    fi
    SKILL_COUNT=$((SKILL_COUNT + 1))
  done

  ok "Created $AGENT_COUNT agent/workflow symlinks (em:*) + $SKILL_COUNT skill symlinks (em:skill:*)"
  ok "  $SOURCE_LINKED/$SKILL_COUNT skills linked directly to source content"
fi

# ─── Step 5: Clean up orphaned flat symlinks ───
info "Cleaning up orphaned flat files (invalid skill format) ..."

ORPHANS_REMOVED=0
for candidate in "$SKILLS_DIR"/em-*; do
  if [[ -f "$candidate" && ! -L "$candidate" ]]; then
    rm -f "$candidate"
    ORPHANS_REMOVED=$((ORPHANS_REMOVED + 1))
  elif [[ -L "$candidate" ]]; then
    rm -f "$candidate"
    ORPHANS_REMOVED=$((ORPHANS_REMOVED + 1))
  fi
done

# Also clean orphaned em:skill:* directories from old installs
for candidate in "$SKILLS_DIR"/em:skill:*; do
  if [[ -d "$candidate" ]]; then
    link_file="$candidate/SKILL.md"
    if [[ ! -f "$link_file" ]] || [[ -L "$link_file" && ! -e "$link_file" ]]; then
      rm -rf "$candidate"
      ORPHANS_REMOVED=$((ORPHANS_REMOVED + 1))
    fi
  fi
done

if [[ "$ORPHANS_REMOVED" -gt 0 ]]; then
  ok "Removed $ORPHANS_REMOVED orphaned entries (will be recreated as em:*/SKILL.md or em:skill:*/SKILL.md)"
fi

# ─── Step 6: Verify installation ───
echo ""
info "Verifying installation ..."
echo ""

ERRORS=0

# Check config.json is valid JSON
if command -v jq &>/dev/null; then
  if ! jq empty "$CONFIG" 2>/dev/null; then
    err "  config.json is not valid JSON"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check paths point to correct repo
EXPECTED_SKILLS="$REPO/.claude/skills"
EXPECTED_AGENTS="$REPO/agents"
EXPECTED_WORKFLOWS="$REPO/workflows"

if grep -q "$EXPECTED_SKILLS" "$CONFIG" 2>/dev/null; then
  ok "  skills.paths  → $EXPECTED_SKILLS"
else
  warn "  skills.paths may not be set correctly"
  ERRORS=$((ERRORS + 1))
fi

if grep -q "$EXPECTED_AGENTS" "$CONFIG" 2>/dev/null; then
  ok "  agents.paths  → $EXPECTED_AGENTS"
else
  warn "  agents.paths may not be set correctly"
  ERRORS=$((ERRORS + 1))
fi

if grep -q "$EXPECTED_WORKFLOWS" "$CONFIG" 2>/dev/null; then
  ok "  workflows.paths → $EXPECTED_WORKFLOWS"
else
  warn "  workflows.paths may not be set correctly"
  ERRORS=$((ERRORS + 1))
fi

# Check symlinks (count unique em:* and em:skill:* directories)
SYMLINK_COUNT=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -name 'em:*' | wc -l | tr -d ' ')
BROKEN_LINKS=0
for dir in "$SKILLS_DIR"/em:*; do
  if [[ -d "$dir" && -L "$dir/SKILL.md" && ! -e "$dir/SKILL.md" ]]; then
    BROKEN_LINKS=$((BROKEN_LINKS + 1))
  fi
done

if [[ "$SYMLINK_COUNT" -gt 0 ]]; then
  ok "  $SYMLINK_COUNT skill symlinks active"
else
  warn "  No skill symlinks found"
fi

if [[ "$BROKEN_LINKS" -gt 0 ]]; then
  warn "  $BROKEN_LINKS broken symlinks detected"
  ERRORS=$((ERRORS + 1))
fi

# Check for remaining orphaned flat files
ORPHAN_COUNT=$(find "$SKILLS_DIR" -maxdepth 1 -name "em-*" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$ORPHAN_COUNT" -gt 0 ]]; then
  warn "  $ORPHAN_COUNT orphaned em-* entries found (run install.sh again to clean)"
  ERRORS=$((ERRORS + 1))
else
  ok "  No orphaned entries"
fi

# ─── Summary ───
echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo -e "  ${GREEN}Installation complete!${NC}"
  echo ""
  echo "  What's configured:"
  echo "    Skills:    $EXPECTED_SKILLS"
  echo "    Agents:    $EXPECTED_AGENTS"
  echo "    Workflows: $EXPECTED_WORKFLOWS"
  echo "    Symlinks:  $SYMLINK_COUNT total (em:* agents + em:skill:* skills)"
  echo ""
  echo "  Next steps:"
  echo "    1. Open any project in Claude Code"
  echo "    2. Type / to see all available EM-Team skills"
  echo "    3. Try: /em:quick fix typo in README"
  echo "    4. Try: /style-switcher to switch communication style"
  echo ""
  echo "  To uninstall: bash $REPO/uninstall.sh"
else
  echo -e "  ${YELLOW}Installed with $ERRORS warnings.${NC}"
  echo "  Check the output above for details."
fi
echo ""

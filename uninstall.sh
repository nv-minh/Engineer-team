#!/bin/bash
# uninstall.sh — Remove EM-Team global installation
# Usage: bash uninstall.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$SCRIPT_DIR"
CONFIG="$HOME/.claude/config.json"
SKILLS_DIR="$HOME/.claude/skills"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[uninstall]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║     EM-Team Uninstaller              ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ─── Step 1: Remove em:* symlinks from ~/.claude/skills/ ───
info "Removing em:* and em:skill:* symlinks ..."

REMOVED=0
for dir in "$SKILLS_DIR"/em:*; do
  if [[ -d "$dir" || -L "$dir" ]]; then
    rm -rf "$dir"
    REMOVED=$((REMOVED + 1))
  fi
done
ok "Removed $REMOVED em:* entries"

# ─── Step 1b: Remove orphaned em-* flat symlinks ───
info "Removing orphaned em-* and em-skill-* flat files ..."

REMOVED_FLAT=0
for candidate in "$SKILLS_DIR"/em-*; do
  if [[ -f "$candidate" || -L "$candidate" ]]; then
    rm -f "$candidate"
    REMOVED_FLAT=$((REMOVED_FLAT + 1))
  fi
done

if [[ "$REMOVED_FLAT" -gt 0 ]]; then
  ok "Removed $REMOVED_FLAT orphaned entries"
fi

# ─── Step 1c: Remove CLI wrapper if present ───
if [[ -f "$HOME/.local/bin/em-team" ]]; then
  rm -f "$HOME/.local/bin/em-team"
  ok "Removed ~/.local/bin/em-team CLI wrapper"
fi

# ─── Step 2: Clean config.json ───
info "Cleaning ~/.claude/config.json ..."

if [[ -f "$CONFIG" ]]; then
  if command -v jq &>/dev/null; then
    # Remove EM-Team paths, preserve other settings
    jq 'del(.skills, .agents, .workflows)' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
  elif command -v python3 &>/dev/null; then
    python3 -c "
import json
try:
    with open('$CONFIG') as f:
        cfg = json.load(f)
    cfg.pop('skills', None)
    cfg.pop('agents', None)
    cfg.pop('workflows', None)
    with open('$CONFIG', 'w') as f:
        json.dump(cfg, f, indent=2)
        f.write('\n')
except:
    pass
"
  fi
  ok "Cleaned config.json (preserved assistant settings)"
else
  warn "config.json not found, skipping"
fi

echo ""
echo -e "  ${GREEN}Uninstall complete.${NC}"
echo ""
echo "  Remaining:"
echo "    ~/.claude/config.json — assistant model settings preserved"
echo "    ~/.claude/skills/ — non-EM skills untouched"
echo ""
echo "  To reinstall: bash $REPO/install.sh"
echo ""

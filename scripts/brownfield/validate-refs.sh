#!/usr/bin/env bash
# Validate all cross-references in .em-brownfield/ are reachable.
# Usage: validate-refs.sh [brownfield-path]
# Exit code 0: all refs OK. Exit code 1: at least one broken ref.

set -euo pipefail
BF="${1:-.em-brownfield}"

if [[ ! -d "$BF" ]]; then
  echo "ERROR: $BF not found"
  exit 1
fi

broken=0
total=0

# Check module cross-refs [name](../name/FILE.md)
while IFS= read -r md_file; do
  [[ -z "$md_file" ]] && continue
  base_dir=$(dirname "$md_file")
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    total=$((total + 1))
    target=$(echo "$ref" | grep -oE '\([^)]+\)' | tr -d '()' | head -1 || true)
    [[ -z "$target" ]] && continue
    resolved="${base_dir}/${target}"
    if [[ ! -f "$resolved" ]]; then
      echo "BROKEN: $md_file → $target"
      broken=$((broken + 1))
    fi
  done < <(grep -oE '\[[^]]+\]\(\.\.\/[^)]+\)' "$md_file" 2>/dev/null || true)
done < <(find "$BF" -name "*.md" -type f 2>/dev/null || true)

# Collect defined flow IDs into a tmp file (no associative arrays for macOS bash 3.2 compat)
# A flow is "defined" if it appears in a "## Flow: ... (FLOW-X-NNN)" heading
# or via a "{#flow-flow-x-nnn}" anchor on a heading line.
DEFINED_FLOWS=$(mktemp)
trap "rm -f $DEFINED_FLOWS" EXIT
{
  grep -rhoE '^## Flow:.*\(FLOW-[A-Z_-]+-[0-9]+\)' "$BF" 2>/dev/null | grep -oE 'FLOW-[A-Z_-]+-[0-9]+' || true
  grep -rhE '^#+ .*\{#flow-' "$BF" 2>/dev/null | grep -oE 'FLOW-[A-Z_-]+-[0-9]+' || true
} | sort -u > "$DEFINED_FLOWS"

# Check every flow ID reference exists in defined set
while IFS= read -r flow_id; do
  [[ -z "$flow_id" ]] && continue
  total=$((total + 1))
  found=0
  grep -qx "$flow_id" "$DEFINED_FLOWS" && found=1 || found=0
  if [[ $found -eq 0 ]]; then
    echo "BROKEN FLOW REF: $flow_id is referenced but not defined"
    broken=$((broken + 1))
  fi
done < <(grep -rhoE 'FLOW-[A-Z_-]+-[0-9]+' "$BF" 2>/dev/null | sort -u || true)

echo "---"
echo "Total refs checked: $total"
echo "Broken refs: $broken"

[[ $broken -eq 0 ]] && exit 0 || exit 1

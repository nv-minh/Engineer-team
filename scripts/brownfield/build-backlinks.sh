#!/usr/bin/env bash
# Build .em-brownfield/BACKLINKS.json — reverse index of all cross-references.
# Usage: build-backlinks.sh [brownfield-path]

set -euo pipefail
BF="${1:-.em-brownfield}"

if [[ ! -d "$BF" ]]; then
  echo "{}"
  exit 0
fi

# Use associative arrays (requires bash 4+)
# Fallback: track refs as newline-separated strings in temp files
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

mkdir -p "$TMP/flows" "$TMP/acs" "$TMP/symbols"

# Scan all .md files for references
while IFS= read -r md_file; do
  [[ -z "$md_file" ]] && continue

  # Find FLOW-{MODULE}-{NNN} refs
  while IFS= read -r flow_id; do
    [[ -z "$flow_id" ]] && continue
    # Use base64 of ID as filename to be safe
    key=$(echo -n "$flow_id" | tr -c '[:alnum:]_-' '_')
    echo "$md_file" >> "$TMP/flows/$key"
  done < <(grep -oE 'FLOW-[A-Z_-]+-[0-9]+' "$md_file" 2>/dev/null | sort -u || true)

  # Find AC-{MODULE}-{NNN} refs
  while IFS= read -r ac_id; do
    [[ -z "$ac_id" ]] && continue
    key=$(echo -n "$ac_id" | tr -c '[:alnum:]_-' '_')
    echo "$md_file" >> "$TMP/acs/$key"
  done < <(grep -oE 'AC-[A-Z_-]+-[0-9]+' "$md_file" 2>/dev/null | sort -u || true)

  # Find module cross-refs: [name](../name/FILE.md)
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    target=$(echo "$ref" | grep -oE '\.\./[^/]+/[^)]+' | head -1 || true)
    [[ -z "$target" ]] && continue
    key=$(echo -n "$target" | tr -c '[:alnum:]_-' '_')
    echo "$md_file" >> "$TMP/symbols/$key"
  done < <(grep -oE '\[[^]]+\]\(\.\.\/[^)]+\)' "$md_file" 2>/dev/null | sort -u || true)
done < <(find "$BF" -name "*.md" -type f 2>/dev/null || true)

# Emit JSON
echo "{"
echo '  "schema_version": "5.4.0",'
echo "  \"generated_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","

# flow_refs
echo '  "flow_refs": {'
first=true
if [[ -d "$TMP/flows" ]]; then
  for keyfile in "$TMP/flows"/*; do
    [[ ! -f "$keyfile" ]] && continue
    key=$(basename "$keyfile")
    # Reconstruct ID from filename: replace _ back to original chars where possible
    # The original IDs are like FLOW-MODULE-001; the only non-alnum is -, which we preserved via tr
    refs=$(sort -u "$keyfile" | awk 'BEGIN{first=1} {if(first){first=0;printf "\""$0"\""}else{printf ",\""$0"\""}}')
    if [[ "$first" == true ]]; then
      first=false
    else
      echo "    ,"
    fi
    echo "    \"$key\": [$refs]"
  done
fi
echo '  },'

# ac_refs
echo '  "ac_refs": {'
first=true
if [[ -d "$TMP/acs" ]]; then
  for keyfile in "$TMP/acs"/*; do
    [[ ! -f "$keyfile" ]] && continue
    key=$(basename "$keyfile")
    refs=$(sort -u "$keyfile" | awk 'BEGIN{first=1} {if(first){first=0;printf "\""$0"\""}else{printf ",\""$0"\""}}')
    if [[ "$first" == true ]]; then
      first=false
    else
      echo "    ,"
    fi
    echo "    \"$key\": [$refs]"
  done
fi
echo '  }'

echo "}"

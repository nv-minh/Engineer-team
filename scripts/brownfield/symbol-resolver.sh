#!/usr/bin/env bash
# Resolve a symbol like "OrderService.create" or "createOrder" to file:line:signature.
# Outputs JSON: {"found": bool, "file": "...", "line": N, "signature": "..."}
# Falls back to grep-based heuristic if no LSP available.

set -euo pipefail

SYMBOL="${1:-}"
ROOT="${2:-.}"

if [[ -z "$SYMBOL" ]]; then
  echo '{"error": "Usage: symbol-resolver.sh <Symbol> [root]"}' >&2
  exit 1
fi

# Parse "Class.method" or "module.function" or bare "name"
CLASS=""
METHOD=""
if [[ "$SYMBOL" == *.* ]]; then
  CLASS="${SYMBOL%.*}"
  METHOD="${SYMBOL##*.}"
else
  METHOD="$SYMBOL"
fi

# Build search patterns per language
patterns=()
if [[ -n "$CLASS" ]]; then
  patterns+=(
    "class ${CLASS}"           # JS/TS/Java/C#/Python
    "${CLASS}\\.prototype\\.${METHOD}"
    "  ${METHOD}\\s*\\("       # TS/Java method in class
    "  ${METHOD}\\s*="         # arrow method
    "def ${METHOD}\\("         # Python
    "func \\(\\w+\\s+\\*?${CLASS}\\)\\s+${METHOD}\\("  # Go receiver
  )
else
  patterns+=(
    "class ${METHOD}\\b"
    "interface ${METHOD}\\b"
    "type ${METHOD}\\b"
    "enum ${METHOD}\\b"
    "function ${METHOD}"
    "const ${METHOD}"
    "def ${METHOD}\\("
    "func ${METHOD}\\("
    "fn ${METHOD}\\("
  )
fi

# Search across common source dirs, excluding node_modules/dist/build
search_dirs=("src" "apps" "packages" "lib" "internal" "pkg")
files_to_search=()
for dir in "${search_dirs[@]}"; do
  if [[ -d "${ROOT}/${dir}" ]]; then
    files_to_search+=("${ROOT}/${dir}")
  fi
done
[[ ${#files_to_search[@]} -eq 0 ]] && files_to_search+=("$ROOT")

best_file=""
best_line=""
best_signature=""

for pattern in "${patterns[@]}"; do
  while IFS=: read -r file line content; do
    [[ -z "$file" ]] && continue
    if [[ -z "$best_file" ]]; then
      best_file="$file"
      best_line="$line"
      best_signature="$content"
      # If we found a class declaration, keep looking for the method specifically
      if [[ -n "$CLASS" ]] && [[ "$content" == *"class ${CLASS}"* ]]; then
        # Find method line within file. Allow optional public/private/protected modifiers.
        # `|| true` keeps the pipeline safe under `set -e`/`pipefail` when grep finds no match.
        method_line=$(grep -nE "^\\s+(public|private|protected)?\\s*(async\\s+)?${METHOD}\\s*[(:=]" "$file" 2>/dev/null | head -1 | cut -d: -f1 || true)
        if [[ -n "$method_line" ]]; then
          best_line="$method_line"
          best_signature=$(sed -n "${method_line}p" "$file")
        fi
      fi
    fi
  done < <(grep -rnE "$pattern" "${files_to_search[@]}" \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" \
    --include="*.py" --include="*.go" --include="*.rs" --include="*.java" --include="*.kt" \
    --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=build --exclude-dir=.next \
    2>/dev/null || true)

  [[ -n "$best_file" ]] && break
done

if [[ -z "$best_file" ]]; then
  printf '{"found": false, "file": null, "line": null, "signature": null, "symbol": "%s"}\n' "$SYMBOL"
  exit 0
fi

# Escape JSON
escaped_signature=$(printf '%s' "$best_signature" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr -d '\r\n')
relative_file="${best_file#$ROOT/}"

printf '{"found": true, "file": "%s", "line": %s, "signature": "%s", "symbol": "%s"}\n' \
  "$relative_file" "$best_line" "$escaped_signature" "$SYMBOL"

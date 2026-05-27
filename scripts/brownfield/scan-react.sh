#!/usr/bin/env bash
# Scan React/Next.js/Vite project for routes and components.
# Usage: scan-react.sh [src_root]
# Output: JSON {routes: [...], components: [...]}

set -euo pipefail
SRC="${1:-apps/web/src}"

[[ ! -d "$SRC" ]] && { echo '{"routes": [], "components": []}'; exit 0; }

routes=()

# Next.js App Router: app/**/page.tsx
if [[ -d "$SRC/app" ]]; then
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    rel="${f#$SRC/}"
    route_path=$(echo "$rel" | sed 's/^app//; s/\/page\.\(tsx\|jsx\|js\|ts\)$//; s/\[\(\w*\)\]/:\1/g')
    [[ -z "$route_path" ]] && route_path="/"
    routes+=("{\"path\": \"$route_path\", \"file\": \"$f\", \"type\": \"next-app\"}")
  done < <(find "$SRC/app" \( -name "page.tsx" -o -name "page.jsx" -o -name "page.js" -o -name "page.ts" \) 2>/dev/null || true)
fi

# Next.js Pages Router: pages/**/*.tsx (excluding _*.tsx and api/)
if [[ -d "$SRC/pages" ]]; then
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    rel="${f#$SRC/}"
    basename_no_ext=$(basename "$f" | sed 's/\.\(tsx\|jsx\|js\|ts\)$//')
    [[ "$basename_no_ext" == _* ]] && continue
    route_path=$(echo "$rel" | sed 's/^pages//; s/\.\(tsx\|jsx\|js\|ts\)$//; s/\/index$/\//; s/\[\(\w*\)\]/:\1/g')
    routes+=("{\"path\": \"$route_path\", \"file\": \"$f\", \"type\": \"next-pages\"}")
  done < <(find "$SRC/pages" -type f \( -name "*.tsx" -o -name "*.jsx" -o -name "*.js" -o -name "*.ts" \) -not -path "*/api/*" 2>/dev/null || true)
fi

# Vite + React Router: search for path: 'X' / path="X" in tsx/jsx files
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    path=$(echo "$line" | grep -oE "path:\s*['\"][^'\"]+['\"]|path=['\"][^'\"]+['\"]" | grep -oE "'[^']+'|\"[^\"]+\"" | head -1 | tr -d "'\"" || true)
    [[ -n "$path" ]] && routes+=("{\"path\": \"$path\", \"file\": \"$f\", \"type\": \"react-router\"}")
  done < <(grep -nE "path:\s*['\"]|path=['\"]" "$f" 2>/dev/null || true)
done < <(find "$SRC" -type f \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | head -50 || true)

# Components (top-level src/components/*)
components=()
if [[ -d "$SRC/components" ]]; then
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    name=$(basename "$f" | sed 's/\.\(tsx\|jsx\|js\|ts\)$//')
    components+=("{\"name\": \"$name\", \"file\": \"$f\"}")
  done < <(find "$SRC/components" -maxdepth 3 \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | head -100 || true)
fi

if [[ ${#routes[@]} -gt 0 ]]; then
  routes_json=$(IFS=,; echo "${routes[*]}")
else
  routes_json=""
fi
if [[ ${#components[@]} -gt 0 ]]; then
  components_json=$(IFS=,; echo "${components[*]}")
else
  components_json=""
fi

echo "{\"routes\": [$routes_json], \"components\": [$components_json]}"
